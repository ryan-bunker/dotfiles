{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./sddm
    ./sops.nix
    ./ssh.nix
    ./storage.nix

    # profiles
    ./profiles
  ];
}
