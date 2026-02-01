{config, ...}: {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # DISABLE SSH Key Import
    age.sshKeyPaths = [];

    # ENABLE Manual Key File
    age.keyFile = "/var/lib/sops-nix/keys.txt";
  };
}
