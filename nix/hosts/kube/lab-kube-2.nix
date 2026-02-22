{
  config,
  pkgs,
  ...
}: {
  networking = {
    hostName = "kube-2";
    domain = "dev.thebunker.house";
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "10.17.0.11";
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
    serverAddr = "https://10.17.0.10:6443";
    tokenFile = config.sops.secrets.k3s_token.path;
  };

  system.stateVersion = "24.11";
}
