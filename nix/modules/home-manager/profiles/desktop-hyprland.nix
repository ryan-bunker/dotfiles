{
  config,
  lib,
  ...
}: let
  cfg = config.my.profiles.desktop-hyprland;
in {
  options = {
    my.profiles.desktop-hyprland.enable = lib.mkEnableOption "Hyprland based desktop profile";
  };

  config = lib.mkIf cfg.enable {
    my.desktop = {
      avizo.enable = lib.mkDefault true;
      fuzzel.enable = lib.mkDefault true;
      hypridle.enable = lib.mkDefault true;
      hyprland.enable = lib.mkDefault true;
      hyprlock.enable = lib.mkDefault true;
      wallpapers = {
        enable = lib.mkDefault true;
        wallpaperDir = ../../../../wallpapers;
      };
    };
  };
}
