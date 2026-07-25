#!/bin/sh
# Stop hook: 未コミットの .md を整形する。
# プロジェクトの flake formatter (nix fmt) が Markdown を扱えるなら、汎用フォーマッタ
# ではなくそちらに委譲する。扱えない/flake が無い場合のみ prettier にフォールバック。
# fail-open 設計: prettier 不在・git 管理外・対象なしのときは黙って exit 0。
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
files=$(git ls-files -mo --exclude-standard -- '*.md')
[ -n "$files" ] || exit 0

# flake formatter が .md をカバーするか、ファイルを変更しない stdin プローブで判定する。
# --on-unmatched=fatal により、.md にマッチするフォーマッタが無ければ非 0 で抜ける。
# カバーするなら nix fmt に委譲して終了 (prettier は動かさない)。
if [ -e flake.nix ] && command -v nix >/dev/null 2>&1 &&
  printf '\n' | nix fmt -- --stdin _probe.md --on-unmatched=fatal -q >/dev/null 2>&1; then
  printf '%s\n' "$files" | xargs -d '\n' nix fmt -- >/dev/null 2>&1
  exit 0
fi

# フォールバック: prettier
command -v prettier >/dev/null 2>&1 || exit 0
# 前処理: テーブル行のコードスパン内の未エスケープ | を \| に変換
# (GFM では | がコードスパン内でもセル区切りになるため)
if command -v python3 >/dev/null 2>&1; then
  printf '%s\n' "$files" | xargs -d '\n' python3 "$HOME/.claude/hooks/md_table_pipe_escape.py"
fi
printf '%s\n' "$files" | xargs -d '\n' prettier --write --log-level warn
exit 0
