{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./impermanence.nix
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
