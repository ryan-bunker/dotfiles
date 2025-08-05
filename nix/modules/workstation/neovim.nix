{
  lib,
  config,
  pkgs,
  neovim-nightly-overlay,
  ...
}: let
  cfg = config.bunker-house.workstation.neovim;
in {
  options = {
    bunker-house.workstation.neovim.enable = lib.mkEnableOption "Enable neovim on the workstation";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      package = neovim-nightly-overlay.packages.${pkgs.system}.default;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.file = {
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/concur-dotfiles/dotfiles/neovim";
    };
  };
}
