{
  lib,
  config,
  ...
}: let
  cfg = config.bunker-house.workstation.swww;
in {
  options.bunker-house.workstation.swww = {
    enable = lib.mkEnableOption "Enable swww wallpaper service";
  };

  config = lib.mkIf cfg.enable {
    services.swww.enable = true;

    systemd.user = {
      services.wallpaper-random = {
        Unit = {
          Description = "Changes the desktop wallpaper to a random image";
          Requires = "swww.service";
          Wants = "wallpaper-random.timer";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${../../../wallpapers/random.sh} ${../../../wallpapers}";
        };
      };

      timers.wallpaper-random = {
        Unit = {
          Description = "changes the desktop wallpaper to a random image";
          PartOf = [config.wayland.systemd.target];
          After = [config.wayland.systemd.target];
          Requires = [config.wayland.systemd.target];
        };
        Timer = {
          Unit = "wallpaper-random.service";
          OnCalendar = "*:0/5";
        };
        Install = {
          WantedBy = [config.wayland.systemd.target];
        };
      };
    };
  };
}
