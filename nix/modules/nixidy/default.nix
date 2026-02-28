{...}: {
  imports = [
    ./chart-crds.nix
    ./longhorn.nix
    ./metallb.nix
    ./sops.nix
  ];
}
