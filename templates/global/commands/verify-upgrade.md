---
description: Verify effectiveness of recent upgrades - run after 5+ sessions since last upgrade
---

# Verify Upgrade Effectiveness

## 1. Load Data

```bash
echo "=== Recent Upgrades ==="
tail -100 ~/.claude/upgrade-log.md

echo ""
echo "=== Current Issues ==="
cat ~/.claude/issues.json
```

## 2. Identify Issues to Verify

Find issues that were resolved recently:
- `status: "resolved"`
- `resolution.applied_at` within last 2 weeks
- `effectiveness.measured_at` is null OR older than `applied_at`

List them:

```markdown
## Issues Pending Verification

| ID | Title | Resolved | Sessions Since |
|----|-------|----------|----------------|
| G-XXX | [title] | [date] | [N] |
| G-YYY | [title] | [date] | [N] |
```

## 3. Gather Evidence for Each Issue

For each issue to verify:

### Search for Recurrence

```bash
# Check global issues for new occurrences
grep -A5 "[issue title keywords]" ~/.claude/issues.json

# Check recent project issues (if accessible)
find ~/projects -name "issues.json" -exec grep -l "[keywords]" {} \;
```

### Count Sessions
- Count entries in upgrade-log.md since resolution
- Check project progress.md files for session counts

### Analyze Patterns
- Was the root cause addressed?
- Are there similar issues appearing?

## 4. Evaluate Each Issue

For each verified issue:

```markdown
---

### Verification: G-XXX - [Title]

**Resolution Date**: [date]
**Sessions Since Fix**: [N]
**Minimum Required**: 5 sessions

#### Evidence Collected

**Recurrence Check**:
- [ ] Searched global issues.json: [Found/Not found]
- [ ] Searched recent project issues: [Found/Not found]
- [ ] Similar issues reported: [Yes/No]

**Behavioral Observation**:
- Expected: [What should happen now]
- Observed: [What actually happened - based on logs/issues]

#### Verdict

**Status**: [Choose one]

✅ **EFFECTIVE** - No recurrence, behavior changed as expected
- Evidence: [brief evidence]
- Action: Mark as verified, no further action

⚠️ **PARTIALLY EFFECTIVE** - Reduced frequency or severity
- Improvement: [what got better]
- Remaining gap: [what still happens]
- Action: Consider strengthening the fix

❌ **INEFFECTIVE** - Issue continues to occur
- Evidence: [recurrence details]
- Analysis: [why fix didn't work]
- Action: Escalate - needs stronger intervention

⏳ **INSUFFICIENT DATA** - Not enough sessions to evaluate
- Sessions needed: [N more]
- Action: Re-verify after more sessions

---
```

## 5. Update Issue Records

For each verified issue, update ~/.claude/issues.json:

### If Effective:
```json
{
  "id": "G-XXX",
  "effectiveness": {
    "measured_at": "[now]",
    "recurrence": false,
    "sessions_since_fix": [N],
    "verdict": "effective",
    "verified_by": "verify-upgrade command"
  }
}
```

### If Partially Effective:
```json
{
  "id": "G-XXX",
  "status": "pending",
  "effectiveness": {
    "measured_at": "[now]",
    "recurrence": true,
    "sessions_since_fix": [N],
    "verdict": "partial",
    "notes": "[what still needs improvement]"
  },
  "proposed_resolution": {
    "type": "escalation",
    "description": "[proposed stronger fix]"
  }
}
```

### If Ineffective:
```json
{
  "id": "G-XXX",
  "status": "pending",
  "severity": "[escalate: medium→high, high→critical]",
  "effectiveness": {
    "measured_at": "[now]",
    "recurrence": true,
    "sessions_since_fix": [N],
    "verdict": "ineffective",
    "failed_resolution": "[what was tried]"
  },
  "proposed_resolution": {
    "type": "escalation",
    "description": "[proposed alternative approach]"
  }
}
```

## 6. Generate Recommendations

For issues needing further action:

```markdown
## Recommended Escalations

### G-XXX: [Title] - INEFFECTIVE

**Previous Fix**: [what was tried]
**Why It Failed**: [analysis]

**Escalation Options**:

1. **Strengthen Keywords**
   - Current: "IMPORTANT: ..."
   - Proposed: "YOU MUST ... NEVER ..."

2. **Add Hook Enforcement**
   ```json
   {
     "PreToolUse": [{
       "matcher": "[pattern]",
       "hooks": [{"type": "block", "message": "[message]"}]
     }]
   }
   ```

3. **Structural Change**
   - Add mandatory command to workflow
   - Create pre-commit hook
   - Add to automated checklist

**Recommended**: Option [N] because [reason]
```

## 7. Summary Report

```markdown
## 📊 Verification Report: [Date]

### Overview
- Issues Verified: [N]
- Effective: [N] ✅
- Partial: [N] ⚠️
- Ineffective: [N] ❌
- Insufficient Data: [N] ⏳

### Fully Effective (Verified Complete)
| ID | Title | Sessions Tested |
|----|-------|-----------------|
| G-XXX | [title] | [N] |

### Needs Attention
| ID | Title | Verdict | Recommended Action |
|----|-------|---------|-------------------|
| G-YYY | [title] | Partial | Strengthen fix |
| G-ZZZ | [title] | Ineffective | Hook enforcement |

### Pending Re-verification
| ID | Title | Sessions Needed |
|----|-------|-----------------|
| G-AAA | [title] | [N] more |

### Next Steps
1. Run `/upgrade-global` to address ineffective issues
2. Re-run `/verify-upgrade` after [N] more sessions for pending items

### Improvement Trend
- Total issues ever: [N]
- Resolved & verified: [N] ([X]%)
- Average fix success rate: [X]%
```

## 8. Log Verification

Append to ~/.claude/upgrade-log.md:

```markdown
## Verification: [Date]

### Results
- Verified: [N] issues
- Effective: [N]
- Needs escalation: [N]

### Actions Taken
- G-XXX: Marked as verified effective
- G-YYY: Escalated severity to high
- G-ZZZ: Re-opened for alternative fix

---
```

## Notes

- Run this command at least 5 sessions after each upgrade
- Issues marked ineffective will appear with higher priority in next `/upgrade-global`
- Continuous improvement requires honest assessment - don't mark as effective if issues persist
