{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./gui/hyprland
    ./gui/wezterm.nix
  ];

  home = rec {
    username = "chomo";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      discord
      awww
      godot
      google-chrome
    ];
  };
}
