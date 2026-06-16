{ pkgs, lib, ... }:
{
  imports = [
    ./common.nix
  ];

  # ブートローダー
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ネットワーク
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # X11 / GNOME
  # services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # 印刷
  # services.printing.enable = true;

  # オーディオ (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ユーザー
  users.users.chomo = {
    isNormalUser = true;
    description = "chomo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # プログラム (GUI固有)
  programs.hyprland.enable = true;

  # remove "hyprland(uwsm-managed)" from gdm session list.
  services.displayManager.sessionPackages = lib.mkForce [
    (pkgs.runCommand "hyprland-session-only" { passthru.providedSessions = [ "hyprland" ]; } ''
      mkdir -p $out/share/wayland-sessions
      ln -s ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop $out/share/wayland-sessions/
    '')
  ];

  # 日本語入力 (fcitx5-mozc)
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  # fcitx5の環境変数はHome Manager (home/gui/hyprland/default.nix) で管理

  # フォント
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.noto
      nerd-fonts.jetbrains-mono
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans CJK JP"
          "Noto Color Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
