{
  config,
  lib,
  pkgs,
  catppuccin,
  ...
}: let
  cfg = config.my.programs.ssh;

  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;
  palette = (lib.importJSON "${pkgs.catppuccin}/palette/palette.json").${flavor}.colors;
  accentColor = palette.${accent};
in {
  options.my.desktop.avizo = {
    enable = lib.mkEnableOption "Enable avizo on screen display";
  };

  config = lib.mkIf cfg.enable {
    services.avizo = {
      enable = true;
      settings = {
        default = {
          background = "${palette.base.hex}";
          border-color = "${accentColor.hex}";
          bar-fg-color = "${accentColor.hex}";
          bar-bg-color = "${palette.surface2.hex}";
          border-radius = 8;
          border-width = 2;
        };
      };
    };
  };
}
