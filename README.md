# dotfiles

NixOS Flakes を使用したシステム設定・Home Manager 設定の一元管理リポジトリ。

---

## 新規マシンへのインストール（Minimal ISO）

> **前提**: [NixOS Minimal ISO](https://nixos.org/download/) を書き込んだ USB から起動していること。
> Graphical Installer は不要。

### 事前準備（初回のみ・リポジトリ側の作業）

新しいマシンにインストールする前に、**ディスク名を `os/disk-config.nix` に合わせること**。

```bash
# 新マシンの ISO 上で lsblk を実行してディスク名を確認
lsblk
```

`os/disk-config.nix` の `device` を実機のディスク名に書き換えて push する。

```nix
disko.devices.disk.main = {
  device = "/dev/nvme0n1";  # ← ここを lsblk で確認した名前に変更
  ...
};
```

> `/dev/disk/by-id/...` の形式を使うと名前が安定してより安全。

---

### インストール手順

#### 1. ISO 起動後に root でログイン

Minimal ISO は自動的に root シェルに入る。入っていない場合:

```bash
sudo -i
```

#### 2. ネットワーク接続

**有線**: 自動で接続される（DHCP）。

**Wi-Fi**:

```bash
nmtui
```

接続を確認:

```bash
ping -c 2 nixos.org
```

#### 3. 一発インストール

```bash
nix --extra-experimental-features "nix-command flakes" \
  run github:ChomoLungma8848/dotfiles#install
```

内部では以下を順に実行する:

1. **disko** — GPT パーティション作成・フォーマット・マウント（既存データは消去される）
2. **nixos-install** — システム + Home Manager を一括ビルド・インストール

#### 4. 再起動

```bash
reboot
```

#### 5. 初回ログイン後にパスワードを変更

ユーザー: `chomo` / パスワード: `admin`（初期値）

```bash
passwd
```

---

### インストール後の確認

Home Manager 由来の設定（zsh / starship / nixvim / hyprland 等）がすぐに使える状態になっている。

---

## 既存マシンの設定更新

### システム設定の再ビルド

```bash
# GUI 環境（/etc/nixos/hardware-configuration.nix を参照するため --impure が必要）
sudo nixos-rebuild switch --flake .#nixos --impure

# WSL 環境
nixos-rebuild switch --flake .#wsl --use-remote-sudo
```

### Home Manager 設定の再ビルド

```bash
# GUI 環境
home-manager switch --flake .#home

# WSL 環境
home-manager switch --flake .#wsl
```

### Flake 入力の更新

```bash
nix flake update
```

---

## Flake プロファイル一覧

| プロファイル | 用途 | 備考 |
|---|---|---|
| `#install` | **新規マシンへのインストール** | pure 評価・`--impure` 不要 |
| `#nixos` | 既存 GUI 環境のシステム再ビルド | `/etc/nixos/hardware-configuration.nix` 参照のため `--impure` 必要 |
| `#wsl` | WSL 環境のシステム再ビルド | |
| `homeConfigurations.home` | GUI 環境の Home Manager | `home-manager switch --flake .#home` |
| `homeConfigurations.wsl` | WSL 環境の Home Manager | `home-manager switch --flake .#wsl` |

---

## トラブルシューティング

### 特殊なストレージ構成で起動しない場合

Intel VMD が有効なノート PC など、`os/hardware/generic.nix` の汎用モジュールでは起動しないことがある。その場合は disko 実行後に以下でハードウェア固有のモジュールを確認し、`os/hardware/generic.nix` に追記する。

```bash
nixos-generate-config --no-filesystems --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

### `device not found` エラー

`os/disk-config.nix` の `device` が実機のディスク名と一致しているか確認する（`lsblk`）。
