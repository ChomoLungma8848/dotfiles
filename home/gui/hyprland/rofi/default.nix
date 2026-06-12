{ pkgs, ... }:
let
  scripts = import ./scripts { inherit pkgs; };
in
{
  imports = [
    ./theme.nix
  ];

  home.packages = with pkgs; [
    scripts.rofi-hub
    scripts.rofi-wifi
    scripts.rofi-bluetooth
    scripts.rofi-files
    scripts.rofi-colorpicker
    scripts.rofi-nerd
    scripts.rofi-power
    fd
    papirus-icon-theme
    networkmanagerapplet
    blueman
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "wezterm";
    font = "JetBrainsMono Nerd Font 12";

    extraConfig = {
      modi = "drun,run,window,filebrowser";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = " Apps";
      display-run = " Run";
      display-window = " Windows";
      display-filebrowser = " Files";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";

      # 競合するキーバインドを無効化
      kb-remove-to-eol = "";
      kb-remove-to-sol = "";
      kb-clear-line = "";
      kb-move-front = "";
      kb-move-end = "";
      kb-move-word-back = "";
      kb-move-word-forward = "";
      kb-move-char-back = "";
      kb-move-char-forward = "";

      # Vim風キーバインド
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
      kb-mode-next = "Tab,Control+l";
      kb-mode-previous = "ISO_Left_Tab,Control+h";
      kb-accept-entry = "Return,KP_Enter";
      kb-cancel = "Escape,Control+c";
    };
  };
}
