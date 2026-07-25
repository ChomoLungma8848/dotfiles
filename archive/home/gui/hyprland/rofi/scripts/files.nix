{ pkgs }:
pkgs.writeShellScriptBin "rofi-files" ''
  export PATH="${pkgs.fd}/bin:${pkgs.coreutils}/bin:${pkgs.gnused}/bin:${pkgs.xdg-utils}/bin:$PATH"

  # ファイルにアイコンを付与する関数
  add_icon() {
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      ext="''${file##*.}"
      case "$ext" in
        # コード
        nix) echo "  $file" ;;
        rs) echo "  $file" ;;
        py) echo "  $file" ;;
        js|jsx) echo "  $file" ;;
        ts|tsx) echo "  $file" ;;
        go) echo "  $file" ;;
        lua) echo "  $file" ;;
        sh|bash|zsh) echo "  $file" ;;
        c|h) echo "  $file" ;;
        cpp|hpp|cc) echo "  $file" ;;
        java) echo "  $file" ;;
        rb) echo "  $file" ;;
        php) echo "  $file" ;;
        html|htm) echo "  $file" ;;
        css|scss|sass) echo "  $file" ;;
        json) echo "  $file" ;;
        yaml|yml) echo "  $file" ;;
        toml) echo "  $file" ;;
        xml) echo "󰗀  $file" ;;
        sql) echo "  $file" ;;
        # ドキュメント
        md|markdown) echo "  $file" ;;
        txt) echo "  $file" ;;
        pdf) echo "  $file" ;;
        doc|docx) echo "󰈬  $file" ;;
        xls|xlsx) echo "󰈛  $file" ;;
        ppt|pptx) echo "󰈧  $file" ;;
        # 画像
        png|jpg|jpeg|gif|bmp|svg|webp) echo "  $file" ;;
        # 音声・動画
        mp3|wav|flac|ogg|m4a) echo "  $file" ;;
        mp4|mkv|avi|mov|webm) echo "  $file" ;;
        # アーカイブ
        zip|tar|gz|bz2|xz|7z|rar) echo "  $file" ;;
        # 設定
        conf|cfg|ini) echo "  $file" ;;
        lock) echo "  $file" ;;
        # Git
        gitignore) echo "  $file" ;;
        # その他
        *) echo "  $file" ;;
      esac
    done
  }

  # fd でファイル検索、アイコン付きで表示
  selected=$(fd --type f --hidden --exclude .git --exclude node_modules --exclude .cache --max-depth 6 . "$HOME" 2>/dev/null | \
             head -5000 | \
             add_icon | \
             rofi -dmenu -i -p " Files" -theme-str 'listview { lines: 15; }')

  if [ -n "$selected" ]; then
    # アイコンを除去してファイルパスを取得
    file=$(echo "$selected" | sed 's/^[^ ]* *//')
    xdg-open "$file" 2>/dev/null || wezterm start -- nvim "$file"
  fi
''
