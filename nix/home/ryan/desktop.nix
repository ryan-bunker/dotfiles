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
    wallpapers.target = ["3440x1440" "1440x2560"];
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
    sopsKey = "ssh_key_desktop";
    publicKey = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtZ8rdN4bP15DEbGFaL5K0lq9jQus0Ya/WMiZLg38v4 ryan.bunker@gmail.com
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

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
