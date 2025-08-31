{
  lib,
  config,
  ...
}: let
  cfg = config.bunker-house.workstation.fuzzel;
in {
  options.bunker-house.workstation.fuzzel = {
    enable = lib.mkEnableOption "Enable fuzzel application launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          dpi-aware = "yes";
          width = 25;
          font = "Montserrat:size=10";
          line-height = 15;
          prompt = "❯   ";
          layer = "overlay";
          launch-prefix = "uwsm app -- ";
        };
        # colors = {
        #   background = "24273add";
        #   text = "cad3f5ff";
        #   match = "ed8796ff";
        #   selection = "5b6078ff";
        #   selection-match = "ed8796ff";
        #   selection-text = "cad3f5ff";
        #   border = "b7bdf8ff";
        # };
        # border = {
        #   radius = 20;
        # };
        dmenu = {
          exit-immediately-if-empty = "yes";
        };
      };
    };
  };
}
