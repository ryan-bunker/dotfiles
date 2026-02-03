{
  config,
  lib,
  pkgs,
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

    catppuccin.cursors.enable = lib.mkDefault true;

    gtk = {
      enable = lib.mkDefault true;
      theme = {
        name = "Catppuccin-GTK-Orange-Dark-Macchiato";
        package = pkgs.magnetic-catppuccin-gtk.override {
          accent = ["orange"];
          tweaks = [config.catppuccin.flavor];
        };
      };
    };
  };
}
