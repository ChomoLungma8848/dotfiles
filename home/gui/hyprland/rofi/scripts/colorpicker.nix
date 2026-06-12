{ pkgs }:
pkgs.writeShellScriptBin "rofi-colorpicker" ''
  color=$(${pkgs.hyprpicker}/bin/hyprpicker -a)
  if [ -n "$color" ]; then
    ${pkgs.libnotify}/bin/notify-send "󰏘 Color Picker" "Copied: $color"
  fi
''
