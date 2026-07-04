{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings intert

      set -g fish_cursor_insert line
      set -g fish_cursor_default block
      set -g fish_cursor_visual block
    '';

    generateCompletions = true;

    binds = {
      "jj" = {
        mode = "insert";
        command = "";
        setsMode = "default";
        operate = "user";
        silent = true;
      };

      "\\cp" = {
        mode = "insert";
        command = "up-line";
        operate = "user";
      };

      "\\cn" = {
        mode = "insert";
        command = "down-line";
        operate = "user";
      };

      "\\cg" = {
        mode = "insert";
        command = "ghq-fzf";
        operate = "user";
        repaint = true;
      };
    };

    functions = {
      ghq-fzf = ''
        set -l repos=$(ghq list | fzf --cycle --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
        if [ -n "$repos" ]; then
          cd (ghq root)/$repo
        end
      '';
    };

    preferAbbrs = true;

    shellAbbrs = {
      ls = "eza --icons always --classify always";
      ll = "eza --icons always --group-directories-first --total-size --git -la";
      lt = "eza --icons always --classify always -T";
      cat = "bat";
      grep = "rg";
      lg = "lazygit";
      cw = "CLAUDE_CONFIG_DIR=~/.claude-work claude";
      emacs = "emacs --no-window-system";
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "hydro";
        src = pkgs.fishPlugins.hydro.src;
      }
    ];
  };
}
