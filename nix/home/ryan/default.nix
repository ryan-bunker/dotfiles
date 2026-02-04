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
