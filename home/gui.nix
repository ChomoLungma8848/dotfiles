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

  # vesktop が EOL の electron 40 に依存しているため一時的に許可。
  # nixpkgs 側で vesktop が新しい electron に移行したら削除する。
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
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
