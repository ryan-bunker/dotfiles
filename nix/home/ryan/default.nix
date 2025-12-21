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

  my.profiles.workstation.enable = true;
  my.desktop.wallpapers.targets = ["3440x1440" "1440x2560"];

  # home.packages = with pkgs; [
  # ];

  programs = {
    ags = {
      enable = true;
      configDir = ../../ags;
      systemd.enable = true;
      extraPackages = with ags.packages.${pkgs.system}; [
        battery
        hyprland
        network
        tray
        wireplumber
      ];
    };

    # qutebrowser = {
    #   searchEngines = {
    #   };
    # };
  };

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
