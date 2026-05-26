{
  lib,
  config,
  pkgs,
  ags,
  ...
}: {
  # Allow installing unfree packages.
  nixpkgs.config.allowUnfree = true;

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  my.profiles = {
    workstation.enable = true;
    desktop-hyprland.enable = true;
  };

  my.desktop = {
    ags.enable = true;
    wallpapers.targets = ["3440x1440" "1440x2560"];
    hyprlock.backgrounds = [
      {
        monitor = "DP-1";
        path = ../../../wallpapers/login_wallpaper_3440x1440.png;
      }
      {
        monitor = "HDMI-A-1";
        color = "$base";
      }
    ];
  };

  my.programs.ssh = {
    publicKeyFile = ../../../secrets/keys/desktop/public;
    privateKey = {
      sopsFile = ../../../secrets/keys/desktop/private;
      format = "binary";
    };
  };

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
