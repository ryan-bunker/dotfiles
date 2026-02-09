{
  lib,
  config,
  ...
}: let
  imp = config.my.system.impermanence;
in {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # DISABLE SSH Key Import
    age.sshKeyPaths = [];

    # ENABLE Manual Key File
    age.keyFile =
      if imp.enable
      then "${imp.persistPath}/var/lib/sops-nix/keys.txt"
      else "/var/lib/sops-nix/keys.txt";
  };

  # automatically persist the age key if impermanence is on
  environment.persistence = lib.mkIf imp.enable {
    "${imp.persistPath}" = {
      directories = [
        "/var/lib/sops-nix"
      ];
    };
  };
}
