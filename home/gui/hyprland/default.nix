{ pkgs, ... }:
{
  imports = [
    # ./waybar.nix
    # ./ashell.nix
    ./noctalia.nix
    # ./fuzzel.nix
    # ./hyprlauncher.nix
    ./rofi
    ./mako.nix
    ./awww.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  # スクリーンショット用ツール
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];

  # fcitx5用の環境変数
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      # モニター設定（自動検出）
      monitor = ",preferred,auto,1";

      # fcitx5用環境変数（Hyprland経由で起動するアプリに確実に渡す）
      env = [
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
        "INPUT_METHOD,fcitx"
        "SDL_IM_MODULE,fcitx"
        "GLFW_IM_MODULE,ibus"
      ];

      # 入力設定
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      # 一般設定
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # 装飾
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
      };

      # アニメーション
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # レイアウト
      dwindle = {
        preserve_split = true;
      };

      # キーバインド
      "$mod" = "SUPER";

      bind = [
        "$mod, Space, exec, noctalia-shell ipc call launcher toggle"

        "$mod, Return, exec, wezterm"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"
        "$mod, D, exec, rofi-hub"

        # フォーカス移動
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # ワークスペース切り替え
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        # ウィンドウをワークスペースに移動
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        # スクリーンショット（クリップボードへ）
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        ", Print, exec, grim - | wl-copy"

        # special workspace（最小化の代替）
        "$mod, Tab, togglespecialworkspace, magic"
        "$mod SHIFT, Tab, movetoworkspacesilent, special:magic"

        # ロック
        "$mod, Escape, exec, hyprlock"

        # ウィンドウ移動
        "$mod CTRL, H, movewindow, l"
        "$mod CTRL, L, movewindow, r"
        "$mod CTRL, K, movewindow, u"
        "$mod CTRL, J, movewindow, d"
      ];

      # ウィンドウリサイズ（キーリピート対応）
      binde = [
        "$mod SHIFT, H, resizeactive, -20 0"
        "$mod SHIFT, L, resizeactive, 20 0"
        "$mod SHIFT, K, resizeactive, 0 -20"
        "$mod SHIFT, J, resizeactive, 0 20"
      ];

      # マウスバインド
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # 自動起動
      exec-once = [
        "fcitx5 -d"
        # "wqyber"
        # "ashell"
        "noctalia-shell"
        "$HOME/.config/hypr/scripts/awww-init.sh"
        "hypridle"
        "nm-applet --indicator"
        "blueman-applet"
      ];
    };
  };
}
