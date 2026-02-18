{pkgs, ...}: {
  networking = {
    hostName = "kube-2";
    domain = "dev.thebunker.house";
    interfaces.eth1.ipv4.addresses = [
      {
        address = "192.168.1.101";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1"];
    useDHCP = false;
  };

  my.profiles.server.enable = true;
  my.storage.mainDisk = "/dev/sda";

  system.stateVersion = "24.11";
}
