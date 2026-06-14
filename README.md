# dotfiles

NixOS Flakes を使用したシステム設定・Home Manager 設定の一元管理リポジトリ。

---

## 新規マシンへのインストール（Minimal ISO）

> **前提**: [NixOS Minimal ISO](https://nixos.org/download/) を書き込んだ USB から起動していること。

### 1. root でログイン

Minimal ISO は自動的に root シェルに入る。入っていない場合:

```bash
sudo -i
```

### 2. ネットワーク接続

**有線**: 自動で接続される（DHCP）。

**Wi-Fi**:

```bash
nmtui
```

接続を確認:

```bash
ping -c 2 nixos.org
```

### 3. ディスク名の確認

```bash
lsblk
```

インストール先が `/dev/nvme0n1` であることを確認する。異なる場合は[トラブルシューティング](#ディスク名が-devnvme0n1-でない場合)を参照。

### 4. インストール

```bash
nix --extra-experimental-features "nix-command flakes" \
  run github:ChomoLungma8848/dotfiles#install
```

ディスクのパーティション・フォーマット・マウントおよびシステムのビルド・インストールが順に行われる。

### 5. 再起動

```bash
reboot
```

### 6. 初回ログイン後にパスワードを変更

ユーザー: `chomo` / 初期パスワード: `admin`

```bash
passwd
```

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
| `#install` | 新規マシンへのインストール | pure 評価・`--impure` 不要 |
| `#nixos` | 既存 GUI 環境のシステム再ビルド | `--impure` 必要 |
| `#wsl` | WSL 環境のシステム再ビルド | |
| `homeConfigurations.home` | GUI 環境の Home Manager | `home-manager switch --flake .#home` |
| `homeConfigurations.wsl` | WSL 環境の Home Manager | `home-manager switch --flake .#wsl` |

---

## トラブルシューティング

### ディスク名が `/dev/nvme0n1` でない場合

`os/disk-config.nix` のデフォルト設定は `/dev/nvme0n1` を想定している。異なる場合は以下の手順でリポジトリを修正してからインストールを実行する。

**1. ネットワーク経由でリポジトリをクローン**

```bash
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git -c \
  git clone https://github.com/ChomoLungma8848/dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles
```

**2. `os/disk-config.nix` の `device` を書き換える**

```bash
# lsblk でディスク名を確認してから編集
nano os/disk-config.nix
```

```nix
disko.devices.disk.main = {
  device = "/dev/sda";  # ← 実機のデバイス名に変更
  ...
};
```

> `/dev/disk/by-id/...` の形式を使うと名前が安定してより安全。

**3. 変更を push**

```bash
git config user.email "chomolungma8848s@gmail.com"
git config user.name "ChomoLungma8848"
git add os/disk-config.nix
git commit -m "fix(disk): update device for this machine"
git push
```

**4. インストールを実行**

```bash
nix --extra-experimental-features "nix-command flakes" \
  run github:ChomoLungma8848/dotfiles#install
```

---

### 特殊なストレージ構成で起動しない場合

Intel VMD が有効なノート PC など、`os/hardware/generic.nix` の汎用モジュールでは起動しないことがある。その場合は disko 実行後に以下でハードウェア固有のモジュールを確認し、`os/hardware/generic.nix` に追記する。

```bash
nixos-generate-config --no-filesystems --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```
