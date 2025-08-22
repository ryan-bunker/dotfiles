{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.bunker-house.workstation.qutebrowser;
in {
  options.bunker-house.workstation.qutebrowser = {
    enable = lib.mkEnableOption "Enable qutebrowser app";
  };

  config = lib.mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;

      searchEngines = {
        DEFAULT = "https://www.google.com/search?hl=en&q={}";
      };
    };
  };
}
