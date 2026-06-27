# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

Nix Flakes による NixOS / Home Manager の dotfiles。システム設定（os/）とユーザー設定（home/）を分離し、ネイティブ NixOS (GUI/Hyprland) と WSL に対応。Home Manager 設定は他OS（Nix-as-PM）でも再利用できるようポータブルに保つ。

## コマンド

```bash
# 既存マシンの再ビルド
sudo nixos-rebuild switch --flake .#nixos             # システム（GUI）
home-manager switch --flake .#home                    # ユーザー環境（GUI）
nixos-rebuild switch --flake .#wsl --use-remote-sudo  # システム（WSL）
home-manager switch --flake .#wsl                     # ユーザー環境（WSL）

# flake 入力の更新
nix flake update

# 新規マシン（Minimal ISO から / 詳細は README.md）
nix run github:ChomoLungma8848/dotfiles#install       # システムのみ。home は後段で別途適用
```

## 構成

```
flake.nix                  # 出力定義（下記）
os/                        # NixOS システム設定
├── common.nix             #   共通ベース（nix/locale/timezone/zsh 有効化）
├── gui.nix                #   GUI（hyprland/gdm/fonts/fcitx5 + chomo ユーザー）
├── wsl.nix                #   WSL（nixos-wsl）
├── disk-config.nix        #   disko によるディスク宣言
└── hardware/generic.nix   #   汎用HW（hardware-configuration.nix の代替）
home/                      # Home Manager 設定
├── common.nix             #   ポータブル（CLI・nixvim・git・zsh・starship・emacs・allowUnfree）
├── gui.nix                #   GUI（hyprland/wezterm + GUIパッケージ）
├── wsl.nix                #   WSL 固有変数
├── programs/              #   nixvim/ git/ zsh/ starship/ emacs/
└── gui/                   #   hyprland/（noctalia 等）・wezterm・vesktop
```

**Flake 出力:**
- `nixosConfigurations.nixos` — ネイティブ NixOS。新規 install と日常 rebuild を兼ねる（disko + generic.nix で pure 評価）
- `nixosConfigurations.wsl` — WSL システム
- `homeConfigurations.home` / `.wsl` — 各環境の Home Manager 設定（共に chomo ユーザー）
- `apps.install` — Minimal ISO からの一発インストーラ（disko + nixos-install `#nixos`）

## 設計方針

**OS固有 / ポータブルの分離:** os/ には OS 固有の最小限のみ（ログインシェル指定・シェル有効化など）。プログラムの中身は home/ に置き他OSでも再利用可能にする。例: zsh の有効化は `os/common.nix`、中身は `home/programs/zsh.nix`。

**システムとユーザーの非結合:** 新規マシンは `#nixos` でシステムのみ入れ、ユーザー環境は後から `home-manager switch --flake .#home`。`homeConfigurations.home` を唯一の定義とし二重管理を避ける。allowUnfree は `home/common.nix` に集約（standalone HM が nixpkgs を再 import するため、ここで効く）。

**GUI = CLI + デスクトップ拡張:** `os/gui.nix` = `os/common.nix` + ブート/HW + デスクトップ、`home/gui.nix` = `home/common.nix` + Hyprland/WezTerm + GUIパッケージ。

**Neovim:** nixvim で宣言的に管理（`home/programs/nixvim/`）。

## Commit Style

Conventional Commits: `type(scope): description`（例: `feat(nixvim): add plugin`, `fix(zsh): correct alias`）

## Language

常に日本語で回答すること。
