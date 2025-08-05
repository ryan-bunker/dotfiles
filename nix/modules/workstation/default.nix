{
  lib,
  config,
  pkgs,
  alejandra,
  ...
}: let
  cfg = config.bunker-house.workstation;
in {
  imports = [
    ./neovim.nix
    ./zsh

    # TODO: move these to real modules with options
    ../aerospace
    ../sketchybar
    ../tmux
  ];

  options = {
    bunker-house.workstation.enable = lib.mkEnableOption "sets up default workstation configuration";
  };

  config = lib.mkIf cfg.enable {
    bunker-house.workstation = {
      neovim.enable = lib.mkDefault true;
      zsh = {
        enable = lib.mkDefault true;
        oh-my-posh.enable = lib.mkDefault true;
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      alejandra.packages.${system}.default
      nerd-fonts.jetbrains-mono
      antlr
      curl
      dua
      libxml2
      luajit
      lynx
      powershell
      spotify
      tree
      unixtools.watch
      yq
    ];

    fonts.fontconfig.enable = true;

    home.file = {
      ".local/bin/tmux-sessionizer".source = ../../tmux-sessionizer;
    };

    home.sessionPath = [
      "$GOPATH/bin"
      "$HOME/.local/bin"
      "$HOME/.krew/bin"
    ];
    home.sessionVariables = {
      GOPATH = "$HOME/go";
    };

    programs = {
      bash.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      eza = {
        enable = lib.mkDefault true;
        git = true;
        icons = "auto";
      };
      fzf.enable = lib.mkDefault true;
      gh.enable = lib.mkDefault true;
      jq.enable = lib.mkDefault true;
      lazygit.enable = lib.mkDefault true;
      # TODO: this doesn't install an .app and it crashes when run from the terminal
      # qutebrowser = (import ./qutebrowser.nix { inherit pkgs; });
      ripgrep.enable = lib.mkDefault true;
      zoxide = {
        enable = lib.mkDefault true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
