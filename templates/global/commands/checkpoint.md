---
description: Create a checkpoint for session handoff - USE when context > 60% or before complex changes
---

# Checkpoint

## Save Current State

1. **Stage all changes**
   ```bash
   git add .
   ```

2. **Create checkpoint commit**
   ```bash
   git commit -m "checkpoint: [describe current state and work in progress]"
   ```

## Document Progress

3. **Update progress.md with detailed state:**

   ```markdown
   ## Checkpoint: [timestamp]

   ### Work Completed This Session
   - [List specific completed items]

   ### Current State of In-Progress Task
   - Task: [task name/id]
   - Status: [specific progress]
   - Files modified: [list]
   - Tests status: [passing/failing/pending]

   ### Remaining Work
   - [Specific next steps]
   - [Estimated complexity]

   ### Blockers or Issues
   - [Any problems encountered]
   - [Decisions needed]

   ### Notes for Next Session
   - [Important context]
   - [Technical notes]
   - [Recommended starting point]
   ```

## Report

4. **Show current context usage**
   - Run `/context` and report percentage

5. **Summarize next session priorities**
   - What should be done first
   - Any prerequisites or setup needed
   - Estimated task complexity

## IMPORTANT

- **YOU MUST** create this checkpoint before context reaches 70%
- **NEVER** lose work by ignoring context limits
- Document enough detail that another session can continue seamlessly
