# Behavior Principles

## Core Principles

### 1. Incremental Development
- Complete ONE task per session
- Each task must be testable independently
- Commit after each logical unit
- Never attempt to complete entire project in one session

### 2. Explicit State Management
- Use JSON for task state (resistant to modification)
- Use Markdown for progress notes (human-readable)
- Use Git for history and recovery
- Never rely on memory between sessions

### 3. Verification Before Completion
- Run tests before marking complete
- Verify no console errors
- Check for TODO comments
- Validate against acceptance criteria

### 4. Context Awareness
- Monitor context usage: warn at 50%, checkpoint at 70%
- Use `/compact` when approaching limits
- Start new session rather than risk data loss
- Report context usage at session end

### 5. Human-in-the-Loop
- Enter Plan Mode before implementation
- Present plan and wait for approval
- Ask clarifying questions rather than assume
- Report blockers immediately

## Anti-Patterns to Avoid

| Anti-Pattern | Correct Approach |
|--------------|------------------|
| One-shot completion | Incremental implementation |
| Premature "done" declaration | Test-driven completion |
| Uncommitted session end | Always commit before exit |
| Assumption without verification | Ask clarifying questions |
| Context overflow | Checkpoint and new session |
| Skipping tests | Run all tests before completion |
| Silent failures | Report errors explicitly |

## Session Boundaries

### Valid Session End
- All changes committed
- progress.md updated
- Context usage reported
- Next steps documented

### Invalid Session End
- Uncommitted changes
- Incomplete documentation
- No progress update
- Context overflow without checkpoint

## Error Handling

When encountering errors:
1. Stop and analyze the error
2. Search codebase for similar patterns
3. Check git history for context
4. If still unclear, ask human for guidance
5. Never proceed with assumptions on critical paths

---

## Automatic Issue Detection (Low-Token Mode)

**YOU MUST** detect issues during sessions but **defer file operations to session end** to minimize token consumption.

### Detection Triggers

| Trigger | Example | Category |
|---------|---------|----------|
| User correction | "That's not what I meant", "違う", "そうじゃない" | `communication` |
| Requirement mismatch | Code review reveals different intent | `communication` |
| Test failure | Tests fail after implementation | `quality-gate` |
| Repeated explanation | User explains the same thing twice | `communication` |
| Runtime error | Code throws unexpected errors | `quality-gate` |
| Wrong file edited | Modified incorrect file | `workflow` |
| Forgot verification | Committed without testing | `quality-gate` |
| Context overflow | Exceeded 85% without checkpoint | `context-management` |

### During Session: Memory-Only Mode

When an issue is detected:

1. **Acknowledge** - Recognize the issue to the user
2. **Note briefly** - Report: "📝 Noted: [2-3 word summary]"
3. **Continue** - Proceed with correction immediately
4. **NO file operations** - Do not read/write issues.json during session

**Example:**
```
User: "No, I wanted an array, not an object"

Claude:
I understand. Let me fix that to return an array.

📝 Noted: Return type mismatch

[Proceeds with correction - NO file I/O]
```

### Session End: Batch Recording

**At session end**, perform ONE batch operation:

1. **Recall** all noted issues from the session
2. **Read** issues.json once
3. **Write** all issues in a single operation
4. **Report** summary: "📊 Session: X issues recorded"

**Batch Entry Format:**
```json
{
  "id": "P-XXX",
  "title": "[Issue title]",
  "category": "[category]",
  "severity": "[severity]",
  "status": "logged",
  "trigger": "auto-detected",
  "session": "[YYYY-MM-DD]",
  "summary": "[Brief description]",
  "global_relevance": true,
  "logged_at": "[timestamp]"
}
```

### Severity Classification

| Condition | Severity |
|-----------|----------|
| Data loss, security risk, or blocked work | `critical` |
| User had to repeat themselves or redo work | `high` |
| Implementation needed correction | `medium` |
| Minor misunderstanding, quickly resolved | `low` |

### Token Efficiency

| Operation | When | Token Cost |
|-----------|------|------------|
| Issue detection | During session | Zero (memory only) |
| "📝 Noted" message | During session | ~5 tokens |
| Batch file write | Session end only | One-time cost |

This approach reduces token consumption by **~90%** compared to per-issue file operations.
