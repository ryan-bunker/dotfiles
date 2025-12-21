{...}: {
  imports = [
    # low level modules
    ./aerospace
    ./fuzzel.nix
    ./hyprland
    ./kitty.nix
    ./neovim
    ./pass.nix
    ./qutebrowser.nix
    ./sketchybar
    ./spicetify.nix
    ./tmux
    ./vesktop.nix
    ./wallpapers
    ./zsh

    # profiles
    ./profiles
  ];
}
