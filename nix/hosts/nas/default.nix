{
  config,
  lib,
  envCfg,
  ...
}: let
  nodeCfg = envCfg.nas;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nas";

  my.profiles.server = {
    enable = true;
    inherit (envCfg) domain;
    inherit (envCfg.network) gateway nameservers prefixLength;
    inherit (nodeCfg) ip;
    interface = nodeCfg.interface or envCfg.defaultInterface;
    network = envCfg.network.prefix;
  };
  my.storage.mainDisk = nodeCfg.mainDisk or envCfg.defaultMainDisk;
  my.storage.dataDisks = nodeCfg.data_disks;

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

  my.services.nfs = {
    enable = true;
    exports = {
      "k8s-volumes".client = "${envCfg.network.prefix}/${toString envCfg.network.prefixLength}";
    };
  };

  system.stateVersion = "24.11";
}
