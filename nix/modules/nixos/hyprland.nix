{
  lib,
  config,
  pkgs,
  ...
} @ args: let
  cfg = config.my.desktop.hyprland;
in {
  options.my.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland and related apps";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
