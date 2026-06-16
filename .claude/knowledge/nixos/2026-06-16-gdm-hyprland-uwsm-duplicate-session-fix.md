---
title: "GDMのセッション選択肢にHyprlandが2つ表示される問題への対処"
id: "gdm-hyprland-uwsm-duplicate-session-fix"
type: decision
scope: project
created: 2026-06-16
updated: 2026-06-16
last_verified: 2026-06-16
status: validated
author: "ChomoLungma8848"
tags: ["nixos","hyprland","gdm","display-manager","wayland-sessions","uwsm"]
environment: "NixOS unstable, hyprland 0.55.4 (nixpkgs programs.hyprland module)"
confidence: high
related: ["@/home/chomo/.claude/knowledge/nix/2026-06-16-nix-overrideattrs-survives-override-finalattrs.md"]
---

# GDMのセッション選択肢にHyprlandが2つ表示される問題への対処

## 背景・課題 (Context)

NixOSでGDMのセッション選択画面を開くと、「Hyprland」と「Hyprland (uwsm-managed)」の2つが表示される。`os/gui.nix`で`programs.hyprland.withUWSM = false;`にしても、この2エントリは消えなかった。

調査して分かったこと(nixpkgsの実ソースを確認):

- `nixos/modules/programs/wayland/hyprland.nix`の`withUWSM`オプションは、`programs.uwsm.enable = true;`を立てるだけ。GDMに渡すセッション一覧は`services.displayManager.sessionPackages = [ cfg.package ];`であり、これは`withUWSM`の値に関わらず常に同じ`hyprland`パッケージそのものを指す。
- `pkgs/by-name/hy/hyprland/package.nix`では`passthru.providedSessions = [ "hyprland" ] ++ optionals withSystemd [ "hyprland-uwsm" ];`となっている。`withSystemd`はデフォルト`true`なので、Hyprland本体のビルドが`hyprland.desktop`と`hyprland-uwsm.desktop`の両方を`$out/share/wayland-sessions/`に同梱する。
- `nixos/modules/services/display-managers/default.nix`の`desktops`派生(GDMが実際にスキャンする一覧)は、`services.displayManager.sessionPackages`に渡された各パッケージの`share/wayland-sessions`ディレクトリを`lndir`で**丸ごと**リンクする。`providedSessions`は「リストに書いた名前のファイルが実在するか」の検証にしか使われず、フィルタには使われない。

つまり「1つのhyprlandパッケージが2つの`.desktop`を同梱していて、NixOS側はディレクトリ単位でしか取り込まない」ことが原因で、`withUWSM`を切っても無関係に両方残っていた。

確認に使った診断コマンド(現在のシステムでの実例):
```bash
cat /etc/systemd/system/display-manager.service | grep XDG_DATA_DIRS
# → .../desktops/share が含まれる(GDMが参照するセッション一覧の実体)
ll /nix/store/<hash>-desktops/share/wayland-sessions
# → hyprland.desktop と hyprland-uwsm.desktop が同一の hyprland-0.55.4 パッケージを指すシンボリックリンクだった
nix why-depends /run/current-system /nix/store/<hash>-desktops
# → nixos-system → /etc → etc-pam-environment → desktops という依存チェーンを確認
nix-store --query --roots /nix/store/<hash>-desktops
# → /run/current-system 等から参照されている=現役のパスであることを確認(GCルートの調べ方)
```

## 決定 (Decision)

`programs.hyprland.package`(Hyprland本体)はそのままにし、`services.displayManager.sessionPackages`を`lib.mkForce`で完全に上書きして、`hyprland.desktop`へのシンボリックリンクのみを持つ小さな`runCommand`派生に置き換える。

```nix
{ pkgs, lib, ... }:
{
  programs.hyprland.enable = true;

  # hyprland パッケージは hyprland-uwsm.desktop を常に同梱しており、
  # NixOS は services.displayManager.sessionPackages の
  # share/wayland-sessions をディレクトリ単位でリンクするため、
  # GDM のセッション一覧だけを上書きして取り除く
  # (Hyprland 本体は標準パッケージのまま、再ビルドは発生しない)
  services.displayManager.sessionPackages = lib.mkForce [
    (pkgs.runCommand "hyprland-session-only" { passthru.providedSessions = [ "hyprland" ]; } ''
      mkdir -p $out/share/wayland-sessions
      ln -s ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop $out/share/wayland-sessions/
    '')
  ];
}
```

`passthru.providedSessions = [ "hyprland" ];`を持たせるのは、`services.displayManager.sessionPackages`の型チェック(`p.providedSessions != []`であることを要求)を満たすため。`lib.mkForce`は、hyprlandモジュール自身が同じオプションに追加する`[ cfg.package ]`という寄与を、優先度の力で完全に上書きするために必要(NixOSのlist型オプションは通常モジュール間で連結されるため、`mkForce`なしでは両方の寄与が残ってしまう)。

検証: `nix eval '.#nixosConfigurations.nixos.config.services.displayManager.sessionData.sessionNames'`が`[ "hyprland" ]`のみになることを確認済み。

## 検討して捨てた選択肢 (Alternatives considered)

- **A: `programs.hyprland.package`を`overrideAttrs`で書き換え、`postInstall`で`hyprland-uwsm.desktop`を`rm -f`し、`passthru.providedSessions`も`["hyprland"]`に上書きする。**
  動作することは実機ビルドで確認済み(`.override`が後段で呼ばれても変更は失われないことも検証済み。詳細は @/home/chomo/.claude/knowledge/nix/2026-06-16-nix-overrideattrs-survives-override-finalattrs.md を参照)。
  不採用の理由: このカスタムpackageは独自derivationになるためバイナリキャッシュが効かず、Hyprland本体をローカルでフルビルドする必要がある。GDMの一覧から1エントリを消すためだけにC++プロジェクト全体をローカルコンパイルするのはコストに対して得るものが小さい。
- **C: `programs.hyprland.package = pkgs.hyprland.override { withSystemd = false; };`**
  CMakeフラグ`NO_UWSM=true`になり、そもそも`hyprland-uwsm.desktop`がビルドされなくなる。`.override`だけで済むのでコードはシンプル。
  不採用の理由: `withSystemd`はUWSM対応専用のフラグではなく、systemd連携全般(sd-notifyでの起動完了通知、journal連携など)もまとめて無効化してしまう。GDMの表示を1つ消すためだけに、Hyprland自体のsystemd統合機能を犠牲にするのは副作用が大きすぎる。
- **D: 何もせず`services.displayManager.defaultSession = "hyprland";`だけ設定する。**
  ビルド不要で即反映。GDM/AccountsServiceはユーザーごとに最後に選んだセッションを覚えるので、一度「Hyprland」を選べば実質的に2度と目にしなくなる。
  不採用の理由: 選択肢自体(歯車アイコンから見える一覧)は消えないため、「選択肢から消したい」という元の要望をコスメティックにしか満たさない。

## 影響・トレードオフ (Consequences)

- Hyprland本体(`programs.hyprland.package`)は無改変のまま標準のキャッシュ済みビルドを使えるため、`sudo nixos-rebuild switch --flake .#nixos`でHyprlandの再コンパイルが発生しない。
- `services.displayManager.sessionPackages`を`mkForce`で完全に上書きしているため、**将来別のwayland-session提供モジュール(sway, niriなど)を追加した場合、その寄与もこの`mkForce`によって上書きされて消えてしまう**。その時点でこの設定を見直し、`mkForce`のリストに新しいセッションのパッケージも明示的に加える必要がある。
- `runCommand`で作る派生は`pkgs.hyprland`への参照(`${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop`へのsymlink)を持つため、`pkgs.hyprland`がバージョンアップされてもパスは自動的に追従する。

## 根拠・参照 (Evidence)

- 検証コマンドと実行結果は上記Context/Decision内に記載。
- nixpkgsソース該当箇所(2026-06-16時点でこのflakeが固定しているnixpkgs-unstableのrev):
  - `nixos/modules/programs/wayland/hyprland.nix`(`withUWSM`の実装、`services.displayManager.sessionPackages = [ cfg.package ];`)
  - `pkgs/by-name/hy/hyprland/package.nix`(`passthru.providedSessions`の条件分岐、`withSystemd`デフォルト)
  - `nixos/modules/services/display-managers/default.nix`(`desktops`派生の`lndir`によるディレクトリ単位リンク)
- `.override`と`.overrideAttrs`の合成挙動の検証結果: @/home/chomo/.claude/knowledge/nix/2026-06-16-nix-overrideattrs-survives-override-finalattrs.md
- 適用したコードは `os/gui.nix` を参照。
