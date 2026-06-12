{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprlauncher
  ];

  # hyprlauncher設定
  xdg.configFile."hyprlauncher/config.toml".text = ''
    [general]
    terminal = "wezterm"

    [style]
    width = 600
    height = 400
    border_radius = 10
    font_family = "JetBrainsMono Nerd Font"
    font_size = 14

    [colors]
    background = "#1e1e2e"
    text = "#cdd6f4"
    border = "#89b4fa"
    selection = "#585b70"
  '';
}
