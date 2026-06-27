{ pkgs }:
pkgs.writeShellScriptBin "rofi-wifi" ''
    export PATH="${pkgs.networkmanager}/bin:${pkgs.gnugrep}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.libnotify}/bin:${pkgs.gnused}/bin:$PATH"

    # 一時ファイル
    MENU_FILE=$(mktemp /tmp/rofi-wifi-menu.XXXXXX)
    SSID_FILE=$(mktemp /tmp/rofi-wifi-ssids.XXXXXX)
    RESULT_FILE=$(mktemp /tmp/rofi-wifi-result.XXXXXX)
    PID_FILE=$(mktemp /tmp/rofi-wifi-pid.XXXXXX)
    REFRESH_FILE="/tmp/rofi-wifi-refresh-$$"

    cleanup() {
      rm -f "$MENU_FILE" "$SSID_FILE" "$RESULT_FILE" "$PID_FILE" "$REFRESH_FILE"
      [ -n "$MONITOR_PID" ] && kill "$MONITOR_PID" 2>/dev/null
      wait "$MONITOR_PID" 2>/dev/null
    }
    trap cleanup EXIT

    # ネットワーク変化を監視し、rofiを自動更新する
    monitor_network() {
      local last=0
      nmcli monitor 2>/dev/null | while IFS= read -r _; do
        now=$(date +%s)
        if (( now - last >= 2 )); then
          last=$now
          touch "$REFRESH_FILE"
          [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null
        fi
      done
    }
    monitor_network &
    MONITOR_PID=$!

    # Pangoマークアップ用エスケープ
    escape_markup() {
      echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
    }

    build_menu() {
      > "$MENU_FILE"
      > "$SSID_FILE"

      # WiFi ON/OFFトグル
      if [ "$(nmcli radio wifi)" = "disabled" ]; then
        echo "󰖪  Enable WiFi" >> "$MENU_FILE"
      else
        echo "󰖩  Disable WiFi" >> "$MENU_FILE"
      fi
      echo "__TOGGLE__" >> "$SSID_FILE"

      # リスキャン
      echo "󰑓  Rescan" >> "$MENU_FILE"
      echo "__RESCAN__" >> "$SSID_FILE"

      # 現在の接続
      local current
      current=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)

      # ── 接続中セクション ──
      if [ -n "$current" ]; then
        echo "<span color='#585b70'>── Connected ──</span>" >> "$MENU_FILE"
        echo "__SEP__" >> "$SSID_FILE"

        local esc_current
        esc_current=$(escape_markup "$current")
        echo "<span color='#a6e3a1'><b>󰤨  $esc_current</b></span>" >> "$MENU_FILE"
        echo "$current" >> "$SSID_FILE"
      fi

      # ── 使用可能セクション ──
      local has_available=false
      local available_entries=""
      local available_ssids=""

      while IFS=: read -r ssid signal security; do
        [ -z "$ssid" ] && continue
        [ "$ssid" = "--" ] && continue
        [ "$ssid" = "$current" ] && continue

        local icon
        if [ -n "$security" ] && [ "$security" != "--" ] && [ "$security" != "" ]; then
          icon="󰤡"
        else
          icon="󰤯"
        fi

        local esc_ssid
        esc_ssid=$(escape_markup "$ssid")
        available_entries="$available_entries
  $icon  $esc_ssid <span color='#6c7086'>($signal%)</span>"
        available_ssids="$available_ssids
  $ssid"
        has_available=true
      done < <(nmcli -t -f ssid,signal,security dev wifi list 2>/dev/null | sort -t: -k2 -nr | awk -F: '!seen[$1]++')

      if [ "$has_available" = true ]; then
        echo "<span color='#585b70'>── Available ──</span>" >> "$MENU_FILE"
        echo "__SEP__" >> "$SSID_FILE"

        echo "$available_entries" | tail -n +2 >> "$MENU_FILE"
        echo "$available_ssids" | tail -n +2 >> "$SSID_FILE"
      fi
    }

    # メインループ（操作後もメニューに戻る）
    while true; do
      build_menu
      rm -f "$REFRESH_FILE"

      # rofiをバックグラウンドで起動（モニターからkillできるように）
      > "$RESULT_FILE"
      rofi -dmenu -i -markup-rows -p "󰖩 WiFi" -format i \
        -theme-str 'listview { lines: 12; }' \
        < "$MENU_FILE" > "$RESULT_FILE" 2>/dev/null &
      ROFI_PID=$!
      echo "$ROFI_PID" > "$PID_FILE"
      wait "$ROFI_PID" 2>/dev/null
      rofi_exit=$?

      idx=$(cat "$RESULT_FILE")

      # モニターによるリフレッシュ → メニューを再表示
      if [ -f "$REFRESH_FILE" ]; then
        rm -f "$REFRESH_FILE"
        sleep 0.3
        continue
      fi

      # Escape → 終了
      [ $rofi_exit -ne 0 ] && break
      [ -z "$idx" ] && break

      # インデックスからSSIDを取得（パース不要で確実）
      ssid=$(sed -n "$((idx + 1))p" "$SSID_FILE")

      case "$ssid" in
        __SEP__)
          continue
          ;;
        __TOGGLE__)
          if [ "$(nmcli radio wifi)" = "disabled" ]; then
            nmcli radio wifi on
            notify-send "WiFi" "WiFi enabled"
          else
            nmcli radio wifi off
            notify-send "WiFi" "WiFi disabled"
          fi
          sleep 1
          ;;
        __RESCAN__)
          notify-send "WiFi" "Scanning..."
          nmcli dev wifi rescan 2>/dev/null
          sleep 2
          ;;
        *)
          if [ -n "$ssid" ]; then
            # 接続済みなら何もしない
            current=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
            if [ "$ssid" = "$current" ]; then
              continue
            fi

            # 既知のネットワーク → 保存済み情報で接続
            if nmcli -t -f name con show 2>/dev/null | grep -qx "$ssid"; then
              if nmcli con up "$ssid" 2>/dev/null; then
                notify-send "WiFi" "Connected to $ssid"
              else
                notify-send "WiFi" "Failed to connect to $ssid"
              fi
            else
              # セキュリティ確認
              security=$(nmcli -t -f ssid,security dev wifi list 2>/dev/null | awk -F: -v s="$ssid" '$1 == s {print $2; exit}')
              if [ -z "$security" ] || [ "$security" = "--" ]; then
                # オープンネットワーク → パスワードなしで接続
                if nmcli dev wifi connect "$ssid" 2>/dev/null; then
                  notify-send "WiFi" "Connected to $ssid"
                else
                  notify-send "WiFi" "Failed to connect to $ssid"
                fi
              else
                # セキュリティありネットワーク → パスワード入力
                pass=$(rofi -dmenu -p "  $ssid" -password \
                  -theme-str 'listview { lines: 0; }')
                if [ -n "$pass" ]; then
                  if nmcli dev wifi connect "$ssid" password "$pass" 2>/dev/null; then
                    notify-send "WiFi" "Connected to $ssid"
                  else
                    notify-send "WiFi" "Failed to connect to $ssid"
                  fi
                fi
              fi
            fi
          fi
          ;;
      esac
    done
''
