{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.bunker-house.workstation.pass;
in {
  options.bunker-house.workstation.pass = {
    enable = lib.mkEnableOption "Enable pass configuration";

    choosePassPackage = lib.mkOption {
      type = lib.types.package;
      default =
        pkgs.writeShellApplication
        {
          name = "choose-pass";
          runtimeInputs = [pkgs.pass pkgs.choose-gui];
          text = let
            passStoreDir = config.programs.password-store.settings.PASSWORD_STORE_DIR;
          in ''
            export PASSWORD_STORE_DIR="${passStoreDir}"
            result="$(find "$PASSWORD_STORE_DIR" -type f -name "*.gpg" | sed "s|^.\{${toString (builtins.stringLength passStoreDir + 1)}\}||; s|\.gpg$||" | choose | xargs -r -I{} pass show -c {})"
            if [[ -n "$result" ]]; then
              osascript -e "display notification \"$result\" with title \"Password\""
            fi
          '';
        };
      readOnly = true;
      description = "The choose-pass package";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.password-store.enable = true;
    home.packages = [cfg.choosePassPackage];
  };
}
