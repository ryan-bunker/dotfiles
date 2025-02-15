{ pkgs, ... }:
let
  catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "dreamsofcode-io";
      repo = "catppuccin-tmux";
      rev = "main";
      sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
    };
  };
in 
{
  enable = true;

  mouse = true;
  prefix = "C-Space";
  baseIndex = 1;
  keyMode = "vi";
  escapeTime = 10;
  terminal = "tmux-256color";
  focusEvents = true;

  extraConfig = ''
    # keybindings
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Open panes in current directory
    bind '"' split-window -v -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"

    set -gu default-command
    set -g default-shell "$SHELL"
  '';

  plugins = with pkgs.tmuxPlugins; [
    vim-tmux-navigator
    {
      plugin = catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavour 'macchiato'

        # Catppuccin settings
        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_default_text "#W"
        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#W"
        set -g @catppuccin_window_status_icon_enable "yes"
        set -g @catppuccin_status_modules_right "session"
        set -g @catppuccin_status_modules_left "directory"
      '';
    }
    yank
  ];
}
