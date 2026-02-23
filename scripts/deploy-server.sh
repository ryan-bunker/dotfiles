#!/usr/bin/env bash

set -eou pipefail

TARGET_HOST=${TARGET_HOST:-192.168.122.27}
TARGET_SYSTEM=${TARGET_SYSTEM:-lab-kube-1}
FINAL_IP=${FINAL_IP:-10.17.0.10}

# 1. Generate a temporary key locally
DISK_KEY=$(mktemp)
head -c 32 /dev/urandom | base64 | tr -d '\n' > "$DISK_KEY"

MY_FILES=$(mktemp -d)
mkdir -p "${MY_FILES}/persist/var/lib/sbctl"
mkdir -p "${MY_FILES}/persist/var/lib/sops-nix"
cp ~/.config/sops/age/keys.txt "${MY_FILES}/persist/var/lib/sops-nix/keys.txt"

DEFAULT_SBCTL="/var/lib/sbctl"
TARGET_DIR="${MY_FILES}/persist/var/lib/sbctl"

echo "Checking for existing host keys..."
if [ -d "$DEFAULT_SBCTL" ]; then
	echo "WARNING: $DEFAULT_SBCTL already exists on this host!"
	echo "I will not overwrite your host keys. Please backup or remove them manually."
	exit 1
fi

echo "Generating keys in default location..."
nix shell nixpkgs#sbctl --command sudo sbctl create-keys

echo "Staging keys for persistence..."
sudo mv "$DEFAULT_SBCTL"/* "$TARGET_DIR"
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR"
sudo rmdir "$DEFAULT_SBCTL" 2>/dev/null || true

echo "Mirroring keys for installation phase..."
# We must copy the keys to the 'root' location so the installer can find them
# before the persistence bind-mounts are active.
mkdir -p "${MY_FILES}/var/lib"
cp -r "${MY_FILES}/persist/var/lib/sbctl" "${MY_FILES}/var/lib/"

echo "Keys generated and staged successfully."

# 3. Install (The Clean Way)
# --disk-encryption-keys <remote_path> <local_path>
NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	nix run github:nix-community/nixos-anywhere -- \
	--flake ./nix#${TARGET_SYSTEM} \
	--extra-files "$MY_FILES" \
	--disk-encryption-keys /tmp/disk.key "$DISK_KEY" \
	--no-reboot \
	root@${TARGET_HOST}

# clear any cached SSH keys
ssh-keygen -R ${TARGET_HOST}

# 4. The Critical TPM Enrollment (Still Required)
echo "Enrolling TPM..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${TARGET_HOST} "bash -s" << 'EOF'
	set -e

	# Enroll Secure Boot
	echo "Enrolling Secure Boot keys..."
	nixos-enter --root /mnt -- sbctl enroll-keys --yes-this-might-brick-my-machine

	# Enroll TPM for LUKS automatic unlocking
	echo "Enrolling TPM with LUKS key..."
	# Copy the key into the new system's /tmp so nixos-enter can see it.
	cp /tmp/disk.key /mnt/tmp/disk.key

	# Run cryptenroll inside the new system. It will see the key at /tmp/disk.key.
	nixos-enter --root /mnt -- systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="" /dev/disk/by-partlabel/disk-main-root --unlock-key-file=/tmp/disk.key

	# Clean up the key from the new system's /tmp
	rm /mnt/tmp/disk.key

	echo "Rebooting..."
	reboot
EOF

# 5. Post-Reboot Security Hardening
echo "Waiting for server to reboot..."
# Loop until SSH is available
while ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ryan@${FINAL_IP} "true" >/dev/null 2>&1; do
	echo "Waiting for SSH..."
	sleep 5
done

echo "Server is back online. Re-enrolling TPM with PCR 7 for Secure Boot protection..."
# Copy the disk key to the server to authorize the enrollment
# We use cat | ssh because SFTP is disabled on the hardened server
# We use chmod u=rw,go= to secure the key file immediately, avoiding cryptenroll warnings
cat "$DISK_KEY" | ssh ryan@${FINAL_IP} "cat > /tmp/disk.key && chmod u=rw,go= /tmp/disk.key"

# Enroll with the key file
ssh -t ryan@${FINAL_IP} "
	set -e
	echo 'Enrolling TPM with PCR 7... (You may be asked for your sudo password)'
	sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-root \
		--wipe-slot=tpm2 \
		--tpm2-device=auto \
		--tpm2-pcrs=7 \
		--unlock-key-file=/tmp/disk.key

	# Clean up
	rm /tmp/disk.key
"

# Cleanup
rm "$DISK_KEY"
rm -rf "$MY_FILES"

