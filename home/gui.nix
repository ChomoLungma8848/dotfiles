{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./gui/hyprland
    ./gui/wezterm.nix
    ./gui/vesktop.nix
  ];

  home = {
    packages = with pkgs; [
      google-chrome
      qutebrowser
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    file = {
      "Wallpaper".source = ../Wallpaper;
    };
  };
}
