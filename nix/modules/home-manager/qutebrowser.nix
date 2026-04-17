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
    home.sessionVariables = {
      # Without this set qutebrowser falls back to vulkan renderer and hangs on
      # startup (see https://github.com/qutebrowser/qutebrowser/issues/8927)
      QTWEBENGINE_FORCE_USE_GBM = "1";
    };

    programs.qutebrowser = {
      enable = true;

      searchEngines = {
        DEFAULT = "https://www.google.com/search?hl=en&q={}";
      };

      settings = {
        auto_save.session = true;
        colors.webpage.preferred_color_scheme = "dark";
        fonts = {
          default_size = "12pt";
          default_family = "JetBrainsMono Nerd Font Mono";
          tabs.selected = "12pt Montserrat";
          tabs.unselected = "12pt Montserrat";
        };
      };

      extraConfig = ''
        c.tabs.padding = {'top': 3, 'bottom': 5, 'right': 5, 'left': 5}
      '';
    };
  };
}
