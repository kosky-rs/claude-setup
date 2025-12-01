# Quality Gates

## Mandatory Checks

| Check | Description | Trigger | Response |
|-------|-------------|---------|----------|
| No premature completion | No "done" before testing | Completion attempt | Force test execution |
| No uncommitted endings | No session end without commit | Session end | Force commit |
| No context overflow | Warn at 50%, checkpoint at 70% | Context check | Save progress, new session |
| No untested code | Verify all changes | Code modification | Force test execution |
| No assumption errors | Verify before proceeding | Uncertainty | Ask clarifying question |

## Pre-Completion Checklist

Before marking ANY task as complete:

- [ ] All unit tests pass
- [ ] All integration tests pass (if applicable)
- [ ] No console errors or warnings
- [ ] No TODO/FIXME comments left behind
- [ ] Code follows project style guidelines
- [ ] Documentation updated (if needed)
- [ ] Changes committed with descriptive message
- [ ] Acceptance criteria verified

## Context Management Gates

### At 50% Context Usage
- **Action**: Log warning in progress.md
- **Message**: "Context at 50%, consider completing current task"

### At 70% Context Usage
- **Action**: Create checkpoint
- **Steps**:
  1. Commit all current changes
  2. Update progress.md with detailed state
  3. Document next steps
  4. Report to human

### At 85% Context Usage
- **Action**: Emergency save and stop
- **Steps**:
  1. Immediate commit
  2. Full state dump to progress.md
  3. Recommend new session

## When Uncertain

1. **Stop and analyze**
   - What exactly is unclear?
   - What are the possible interpretations?

2. **Search for context**
   - Check existing codebase for patterns
   - Review git history for similar changes
   - Look for documentation

3. **Ask clarifying questions**
   - Be specific about what's unclear
   - Propose options if possible
   - Wait for response before proceeding

4. **Never assume on critical paths**
   - Security-related code
   - Data mutations
   - External API calls
   - Configuration changes

## IMPORTANT Keywords Usage

Use these keywords in CLAUDE.md for critical instructions:

| Keyword | Usage | Compliance Level |
|---------|-------|------------------|
| **IMPORTANT** | Must be followed in most cases | High |
| **YOU MUST** | Absolutely required, no exceptions | Critical |
| **NEVER** | Prohibited action | Critical |
| **ALWAYS** | Required action | High |

### Examples:
- **IMPORTANT**: Run tests before declaring completion
- **YOU MUST**: Commit all changes before session end
- **NEVER**: Modify production configuration without approval
- **ALWAYS**: Ask clarifying questions when uncertain

## Code Review Gates

Before committing, verify:

### Security
- [ ] No hardcoded credentials
- [ ] Input validation present
- [ ] SQL injection prevention
- [ ] XSS prevention (if web)

### Performance
- [ ] No obvious N+1 queries
- [ ] No unnecessary loops
- [ ] Appropriate caching considered

### Maintainability
- [ ] Code is readable
- [ ] Functions are focused
- [ ] Naming is clear
- [ ] Comments where needed

### Testing
- [ ] New code has tests
- [ ] Edge cases covered
- [ ] Error paths tested

## Violation Handling

When a quality gate is violated:

1. **Stop current work**
2. **Identify the violation**
3. **Take corrective action**
4. **Document the incident**
5. **Resume only after resolution**

### Example Violation Response:

```markdown
## Quality Gate Violation

**Gate**: Pre-completion testing
**Violation**: Attempted to mark task complete without running tests
**Corrective Action**: Running test suite now
**Result**: [Tests passed/failed]
**Lesson**: Added explicit test step to workflow
```
