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

        # enable remote control so vim-kitty-navigator plugin works
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty";
      };

      keybindings = let
        leader = "ctrl+space";
      in {
        # window/nvim navigation
        "ctrl+j" = "kitten pass_keys.py bottom ctrl+j";
        "ctrl+k" = "kitten pass_keys.py top    ctrl+k";
        "ctrl+h" = "kitten pass_keys.py left   ctrl+h";
        "ctrl+l" = "kitten pass_keys.py right  ctrl+l";

        # zoom
        "${leader}>z" = "combine : toggle_layout stack : scroll_prompt_to_bottom";
        # tabs (tmux windows)
        "${leader}>c" = "new_tab";
        "${leader}>n" = "next_tab";
        "${leader}>p" = "previous_tab";
        "${leader}>l" = "goto_tab -1";
        "${leader}>0" = "goto_tab 0";
        "${leader}>1" = "goto_tab 1";
        "${leader}>2" = "goto_tab 2";
        "${leader}>3" = "goto_tab 3";
        "${leader}>4" = "goto_tab 4";
        "${leader}>5" = "goto_tab 5";
        "${leader}>6" = "goto_tab 6";
        "${leader}>7" = "goto_tab 7";
        "${leader}>8" = "goto_tab 8";
        "${leader}>9" = "goto_tab 9";
        # splits
        "${leader}>\"" = "launch --location=vsplit";
        "${leader}>%" = "launch --location=hsplit";
      };
    };
  };
}
