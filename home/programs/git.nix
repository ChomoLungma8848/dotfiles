{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "ChomoLungma8848";
        email = "chomo_lungma@icloud.com";
      };

      core.editor = "nvim";
      init.defaultBranch = "main";
      commit.verbose = true;
      pull.rebase = true;
      push.autoSetupRemoto = true;

      ghq.root = "~/ghq";
    };
  };
}
