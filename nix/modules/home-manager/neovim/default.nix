{
  lib,
  config,
  pkgs,
  neovim-nightly-overlay,
  alejandra,
  ...
}: let
  cfg = config.my.programs.neovim;

  # import nvfetcher sources
  sources = pkgs.callPackage ./_sources/generated.nix {};

  # helper to build plugins from sources
  buildPlugin = name: overrides:
    pkgs.vimUtils.buildVimPlugin ({
        pname = name;
        inherit (sources.${name}) version src;
        dontBuild = true;
      }
      // overrides);

  ascii-nvim = buildPlugin "ascii-nvim" {
    dependencies = [pkgs.vimPlugins.nui-nvim];
  };

  gopher-nvim = buildPlugin "gopher-nvim" {};

  reactive-nvim = buildPlugin "reactive-nvim" {};

  # This fixes a current issue where neotest can't find treesitter grammars that are package outside nvim-treesitter.
  # See this PR for details: https://github.com/nvim-neotest/neotest/pull/577
  neotest-fix = buildPlugin "neotest-fix" {
    pname = "neotest";
    dependencies = with pkgs.vimPlugins; [
      nvim-nio
      plenary-nvim
      FixCursorHold-nvim
      nvim-treesitter
    ];
  };
  neotest-golang-fix = buildPlugin "neotest-golang-fix" {
    pname = "neotest-golang";
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
    plenary-nvim
    rainbow-delimiters-nvim
    reactive-nvim
    telescope-nvim
    telescope-ui-select-nvim
    telescope-fzf-native-nvim
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
