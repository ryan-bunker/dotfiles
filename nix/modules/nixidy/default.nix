{...}: {
  imports = [
    ./chart-crds.nix
    ./csi-driver-nfs.nix
    ./longhorn.nix
    ./metallb.nix
    ./pihole.nix
    ./sops.nix
  ];
}
