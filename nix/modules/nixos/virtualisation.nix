{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.my.system.virtualisation;
in {
  options.my.system.virtualisation = {
    enable = lib.mkEnableOption "Enable virtualisation support";
  };

  config = lib.mkIf cfg.enable {
    # Enable libvirt to get the 'virbr0' bridge and dnsmasq (DHCP).
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true; # Keeps things simple for bridge helpers
        swtpm.enable = true; # TPM support for Windows 11/Secure Boot
      };
    };

    # Allow QEMU to attach to the bridge without sudo. This sets the setuid
    # bit on the helper binary.
    security.wrappers.qemu-bridge-helper = {
      owner = "root";
      group = "root";
      # The default capabilities must be disabled as they conflict with setuid = true.
      capabilities = lib.mkForce "";
      setuid = true;
    };

    # Tell the helper which bridges are safe to access.
    environment.etc."qemu/bridge.conf".text = "allow virbr0";

    # 'vhost_net' moves network packet processing into the kernel for
    # significantly better VM network performance.
    boot.kernelModules = ["kvm-amd" "kvm-intel" "vhost_net"];

    environment.persistence.${config.my.system.impermanence.persistPath} = lib.mkIf config.my.system.impermanence.enable {
      directories = [
        "/var/lib/libvirt"
        "/var/lib/qemu"
      ];
    };
  };
}
