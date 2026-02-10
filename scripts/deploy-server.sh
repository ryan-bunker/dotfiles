#!/usr/bin/env bash

set -eou pipefail

TARGET_HOST=${TARGET_HOST:-192.168.122.27}

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
nix run github:nix-community/nixos-anywhere -- \
	--flake ./nix#lab-kube-1 \
	--extra-files "$MY_FILES" \
	--disk-encryption-keys /tmp/disk.key "$DISK_KEY" \
	--no-reboot \
	root@${TARGET_HOST}

# clear any cached SSH keys
ssh-keygen -R ${TARGET_HOST}

# 4. The Critical TPM Enrollment (Still Required)
echo "Enrolling TPM..."
scp "$DISK_KEY" root@${TARGET_HOST}:/tmp/luks-key
ssh root@${TARGET_HOST} "bash -s" << 'EOF'
	set -e

	# Enroll Secure Boot
	echo "Enrolling keys..."
	nixos-enter --root /mnt -- sbctl enroll-keys --yes-this-might-brick-my-machine

	# Add a simple recovery password ('secret')
	# We use the master key to authorize this addition.
	# Use 'printf' to avoid newline issues.
	echo "Adding recovery password..."
	printf "secret" | cryptsetup luksAddKey \
		--key-file=/tmp/luks-key \
		/dev/disk/by-partlabel/disk-main-root -

	# Clean up keys from disk
	echo "Cleaning up disk key..."
	rm /tmp/luks-key

	echo "Rebooting..."
	reboot
EOF

# Cleanup
rm "$DISK_KEY"
rm -rf "$MY_FILES"

