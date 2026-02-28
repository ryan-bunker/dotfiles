{...}: {
  imports = [
    ./chart-crds.nix
    ./longhorn.nix
    ./metallb.nix
    ./pihole.nix
    ./sops.nix
  ];
}
