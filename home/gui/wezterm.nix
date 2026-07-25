{ pkgs, ... }:
let
  inherit (pkgs.lib) range;
  inherit (pkgs.lib.generators) mkLuaInline;
in
{
  programs.wezterm = {
    enable = true;

    # # noctalia のカラースキーマ反映
    # extraConfig = ''
    #   config.color_scheme = "Noctalia"
    #
    #   local noctalia_scheme = wezterm.home_dir .. "/.config/wezterm/colors/Noctalia.toml"
    #   wezterm.add_to_config_reload_watch_list(noctalia_scheme)
    #   local ok, noctalia_colors = pcall(wezterm.color.load_scheme, noctalia_scheme)
    #   if ok and noctalia_colors then
    #     config.colors = noctalia_colors
    #   end
    # '';

    extraConfig = ''
      wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
        -- Catppuccin Mocha
        local rosewater = "#f5e0dc";
        local flamingo = "#f2cdcd";
        local pink = "#f5c2e7";
        local mauve = "#cba6f7";
        local red = "#f38ba8";
        local maroon = "#eba0ac";
        local peach = "#fab387";
        local yellow = "#f9e2af";
        local green = "#a6e3a1";
        local teal = "#94e2d5";
        local sky = "#89dceb";
        local sapphire = "#74c7ec";
        local blue = "#89b4fa";
        local lavender = "#b4befe";
        local text = "#cdd6f4";
        local subtext1 = "#bac2de";
        local subtext0 = "#a6adc8";
        local overlay2 = "#9399b2";
        local overlay1 = "#7f849c";
        local overlay0 = "#6c7086";
        local surface2 = "#585b70";
        local surface1 = "#45475a";
        local surface0 = "#313244";
        local base = "#1e1e2e";
        local mantle = "#181825";
        local crust = "#1e1e2e";

        local left_circle = wezterm.nerdfonts.ple_left_half_circle_thick
        local right_circle = wezterm.nerdfonts.ple_right_half_circle_thick

        local bg = tab.is_active and mauve or overlay0
        local fg = tab.is_active and base or text

        local title = wezterm.truncate_right(tab.active_pane.title, max_width - 5)

        return {
          { Background = { Color = "none" } },
          { Foreground = { Color = "none" } },
          { Text = " " },
          { Foreground = { Color = bg } },
          { Text = left_circle },
          { Background = { Color = bg } },
          { Foreground = { Color = fg } },
          { Attribute = { Intensity = "Bold" } },
          { Text = " " .. title .. " " },
          { Background = { Color = "none" } },
          { Foreground = { Color = bg } },
          { Text = right_circle },
        }
      end)
    '';

    settings = {
      color_scheme = "Catppuccin Mocha";
      font = mkLuaInline ''wezterm.font("JetBrainsMono Nerd Font")'';
      font_size = 12;
      use_ime = true;

      window_background_opacity = 0.65;
      window_background_gradient = {
        colors = [ "#11111b" ];
      };

      tab_max_width = 30;
      hide_tab_bar_if_only_one_tab = true;
      show_new_tab_button_in_tab_bar = false;
      show_close_tab_button_in_tabs = false;
      show_tab_index_in_tab_bar = false;
      use_fancy_tab_bar = false;
      colors = {
        tab_bar = {
          background = "none";
          inactive_tab_edge = "none";
        };
      };

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
        # タブ作成
        {
          key = "t";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.SpawnTab 'CurrentPaneDomain'";
        }
        # タブを閉じる
        {
          key = "x";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.CloseCurrentTab { confirm = true }";
        }
        # タブ移動
        {
          key = "Tab";
          mods = "ALT";
          action = mkLuaInline "wezterm.action.ActivateTabRelative(1)";
        }
        {
          key = "Tab";
          mods = "ALT|SHIFT";
          action = mkLuaInline "wezterm.action.ActivateTabRelative(-1)";
        }
      ]
      # タブ番号指定（ALT+1..9 → 1..9 番目のタブ）
      ++ map (n: {
        key = toString n;
        mods = "ALT";
        action = mkLuaInline "wezterm.action.ActivateTab(${toString (n - 1)})";
      }) (range 1 9);
    };
  };
}
