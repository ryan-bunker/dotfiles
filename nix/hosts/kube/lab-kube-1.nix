{
  config,
  pkgs,
  ...
}: {
  networking = {
    hostName = "kube-1";
    domain = "dev.thebunker.house";
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "10.17.0.10";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.17.0.1";
    nameservers = ["1.1.1.1"];
    useDHCP = false;
  };

  my.profiles.server.enable = true;
  my.storage.mainDisk = "/dev/vda";

  my.services.kubernetes = {
    enable = true;
    role = "server";
    clusterInit = true;
    tokenFile = config.sops.secrets.k3s_token.path;
  };

  my.services.ssh.hostKeys = {
    ed25519 = {
      format = "binary";
      sopsFile = ../../../secrets/keys/lab-kube-1/ssh_host_ed25519_key;
    };
    rsa = {
      format = "binary";
      sopsFile = ../../../secrets/keys/lab-kube-1/ssh_host_rsa_key;
    };
  };

  system.stateVersion = "24.11";
}
