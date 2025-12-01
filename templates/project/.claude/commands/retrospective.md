---
description: End-of-session retrospective - review session and log undetected issues
---

# Session Retrospective

## 1. Gather Session Data

```bash
echo "=== Session Changes ==="
git log --oneline -20

echo ""
echo "=== Files Modified ==="
git diff --stat HEAD~5 2>/dev/null || git diff --stat

echo ""
echo "=== Current Progress ==="
cat progress.md

echo ""
echo "=== Logged Issues This Session ==="
cat issues.json | grep -A10 "$(date +%Y-%m-%d)" || echo "No issues logged today"

echo ""
echo "=== Tasks Status ==="
cat tasks.json | head -60
```

## 2. Session Analysis Checklist

Review the session against these criteria:

### Instruction Compliance

- [ ] **CLAUDE.md Rules**: Were all global rules followed?
- [ ] **Quality Gates**: Were all checks performed before completion?
- [ ] **Workflow Steps**: Was the session lifecycle followed?
- [ ] **Communication**: Were clarifications requested when needed?

### Behavioral Issues

- [ ] **Assumptions Made**: Were there any unverified assumptions?
- [ ] **Shortcuts Taken**: Were any steps skipped?
- [ ] **Errors Ignored**: Were any errors dismissed without proper handling?
- [ ] **Context Issues**: Was context managed appropriately?

### Efficiency Issues

- [ ] **Repeated Attempts**: Were there multiple failed attempts at something?
- [ ] **Rework Required**: Was any work redone due to misunderstanding?
- [ ] **Time Wasted**: Was time spent on non-productive activities?
- [ ] **Wrong Direction**: Was work done that had to be discarded?

### Technical Issues

- [ ] **Test Failures**: Were there unexplained test failures?
- [ ] **Build Issues**: Were there build/compilation problems?
- [ ] **Integration Problems**: Were there issues with external services?
- [ ] **Configuration Errors**: Were there setup/config problems?

## 3. Detect Unlogged Issues

For each checkbox that indicates a problem, create an issue detection:

```markdown
---

### Detected Issue #[N]

**Problem**: [What happened]
**When**: [During which task/activity]
**Evidence**: [How we know this happened - git log, error, etc.]

**Classification**:
- Category: [category]
- Severity: [severity]  
- Already Logged: [Yes - P-XXX / No]
- Global Relevance: [Yes/No]

**Suggested Fix**: [How to prevent recurrence]

---
```

## 4. Present Findings

```markdown
## 📋 Retrospective Summary

### Session Overview
- **Date**: [date]
- **Tasks Attempted**: [N]
- **Tasks Completed**: [N]
- **Context Used**: [X]%

### Already Logged Issues
| ID | Title | Severity |
|----|-------|----------|
| P-XXX | [title] | [severity] |

### Newly Detected Issues
| # | Problem | Category | Severity | Global? |
|---|---------|----------|----------|---------|
| 1 | [brief] | [cat] | [sev] | [Y/N] |
| 2 | [brief] | [cat] | [sev] | [Y/N] |

### No Issues Detected
[List areas that were checked and found no problems]

---

**Actions**:
- `log all` - Log all detected issues
- `log 1,2` - Log specific issues by number  
- `skip` - Skip logging, issues are minor
- `details N` - Show more details for issue N

Which issues should I log?
```

## 5. Log Confirmed Issues

For each confirmed issue:

### Generate Issue Entry

```json
{
  "id": "P-[next]",
  "title": "[from detection]",
  "category": "[category]",
  "severity": "[severity]",
  "status": "logged",
  "session": "[today's session]",
  "context": "[from detection]",
  "impact": "[assessed impact]",
  "root_cause": "[initial analysis]",
  "suggested_fix": "[from detection]",
  "global_relevance": [true/false],
  "synced_to_global": false,
  "logged_at": "[now]",
  "detected_by": "retrospective"
}
```

### Update issues.json

Add all confirmed issues to the issues array.

## 6. Update Progress Log

Append retrospective summary to progress.md:

```markdown
---

## 📊 Session Retrospective: [Date]

### Session Metrics
- Duration: [estimated]
- Tasks Completed: [N]
- Context Usage: [X]%

### Issues Summary
- Previously Logged: [N]
- Newly Detected: [N]
- Total This Session: [N]

### Issues Logged
| ID | Title | Category | Severity |
|----|-------|----------|----------|
| P-XXX | [title] | [cat] | [sev] |

### What Went Well
- [Positive observation]
- [Positive observation]

### What Could Improve
- [Improvement area]
- [Improvement area]

### Lessons Learned
- [Lesson that should inform future work]

### Recommendations for Global CLAUDE.md
- [Any rules that should be added globally]
```

## 7. Check for Sync Opportunity

```markdown
## 🔄 Global Sync Check

Issues with `global_relevance: true` that haven't been synced:

| ID | Title | Severity |
|----|-------|----------|
| P-XXX | [title] | [severity] |

**Recommendation**: 
[If project is ending or multiple global issues accumulated]
Run `/sync-issues-to-global` to update global issue tracker.

Would you like to sync now? (y/n)
```

## 8. Session Closure

```markdown
## ✅ Retrospective Complete

### Summary
- Issues reviewed: [N]
- New issues logged: [N]  
- Progress updated: Yes

### Before Ending Session
- [ ] All changes committed
- [ ] Progress.md updated
- [ ] Context usage noted

### Recommended Next Actions
1. [Based on issues found]
2. [Based on incomplete tasks]

### If Project Ending
Run `/sync-issues-to-global` to preserve learnings.
```

## Notes

- Run at the end of EVERY session for consistent improvement
- Be honest about issues - underreporting hurts long-term quality
- Global relevance should be true for systematic issues, false for one-off problems
- This is the primary mechanism for detecting issues that weren't caught during work
