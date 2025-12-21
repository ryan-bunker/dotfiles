# vesktop is a custom Discord desktop app -- https://github.com/Vencord/Vesktop
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.bunker-house.workstation.vesktop;
in {
  options.bunker-house.workstation.vesktop = {
    enable = lib.mkEnableOption "Enable vesktop Discord client";

    enableRichPresence = lib.mkEnableOption "Enable Discord Rich Presence integration";
  };

  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        minimizeToTray = true;
        arRPC = cfg.enableRichPresence;
      };
    };
  };
}
