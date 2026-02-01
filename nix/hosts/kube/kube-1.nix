{pkgs, ...}: {
  networking.hostName = "kube-1";

  my.profiles.server.enable = true;
  my.storage.mainDisk = "/dev/sda";

  system.stateVersion = "24.11";
}
