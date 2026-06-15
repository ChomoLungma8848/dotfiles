---
name: commit
description: 変更を論理的な単位に分割してConventional Commits形式でコミット・プッシュする。/commit で起動。git commitしたい、変更をコミットしたい、pushしたい、複数コミットに分けたい、といった場面で使用。
---

## 概要

すべての変更を読み取り、論理的にまとまりのある単位へ自動でグループ化。各グループのConventional Commitsメッセージを一括提案してユーザーに確認を取り、順番にコミット・プッシュするスキル。

## 手順

### 1. 変更状態の確認

以下を並列で実行して状態を把握する：
- `git status --short` — 全ファイルの状態（ステージング済み・未ステージング・未追跡）
- `git diff --staged` — ステージング済みの差分
- `git diff` — 未ステージングの差分

**変更が何もない場合**: 「コミットする変更がありません」と伝えて終了する。

### 2. ステージングされていない変更の処理

未ステージングまたは未追跡のファイルがある場合、**AskUserQuestion ツール**を使って以下を尋ねる：

```
question: "ステージングされていない変更があります。どうしますか？"
header: "ステージング"
options:
  - label: "全部対象にする"
    description: "ステージング済み・未ステージング・未追跡をすべてコミット対象にする"
  - label: "ステージング済みのみ"
    description: "現在ステージングされている変更のみコミットする"
  - label: "キャンセル"
    description: "処理を中断する"
```

選択に応じてコミット対象ファイルの範囲を決定する（この時点ではgit addは実行しない）。

### 3. 変更のグループ化と分割案の作成

対象ファイルの差分を精査し、**日本語**のConventional Commitsメッセージとともに論理的なグループへ分割する。

**グループ化の基準（優先順位順）:**
1. 同一機能・同一コンポーネントの変更は1つにまとめる（例: `hyprland/ashell.nix` と `hyprland/default.nix` への同一機能追加）
2. typeが異なる変更は別グループにする（例: `feat` と `chore` は分ける）
3. 完全に独立した機能は別グループにする
4. 変更量が多くても論理的に1つのまとまりなら1グループで構わない

**グループが1つしかない場合**: 分割案の提示をスキップしてステップ4へ進む。

**メッセージ形式**: `type(scope): 説明`

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

### 4. 全コミット案の一括確認（日本語）

作成した分割案を一覧形式で表示し、**AskUserQuestion ツール**を使って確認を取る。

表示例（テキストで整形して question に含める）：
```
コミット 1/3: feat(hyprland): noctalia テーマを追加
  対象: home/gui/hyprland/noctalia.nix, home/gui/hyprland/default.nix

コミット 2/3: chore: flake 入力を更新
  対象: flake.lock, flake.nix

コミット 3/3: feat(hyprland): ashell ステータスバーを追加
  対象: home/gui/hyprland/ashell.nix
```

```
question: "以下の順序でコミットします。\n\n<上記の分割案>\n\nよいですか？"
header: "コミット計画"
options:
  - label: "承認"
    description: "この計画でコミットを実行する"
  - label: "修正"
    description: "計画を変更する（Otherでグループ変更・メッセージ修正などを指示）"
  - label: "キャンセル"
    description: "処理を中断する"
```

- **承認** の場合: そのまま続行
- **修正** の場合: ユーザーの指示に従って分割案を修正し、再度このステップから確認を取る
- **キャンセル** の場合: 中断する

### 5. 英語メッセージへの翻訳

承認された全コミットのメッセージを**英語**のConventional Commits形式に翻訳する。

翻訳ルール：
- `type(scope):` の部分はそのまま保持
- 説明文を自然な英語に翻訳（直訳ではなく慣用的な表現を使う）

例：
- `feat(hyprland): noctalia テーマを追加` → `feat(hyprland): add noctalia theme`
- `chore: flake 入力を更新` → `chore: update flake inputs`

### 6. プッシュ確認

**AskUserQuestion ツール**を使って確認する：

```
question: "全コミット後にリモートにプッシュしますか？"
header: "プッシュ確認"
options:
  - label: "プッシュする"
    description: "git push でリモートに送信する（デフォルト）"
  - label: "プッシュしない"
    description: "コミットのみで終了する"
```

### 7. 全コミットの順番実行

ユーザーがステップ4・6で承認済みのため、**Agent ツール**（`model: "haiku"`、`mode: "bypassPermissions"`）を使ってgitコマンドを実行する。全コミットとプッシュを1回のAgent呼び出しにまとめることで、Bashツールの許可プロンプトは発生しない。

Agentへの指示例（コミット3件＋プッシュの場合）：

```
Bashツールのみを使って以下を順番に実行してください。
作業ディレクトリ: <カレントディレクトリのパス>

まず git reset HEAD -- . でステージングエリアをリセットする（ワーキングツリーは変更しない）。

--- コミット 1/3 ---
1. git add home/gui/hyprland/noctalia.nix home/gui/hyprland/default.nix
2. git commit -m "feat(hyprland): add noctalia theme"

--- コミット 2/3 ---
3. git add flake.lock flake.nix
4. git commit -m "chore: update flake inputs"

--- コミット 3/3 ---
5. git add home/gui/hyprland/ashell.nix
6. git commit -m "feat(hyprland): add ashell status bar"

--- プッシュ ---
7. git push
   上流ブランチ未設定の場合: git push --set-upstream origin <現在のブランチ名>

各コマンドの出力をそのまま返してください。
```

コミットが1件のみの場合は git reset をスキップし、通常通りに対象ファイルをgit addしてコミットする。
「プッシュしない」を選択した場合はgit pushの指示を省く。

Agentから受け取った実行結果をユーザーに表示して完了。
