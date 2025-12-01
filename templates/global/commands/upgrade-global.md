---
description: Analyze global issues and upgrade CLAUDE.md/settings - run periodically to improve configuration
---

# Upgrade Global Configuration

## 1. Load Global Issues

```bash
echo "=== Global Issues ==="
cat ~/.claude/issues.json

echo ""
echo "=== Recent Upgrades ==="
tail -50 ~/.claude/upgrade-log.md
```

## 2. Analyze Pending Issues

### Priority Classification

**🔴 Critical/High (Address Now)**
- Filter: `status: "pending"` AND (`severity: "critical"` OR `severity: "high"`)
- Sort by: occurrence count (most frequent first)

**🟡 Patterns (Systematic Issues)**
- Review `patterns` array
- Issues occurring 3+ times indicate systematic problems

**🟢 Medium (If Time Permits)**
- Filter: `status: "pending"` AND `severity: "medium"`

## 3. Generate Improvement Proposals

For each priority issue, create a proposal:

```markdown
---

### Proposal for G-XXX: [Issue Title]

**Priority**: 🔴 Critical / 🟠 High / 🟡 Medium
**Occurrences**: [N] times across [M] projects
**Pattern**: [Pattern name if part of a pattern]
**Category**: [category]

#### Root Cause Analysis
[Analyze why this keeps happening based on occurrences]

#### Current State
**File**: [relevant file, e.g., ~/.claude/docs/quality-gates.md]
**Current Instruction**:
```
[Quote current instruction if exists, or "None"]
```

#### Proposed Change

**Option A: CLAUDE.md Update**
```markdown
[New or updated instruction text]
```
- Keyword strength: [IMPORTANT / YOU MUST / NEVER / ALWAYS]
- Rationale: [Why this wording]

**Option B: Hook Enforcement** (if applicable)
```json
{
  "hooks": {
    "[HookType]": [
      {
        "matcher": "[pattern]",
        "hooks": [
          {
            "type": "command",
            "command": "[command]"
          }
        ]
      }
    ]
  }
}
```
- Rationale: [Why automation is better]

**Option C: New Command/Structure** (if applicable)
- Change: [Description of structural change]
- Rationale: [Why structure needs to change]

#### Recommendation
**Apply Option [A/B/C]** because [reason]

---
```

## 4. Present Proposals to Human

Display organized summary:

```markdown
## 🔧 Upgrade Proposals

### 🔴 Critical Priority
| # | Issue | Proposal | Est. Impact |
|---|-------|----------|-------------|
| 1 | G-XXX: [title] | [brief] | High |
| 2 | G-YYY: [title] | [brief] | High |

### 🟠 High Priority  
| # | Issue | Proposal | Est. Impact |
|---|-------|----------|-------------|
| 3 | G-ZZZ: [title] | [brief] | Medium |

### 🟡 Medium Priority (Optional)
| # | Issue | Proposal | Est. Impact |
|---|-------|----------|-------------|
| 4 | G-AAA: [title] | [brief] | Low |

---

**Quick Actions:**
- `all` - Apply all Critical + High priority
- `critical` - Apply only Critical priority
- `1,2,3` - Apply specific proposals by number
- `none` - Skip this upgrade cycle
- `details N` - Show full details for proposal N

Enter your choice:
```

## 5. Apply Approved Changes

For each approved proposal:

### For CLAUDE.md / docs/* Updates:
1. Read the target file
2. Locate the section to update
3. Apply the change (add new section or modify existing)
4. Verify the file is still valid markdown

### For settings.json Updates:
1. Read current ~/.claude/settings.json
2. Parse as JSON
3. Merge the new hook/permission configuration
4. Validate JSON structure
5. Write back

### For New Files:
1. Create file with proposed content
2. If needed, add @import reference to CLAUDE.md

## 6. Update Issue Status

For each applied change, update ~/.claude/issues.json:

```json
{
  "id": "G-XXX",
  "status": "resolved",
  "resolution": {
    "type": "claude_md_update",
    "file": "[affected file path]",
    "change": "[description of what was changed]",
    "applied_at": "[ISO timestamp]"
  },
  "effectiveness": {
    "measured_at": null,
    "recurrence": null,
    "sessions_since_fix": 0
  }
}
```

## 7. Log the Upgrade

Append to ~/.claude/upgrade-log.md:

```markdown
## Upgrade: [Current Date]

### Trigger
- Pending issues: [N]
- Command: /upgrade-global

### Changes Applied
1. **G-XXX**: [title]
   - File: [file]
   - Type: [claude_md_update | hook_addition | structural]
   - Change: [brief description]

2. **G-YYY**: [title]
   - File: [file]  
   - Type: [type]
   - Change: [brief description]

### Skipped
- G-ZZZ: [reason - e.g., "Deferred to next cycle"]

### Effectiveness Tracking
Monitor in next 5 sessions:
- G-XXX: Should see [expected behavior]
- G-YYY: Should see [expected behavior]

---
```

## 8. Summary and Next Steps

```markdown
## ✅ Upgrade Complete

### Applied
- [N] issues resolved
- [M] files modified

### Files Changed
- ~/.claude/docs/quality-gates.md
- ~/.claude/settings.json
- [other files]

### Next Steps
1. Run `/verify-upgrade` after 5 sessions to check effectiveness
2. If issues recur, they will be auto-escalated in severity

### Commands
- View changes: `git diff ~/.claude/`
- Undo last change: `git checkout ~/.claude/[file]`
- Verify later: `/verify-upgrade`
```

## Important Notes

- **NEVER** apply changes without explicit human approval
- **ALWAYS** show the exact change before applying
- **PRESERVE** existing content when adding new sections
- **VALIDATE** file syntax after modifications
- **LOG** all changes for future reference
