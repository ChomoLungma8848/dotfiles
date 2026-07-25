{ pkgs }:
pkgs.writeShellScriptBin "rofi-power" ''
    options="󰌾  Lock
  󰗽  Logout
  󰤄  Suspend
  󰜉  Reboot
  󰐥  Shutdown"

    chosen=$(echo "$options" | rofi -dmenu -i -p "󰐥 Power" -theme-str 'listview { lines: 5; }')

    case "$chosen" in
      *Lock*) hyprlock ;;
      *Logout*) hyprctl dispatch exit ;;
      *Suspend*) systemctl suspend ;;
      *Reboot*) systemctl reboot ;;
      *Shutdown*) systemctl poweroff ;;
    esac
''
