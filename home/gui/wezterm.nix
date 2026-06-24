{ pkgs, ... }:
let
  inherit (pkgs.lib.generators) mkLuaInline;
in
{
  programs.wezterm = {
    enable = true;

    # noctalia の apply.sh は `config.color_scheme = "Noctalia"` 形式の行を検出すると
    # wezterm.lua の書き換え（clobber）をスキップする。HM側でこの形式の行を出力することで
    # HM管理（symlink）を維持したまま noctalia のカラースキーマを適用する。
    # （settings のテーブル形式 `["color_scheme"]` では noctalia の正規表現にマッチしない）
    extraConfig = ''
      config.color_scheme = "Noctalia"
    '';

    settings = {
      font = mkLuaInline ''wezterm.font("JetBrainsMono Nerd Font")'';
      font_size = 12;
      use_ime = true;
      hide_tab_bar_if_only_one_tab = true;
      window_background_opacity = 0.6;

      leader = {
        key = ";";
        mods = "CTRL";
        timeout_milliseconds = 1000;
      };

      keys = [
        # ペイン分割
        {
          key = "/";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }";
        }
        {
          key = "-";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }";
        }
        # ペインを閉じる
        {
          key = "q";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.CloseCurrentPane { confirm = true }";
        }
        # ペイン移動
        {
          key = "h";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.ActivatePaneDirection 'Left'";
        }
        {
          key = "j";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.ActivatePaneDirection 'Down'";
        }
        {
          key = "k";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.ActivatePaneDirection 'Up'";
        }
        {
          key = "l";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.ActivatePaneDirection 'Right'";
        }
        # ペインサイズ変更
        {
          key = "h";
          mods = "ALT|SHIFT";
          action = mkLuaInline "wezterm.action.AdjustPaneSize { 'Left', 5 }";
        }
        {
          key = "j";
          mods = "ALT|SHIFT";
          action = mkLuaInline "wezterm.action.AdjustPaneSize { 'Down', 5 }";
        }
        {
          key = "k";
          mods = "ALT|SHIFT";
          action = mkLuaInline "wezterm.action.AdjustPaneSize { 'Up', 5 }";
        }
        {
          key = "l";
          mods = "ALT|SHIFT";
          action = mkLuaInline "wezterm.action.AdjustPaneSize { 'Right', 5 }";
        }
      ];
    };
  };
}
