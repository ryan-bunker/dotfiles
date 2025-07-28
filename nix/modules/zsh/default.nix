{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history = {
      size = 5000;
      save = 5000;
      append = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      cat = "bat";
      k = "kubectl";
      kns = "kubectl config set-context --current --namespace";
      ls = "eza";
    };
    # TODO: evaluation warning: `programs.zsh.initExtraFirst` is deprecated, use `programs.zsh.initContent` with `lib.mkBefore` instead.
    #   Example: programs.zsh.initContent = lib.mkBefore "your content here";
    initExtraFirst = ''
      # Setup homebrew on systems where it is installed
      [ -s /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    # TODO: evaluation warning: `programs.zsh.initExtra` is deprecated, use `programs.zsh.initContent` instead.
    #   Example: programs.zsh.initContent = "your content here";
    initExtra = ''
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      # Keybindings
      bindkey '^f' autosuggest-accept
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey "^[[A" up-line-or-beginning-search # Up
      bindkey "^[[B" down-line-or-beginning-search # Down
      bindkey "^[[1~" beginning-of-line # Home
      bindkey "^[[4~" end-of-line # End
      bindkey -s '^g' "tmux-sessionizer\n"

      HISTDUP=erase
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_FIND_NO_DUPS

      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "\$\{(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      source <(kubectl completion zsh)
    '';
    plugins =
      [
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-completions";
          src = pkgs.zsh-completions;
          file = "share/zsh-completions/zsh-completions.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ]
      ++ map (p: {
        name = "omzp::${p}";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/${p}/${p}.plugin.zsh";
      }) ["asdf" "git" "sudo" "aws" "command-not-found" "kubectx"];
  };

  programs.oh-my-posh = {
    enable = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ./oh-my-posh.toml));
  };
}
