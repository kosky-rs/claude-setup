---
description: Sync project issues to global tracker - run at project end or periodically
---

# Sync Issues to Global

## 1. Load Data

```bash
echo "=== Project Issues ==="
cat ./issues.json

echo ""
echo "=== Global Issues ==="
cat ~/.claude/issues.json

echo ""
echo "=== Project Info ==="
basename $(pwd)
```

## 2. Identify Syncable Issues

Filter project issues:
- `global_relevance: true`
- `synced_to_global: false`

```markdown
## Issues to Sync

| ID | Title | Category | Severity | Occurrences Here |
|----|-------|----------|----------|------------------|
| P-XXX | [title] | [cat] | [sev] | [N] |
| P-YYY | [title] | [cat] | [sev] | [N] |

**Total**: [N] issues ready to sync
```

## 3. Match Against Global Issues

For each syncable issue:

### Search for Existing Match

Match criteria:
- Same `category`
- Similar `title` (fuzzy match on keywords)
- Similar `root_cause`

```markdown
### P-XXX: [Title]

**Searching global issues...**

**Match Found**: G-YYY - [Similar title]
- Category: [same/different]
- Similarity: [High/Medium/Low]
- Recommendation: [Add occurrence / Create new]

**OR**

**No Match Found**
- Recommendation: Create new global issue
```

## 4. Present Sync Plan

```markdown
## 📤 Sync Plan

### Will Add Occurrences (Existing Global Issues)
| Project Issue | → | Global Issue | Action |
|---------------|---|--------------|--------|
| P-XXX | → | G-YYY | Add occurrence |
| P-ZZZ | → | G-AAA | Add occurrence |

### Will Create New Global Issues
| Project Issue | Category | Severity |
|---------------|----------|----------|
| P-YYY | [cat] | [sev] |

### Will Skip (Project-Specific)
| Project Issue | Reason |
|---------------|--------|
| P-BBB | [reason] |

---

**Actions**:
- `confirm` - Execute sync plan as shown
- `skip P-XXX` - Remove specific issue from sync
- `force-new P-XXX` - Create new global issue instead of matching
- `cancel` - Abort sync

Confirm sync plan?
```

## 5. Execute Sync

### For Matched Issues (Add Occurrence)

Update existing global issue:

```json
{
  "id": "G-YYY",
  "occurrences": [
    // ... existing occurrences ...,
    {
      "project": "[current project name]",
      "date": "[today]",
      "context": "[from project issue]",
      "project_issue_id": "P-XXX"
    }
  ],
  "updated": "[now]"
}
```

### For New Issues

Generate new global issue ID:
```bash
# Find max G-XXX number
cat ~/.claude/issues.json | grep '"id": "G-' | wc -l
# New ID = G-[max + 1], padded to 3 digits
```

Create new global issue:

```json
{
  "id": "G-[new]",
  "title": "[from project issue]",
  "category": "[category]",
  "severity": "[severity]",
  "status": "pending",
  "occurrences": [
    {
      "project": "[current project]",
      "date": "[today]",
      "context": "[from project issue]",
      "project_issue_id": "P-XXX"
    }
  ],
  "root_cause": "[from project issue or 'To be analyzed']",
  "proposed_resolution": null,
  "created_at": "[now]",
  "updated": "[now]"
}
```

### Update Statistics

```json
{
  "statistics": {
    "total_issues": [+N for new],
    "pending": [+N for new],
    // ... recalculate ...
  }
}
```

## 6. Detect Patterns

After sync, analyze for patterns:

### Pattern Detection Rules

A pattern exists when:
- 3+ issues share the same category
- Issues occurred across 2+ projects
- Similar root causes

```markdown
### Pattern Analysis

**Existing Patterns Updated**:
- P-001 (Test Skipping): Now [N] occurrences

**New Patterns Detected**:
- [Pattern Name]: Issues G-XXX, G-YYY, G-ZZZ
  - Category: [category]
  - Frequency: [N] times in [M] weeks
  - Projects Affected: [list]
```

### Create/Update Pattern Entry

```json
{
  "id": "P-[new]",
  "name": "[Descriptive pattern name]",
  "related_issues": ["G-XXX", "G-YYY", "G-ZZZ"],
  "category": "[common category]",
  "frequency": "[estimated frequency]",
  "first_occurrence": "[earliest date]",
  "last_occurrence": "[latest date]",
  "projects_affected": ["project1", "project2"]
}
```

## 7. Mark Project Issues as Synced

Update each synced project issue:

```json
{
  "id": "P-XXX",
  "synced_to_global": true,
  "synced_at": "[now]",
  "global_issue_id": "G-YYY"
}
```

## 8. Generate Sync Report

```markdown
## ✅ Sync Complete

### Summary
- Issues Synced: [N]
- Occurrences Added: [N]
- New Global Issues: [N]
- Patterns Updated: [N]

### Details

#### Added Occurrences
| Project | Global | Title |
|---------|--------|-------|
| P-XXX | G-YYY | [title] |

#### New Global Issues Created
| ID | Title | Category |
|----|-------|----------|
| G-ZZZ | [title] | [cat] |

#### Patterns Updated
| Pattern | Total Occurrences |
|---------|-------------------|
| [name] | [N] |

### Files Modified
- ./issues.json (marked as synced)
- ~/.claude/issues.json (issues added/updated)

### Next Steps
1. Run `/upgrade-global` to address pending global issues
2. Review patterns for systematic improvements
3. Share learnings with team (if applicable)
```

## 9. Prompt for Upgrade

```markdown
## 🔄 Upgrade Opportunity

Global issues pending resolution: [N]
- Critical: [N]
- High: [N]
- Medium: [N]

**Recommendation**: 
[If critical/high issues exist]
Run `/upgrade-global` now to address pending issues.

Would you like to upgrade global configuration now? (y/n)
```

## Notes

- Run this command when:
  - Project is complete/ending
  - Accumulated 5+ global-relevant issues
  - Before starting a new major project
- Patterns help identify systematic issues needing structural fixes
- Synced issues remain in project issues.json for reference
- Global issues become input for `/upgrade-global` command
