{ ... }:
let
  # クォートなしのパスリテラル → Nix storeにコピーされ絶対パスになる
  wallpaper = ./wallpaper-1.png;
in
{
  services.swww.enable = true;

  # swwwデーモン起動後に壁紙を設定するスクリプト
  # exec-onceで使用
  home.file.".config/hypr/scripts/swww-init.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      swww img "${wallpaper}" --transition-type fade --transition-duration 1
    '';
  };
}
