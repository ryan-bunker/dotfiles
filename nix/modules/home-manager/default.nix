{...}: {
  imports = [
    # low level modules
    ./aerospace
    ./fuzzel.nix
    ./hypridle.nix
    ./hyprland
    ./hyprlock.nix
    ./kitty.nix
    ./neovim
    ./pass.nix
    ./qutebrowser.nix
    ./sketchybar
    ./sops.nix
    ./spicetify.nix
    ./ssh.nix
    ./tmux
    ./vesktop.nix
    ./wallpapers
    ./zsh

    # profiles
    ./profiles
  ];
}
