{ ... }:
let
  # 壁紙は 00e05c2 でリポジトリルートの Wallpaper/ に集約された。
  # 同ディレクトリの ./wallpaper-1.png を指したままだったため eval エラーになっていた
  wallpaper = ../../../../Wallpaper/wallpaper-1.png;
in
{
  # awww デーモン自体は home-manager が systemd user service として起動するが、
  # 壁紙をセットする初回実行は自前で呼ぶ必要がある。
  # import しただけで完結するよう、このモジュール自身が exec-once を宣言する
  # (hyprland の settings は複数モジュールの定義がリスト連結でマージされる)
  services.awww.enable = true;

  wayland.windowManager.hyprland.settings.exec-once = [
    "$HOME/.config/hypr/scripts/awww-init.sh"
  ];

  home.file.".config/hypr/scripts/awww-init.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      awww img "${wallpaper}" --transition-type fade --transition-duration 1
    '';
  };
}
