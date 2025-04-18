{ config, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
in 
{
  launchd.agents = {
    sketchybar = {
      enable = true;
      config = {
        ProgramArguments = ["${pkgs.sketchybar}/bin/sketchybar" "--config" "${homeDir}/.config/sketchybar/sketchybarrc"];
        RunAtLoad = true;
        EnvironmentVariables = {
          PATH = "${config.home.profileDirectory}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
        StandardOutPath = "/tmp/sketchybar.out.log";
        StandardErrorPath = "/tmp/sketchybar.err.log";
      };
    };
  };
}
