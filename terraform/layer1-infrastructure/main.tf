terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "lab_net" {
  name      = "homelab-internal"
  autostart = true

  forward = {
    mode = "nat"
  }

  domain = {
    name = "dev.thebunker.house"
  }

  ips = [
    {
      address = "10.17.0.1"
      prefix  = 24
      dhcp = {
        ranges = [
          {
            start = "10.17.0.100"
            end   = "10.17.0.250"
          }
        ]
      }
    }
  ]
}

resource "libvirt_pool" "lab_pool" {
  name = "homelab-pool"
  type = "dir"

  target = {
    path = "/var/lib/libvirt/images/terraform-lab"
  }
}

resource "libvirt_volume" "k8s_disk" {
  count    = 3
  name     = "k8s-node-disk-${count.index}.qcow2"
  pool     = libvirt_pool.lab_pool.name
  capacity = 21474836480 # 20GB in bytes
}

resource "libvirt_domain" "k8s_nodes" {
  count = 1
  name  = "k8s-node-${count.index}"

  type        = "kvm"
  vcpu        = 2
  memory      = 4096
  memory_unit = "MiB"

  cpu = {
    mode = "host-passthrough"
  }

  features = {
    acpi = true
  }

  os = {
    firmware     = "efi"
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    loader       = "/run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd"
    nvram = {
      template = "/run/libvirt/nix-ovmf/edk2-i386-vars.fd"
    }
    boot_devices = [
      { dev = "hd" }
    ]
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            volume = libvirt_volume.k8s_disk[count.index].name
            pool   = libvirt_pool.lab_pool.name
          }
        }
        target = { dev = "vda", bus = "virtio" }
      },
      {
        source = {
          file = { file = "/nix/store/n45s3qpvq0ivzph02xq6g70xz66kf0ll-nixos-26.05.20251219.7d853e5-x86_64-linux.iso/iso/nixos-26.05.20251219.7d853e5-x86_64-linux.iso" }
        }
        device    = "cdrom"
        target    = { dev = "sda", bus = "sata" }
        read_only = true
      }
    ]

    interfaces = [
      {
        source = {
          network = { network = libvirt_network.lab_net.name }
        }
        model = { type = "virtio" }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]

    graphics = [
      {
        spice = {
          auto_port = true
        }
      }
    ]
  }
}
