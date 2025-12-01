---
description: Log an issue that occurred during this session - use when problems are detected
---

# Log Issue: $ARGUMENTS

## 1. Gather Context

```bash
echo "=== Current Task ==="
cat tasks.json | head -50

echo ""
echo "=== Recent Git Activity ==="
git log --oneline -5

echo ""
echo "=== Current Progress ==="
tail -30 progress.md
```

## 2. Analyze the Issue

Based on $ARGUMENTS and context, determine:

### Issue Classification

**Category** (choose one):
- `quality-gate` - Test/verification problems
- `context-management` - Context overflow issues
- `workflow` - Process/procedure problems
- `code-standard` - Coding convention violations
- `communication` - Confirmation/reporting issues
- `mcp` - MCP configuration/usage problems
- `permission` - Security/access issues
- `other` - Doesn't fit above categories

**Severity** (choose one):
- `critical` - Data loss, security risk, blocks all work
- `high` - Significant impact on efficiency/quality
- `medium` - Notable issue, improvement needed
- `low` - Minor inconvenience

**Global Relevance**:
- `true` - Likely to occur in other projects
- `false` - Specific to this project's setup/context

## 3. Create Issue Entry

Generate the next issue ID:
```bash
# Count existing issues
cat issues.json | grep '"id":' | wc -l
# New ID = P-[count + 1], padded to 3 digits
```

Create issue object:

```json
{
  "id": "P-XXX",
  "title": "[Concise issue title from $ARGUMENTS]",
  "category": "[category]",
  "severity": "[severity]",
  "status": "logged",
  "session": "[YYYY-MM-DD-session-N]",
  "context": "[What was happening when issue occurred]",
  "impact": "[What was the effect of this issue]",
  "root_cause": "[Initial analysis of why this happened]",
  "suggested_fix": "[How to prevent this in future]",
  "global_relevance": [true/false],
  "synced_to_global": false,
  "logged_at": "[ISO timestamp]"
}
```

## 4. Update issues.json

Read current issues.json, append new issue, write back:

```bash
# Backup first
cp issues.json issues.json.bak
```

Add to `issues` array and update `updated` timestamp.

## 5. Add to Progress Log

Append to progress.md:

```markdown
### 🔴 Issue Logged: P-XXX

**Title**: [title]
**Category**: [category]
**Severity**: [severity]
**Context**: [brief context]
**Immediate Action**: [what was done now, if anything]
```

## 6. Prompt for Immediate Action

```markdown
## Issue P-XXX Logged

**Title**: [title]
**Severity**: [severity]
**Global Relevance**: [Yes/No]

### Options:
1. **Continue** - Proceed with current task, address issue later
2. **Fix Now** - Attempt to fix the root cause immediately
3. **Add to CLAUDE.md** - Add a rule to project CLAUDE.md now
4. **Block Task** - Mark current task as blocked by this issue

What would you like to do?
```

## 7. If "Add to CLAUDE.md" Selected

Propose a rule addition:

```markdown
### Proposed CLAUDE.md Addition

**Section**: [Relevant section, e.g., "## Quality Gates"]

**Rule**:
```markdown
### [Rule Title]
**[IMPORTANT/YOU MUST/NEVER]**: [Rule description based on issue]

Example of violation:
- [What happened]

Correct approach:
- [What should happen]
```

Apply this change? (y/n)
```

## Example Usage

**User**: `/log-issue Agent committed without running tests`

**Result**:
```json
{
  "id": "P-001",
  "title": "Committed without running tests",
  "category": "quality-gate",
  "severity": "high",
  "status": "logged",
  "session": "2025-12-01-session-2",
  "context": "During Task 3 implementation, committed changes directly without test execution",
  "impact": "Broken code merged, required hotfix",
  "root_cause": "No explicit test requirement in pre-commit workflow",
  "suggested_fix": "Add mandatory test step to complete-task command",
  "global_relevance": true,
  "synced_to_global": false,
  "logged_at": "2025-12-01T14:30:00Z"
}
```

## Notes

- Log issues as soon as they're noticed - don't wait until session end
- Be specific about context - vague issues are hard to fix
- Consider global relevance carefully - systematic issues should be synced
- Suggested fixes don't need to be perfect - they're starting points for analysis
