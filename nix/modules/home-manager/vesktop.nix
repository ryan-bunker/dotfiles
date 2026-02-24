# vesktop is a custom Discord desktop app -- https://github.com/Vencord/Vesktop
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.vesktop;

  # Temporary fix for vesktop build issue on Darwin
  # TODO: Remove once PR #489725 is merged
  # https://github.com/NixOS/nixpkgs/pull/489725
  vesktop-fixed = pkgs.vesktop.overrideAttrs (oldAttrs: {
    # Remove the postConfigure hook that sets CSC_IDENTITY_AUTO_DISCOVERY
    postConfigure = "";

    # Update buildPhase to include -c.mac.identity=null for Darwin
    buildPhase = ''
      runHook preBuild

      pnpm build
      pnpm exec electron-builder \
        --dir \
        -c.asarUnpack="**/*.node" \
        -c.electronDist=${if pkgs.stdenv.hostPlatform.isDarwin then "." else pkgs.electron.dist} \
        -c.electronVersion=${pkgs.electron.version} \
        ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "-c.mac.identity=null"}

      runHook postBuild
    '';
  });
in {
  options.my.programs.vesktop = {
    enable = lib.mkEnableOption "Enable vesktop Discord client";

    enableRichPresence = lib.mkEnableOption "Enable Discord Rich Presence integration";
  };

  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
      package = vesktop-fixed;
      settings = {
        discordBranch = "stable";
        minimizeToTray = true;
        arRPC = cfg.enableRichPresence;
      };
    };
  };
}
