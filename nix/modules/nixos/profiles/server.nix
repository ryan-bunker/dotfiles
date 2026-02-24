{
  self,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.profiles.server;
in {
  options.my.profiles.server = {
    enable = lib.mkEnableOption "Server Machine Profile";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name for the server.";
    };
    interface = lib.mkOption {
      type = lib.types.str;
      description = "The primary network interface.";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "The static IP address for the server.";
    };
    network = lib.mkOption {
      type = lib.types.str;
      description = "The subnet prefix.";
    };
    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "The subnet prefix length.";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      description = "The default gateway address.";
    };
    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["1.1.1.1"];
      description = "List of DNS nameservers.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      domain = cfg.domain;
      interfaces.${cfg.interface}.ipv4.addresses = [
        {
          address = cfg.ip;
          prefixLength = cfg.prefixLength;
        }
      ];
      defaultGateway = cfg.gateway;
      nameservers = cfg.nameservers;
      useDHCP = false;
    };

    my.storage.enable = true;
    my.services.ssh = {
      enable = true;
      network = "${cfg.network}/${toString cfg.prefixLength}";
    };
    my.system = {
      impermanence.enable = true;
      secure-boot.enable = true;
    };

    boot.supportedFilesystems = ["nfs"];

    boot.kernelParams = ["console=ttyS0,115200n8"];
    boot.loader.timeout = 5; # Give time to see the menu

    environment.systemPackages = with pkgs; [
      vim
    ];

    home-manager.users.ryan = {
      imports = [
        self.homeManagerModules.default
        ../../../home/ryan/server.nix
      ];
    };

    services.btrfs.autoScrub = {
      enable = true;
      interval = lib.mkDefault "weekly";
      fileSystems = ["/"];
    };

    boot.kernel.sysctl = {
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = false;
      "kernel.kptr_restrict" = 2;
      "kernel.sysrq" = false;
      "kernel.unprivileged_bpf_disabled" = true;

      "net.core.bpf_jit_harden" = 2;

      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;

      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;

      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.default.log_martians" = true;

      "net.ipv4.conf.all.rp_filter" = true;
      "net.ipv4.conf.all.send_redirects" = false;
    };

    fileSystems."/proc" = {
      device = "proc";
      fsType = "proc";
      options = ["defaults" "hidepid=2"];
      # unclear if this is actually needed
      neededForBoot = true;
    };

    boot.blacklistedKernelModules = [
      "dccp"
      "sctp"
      "rds"
      "tipc"
    ];

    services.dbus.implementation = "broker";
    security.sudo.execWheelOnly = true;

    systemd.services.systemd-rfkill = {
      serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        PrivateTmp = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
        IPAddressDeny = "any";
      };
    };

    systemd.services.systemd-journald = {
      serviceConfig = {
        UMask = 0077;
        PrivateNetwork = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
      };
    };
  };
}
