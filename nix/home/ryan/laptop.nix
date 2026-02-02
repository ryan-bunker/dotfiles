{
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
    sopsKey = "ssh_key_dell";
    publicKey = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeZJke7UzcoOJQNCFYpNlt/7wsQe+hKQI+q/DaNAHhB ryan.bunker@gmail.com
    '';
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
