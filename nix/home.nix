{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./modules/aerospace
    ./modules/sketchybar
    ./modules/tmux
    ./modules/zsh
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "I845798";
  home.homeDirectory = "/Users/I845798";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    inputs.alejandra.defaultPackage.${system}
    nerd-fonts.jetbrains-mono
    antlr
    choose-gui
    curl
    dua
    libxml2
    luajit
    lynx
    pass
    powershell
    slack
    spotify
    tree
    unixtools.watch
    yq
  ];

  fonts.fontconfig.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".local/bin/tmux-sessionizer".source = ./tmux-sessionizer;
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/neovim";
  };

  home.sessionPath = [
    "$GOPATH/bin"
    "$HOME/.local/bin"
    "$HOME/.krew/bin"
  ];
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/I845798/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
  };

  programs = {
    bash = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
    fzf = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Ryan Bunker";
      userEmail = "ryan.bunker@sap.com";
      includes = [
        {path = ./gitconfig.local;}
      ];
    };
    jq = {
      enable = true;
    };
    lazygit = {
      enable = true;
    };
    neovim = {
      enable = true;
    };
    oh-my-posh = {
      enable = true;
      settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../roles/zsh/files/oh-my-posh.toml));
    };
    # TODO: this doesn't install an .app and it crashes when run from the terminal
    # qutebrowser = (import ./qutebrowser.nix { inherit pkgs; });
    ripgrep = {
      enable = true;
    };
    zoxide = {
      enable = true;
      options = ["--cmd" "cd"];
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
