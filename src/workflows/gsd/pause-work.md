---
description: Create a .continue-here.md handoff file to preserve work state across sessions. Usage: /gsd/pause-work
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Create `.continue-here.md` handoff file to preserve complete work state across sessions. Enables seamless resumption with full context restoration.
</purpose>

<process>

## 1. Detect Current Phase

[TOOL HARNESS: find_by_name, read_file]

Find most recently modified phase directory with active work:
- Find all `*-PLAN.md` files in `.planning/phases/` subdirectories
- Identify the one most recently modified that has no matching SUMMARY.md

If no active phase detected: ask user (freeform) which phase they're pausing work on.

## 2. Gather State

[TOOL HARNESS: read_file, run_command]

Collect complete state for handoff:

1. **Current position**: Which phase, which plan, which task
2. **Work completed**: What got done this session
3. **Work remaining**: What's left in current plan/phase
4. **Decisions made**: Key decisions and rationale
5. **Blockers/issues**: Anything stuck
6. **Mental context**: The approach, next steps, the plan
7. **Files modified**: run_command: `git status --short`

Ask user (freeform) for any clarifications needed.

## 3. Write Handoff

[TOOL HARNESS: write_to_file]

Write to `.planning/phases/{XX-name}/.continue-here.md`:

```markdown
---
phase: {XX-name}
task: {current_task_number}
total_tasks: {total_tasks}
status: in_progress
last_updated: {ISO timestamp}
---

<current_state>
{Where exactly are we? Immediate context}
</current_state>

<completed_work>

- Task 1: {name} - Done
- Task 2: {name} - Done
- Task 3: {name} - In progress, {what's done}
</completed_work>

<remaining_work>

- Task 3: {what's left}
- Task 4: Not started
- Task 5: Not started
</remaining_work>

<decisions_made>

- Decided to use {X} because {reason}
- Chose {approach} over {alternative} because {reason}
</decisions_made>

<blockers>
- {Blocker 1}: {status/workaround}
</blockers>

<context>
{Mental state, what were you thinking, the plan}
</context>

<next_action>
Start with: {specific first action when resuming}
</next_action>
```

Be specific enough for a fresh Cascade session to understand immediately.

## 4. Commit

[TOOL HARNESS: run_command]

Read `.planning/config.json` → check `commit_docs`.

If commit_docs=true:
run_command: `git add ".planning/phases/{XX-name}/.continue-here.md"`
run_command: `git commit -m "wip: {phase-name} paused at task {X}/{Y}"`

## 5. Confirm

Display:
```
✓ Handoff created: .planning/phases/{XX-name}/.continue-here.md

Current state:

- Phase: {XX-name}
- Task: {X} of {Y}
- Status: in_progress
- Committed as WIP

To resume: /gsd/resume-work
```

</process>

<success_criteria>
- [ ] .continue-here.md created in correct phase directory
- [ ] All sections filled with specific content
- [ ] Committed as WIP (if commit_docs=true)
- [ ] User knows location and how to resume
</success_criteria>
