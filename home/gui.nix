{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./gui/hyprland
    ./gui/wezterm.nix
  ];

  home.packages = with pkgs; [
    discord
    google-chrome
  ];
}
