---
description: Start working on a new task - reads state and creates implementation plan
---

# Start Task: $ARGUMENTS

## 1. Understand Current State

Read and analyze:
```bash
cat progress.md
cat tasks.json
git log --oneline -5
git status
```

## 2. Locate the Task

Find the specified task in `tasks.json`:
- If task ID provided: Find by ID
- If task name provided: Find by title match
- If no argument: Show pending tasks and ask which to start

## 3. Verify Dependencies

Check that all tasks in `dependencies` array have status "completed".

If dependencies not met:
- List which dependencies are incomplete
- Suggest completing dependencies first
- Ask if user wants to proceed anyway

## 4. Analyze Task Scope

Based on task details:
- List files that will likely need modification
- Identify potential risks or complexities
- Estimate context usage for this task

## 5. Enter Plan Mode

**Shift+Tab×2** to enter Plan Mode

Create implementation plan:
```markdown
## Implementation Plan for Task: [Title]

### Overview
[Brief description of what will be implemented]

### Steps
1. [Step 1]
   - Files: [list]
   - Estimated effort: [low/medium/high]
2. [Step 2]
   - Files: [list]
   - Estimated effort: [low/medium/high]
[...]

### Testing Strategy
- Unit tests: [what to test]
- Integration tests: [what to test]
- Manual verification: [what to check]

### Risks
- [Risk 1]: [mitigation]
- [Risk 2]: [mitigation]

### Estimated Context Usage
[X]% of available context
```

## 6. Wait for Approval

**IMPORTANT**: Present the plan and **WAIT** for human approval.

Do NOT start implementation until approval is received.

## 7. Update Status

After approval, update `tasks.json`:
```json
{
  "id": [task_id],
  "status": "in_progress",
  "started_at": "[timestamp]"
}
```
