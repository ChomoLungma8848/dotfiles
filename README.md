# dotfiles セットアップ手順

NixOS環境を新規セットアップする際の初期化手順。

## 1. Nix Flakeを有効化

```bash
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

## 2. SSH鍵を生成

```bash
ssh-keygen -t ed25519 -C "任意のコメント"
```

## 3. 公開鍵をGitHubに登録

```bash
cat ~/.ssh/id_ed25519.pub
```

表示された公開鍵をコピーし、[GitHub Settings > SSH and GPG keys](https://github.com/settings/keys) に追加する。

## 4. dotfilesのSSH clone URLをコピー

GitHubのリポジトリページを開き、**Code > SSH** のURLをコピーする。

## 5. nix shellに入る

```bash
nix shell nixpkgs#git
```

## 6. dotfilesをクローン

```bash
git clone git@github.com:<user>/<repo>.git ~/.dotfiles
```

## 7. flakeの実行

<!-- TODO: 後から追記 -->
