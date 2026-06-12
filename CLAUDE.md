# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

Nix Flakesを使用したNixOSのdotfilesリポジトリ。NixOSシステム設定とHome Managerユーザー設定を分離。
ネイティブNixOS (GUI) 環境と WSL 環境の両方に対応。

## コマンド

```bash
# Home Manager設定の再ビルド（GUI環境）
home-manager switch --flake .#home

# NixOSシステム設定の再ビルド（GUI環境）
sudo nixos-rebuild switch --flake .#nixos

# Home Manager設定の再ビルド（WSL環境）
home-manager switch --flake .#wsl

# NixOSシステム設定の再ビルド（WSL環境）
nixos-rebuild switch --flake .#wsl --use-remote-sudo

# flake入力の更新
nix flake update
```

## アーキテクチャ

**ディレクトリ構造:**
```
flake.nix
os/
├── common.nix              # 共通ベース（nix設定・ロケール・タイムゾーン・zsh有効化）
├── gui.nix                 # GUI環境（common + ブート/HW/GNOME/hyprland/fonts/fcitx5）
├── wsl.nix                 # WSL環境（common + nixos-wsl設定）
└── hardware-configuration.nix
home/
├── common.nix              # ポータブル設定（CLIツール・neovim・git・zsh・starship）
├── gui.nix                 # GUI環境（common + hyprland/wezterm/vscode + GUIパッケージ）
├── wsl.nix                 # WSL環境（common + WSL固有変数）
├── programs/
│   ├── git.nix
│   ├── neovim.nix
│   ├── nvim/               # Neovim Lua設定（~/.config/nvimにデプロイ）
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   └── lua/
│   │       ├── config/
│   │       │   ├── init.lua
│   │       │   ├── lazy.lua     # Lazy.nvimブートストラップ
│   │       │   └── option.lua   # Neovimオプション設定
│   │       └── plugins/
│   ├── starship.nix
│   └── zsh.nix
└── gui/
    ├── hyprland/           # Hyprland（Waylandコンポジター）設定
    │   ├── default.nix     # Hyprland本体設定（キーバインド・レイアウト・fcitx5環境変数）
    │   ├── waybar.nix      # ステータスバー
    │   ├── rofi/           # アプリケーションランチャー
    │   │   ├── default.nix
    │   │   ├── theme.nix
    │   │   └── scripts/    # hub/wifi/bluetooth/files/colorpicker/nerd/power
    │   ├── mako.nix        # 通知デーモン
    │   ├── swww.nix        # 壁紙
    │   ├── hyprlock.nix    # ロック画面
    │   ├── hypridle.nix    # アイドル管理
    │   └── wallpaper-1.png
    ├── wezterm.nix
    └── vscode.nix
```

**Flake出力:**
- `nixosConfigurations.nixos` — ネイティブNixOS (GUI) システム設定
- `nixosConfigurations.wsl` — WSLシステム設定
- `homeConfigurations.home` — GUI環境 Home Manager設定（chomo ユーザー）
- `homeConfigurations.wsl` — WSL環境 Home Manager設定（nixos ユーザー）

## 設計方針

**OS固有設定とポータブル設定の分離:**

Home Managerの設定は他のOS（macOS等、Nix-as-PM環境）でも再利用可能にするため、以下の方針で分離する。

| 設定 | 場所 | 理由 |
|------|------|------|
| ログインシェルの指定 (`shell = pkgs.zsh`) | os/ | OS固有の設定 |
| シェルの有効化 (`programs.zsh.enable`) | os/common.nix | NixOSがログインシェルを認識するため必要 |
| シェルの中身（エイリアス、プラグイン等） | home/programs/zsh.nix | ポータブル、他OSでも同じ設定を使用可能 |
| fcitx5環境変数 | home/gui/hyprland/default.nix | Hyprland固有の設定として管理 |
| WSL固有環境変数（WAYLAND_DISPLAY等） | home/wsl.nix | WSL固有の設定として管理 |

os/配下にはOS固有の最小限の設定のみを書き、実際のプログラム設定はHome Manager側（home/配下）で管理する。

**GUI = CLI + デスクトップ環境の拡張:**

- `os/gui.nix` = `os/common.nix` + ブートローダー/HW + デスクトップ環境
- `os/wsl.nix` = `os/common.nix` + nixos-wsl設定
- `home/gui.nix` = `home/common.nix` + Hyprland/WezTerm/VSCode + GUIパッケージ
- `home/wsl.nix` = `home/common.nix` + WSL固有設定

将来 i3 等の WM を追加する場合: `home/gui/i3/` ディレクトリを作成し、
`os/gui.nix` に `services.xserver.windowManager.i3.enable` を追加するだけで gdm から選択可能になる。

**Neovim設定の設計:**
- `neovim.nix`でHome Managerのneovimモジュールを有効化（vi/vimエイリアス設定）
- 実際のLua設定は`programs/nvim/`ディレクトリに配置し、`home.file`で`~/.config/nvim`にデプロイ
- プラグイン管理はLazy.nvimを使用（Nixでプラグインを管理せず、Lazy.nvimに任せる方式）
- この方式により、プラグインの追加・更新がNixビルドなしで可能

**rofiスクリプトの設計:**
- 各スクリプトは`writeShellScriptBin`で独立したパッケージとして作成
- 依存するコマンドはPATHに明示的に追加（例: `${pkgs.libnotify}/bin`）
- `scripts/default.nix`で`builtins.listToAttrs`を使用し、スクリプト追加を容易に

## Commit Style

Conventional Commits: `type(scope): description`
例: `feat(nvim): add plugin`, `fix(zsh): correct alias`, `chore: update flake inputs`

## Language

常に日本語で回答すること。
