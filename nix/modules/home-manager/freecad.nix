{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.freecad;
in {
  options.my.programs.freecad.enable = lib.mkEnableOption "FreeCAD";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.freecad];
  };
}
