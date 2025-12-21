{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.bunker-house.workstation.sketchybar;
  homeDir = config.home.homeDirectory;
  configDir = builtins.path {
    name = "sketchybar-config";
    path = ./config;
  };
  sketchybarrcFile = "${configDir}/sketchybarrc";
in {
  options.bunker-house.workstation.sketchybar = {
    enable = lib.mkEnableOption "Enable sketchybar configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.sketchybar];

    launchd.agents = {
      sketchybar = {
        enable = true;
        config = {
          ProgramArguments = ["${pkgs.sketchybar}/bin/sketchybar" "--config" sketchybarrcFile];
          RunAtLoad = true;
          EnvironmentVariables = {
            PATH = "${config.home.profileDirectory}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
          StandardOutPath = "/tmp/sketchybar.out.log";
          StandardErrorPath = "/tmp/sketchybar.err.log";
        };
      };
    };
  };
}
