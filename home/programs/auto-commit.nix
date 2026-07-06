{ pkgs, config, ... }:
let
  # 自動コミット対象の作業ディレクトリ
  workDir = "${config.home.homeDirectory}/ghq/github.com/ChomoLungma8848/dotfiles";
in
{
  systemd.user.services.auto-commit = {
    Unit = {
      Description = "Run 'claude -p /commit auto' to auto-commit dotfiles changes";
    };

    Service = {
      Type = "oneshot";
      WorkingDirectory = workDir;
      # git/gh/ssh 等を claude-code から使えるよう PATH を通す
      Environment = [
        "PATH=${
          pkgs.lib.makeBinPath [
            pkgs.claude-code
            pkgs.bash
            pkgs.git
            pkgs.gh
            pkgs.openssh
            pkgs.coreutils
          ]
        }"
        # claude の Bash ツールがシェルを起動するために必要
        "SHELL=${pkgs.bash}/bin/bash"
      ];
      ExecStart = ''${pkgs.claude-code}/bin/claude --model sonnet --effort high -p "/commit auto"'';
    };
  };

  systemd.user.timers.auto-commit = {
    Unit = {
      Description = "Timer for auto-commit (daily)";
    };

    Timer = {
      OnCalendar = "daily";
      # マシンが停止していて実行を逃した場合、起動後に実行する
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
