---
description: Execute small, ad-hoc tasks with GSD guarantees (atomic commits, STATE.md tracking). Usage: /gsd/quick [description] [--full]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Execute small, ad-hoc tasks with GSD guarantees (atomic commits, STATE.md tracking). Quick mode spawns gsd-planner (quick mode) + gsd-executor, tracks tasks in `.planning/quick/`, and updates STATE.md's "Quick Tasks Completed" table.

With `--full` flag: enables plan-checking (max 2 iterations) and post-execution verification for quality guarantees without full milestone ceremony.
</purpose>

<process>

## 1. Parse Arguments

Parse arguments for:
- `--full` flag → store as `FULL_MODE` (true/false)
- Remaining text → use as `DESCRIPTION` if non-empty

If `DESCRIPTION` is empty after parsing: use ask_user_question:
- question: "What do you want to do?"
- options: (leave empty — user provides freeform text)

Actually: ask freeform (not ask_user_question) since description is open-ended.

If `FULL_MODE`:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► QUICK TASK (FULL MODE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Plan checking + verification enabled
```

## 2. Initialize

[TOOL HARNESS: read_file, find_by_name, run_command]

Read `.planning/ROADMAP.md`. If missing:
```
ERROR: Quick mode requires an active project with ROADMAP.md.
Run /gsd/new-project first.
```
Exit.

Read `.planning/config.json` → extract `commit_docs`.

Calculate `next_num`: count directories in `.planning/quick/` + 1, zero-padded to 3 digits (001, 002, 003...).
Generate `slug` from description: lowercase, spaces → hyphens, max 40 chars.

`task_dir` = `.planning/quick/{next_num}-{slug}`

run_command: `mkdir -p "{task_dir}"`

Display: `Creating quick task {next_num}: {DESCRIPTION}`

## 3. Spawn Planner (Quick Mode)

[TOOL HARNESS: read_file, write_to_file, run_command]

Display: `◆ Spawning planner (quick mode)...`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-planner.md
  Act as gsd-planner in **quick mode**.
  Read:
  - `.planning/STATE.md`
  - `./CLAUDE.md` (if exists)
  - `.agents/skills/` SKILL.md files (if exists)
  Mode: {FULL_MODE ? 'quick-full' : 'quick'}
  Description: {DESCRIPTION}
  Directory: {task_dir}
  Constraints:
  - Create a SINGLE plan with 1-3 focused tasks
  - Quick tasks should be atomic and self-contained
  - No research phase
  - Target ~30% context usage (simple, focused)
  {If FULL_MODE: - MUST generate `must_haves` in plan frontmatter (truths, artifacts, key_links)}
  {If FULL_MODE: - Each task MUST have `files`, `action`, `verify`, `done` fields}
  Write plan to: `{task_dir}/{next_num}-PLAN.md`
  Return: `## PLANNING COMPLETE` with plan path
→ END ROLE

Verify plan exists at `{task_dir}/{next_num}-PLAN.md`. If missing: error.

## 4. Plan-Checker Loop (FULL_MODE only)

[TOOL HARNESS: read_file]

**Skip this step entirely if NOT FULL_MODE.**

Display: `◆ Spawning plan checker...`

Initialize `iteration_count = 1`.

→ ROLE SWITCH: Read GSD_AGENTS/gsd-plan-checker.md
  Act as gsd-plan-checker in **quick mode**.
  Read: `{task_dir}/{next_num}-PLAN.md`
  Mode: quick-full
  Task Description: {DESCRIPTION}
  Scope: Quick task — skip checks requiring ROADMAP phase goal.
  Check: requirement coverage, task completeness, key links, scope sanity (1-3 tasks), must_haves derivation.
  Return: `## VERIFICATION PASSED` or `## ISSUES FOUND {structured list}`
→ END ROLE

**If VERIFICATION PASSED:** Continue to step 5.

**If ISSUES FOUND:** Revision loop (max 2 iterations):

If iteration_count < 2:
  Display: `Sending back to planner for revision... (iteration {N}/2)`
  → ROLE SWITCH: gsd-planner in revision mode. Read existing plan + checker issues. Make targeted updates.
  Increment iteration_count → re-run checker.

If iteration_count >= 2:
  Display: `Max iterations reached. {N} issues remain.`
  Use ask_user_question:
  - label: "Force proceed" — description: Execute despite remaining issues
  - label: "Abort" — description: Exit workflow

## 5. Execute

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name]

Display: `◆ Spawning executor...`

→ ROLE SWITCH: Read GSD_WORKFLOWS/execute-plan.md
  Act as gsd-executor following the execute-plan workflow.
  Read:
  - `{task_dir}/{next_num}-PLAN.md`
  - `.planning/STATE.md`
  - `./CLAUDE.md` (if exists)
  - `.agents/skills/` SKILL.md files (if exists)
  Execute all tasks. Commit each task atomically.
  Create summary at: `{task_dir}/{next_num}-SUMMARY.md`
  Do NOT update ROADMAP.md (quick tasks are separate from planned phases).
  Return: task completion status, commit hashes, summary path.
→ END ROLE

Verify summary exists at `{task_dir}/{next_num}-SUMMARY.md`. If missing: error.

## 6. Verification (FULL_MODE only)

[TOOL HARNESS: read_file, grep_search, find_by_name]

**Skip this step entirely if NOT FULL_MODE.**

Display: `◆ Spawning verifier...`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-verifier.md
  Act as gsd-verifier.
  Read: `{task_dir}/{next_num}-PLAN.md`
  Task goal: {DESCRIPTION}
  Check must_haves against actual codebase.
  Create VERIFICATION.md at `{task_dir}/{next_num}-VERIFICATION.md`.
  Return: status (passed/human_needed/gaps_found)
→ END ROLE

Read verification status from `{task_dir}/{next_num}-VERIFICATION.md` frontmatter.

| Status | Action |
|--------|--------|
| `passed` | Store `VERIFICATION_STATUS = "Verified"`, continue |
| `human_needed` | Display items needing manual check, store `VERIFICATION_STATUS = "Needs Review"`, continue |
| `gaps_found` | Display gap summary, offer: 1) Re-run executor to fix gaps, 2) Accept as-is. Store `VERIFICATION_STATUS = "Gaps"` |

## 7. Update STATE.md

[TOOL HARNESS: read_file, write_to_file, run_command]

Get commit hash: run_command: `git rev-parse --short HEAD`

Read `.planning/STATE.md`. Check for `### Quick Tasks Completed` section.

If section doesn't exist, create it:
```markdown
### Quick Tasks Completed

| # | Description | Date | Commit | {If FULL_MODE: Status | }Directory |
|---|-------------|------|--------|{If FULL_MODE: --------|}-----------| 
```

Append new row:
```markdown
| {next_num} | {DESCRIPTION} | {date} | {commit_hash} | {If FULL_MODE: {VERIFICATION_STATUS} | }[{next_num}-{slug}](.planning/quick/{next_num}-{slug}/) |
```

Update "Last activity" line: `{date} - Completed quick task {next_num}: {DESCRIPTION}`

## 8. Final Commit and Completion

[TOOL HARNESS: run_command]

File list: `{task_dir}/{next_num}-PLAN.md`, `{task_dir}/{next_num}-SUMMARY.md`, `.planning/STATE.md`
If FULL_MODE and verification file exists: add `{task_dir}/{next_num}-VERIFICATION.md`

If commit_docs=true:
run_command: `git add {file_list}`
run_command: `git commit -m "docs(quick-{next_num}): {DESCRIPTION}"`

Display completion:

**If FULL_MODE:**
```
---

GSD ► QUICK TASK COMPLETE (FULL MODE)

Quick Task {next_num}: {DESCRIPTION}

Summary: {task_dir}/{next_num}-SUMMARY.md
Verification: {task_dir}/{next_num}-VERIFICATION.md ({VERIFICATION_STATUS})
Commit: {commit_hash}

---

Ready for next task: /gsd/quick
```

**If NOT FULL_MODE:**
```
---

GSD ► QUICK TASK COMPLETE

Quick Task {next_num}: {DESCRIPTION}

Summary: {task_dir}/{next_num}-SUMMARY.md
Commit: {commit_hash}

---

Ready for next task: /gsd/quick
```

</process>

<success_criteria>
- [ ] ROADMAP.md validation passes
- [ ] User provides task description
- [ ] `--full` flag parsed from arguments when present
- [ ] Slug generated (lowercase, hyphens, max 40 chars)
- [ ] Next number calculated (001, 002, 003...)
- [ ] Directory created at `.planning/quick/{NNN}-{slug}/`
- [ ] `{next_num}-PLAN.md` created by planner role-switch
- [ ] (--full) Plan checker validates plan, revision loop capped at 2
- [ ] `{next_num}-SUMMARY.md` created by executor role-switch
- [ ] (--full) `{next_num}-VERIFICATION.md` created by verifier role-switch
- [ ] STATE.md updated with quick task row (Status column when --full)
- [ ] Artifacts committed (if commit_docs=true)
</success_criteria>
