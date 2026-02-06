{
  lib,
  config,
  ...
}: {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # DISABLE SSH Key Import
    age.sshKeyPaths = [];

    # ENABLE Manual Key File
    age.keyFile = "/var/lib/sops-nix/keys.txt";
  };

  # automatically persist the age key if impermanence is on
  environment.persistence = lib.mkIf config.my.system.impermanence.enable {
    "${config.my.system.impermanence.persistPath}" = {
      directories = [
        "/var/lib/sops-nix"
      ];
    };
  };
}
