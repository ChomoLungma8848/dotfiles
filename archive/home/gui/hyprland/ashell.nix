{
  programs.ashell = {
    enable = true;

    # import しただけで自動起動するようにする。
    # これがないと default.nix 側の exec-once に手で足す必要があり、復帰時に忘れる
    systemd.enable = true;
  };
}
