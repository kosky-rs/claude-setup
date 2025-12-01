---
description: Complete current task with proper verification - runs tests and updates state
---

# Complete Task: $ARGUMENTS

## Pre-Completion Verification

### 1. Run Tests

```bash
# Run all relevant tests
npm test
# or
python -m pytest
# or project-specific test command
```

**YOU MUST** verify all tests pass before proceeding.

### 2. Check for Errors

```bash
# Check for TypeScript errors
npx tsc --noEmit

# Check for linting errors
npm run lint
```

### 3. Manual Verification

- [ ] Feature works as expected
- [ ] No console errors or warnings
- [ ] Edge cases handled
- [ ] Error states display correctly

### 4. Code Quality Check

Search for issues:
```bash
grep -r "TODO" src/
grep -r "FIXME" src/
grep -r "console.log" src/
```

- [ ] No TODO/FIXME comments left behind
- [ ] No debug console.log statements
- [ ] Code follows project conventions

## Completion Steps

### 5. Verify Acceptance Criteria

Read the task's `acceptance_criteria` from `tasks.json`.

For each criterion:
- [ ] [Criterion 1] - Verified
- [ ] [Criterion 2] - Verified
- [ ] [Criterion 3] - Verified

**IMPORTANT**: Do NOT proceed if any criterion is not met.

### 6. Update Task State

Update `tasks.json`:
```json
{
  "id": [task_id],
  "status": "completed",
  "completed_at": "[timestamp]"
}
```

### 7. Commit Changes

```bash
git add .
git commit -m "feat([scope]): [descriptive message]

- [Detail 1]
- [Detail 2]

Completes task #[task_id]"
```

### 8. Update Progress

Add to `progress.md`:
```markdown
### Completed
- [x] Task [ID]: [Title]
  - Acceptance criteria verified
  - Tests passing
  - Committed: [commit hash]
```

### 9. Suggest Next Task

Review `tasks.json` for:
- Tasks that depended on this one (now unblocked)
- Highest priority pending tasks
- Natural next steps

Recommend the next task to work on with brief justification.

## Failure Handling

If any verification fails:

1. **Stop completion process**
2. **Document the failure** in progress.md
3. **Report to human**:
   - What failed
   - Why it failed
   - Proposed fix
4. **Do NOT mark as complete**
