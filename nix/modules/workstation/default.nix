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
    ./aerospace
    ./kitty.nix
    ./neovim.nix
    ./pass.nix
    ./qutebrowser.nix
    ./sketchybar
    ./spicetify.nix
    ./tmux
    ./vesktop.nix
    ./zsh
  ];

  options = {
    bunker-house.workstation.enable = lib.mkEnableOption "sets up default workstation configuration";
  };

  config = lib.mkIf cfg.enable {
    bunker-house.workstation = {
      aerospace.enable = lib.mkDefault pkgs.stdenv.isDarwin;
      kitty.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      pass.enable = lib.mkDefault false;
      qutebrowser.enable = lib.mkDefault true;
      sketchybar.enable = lib.mkDefault pkgs.stdenv.isDarwin;
      spicetify.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      vesktop = {
        enable = lib.mkDefault true;
        enableRichPresence = lib.mkDefault true;
      };
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
      tree
      unixtools.watch
      yq
    ];

    fonts.fontconfig.enable = true;

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "sky";
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
      ripgrep.enable = lib.mkDefault true;
      zoxide = {
        enable = lib.mkDefault true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
