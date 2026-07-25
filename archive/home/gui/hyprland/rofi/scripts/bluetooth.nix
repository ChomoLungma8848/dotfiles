{ pkgs }:
pkgs.writeShellScriptBin "rofi-bluetooth" ''
    export PATH="${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.libnotify}/bin:${pkgs.gnused}/bin:$PATH"

    # 一時ファイル
    MENU_FILE=$(mktemp /tmp/rofi-bt-menu.XXXXXX)
    MAC_FILE=$(mktemp /tmp/rofi-bt-macs.XXXXXX)
    RESULT_FILE=$(mktemp /tmp/rofi-bt-result.XXXXXX)
    PID_FILE=$(mktemp /tmp/rofi-bt-pid.XXXXXX)
    REFRESH_FILE="/tmp/rofi-bt-refresh-$$"

    cleanup() {
      bluetoothctl scan off 2>/dev/null
      rm -f "$MENU_FILE" "$MAC_FILE" "$RESULT_FILE" "$PID_FILE" "$REFRESH_FILE"
      [ -n "$MONITOR_PID" ] && kill "$MONITOR_PID" 2>/dev/null
      [ -n "$SCAN_PID" ] && kill "$SCAN_PID" 2>/dev/null
      wait "$MONITOR_PID" 2>/dev/null
      wait "$SCAN_PID" 2>/dev/null
    }
    trap cleanup EXIT

    SCANNING=false

    # Pangoマークアップ用エスケープ
    escape_markup() {
      echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
    }

    # バッテリー残量を取得
    get_battery() {
      local mac=$1
      bluetoothctl info "$mac" 2>/dev/null | grep "Battery Percentage" | awk -F'[()]' '{print $2}'
    }

    # デバイス種別に応じたNerd Fontアイコン
    get_device_icon() {
      local mac=$1
      local icon_type
      icon_type=$(bluetoothctl info "$mac" 2>/dev/null | grep "Icon:" | awk '{print $2}')
      case "$icon_type" in
        audio-headset|audio-headphones) echo "󰋋" ;;
        audio-card|audio-speakers)      echo "󰓃" ;;
        input-keyboard)                 echo "󰌌" ;;
        input-mouse)                    echo "󰍽" ;;
        input-gaming)                   echo "󰊗" ;;
        input-tablet)                   echo "󰓶" ;;
        phone)                          echo "󰏲" ;;
        computer)                       echo "󰟀" ;;
        *)                              echo "󰂳" ;;
      esac
    }

    # Bluetooth変化を監視し、rofiを自動更新する
    monitor_bluetooth() {
      local last=0
      bluetoothctl --monitor 2>/dev/null | grep --line-buffered -E '\[(NEW|DEL|CHG)\]' | while IFS= read -r line; do
        if echo "$line" | grep -qE '\[(NEW|DEL)\]|Connected:|Paired:|Powered:'; then
          now=$(date +%s)
          if (( now - last >= 2 )); then
            last=$now
            touch "$REFRESH_FILE"
            [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null
          fi
        fi
      done
    }
    monitor_bluetooth &
    MONITOR_PID=$!

    build_menu() {
      > "$MENU_FILE"
      > "$MAC_FILE"

      # 電源トグル
      local power_status
      power_status=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

      if [ "$power_status" = "yes" ]; then
        echo "󰂲  Disable Bluetooth" >> "$MENU_FILE"
      else
        echo "󰂯  Enable Bluetooth" >> "$MENU_FILE"
      fi
      echo "__TOGGLE__" >> "$MAC_FILE"

      # 電源OFFなら他の項目は表示しない
      if [ "$power_status" != "yes" ]; then
        return
      fi

      # スキャントグル
      if [ "$SCANNING" = true ]; then
        echo "<span color='#a6e3a1'>󰑓  Scanning...</span>" >> "$MENU_FILE"
      else
        echo "󰑓  Scan for devices" >> "$MENU_FILE"
      fi
      echo "__SCAN__" >> "$MAC_FILE"

      # Discoverableトグル
      local discoverable
      discoverable=$(bluetoothctl show 2>/dev/null | grep "Discoverable:" | awk '{print $2}')
      if [ "$discoverable" = "yes" ]; then
        echo "󰂰  Discoverable (ON)" >> "$MENU_FILE"
      else
        echo "󰂰  Discoverable (OFF)" >> "$MENU_FILE"
      fi
      echo "__DISCOVERABLE__" >> "$MAC_FILE"

      local connected_macs
      connected_macs=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')

      local paired_lines
      paired_lines=$(bluetoothctl devices Paired 2>/dev/null)

      # ── Connected ──
      local has_connected=false
      while read -r line; do
        [ -z "$line" ] && continue
        local mac name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [ -z "$name" ] && continue
        echo "$connected_macs" | grep -q "$mac" || continue

        if [ "$has_connected" = false ]; then
          echo "<span color='#585b70'>── Connected ──</span>" >> "$MENU_FILE"
          echo "__SEP__" >> "$MAC_FILE"
          has_connected=true
        fi

        local icon esc_name battery battery_str
        icon=$(get_device_icon "$mac")
        esc_name=$(escape_markup "$name")
        battery=$(get_battery "$mac")
        if [ -n "$battery" ]; then
          battery_str=" <span color='#6c7086'>($battery%)</span>"
        else
          battery_str=""
        fi
        echo "<span color='#a6e3a1'>$icon  $esc_name</span>$battery_str" >> "$MENU_FILE"
        echo "$mac" >> "$MAC_FILE"
      done <<< "$paired_lines"

      # ── Paired（未接続）──
      local has_paired=false
      while read -r line; do
        [ -z "$line" ] && continue
        local mac name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [ -z "$name" ] && continue
        echo "$connected_macs" | grep -q "$mac" && continue

        if [ "$has_paired" = false ]; then
          echo "<span color='#585b70'>── Paired ──</span>" >> "$MENU_FILE"
          echo "__SEP__" >> "$MAC_FILE"
          has_paired=true
        fi

        local icon esc_name
        icon=$(get_device_icon "$mac")
        esc_name=$(escape_markup "$name")
        echo "$icon  $esc_name" >> "$MENU_FILE"
        echo "$mac" >> "$MAC_FILE"
      done <<< "$paired_lines"

      # ── Available（スキャン中のみ）──
      if [ "$SCANNING" = true ]; then
        local paired_macs
        paired_macs=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}')
        local has_available=false

        while read -r line; do
          [ -z "$line" ] && continue
          local mac name
          mac=$(echo "$line" | awk '{print $2}')
          name=$(echo "$line" | cut -d' ' -f3-)
          [ -z "$name" ] && continue

          # 名前未解決（MACアドレスのみ）のデバイスを除外
          if echo "$name" | grep -qE '^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$'; then
            continue
          fi

          # ペアリング済みは除外
          echo "$paired_macs" | grep -q "$mac" && continue

          if [ "$has_available" = false ]; then
            echo "<span color='#585b70'>── Available ──</span>" >> "$MENU_FILE"
            echo "__SEP__" >> "$MAC_FILE"
            has_available=true
          fi

          local icon esc_name
          icon=$(get_device_icon "$mac")
          esc_name=$(escape_markup "$name")
          echo "<span color='#6c7086'>$icon  $esc_name</span>" >> "$MENU_FILE"
          echo "$mac" >> "$MAC_FILE"
        done < <(bluetoothctl devices 2>/dev/null)
      fi
    }

    # ペアリング済みデバイスのサブメニュー
    device_submenu() {
      local mac=$1
      local name
      name=$(bluetoothctl info "$mac" 2>/dev/null | sed -n 's/.*Name: //p' | head -1)
      [ -z "$name" ] && name="$mac"

      local connected_macs
      connected_macs=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')

      local sub_menu=""
      local sub_actions=""

      if echo "$connected_macs" | grep -q "$mac"; then
        sub_menu="󰂲  Disconnect"
        sub_actions="__DISCONNECT__"
      else
        sub_menu="󰂱  Connect"
        sub_actions="__CONNECT__"
      fi

      sub_menu="$sub_menu
  󰆴  Remove / Forget
  󰁍  Back"
      sub_actions="$sub_actions
  __REMOVE__
  __BACK__"

      local sub_result
      sub_result=$(echo "$sub_menu" | rofi -dmenu -i -p "󰂯 $name" -format i \
        -theme-str 'listview { lines: 4; }' 2>/dev/null)

      [ -z "$sub_result" ] && return

      local action
      action=$(echo "$sub_actions" | sed -n "$((sub_result + 1))p")

      case "$action" in
        __CONNECT__)
          notify-send "Bluetooth" "Connecting to $name..."
          if timeout 15 bluetoothctl connect "$mac" 2>/dev/null; then
            notify-send "Bluetooth" "Connected to $name"
          else
            notify-send "Bluetooth" "Failed to connect to $name"
          fi
          ;;
        __DISCONNECT__)
          if bluetoothctl disconnect "$mac" 2>/dev/null; then
            notify-send "Bluetooth" "Disconnected from $name"
          else
            notify-send "Bluetooth" "Failed to disconnect from $name"
          fi
          ;;
        __REMOVE__)
          local confirm
          confirm=$(printf "Yes, remove\nNo, cancel" | rofi -dmenu -i -p "Remove $name?" \
            -theme-str 'listview { lines: 2; }' 2>/dev/null)
          if [ "$confirm" = "Yes, remove" ]; then
            bluetoothctl remove "$mac" 2>/dev/null
            notify-send "Bluetooth" "Removed $name"
          fi
          ;;
        __BACK__)
          return
          ;;
      esac
    }

    # メインループ（操作後もメニューに戻る）
    while true; do
      build_menu
      rm -f "$REFRESH_FILE"

      # rofiをバックグラウンドで起動（モニターからkillできるように）
      > "$RESULT_FILE"
      rofi -dmenu -i -markup-rows -p "󰂯 Bluetooth" -format i \
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

      # インデックスからアクションを取得
      action=$(sed -n "$((idx + 1))p" "$MAC_FILE")

      case "$action" in
        __SEP__)
          continue
          ;;
        __TOGGLE__)
          power_status=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
          if [ "$power_status" = "yes" ]; then
            bluetoothctl power off 2>/dev/null
            notify-send "Bluetooth" "Bluetooth disabled"
            SCANNING=false
          else
            bluetoothctl power on 2>/dev/null
            notify-send "Bluetooth" "Bluetooth enabled"
          fi
          sleep 1
          ;;
        __SCAN__)
          if [ "$SCANNING" = true ]; then
            bluetoothctl scan off 2>/dev/null
            [ -n "$SCAN_PID" ] && kill "$SCAN_PID" 2>/dev/null
            SCANNING=false
            notify-send "Bluetooth" "Scan stopped"
          else
            bluetoothctl scan on 2>/dev/null &
            SCAN_PID=$!
            SCANNING=true
            notify-send "Bluetooth" "Scanning for devices..."
          fi
          sleep 1
          ;;
        __DISCOVERABLE__)
          discoverable=$(bluetoothctl show 2>/dev/null | grep "Discoverable:" | awk '{print $2}')
          if [ "$discoverable" = "yes" ]; then
            bluetoothctl discoverable off 2>/dev/null
            notify-send "Bluetooth" "Discoverable off"
          else
            bluetoothctl discoverable on 2>/dev/null
            notify-send "Bluetooth" "Discoverable on"
          fi
          sleep 0.5
          ;;
        *)
          if [ -n "$action" ]; then
            # ペアリング済みか確認
            is_paired=false
            bluetoothctl devices Paired 2>/dev/null | awk '{print $2}' | grep -q "$action" && is_paired=true

            if [ "$is_paired" = true ]; then
              # サブメニュー（Connect/Disconnect/Remove）
              device_submenu "$action"
            else
              # 新規デバイス → pair → trust → connect
              name=$(bluetoothctl devices 2>/dev/null | grep "$action" | cut -d' ' -f3-)
              [ -z "$name" ] && name="$action"
              notify-send "Bluetooth" "Pairing with $name..."
              if timeout 15 bluetoothctl pair "$action" 2>/dev/null; then
                bluetoothctl trust "$action" 2>/dev/null
                notify-send "Bluetooth" "Connecting to $name..."
                if timeout 15 bluetoothctl connect "$action" 2>/dev/null; then
                  notify-send "Bluetooth" "Connected to $name"
                else
                  notify-send "Bluetooth" "Paired but failed to connect to $name"
                fi
              else
                notify-send "Bluetooth" "Failed to pair with $name"
              fi
            fi
          fi
          ;;
      esac
    done
''
