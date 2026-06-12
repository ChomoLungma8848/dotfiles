{ pkgs }:
pkgs.writeShellScriptBin "rofi-hub" ''
  options="󰀻  Apps\n󰖯  Windows\n󰖩  WiFi\n󰂯  Bluetooth\n󰈙  Files\n󰏘  Color Picker\n  Nerd Icons\n󰐥  Power"

  chosen=$(echo -e "$options" | rofi -dmenu -i -p "Menu" -theme-str 'listview { lines: 8; }')

  case "$chosen" in
    *Apps*) rofi -show drun ;;
    *Windows*) rofi -show window ;;
    *WiFi*) rofi-wifi ;;
    *Bluetooth*) rofi-bluetooth ;;
    *Files*) rofi-files ;;
    *Color*) rofi-colorpicker ;;
    *Nerd*) rofi-nerd ;;
    *Power*) rofi-power ;;
  esac
''
