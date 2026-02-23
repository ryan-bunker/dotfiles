#!/usr/bin/env bash

set -eou pipefail

# --- Configuration ---
LAB_TF_DIR="terraform/lab"
KUBE_CONFIG="lab-kube-config"

# VM names, must match terraform config
VM_NAMES=(
    "k8s-node-0"
    "k8s-node-1"
    "k8s-node-2"
)

# --- Styling & Helpers ---
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ICON_VM="🖥️"
ICON_WAIT="⏳"
ICON_DESTROY="🔥"
ICON_DOWN="💤"
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

# --- Main Logic ---

# Check for --destroy flag
DESTROY=false
if [[ "${1-}" == "--destroy" ]]; then
    DESTROY=true
fi

# Shutdown loop
for vm_name in "${VM_NAMES[@]}"; do
    log "$ICON_VM" "Checking node: ${vm_name}"

    state=$(virsh domstate "$vm_name" 2>/dev/null || echo "not found")

    if [[ "$state" == "running" ]]; then
        log "$ICON_WAIT" "Shutting down VM ${vm_name}..."
        virsh shutdown "$vm_name" >/dev/null
    elif [[ "$state" == "shut off" ]];
        then log "$ICON_DOWN" "VM ${vm_name} is already shut off."
    else
        warn "VM ${vm_name} not found or in an unexpected state: '$state'. Skipping."
    fi
done

# If --destroy flag is set, tear down infrastructure
if [ "$DESTROY" = true ]; then
    echo ""
    warn "---------------------------------------------------------"
    warn "You are about to destroy the entire lab infrastructure."
    warn "This action is irreversible."
    warn "---------------------------------------------------------"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "$ICON_DESTROY" "Waiting for VMs to shut down completely..."
        for vm_name in "${VM_NAMES[@]}"; do
            while [[ "$(virsh domstate "$vm_name" 2>/dev/null)" == "running" ]]; do
                sleep 2
            done
        done
        
        log "$ICON_DESTROY" "Destroying Terraform infrastructure..."
        tofu -chdir="$LAB_TF_DIR" destroy -auto-approve

        if [ -f "$KUBE_CONFIG" ]; then
            log "$ICON_DESTROY" "Removing kubeconfig file..."
            rm "$KUBE_CONFIG"
        fi
        
        success "Lab environment destroyed."
    else
        log "$ICON_CHECK" "Destroy action cancelled."
    fi
fi

if [ "$DESTROY" = false ]; then
    success "Lab VMs are shut down."
fi

