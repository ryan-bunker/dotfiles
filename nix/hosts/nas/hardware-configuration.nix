{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # This imports a standard profile from Nixpkgs that includes
  # most common QEMU drivers (virtio, etc.) automatically.
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd" "kvm-intel"];
  boot.extraModulePackages = [];
}
