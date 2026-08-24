{ pkgs, ... }:
let
  hypr-display = pkgs.callPackage ./display.nix { };
in
{
  imports = [
    ./noctalia.nix
  ];

  home.packages = [
    hypr-display
  ]
  ++ (with pkgs; [
    # スクリーンショット用ツール
    grim
    slurp
    wl-clipboard
  ]);

  # fcitx5用の環境変数
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  xdg.configFile."hypr/hyprland.conf".force = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      # モニター設定（自動検出）
      # 環境ごとに変わるモニター名はここに書かない。並び順を変えたいときは
      # $mod SHIFT, P（左右反転）で行う。$mod, P / $mod SHIFT, P はどちらも
      # この定義を hyprctl reload で読み直すため、解像度・スケールの権威はここに残る。
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

      # noctaliaが生成するカラースキーマを読み込む
      # （general の col.active_border / col.inactive_border 等を上書き）
      source = "~/.config/hypr/noctalia.conf";

      # 一般設定
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        layout = "dwindle";
      };

      # 装飾
      decoration = {
        rounding = 20;
        rounding_power = 2;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 4;
          color = "0xee1a1a1a";
        };

        blur = {
          enabled = false;
          size = 3;
          passes = 2;
          new_optimizations = true;
          xray = true;
          popups = true;
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

      # Godotで実行したゲームをフローティングにする
      # (classはproject.godotのconfig/name。エディタ本体はclassが異なるため対象外)
      #
      # サイズは Hyprland 側で持つ(9:19.6 でバーを除く縦いっぱい)。
      # Godot(XWayland)クライアント側のリサイズは Hyprland の管理サイズに
      # 反映されず、初回のウィンドウ移動で初期サイズへ巻き戻されるため、
      # ジオメトリの権威はこの windowrule に置く。ゲーム側(boot.gd)は
      # HYPRLAND_INSTANCE_SIGNATURE 検出時にリサイズをスキップする。
      # 導出: eDP-1 1920x1080、noctalia バー(上34px)を除く高さ 1046、
      #       幅 = round(1046 * 9 / 19.6) = 480
      windowrule = {
        name = "gear-game-float";
        match.class = "^gear-game$";
        float = true;
        size = "480 1046";
        center = 1; # 1 = 予約領域(バー)を避けて中央配置
      };

      # noctalia layerrule
      layerrule = {
        name = "noctalia";
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)\$";
        blur = true;
        blur_popups = true;
        ignore_alpha = 0.5;
        xray = true;
      };

      # キーバインド
      "$mod" = "SUPER";

      bind = [
        "$mod, Space, exec, noctalia msg panel-toggle launcher"
        "$mod, S, exec, noctalia msg panel-toggle control-center"
        "$mod, comma, exec, noctalia msg settings-toggle"
        "$mod, V, exec, noctalia msg panel-toggle clipboard"
        "$mod, Escape, exec, noctalia msg session lock"

        # ディスプレイモード切り替え（Windows の Win+P 相当）
        # 拡張 → 複製 → 内蔵のみ → 外部のみ を巡回する
        "$mod, P, exec, ${hypr-display}/bin/hypr-display cycle"
        # モニターの左右の並び順を反転する
        "$mod SHIFT, P, exec, ${hypr-display}/bin/hypr-display flip"

        "$mod, Return, exec, wezterm"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"

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
        "noctalia"
        "nm-applet --indicator"
        "blueman-applet"
      ];
    };
  };
}
