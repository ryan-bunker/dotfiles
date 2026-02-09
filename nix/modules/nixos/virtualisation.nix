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

    # Ensure Default Network is Active
    # This automatically defines and starts the default network if it's missing.
    systemd.services.libvirt-default-network = {
      description = "Ensure Libvirt Default Network is Active";
      after = ["libvirtd.service"];
      requires = ["libvirtd.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Check if 'default' network exists
        if ! ${pkgs.libvirt}/bin/virsh net-info default > /dev/null 2>&1; then
          # Define it if missing (using the standard XML)
          ${pkgs.libvirt}/bin/virsh net-define ${pkgs.writeText "default.xml" ''
          <network>
            <name>default</name>
            <bridge name='virbr0'/>
            <forward mode='nat'/>
            <ip address='192.168.122.1' netmask='255.255.255.0'>
              <dhcp>
                <range start='192.168.122.2' end='192.168.122.254'/>
              </dhcp>
            </ip>
          </network>
        ''}
        fi

        # Ensure it is active and autostarted
        if ! ${pkgs.libvirt}/bin/virsh net-info default | grep -q "Active: yes"; then
          ${pkgs.libvirt}/bin/virsh net-start default
        fi
        ${pkgs.libvirt}/bin/virsh net-autostart default
      '';
    };
  };
}
