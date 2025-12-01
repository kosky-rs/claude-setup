# Claude Code 完全セットアップガイド
## 仕様書 & 設定マニュアル

> **Version:** 1.0  
> **Last Updated:** 2025-12-01  
> **Author:** Kosky  
> **対象:** Claude Code v2.0+

---

## 目次

1. [概要と目的](#第1章-概要と目的)
2. [アーキテクチャ全体像](#第2章-アーキテクチャ全体像)
3. [ディレクトリ構成](#第3章-ディレクトリ構成)
4. [CLAUDE.md設計と実装](#第4章-claudemd設計と実装)
5. [MCP設定と運用](#第5章-mcp設定と運用)
6. [Skills設定](#第6章-skills設定)
7. [タスク管理ワークフロー](#第7章-タスク管理ワークフロー)
8. [Hooksと品質ゲート](#第8章-hooksと品質ゲート)
9. [カスタムコマンド](#第9章-カスタムコマンド)
10. [Issue管理と継続的改善](#第10章-issue管理と継続的改善)
11. [セットアップ手順](#第11章-セットアップ手順)
12. [運用ガイドライン](#第12章-運用ガイドライン)
13. [付録](#付録)

---

# 第1章: 概要と目的

## 1.1 本ドキュメントの目的

本ドキュメントは、Claude Codeのローカル開発環境を**網羅的かつ最適化された状態**で構築するための仕様書兼設定マニュアルである。

### 解決する課題

| 課題 | 解決アプローチ |
|------|---------------|
| ロングランでの完了偽装・中途半端な出力 | タスク駆動開発 + 品質ゲート |
| チャット継続に伴う精度低下 | コンテキスト管理 + Compaction戦略 |
| MCP・Skillsの活用不足 | 体系的な設定 + Progressive Disclosure |
| CLAUDE.md・オーケストレーション未整備 | モジュラー構成 + @import活用 |
| チーム間での設定差異 | 標準化されたテンプレート |

## 1.2 対象読者

- Claude Codeを本格活用したい開発者
- Webアプリ開発、クラウド開発、LLM開発従事者
- AI駆動開発ワークフローを体系化したい方
- チームへの展開を見据えた標準化を目指す方

## 1.3 設計原則

### Progressive Disclosure（段階的開示）

全ての設定は「必要な時に必要な分だけ」ロードする設計を採用：

```
Level 1: メタデータスキャン（約100トークン/項目）
    ↓ タスクマッチ時のみ
Level 2: 指示のロード（約5,000トークン未満）
    ↓ 必要時のみ
Level 3: リソースのロード（スクリプト、テンプレート等）
```

### コンテキストウィンドウ効率化

- CLAUDE.md: 5kトークン以下
- MCP: 使用するものだけ有効化
- Skills: タスクに関連するもののみ自動ロード

---

# 第2章: アーキテクチャ全体像

## 2.1 設定ファイル階層

```
┌─────────────────────────────────────────────────────────────────┐
│ 優先度: 高                                                       │
├─────────────────────────────────────────────────────────────────┤
│ [Enterprise Layer] - IT管理者配布（オプション）                  │
│ ├── /etc/claude-code/managed-mcp.json                           │
│ └── /etc/claude-code/managed-settings.json                      │
├─────────────────────────────────────────────────────────────────┤
│ [User Layer] - 個人の常用設定                                    │
│ ├── ~/.claude/CLAUDE.md          ← グローバル指示               │
│ ├── ~/.claude.json               ← User scope MCP               │
│ ├── ~/.claude/settings.json      ← Hooks, Permissions           │
│ └── ~/.claude/docs/              ← 詳細ドキュメント              │
├─────────────────────────────────────────────────────────────────┤
│ [Project Layer] - プロジェクト固有                               │
│ ├── ./CLAUDE.md                  ← プロジェクト指示              │
│ ├── ./.mcp.json                  ← Project scope MCP            │
│ ├── ./.claude/settings.json      ← Project Hooks                │
│ ├── ./.claude/settings.local.json ← ローカル設定（.gitignore）  │
│ ├── ./.claude/commands/*.md      ← カスタムコマンド              │
│ ├── ./.claude/agents/*.md        ← Subagent定義                 │
│ └── ./.claude/skills/*/SKILL.md  ← カスタムSkill                │
├─────────────────────────────────────────────────────────────────┤
│ 優先度: 低                                                       │
└─────────────────────────────────────────────────────────────────┘
```

## 2.2 コンポーネント関係図

```
┌──────────────────────────────────────────────────────────────────┐
│                        Claude Code                                │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    Context Window                           │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │  │
│  │  │CLAUDE.md │ │   MCP    │ │  Skills  │ │  Tasks   │      │  │
│  │  │ (~3-5k)  │ │ (15-50k) │ │ (動的)   │ │ (JSON)   │      │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│              ┌───────────────┼───────────────┐                   │
│              ▼               ▼               ▼                   │
│         ┌────────┐     ┌────────┐     ┌────────┐                │
│         │ Hooks  │     │Commands│     │Subagent│                │
│         │(Pre/   │     │(/cmd)  │     │(並列)  │                │
│         │ Post)  │     │        │     │        │                │
│         └────────┘     └────────┘     └────────┘                │
└──────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ GitHub   │   │PostgreSQL│   │ Context7 │
        │ (MCP)    │   │  (MCP)   │   │  (MCP)   │
        └──────────┘   └──────────┘   └──────────┘
```

## 2.3 データフロー

```
セッション開始
    │
    ├── CLAUDE.md読み込み（グローバル→プロジェクト）
    ├── MCP接続確立（user → project scope）
    ├── Skills検出（メタデータのみ）
    │
    ▼
タスク実行
    │
    ├── タスクマッチでSkill詳細ロード
    ├── MCPツール呼び出し
    ├── Hooks実行（Pre/Post）
    │
    ▼
セッション終了
    │
    ├── Git commit
    ├── progress.md更新
    └── コンテキスト使用率報告
```

---

# 第3章: ディレクトリ構成

## 3.1 グローバル構成（~/.claude/）

```bash
~/.claude/
├── CLAUDE.md                    # グローバル指示（最小限、英語推奨）
├── settings.json                # Hooks, Permissions
├── issues.json                  # グローバルIssue管理
├── upgrade-log.md               # アップグレード履歴
├── docs/                        # 詳細ドキュメント（@importで参照）
│   ├── behavior-principles.md   # 振る舞い原則
│   ├── task-workflow.md         # タスク管理ワークフロー
│   ├── code-standards.md        # コーディング規約
│   └── quality-gates.md         # 品質チェック
└── commands/                    # グローバルカスタムコマンド
    ├── checkpoint.md
    ├── review.md
    ├── upgrade-global.md        # 設定アップグレード
    └── verify-upgrade.md        # 効果検証

~/.claude.json                   # User scope MCP設定
```

## 3.2 プロジェクト構成（./）

```bash
project/
├── CLAUDE.md                    # プロジェクト固有指示
├── .mcp.json                    # Project scope MCP（Git管理）
├── tasks.json                   # タスク状態（JSON）
├── issues.json                  # プロジェクトIssue管理
├── progress.md                  # 進捗メモ（Markdown）
├── docs/
│   ├── architecture.md          # アーキテクチャ詳細
│   ├── tech-stack.md            # 技術スタック
│   └── api-specs.md             # API仕様
├── .claude/
│   ├── settings.json            # Project Hooks
│   ├── settings.local.json      # ローカル設定（.gitignore）
│   ├── commands/                # プロジェクト固有コマンド
│   │   ├── start-task.md
│   │   ├── complete-task.md
│   │   ├── log-issue.md         # Issue記録
│   │   ├── retrospective.md     # セッション振り返り
│   │   ├── sync-issues-to-global.md  # グローバル同期
│   │   └── deploy.md
│   ├── agents/                  # Subagent定義
│   │   ├── security-reviewer.md
│   │   └── performance-analyst.md
│   └── skills/                  # カスタムSkill
│       └── my-skill/
│           └── SKILL.md
└── .env.mcp                     # MCP用環境変数（.gitignore）
```

## 3.3 .gitignore推奨設定

```gitignore
# Claude Code ローカル設定
.claude/settings.local.json
.env.mcp
.env.local

# 一時ファイル
*.tmp
*.bak
```

---

# 第4章: CLAUDE.md設計と実装

## 4.1 設計原則

### トークン最適化

| 構成 | 推定トークン | 効果 |
|------|-------------|------|
| 全部入りCLAUDE.md | 3,000-5,000 | 毎回全量消費 |
| 最小版 + @import | 300-500（メイン） | 必要時のみ詳細読込 |

### 言語選択

| 対象 | 言語 | 理由 |
|------|------|------|
| グローバルCLAUDE.md | **英語** | 精度向上（約4%差） |
| プロジェクト固有指示 | 日本語可 | コンテキストの明確さ優先 |
| コード・変数名 | 英語必須 | 標準プラクティス |

## 4.2 グローバルCLAUDE.md

### ファイル: `~/.claude/CLAUDE.md`

```markdown
# Global Instructions for Claude Code

## Behavior Principles
@~/.claude/docs/behavior-principles.md

## Task Management Workflow
@~/.claude/docs/task-workflow.md

## Code Standards
@~/.claude/docs/code-standards.md

## Quality Gates
@~/.claude/docs/quality-gates.md

---

## Quick Reference

### Session Start Checklist
1. `pwd` → `git log --oneline -5` → `cat progress.md`
2. Select ONE pending task
3. Enter Plan Mode (Shift+Tab×2)
4. **Wait for human approval before coding**

### Session End Checklist
1. Run all tests
2. `git add . && git commit -m "feat: [description]"`
3. Update progress.md
4. Report context usage %

### Critical Rules
- **IMPORTANT**: Never declare completion without E2E testing
- **YOU MUST**: Commit all changes before session end
- **IMPORTANT**: Ask clarifying questions rather than assume
```

## 4.3 詳細ドキュメント

### ファイル: `~/.claude/docs/behavior-principles.md`

```markdown
# Behavior Principles

## Core Principles

### 1. Incremental Development
- Complete ONE task per session
- Each task must be testable independently
- Commit after each logical unit

### 2. Explicit State Management
- Use JSON for task state (resistant to modification)
- Use Markdown for progress notes (human-readable)
- Use Git for history and recovery

### 3. Verification Before Completion
- Run tests before marking complete
- Verify no console errors
- Check for TODO comments

### 4. Context Awareness
- Monitor context usage: warn at 50%, checkpoint at 70%
- Use `/compact` when approaching limits
- Start new session rather than risk data loss

## Anti-Patterns to Avoid

| Anti-Pattern | Correct Approach |
|--------------|------------------|
| One-shot completion | Incremental implementation |
| Premature "done" declaration | Test-driven completion |
| Uncommitted session end | Always commit before exit |
| Assumption without verification | Ask clarifying questions |
| Context overflow | Checkpoint and new session |
```

### ファイル: `~/.claude/docs/task-workflow.md`

```markdown
# Task Management Workflow

## Task Hierarchy

| Complexity | Task Count | Example |
|------------|-----------|---------|
| Huge | 15-25 top-level | Full application |
| Large | 8-15 tasks | Multi-component feature |
| Medium | 3-8 tasks | Single component |
| Small | Direct implementation | Bug fix, tweak |

## Session Lifecycle

### START Phase
```bash
# 1. Confirm working directory
pwd

# 2. Check recent changes
git log --oneline -5

# 3. Review progress
cat progress.md
cat tasks.json

# 4. Select ONE pending task
# 5. Run baseline tests
npm test  # or appropriate command
```

### WORK Phase
1. Enter Plan Mode (Shift+Tab×2)
2. Create implementation plan
3. **Present plan and wait for approval**
4. Implement incrementally
5. Commit frequently
6. Test thoroughly before completion

### END Phase
```bash
# 1. Commit changes
git add .
git commit -m "feat: [detailed description]"

# 2. Update progress
# Add to progress.md:
# - Completed work
# - Remaining tasks
# - Handoff notes

# 3. Report context usage
```

## Task State Format (tasks.json)

```json
{
  "project": "project-name",
  "updated": "2025-12-01T10:00:00Z",
  "tasks": [
    {
      "id": 1,
      "title": "Task title",
      "status": "pending|in_progress|completed|blocked",
      "type": "small|medium|large|huge",
      "dependencies": [],
      "subtasks": []
    }
  ]
}
```
```

### ファイル: `~/.claude/docs/quality-gates.md`

```markdown
# Quality Gates

## Mandatory Checks

| Check | Description | Violation Response |
|-------|-------------|-------------------|
| No premature completion | No "done" before E2E test | Force test execution |
| No uncommitted endings | No session end without commit | Force commit |
| No context overflow | Warn at 50%, checkpoint at 70% | Save progress, new session |
| No untested code | Verify all changes | Force test execution |

## Pre-Completion Checklist

- [ ] All tests pass
- [ ] No console errors
- [ ] No TODO comments left behind
- [ ] Code follows project standards
- [ ] Documentation updated if needed

## When Uncertain

1. Ask clarifying questions (don't assume)
2. Search codebase for similar implementations
3. Check git history for patterns
4. If still unclear, propose options to human

## IMPORTANT Keywords

Use these for critical instructions:
- **IMPORTANT**: Must be followed in most cases
- **YOU MUST**: Absolutely required, no exceptions
- **NEVER**: Prohibited action
- **ALWAYS**: Required action
```

### ファイル: `~/.claude/docs/code-standards.md`

```markdown
# Code Standards

## General Principles

- Write self-documenting code
- Follow existing project patterns
- Prefer composition over inheritance
- Keep functions small and focused

## Language-Specific

### TypeScript/JavaScript
- Use TypeScript strict mode
- Prefer `const` over `let`
- Use async/await over callbacks
- Explicit return types for functions

### Python
- Follow PEP 8
- Use type hints
- Prefer f-strings for formatting
- Use dataclasses for data structures

## Git Commit Messages

Format: `<type>: <description>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `docs`: Documentation
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Example: `feat: add user authentication endpoint`

## Testing Requirements

- Unit tests for all business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Minimum 80% code coverage
```

## 4.4 プロジェクトCLAUDE.md

### ファイル: `./CLAUDE.md`（プロジェクトルート）

```markdown
# Project: [Project Name]

## Overview
[Brief project description]

## Tech Stack
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL
- Cloud: Azure

## Project-Specific Rules

### Architecture
@./docs/architecture.md

### API Specifications
@./docs/api-specs.md

## MCP Usage Guidelines

| MCP Server | Purpose | When to Use |
|------------|---------|-------------|
| context7 | Library docs | Before using new library |
| postgresql | DB schema/queries | Before migrations, data checks |
| puppeteer | Screenshots | After UI implementation |

## Directory Structure
```
src/
├── components/    # React components
├── pages/         # Page components
├── api/           # API routes
├── lib/           # Utilities
└── types/         # TypeScript types
```

## Testing Commands
```bash
npm test          # Unit tests
npm run test:e2e  # E2E tests
npm run lint      # Linting
```

## Environment Variables
See `.env.example` for required variables
```

---

# 第5章: MCP設定と運用

## 5.1 スコープ戦略

| スコープ | 保存場所 | 用途 | Git管理 |
|----------|----------|------|---------|
| user | ~/.claude.json | 常用MCP（軽量・汎用） | No |
| project | .mcp.json | プロジェクト固有 | Yes |
| local | .claude/settings.local.json | 実験用 | No |

## 5.2 トークンコスト一覧

**重要**: MCPは未使用でもトークンを消費する

| MCP構成 | トークン消費 | コンテキスト占有率(200k) |
|---------|-------------|------------------------|
| MCP無し | 0 | 0% |
| 3サーバー（軽量） | 約15k-25k | 7.5%-12.5% |
| 5サーバー（標準） | 約40k-55k | 20%-27.5% |
| 10サーバー以上 | 67k-100k+ | 33%-50%+ |

### 個別サーバートークン消費

| MCP Server | ツール数 | 推定トークン |
|------------|---------|-------------|
| Context7 | 2 | 約3k |
| Sequential Thinking | 1 | 約2k |
| GitHub | 27 | 約18k |
| PostgreSQL | 8 | 約8k |
| Puppeteer | 13 | 約13k |
| Playwright | 21 | 約14k |

## 5.3 推奨MCP構成

### Tier 1: 必須級（全プロジェクト）

```json
// ~/.claude.json (user scope)
{
  "mcpServers": {
    "context7": {
      "type": "stdio",
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

### Tier 2: プロジェクトタイプ別

```json
// .mcp.json (project scope) - Web Frontend
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

```json
// .mcp.json (project scope) - API Backend
{
  "mcpServers": {
    "postgresql": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL:-postgresql://localhost:5432/dev}"
      }
    }
  }
}
```

### Tier 3: オプション

```json
// Remote MCP（OAuth対応）
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.dev/mcp"
    }
  }
}
```

## 5.4 環境変数管理

### ファイル: `.env.mcp`（.gitignoreに追加）

```bash
# MCP Configuration Environment Variables

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb

# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# Search APIs
PERPLEXITY_API_KEY=pplx_xxxxxxxxxxxxxxxxxxxx
BRAVE_API_KEY=BSA_xxxxxxxxxxxxxxxxxxxx

# Cloud Providers
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

## 5.5 MCPコマンド一覧

```bash
# 追加
claude mcp add <name> -- <command>
claude mcp add <name> -s user -- <command>
claude mcp add --transport http <name> <url>

# 管理
claude mcp list
claude mcp get <name>
claude mcp remove <name>

# セッション中
/mcp                    # 接続状態確認
@<server> disable       # 一時無効化
@<server> enable        # 再有効化
/context               # トークン使用量確認

# デバッグ
claude --mcp-debug
npx @modelcontextprotocol/inspector
```

---

# 第6章: Skills設定

## 6.1 Skillsの構造

```
my-skill/
├── SKILL.md          # 必須: 指示とメタデータ
├── reference.md      # オプション: 詳細リファレンス
├── examples.md       # オプション: 例集
├── scripts/          # オプション: 実行可能コード
│   └── helper.py
└── templates/        # オプション: テンプレート
    └── output.xlsx
```

## 6.2 SKILL.mdフォーマット

```yaml
---
name: my-skill-name
description: このSkillが何をするか、いつ使うかの説明
---

# My Skill Name

## Instructions
1. Step one
2. Step two
3. Step three

## Output Format
- Format specification here

## Examples
- Example 1
- Example 2

## Guidelines
- Guideline 1
- Guideline 2
```

## 6.3 公式Skills一覧

### Document Skills（プリインストール済み）

| Skill | 機能 |
|-------|------|
| docx | Word文書の作成・編集・分析 |
| pdf | PDF操作ツールキット |
| pptx | PowerPointプレゼンテーション |
| xlsx | Excelスプレッドシート |

### Example Skills

| Skill | 説明 |
|-------|------|
| algorithmic-art | p5.jsでジェネレーティブアート作成 |
| artifacts-builder | React + Tailwind + shadcn/ui |
| mcp-server | MCPサーバー作成ガイド |
| brand-guidelines | ブランドカラー・タイポグラフィ適用 |
| skill-creator | 新規Skill作成ガイド |

## 6.4 Skillsインストール

```bash
# マーケットプレイス追加
/plugin marketplace add anthropics/skills

# インストール
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills

# 確認
/plugins

# 再読み込み
/reload-skills
```

## 6.5 カスタムSkill作成

### ステップ

1. `.claude/skills/my-skill/` ディレクトリ作成
2. `SKILL.md` に name, description, instructions を記述
3. （オプション）テンプレート、スクリプト追加
4. テストと改善

### ベストプラクティス

| 項目 | 推奨 |
|------|------|
| 長さ | 成熟版: 150-400行、初期: 100行未満 |
| description | 実際に使う言い回しを含める |
| 出力仕様 | カラム名、ファイル名を具体的に |
| スコープ | 広すぎたら分割 |

---

# 第7章: タスク管理ワークフロー

## 7.1 2段構成エージェント

| エージェント | 役割 | 実行タイミング |
|-------------|------|---------------|
| Initializer Agent | 環境セットアップ、タスクリスト作成 | 初回セッション |
| Coding Agent | インクリメンタル実装、進捗更新 | 2回目以降 |

## 7.2 タスク分割原則

### 複雑度に応じた階層

```
Epic: User Authentication (huge)
├── Task 1: Database schema (medium) 
├── Task 2: API endpoints (large)
│   ├── Subtask 2.1: Login endpoint
│   ├── Subtask 2.2: Register endpoint
│   └── Subtask 2.3: Token refresh
├── Task 3: Frontend forms (large)
│   ├── Subtask 3.1: Login form
│   └── Subtask 3.2: Register form
└── Task 4: Integration tests (medium)
```

### コア原則

- 各タスクは1セッションで完了可能（コンテキスト50%未満）
- 大きすぎたら分割
- 明確な受け入れ基準を持つ
- 依存関係を事前に特定

## 7.3 tasks.json仕様

```json
{
  "project": "my-project",
  "version": "1.0.0",
  "updated": "2025-12-01T10:00:00Z",
  "tasks": [
    {
      "id": 1,
      "title": "Database schema design",
      "description": "Create initial database schema for user management",
      "status": "completed",
      "type": "medium",
      "dependencies": [],
      "acceptance_criteria": [
        "Schema supports user, role, permission tables",
        "Migration scripts created",
        "Seed data available"
      ],
      "completed_at": "2025-12-01T09:00:00Z"
    },
    {
      "id": 2,
      "title": "API endpoints",
      "status": "in_progress",
      "type": "large",
      "dependencies": [1],
      "subtasks": [
        { "id": "2.1", "title": "Login endpoint", "status": "completed" },
        { "id": "2.2", "title": "Register endpoint", "status": "in_progress" },
        { "id": "2.3", "title": "Token refresh", "status": "pending" }
      ]
    }
  ]
}
```

## 7.4 progress.md仕様

```markdown
# Progress Log

## Current Session: 2025-12-01

### Completed
- [x] Task 1: Database schema design
- [x] Subtask 2.1: Login endpoint

### In Progress
- [ ] Subtask 2.2: Register endpoint
  - Implemented basic route
  - TODO: Add validation

### Blocked
- None

### Notes for Next Session
- Complete register endpoint validation
- Start token refresh implementation
- Review error handling patterns

### Context Usage
- Session start: 15%
- Session end: 45%
```

---

# 第8章: Hooksと品質ゲート

## 8.1 利用可能なHookポイント

| Hook | タイミング | 用途 |
|------|-----------|------|
| PreToolUse | ツール実行前 | 確認、バリデーション |
| PostToolUse | ツール実行後 | フォーマット、リント |
| Notification | 通知時 | カスタム通知処理 |

## 8.2 Hooks設定

### ファイル: `~/.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Bash(git *)",
      "Bash(npm run *)",
      "Bash(npx *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Write(./production.config.*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "python -m black $file"
          },
          {
            "type": "command",
            "command": "python -m ruff check $file"
          }
        ]
      },
      {
        "matcher": "Write(*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $file"
          },
          {
            "type": "command",
            "command": "npx tsc --noEmit"
          }
        ]
      },
      {
        "matcher": "Write(*.tsx)",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $file"
          },
          {
            "type": "command",
            "command": "npx eslint $file --fix"
          }
        ]
      }
    ]
  }
}
```

### ファイル: `.claude/settings.json`（プロジェクト）

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(rm -rf *)",
        "hooks": [
          {
            "type": "block",
            "message": "Dangerous operation blocked"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write(src/**/*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix"
          }
        ]
      }
    ]
  }
}
```

## 8.3 品質ゲート実装

### 必須チェック項目

| チェック | 実装方法 |
|----------|---------|
| E2Eテスト必須 | complete-task.md で強制 |
| コミット必須 | セッション終了時チェック |
| コンテキスト監視 | 50%警告、70%チェックポイント |
| リント通過 | PostToolUse Hookで自動実行 |

---

# 第9章: カスタムコマンド

## 9.1 コマンド構造

```markdown
---
description: Command description (shows in /help)
---

# Command Title

[Instructions for Claude to follow]
```

## 9.2 必須コマンド

### ファイル: `~/.claude/commands/checkpoint.md`

```markdown
---
description: Create a checkpoint for session handoff
---

# Checkpoint

## Save Current State
1. Git add all changes
2. Git commit with message: "checkpoint: [current work description]"

## Document Progress
3. Update `progress.md` with:
   - Work completed this session
   - Current state of in-progress task
   - Remaining work
   - Any blockers or issues
   - Notes for next session

## Report
4. Show current context usage percentage
5. Summarize what the next session should do first
```

### ファイル: `.claude/commands/start-task.md`

```markdown
---
description: Start working on a new task
---

# Start Task: $ARGUMENTS

1. Read `progress.md` to understand current state
2. Read `tasks.json` to find the specified task
3. If task has dependencies, verify they are complete
4. Enter Plan Mode and create implementation plan
5. **Present plan and wait for approval**
6. Do NOT start coding until approved
```

### ファイル: `.claude/commands/complete-task.md`

```markdown
---
description: Complete current task with proper verification
---

# Complete Task: $ARGUMENTS

## Pre-completion Checklist
1. Run all relevant tests
2. Verify no console errors
3. Check for any TODO comments left behind

## Completion Steps
4. Update `tasks.json` - set status to "completed"
5. Git add and commit with descriptive message
6. Update `progress.md` with:
   - What was completed
   - Any notes for future reference
7. Suggest next task based on dependencies
```

### ファイル: `.claude/commands/review.md`

```markdown
---
description: Review code changes before commit
---

# Code Review

## Analysis
1. Run `git diff` to see all changes
2. Check for:
   - Code style consistency
   - Potential bugs
   - Missing error handling
   - Security concerns
   - Performance issues

## Report Format
Provide feedback in this structure:

### Summary
[Brief overview of changes]

### Issues Found
- [Issue 1]: [Description] - [Severity: High/Medium/Low]
- [Issue 2]: ...

### Suggestions
- [Improvement idea 1]
- [Improvement idea 2]

### Verdict
[APPROVED / NEEDS CHANGES / BLOCKED]
```

---

# 第10章: Issue管理と継続的改善

## 10.1 概要

プロジェクト横断でIssueを蓄積し、CLAUDE.mdを継続的に改善するシステムです。

### 改善サイクル

```
セッション中 → /log-issue で問題記録
    ↓
セッション終了 → /retrospective で振り返り
    ↓
プロジェクト終了 → /sync-issues-to-global で蓄積
    ↓
定期メンテナンス → /upgrade-global で設定改善
    ↓
効果検証 → /verify-upgrade で確認
```

## 10.2 Issue管理ファイル

### グローバルIssue（~/.claude/issues.json）

```json
{
  "version": "1.0.0",
  "created": "2025-12-01T10:00:00Z",
  "updated": "2025-12-01T15:00:00Z",
  "statistics": {
    "total_issues": 5,
    "resolved": 3,
    "pending": 2,
    "wontfix": 0
  },
  "issues": [
    {
      "id": "G-001",
      "title": "テスト未実行でコミット",
      "category": "quality-gate",
      "severity": "high",
      "status": "resolved",
      "occurrences": [
        {"project": "project-a", "date": "2025-12-01"},
        {"project": "project-b", "date": "2025-12-02"}
      ],
      "resolution": {
        "type": "claude_md_update",
        "file": "~/.claude/docs/quality-gates.md",
        "change": "YOU MUST run tests before completion追加",
        "applied_at": "2025-12-02T10:00:00Z"
      },
      "effectiveness": {
        "measured_at": "2025-12-05T10:00:00Z",
        "recurrence": false,
        "verdict": "effective"
      }
    }
  ],
  "patterns": [
    {
      "id": "P-001",
      "name": "Test Skipping Pattern",
      "related_issues": ["G-001", "G-003"],
      "frequency": "weekly"
    }
  ]
}
```

### プロジェクトIssue（./issues.json）

```json
{
  "project": "my-project",
  "created": "2025-12-01T10:00:00Z",
  "updated": "2025-12-01T15:00:00Z",
  "issues": [
    {
      "id": "P-001",
      "title": "テスト未実行でコミット",
      "category": "quality-gate",
      "severity": "high",
      "status": "logged",
      "session": "2025-12-01-session-2",
      "context": "Task 3実装中にテストを実行せずにコミット",
      "impact": "バグがマージされた",
      "root_cause": "pre-commitワークフローにテスト必須の指示がない",
      "suggested_fix": "complete-taskにテスト必須ステップを追加",
      "global_relevance": true,
      "synced_to_global": false,
      "logged_at": "2025-12-01T14:30:00Z"
    }
  ]
}
```

## 10.3 Issue管理コマンド

### /log-issue - Issue記録

```markdown
---
description: Log an issue during work
---

# Log Issue: $ARGUMENTS

1. Analyze the issue and classify:
   - Category: quality-gate, context-management, workflow, code-standard, communication
   - Severity: critical, high, medium, low
   - Global relevance: true/false

2. Create issue entry in issues.json

3. Prompt for immediate action:
   - Continue work
   - Fix now
   - Add to CLAUDE.md
   - Block current task
```

### /retrospective - セッション振り返り

```markdown
---
description: End-of-session review
---

# Session Retrospective

1. Gather session data (git log, progress.md, issues.json)

2. Analyze against checklist:
   - CLAUDE.md compliance
   - Quality gate adherence
   - Workflow steps followed
   - Communication effectiveness

3. Detect unlogged issues

4. Present findings and confirm which to log

5. Update progress.md with retrospective summary
```

### /sync-issues-to-global - グローバル同期

```markdown
---
description: Sync project issues to global tracker
---

# Sync Issues to Global

1. Filter: global_relevance: true, synced_to_global: false

2. Match against existing global issues

3. For matches: Add occurrence
   For new: Create global issue

4. Detect patterns (3+ issues with same category)

5. Mark project issues as synced
```

### /upgrade-global - 設定アップグレード

```markdown
---
description: Upgrade global configuration based on issues
---

# Upgrade Global Configuration

1. Load global issues (pending, high/critical priority)

2. Generate improvement proposals:
   - CLAUDE.md updates (new rules, stronger keywords)
   - Hook additions (automated enforcement)
   - Structural changes (new commands, workflows)

3. Present proposals with priority ranking

4. Apply approved changes

5. Log to upgrade-log.md
```

### /verify-upgrade - 効果検証

```markdown
---
description: Verify effectiveness of upgrades
---

# Verify Upgrade Effectiveness

1. Find recently resolved issues (within 2 weeks)

2. Check for recurrence in global/project issues

3. Evaluate: Effective / Partially Effective / Ineffective

4. Update issue records with verdict

5. Recommend escalation for ineffective fixes
```

## 10.4 アップグレードログ

### ファイル: ~/.claude/upgrade-log.md

```markdown
# CLAUDE.md Upgrade Log

## Upgrade: 2025-12-02

### Trigger
- Pending issues: 5
- Command: /upgrade-global

### Changes Applied
1. **G-001**: テスト未実行でコミット
   - File: ~/.claude/docs/quality-gates.md
   - Type: claude_md_update
   - Change: "YOU MUST run tests before completion" 追加

### Skipped
- G-003: Deferred to next cycle

### Effectiveness Tracking
Monitor in next 5 sessions:
- G-001: Should see no commits without tests

---
```

## 10.5 Issue分類

| カテゴリ | 説明 | 例 |
|----------|------|-----|
| quality-gate | テスト・検証の問題 | テスト未実行でコミット |
| context-management | コンテキスト管理 | コンテキストオーバーフロー |
| workflow | プロセス・手順 | Plan Mode未使用 |
| code-standard | コーディング規約 | 命名規則違反 |
| communication | 確認・報告 | 承認なしで実装開始 |
| mcp | MCP設定・使用 | MCP接続エラー |
| permission | セキュリティ・アクセス | 機密ファイル読み取り |

## 10.6 重要度判定

| 重要度 | 基準 | 対応 |
|--------|------|------|
| critical | データ損失、セキュリティリスク | 即時対応必須 |
| high | 効率・品質に大きな影響 | 次回アップグレードで対応 |
| medium | 改善が望ましい | 余裕があれば対応 |
| low | 軽微な不便 | 蓄積後に検討 |

---

# 第11章: セットアップ手順

## 11.1 事前準備

### 必要なツール

```bash
# Node.js 18+
node --version  # v18.0.0以上

# Git
git --version

# Claude Code
claude --version
```

### 環境変数の準備

```bash
# ~/.bashrc または ~/.zshrc に追加
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export DATABASE_URL="postgresql://user:pass@localhost:5432/dev"
```

## 11.2 グローバル設定セットアップ

### Step 1: ディレクトリ作成

```bash
# グローバル設定ディレクトリ
mkdir -p ~/.claude/docs
mkdir -p ~/.claude/commands
```

### Step 2: グローバルCLAUDE.md作成

```bash
cat > ~/.claude/CLAUDE.md << 'EOF'
# Global Instructions for Claude Code

## Behavior Principles
@~/.claude/docs/behavior-principles.md

## Task Management Workflow
@~/.claude/docs/task-workflow.md

## Code Standards
@~/.claude/docs/code-standards.md

## Quality Gates
@~/.claude/docs/quality-gates.md

---

## Quick Reference

### Session Start Checklist
1. `pwd` → `git log --oneline -5` → `cat progress.md`
2. Select ONE pending task
3. Enter Plan Mode (Shift+Tab×2)
4. **Wait for human approval before coding**

### Session End Checklist
1. Run all tests
2. `git add . && git commit -m "feat: [description]"`
3. Update progress.md
4. Report context usage %

### Critical Rules
- **IMPORTANT**: Never declare completion without E2E testing
- **YOU MUST**: Commit all changes before session end
- **IMPORTANT**: Ask clarifying questions rather than assume
EOF
```

### Step 3: User scope MCP設定

```bash
cat > ~/.claude.json << 'EOF'
{
  "mcpServers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
EOF
```

### Step 4: グローバルHooks設定

```bash
cat > ~/.claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Bash(git *)",
      "Bash(npm run *)",
      "Bash(npx *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
EOF
```

### Step 5: 詳細ドキュメント配置

```bash
# behavior-principles.md, task-workflow.md, quality-gates.md, code-standards.md
# を ~/.claude/docs/ に配置（本ドキュメント第4章参照）
```

## 11.3 プロジェクト設定セットアップ

### Step 1: ディレクトリ作成

```bash
cd /path/to/project

mkdir -p .claude/commands
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p docs
```

### Step 2: プロジェクトCLAUDE.md作成

```bash
cat > CLAUDE.md << 'EOF'
# Project: [Project Name]

## Overview
[Brief project description]

## Tech Stack
- Frontend: 
- Backend: 
- Database: 
- Cloud: 

## Project-Specific Rules
@./docs/architecture.md

## MCP Usage Guidelines
| MCP Server | Purpose | When to Use |
|------------|---------|-------------|
| context7 | Library docs | Before using new library |

## Testing Commands
```bash
npm test          # Unit tests
npm run test:e2e  # E2E tests
```
EOF
```

### Step 3: Project scope MCP設定

```bash
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "postgresql": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL:-postgresql://localhost:5432/dev}"
      }
    }
  }
}
EOF
```

### Step 4: タスク管理ファイル初期化

```bash
cat > tasks.json << 'EOF'
{
  "project": "project-name",
  "version": "1.0.0",
  "updated": "",
  "tasks": []
}
EOF

cat > progress.md << 'EOF'
# Progress Log

## Current Session

### Completed
- None yet

### In Progress
- Initial setup

### Notes for Next Session
- 
EOF
```

### Step 5: カスタムコマンド配置

```bash
# start-task.md, complete-task.md を .claude/commands/ に配置
```

### Step 6: .gitignore更新

```bash
cat >> .gitignore << 'EOF'

# Claude Code
.claude/settings.local.json
.env.mcp
EOF
```

## 11.4 動作確認

```bash
# Claude Code起動
claude

# コンテキスト確認
/context

# MCP接続確認
/mcp

# カスタムコマンド確認
/help
```

---

# 第12章: 運用ガイドライン

## 12.1 日常運用

### セッション開始ルーチン

```
1. claude 起動
2. pwd で作業ディレクトリ確認
3. git log --oneline -5 で最近の変更確認
4. cat progress.md で進捗確認
5. 1つのタスクを選択
6. Plan Mode で計画作成
7. 承認を得てから実装開始
```

### セッション終了ルーチン

```
1. テスト実行・確認
2. git add . && git commit
3. progress.md 更新
4. /context でコンテキスト使用率確認
5. 次セッションへの引き継ぎ事項記録
```

## 12.2 トラブルシューティング

### 問題: CLAUDE.mdが読み込まれない

**解決策:**
1. ファイル名が正確か確認（大文字小文字）
2. `/context` で読み込み状況を確認
3. 構文エラーがないか確認

### 問題: @importが機能しない

**解決策:**
1. パスが正しいか確認
2. 絶対パスで試す
3. 最大5階層までの制限を確認

### 問題: MCPが接続できない

**解決策:**
1. `claude --mcp-debug` でデバッグ
2. Node.jsバージョン確認（18+必須）
3. 環境変数が設定されているか確認
4. `/mcp` で再認証

### 問題: コンテキストがすぐ消費される

**解決策:**
1. CLAUDE.mdをモジュラー化
2. 不要なMCPを無効化 `@server disable`
3. `/clear` でタスク間をクリア
4. `/compact` で圧縮

### 問題: 完了偽装が発生する

**解決策:**
1. quality-gates.mdの内容を強化
2. 「IMPORTANT」「YOU MUST」を追加
3. テスト実行をHooksで強制

## 12.3 CLAUDE.md育成サイクル

```
問題発生
    ↓
原因分析
    ↓
CLAUDE.md/docs更新
    ↓
効果確認
    ↓
改善ログに記録
```

### 改善ログテンプレート

```markdown
## Improvement Log

### 2025-12-01
**Issue**: Agent declared completion without running tests
**Root Cause**: Quality gate instruction not strong enough
**Solution**: Added "YOU MUST run tests before completion" to quality-gates.md
**Result**: Compliance improved
```

---

# 付録

## A. ファイル一覧

| ファイル | パス | 用途 |
|----------|------|------|
| CLAUDE.md | ~/.claude/ | グローバル指示 |
| CLAUDE.md | ./ | プロジェクト指示 |
| .claude.json | ~/ | User scope MCP |
| .mcp.json | ./ | Project scope MCP |
| settings.json | ~/.claude/ | グローバルHooks |
| settings.json | .claude/ | プロジェクトHooks |
| tasks.json | ./ | タスク状態 |
| progress.md | ./ | 進捗メモ |
| *.md | ~/.claude/docs/ | 詳細ドキュメント |
| *.md | .claude/commands/ | カスタムコマンド |

## B. コマンドクイックリファレンス

```bash
# セッション管理
/context          # コンテキスト使用量
/clear            # コンテキストクリア
/compact          # コンテキスト圧縮

# MCP管理
/mcp              # MCP接続状態
claude mcp add    # MCP追加
claude mcp remove # MCP削除
@server disable   # 一時無効化
@server enable    # 再有効化

# モード切替
Shift+Tab×2       # Plan Mode切替

# デバッグ
claude --mcp-debug
/hooks            # Hooks確認

# Skills
/plugins          # プラグイン一覧
/reload-skills    # Skill再読み込み
```

## C. トークン予算ガイドライン

| コンポーネント | 推奨上限 | 備考 |
|---------------|---------|------|
| CLAUDE.md | 5k | @importで分割 |
| MCP | 50k | 使用分のみ有効化 |
| Skills | 動的 | タスクマッチ時のみ |
| タスク実行 | 残り | 50%で警告 |

## D. 用語集

| 用語 | 説明 |
|------|------|
| CLAUDE.md | 自動読み込みされる設定/指示ファイル |
| MCP | Model Context Protocol - 外部ツール連携 |
| Skill | タスクマッチで自動起動する機能 |
| Plan Mode | 読み取り専用の計画モード |
| Hooks | ツール使用時に自動実行されるスクリプト |
| Compaction | コンテキストの圧縮・要約 |
| Subagent | 特定タスクに特化した子エージェント |
| Progressive Disclosure | 段階的に情報をロードする設計 |

## E. 参考リソース

| リソース | URL |
|----------|-----|
| Anthropic - Long-running agents | https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents |
| Claude Code Best Practices | https://www.anthropic.com/engineering/claude-code-best-practices |
| Claude Code Docs | https://docs.claude.com/en/docs/claude-code |
| MCP公式 | https://modelcontextprotocol.io/ |
| Skills GitHub | https://github.com/anthropics/skills |
| Awesome MCP Servers | https://github.com/wong2/awesome-mcp-servers |

---

## 更新履歴

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-01 | 初版作成 |
| 1.1 | 2025-12-02 | 第10章: Issue管理と継続的改善を追加 |

---

*本ドキュメントはClaude Code v2.0+を対象としています。*
