#!/usr/bin/env bash
# create-knowledge スキルの補助スクリプト。
# frontmatterとtype別の見出し骨格を持つMarkdownファイルを生成し、
# 絶対パスをstdoutに出力する。本文の中身は呼び出し側(Claude)がEditで埋める。
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scaffold.sh --type troubleshoot|decision|research --scope user|project \
                    --slug <kebab-case-slug> --title "<title>" \
                    [--subdir <name>] [--tags "tag1,tag2"] [--root <project-root>] \
                    [--related "@path1,@path2"] [--environment "<text>"] \
                    [--confidence high|medium|low] [--status draft|validated|deprecated|archived] \
                    [--author "<name>"] [--force]

Creates a new knowledge markdown file with the correct frontmatter and
heading skeleton for the given type, under <project-root>/.claude/knowledge/
(scope=project) or ~/.claude/knowledge/ (scope=user). Prints the absolute
path of the created file on stdout.
EOF
}

type=""
scope=""
slug=""
title=""
subdir=""
tags=""
root=""
related=""
environment=""
confidence="medium"
status="draft"
author=""
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) type="$2"; shift 2 ;;
    --scope) scope="$2"; shift 2 ;;
    --slug) slug="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --subdir) subdir="$2"; shift 2 ;;
    --tags) tags="$2"; shift 2 ;;
    --root) root="$2"; shift 2 ;;
    --related) related="$2"; shift 2 ;;
    --environment) environment="$2"; shift 2 ;;
    --confidence) confidence="$2"; shift 2 ;;
    --status) status="$2"; shift 2 ;;
    --author) author="$2"; shift 2 ;;
    --force) force=1; shift 1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

case "$type" in
  troubleshoot|decision|research) ;;
  *) echo "error: --type must be troubleshoot|decision|research (got: '$type')" >&2; exit 1 ;;
esac
case "$scope" in
  user|project) ;;
  *) echo "error: --scope must be user|project (got: '$scope')" >&2; exit 1 ;;
esac
case "$confidence" in
  high|medium|low) ;;
  *) echo "error: --confidence must be high|medium|low (got: '$confidence')" >&2; exit 1 ;;
esac
case "$status" in
  draft|validated|deprecated|archived) ;;
  *) echo "error: --status must be draft|validated|deprecated|archived (got: '$status')" >&2; exit 1 ;;
esac
[[ -n "$slug" ]] || { echo "error: --slug is required" >&2; exit 1; }
[[ -n "$title" ]] || { echo "error: --title is required" >&2; exit 1; }
if ! [[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: --slug must be ascii kebab-case, e.g. 'gdm-hyprland-uwsm-session' (got: '$slug')" >&2
  exit 1
fi

today="$(date +%Y-%m-%d)"
author="${author:-$(git config user.name 2>/dev/null || echo "${USER:-unknown}")}"

if [[ "$scope" == "user" ]]; then
  # KNOWLEDGE_USER_HOME は eval/テスト時に実ホームを汚さず差し替えるためのフック。
  # 通常運用では未設定のため $HOME と完全に同じ挙動になる。
  knowledge_root="${KNOWLEDGE_USER_HOME:-$HOME}/.claude/knowledge"
else
  search_dir="${root:-$PWD}"
  search_dir="$(cd "$search_dir" && pwd)"
  project_root=""
  dir="$search_dir"
  while true; do
    if [[ -e "$dir/.git" || -d "$dir/.claude" ]]; then
      project_root="$dir"
      break
    fi
    [[ "$dir" == "/" ]] && break
    dir="$(dirname "$dir")"
  done
  if [[ -z "$project_root" ]]; then
    echo "error: .git も .claude も見つからず project root を特定できません。--root で明示してください" >&2
    exit 1
  fi
  knowledge_root="$project_root/.claude/knowledge"
fi

[[ -n "$subdir" ]] && knowledge_root="$knowledge_root/$subdir"
mkdir -p "$knowledge_root"

filename="${today}-${slug}.md"
filepath="$knowledge_root/$filename"

if [[ -e "$filepath" && "$force" -ne 1 ]]; then
  echo "error: $filepath は既に存在します(上書きするなら --force)" >&2
  exit 1
fi

yaml_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

yaml_list() {
  local csv="$1"
  if [[ -z "$csv" ]]; then
    printf '[]'
    return
  fi
  local IFS=','
  local items=()
  for raw in $csv; do
    raw="$(printf '%s' "$raw" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -n "$raw" ]] && items+=("\"$(yaml_escape "$raw")\"")
  done
  local out
  out="$(IFS=', '; printf '%s' "${items[*]}")"
  printf '[%s]' "$out"
}

case "$type" in
  troubleshoot)
    body=$(cat <<'BODY'
## 問題 (Problem / Symptom)

<!-- エラーメッセージは原文ママ貼り付ける。再現条件(バージョン・コマンド・環境)も書く -->

## 原因 (Root Cause)

<!-- 5 Whysで深掘りする。「確証」か「仮説」かを明記する -->

## 解決策 (Resolution)

<!-- コピペで再現できるコマンド・設定をそのまま書く -->

## 試したが効かなかったこと (Dead ends)

<!-- 何を試して、なぜダメだったか。次に同じ罠を踏まないために残す -->

## 根拠・参照 (Evidence)

<!-- 検証コマンドの実行結果、ソースコードの該当箇所、参照したドキュメントのURLなど -->
BODY
)
    ;;
  decision)
    body=$(cat <<'BODY'
## 背景・課題 (Context)

<!-- なぜこの決定が必要になったか。制約条件は何か -->

## 決定 (Decision)

<!-- 何を選んだか。具体的なコード/設定を含める -->

## 検討して捨てた選択肢 (Alternatives considered)

<!-- 各選択肢について、なぜ採用しなかったか(why not)を明記する -->

## 影響・トレードオフ (Consequences)

<!-- この決定によって得たもの・失ったもの -->

## 根拠・参照 (Evidence)

<!-- 検証結果、参照したコード/ドキュメント -->
BODY
)
    ;;
  research)
    body=$(cat <<'BODY'
## 問い (Question)

<!-- 何を調べたかったか -->

## 結論 (Findings)

<!-- 先に結論を書く。後から読む人が結論だけ読んで判断できるように -->

## 詳細・根拠 (Details)

<!-- 結論に至った調査過程、検証コマンドと結果 -->

## 未解決・次の問い (Open questions)

<!-- まだ分かっていないこと、今後調べるべきこと -->

## 参照 (References)

<!-- 参照したドキュメント、ソースコード、関連ナレッジへの@メンション -->
BODY
)
    ;;
esac

{
  echo "---"
  echo "title: \"$(yaml_escape "$title")\""
  echo "id: \"$slug\""
  echo "type: $type"
  echo "scope: $scope"
  echo "created: $today"
  echo "updated: $today"
  echo "last_verified: $today"
  echo "status: $status"
  echo "author: \"$(yaml_escape "$author")\""
  echo "tags: $(yaml_list "$tags")"
  echo "environment: \"$(yaml_escape "$environment")\""
  echo "confidence: $confidence"
  echo "related: $(yaml_list "$related")"
  echo "---"
  echo ""
  echo "# $title"
  echo ""
  echo "$body"
} > "$filepath"

echo "$filepath"
