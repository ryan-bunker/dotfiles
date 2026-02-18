{
  config,
  pkgs,
  ...
}: {
  networking = {
    hostName = "kube-2";
    domain = "dev.thebunker.house";
    interfaces.enp0s2.ipv4.addresses = [
      {
        address = "192.168.122.101";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.122.1";
    nameservers = ["1.1.1.1"];
    useDHCP = false;
  };

  my.profiles.server.enable = true;
  my.storage.mainDisk = "/dev/vda";

  my.services.kubernetes = {
    enable = true;
    role = "server";
    serverAddr = "https://192.168.122.100:6443";
    tokenFile = config.sops.secrets.k3s_token.path;
  };

  system.stateVersion = "24.11";
}
