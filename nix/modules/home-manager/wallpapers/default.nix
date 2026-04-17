{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.wallpapers;

  # ---------------------------------------------------------------------------
  # 1. THE BUILDER SCRIPT (Python)
  # This runs during 'home-manager switch'. It organizes images by resolution.
  # ---------------------------------------------------------------------------
  builderScript = pkgs.writers.writePython3 "wallpaper-builder" {
    libraries = [pkgs.python3Packages.pillow];
    flakeIgnore = ["E501"];
  } (builtins.readFile ./wallpaper_builder.py);

  # ---------------------------------------------------------------------------
  # 2. THE DERIVATION
  # This executes the builder script to create the processed output
  # ---------------------------------------------------------------------------
  processedWallpapers = pkgs.runCommand "processed-wallpapers" {} ''
    # Run the builder script
    # We pass the source directory and the list of targets
    ${builderScript} "${cfg.wallpaperDir}" "$out" "${toString cfg.targets}"
  '';

  # ---------------------------------------------------------------------------
  # 3. THE RUNTIME SCRIPT (Python)
  # This runs when the systemd service starts.
  # ---
  runtimeScript = pkgs.writers.writePython3Bin "set-random-wallpaper" {
    libraries = []; # No heavy deps needed! standard library only.
    flakeIgnore = ["E501"];
  } (builtins.readFile ./random_wallpaper.py);
in {
  # ---------------------------------------------------------------------------
  # 4. OPTIONS
  # ---------------------------------------------------------------------------
  options.my.desktop.wallpapers = {
    enable = mkEnableOption "Random wallpaper service";

    wallpaperDir = mkOption {
      type = types.path;
      description = "Path to the directory containing raw wallpapers.";
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = ["1920x1080" "2560x1440" "3840x2160"];
      description = "List of resolutions to organize wallpapers into.";
    };

    transition = {
      duration = mkOption {
        type = types.int;
        default = 3;
        description = "Transition duration in seconds.";
      };

      fps = mkOption {
        type = types.int;
        default = 60;
        description = "Transition frame rate.";
      };

      type = mkOption {
        type = types.enum ["simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "random"];
        default = "fade";
        description = "Type of transition to use.";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 5. CONFIGURATION
  # ---------------------------------------------------------------------------
  config = mkIf cfg.enable {
    # Ensure awww is available
    services.awww.enable = true;

    systemd.user.services.wallpaper-random = {
      Unit = {
        Description = "Changes the desktop wallpaper to a random image";
        Requires = "awww.service";
        After = [config.wayland.systemd.target];
        PartOf = [config.wayland.systemd.target];
        Wants = "wallpaper-random.timer";
      };
      Service = {
        Type = "oneshot";
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.awww pkgs.hyprland]}"
          "AWWW_TRANSITION=${cfg.transition.type}"
          "AWWW_TRANSITION_DURATION=${toString cfg.transition.duration}"
          "AWWW_TRANSITION_FPS=${toString cfg.transition.fps}"
        ];
        ExecStart = "${runtimeScript}/bin/set-random-wallpaper ${processedWallpapers}";
      };
      Install.WantedBy = [config.wayland.systemd.target];
    };

    systemd.user.timers.wallpaper-random = {
      Unit = {
        Description = "Changes the desktop wallpaper to a random image";
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
}
