---
name: commit
description: ステージングされた変更からConventional Commits形式のコミットメッセージを生成し、コミット・プッシュを行う。/commit で起動。git commitしたい、変更をコミットしたい、pushしたい、といった場面で使用。
---

## 概要

ステージングされた変更を読み取り、Conventional Commits形式のメッセージを自動生成してコミット・プッシュするスキル。

## 手順

### 1. 変更状態の確認

以下を並列で実行して状態を把握する：
- `git diff --staged --stat` — ステージング済みファイルの一覧
- `git diff --staged` — ステージング済みの差分（メッセージ生成に使用）
- `git diff --stat` — ステージングされていないファイルの一覧
- `git status --short` — 全体の状態

**ステージングが空の場合**: 「コミットする変更がありません」と伝えて終了する。

### 2. ステージングされていない変更の処理

`git diff --stat` の結果が空でない場合、**AskUserQuestion ツール**を使って以下を尋ねる：

```
question: "ステージングされていない変更があります。どうしますか？"
header: "ステージング"
options:
  - label: "全部ステージングしてコミット"
    description: "git add -A を実行してからコミットする"
  - label: "ステージング済みのみコミット"
    description: "現在ステージングされている変更のみコミットする"
  - label: "キャンセル"
    description: "処理を中断する"
```

選択に応じて処理を続行または中断する。「全部ステージングしてコミット」の場合は、**Agent ツール**（`model: "haiku"`、`mode: "bypassPermissions"`）を使って以下を実行する：

```
Bashツールで git add -A を実行してください。
作業ディレクトリ: <カレントディレクトリのパス>
```

### 3. コミットメッセージの生成（日本語）

差分を分析して、**日本語**でConventional Commits形式のメッセージを生成する。

**形式**: `type(scope): 説明`

typeの選び方：
- `feat` — 新機能の追加
- `fix` — バグ修正
- `chore` — ビルド・依存関係・設定の変更
- `refactor` — 動作変更を伴わないコードの整理
- `docs` — ドキュメントのみの変更
- `style` — フォーマットのみの変更
- `test` — テストの追加・修正

scopeの選び方（このリポジトリの慣例）：
- `nvim`, `zsh`, `git`, `starship` などプログラム名
- `home`, `os` など設定の対象
- 複数にまたがる場合はscopeを省略可

変更が複雑または広範囲の場合は、bodyに箇条書きで詳細を追加する：
```
feat(nvim): LSPの設定を追加

- lspconfig でrust-analyzerを設定
- on_attach にキーマップを追加
```

### 4. ユーザーへの確認（日本語）

生成した**日本語**のコミットメッセージを確認するため、**AskUserQuestion ツール**を使って以下を尋ねる：

```
question: "生成したコミットメッセージ：\n\n`feat(nvim): LSPの設定を追加`\n\nこのメッセージでよいですか？"
header: "メッセージ確認"
options:
  - label: "承認"
    description: "このメッセージでコミットする"
  - label: "編集"
    description: "メッセージを修正する（Otherで日本語入力）"
  - label: "キャンセル"
    description: "処理を中断する"
```

- **承認** の場合: そのまま続行
- **編集** の場合: ユーザーが入力した日本語メッセージを使用して続行
- **キャンセル** の場合: 中断する

### 5. 英語メッセージへの翻訳

ユーザーが承認（または日本語で編集）したメッセージを、**英語**のConventional Commits形式に翻訳する。

翻訳ルール：
- `type(scope):` の部分はそのまま保持
- 説明文を自然な英語に翻訳（直訳ではなく、英語圏での慣用的な表現を使う）
- bodyがある場合も英語に翻訳する

例：
- 日本語: `feat(nvim): LSPの設定を追加` → 英語: `feat(nvim): add LSP configuration`
- 日本語: `fix(zsh): エイリアスが正しく動作しない問題を修正` → 英語: `fix(zsh): correct alias not working properly`

### 6. プッシュ確認

**AskUserQuestion ツール**を使って確認する：

```
question: "リモートにプッシュしますか？"
header: "プッシュ確認"
options:
  - label: "プッシュする"
    description: "git push でリモートに送信する（デフォルト）"
  - label: "プッシュしない"
    description: "コミットのみで終了する"
```

### 7. コミット（＋プッシュ）の実行

ユーザーがステップ4・6で承認済みのため、**Agent ツール**（`model: "haiku"`、`mode: "bypassPermissions"`）を使ってgitコマンドを実行する。コミットとプッシュを1回のAgent呼び出しにまとめることで、Bashツールの許可プロンプトは発生しない。

Agentへの指示例（プッシュする場合）：

```
Bashツールのみを使って以下を順番に実行してください。
作業ディレクトリ: <カレントディレクトリのパス>

1. git commit -m "<英語コミットメッセージ>"
   bodyがある場合はHEREDOC形式:
   git commit -m "$(cat <<'EOF'
   <subject>

   <body>
   EOF
   )"

2. git push
   上流ブランチ未設定の場合: git push --set-upstream origin <現在のブランチ名>

各コマンドの出力をそのまま返してください。
```

「プッシュしない」を選択した場合はgit pushの指示を省く。

Agentから受け取った実行結果をユーザーに表示して完了。
