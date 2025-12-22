{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.desktop.hypridle;

  brightnessctl = lib.getExe pkgs.brightnessctl;
in {
  options.my.desktop.hypridle = {
    enable = lib.mkEnableOption "Enable hypridle idle daemon";

    enableSleeping = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable sleeping after a certain amount of time";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display
        };

        listener =
          [
            {
              timeout = 150; # 2.5 min
              on-timeout = "${brightnessctl} --save set 10"; # set monitor backlight to minimum
              on-resume = "${brightnessctl} --restore"; # monitor backlight restore
            }
            {
              timeout = 150; # 2.5 min
              on-timeout = "${brightnessctl} --save --device *kbd_backlight set 0"; # turn off keyboard backlight
              on-resume = "${brightnessctl} --restore --device *kbd_backlight"; # turn on keyboard backlight
            }
            {
              timeout = 300; # 5 min
              on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
            }
            {
              timeout = 330; # 5.5 min
              on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
              on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected
            }
          ]
          ++ lib.optionals cfg.enableSleeping [
            {
              timeout = 1800; # 30 min
              on-timeout = "systemctl suspend"; # suspend pc
            }
          ];
      };
    };
  };
}
