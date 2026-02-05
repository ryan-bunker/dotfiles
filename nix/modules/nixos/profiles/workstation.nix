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
  };
}
