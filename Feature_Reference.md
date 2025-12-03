# Claude Code Setup 機能リファレンス

セットアップスクリプト（`setup-global.sh` / `setup-project.sh`）を実行すると、以下の機能が自動的に構成されます。

---

## 目次

1. [カスタムコマンド](#1-カスタムコマンド)
2. [MCPサーバー](#2-mcpサーバー)
3. [Hooks（自動実行）](#3-hooks自動実行)
4. [権限管理](#4-権限管理)
5. [Agents（サブエージェント）](#5-agentsサブエージェント)
6. [自動育成機能](#6-自動育成機能)
7. [コンテキストエンジニアリング](#7-コンテキストエンジニアリング)
8. [ファイル構成一覧](#8-ファイル構成一覧)

---

## 1. カスタムコマンド

### グローバルコマンド（全プロジェクト共通）

| コマンド | 説明 | 主な用途 |
|---------|------|---------|
| `/checkpoint` | 現在の状態を保存 | コンテキスト60%超過時、複雑な作業前 |
| `/review` | コードレビュー実行 | コミット前の品質チェック |
| `/security-review` | セキュリティ特化レビュー | 機密性の高い変更のコミット前 |
| `/upgrade-global` | グローバル設定をアップグレード | 蓄積Issueから設定改善（週次推奨） |
| `/verify-upgrade` | アップグレードの効果検証 | 改善後5セッション経過時 |

### プロジェクトコマンド

| コマンド | 説明 | 主な用途 |
|---------|------|---------|
| `/start-task [id]` | タスク開始 | 新タスク着手時、プラン作成 |
| `/complete-task [id]` | タスク完了 | テスト・検証後の完了処理 |
| `/log-issue [説明]` | Issue手動記録 | 問題発生時の即座記録 |
| `/retrospective` | セッション振り返り | セッション終了時の問題検出 |
| `/sync-issues-to-global` | Issueをグローバルに同期 | プロジェクト終了時 |

### コマンド詳細

#### `/checkpoint`
```
機能:
- 全変更をGitにコミット
- progress.mdに詳細な状態を記録
- 次セッションへの引き継ぎ情報を作成
- コンテキスト使用量を報告

記録される情報:
- 完了した作業
- 進行中タスクの状態
- 残作業と推定複雑度
- ブロッカーや問題
- 次セッションへのメモ
```

#### `/review`
```
機能:
- git diff で変更内容を取得
- 6つの観点でレビュー実行
  - コード品質
  - 正確性
  - セキュリティ
  - パフォーマンス
  - テスト
  - ドキュメント
- 問題を重要度別に分類
- 判定: APPROVED / NEEDS CHANGES / BLOCKED
```

#### `/security-review`
```
機能:
- シークレット検出（APIキー、パスワード、トークン、秘密鍵）
- 入力バリデーション確認
- 認証・認可チェック
- インジェクション防止確認（SQL, XSS, コマンド）
- 機密ファイルへの変更検出

検出対象:
- API Keys, Passwords, Tokens
- Private Keys (PEM形式)
- AWS Credentials
- Generic secrets

判定:
- PASS: 問題なし、コミット可能
- WARN: 警告あり、確認後コミット可
- FAIL: 問題あり、修正必須
```

#### `/start-task`
```
機能:
- 現在の状態を確認（progress.md, tasks.json, git log）
- タスクの依存関係を検証
- 実装プランを作成
- Plan Modeで承認を待機
- 承認後、tasks.jsonを更新

作成されるプラン:
- 実装ステップ
- 修正ファイル一覧
- テスト戦略
- リスクと対策
- 推定コンテキスト使用量
```

#### `/complete-task`
```
機能:
- テスト実行（必須）
- エラーチェック（TypeScript, Lint）
- TODO/FIXME検索
- 受け入れ基準の検証
- tasks.json更新
- コミット作成
- progress.md更新
- 次タスクの推奨
```

#### `/upgrade-global`
```
機能:
- グローバルissues.jsonを読み込み
- 優先度別に問題を分類
  - 🔴 Critical/High: 即時対応
  - 🟡 Patterns: 3回以上発生の系統的問題
  - 🟢 Medium: 時間があれば対応
- 改善提案を生成
  - CLAUDE.md更新
  - Hook追加
  - 構造変更
- 承認を得て適用
- upgrade-log.mdに記録
```

#### `/verify-upgrade`
```
機能:
- 最近のアップグレードを読み込み
- 問題の再発を確認
- 効果を判定
  - ✅ EFFECTIVE: 再発なし
  - ⚠️ PARTIALLY EFFECTIVE: 頻度低下
  - ❌ INEFFECTIVE: 継続発生
  - ⏳ INSUFFICIENT DATA: データ不足
- 無効な場合はエスカレーション提案
```

---

## 2. MCPサーバー

### グローバルMCP（User Scope）

| サーバー | 用途 | 使用タイミング |
|---------|------|---------------|
| **context7** | ライブラリの最新ドキュメント取得 | 不慣れなライブラリ使用前 |
| **sequential-thinking** | 複雑な問題のステップバイステップ推論 | 複雑な問題分析時 |

### プロジェクトMCP（Project Scope）

プロジェクトタイプに応じて自動選択：

| プロジェクトタイプ | サーバー | 用途 |
|------------------|---------|------|
| React/Next.js/Node.js | puppeteer | ブラウザ自動化、スクリーンショット |
| Express/FastAPI/Django | postgresql | DBスキーマ確認、クエリ実行 |

### MCP設定ファイル

**グローバル（~/.claude.json）:**
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

**プロジェクト（.mcp.json）:**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

---

## 3. Hooks（自動実行）

### PostToolUse Hooks（ファイル保存後に自動実行）

| 対象ファイル | 実行コマンド | 効果 |
|-------------|-------------|------|
| `*.py` | `black`, `ruff check` | Pythonコードの自動フォーマット・Lint |
| `*.ts` | `prettier --write` | TypeScriptの自動フォーマット |
| `*.tsx` | `prettier --write`, `eslint --fix` | React TypeScriptの自動フォーマット・Lint |
| `*.js` | `prettier --write` | JavaScriptの自動フォーマット |
| `*.jsx` | `prettier --write` | React JSXの自動フォーマット |
| `*.json` | `prettier --write` | JSONの自動フォーマット |

### 監査ログ Hooks（重要操作の記録）

| 対象操作 | 記録先 | 内容 |
|---------|-------|------|
| `Write(*.env*)` | `~/.claude/security-audit.log` | 環境変数ファイルへの書き込み |
| `Write(*secret*)` | `~/.claude/security-audit.log` | シークレット関連ファイルへの書き込み |
| `Bash(git push*)` | `~/.claude/security-audit.log` | git push実行 |

**ログ形式:**
```
2025-12-03_10:30:00|WRITE|.env.local
2025-12-03_11:45:00|GIT_PUSH
```

### PreToolUse Hooks（危険操作のブロック）

| パターン | 動作 | メッセージ |
|---------|------|----------|
| `rm -rf *` | ブロック | "Dangerous recursive delete blocked" |
| `.env.production` への書き込み | ブロック | "Production environment file modification blocked" |

### 設定ファイル

**グローバル（~/.claude/settings.json）:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {"type": "command", "command": "python -m black $file 2>/dev/null || true"},
          {"type": "command", "command": "python -m ruff check $file 2>/dev/null || true"}
        ]
      }
    ]
  }
}
```

**プロジェクト（.claude/settings.json）:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(rm -rf *)",
        "hooks": [{"type": "block", "message": "Dangerous recursive delete blocked."}]
      }
    ]
  }
}
```

---

## 4. 権限管理

### 許可された操作（Allow）

| カテゴリ | 許可パターン |
|---------|-------------|
| ファイル | `Read`, `Write` |
| Git | `Bash(git *)` |
| Node.js | `Bash(npm run *)`, `Bash(npx *)`, `Bash(node *)` |
| Python | `Bash(python *)`, `Bash(pip *)` |
| ファイル操作 | `Bash(cat *)`, `Bash(ls *)`, `Bash(grep *)`, `Bash(find *)` |
| ディレクトリ | `Bash(mkdir *)`, `Bash(cp *)`, `Bash(mv *)`, `Bash(pwd)` |

### 禁止された操作（Deny）

| カテゴリ | 禁止パターン | 理由 |
|---------|-------------|------|
| 環境変数 | `Read(./.env)`, `Read(./.env.*)` | 環境変数の漏洩防止 |
| シークレット | `Read(**/secrets/**)`, `Read(**/.ssh/**)` | 認証情報の保護 |
| 秘密鍵 | `Read(**/*.pem)`, `Read(**/*secret*)` | 秘密鍵・機密ファイルの保護 |
| クラウド認証 | `Read(**/.aws/*)` | AWS認証情報の保護 |
| 本番環境 | `Write(./production.*)`, `Write(./.env.production)` | 本番環境の保護 |
| 危険コマンド | `Bash(rm -rf /)`, `Bash(sudo *)`, `Bash(chmod 777 *)` | システム破壊防止 |
| リモート実行 | `Bash(curl * \| bash)`, `Bash(wget * \| bash)` | 悪意あるスクリプト実行防止 |
| ディスク破壊 | `Bash(* > /dev/sd*)`, `Bash(dd if=*)` | ディスク破壊防止 |

---

## 5. Agents（サブエージェント）

### security-reviewer

**目的:** セキュリティ観点でのコードレビュー

**チェック項目:**
- 認証・認可（ルート保護、セッション管理）
- 入力検証（型チェック、長さ制限）
- インジェクション防止（SQL, XSS, コマンド）
- データ保護（暗号化、PII、シークレット）
- API セキュリティ（レート制限、CORS、エラーメッセージ）

**使用方法:**
```
セキュリティレビューを実行して
```

**レポート形式:**
```
## Security Review: [Component]

### Critical Issues
- **[CRITICAL]** [Location]: [Description]

### High Issues
- **[HIGH]** [Location]: [Description]

### Passed Checks
- [List of passed checks]
```

---

## 6. 自動育成機能

### Issue自動検出（Low-Token Mode）

**セッション中の動作:**

| トリガー | 例 | 動作 |
|---------|-----|------|
| ユーザーの指摘 | 「違う」「そうじゃない」 | 📝 Noted: [概要] |
| 要件の認識違い | コードレビューで発覚 | 📝 Noted: [概要] |
| テスト失敗 | 実装後にテスト失敗 | 📝 Noted: [概要] |
| 説明の繰り返し | 同じ説明を2回以上 | 📝 Noted: [概要] |
| 実行エラー | 予期せぬエラー | 📝 Noted: [概要] |

**ポイント:**
- セッション中はメモリ保持のみ（ファイル操作なし）
- トークン消費を約90%削減
- セッション終了時に一括記録

**セッション終了時:**
```
📊 Session: 3 issues recorded
- 戻り値の型違い (communication/medium)
- テスト未実行 (quality-gate/high)
- 依存関係の見落とし (workflow/medium)
```

### 継続的改善サイクル

```
セッション中
    │
    ├── 問題検出 → 📝 Noted（メモリ保持）
    │
    └── セッション終了 → issues.json に一括記録
                              │
                              ▼
                    /sync-issues-to-global
                              │
                              ▼
                    グローバル issues.json に蓄積
                              │
                              ▼
                    /upgrade-global（週次）
                              │
                              ▼
                    CLAUDE.md / settings.json 改善
                              │
                              ▼
                    /verify-upgrade（5セッション後）
                              │
                              ▼
                    効果検証 → 必要に応じて再改善
```

### Issue分類

| カテゴリ | 説明 | 例 |
|---------|------|-----|
| `quality-gate` | テスト・検証の問題 | テスト未実行でコミット |
| `context-management` | コンテキスト管理の問題 | コンテキスト溢れで作業ロスト |
| `workflow` | プロセス・手順の問題 | 依存タスクを先に実行 |
| `code-standard` | コーディング規約違反 | 命名規則の不統一 |
| `communication` | 確認・報告の問題 | 要件の認識違い |

### 重要度判定

| 重要度 | 基準 |
|-------|------|
| `critical` | データ損失、セキュリティリスク、作業ブロック |
| `high` | ユーザーが繰り返し説明、やり直し発生 |
| `medium` | 実装の修正が必要 |
| `low` | 軽微な誤解、すぐ解決 |

---

## 7. コンテキストエンジニアリング

### コンテキスト管理ルール

| 使用率 | 動作 | アクション |
|-------|------|----------|
| 50%超過 | 警告 | 現タスク完了を検討 |
| 70%超過 | チェックポイント | `/checkpoint` 実行 |
| 85%超過 | 緊急保存 | 即座にコミット、新セッション推奨 |

### セッション境界の管理

**有効なセッション終了:**
- 全変更がコミット済み
- progress.md が更新済み
- コンテキスト使用量を報告
- 次ステップが文書化

**無効なセッション終了:**
- 未コミットの変更あり
- ドキュメント未更新
- 進捗更新なし
- コンテキスト溢れ（チェックポイントなし）

### 状態管理ファイル

| ファイル | 形式 | 用途 |
|---------|------|------|
| `tasks.json` | JSON | タスク状態（改ざん耐性） |
| `progress.md` | Markdown | 進捗ノート（可読性重視） |
| `issues.json` | JSON | Issue追跡 |

### 行動原則

| 原則 | 内容 |
|------|------|
| インクリメンタル開発 | 1セッション1タスク、独立テスト可能 |
| 明示的状態管理 | セッション間でメモリに依存しない |
| 完了前検証 | テスト実行、受け入れ基準確認 |
| コンテキスト認識 | 使用率監視、適切なチェックポイント |
| Human-in-the-Loop | Plan Mode、承認待ち、質問優先 |

---

## 8. ファイル構成一覧

### グローバル設定（~/.claude/）

```
~/.claude/
├── CLAUDE.md                    # グローバル指示（@importで分割）
├── settings.json                # 権限・Hooks設定
├── issues.json                  # グローバルIssue追跡
├── upgrade-log.md               # アップグレード履歴
├── security-audit.log           # 監査ログ（自動生成）
├── docs/
│   ├── behavior-principles.md   # 行動原則
│   ├── task-workflow.md         # タスク管理ワークフロー
│   ├── code-standards.md        # コーディング規約
│   └── quality-gates.md         # 品質ゲート
└── commands/
    ├── checkpoint.md            # /checkpoint
    ├── review.md                # /review
    ├── security-review.md       # /security-review
    ├── upgrade-global.md        # /upgrade-global
    └── verify-upgrade.md        # /verify-upgrade

~/.claude.json                   # User Scope MCP設定
```

### プロジェクト設定（your-project/）

```
your-project/
├── CLAUDE.md                    # プロジェクト固有指示
├── .mcp.json                    # Project Scope MCP設定
├── tasks.json                   # タスク管理
├── issues.json                  # プロジェクトIssue追跡
├── progress.md                  # 進捗ログ
├── .env.mcp.example             # 環境変数テンプレート
├── .claude/
│   ├── settings.json            # プロジェクトHooks
│   ├── commands/
│   │   ├── start-task.md        # /start-task
│   │   ├── complete-task.md     # /complete-task
│   │   ├── log-issue.md         # /log-issue
│   │   ├── retrospective.md     # /retrospective
│   │   └── sync-issues-to-global.md  # /sync-issues-to-global
│   └── agents/
│       └── security-reviewer.md # セキュリティレビューエージェント
└── docs/
    ├── architecture.md          # アーキテクチャ設計書
    └── api-specs.md             # API仕様書
```

---

## クイックリファレンス

### よく使うコマンド

```bash
# タスク管理
/start-task 1          # タスク開始
/complete-task 1       # タスク完了

# 品質管理
/review                # コードレビュー
/security-review       # セキュリティレビュー
/checkpoint            # 状態保存

# Issue管理
/log-issue [説明]      # Issue記録
/retrospective         # 振り返り

# 継続的改善
/upgrade-global        # 設定改善（週次）
/verify-upgrade        # 効果検証
```

### キーボードショートカット

| ショートカット | 機能 |
|---------------|------|
| `Shift+Tab×2` | Plan Mode |
| `Ctrl+C` | 処理キャンセル |
| `Escape` | 入力キャンセル |

### ビルトインコマンド

| コマンド | 機能 |
|---------|------|
| `/context` | コンテキスト使用量 |
| `/compact` | 会話圧縮 |
| `/mcp` | MCP接続状況 |
| `/help` | ヘルプ |

---

Created by Kosky | Based on Claude Code Complete Setup Package
