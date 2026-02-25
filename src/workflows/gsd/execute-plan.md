---
description: Execute a single phase plan (PLAN.md) and create SUMMARY.md. Usually invoked by execute-phase, but can be run standalone. Usage: /gsd/execute-plan [phase] [plan]
---

<!-- GSD_HOME=~/.codeium/windsurf/get-shit-done -->

<process>

## 1. Init Context

[TOOL HARNESS: read_file, find_by_name, run_command]

Read:
- `.planning/STATE.md`
- `.planning/config.json`
- `.planning/ROADMAP.md`

Extract: `commit_docs`, `mode` (yolo/interactive), `phase_dir`, `phase_number`.

If `.planning/` missing: error.

## 2. Identify Plan

[TOOL HARNESS: find_by_name, run_command]

Find all `*-PLAN.md` in phase directory. Find all `*-SUMMARY.md` in phase directory.

Find first PLAN.md without a matching SUMMARY.md (by plan number).

**If mode=yolo:** Auto-approve: `⚡ Execute {phase}-{plan}-PLAN.md [Plan X of Y for Phase Z]` → proceed to parse_segments.

**If mode=interactive:** Present plan identification, wait for confirmation.

## 3. Record Start Time

Note current timestamp as `PLAN_START_TIME`.

## 4. Parse Segments

[TOOL HARNESS: read_file, grep_search]

Read the PLAN.md completely.

Check for checkpoint tasks: grep for `type="checkpoint` in the plan.

**Routing by checkpoint type:**

| Checkpoints | Pattern | Execution |
|-------------|---------|-----------|
| None | A (autonomous) | Full plan in single executor role-switch |
| Verify-only | B (segmented) | Segments between checkpoints |
| Decision/Action | C (main) | Execute in current context |

**Pattern A:** Proceed to step 5 (execute via role-switch).

**Pattern B:** Execute segment-by-segment. Autonomous segments: executor role-switch for assigned tasks only (no SUMMARY/commit). Checkpoints: handle in current context. After all segments: aggregate, create SUMMARY, commit.

**Pattern C:** Execute directly in current context using step 6 (execute).

## 5. Execute via Role-Switch (Pattern A)

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name]

→ ROLE SWITCH: (act as gsd-executor following execute-plan workflow)
  Read:
  - `{phase_dir}/{plan_file}` (the PLAN.md — this IS the execution instructions, follow exactly)
  - `.planning/STATE.md`
  - `.planning/config.json`
  - `./CLAUDE.md` (if exists — follow project-specific guidelines and coding conventions)
  - `.agents/skills/` SKILL.md files (if exists — read each, follow relevant rules)
  Execute ALL tasks. Commit each task atomically. Create SUMMARY.md. Update STATE.md and ROADMAP.md.
  Follow all deviation rules, auth gates, TDD protocol as defined in this workflow.
  Return: plan name, tasks completed, SUMMARY path, commit hashes, deviations.
→ END ROLE

After role-switch: run self-check (step 12), then proceed to offer_next.

## 6. Execute (Pattern C — main context)

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name, mcp0_query-docs]

The PLAN.md IS the execution instructions. Follow exactly. If plan references CONTEXT.md: honor user's vision throughout.

Read all `@context` files referenced in the plan.

**Per task:**
- `type="auto"`: if `tdd="true"` → TDD execution (see tdd_plan_execution). Implement with deviation rules + auth gates. Verify done criteria. Commit (see task_commit). Track hash for Summary.
- `type="checkpoint:*"`: STOP → checkpoint_protocol → wait for user → continue only after confirmation.

Run `<verification>` checks after all tasks.
Confirm `<success_criteria>` met.
Document deviations in Summary.

</process>

<authentication_gates>

## Authentication Gates

Auth errors during execution are NOT failures — they're expected interaction points.

**Indicators:** "Not authenticated", "Unauthorized", 401/403, "Please run {tool} login", "Set {ENV_VAR}"

**Protocol:**
1. Recognize auth gate (not a bug)
2. STOP task execution
3. Create dynamic checkpoint:human-action with exact auth steps
4. Wait for user to authenticate
5. Verify credentials work
6. Retry original task
7. Continue normally

**In Summary:** Document as normal flow under "## Authentication Gates", not as deviations.

</authentication_gates>

<deviation_rules>

## Deviation Rules

You WILL discover unplanned work. Apply automatically, track all for Summary.

| Rule | Trigger | Action | Permission |
|------|---------|--------|------------|
| **1: Bug** | Broken behavior, errors, wrong queries, type errors, security vulns, race conditions, leaks | Fix → test → verify → track `[Rule 1 - Bug]` | Auto |
| **2: Missing Critical** | Missing essentials: error handling, validation, auth, CSRF/CORS, rate limiting, indexes, logging | Add → test → verify → track `[Rule 2 - Missing Critical]` | Auto |
| **3: Blocking** | Prevents completion: missing deps, wrong types, broken imports, missing env/config/files, circular deps | Fix blocker → verify proceeds → track `[Rule 3 - Blocking]` | Auto |
| **4: Architectural** | Structural change: new DB table, schema change, new service, switching libs, breaking API, new infra | STOP → present decision → track `[Rule 4 - Architectural]` | Ask user |

**Rule 4 format:** `⚠️ Architectural Decision Needed` — Current task, Discovery, Proposed change, Why needed, Impact, Alternatives, then ask to proceed.

**Priority:** Rule 4 (STOP) > Rules 1-3 (auto) > unsure → Rule 4

</deviation_rules>

<tdd_plan_execution>
For `type: tdd` plans — RED-GREEN-REFACTOR: 1) Infrastructure (first plan only). 2) RED: write failing test → run (MUST fail) → commit `test(...)`. 3) GREEN: minimal code → run (MUST pass) → commit `feat(...)`. 4) REFACTOR: clean up → tests pass → commit `refactor(...)`. See GSD_REFERENCES/tdd.md.
</tdd_plan_execution>

<task_commit>

## Task Commit Protocol

After each task (verification passed, done criteria met), commit immediately.

**1. Check:** run_command: `git status --short`

**2. Stage individually** (NEVER `git add .` or `git add -A`):
```
git add src/api/auth.ts
git add src/types/user.ts
```

**3. Commit format:** `{type}({phase}-{plan}): {description}` — types: feat/fix/test/refactor/perf/docs/chore

**4. Record hash:** Note commit hash for SUMMARY.

</task_commit>

<checkpoint_protocol>

## Checkpoint Protocol

On `type="checkpoint:*"`: automate first, then stop. Display box: `CHECKPOINT: [Type]` with plan, progress, details, action prompt.

| Type | Content | Resume signal |
|------|---------|---------------|
| human-verify (90%) | What was built + steps | "approved" or issues |
| decision (9%) | Decision + options | "Select: option-id" |
| human-action (1%) | ONE manual step | "done" |

WAIT for user — do NOT hallucinate completion. See GSD_REFERENCES/checkpoints.md.

</checkpoint_protocol>

<step name="generate_user_setup">

## Generate User Setup

Check plan frontmatter for `user_setup:` field.

If user_setup exists: create `{padded_phase}-USER-SETUP.md` using GSD_TEMPLATES/user-setup.md. Per service: env vars table, account setup checklist, dashboard config, local dev notes, verification commands. Status "Incomplete". Set `USER_SETUP_CREATED=true`.

If empty/missing: skip.

</step>

<step name="create_summary">

## Create Summary

[TOOL HARNESS: write_to_file]

Create `{padded_phase}-{plan_num}-SUMMARY.md` in `{phase_dir}/`. Use GSD_TEMPLATES/summary.md as structure.

**Frontmatter:** phase, plan, subsystem, tags | requires/provides/affects | tech-stack.added/patterns | key-files.created/modified | key-decisions | requirements-completed (copy `requirements` array from PLAN.md frontmatter verbatim) | duration, completed timestamp.

**Title:** `# Phase [X] Plan [Y]: [Name] Summary`

**One-liner:** SUBSTANTIVE — "JWT auth with refresh rotation using jose library" not "Authentication implemented"

Include: duration, task count, file count, commit hashes per task.

Next: more plans → "Ready for {next-plan}" | last → "Phase complete, ready for transition".

</step>

<step name="self_check">

## Self-Check

[TOOL HARNESS: find_by_name, run_command]

After creating SUMMARY.md:
- Verify first 2 files from `key-files.created` exist on disk
- run_command: `git log --oneline --all --grep="{phase}-{plan}"` → verify ≥1 commit

Append to SUMMARY.md: `## Self-Check: PASSED` or `## Self-Check: FAILED` with details.

</step>

<step name="update_state">

## Update State

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/STATE.md`. Update:
- `current_plan` → advance to next plan number
- `progress` → recalculate from disk (count PLAN.md vs SUMMARY.md files)
- `last_session.stopped_at` → "Completed {phase}-{plan}-PLAN.md"
- `decisions` → append key decisions from SUMMARY.md
- Keep STATE.md under 150 lines

</step>

<step name="update_roadmap">

## Update Roadmap

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/ROADMAP.md`. Find phase section. Update progress table row: count PLAN vs SUMMARY files on disk → update count and status (`In Progress` or `Complete` with date).

</step>

<step name="update_requirements">

## Update Requirements

[TOOL HARNESS: read_file, write_to_file]

Read PLAN.md frontmatter `requirements:` field (e.g., `requirements: [AUTH-01, AUTH-02]`).

Read `.planning/REQUIREMENTS.md`. Mark each listed requirement ID as completed (`[x]`).

If no requirements field in plan: skip.

</step>

<step name="git_commit_metadata">

## Commit Plan Metadata

[TOOL HARNESS: run_command]

Task code already committed per-task. Now commit plan metadata:

run_command: `git add {phase_dir}/{padded_phase}-{plan_num}-SUMMARY.md .planning/STATE.md .planning/ROADMAP.md .planning/REQUIREMENTS.md`
run_command: `git commit -m "docs({phase}-{plan}): complete [plan-name] plan"`

</step>

<step name="update_codebase_map">

## Update Codebase Map (if exists)

[TOOL HARNESS: read_file, write_to_file, run_command]

If `.planning/codebase/` doesn't exist: skip.

run_command: `git log --oneline --grep="feat({phase}-{plan}):" --grep="fix({phase}-{plan}):" --reverse` → get first commit hash.
run_command: `git diff --name-only {first_hash}^..HEAD 2>$null` → get changed files.

Update only structural changes:
- New `src/` directory → STRUCTURE.md
- New dependencies → STACK.md
- New file patterns → CONVENTIONS.md
- New API client → INTEGRATIONS.md
- New config → STACK.md

Skip code-only/bugfix/content changes.

If updated: run_command: `git add .planning/codebase/*.md && git commit --amend --no-edit`

</step>

<step name="offer_next">

## Offer Next

[TOOL HARNESS: find_by_name]

If `USER_SETUP_CREATED=true`: display `⚠️ USER SETUP REQUIRED` with path + env/config tasks at TOP.

Count PLAN.md vs SUMMARY.md files in phase directory.

| Condition | Route |
|-----------|-------|
| summaries < plans | **More plans:** Find next PLAN without SUMMARY. Yolo: auto-continue. Interactive: suggest `/gsd/execute-phase {phase}`. |
| summaries = plans, more phases remain | **Phase done:** Suggest `/gsd/verify-work {phase}` + `/gsd/discuss-phase {next}` |
| summaries = plans, last phase | **Milestone done:** Suggest `/gsd/complete-milestone` + `/gsd/verify-work` |

All routes: note `/clear` first for fresh context.

</step>

<success_criteria>
- [ ] All tasks from PLAN.md completed
- [ ] All verifications pass
- [ ] USER-SETUP.md generated if user_setup in frontmatter
- [ ] SUMMARY.md created with substantive content and Self-Check marker
- [ ] Each task committed individually with correct format
- [ ] STATE.md updated (position, decisions, session)
- [ ] ROADMAP.md updated with plan progress
- [ ] REQUIREMENTS.md updated with completed requirement IDs
- [ ] Codebase map updated if structural changes detected
- [ ] USER-SETUP.md prominently surfaced in completion output if created
</success_criteria>
