{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.noctalia = {
    enable = true;

    settings = {
      audio = {
        enable_overdrive = true;
        enable_sounds = true;
      };

      bar = {
        default = {
          background_opacity = 0.6;
          border = "primary";
          border_width = 1.5;
          color = "primary";
          
          capsule_border = "primary";
          capsule_fill = "surface";
          capsule_opacity = 0.8;
          capsule_padding = 10.0;
          capsule_thickness = 0.6;

          margin_ends = 10;
          radius = 80;
          widget_spacing =10;

          capsule_group = [{
            id = "g1";
            border = "";
            fill = "#000000";
            members = [
              "cpu"
              "ram"
              "temp"
              "network_rx"
              "network_tx"
            ];
            opacity = 0.0;
            padding = 0.0;
          }];
          
          start = [
            "launcher"
            "spacer"
            "group:g1"
            "audio_visualizer"
          ];
          center = [
            "taskbar"
          ];
          end = [
            "tray"
            "notifications"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "clock"
            "weather"
            "session"
          ];
        };
      };

      calender = {
        enabled = true;
      };

      control_center = {
        sidebar = "full";
        sidebar_section = "none";
        width = 1020;
      };

      desktop_widgets = {
        schema_version = 2;
        widget_order = [];
        desktop_widgets = {
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
      };

      widget = {};
      };

      dock = {
        auto_hide = true;
        background_opacity = 0.7;
        enabled = true;
        inactive_scale = 0.8;
        launcher_icon = "hyprland";
        launcher_position = "end";
        pinned = [
          "google-chrome"
          "vesktop"
        ];
        radius = 80;
        reserve_space = false;
        show_dots = true;
      };

      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 600;
          };
          lock-and-suspend = {
            action = "lock_and_suspend";
            enabled = false;
            timeout = 900;
          };
          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 660;
          };
        };
      };

      location = {
        auto_locate = true;
      };

      lockscreen = {
        blur_intensity = 0.1;
        fingerprint = false;
        wallpaper = "";
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        # widget_order = [
        #   "lockscreen-login-box@HDMI-A-1"
        #   "lockscreen-widget-0000000000000001"
        #   "lockscreen-widget-0000000000000002"
        # ];

        grid = {
          cell_size = 8;
          major_interval = 4;
          visible = true;
        };

        # widget = {
        #   "lockscreen-login-box@HDMI-A-1" = {
        #     box_height = 70.0;
        #     box_width = 400.0;
        #     cx = 960.0;
        #     cy = 961.0;
        #     output = "HDMI-A-1";
        #     rotation = 0.0;
        #     type = "login_box";
        #     settings = {
        #       background_color = "surface_variant";
        #       background_opacity = 0.88;
        #       background_radius = 12.0;
        #       input_opacity = 1.0;
        #       input_radius = 6.0;
        #       show_login_button = true;
        #     };
        #   };
        #
        #   lockscreen-widget-0000000000000001 = {
        #     box_height = 88.0;
        #     box_width = 200.0;
        #     cx = 1468.0;
        #     cy = 364.0;
        #     output = "HDMI-A-1";
        #     rotation = 0.0;
        #     type = "clock";
        #     settings = {
        #       background = false;
        #       background_color = "on_primary";
        #       background_opacity = 0.7;
        #       background_padding = 15.0;
        #       background_radius = 32.0;
        #       center_text = true;
        #       clock_style = "digital";
        #       color = "#719AC6";
        #       font_family = "JetBrainsMono Nerd Font";
        #       format = "{:%H:%M}";
        #       shadow = false;
        #     };
        #   };
        #
        #   lockscreen-widget-0000000000000002 = {
        #     box_height = 264.0;
        #     box_width = 432.0;
        #     cx = 472.0;
        #     cy = 344.0;
        #     output = "HDMI-A-1";
        #     rotation = 0.0;
        #     type = "weather";
        #     settings = {
        #       background_opacity = 0.65;
        #       background_radius = 32.0;
        #       color = "primary";
        #       show_forecast = true;
        #     };
        #   };
        # };
      };

      notification = {
        background_opacity = 0.7;
      };

      plugins = {
        enabled = [];
      };

      shell = {
        corner_radius_scale = 2.0;
        font_family = "JetBrainsMono Nerd Font";
        password_style = "random";
        screen_time_enabled = true;
        settings_show_advanced = true;
        panel = {
          launcher_session_search = true;
          open_near_click_control_center = true;
          open_near_click_session = true;
          session_placement = "centered";
        };
        screenshot = {
          save_to_file = false;
        };
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
        templates = {
          builtin_ids = [
            "btop"
            "hyprland"
            "wezterm"
          ];
          community_ids = [
            "zen_browser"
            "discord"
          ];
        };
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        transition = ["fade" "wipe" "disc" "stripes" "zoom" "honeycomb"];
        transition_duration = 3000;
        transition_on_startup = true;
        
        directory = "/home/chomo/Wallpaper";
        default.path = "/home/chomo/Wallpaper/wallpaper-1.png";

        automation = {
          enabled = true;
          interval_seconds = 300;
          order = "random";
          recursive = "true";
        };
      };

      widget = {
        audio_visualizer = {
          anchor = true;
          color_2 = "tertiary";
          width = 125.0;
        };

        battery = {
          anchor = true;
          show_label = false;
        };

        bluetooth = {
          scale = 1.2;
        };

        brightness = {
          anchor = true;
          show_label = false;
        };

        clock = {
          anchor = true;
          format = "{:%m/%d %H:%M}";
        };

        cpu = {
          anchor = true;
          show_label = false;
        };

        launcher = {
          anchor = true;
          glyph = "hyprland";
          scale = 1.2;
        };

        network = {
          anchor = true;
          scale = 1.2;
          show_label = false;
        };

        network_rx = {
          anchor = true;
          show_label = false;
        };

        network_tx = {
          show_label = false;
        };

        notifications = {
          anchor = true;
          hide_when_no_unread = true;
          scale = 1.2;
        };

        ram = {
          anchor = true;
          show_label = false;
        };

        session = {
          anchor = true;
          glyph = "snowflake";
          scale = 1.25;
        };

        spacer_1 = {
          type = "spacer";
        };

        taskbar = {
          group_by_workspace = true;
          scale = 1.2;
        };

        temp = {
          anchor = true;
          show_label = false;
        };

        tray = {
          drawer = true;
        };

        volume = {
          anchor = true;
          mute_color = "hover";
          scale = 1.15;
          show_label = false;
        };

        weather = {
          anchor = true;
          show_condition = false;
        };

        workspaces = {
          anchor = true;
          font_weight = 800;
          scale = 1.3;
        };
      };
    };
  };
}
