{
  lib,
  config,
  ...
}: let
  cfg = config.my.desktop.hyprlock;
in {
  options.my.desktop.hyprlock = {
    enable = lib.mkEnableOption "Enable hyprlock lock screen";

    backgrounds = lib.mkOption {
      description = "List of background configurations per monitor.";
      default = [
        {
          monitor = "";
          use_screenshot = true;
          blur_passes = 2;
        }
      ];

      type = lib.types.listOf (lib.types.submodule {
        options = {
          monitor = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Monitor name (e.g. DP-1). Empty for all.";
          };

          path = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to an image file.";
          };

          use_screenshot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Use the current screen content as background.";
          };

          color = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Solid color fallback.";
          };

          blur_passes = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Number of blur passes to make. Only applies if use_screenshot is true.";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    # disable the default catppuccin theme since we define our own
    catppuccin.hyprlock.useDefaultConfig = false;

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };

        # background = [
        #   {
        #     monitor = "DP-1";
        #     path = "${../../../wallpapers/login_wallpaper_3440x1440.png}";
        #     blur_passes = 0;
        #     color = "$base";
        #   }
        #   {
        #     monitor = "";
        #     color = "$base";
        #   }
        # ];
        # background = {
        #   monitor = "";
        #   path = "screenshot";
        #   color = "$base";
        #   blur_passes = 2;
        # };

        background =
          builtins.map (bg: {
            monitor = bg.monitor;
            color = bg.color;
            blur_passes = toString bg.blur_passes;

            # If use_screenshot is true, path is "screenshot", otherwise if
            # path is set, use that, otherwise use empty string.
            path =
              if bg.use_screenshot
              then "screenshot"
              else if bg.path != null
              then "${bg.path}"
              else "";
          })
          cfg.backgrounds;

        label = [
          # TIME
          {
            monitor = (builtins.head cfg.backgrounds).monitor;
            text = "cmd[update:30000] echo \"$(date +\"%R\")\"";
            color = "$text";
            font_size = 45;
            font_family = "$font";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }

          # DATE
          {
            monitor = (builtins.head cfg.backgrounds).monitor;
            text = "cmd[update:43200000] echo \"$(date +\"%A, %d %B %Y\")\"";
            color = "$text";
            font_size = 12;
            font_family = "$font";
            position = "-30, -75";
            halign = "right";
            valign = "top";
          }
        ];

        # USER AVATAR
        image = {
          monitor = (builtins.head cfg.backgrounds).monitor;
          path = "~/.face";
          size = 100;
          border_color = "$accent";
          position = "0, 75";
          halign = "center";
          valign = "center";
        };

        # INPUT FIELD
        input-field = {
          monitor = (builtins.head cfg.backgrounds).monitor;
          size = "225, 45";
          outline_thickness = 4;
          dots_size = "0.3";
          dots_spacing = "0.3";
          dots_center = "true";
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = "false";
          placeholder_text = "<span foreground=\"##$textAlpha\"><i>󰌾 Logged in as </i><span foreground=\"##$accentAlpha\">$USER</span></span>";
          hide_input = "false";
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -35";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
