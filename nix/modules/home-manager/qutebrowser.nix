{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.qutebrowser;
in {
  options.my.programs.qutebrowser = {
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
