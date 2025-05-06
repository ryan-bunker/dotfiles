{
  inputs,
  config,
  pkgs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  imports = [inputs.ags.homeManagerModules.default];

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
    nerd-fonts.jetbrains-mono
    curl
    luajit
    lynx
    pass
    powershell
    spotify
    swww
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

  services = {
    avizo = {
      enable = true;
    };
  };

  programs = {
    ags = {
      enable = true;
      configDir = ./ags;
      systemd.enable = true;
      extraPackages = with inputs.ags.packages.${pkgs.system}; [
        battery
        hyprland
        network
        tray
        wireplumber
      ];
    };
    bat = {
      enable = true;
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
    fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "yes";
          width = 25;
          font = "Montserrat:size=10";
          line-height = 15;
          prompt = "❯   ";
          layer = "overlay";
          launch-prefix = "uwsm app -- ";
        };
        colors = {
          background = "24273add";
          text = "cad3f5ff";
          match = "ed8796ff";
          selection = "5b6078ff";
          selection-match = "ed8796ff";
          selection-text = "cad3f5ff";
          border = "b7bdf8ff";
        };
        border = {
          radius = 20;
        };
        dmenu = {
          exit-immediately-if-empty = "yes";
        };
      };
    };
    fzf = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Ryan Bunker";
      userEmail = "ryan.bunker@gmail.com";
    };
    jq = {
      enable = true;
    };
    lazygit = {
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
    tmux = import ./tmux.nix {inherit pkgs;};
    zoxide = {
      enable = true;
      options = ["--cmd" "cd"];
    };
    zsh = import ./zsh.nix {inherit config pkgs;};
  };

  systemd.user.services = {
    swww = {
      Unit = {
        Description = "A solution to your Wayland wallpaper woes.";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };
      Service = {
        Slice = "background-graphical.slice";
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
    wallpaper-random = {
      Unit = {
        Description = "Changes the desktop wallpaper to a random image";
        Requires = "swww.service";
        Wants = "wallpaper-random.timer";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/dotfiles/wallpapers/random.sh %h/dotfiles/wallpapers/";
      };
    };
  };
  systemd.user.timers = {
    wallpaper-random = {
      Unit = {
        Description = "changes the desktop wallpaper to a random image";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
        Requires = "wallpaper-random.service";
      };
      Timer = {
        Unit = "wallpaper-random.service";
        OnCalendar = "*:0/5";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
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
