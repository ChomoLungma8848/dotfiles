{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    ./common.nix
    ./gui/hyprland
    # ./gui/niri
    ./gui/wezterm.nix
    ./gui/vesktop.nix
  ];

  home = {
    packages = with pkgs; [
      google-chrome
      inputs.zen-browser.packages.${system}.default
      libreoffice
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    file = {
      "Wallpaper".source = ../Wallpaper;
    };
  };
}
