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
