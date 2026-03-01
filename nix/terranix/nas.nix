{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.nas;
in {
  options.my.nas = {
    nixos-iso = lib.mkOption {
      type = lib.types.package;
      description = "Path to ISO to use as installer for the NAS machine";
    };
    proxmox_endpoint = lib.mkOption {
      type = lib.types.str;
      default = "https://10.17.0.20:8006/";
      description = "The API endpoint for the Proxmox server.";
    };
  };

  config = {
    terraform.required_providers.proxmox = {
      source = "bpg/proxmox";
      version = "0.97.1";
    };

    provider.proxmox = {
      endpoint = cfg.proxmox_endpoint;
      insecure = true;
      # Authentication should be provided via environment variables:
      # PROXMOX_VE_USERNAME (e.g. root@pam) and PROXMOX_VE_PASSWORD
    };

    # Upload the NixOS installer ISO to Proxmox
    resource.proxmox_virtual_environment_file.nixos_iso = {
      content_type = "iso";
      datastore_id = "local";
      node_name = "proxmox";
      source_file.path = "${cfg.nixos-iso}/iso/installer.iso";
    };

    # Create the NAS Virtual Machine
    resource.proxmox_virtual_environment_vm.nas = {
      name = "nas";
      node_name = "proxmox";

      machine = "q35";
      bios = "ovmf";

      tpm_state.version = "v2.0";

      cpu = {
        cores = 2;
        type = "host";
      };

      memory = {
        dedicated = 2048;
      };

      cdrom = {
        file_id = "\${proxmox_virtual_environment_file.nixos_iso.id}";
        interface = "scsi1";
      };

      efi_disk.type = "4m";

      # Define the disks: 1 root disk + 3 passthrough block devices
      disk =
        [
          {
            datastore_id = "local-lvm";
            interface = "scsi0";
            size = 20;
            file_format = "raw";
          }
        ]
        ++ (builtins.genList (i: {
            datastore_id = ""; # Required for host block device passthrough
            path_in_datastore = "/dev/vd${builtins.substring i 1 "bcdefg"}";
            interface = "scsi${toString (i + 2)}"; # scsi2, scsi3, scsi4 (avoid scsi1 cdrom)
            file_format = "raw";
          })
          3);

      serial_device = [
        {
          device = "socket";
        }
      ];

      vga = {
        type = "virtio";
      };

      network_device = {
        bridge = "vmbr0";
        model = "virtio";
      };

      operating_system = {
        type = "l26"; # Linux 2.6+ kernel
      };

      # Boot from CDROM first for installation, then disk
      boot_order = ["scsi1" "scsi0"];
    };
  };
}
