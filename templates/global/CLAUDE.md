# Global Instructions for Claude Code

## Behavior Principles
@~/.claude/docs/behavior-principles.md

## Task Management Workflow
@~/.claude/docs/task-workflow.md

## Code Standards
@~/.claude/docs/code-standards.md

## Quality Gates
@~/.claude/docs/quality-gates.md

---

## Quick Reference

### Session Start Checklist
1. `pwd` → `git log --oneline -5` → `cat progress.md`
2. Select ONE pending task from tasks.json
3. Enter Plan Mode (Shift+Tab×2)
4. **Wait for human approval before coding**

### Session End Checklist
1. Run all tests
2. `git add . && git commit -m "feat: [description]"`
3. Update progress.md
4. Report context usage %

### Critical Rules
- **IMPORTANT**: Never declare completion without E2E testing
- **YOU MUST**: Commit all changes before session end
- **IMPORTANT**: Ask clarifying questions rather than assume
- **IMPORTANT**: Monitor context usage - warn at 50%, checkpoint at 70%

### Context Management
- Use `/context` to check usage
- Use `/compact` when approaching limits
- Create checkpoint before context overflow
