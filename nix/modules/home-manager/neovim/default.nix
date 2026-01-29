{
  lib,
  config,
  pkgs,
  neovim-nightly-overlay,
  alejandra,
  ...
}: let
  cfg = config.my.programs.neovim;

  ascii-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "ascii-nvim";
    version = "2025-12-03";
    dontBuild = true;

    # Use a fetcher to get source code
    src = pkgs.fetchFromGitHub {
      owner = "MaximilianLloyd";
      repo = "ascii.nvim";
      rev = "70783fea66e99525221e52dce3b3489c05354181";
      hash = "sha256-2CE03Lvyn7Ta8yd5pR6ZXGiXAyYtVxYPynUmhHATqG8=";
    };

    dependencies = [pkgs.vimPlugins.nui-nvim];
  };

  gopher-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "gopher-nvim";
    version = "2025-12-03";

    # Use a fetcher to get source code
    src = pkgs.fetchFromGitHub {
      owner = "olexsmir";
      repo = "gopher.nvim";
      rev = "4a2384ade8005affb4a35951efff4dfd2295600e";
      hash = "sha256-Vm+7egZRep3LMElYiP2zSUZHRoBgraiJ0etyMiQlHTs=";
    };
  };

  reactive-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "reactive-nvim";
    version = "2025-12-03";

    # Use a fetcher to get source code
    src = pkgs.fetchFromGitHub {
      owner = "rasulomaroff";
      repo = "reactive.nvim";
      rev = "e0a22a42811ca1e7aa7531f931c55619aad68b5d";
      hash = "sha256-ox26LQIkNNutdh7OUMER2uveFhykgMRxvGoQ0nIRkkk=";
    };
  };

  # This fixes a current issue where neotest can't find treesitter grammars that are package outside nvim-treesitter.
  # See this PR for details: https://github.com/nvim-neotest/neotest/pull/577
  neotest-fix = pkgs.vimUtils.buildVimPlugin {
    pname = "neotest";
    version = "2026-01-20-pr577";
    src = pkgs.fetchFromGitHub {
      owner = "archie-judd";
      repo = "neotest";
      rev = "ce51b2834f6f4e9d9a09c1047a0d1f627b13161a";
      hash = "sha256-EpkobU9KzMpvQr+XZKy9abna1q/TZSKr469ggx+tvgk=";
    };

    dependencies = with pkgs.vimPlugins; [
      nvim-nio
      plenary-nvim
      FixCursorHold-nvim
      nvim-treesitter
    ];
  };
  neotest-golang-fix = pkgs.vimUtils.buildVimPlugin {
    pname = "neotest-golang";
    version = "v2.7.2";
    src = pkgs.fetchFromGitHub {
      owner = "fredrikaverpil";
      repo = "neotest-golang";
      rev = "67800bdb6bee0107f478e35400ba937b438f1a4b"; # v2.7.2
      hash = "sha256-oZWb6GsZTgclKFyDgZWWANmfPRjg0LZgFymQs2SC8Rc=";
    };
    dependencies = with pkgs.vimPlugins; [
      neotest-fix
      nvim-nio
      plenary-nvim
      nvim-treesitter
    ];
  };

  nvim-plugins = with pkgs.vimPlugins; [
    alpha-nvim
    ascii-nvim
    auto-save-nvim
    auto-session
    blink-cmp
    catppuccin-nvim
    codecompanion-lualine-nvim
    codecompanion-nvim
    comment-nvim
    conform-nvim
    copilot-lua
    FixCursorHold-nvim
    friendly-snippets
    gitsigns-nvim
    gopher-nvim
    indent-blankline-nvim
    leap-nvim
    lualine-nvim
    mini-nvim
    neo-tree-nvim
    neotest-fix # TEMP: fixes neotest issue
    neotest-golang-fix
    noice-nvim
    nvim-autopairs
    nvim-dap
    nvim-dap-ui
    nvim-dap-go
    nvim-lspconfig
    nvim-nio
    nvim-notify
    nvim-surround
    nvim-treesitter.withAllGrammars
    nvim-web-devicons
    plenary-nvim
    rainbow-delimiters-nvim
    reactive-nvim
    telescope-nvim
    todo-comments-nvim
    vim-kitty-navigator
    vim-sleuth
    which-key-nvim
  ];
in {
  options.my.programs.neovim = {
    enable = lib.mkEnableOption "Enable neovim on the workstation";

    gemini.enable = lib.mkEnableOption "Include gemini-cli adapter settings for CodeCompanion plugin";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      package = neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

      plugins = nvim-plugins;

      extraPackages = with pkgs;
        [
          # formatters
          alejandra.packages.${system}.default
          prettierd
          stylua
          # LSPs
          buf
          gopls
          helm-ls
          lua-language-server
          omnisharp-roslyn
          powershell-editor-services
          yaml-language-server
          # extra utilities
          ripgrep # telescope
          fd # telescope
          nodejs_24 # copilot
          gotestsum # neotest-golang
        ]
        ++ lib.optional cfg.gemini.enable pkgs.gemini-cli;
    };

    programs.zsh = {
      shellAliases = {
        nvim-lazy = "NVIM_APPNAME=nvim-lazy nvim";
      };
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    xdg.configFile = {
      "nvim/lua".source = ./lua;
      "nvim/init.lua".text = ''
        _G.Nix = {
          enableGemini = ${lib.boolToString cfg.gemini.enable},
        }

        require("settings")
        require("plugins").setup()
      '';
    };

    # disable catppuccin automatic styling as it is currently setup directly
    # in the neovim config which is not controlled by nix/home-manager
    catppuccin.nvim.enable = false;
  };
}
