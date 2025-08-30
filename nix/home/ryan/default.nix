{
  config,
  pkgs,
  ...
}: {
  # Allow installing unfree packages.
  nixpkgs.config.allowUnfree = true;

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  bunker-house.workstation = {
    enable = true;
  };

  # home.packages = with pkgs; [
  # ];

  programs = {
    git = {
      enable = true;
      userName = "Ryan Bunker";
      userEmail = "ryan.bunker@gmail.com";
      includes = [
        {path = ./gitconfig.local;}
      ];
    };

    # qutebrowser = {
    #   searchEngines = {
    #   };
    # };
  };

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
