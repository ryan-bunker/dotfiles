{
  lib,
  config,
  pkgs,
  alejandra,
  ...
}: let
  cfg = config.my.profiles.workstation;
in {
  options = {
    my.profiles.workstation.enable = lib.mkEnableOption "Workstation User Profile";
  };

  config = lib.mkIf cfg.enable {
    my.programs = {
      neovim = {
        enable = lib.mkDefault true;
        gemini.enable = lib.mkDefault true;
      };
      tmux.enable = lib.mkDefault true;
      zsh = {
        enable = lib.mkDefault true;
        oh-my-posh.enable = lib.mkDefault true;
      };
      kitty.enable = lib.mkDefault true;
      pass.enable = lib.mkDefault false;
      qutebrowser.enable = lib.mkDefault true;
      spicetify.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      vesktop = {
        enable = lib.mkDefault true;
        enableRichPresence = lib.mkDefault true;
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
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
      cursors.enable = true;
      flavor = "macchiato";
      accent = "peach";
      cursors.accent = "peach";
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
      lazygit.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      zoxide = {
        enable = lib.mkDefault true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
