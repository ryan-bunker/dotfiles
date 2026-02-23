#!/usr/bin/env bash

set -eou pipefail

# --- Configuration ---
if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <TARGET_HOST> <TARGET_SYSTEM> <FINAL_IP>"
	echo "Example: $0 192.168.122.27 lab-kube-1 10.17.0.10"
	exit 1
fi

TARGET_HOST=$1
TARGET_SYSTEM=$2
FINAL_IP=$3

# --- Styling & Helpers ---
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ICON_KEY="🔑"
ICON_INSTALL="💾"
ICON_SECURE="🛡️"
ICON_WAIT="⏳"
ICON_SUCCESS="🚀"
ICON_INFO="ℹ️"

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

# --- Main Script ---

log "$ICON_KEY" "Generating temporary disk key..."
DISK_KEY=$(mktemp)
head -c 32 /dev/urandom | base64 | tr -d '\n' > "$DISK_KEY"

MY_FILES=$(mktemp -d)
mkdir -p "${MY_FILES}/persist/var/lib/sbctl"
mkdir -p "${MY_FILES}/persist/var/lib/sops-nix"
cp ~/.config/sops/age/keys.txt "${MY_FILES}/persist/var/lib/sops-nix/keys.txt"

DEFAULT_SBCTL="/var/lib/sbctl"
TARGET_DIR="${MY_FILES}/persist/var/lib/sbctl"

if [ -d "$DEFAULT_SBCTL" ]; then
	warn "$DEFAULT_SBCTL already exists on this host!"
	warn "I will not overwrite your host keys. Please backup or remove them manually."
	exit 1
fi

log "$ICON_KEY" "Generating Secure Boot keys..."
nix shell nixpkgs#sbctl --command sudo sbctl create-keys >/dev/null 2>&1

log "$ICON_KEY" "Staging keys for persistence..."
sudo mv "$DEFAULT_SBCTL"/* "$TARGET_DIR"
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR"
sudo rmdir "$DEFAULT_SBCTL" 2>/dev/null || true

# Mirror keys for installation phase (so installer can find them before persist mount)
mkdir -p "${MY_FILES}/var/lib"
cp -r "${MY_FILES}/persist/var/lib/sbctl" "${MY_FILES}/var/lib/"

log "$ICON_INSTALL" "Starting NixOS installation on ${TARGET_HOST}..."
NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	nix run github:nix-community/nixos-anywhere -- \
	--flake ./nix#${TARGET_SYSTEM} \
	--extra-files "$MY_FILES" \
	--disk-encryption-keys /tmp/disk.key "$DISK_KEY" \
	--no-reboot \
	root@${TARGET_HOST}

# clear any cached SSH keys for the installer IP
ssh-keygen -R ${TARGET_HOST} >/dev/null 2>&1 || true

log "$ICON_SECURE" "Enrolling initial TPM keys (pre-reboot)..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${TARGET_HOST} "bash -s" << 'EOF'
	set -e

	echo "  -> Enrolling Secure Boot keys..."
	nixos-enter --root /mnt -- sbctl enroll-keys --yes-this-might-brick-my-machine >/dev/null 2>&1

	echo "  -> Enrolling TPM (binding to presence only for first boot)..."
	cp /tmp/disk.key /mnt/tmp/disk.key
	nixos-enter --root /mnt -- systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="" /dev/disk/by-partlabel/disk-main-root --unlock-key-file=/tmp/disk.key >/dev/null 2>&1

	rm /mnt/tmp/disk.key

	echo "  -> Rebooting system..."
	reboot
EOF

log "$ICON_WAIT" "Waiting for server to reboot at ${FINAL_IP}..."
# Loop until SSH is available
while ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ryan@${FINAL_IP} "true" >/dev/null 2>&1; do
	sleep 5
done

log "$ICON_SECURE" "Server online. Configuring post-reboot security..."

# Copy the disk key to the server to authorize the enrollment
# We use cat | ssh because SFTP is disabled on the hardened server
# We use chmod u=rw,go= to secure the key file immediately, avoiding cryptenroll warnings
cat "$DISK_KEY" | ssh ryan@${FINAL_IP} "cat > /tmp/disk.key && chmod u=rw,go= /tmp/disk.key"

# Enroll with the key file
ssh -t ryan@${FINAL_IP} "
	set -e
	echo '  -> Enrolling TPM with PCR 7 (Secure Boot)...'
	# Use sudo to run cryptenroll, using the uploaded key file for auth
	sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-root \
		--wipe-slot=tpm2 \
		--tpm2-device=auto \
		--tpm2-pcrs=7 \
		--unlock-key-file=/tmp/disk.key >/dev/null 2>&1

	rm /tmp/disk.key
"

# Cleanup
rm "$DISK_KEY"
rm -rf "$MY_FILES"

success "Deployment of ${TARGET_SYSTEM} complete! SSH access ready at ryan@${FINAL_IP}"
