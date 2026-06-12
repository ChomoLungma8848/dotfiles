{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        spacing = 0;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;

        modules-left = [
          "custom/logo"
          "hyprland/workspaces"
        ];
        modules-center = [ "wlr/taskbar" ];
        modules-right = [
          "cpu"
          "memory"
          "pulseaudio"
          "bluetooth"
          "network"
          "backlight"
          "battery"
          "clock"
          "custom/power"
        ];

        "custom/logo" = {
          format = " ";
          tooltip = false;
          on-click = "rofi -show drun";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            urgent = "";
            default = "";
          };
          on-click = "activate";
          persistent-workspaces = {
            "*" = 5;
          };
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          icon-theme = "Papirus-Dark";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
          tooltip = true;
          on-click = "gnome-system-monitor";
        };

        memory = {
          interval = 5;
          format = " {percentage}%";
          tooltip-format = "{used:0.1f}GB / {total:0.1f}GB";
          on-click = "gnome-system-monitor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip-format = "{desc}";
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          scroll-step = 5;
        };

        bluetooth = {
          format = "";
          format-connected = " {num_connections}";
          format-disabled = "󰂲";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = " ";
          format-ethernet = "󰌗 ";
          format-disconnected = "󰤯 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}";
          on-click = "nm-connection-editor";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [
            "󱩎"
            "󱩏"
            "󱩐"
            "󱩑"
            "󱩒"
            "󱩓"
            "󱩔"
            "󱩕"
            "󱩖"
            "󰛨"
          ];
          tooltip-format = "Brightness: {percent}%";
          scroll-step = 5;
          on-click = "${pkgs.brightnessctl}/bin/brightnessctl set 50%";
        };

        battery = {
          interval = 30;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [
            "󰁻"
            "󰁽"
            "󰁿"
            "󰂁"
            "󰁹"
          ];
          tooltip-format = "{timeTo}";
          on-click = "gnome-control-center power";
        };

        clock = {
          format = " {:%m/%d %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#f5e0dc'><b>{}</b></span>";
              days = "<span color='#cdd6f4'>{}</span>";
              weeks = "<span color='#94e2d5'>W{}</span>";
              weekdays = "<span color='#f9e2af'>{}</span>";
              today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click = "mode";
            on-click-right = "gnome-calendar";
          };
        };

        "custom/power" = {
          format = " ";
          tooltip = false;
          on-click = "rofi-power";
        };
      };
    };

    style = ''
      /* Catppuccin Mocha Colors */
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 14px;
        font-weight: 600;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: @text;
      }

      window#waybar > box {
        background: transparent;
      }

      /* Module Groups */
      .modules-left,
      .modules-center,
      .modules-right {
        background: transparent;
      }

      /* Left Modules Container */
      .modules-left > widget:first-child > #custom-logo {
        margin-left: 0;
        border-radius: 0 0 0 0;
        padding-left: 8px;
      }

      .modules-left > widget:last-child > #workspaces {
        border-radius: 0 12px 12px 0;
        padding-right: 8px;
      }

      /* Custom Logo */
      #custom-logo {
        background: linear-gradient(135deg, alpha(@mauve, 0.9), alpha(@blue, 0.9));
        color: @crust;
        font-size: 18px;
      }

      #custom-logo:hover {
        background: linear-gradient(135deg, @mauve, @blue);
      }

      /* Workspaces */
      #workspaces {
        background: alpha(@surface0, 0.85);
        padding: 0 4px;
      }

      #workspaces button {
        color: @overlay1;
        padding: 0 8px;
        margin: 4px 2px;
        border-radius: 8px;
        background: transparent;
        transition: all 0.2s ease;
      }

      #workspaces button:hover {
        color: @text;
        background: alpha(@surface2, 0.8);
      }

      #workspaces button.active {
        color: @crust;
        background: linear-gradient(135deg, @mauve, @lavender);
        box-shadow: 0 2px 8px alpha(@mauve, 0.4);
      }

      #workspaces button.urgent {
        color: @crust;
        background: @red;
      }

      /* Center Taskbar */
      #taskbar {
        background: alpha(@surface0, 0.85);
        border-radius: 12px;
        padding: 4px 12px;
      }

      #taskbar button {
        padding: 0 6px;
        margin: 0 2px;
        border-radius: 8px;
        background: transparent;
        transition: all 0.2s ease;
      }

      #taskbar button:hover {
        background: alpha(@surface2, 0.8);
      }

      #taskbar button.active {
        background: alpha(@mauve, 0.3);
      }

      /* Right Modules - Pill Style */
      .modules-right > widget > * {
        background: alpha(@surface0, 0.85);
        padding: 0 14px;
      }

      .modules-right > widget:first-child > * {
        border-radius: 12px 0 0 12px;
        margin-left: 0;
      }

      .modules-right > widget:last-child > * {
        border-radius: 0 0 0 0;
        margin-right: 0;
      }

      /* CPU */
      #cpu {
        color: @teal;
      }

      #cpu:hover {
        background: alpha(@teal, 0.2);
      }

      /* Memory */
      #memory {
        color: @green;
      }

      #memory:hover {
        background: alpha(@green, 0.2);
      }

      /* Pulseaudio */
      #pulseaudio {
        color: @yellow;
      }

      #pulseaudio:hover {
        background: alpha(@yellow, 0.2);
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      /* Bluetooth */
      #bluetooth {
        color: @blue;
      }

      #bluetooth:hover {
        background: alpha(@blue, 0.2);
      }

      #bluetooth.disabled {
        color: @overlay0;
      }

      #bluetooth.connected {
        color: @sapphire;
      }

      /* Network */
      #network {
        color: @lavender;
      }

      #network:hover {
        background: alpha(@lavender, 0.2);
      }

      #network.disconnected {
        color: @overlay0;
      }

      /* Backlight */
      #backlight {
        color: @peach;
      }

      #backlight:hover {
        background: alpha(@peach, 0.2);
      }

      /* Battery */
      #battery {
        color: @green;
      }

      #battery:hover {
        background: alpha(@green, 0.2);
      }

      #battery.charging {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @peach;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }

      /* Clock */
      #clock {
        color: @rosewater;
      }

      #clock:hover {
        background: alpha(@rosewater, 0.2);
      }

      /* Power Button */
      #custom-power {
        color: @red;
        padding-right: 14px;
      }

      #custom-power:hover {
        background: alpha(@red, 0.3);
        color: @crust;
      }

      /* Tooltip Styling */
      tooltip {
        background: alpha(@base, 0.95);
        border: 1px solid @surface1;
        border-radius: 12px;
        padding: 8px;
      }

      tooltip label {
        color: @text;
        padding: 4px;
      }
    '';
  };
}
