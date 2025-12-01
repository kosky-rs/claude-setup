# Task Management Workflow

## Task Hierarchy

| Complexity | Task Count | Example | Session Estimate |
|------------|-----------|---------|------------------|
| Huge | 15-25 top-level | Full application | 10+ sessions |
| Large | 8-15 tasks | Multi-component feature | 5-10 sessions |
| Medium | 3-8 tasks | Single component | 2-4 sessions |
| Small | Direct implementation | Bug fix, tweak | 1 session |

## Task Sizing Guidelines

### Each Task Must Be:
- Completable in 1 session (context < 50%)
- Independently testable
- Clearly defined with acceptance criteria
- Documented with dependencies

### When to Split Tasks:
- Estimated context usage > 40%
- Multiple unrelated concerns
- Complex dependencies
- Unclear requirements

## Session Lifecycle

### START Phase

```bash
# 1. Confirm working directory
pwd

# 2. Check recent changes
git log --oneline -5

# 3. Review progress
cat progress.md

# 4. Check task state
cat tasks.json | jq '.tasks[] | select(.status != "completed")'

# 5. Select ONE pending task
# 6. Run baseline tests
npm test  # or appropriate command
```

### WORK Phase

1. **Enter Plan Mode** (Shift+Tab×2)
2. **Create implementation plan**
   - List specific files to modify
   - Identify potential risks
   - Estimate context usage
3. **Present plan and wait for approval**
4. **Implement incrementally**
   - Small, focused changes
   - Frequent commits
   - Continuous testing
5. **Test thoroughly before completion**

### END Phase

```bash
# 1. Run final tests
npm test

# 2. Commit changes
git add .
git commit -m "feat: [detailed description]"

# 3. Update progress.md
# 4. Update tasks.json if completed
# 5. Report context usage
```

## Task State Format (tasks.json)

```json
{
  "project": "project-name",
  "version": "1.0.0",
  "updated": "2025-12-01T10:00:00Z",
  "tasks": [
    {
      "id": 1,
      "title": "Task title",
      "description": "Detailed description",
      "status": "pending",
      "type": "medium",
      "dependencies": [],
      "acceptance_criteria": [
        "Criterion 1",
        "Criterion 2"
      ],
      "subtasks": [],
      "notes": "",
      "created_at": "2025-12-01T10:00:00Z",
      "completed_at": null
    }
  ]
}
```

### Status Values
- `pending`: Not started
- `in_progress`: Currently being worked on
- `completed`: Done and verified
- `blocked`: Cannot proceed (document reason)

### Type Values
- `small`: < 30 minutes, direct implementation
- `medium`: 30-60 minutes, single component
- `large`: 1-2 hours, multiple files
- `huge`: Multiple sessions, needs subtasks

## Progress Tracking (progress.md)

```markdown
# Progress Log

## Current Session: YYYY-MM-DD

### Completed
- [x] Task description

### In Progress
- [ ] Task description
  - Step completed
  - TODO: Next step

### Blocked
- Task: [reason]

### Notes for Next Session
- Important context
- Pending decisions
- Technical notes

### Context Usage
- Session start: X%
- Session end: Y%
```

## Dependency Management

### Before Starting a Task:
1. Check `dependencies` array in tasks.json
2. Verify all dependencies are `completed`
3. If blocked, document in progress.md
4. Suggest alternative task if blocked

### Dependency Chain Example:
```
Task 1: Database schema ──┐
                          ├──► Task 3: API endpoints
Task 2: Auth service ─────┘
                          │
                          └──► Task 4: Frontend integration
```
