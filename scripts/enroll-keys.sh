#!/usr/bin/env bash

ssh ryan@192.168.122.100 "bash -s" << 'EOF'
	set -e

	echo "Enroll keys..."
	sudo systemd-cryptenroll \
		--tpm2-device=auto \
		--tpm2-pcrs=7 \
		--wipe-slot=tpm2 \
		/dev/disk/by-partlabel/disk-main-root	

EOF
