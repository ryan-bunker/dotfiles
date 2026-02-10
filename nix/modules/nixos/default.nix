{...}: {
  imports = [
    # low level modules
    ./hyprland.nix
    ./impermanence.nix
    ./sddm
    ./secure-boot.nix
    ./sops.nix
    ./ssh.nix
    ./storage.nix
    ./virtualisation.nix

    # users
    ./users

    # profiles
    ./profiles
  ];
}
