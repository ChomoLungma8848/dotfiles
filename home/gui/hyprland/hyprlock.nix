{ pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          placeholder_text = "Password...";
          fade_on_empty = false;
          font_color = "rgb(205, 214, 244)";
          inner_color = "rgb(30, 30, 46)";
          outer_color = "rgb(137, 180, 250)";
          outline_thickness = 2;
          rounding = 10;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 80";
          halign = "center";
          valign = "center";
          color = "rgb(205, 214, 244)";
        }
      ];
    };
  };
}
