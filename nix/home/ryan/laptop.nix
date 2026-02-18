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
    wallpapers.targets = ["3840x2160"];
    hyprland.enableTouchpad = true;
    hyprlock.backgrounds = [
      {
        monitor = "eDP-1";
        path = ../../../wallpapers/login_wallpaper_3840x2160.png;
      }
    ];
  };

  my.programs.ssh = {
    publicKeyFile = ../../../secrets/keys/laptop/public;
    privateKey = {
      sopsFile = ../../../secrets/keys/laptop/private;
      format = "binary";
    };
  };

  programs = {
    ags = {
      enable = true;
      configDir = ../../ags;
      systemd.enable = true;
      extraPackages = with ags.packages.${pkgs.stdenv.hostPlatform.system}; [
        battery
        hyprland
        network
        tray
        wireplumber
      ];
    };
  };

  home.stateVersion = "24.11"; # Please read the comment before changing.
}
