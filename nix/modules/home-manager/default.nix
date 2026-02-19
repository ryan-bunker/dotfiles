{...}: {
  imports = [
    # low level modules
    ./aerospace
    ./avizo.nix
    ./fuzzel.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./kitty.nix
    ./neovim
    ./opencode.nix
    ./pass.nix
    ./qutebrowser.nix
    ./sketchybar
    ./sops.nix
    ./spicetify.nix
    ./ssh.nix
    ./tmux
    ./vesktop.nix
    ./wallpapers
    ./wezterm
    ./zsh

    # profiles
    ./profiles
  ];
}
