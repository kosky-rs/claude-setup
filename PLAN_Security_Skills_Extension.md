# 拡張機能プラン: セキュリティ・ガードレール & 領域別Skills

## 概要

現在のセットアップパッケージに、セキュリティ強化機能と領域別Skillsを追加する計画。

**原則:** Shell実行で自動インストールされるものと、参考情報として提供するものを明確に分離。

---

## 構成の分類

### A. Shell実行で自動インストール（Core）

セットアップスクリプト実行時に自動的に配置されるファイル。
すぐに使える状態で提供。

### B. オプション機能（Optional）

ユーザーが必要に応じて手動で有効化する機能。
セットアップ時に案内のみ表示。

### C. 参考ドキュメント（Reference）

実装ファイルではなく、カスタマイズや拡張のための参考情報。
リポジトリのdocs/に配置、Shellではインストールしない。

---

## 詳細設計

### A. Core（自動インストール）

#### A-1. セキュリティ強化（settings.json拡張）

**変更対象:** `templates/global/settings.json`

```json
{
  "permissions": {
    "deny": [
      // 既存に追加
      "Read(**/*.pem)",
      "Read(**/*secret*)",
      "Read(**/.aws/*)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Bash(* > /dev/sd*)",
      "Bash(dd if=*)"
    ]
  }
}
```

**理由:** 基本的なセキュリティは全ユーザーに適用すべき

#### A-2. /security-review コマンド

**新規ファイル:** `templates/global/commands/security-review.md`

既存の`/review`を補完するセキュリティ特化版。
- シークレット検出
- 依存関係脆弱性チェック
- 入力バリデーション確認

**理由:** コミット前のセキュリティチェックは基本機能

#### A-3. 監査ログ（軽量版）

**変更対象:** `templates/global/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.env*)|Write(*secret*)|Bash(git push*)",
        "hooks": [{
          "type": "command",
          "command": "echo \"$(date +%Y-%m-%d_%H:%M:%S)|$TOOL_NAME\" >> ~/.claude/security-audit.log"
        }]
      }
    ]
  }
}
```

**理由:** 重要操作のみログ、トークン消費なし

---

### B. Optional（手動有効化）

#### B-1. サンドボックスプロファイル

**配置先:** `templates/global/optional/sandbox-profiles/`

```
sandbox-profiles/
├── README.md           # 使い方説明
├── strict.json         # 本番作業用（確認多め）
├── standard.json       # 通常開発用（デフォルト）
└── permissive.json     # 実験用（制限緩め）
```

**有効化方法:**
```bash
cp ~/.claude/optional/sandbox-profiles/strict.json ~/.claude/settings.json
```

**理由:** 作業内容により必要なセキュリティレベルが異なる

#### B-2. 領域別Skills

**配置先:** `templates/global/optional/skills/`

```
skills/
├── README.md           # Skills概要と使い方
├── backend/
│   └── SKILL.md        # バックエンド開発ガイド
├── frontend/
│   └── SKILL.md        # フロントエンド開発ガイド
└── design-strategy/
    └── SKILL.md        # 設計・アーキテクチャガイド
```

**有効化方法:**
```bash
# 必要なSkillのみコピー
cp -r ~/.claude/optional/skills/backend ~/.claude/skills/
```

**CLAUDE.mdに追記:**
```markdown
## Skills
@~/.claude/skills/backend/SKILL.md
```

**理由:**
- 全員がすべてのSkillを必要とするわけではない
- 不要なSkillはコンテキストの無駄
- ユーザーが選択的に有効化

#### B-3. 追加セキュリティコマンド

**配置先:** `templates/global/optional/commands/`

```
commands/
├── sandbox.md          # プロファイル切り替え
└── permission.md       # パーミッション確認
```

**有効化方法:**
```bash
cp ~/.claude/optional/commands/sandbox.md ~/.claude/commands/
```

---

### C. Reference（参考ドキュメント）

**配置先:** リポジトリの`docs/advanced/`（Shellではインストールしない）

```
docs/advanced/
├── security-architecture.md      # 多層防御の設計思想
├── skill-development-guide.md    # カスタムSkill作成ガイド
├── team-security-setup.md        # チーム向けセキュリティ設定
├── audit-integration.md          # 外部監査ツール連携
└── examples/
    ├── enterprise-settings.json  # 大規模組織向け設定例
    ├── startup-settings.json     # スタートアップ向け設定例
    └── custom-skill-example.md   # カスタムSkill例
```

**理由:**
- 高度なカスタマイズは参考情報として提供
- 実装の選択肢を示すが、強制しない
- ユーザーが自分の環境に合わせて調整

---

## ファイル構成（実装後）

### templates/global/（セットアップ対象）

```
templates/global/
├── CLAUDE.md                    # 既存
├── settings.json                # 拡張（セキュリティ強化）
├── claude.json                  # 既存
├── issues.json                  # 既存
├── upgrade-log.md               # 既存
├── docs/                        # 既存
├── commands/
│   ├── checkpoint.md            # 既存
│   ├── review.md                # 既存
│   ├── upgrade-global.md        # 既存
│   ├── verify-upgrade.md        # 既存
│   └── security-review.md       # 新規（Core）
└── optional/                    # 新規ディレクトリ
    ├── README.md                # オプション機能の説明
    ├── sandbox-profiles/
    │   ├── README.md
    │   ├── strict.json
    │   ├── standard.json
    │   └── permissive.json
    ├── skills/
    │   ├── README.md
    │   ├── backend/
    │   │   └── SKILL.md
    │   ├── frontend/
    │   │   └── SKILL.md
    │   └── design-strategy/
    │       └── SKILL.md
    └── commands/
        ├── sandbox.md
        └── permission.md
```

### docs/advanced/（リポジトリのみ）

```
docs/advanced/
├── security-architecture.md
├── skill-development-guide.md
├── team-security-setup.md
├── audit-integration.md
└── examples/
    ├── enterprise-settings.json
    ├── startup-settings.json
    └── custom-skill-example.md
```

---

## setup-global.sh の変更

### 追加処理

```bash
# Optionalディレクトリをコピー
echo "Copying optional features..."
cp -r "${TEMPLATE_DIR}/optional" ~/.claude/optional

echo -e "${GREEN}✓ Optional features available${NC}"
```

### 完了メッセージに追加

```bash
echo ""
echo -e "${BOLD}${CYAN}📦 OPTIONAL FEATURES:${NC}"
echo ""
echo "以下の機能は手動で有効化できます："
echo ""
echo "  サンドボックスプロファイル:"
echo "    ls ~/.claude/optional/sandbox-profiles/"
echo "    cp ~/.claude/optional/sandbox-profiles/strict.json ~/.claude/settings.json"
echo ""
echo "  領域別Skills:"
echo "    ls ~/.claude/optional/skills/"
echo "    cp -r ~/.claude/optional/skills/backend ~/.claude/skills/"
echo "    # CLAUDE.mdに @~/.claude/skills/backend/SKILL.md を追加"
echo ""
echo "  詳細: cat ~/.claude/optional/README.md"
```

---

## 実装タスク

### Phase 1: Core機能

| タスク | ファイル | 優先度 |
|-------|---------|--------|
| settings.json セキュリティ拡張 | templates/global/settings.json | 高 |
| /security-review コマンド作成 | templates/global/commands/security-review.md | 高 |
| 監査ログHook追加 | templates/global/settings.json | 中 |

### Phase 2: Optional機能

| タスク | ファイル | 優先度 |
|-------|---------|--------|
| optional/README.md 作成 | templates/global/optional/README.md | 高 |
| サンドボックスプロファイル作成 | templates/global/optional/sandbox-profiles/ | 中 |
| backend SKILL.md 作成 | templates/global/optional/skills/backend/ | 中 |
| frontend SKILL.md 作成 | templates/global/optional/skills/frontend/ | 低 |
| design-strategy SKILL.md 作成 | templates/global/optional/skills/design-strategy/ | 低 |
| 追加コマンド作成 | templates/global/optional/commands/ | 低 |

### Phase 3: Reference

| タスク | ファイル | 優先度 |
|-------|---------|--------|
| セキュリティアーキテクチャ文書 | docs/advanced/security-architecture.md | 低 |
| Skill開発ガイド | docs/advanced/skill-development-guide.md | 低 |
| 設定例 | docs/advanced/examples/ | 低 |

### Phase 4: 統合

| タスク | ファイル | 優先度 |
|-------|---------|--------|
| setup-global.sh 更新 | setup-global.sh | 高 |
| README.md 更新 | README.md | 中 |
| Feature_Reference.md 更新 | Feature_Reference.md | 中 |

---

## 確認事項

1. **Skillsの優先順位**
   - backend, frontend, design-strategy の3つで良いか？
   - infrastructure, data は後回しで良いか？

2. **サンドボックスプロファイル**
   - strict/standard/permissive の3段階で良いか？
   - 具体的な制限内容の調整

3. **参考ドキュメント**
   - docs/advanced/ の内容は今回のスコープに含めるか？
   - 後回しにするか？

4. **Phase分け**
   - Phase 1（Core）のみ先行実装するか？
   - Phase 1-2 まで一気に実装するか？

---

## 次のステップ

承認後、以下の順序で実装：

1. Phase 1: Core機能の実装
2. Phase 2: Optional機能の実装
3. setup-global.sh の更新
4. ドキュメント更新
5. テスト実行
6. コミット・プッシュ

---

Created: 2025-12-03
Status: Planning（承認待ち）
