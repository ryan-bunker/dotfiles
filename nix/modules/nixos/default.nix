{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./sddm
    ./sops.nix
    ./ssh.nix
    ./storage.nix

    # users
    ./users

    # profiles
    ./profiles
  ];
}
