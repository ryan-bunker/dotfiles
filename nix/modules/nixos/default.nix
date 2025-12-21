{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./sddm
    ./sops.nix

    # profiles
    ./profiles
  ];
}
