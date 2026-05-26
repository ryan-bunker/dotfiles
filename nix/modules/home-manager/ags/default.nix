{
  lib,
  config,
  pkgs,
  astal,
  ...
}: let
  cfg = config.my.desktop.ags;
in {
  options.my.desktop.ags = {
    enable = lib.mkEnableOption "Enable Aylur's GTK Shell";
  };

  config = lib.mkIf cfg.enable {
    programs.ags = {
      enable = true;
      configDir = ./config;
      systemd.enable = true;
      extraPackages = with astal.packages.${pkgs.system}; [
        apps
        battery
        hyprland
        mpris
        tray
        wireplumber
      ];
    };
  };
}
