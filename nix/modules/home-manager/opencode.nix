{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.opencode;
in {
  options.my.programs.opencode = {
    enable = lib.mkEnableOption "Enable opencode LLM agent";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      settings = {
        theme = "catppuccin-macchiato"; # this doesn't merge correctly from the catppuccin module
      };
    };
  };
}
