{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey -e  # emacsモードを明示的に有効化（EDITOR=nvim でもCtrl+P等が使えるように）

      # ghq + fzf
      function ghq-fzf() {
        local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
        if [ -n "$src" ]; then
          BUFFER="cd $(ghq root)/$src"
          zle accept-line
        fi
        zle -R -c
      }
      zle -N ghq-fzf
      bindkey '^g' ghq-fzf
    '';
    shellAliases = {
      cat = "bat";
      grep = "rg";
      ls = "eza --icons always --classify always";
      la = "eza --icons always --classify always --all";
      ll = "eza --icons always --long --all --git";
      tree = "eza --icons always --classify always --tree";
      lg = "lazygit";
      claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
    };
  };
}
