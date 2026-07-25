{ pkgs, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "" = {
        font = "JetBrainsMono Nerd Font 11";
        background-color = "#1e1e2e";
        text-color = "#cdd6f4";
        border-color = "#89b4fa";
        border-size = 2;
        border-radius = 10;
        padding = "15";
        default-timeout = 5000;
        max-visible = 3;
        layer = "overlay";
      };
      "urgency=low" = {
        border-color = "#a6adc8";
      };
      "urgency=high" = {
        border-color = "#f38ba8";
        default-timeout = 0;
      };
    };
  };
}
