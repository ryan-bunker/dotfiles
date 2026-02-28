#!/usr/bin/env bash

set -eou pipefail

# --- Configuration ---
LAB_TF_DIR="terraform/lab"
KUBE_CONFIG="lab-kube-config"

# Nodes config: "VM_NAME:FLAKE_SYSTEM:FINAL_IP"
NODES=(
    "k8s-node-0:lab-kube-1:10.17.0.10"
    "k8s-node-1:lab-kube-2:10.17.0.11"
    "k8s-node-2:lab-kube-3:10.17.0.12"
)

# --- Styling & Helpers ---
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ICON_BUILD="🏗️"
ICON_TF="🧱"
ICON_VM="🖥️"
ICON_WAIT="⏳"
ICON_DEPLOY="🚀"
ICON_K8S="☸️"
ICON_SKIP="⏩"
ICON_CHECK="✅"

log() {
    local icon=$1
    local msg=$2
    echo -e "${BOLD}${BLUE}[$(date +'%H:%M:%S')]${RESET} ${icon}  ${BOLD}${msg}${RESET}"
}

warn() {
    echo -e "${BOLD}${YELLOW}[WARNING] $1${RESET}"
}

success() {
    echo -e "${BOLD}${GREEN}[SUCCESS] $1${RESET}"
}

get_vm_ip() {
    local vm_name=$1
    # Query libvirt network 'homelab-internal' for the MAC/IP of the VM
    # We grep for the name, but since leases don't always have names, we might need MAC.
    # However, for a fresh VM booting installer, it usually requests DHCP.
    
    # Simple retry loop to get IP
    local ip=""
    for i in {1..30}; do
        # Try to find IP in lease file associated with the VM's MAC
        # First get MAC address
        local mac=$(virsh domiflist "$vm_name" | awk '/virtio/ {print $5}')
        if [ -n "$mac" ]; then
            ip=$(virsh net-dhcp-leases homelab-internal | grep "$mac" | awk '{print $5}' | cut -d'/' -f1)
        fi
        
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
        sleep 2
    done
    return 1
}

# --- Main Logic ---

# 1. Build & Update Terraform Config
log "$ICON_BUILD" "Building Terraform configuration from Nix..."
nix build ./nix#lab_tf
# Ensure we copy the file content, not just the symlink, to be safe
cp -L result "${LAB_TF_DIR}/main.tf.json"

# 2. Apply Infrastructure
log "$ICON_TF" "Applying infrastructure state..."
# Check if there are changes first (optimization)
if tofu -chdir="$LAB_TF_DIR" plan -detailed-exitcode >/dev/null 2>&1; then
    log "$ICON_SKIP" "Infrastructure is up to date."
else
    tofu -chdir="$LAB_TF_DIR" apply -auto-approve >/dev/null
    log "$ICON_CHECK" "Infrastructure updated."
fi

# 3. Process Nodes
for node_def in "${NODES[@]}"; do
    IFS=':' read -r vm_name system_name final_ip <<< "$node_def"
    
    log "$ICON_VM" "Checking node: ${vm_name} (${system_name})"

    # Check if VM is running
    state=$(virsh domstate "$vm_name" 2>/dev/null || echo "shut off")
    if [[ "$state" != "running" ]]; then
        log "$ICON_WAIT" "Starting VM ${vm_name}..."
        virsh start "$vm_name" >/dev/null
    fi

    # Check if already deployed (SSH reachable on FINAL_IP)
    if ssh -o ConnectTimeout=2 -o BatchMode=yes "ryan@${final_ip}" "true" >/dev/null 2>&1; then
        log "$ICON_SKIP" "Node ${system_name} is already reachable at ${final_ip}. Skipping deployment."
    else
        log "$ICON_WAIT" "Node not reachable at ${final_ip}. Assuming fresh deployment needed."
        
        # Wait for Initial IP (Installer)
        log "$ICON_WAIT" "Waiting for installer IP address..."
        installer_ip=$(get_vm_ip "$vm_name")
        
        if [ -z "$installer_ip" ]; then
            warn "Could not get IP for $vm_name. Is it booting the installer?"
            exit 1
        fi
        
        log "$ICON_DEPLOY" "Found installer at ${installer_ip}. Starting deployment..."
        ./scripts/deploy-server.sh "$installer_ip" "$system_name" "$final_ip"
    fi
done

# 4. Fetch Kubeconfig (Only if primary master is up)
PRIMARY_IP="10.17.0.10"
if [ ! -f "$KUBE_CONFIG" ]; then
    log "$ICON_K8S" "Fetching kubeconfig from ${PRIMARY_IP}..."
    if ssh -o ConnectTimeout=5 "ryan@${PRIMARY_IP}" "true" >/dev/null 2>&1; then
        # The k3s.yaml is readable by the user, so no sudo is needed.
        # We also remove the '-t' flag as no interactive TTY is required.
        ssh "ryan@${PRIMARY_IP}" "cat /etc/rancher/k3s/k3s.yaml" > "$KUBE_CONFIG"
        
        # Fix IP
        sed -i "s/127.0.0.1/${PRIMARY_IP}/g" "$KUBE_CONFIG"
        chmod 600 "$KUBE_CONFIG"
        log "$ICON_CHECK" "Kubeconfig saved to ./${KUBE_CONFIG}"
    else
        warn "Primary master ${PRIMARY_IP} not reachable. Skipping kubeconfig fetch."
    fi
else
    log "$ICON_SKIP" "Kubeconfig already exists."
fi

export KUBECONFIG=$(pwd)/$KUBE_CONFIG

# 5. Inject SOPS Key
if [ -f ~/.config/sops/age/keys.txt ]; then
    log "$ICON_KEY" "Injecting SOPS age key into cluster..."
    # Ensure namespace exists (it's also in manifests, but we need it for the secret now)
    kubectl create namespace sops-system --dry-run=client -o yaml | kubectl apply -f - >/dev/null

    kubectl create secret generic sops-age \
        --namespace=sops-system \
        --from-file=keys.txt=$HOME/.config/sops/age/keys.txt \
        --dry-run=client -o yaml | kubectl apply -f - >/dev/null
    log "$ICON_CHECK" "SOPS key injected."
else
    warn "SOPS key not found at ~/.config/sops/age/keys.txt. Secret decryption will fail!"
fi

# 6. Apply Workloads
log "$ICON_K8S" "Applying Kubernetes workloads via Nixidy..."
nixidy apply ./nix#dev >/dev/null
log "$ICON_CHECK" "Workloads applied."

echo ""
success "Lab environment is UP!"
echo -e "${BOLD}To access the cluster, run:${RESET}"
echo -e "  ${BLUE}export KUBECONFIG=$(pwd)/${KUBE_CONFIG}${RESET}"
