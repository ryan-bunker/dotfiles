{
  lib,
  config,
  pkgs,
  alejandra,
  ...
}: let
  cfg = config.my.profiles.server;
in {
  options = {
    my.profiles.server.enable = lib.mkEnableOption "Server User Profile";
  };

  config = lib.mkIf cfg.enable {
    my.programs = {
      tmux.enable = lib.mkDefault true;
      zsh = {
        enable = lib.mkDefault true;
        oh-my-posh.enable = lib.mkDefault false;
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      antlr
      curl
      dua
      libxml2
      luajit
      lynx
      powershell
      tree
      unixtools.watch
      yq
    ];

    programs = {
      bash.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      eza = {
        enable = lib.mkDefault true;
        git = true;
        icons = "auto";
      };
      fzf.enable = lib.mkDefault true;
      git = {
        enable = lib.mkDefault true;
        lfs.enable = true;
        settings = {
          user.name = "Ryan Bunker";
          user.email = lib.mkDefault "ryan.bunker@gmail.com";
          diff.tool = "bc4";
          merge.tool = "bc4";
        };
      };
      jq.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      zoxide = {
        enable = lib.mkDefault true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
