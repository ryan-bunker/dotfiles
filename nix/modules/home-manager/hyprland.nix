{
  lib,
  config,
  ...
}: let
  cfg = config.my.desktop.hyprland;
in {
  options.my.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland and related apps";

    enableTouchpad = lib.mkEnableOption "Enable touchpad and gestures support";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        monitor = [
          "desc:Acer Technologies Acer X34 P ##ASMILXcTA6fd, 3440x1440@100, 0x0, 1"
          "desc:Samsung Electric Company SAMSUNG 0x00000001, 2560x1440@75,  -1440x-626, 1, transform,3"
          "eDP-1, highrr, auto, 1.6"
          ",preferred,auto,auto"
        ];

        # exec-once = [
        #   "uwsm app -- udiskie --tray"
        #   "[workspace 1 silent] uwsm app -- qutebrowser"
        #   "[workspace 2 silent] uwsm app -- kitty"
        #   "[workspace 4 silent] uwsm app -- vesktop"
        # ];

        env = [
          # Some default env vars.
          "HYPRCURSOR_SIZE,32"
          "XCURSOR_SIZE,32  # set for backwards compat"
          # Nvidia specific environment Variables
          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ];

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = "1";

          touchpad = lib.mkIf cfg.enableTouchpad {
            disable_while_typing = "false";
            natural_scroll = "true";
            clickfinger_behavior = "true";
            tap-to-click = "false";
            drag_lock = "true";
            tap-and-drag = "true";
          };

          sensitivity = "0";
        };

        cursor = {
          no_hardware_cursors = "true";
        };

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = "5";
          gaps_out = "20";
          border_size = "2";
          "col.active_border" = "$accent";
          "col.inactive_border" = "$surface2";

          layout = "dwindle";
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = "3";
          blur = {
            enabled = "true";
            size = "8";
            passes = "2";
            new_optimizations = "true";
          };

          shadow = {
            enabled = "true";
            range = "4";
            render_power = "3";
            color = "rgba(1a1a1aee)";
          };
        };

        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 3, default"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = "yes"; # you probably want this
          force_split = "2"; # always split to the right/bottom
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_status = "master";
        };

        gestures = lib.mkIf cfg.enableTouchpad [
          "3, horizontal, workspace"
        ];

        misc = {
          disable_hyprland_logo = "true";
        };

        windowrule = [
          "workspace 4 silent,class:vesktop"
        ];

        layerrule = [
          "blur,launcher"
          "blur,ags-status-bar"
          "ignorezero,ags-status-bar"
          "blur,notifications"
          "ignorezero,notifications"
        ];

        "$mainMod" = "ALT";

        bind =
          [
            "$mainMod, T, exec, uwsm app -- kitty"
            "$mainMod, Q, killactive,"
            "CTRL $mainMod, Q, exec, uwsm stop"
            "$mainMod, E, exec, uwsm app -- qutebrowser"
            "$mainMod, V, togglefloating,"
            "SUPER, SPACE, exec, fuzzel"
            "$mainMod, P, pseudo," # dwindle
            "$mainMod, O, togglesplit," # dwindle
            "$mainMod SHIFT, F, fullscreen, 0"
            "$mainMod SHIFT, M, fullscreen, 1"
            "$mainMod SHIFT, W, exec, systemctl --user start wallpaper-random.service"

            # Brightness and volume control
            ", XF86AudioRaiseVolume, exec, volumectl -d -u up"
            ", XF86AudioLowerVolume, exec, volumectl -d -u down"
            ", XF86AudioMute, exec, volumectl -d toggle-mute"
            ", XF86AudioMicMute, exec, volumectl -d -m toggle-mute"
            ", XF86MonBrightnessUp, exec, lightctl -d up"
            ", XF86MonBrightnessDown, exec, lightctl -d down"

            # Move focus with mainMod + arrow keys
            "$mainMod, H, movefocus, l"
            "$mainMod, L, movefocus, r"
            "$mainMod, K, movefocus, u"
            "$mainMod, J, movefocus, d"

            # SUPER + TAB window switching
            "$mainMod, TAB, focuscurrentorlast"

            # Scroll through existing workspaces with mainMod + scroll
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
          ]
          ++ (
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mainMod, code:1${toString i}, workspace, ${toString ws}"
                  "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
      };
    };
  };
}
