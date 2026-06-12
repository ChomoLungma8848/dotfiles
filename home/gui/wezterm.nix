{ pkgs, ... }:
let
  general = ''
    automatically_reload_config = true,
    window_background_opacity = 0.7,
    color_scheme = "iceberg-dark",
    font = wezterm.font("JetBrainsMono Nerd Font"),
    font_size = 12.0,
    use_ime = true,
    window_frame = {
      inactive_titlebar_bg = "none",
      active_titlebar_bg = "none",
    },
    window_background_gradient = {
      colors = { "161821" },
    },
  '';

  tabBar = ''
    hide_tab_bar_if_only_one_tab = true,
    show_new_tab_button_in_tab_bar = false,
    show_close_tab_button_in_tabs = false,
    colors = {
      tab_bar = {
        active_tab = { bg_color = "#223a70", fg_color = "#c6c8d1" },
        inactive_tab = { bg_color = "none", fg_color = "#6b7089" },
        inactive_tab_hover = { bg_color = "#393f4c", fg_color = "#6b7089", italic = true },
      },
    },
  '';

  keys = ''
    leader = { key = ';', mods = 'CTRL', timeout_milliseconds = 1000 },
    keys = {
      -- ペイン分割
      { key = '/', mods = 'ALT', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
      { key = '-', mods = 'ALT', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
      -- ペインを閉じる
      { key = 'x', mods = 'ALT', action = act.CloseCurrentPane{ confirm = true } },
      -- ペイン移動
      { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
      { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
      { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
      { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
      -- ペインサイズ変更
      { key = 'h', mods = 'ALT|SHIFT', action = act.AdjustPaneSize{ 'Left', 5 } },
      { key = 'j', mods = 'ALT|SHIFT', action = act.AdjustPaneSize{ 'Down', 5 } },
      { key = 'k', mods = 'ALT|SHIFT', action = act.AdjustPaneSize{ 'Up', 5 } },
      { key = 'l', mods = 'ALT|SHIFT', action = act.AdjustPaneSize{ 'Right', 5 } },
    },
  '';
in
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local act = wezterm.action

      return {
        ${general}
        ${tabBar}
        ${keys}
      }
    '';
  };
}
