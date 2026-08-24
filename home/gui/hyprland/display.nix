# ディスプレイモード切り替え(Win+P 相当)と左右反転のスクリプト。
# 中身は display.sh（Nix の生文字列に埋めるとエディタの支援が効かないため分離）。
{ writeShellApplication, jq }:
writeShellApplication {
  name = "hypr-display";
  runtimeInputs = [ jq ];
  text = builtins.readFile ./display.sh;
}
