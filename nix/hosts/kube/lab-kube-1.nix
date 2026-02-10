{pkgs, ...}: {
  networking = {
    hostName = "kube-1";
    domain = "dev.thebunker.house";
    interfaces.enp0s2.ipv4.addresses = [
      {
        address = "192.168.122.100";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.122.1";
    nameservers = ["1.1.1.1"];
    useDHCP = false;
  };

  my.profiles.server.enable = true;
  my.storage.mainDisk = "/dev/vda";

  system.stateVersion = "24.11";
}
