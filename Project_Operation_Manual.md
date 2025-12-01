# Claude Code プロジェクト実運用マニュアル

Global Settingが完了している前提で、新規プロジェクトでClaude Codeを運用するための手順書です。

---

## 目次

1. [プロジェクト初期セットアップ](#1-プロジェクト初期セットアップ)
2. [CLAUDE.mdのカスタマイズ](#2-claudemdのカスタマイズ)
3. [タスク設計と登録](#3-タスク設計と登録)
4. [セッションワークフロー](#4-セッションワークフロー)
5. [コマンドリファレンス](#5-コマンドリファレンス)
6. [トラブルシューティング](#6-トラブルシューティング)

---

## 1. プロジェクト初期セットアップ

### 1.1 セットアップスクリプトの実行

```bash
# 新規または既存プロジェクトのルートディレクトリに移動
cd /path/to/your/project

# セットアップスクリプトを実行
/path/to/claude-code-setup/setup-project.sh
```

### 1.2 自動生成されるファイル

```
your-project/
├── CLAUDE.md                 # プロジェクト固有の指示
├── .mcp.json                 # Project scope MCP設定
├── tasks.json                # タスク管理ファイル
├── progress.md               # 進捗ログ
├── .claude/
│   ├── settings.json         # Claude Code設定
│   ├── commands/
│   │   ├── start-task.md     # タスク開始コマンド
│   │   └── complete-task.md  # タスク完了コマンド
│   └── agents/
│       └── security-reviewer.md
└── docs/
    ├── architecture.md       # アーキテクチャ設計書
    └── api-specs.md          # API仕様書
```

### 1.3 環境変数の設定（必要な場合）

```bash
# テンプレートをコピー
cp .env.mcp.example .env.mcp

# 必要なAPI KEYを設定
vim .env.mcp

# シェルに読み込み
source .env.mcp
```

### 1.4 動作確認

```bash
# Claude Codeを起動
claude

# 設定確認コマンド
/context    # コンテキスト使用量
/mcp        # MCP接続状況
/help       # 利用可能コマンド
```

---

## 2. CLAUDE.mdのカスタマイズ

### 2.1 必須編集項目

`CLAUDE.md` を開いて以下を編集：

```markdown
# Project: [プロジェクト名を入力]

## Overview
[プロジェクトの目的・概要を2-3文で記述]

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18 + TypeScript |
| Backend | Node.js + Express |
| Database | PostgreSQL 15 |
| Cloud | AWS (EC2, RDS, S3) |
| CI/CD | GitHub Actions |
```

### 2.2 ディレクトリ構造の記述

実際のプロジェクト構造に合わせて更新：

```markdown
## Directory Structure

src/
├── components/    # UIコンポーネント
├── pages/         # ページコンポーネント
├── api/           # API呼び出しロジック
├── lib/           # 共通ライブラリ
├── types/         # TypeScript型定義
└── utils/         # ユーティリティ関数
```

### 2.3 開発コマンドの記述

プロジェクト固有のコマンドを記載：

```markdown
## Commands

### Development
npm run dev       # 開発サーバー起動
npm run build     # プロダクションビルド
npm run lint      # Linter実行

### Testing
npm test          # ユニットテスト
npm run test:e2e  # E2Eテスト
```

### 2.4 コーディング規約の追記

プロジェクト固有のルールがあれば追記：

```markdown
## Coding Conventions

### This Project Specific
- コンポーネントはfunctional componentのみ使用
- API呼び出しはReact Queryを使用
- 状態管理はZustandを使用
```

---

## 3. タスク設計と登録

### 3.1 タスクサイズの基準

| タイプ | 目安 | セッション数 |
|--------|------|-------------|
| small | 30分以内、1ファイル | 1セッション |
| medium | 1時間、2-5ファイル | 1-2セッション |
| large | 2時間、複数コンポーネント | 2-4セッション |
| huge | 1日以上、システム全体 | 複数セッション |

### 3.2 tasks.jsonの編集

```json
{
  "project": "my-project",
  "version": "1.0.0",
  "created": "2025-12-01T10:00:00Z",
  "updated": "2025-12-01T10:00:00Z",
  "tasks": [
    {
      "id": 1,
      "title": "認証機能の実装",
      "description": "JWTベースのログイン・ログアウト機能を実装",
      "status": "pending",
      "type": "large",
      "dependencies": [],
      "acceptance_criteria": [
        "ログインフォームが動作する",
        "JWT tokenが正しく発行される",
        "ログアウトでtokenが無効化される",
        "不正アクセス時に401が返る"
      ],
      "subtasks": [],
      "notes": "",
      "created_at": "2025-12-01T10:00:00Z",
      "completed_at": null
    },
    {
      "id": 2,
      "title": "ユーザープロフィール画面",
      "description": "ユーザー情報の表示と編集機能",
      "status": "pending",
      "type": "medium",
      "dependencies": [1],
      "acceptance_criteria": [
        "プロフィール情報が表示される",
        "編集フォームが動作する",
        "バリデーションが機能する"
      ],
      "subtasks": [],
      "notes": "認証機能完了後に着手",
      "created_at": "2025-12-01T10:00:00Z",
      "completed_at": null
    }
  ]
}
```

### 3.3 良いタスク設計のポイント

**DO ✓**
- 1セッションで完了可能な粒度にする
- 受け入れ基準を具体的に書く
- 依存関係を明示する
- テスト可能な単位で分割する

**DON'T ✗**
- 曖昧な表現（「〜を改善」「〜を最適化」）
- 複数の独立した作業を1タスクにまとめる
- 依存関係を無視した順序

---

## 4. セッションワークフロー

### 4.1 セッション開始時

```
Claude Codeを起動後、以下の流れで進める：

1. 状態確認
   Claude: pwd && git log --oneline -5 && cat progress.md

2. タスク選択
   You: /start-task 1  (または /start-task "認証機能の実装")

3. Claude がプランを提示
   - 実装ステップ
   - 修正ファイル一覧
   - リスク・注意点
   - 推定コンテキスト使用量

4. プラン承認
   You: OK、進めて / もう少し詳しく / この部分を変更して
```

### 4.2 作業中の確認

```
コンテキスト使用量を定期的に確認：

/context

50%超過: 警告を意識して作業継続
70%超過: /checkpoint でセッション保存
85%超過: 即座にコミットして新セッション
```

### 4.3 タスク完了時

```
1. テスト実行
   Claude: npm test && npm run lint

2. 完了コマンド実行
   You: /complete-task 1

3. Claude が以下を実行:
   - 受け入れ基準の確認
   - tasks.json更新
   - コミット作成
   - progress.md更新
   - 次タスクの推奨
```

### 4.4 セッション終了時

```
終了前チェックリスト：

1. 未コミットの変更がないか
   git status

2. progress.mdが更新されているか

3. コンテキスト使用量の報告
   /context

4. 次セッションへの引き継ぎ
   - 中断ポイントをprogress.mdに記録
   - 未解決の問題があれば記録
```

---

## 5. コマンドリファレンス

### 5.1 グローバルコマンド（どのプロジェクトでも使用可）

| コマンド | 説明 | 使用タイミング |
|----------|------|----------------|
| `/checkpoint` | 現在の状態を保存 | コンテキスト60%超、複雑な作業前 |
| `/review` | コードレビュー実行 | コミット前 |

### 5.2 プロジェクトコマンド

| コマンド | 説明 | 使用タイミング |
|----------|------|----------------|
| `/start-task [id/名前]` | タスク開始 | 新タスク着手時 |
| `/complete-task [id]` | タスク完了 | 作業完了時 |

### 5.3 組み込みコマンド

| コマンド | 説明 |
|----------|------|
| `/context` | コンテキスト使用量表示 |
| `/compact` | 会話を圧縮してコンテキスト節約 |
| `/mcp` | MCP接続状況確認 |
| `/help` | ヘルプ表示 |
| `/clear` | 会話履歴クリア |

### 5.4 キーボードショートカット

| ショートカット | 機能 |
|----------------|------|
| `Shift+Tab×2` | Plan Mode（計画モード）に入る |
| `Ctrl+C` | 現在の処理をキャンセル |
| `Escape` | 入力をキャンセル |

---

## 6. トラブルシューティング

### 6.1 MCPが接続できない

```bash
# MCP状況確認
/mcp

# 環境変数が読み込まれているか確認
echo $CONTEXT7_API_KEY

# Claude Codeを再起動
exit
claude
```

### 6.2 コンテキストが足りなくなった

```
1. 即座にチェックポイント作成
   /checkpoint

2. 進捗を保存
   Claude: git add . && git commit -m "checkpoint: [作業内容]"

3. 新しいセッションを開始
   exit
   claude

4. 続きから再開
   /start-task [同じタスクID]
```

### 6.3 タスクが大きすぎた

```
1. タスクをサブタスクに分割

tasks.jsonを編集:
{
  "id": 1,
  "subtasks": [
    {"id": "1-1", "title": "DB スキーマ設計", "status": "completed"},
    {"id": "1-2", "title": "API エンドポイント実装", "status": "in_progress"},
    {"id": "1-3", "title": "フロントエンド連携", "status": "pending"}
  ]
}

2. サブタスク単位で完了を管理
```

### 6.4 Claudeが想定外の動作をした

```
1. 作業を停止させる
   Ctrl+C

2. 状況を確認
   git status
   git diff

3. 必要に応じてリセット
   git checkout -- .  (全ての変更を破棄)
   git stash          (変更を一時保存)

4. 指示を明確にして再試行
   「〜しないでください」「〜だけを行ってください」
```

### 6.5 テストが通らない

```
1. エラー内容を確認させる
   「テストエラーの内容を分析して、原因を特定してください」

2. 修正プランを確認
   「修正方針を説明してから、実装してください」

3. 段階的に修正
   「まず最初のエラーだけ修正してください」
```

---

## 付録: 典型的なセッション例

### A. 新機能実装セッション

```
# セッション開始
You: 今日は認証機能を実装します

Claude:
pwd && git log --oneline -5 && cat progress.md
[状態確認]

You: /start-task 1

Claude:
[タスク詳細を読み込み]
[実装プランを提示]

You: OKです、進めてください

Claude:
[Plan Modeで計画]
[実装開始]
[テスト実行]

You: /complete-task 1

Claude:
[完了処理]
[コミット]
[次タスク推奨]

You: 今日はここまでにします

Claude:
[progress.md更新]
[コンテキスト使用量報告]
```

### B. バグ修正セッション

```
You: ログイン後にリダイレクトされない問題を修正してください

Claude:
[問題の再現確認]
[原因調査]
[修正プラン提示]

You: その方針でOK

Claude:
[修正実装]
[テスト追加]
[動作確認]

You: /review

Claude:
[コードレビュー実行]
[問題なければコミット推奨]

You: コミットしてください

Claude:
[コミット作成]
```

---

## 更新履歴

| バージョン | 日付 | 内容 |
|-----------|------|------|
| 1.0.0 | 2025-12-01 | 初版作成 |

---

Created by Kosky | Based on Claude Code Complete Setup Package
