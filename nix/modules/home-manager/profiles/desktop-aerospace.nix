{
  config,
  lib,
  ...
}: let
  cfg = config.my.profiles.desktop-aerospace;
in {
  options = {
    my.profiles.desktop-aerospace.enable = lib.mkEnableOption "Aerospace based desktop profile";
  };

  config = lib.mkIf cfg.enable {
    my.desktop = {
      aerospace.enable = lib.mkDefault true;
      sketchybar.enable = lib.mkDefault true;
    };
  };
}
