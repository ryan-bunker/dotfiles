{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.bunker-house.workstation.kitty;
in {
  options.bunker-house.workstation.kitty = {
    enable = lib.mkEnableOption "Enable kitty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      font.name = "JetBrainsMono Nerd Font Mono";
      font.size = 10;

      settings = {
        window_margin_width = "8 12";
        hide_window_decorations = "titlebar-only";
        background_opacity = 0.9;
        background_blur = 12;
      };
    };
  };
}
