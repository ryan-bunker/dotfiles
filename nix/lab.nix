{pkgs, ...}: let
  labIsoConfig = pkgs.nixos ({
    config,
    lib,
    ...
  }: {
    imports = [
      "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];

    # 1. Force boot logs to the serial terminal (Terminal Window)
    boot.kernelParams = ["console=ttyS0"];

    users.users.root.openssh.authorizedKeys.keys = [
      (lib.fileContents ../secrets/keys/desktop/public)
      (lib.fileContents ../secrets/keys/laptop/public)
    ];
  });

  labIso = "${labIsoConfig.config.system.build.isoImage}/iso/${labIsoConfig.config.system.build.isoImage.name}";

  ovmf = pkgs.OVMFFull;
in rec {
  mkLabNode = {
    name,
    ram ? 4096,
    cores ? 2,
    macSuffix ? "01",
    disks ? [
      {
        name = "boot";
        size = "20G";
      }
    ],
  }:
    pkgs.writeShellScriptBin "run-${name}" ''
      set -e
      LAB_DIR="./lab/${name}"
      mkdir -p "$LAB_DIR"

      # Setup TPM State & Socket
      # We need a directory for the TPM chip's memory and a socket for QEMU to talk to it.
      TPM_DIR="$LAB_DIR/tpm"
      TPM_SOCK="$TPM_DIR/swtpm-sock"
      mkdir -p "$TPM_DIR"

      # Check if swtpm is already running for this VM, if not, start it.
      if ! pgrep -f "swtpm socket --tmpstate dir=$TPM_DIR" > /dev/null; then
        echo "Starting TPM 2.0 Emulator..."
        ${pkgs.swtpm}/bin/swtpm socket \
          --tpmstate dir="$TPM_DIR" \
          --ctrl type=unixio,path="$TPM_SOCK" \
          --tpm2 \
          --daemon
      fi

      VARS_IMG="$LAB_DIR/OVMF_VARS.fd"

      # 1. Setup UEFI Vars (Copying from the Secure Boot package)
      if [ ! -f "$VARS_IMG" ]; then
        cp ${ovmf.fd}/FV/OVMF_VARS.fd "$VARS_IMG"
        chmod +w "$VARS_IMG"
      fi

      # 2. Generate Disk Flags dynamically
      DISK_FLAGS=""
      ${pkgs.lib.concatMapStringsSep "\n" (disk: ''
          DISK_PATH="$LAB_DIR/${disk.name}.qcow2"
          if [ ! -f "$DISK_PATH" ]; then
            echo "Creating ${disk.size} disk: ${disk.name}..."
            ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$DISK_PATH" ${disk.size}
          fi
          # Append to qemu flags
          DISK_FLAGS="$DISK_FLAGS -drive file=$DISK_PATH,format=qcow2,if=virtio"
        '')
        disks}

      echo "Starting ${name}..."

      # 3. Launch QEMU with dynamic disk flags
      ${pkgs.qemu}/bin/qemu-system-x86_64 \
        -name ${name} \
        -machine q35,smm=on,accel=kvm \
        -enable-kvm \
        -global driver=cfi.pflash01,property=secure,value=on \
        -m ${toString ram} \
        -smp ${toString cores} \
        -cpu host \
        -chardev socket,id=chrtpm,path="$TPM_SOCK" \
        -tpmdev emulator,id=tpm0,chardev=chrtpm \
        -device tpm-tis,tpmdev=tpm0 \
        -drive if=pflash,format=raw,readonly=on,file=${ovmf.fd}/FV/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file="$VARS_IMG" \
        $DISK_FLAGS \
        -drive file=${labIso},media=cdrom,readonly=on \
        -netdev bridge,id=net0,br=virbr0,helper=/run/wrappers/bin/qemu-bridge-helper \
        -device virtio-net-pci,netdev=net0,mac=52:54:00:00:00:${macSuffix} \
        -nographic
    '';
}
