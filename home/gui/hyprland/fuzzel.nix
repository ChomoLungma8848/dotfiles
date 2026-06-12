{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "wezterm";
        layer = "overlay";
        width = 40;
        font = "JetBrainsMono Nerd Font:size=12";
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "89b4faff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "89b4faff";
        border = "89b4faff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
