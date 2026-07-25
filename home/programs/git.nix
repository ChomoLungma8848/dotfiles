{
  programs.git = {
    enable = true;

    # ~/.config/git/ignore を生成する。
    # サブディレクトリで claude を起動するとそこに .claude/settings.local.json が
    # 作られるため、リポジトリ側の .gitignore に頼らずユーザレベルで無視する
    ignores = [ "**/.claude/settings.local.json" ];

    settings = {
      user = {
        name = "ChomoLungma8848";
        email = "chomo_lungma@icloud.com";
      };

      core.editor = "nvim";
      init.defaultBranch = "main";
      commit.verbose = true;
      pull.rebase = true;
      push.autoSetupRemote = true;

      ghq.root = "~/ghq";
    };
  };
}
