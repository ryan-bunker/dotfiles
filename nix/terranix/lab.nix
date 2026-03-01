{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.lab;
in {
  options.my.lab = {
    nixos-iso = lib.mkOption {
      type = lib.types.package;
      description = "Path to ISO to use as installer for nixos machines";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The DNS domain name for the virtual network.";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      description = "The gateway IP address for the virtual network.";
    };
    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "The prefix length for the virtual network subnet.";
    };
    dhcp_range = {
      start = lib.mkOption {
        type = lib.types.str;
        description = "The start of the DHCP IP range.";
      };
      end = lib.mkOption {
        type = lib.types.str;
        description = "The end of the DHCP IP range.";
      };
    };
    mainDisk = lib.mkOption {
      type = lib.types.str;
      description = "The device name for the primary disk.";
    };
  };

  config = {
    terraform.required_providers.libvirt = {
      source = "dmacvicar/libvirt";
      version = "0.9.2";
    };
    provider.libvirt.uri = "qemu:///system";

    resource.libvirt_network.lab_net = {
      name = "homelab-internal";
      autostart = true;
      forward.mode = "nat";
      domain.name = cfg.domain;
      ips = [
        {
          address = cfg.gateway;
          prefix = cfg.prefixLength;
          dhcp.ranges = [
            {
              start = cfg.dhcp_range.start;
              end = cfg.dhcp_range.end;
            }
          ];
        }
      ];
    };

    resource.libvirt_pool.lab_pool = {
      name = "homelab-pool";
      type = "dir";
      target.path = "/var/lib/libvirt/images/terraform-lab";
    };

    resource.libvirt_volume.k8s_disk = {
      count = 3;
      name = "k8s-node-disk-\${count.index}.qcow2";
      pool = "\${libvirt_pool.lab_pool.name}";
      capacity = 21474836480;
    };

    resource.libvirt_domain.k8s_nodes = {
      count = 3;
      name = "k8s-node-\${count.index}";

      type = "kvm";
      vcpu = 2;
      memory = 4096;

      memory_unit = "MiB";

      cpu.mode = "host-passthrough";

      features = {
        acpi = true;
        smm.state = "on";
      };

      os = {
        type = "hvm";
        type_arch = "x86_64";
        type_machine = "q35";
        loader = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd";
        loader_readonly = "yes";
        loader_type = "pflash";
        nv_ram.nv_ram = "/var/lib/libvirt/qemu/nvram/k8s-node-\${count.index}_VARS.fd";
        nv_ram.template = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd";
        boot_devices = [{dev = "hd";}];
      };

      devices.tpms = [
        {
          backend = {
            emulator = {
              version = "2.0";
            };
          };
        }
      ];

      devices.disks = [
        {
          source.volume = {
            volume = "\${libvirt_volume.k8s_disk[count.index].name}";
            pool = "\${libvirt_pool.lab_pool.name}";
          };
          target = {
            dev = lib.lists.last (lib.strings.splitString "/" cfg.mainDisk);
            bus = "virtio";
          };
        }
        {
          source.file.file = "${config.my.lab.nixos-iso}/iso/installer.iso";
          device = "cdrom";
          target = {
            dev = "sda";
            bus = "sata";
          };
          read_only = true;
        }
      ];

      devices.interfaces = [
        {
          source.network.network = "\${libvirt_network.lab_net.name}";
          model.type = "virtio";
        }
      ];

      devices.consoles = [
        {
          type = "pty";
          target_port = "0";
          target_type = "serial";
        }
      ];

      devices.graphics = [{spice.auto_port = true;}];
    };

    resource.libvirt_volume.proxmox_root = {
      name = "proxmox-root.qcow2";
      pool = "\${libvirt_pool.lab_pool.name}";
      capacity = 21474836480; # 40GB
    };

    resource.libvirt_volume.proxmox_data = {
      count = 3;
      name = "proxmox-data-\${count.index}.qcow2";
      pool = "\${libvirt_pool.lab_pool.name}";
      capacity = 10737418240; # 10GB
    };

    resource.libvirt_domain.proxmox = {
      name = "proxmox-server";
      type = "kvm";
      vcpu = 2;
      memory = 4096;
      memory_unit = "MiB";
      cpu.mode = "host-passthrough";

      os = {
        type = "hvm";
        type_arch = "x86_64";
        type_machine = "q35";
        boot_devices = [
          {dev = "hd";}
          {dev = "cdrom";}
        ];
      };

      features = {
        acpi = true;
      };

      devices.disks =
        [
          {
            source.volume = {
              volume = "\${libvirt_volume.proxmox_root.name}";
              pool = "\${libvirt_pool.lab_pool.name}";
            };
            target = {
              dev = "vda";
              bus = "virtio";
            };
          }
        ]
        ++ (builtins.genList (i: {
            source.volume = {
              volume = "\${libvirt_volume.proxmox_data[${toString i}].name}";
              pool = "\${libvirt_pool.lab_pool.name}";
            };
            target = {
              dev = "vd${builtins.substring i 1 "bcdefg"}";
              bus = "virtio";
            };
          })
          3)
        ++ [
          {
            source.file.file = "\${abspath(path.module)}/../../proxmox-custom-installer.iso";
            device = "cdrom";
            target = {
              dev = "sda";
              bus = "sata";
            };
          }
        ];

      devices.interfaces = [
        {
          source.network.network = "\${libvirt_network.lab_net.name}";
          model.type = "virtio";
        }
      ];

      devices.consoles = [
        {
          type = "pty";
          target_port = "0";
          target_type = "serial";
        }
      ];

      devices.graphics = [{spice.auto_port = true;}];

      devices.videos = [
        {
          model.type = "virtio";
          model.heads = 1;
          model.primary = "yes";
        }
      ];
    };
  };
}
