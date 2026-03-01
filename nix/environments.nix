{
  lab = {
    domain = "dev.thebunker.house";
    network = {
      prefix = "10.17.0.0";
      prefixLength = 24;
      gateway = "10.17.0.1";
      fixed_ips = {
        proxmox = "10.17.0.20";
      };
      dhcp_range = {
        start = "10.17.0.100";
        end = "10.17.0.250";
      };
      metallb_range = "10.17.0.64/27";
      pihole_ip = "10.17.0.64";
      nameservers = ["1.1.1.1"];
    };
    defaultInterface = "enp1s0";
    defaultMainDisk = "/dev/vda";
    nodes = {
      "lab-kube-1" = {
        ip = "10.17.0.10";
        clusterInit = true;
      };
      "lab-kube-2" = {
        ip = "10.17.0.11";
        serverAddr = "https://10.17.0.10:6443";
      };
      "lab-kube-3" = {
        ip = "10.17.0.12";
        serverAddr = "https://10.17.0.10:6443";
      };
    };
  };
  # prod = {
  #   domain = "thebunker.house";
  #   gateway = "192.168.1.1";
  #   prefixLength = 24;
  #   nameservers = ["1.1.1.1"];
  #   defaultInterface = "eth1";
  #   defaultMainDisk = "/dev/sda";
  #   nodes = {
  #     "kube-1" = {
  #       ip = "192.168.1.10";
  #       clusterInit = true;
  #     };
  #     "kube-2" = {
  #       ip = "192.168.1.11";
  #       serverAddr = "https://192.168.1.10:6443";
  #     };
  #     "kube-3" = {
  #       ip = "192.168.1.12";
  #       serverAddr = "https://192.168.1.10:6443";
  #     };
  #   };
  # };
}
