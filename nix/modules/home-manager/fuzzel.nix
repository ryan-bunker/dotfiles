{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.desktop.fuzzel;
in {
  options.my.desktop.fuzzel = {
    enable = lib.mkEnableOption "Enable fuzzel application launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          dpi-aware = "yes";
          font = "Montserrat:size=16";
          inner-pad = "14";
          vertical-pad = "14";
          prompt = "❯   ";
          layer = "overlay";
          launch-prefix = "uwsm app -- ";
        };
        dmenu = {
          exit-immediately-if-empty = "yes";
        };
      };
    };

    # Install the Montserrat font
    home.packages = [pkgs.montserrat];
    # Update the font cache - without this, the font files sit in the store, but
    # apps won't "see" them.
    fonts.fontconfig.enable = true;
  };
}
