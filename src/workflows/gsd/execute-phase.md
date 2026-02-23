---
description: Execute all plans in a phase using wave-based execution. Usage: /gsd/execute-phase [phase] [--auto] [--gaps-only] [--no-transition]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Execute all plans in a phase using wave-based execution. Orchestrator stays lean — delegates plan execution to gsd-executor role-switches. Orchestrator: discover plans → analyze deps → group waves → execute agents → handle checkpoints → collect results.
</purpose>

<core_principle>
Orchestrator coordinates, not executes. Each executor role-switch reads the full execute-plan workflow. Orchestrator: discover plans → analyze deps → group waves → execute → handle checkpoints → collect results.
</core_principle>

<required_reading>
Read before starting:
- GSD_HOME/references/ui-brand.md
- GSD_HOME/references/checkpoints.md
- GSD_HOME/references/tdd.md
</required_reading>

<process>

## 1. Initialize

[TOOL HARNESS: read_file, find_by_name, run_command]

Read to load context:
- `.planning/STATE.md`
- `.planning/config.json`
- `.planning/ROADMAP.md`

Extract from config.json: `commit_docs`, `parallelization` (note: always false in Windsurf — sequential only), `branching_strategy`, `phase_branch_template`, `milestone_branch_template`, `model_profile`.

Parse phase number from arguments (normalize: `1` → `01`).

Find phase directory: search `.planning/phases/` for directory matching `{padded_phase}-*`.

**If phase directory not found:** Error — phase directory not found. Run `/gsd/plan-phase {X}` first.

Find all `*-PLAN.md` files in phase directory.

**If no PLAN.md files found:** Error — no plans found. Run `/gsd/plan-phase {X}` first.

**If STATE.md missing but `.planning/` exists:** Use ask_user_question:
- question: "STATE.md is missing. How would you like to proceed?"
- options:
  - label: "Reconstruct STATE.md" — description: Rebuild from ROADMAP.md and git log
  - label: "Continue anyway" — description: Proceed without STATE.md

## 2. Handle Branching

[TOOL HARNESS: run_command]

Check `branching_strategy` from config.json:

**"none" (default):** Skip, continue on current branch.

**"phase":** Derive branch name from `phase_branch_template` (e.g., `gsd/phase-{padded_phase}-{phase_slug}`).
run_command: `git checkout -b "{branch_name}" 2>$null; if ($LASTEXITCODE -ne 0) { git checkout "{branch_name}" }`

**"milestone":** Derive branch name from `milestone_branch_template`.
run_command: same pattern as above.

## 3. Validate Phase

Report: "Found {plan_count} plans in {phase_dir} ({incomplete_count} incomplete)"

Incomplete = PLAN.md with no matching SUMMARY.md.

## 4. Discover and Group Plans

[TOOL HARNESS: read_file, find_by_name]

Read each `*-PLAN.md` frontmatter to extract: `wave`, `depends_on`, `autonomous`, `objective`, `files_modified`.

Find matching `*-SUMMARY.md` files — plans with SUMMARY are already complete, skip them (unless `--gaps-only` in which case also skip non-gap_closure plans).

**If all plans filtered:** "No matching incomplete plans." → exit.

Group plans by wave number.

Report:
```
## Execution Plan

**Phase {X}: {Name}** — {total_plans} plans across {wave_count} waves

| Wave | Plans | What it builds |
|------|-------|----------------|
| 1 | 01-01, 01-02 | {from plan objectives} |
| 2 | 01-03 | ... |
```

## 5. Execute Waves

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name]

Execute each wave in sequence. Within a wave: sequential (Windsurf limitation — no true parallelism).

**For each plan in each wave:**

**1. Describe what's being built (BEFORE executing):**

Read plan's `<objective>`. Display:
```
---
## Wave {N} — Plan {plan_id}: {Plan Name}

{2-3 sentences: what this builds, technical approach, why it matters}

Executing...
---
```

**2. Execute via role-switch:**

→ ROLE SWITCH: Read GSD_WORKFLOWS/execute-plan.md
  Act as gsd-executor following the execute-plan workflow completely.
  Read:
  - `{phase_dir}/{plan_file}` (the PLAN.md — this IS the execution instructions)
  - `.planning/STATE.md`
  - `.planning/config.json` (if exists)
  - `./CLAUDE.md` (if exists — follow project-specific guidelines)
  - `.agents/skills/` SKILL.md files (if exists)
  Execute ALL tasks in the plan. Commit each task atomically. Create SUMMARY.md. Update STATE.md and ROADMAP.md.
  Return: plan name, tasks completed, SUMMARY path, commit hashes, any deviations or checkpoints.
→ END ROLE

**3. Spot-check after completion:**

- Verify first 2 files from SUMMARY.md `key-files.created` exist on disk
- run_command: `git log --oneline --all --grep="{phase}-{plan}"` → verify ≥1 commit
- Check SUMMARY.md for `## Self-Check: FAILED` marker

If ANY spot-check fails: report which plan failed. Use ask_user_question:
- question: "Plan {plan_id} spot-check failed. How would you like to proceed?"
- options:
  - label: "Retry plan" — description: Re-enter executor role for this plan
  - label: "Continue with remaining" — description: Skip this plan, continue

If pass:
```
---
## Wave {N} — Plan {plan_id} Complete ✓

{What was built — from SUMMARY.md one-liner}
{Notable deviations, if any}
{If more plans/waves: what this enables next}
---
```

**4. Handle checkpoints:**

If executor role-switch returns a checkpoint (autonomous: false plan):

Read `workflow.auto_advance` from config.json:

**If auto_advance=true:**
- `human-verify` type → auto-approve, log `⚡ Auto-approved checkpoint`
- `decision` type → auto-select first option, log `⚡ Auto-selected: [option]`
- `human-action` type → present to user (cannot automate auth gates)

**Standard flow:**
Present checkpoint using checkpoint box format from ui-brand.md.
Wait for user response.
Re-enter executor role with continuation context (completed tasks state + user response).

**5. Proceed to next plan/wave.**

## 6. Aggregate Results

After all waves:

```
## Phase {X}: {Name} Execution Complete

**Waves:** {N} | **Plans:** {M}/{total} complete

| Wave | Plans | Status |
|------|-------|--------|
| 1 | plan-01, plan-02 | ✓ Complete |
| 2 | plan-03 | ✓ Complete |

### Plan Details
1. **{phase}-01**: [one-liner from SUMMARY.md]
2. **{phase}-02**: [one-liner from SUMMARY.md]

### Issues Encountered
[Aggregate from SUMMARYs, or "None"]
```

## 7. Close Parent Artifacts (decimal phases only)

[TOOL HARNESS: read_file, write_to_file, run_command]

**Skip if** phase number has no decimal (e.g., `3`, `04`). Only applies to gap-closure phases like `4.1`, `03.1`.

If phase_number contains `.`:
- Derive parent phase: `PARENT_PHASE = phase_number.split('.')[0]`
- Find parent phase directory in `.planning/phases/`
- Find `*-UAT.md` in parent phase directory

**If parent UAT found:**
1. Read UAT file's `## Gaps` section
2. For each gap with `status: failed` → update to `status: resolved`
3. If all gaps resolved: update frontmatter `status: diagnosed` → `status: resolved`, update `updated:` timestamp
4. For each gap with `debug_session:` field: read debug file, update status → resolved, move to `.planning/debug/resolved/`
5. run_command: `git add .planning/phases/ .planning/debug/`
6. run_command: `git commit -m "docs(phase-{PARENT_PHASE}): resolve UAT gaps after {phase_number} gap closure"`

## 8. Verify Phase Goal

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search]

Verify phase achieved its GOAL, not just completed tasks.

From already-read ROADMAP.md: extract phase goal and requirement IDs.

Display: `◆ Spawning verifier...`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-verifier.md
  Act as gsd-verifier.
  Read:
  - All `{phase_dir}/*-SUMMARY.md` files
  - All `{phase_dir}/*-PLAN.md` files
  - `.planning/ROADMAP.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  Phase goal: {goal from ROADMAP.md}
  Phase requirement IDs: {phase_req_ids}
  Check must_haves against actual codebase.
  Cross-reference requirement IDs from PLAN frontmatter against REQUIREMENTS.md — every ID MUST be accounted for.
  Write: `{phase_dir}/{padded_phase}-VERIFICATION.md`
  Return: status (passed / human_needed / gaps_found) + summary
→ END ROLE

Read `{phase_dir}/{padded_phase}-VERIFICATION.md` frontmatter for status.

| Status | Action |
|--------|--------|
| `passed` | → step 9 (update_roadmap) |
| `human_needed` | Present items for human testing, get approval or feedback |
| `gaps_found` | Present gap summary, offer `/gsd/plan-phase {phase} --gaps` |

**If human_needed:**
```
## ✓ Phase {X}: {Name} — Human Verification Required

All automated checks passed. {N} items need human testing:

{From VERIFICATION.md human_verification section}
```
Wait for user: "approved" → step 9 | Issues reported → treat as gaps_found.

**If gaps_found:**
```
## ⚠ Phase {X}: {Name} — Gaps Found

**Report:** {phase_dir}/{padded_phase}-VERIFICATION.md

### What's Missing
{Gap summaries from VERIFICATION.md}

---
## ▶ Next Up

`/gsd/plan-phase {X} --gaps`

<sub>`/clear` first → fresh context window</sub>
```
Exit workflow (do not proceed to update_roadmap).

## 9. Update Roadmap

[TOOL HARNESS: read_file, write_to_file, run_command]

Mark phase complete in all tracking files:

1. Read `.planning/ROADMAP.md` → find phase section → mark checkbox `[x]` with completion date → update Progress table (Status → Complete, date)
2. Read `.planning/STATE.md` → advance current_phase to next phase → update progress bar
3. Read `.planning/REQUIREMENTS.md` → mark all phase requirement IDs as completed

run_command: `git add .planning/ROADMAP.md .planning/STATE.md .planning/REQUIREMENTS.md {phase_dir}/{padded_phase}-VERIFICATION.md`
run_command: `git commit -m "docs(phase-{X}): complete phase execution"`

Extract from ROADMAP.md: `next_phase`, `next_phase_name`, `is_last_phase`.

## 10. Offer Next

**If `--no-transition` flag present** (spawned by auto-advance chain):

Return completion status:
```
## PHASE COMPLETE

Phase: {phase_number} - {phase_name}
Plans: {completed_count}/{total_count}
Verification: Passed
```
STOP. Do not proceed to auto-advance or transition.

**If `--no-transition` NOT present:**

Check `--auto` flag and `workflow.auto_advance` from config.json.

**If auto-advance enabled AND verification passed:**

Display:
```
╔══════════════════════════════════════════╗
║  AUTO-ADVANCING → TRANSITION             ║
╚══════════════════════════════════════════╝
```

Read and follow `GSD_WORKFLOWS/transition.md` inline (do NOT spawn as separate role-switch — orchestrator context already has phase completion data needed).

**If not auto-advance:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PHASE {X} COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Phase {X+1}: {next_phase_name}**

`/gsd/discuss-phase {X+1}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `/gsd/verify-work {X}` — run UAT testing first
- `/gsd/plan-phase {X+1}` — skip discussion, plan directly

───────────────────────────────────────────────────────────────
```

</process>

<context_efficiency>
Orchestrator stays lean. Each executor role-switch reads the full execute-plan workflow and all plan files itself. Orchestrator only receives SUMMARY confirmation + spot-check results.
</context_efficiency>

<failure_handling>
- **Executor returns checkpoint:** Present to user, re-enter executor with continuation context
- **Spot-check fails:** Report, ask user: retry or continue
- **Dependency chain breaks:** Wave 1 fails → Wave 2 dependents likely fail → user chooses attempt or skip
- **Checkpoint unresolvable:** "Skip this plan?" or "Abort phase?" → record partial progress in STATE.md
</failure_handling>

<resumption>
Re-run `/gsd/execute-phase {phase}` → step 4 finds completed SUMMARYs → skips them → resumes from first incomplete plan → continues wave execution.
</resumption>

<success_criteria>
- [ ] Phase directory found with plans
- [ ] Branching strategy applied if configured
- [ ] Plans discovered, grouped by wave, incomplete filtered
- [ ] Each plan described before execution
- [ ] Each plan executed via execute-plan role-switch
- [ ] Each plan spot-checked after completion
- [ ] Checkpoints handled (auto or interactive)
- [ ] Decimal phase parent artifacts closed if applicable
- [ ] gsd-verifier role-switch executed → VERIFICATION.md created
- [ ] Gaps or human verification handled appropriately
- [ ] ROADMAP.md, STATE.md, REQUIREMENTS.md updated → committed
- [ ] User knows next steps
</success_criteria>
