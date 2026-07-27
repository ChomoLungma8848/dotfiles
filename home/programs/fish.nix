{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings insert

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
        command = "up-or-search";
        operate = "user";
      };

      "\\cn" = {
        mode = "insert";
        command = "down-or-search";
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
        set -l repo $(ghq list | fzf --cycle --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
        if test -n "$repo"
          cd (ghq root)/$repo
        end
      '';

      # サブディレクトリで起動すると claude が cwd をプロジェクトルートとみなし、
      # ルートの settings.json / CLAUDE.md を読まず、その場に .claude を作ってしまう。
      # git ルートへ移動してから起動することで常にルート起点に固定する。
      # claude 終了後はシェルの cwd を元に戻す (pushd/popd)。
      # git 管理外や意図的にサブディレクトリで起動したい場合は `command claude` を使う。
      claude = {
        wraps = "claude";
        description = "Launch claude from the git repository root";
        body = ''
          set -l root (git rev-parse --show-toplevel 2>/dev/null)
          if test -n "$root"; and test "$root" != "$PWD"
            pushd $root
            command claude $argv
            popd
          else
            command claude $argv
          end
        '';
      };
    };

    preferAbbrs = true;

    shellAbbrs = {
      cd = "z";
      ls = "eza --icons always --classify always";
      ll = "eza --icons always --group-directories-first --git -la";
      lt = "eza --icons always --classify always -T";
      cat = "bat";
      grep = "rg";
      lg = "lazygit";
      cw = "CLAUDE_CONFIG_DIR=~/.claude-work claude";
      cmt = ''claude --model sonnet --effort high "/commit auto"'';
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      # {
      #   name = "fzf-fish";
      #   src = pkgs.fishPlugins.fzf-fish.src;
      # }
      # {
      #   name = "hydro";
      #   src = pkgs.fishPlugins.hydro.src;
      # }
    ];
  };
}
