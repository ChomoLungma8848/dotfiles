{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./gui/hyprland
    ./gui/wezterm.nix
    ./gui/vscode.nix
  ];

  home = rec {
    username = "chomo";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      # GUI application
      # wezterm # programs.wezterm.enable = true で管理
      # vscode  # programs.vscode.enable = true で管理
      antigravity
      discord
      awww
      godot
      google-chrome
    ];
  };
}
