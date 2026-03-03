{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.profiles.workstation;
in {
  options = {
    my.profiles.workstation.enable = lib.mkEnableOption "Workstation Machine Profile";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
    };

    my.desktop = {
      hyprland.enable = true;
      sddm.enable = true;
    };

    my.system = {
      virtualisation.enable = true;
    };

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "peach";
    };

    services.btrfs.autoScrub = {
      enable = true;
      # default to weekly for workstations
      interval = lib.mkDefault "weekly";
      fileSystems = ["/"];
    };

    # ensure the btrfs scrub doesn't kill the battery on laptops
    systemd.services.btrfs-scrub-root.unitConfig.ConditionACPower = true;

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    programs.ssh.knownHosts = {
      "lab-kube-1" = {
        hostNames = ["lab-kube-1" "10.17.0.10"];
        publicKey = (lib.fileContents ../../../../secrets/keys/lab-kube-1/ssh_host_ed25519_key.pub) + "\n" + (lib.fileContents ../../../../secrets/keys/lab-kube-1/ssh_host_rsa_key.pub);
      };
      "lab-kube-2" = {
        hostNames = ["lab-kube-2" "10.17.0.11"];
        publicKey = (lib.fileContents ../../../../secrets/keys/lab-kube-2/ssh_host_ed25519_key.pub) + "\n" + (lib.fileContents ../../../../secrets/keys/lab-kube-2/ssh_host_rsa_key.pub);
      };
      "lab-kube-3" = {
        hostNames = ["lab-kube-3" "10.17.0.12"];
        publicKey = (lib.fileContents ../../../../secrets/keys/lab-kube-3/ssh_host_ed25519_key.pub) + "\n" + (lib.fileContents ../../../../secrets/keys/lab-kube-3/ssh_host_rsa_key.pub);
      };
    };
  };
}
