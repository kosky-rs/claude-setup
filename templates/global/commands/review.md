---
description: Review code changes before commit - comprehensive quality check
---

# Code Review

## Gather Changes

1. **List all changes**
   ```bash
   git status
   git diff --stat
   ```

2. **View detailed diff**
   ```bash
   git diff
   ```

## Analysis Checklist

3. **Review each changed file for:**

### Code Quality
- [ ] Code is readable and self-documenting
- [ ] Functions are small and focused
- [ ] Naming is clear and consistent
- [ ] No unnecessary complexity

### Correctness
- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] No obvious bugs

### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities (if web)
- [ ] Proper authorization checks

### Performance
- [ ] No obvious N+1 queries
- [ ] No unnecessary loops or iterations
- [ ] Appropriate data structures used
- [ ] No memory leaks

### Testing
- [ ] New code has tests
- [ ] Edge cases tested
- [ ] Error paths tested
- [ ] Tests are meaningful (not just coverage)

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated if needed

## Report Format

4. **Provide feedback in this structure:**

```markdown
## Code Review Summary

### Overview
[Brief description of changes reviewed]

### Files Reviewed
- `path/to/file1.ts` - [brief description]
- `path/to/file2.ts` - [brief description]

### Issues Found

#### Critical (Must Fix)
- **[File:Line]**: [Description] 
  - Suggestion: [How to fix]

#### Major (Should Fix)
- **[File:Line]**: [Description]
  - Suggestion: [How to fix]

#### Minor (Consider)
- **[File:Line]**: [Description]
  - Suggestion: [How to fix]

### Positive Notes
- [Good patterns or improvements noticed]

### Suggestions for Improvement
- [Optional enhancements]

### Verdict
[ ] **APPROVED** - Ready to commit
[ ] **APPROVED WITH NOTES** - Minor issues, can commit
[ ] **NEEDS CHANGES** - Must address issues before commit
[ ] **BLOCKED** - Critical issues, do not commit
```

## Actions

5. **Based on verdict:**

- **APPROVED**: Proceed with `git commit`
- **NEEDS CHANGES**: Fix issues, then re-review
- **BLOCKED**: Discuss with human before proceeding
