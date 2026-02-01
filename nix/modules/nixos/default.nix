{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./sddm
    ./sops.nix
    ./storage.nix

    # profiles
    ./profiles
  ];
}
