{
  config,
  lib,
  envCfg,
  nodeCfg,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  my.profiles.server = {
    enable = true;
    inherit (envCfg) domain;
    inherit (envCfg.network) gateway nameservers prefixLength;
    inherit (nodeCfg) ip;
    interface = nodeCfg.interface or envCfg.defaultInterface;
  };
  my.storage.mainDisk = nodeCfg.mainDisk or envCfg.defaultMainDisk;

  my.services.kubernetes =
    {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets.k3s_token.path;
    }
    // lib.optionalAttrs (nodeCfg ? clusterInit) {
      inherit (nodeCfg) clusterInit;
    }
    // lib.optionalAttrs (nodeCfg ? serverAddr) {
      inherit (nodeCfg) serverAddr;
    };

  my.services.ssh.hostKeys = {
    ed25519 = {
      format = "binary";
      sopsFile = ../../../secrets/keys/${config.networking.hostName}/ssh_host_ed25519_key;
    };
    rsa = {
      format = "binary";
      sopsFile = ../../../secrets/keys/${config.networking.hostName}/ssh_host_rsa_key;
    };
  };

  system.stateVersion = "24.11";
}
