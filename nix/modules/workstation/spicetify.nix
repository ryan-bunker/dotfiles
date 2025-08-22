# spicetify is an alternative client for spotify that allows themes and plugins
# https://spicetify.app/
{
  lib,
  config,
  pkgs,
  spicetify-nix,
  ...
}: let
  cfg = config.bunker-house.workstation.spicetify;
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  options.bunker-house.workstation.spicetify = {
    enable = lib.mkEnableOption "Enable spicetify music player";
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "macchiato";
    };

    programs.spotify-player.enable = true;
    catppuccin.spotify-player.enable = true;
  };
}
