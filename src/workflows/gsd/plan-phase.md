---
description: Create detailed phase plan (PLAN.md files) with research, verification loop, and auto-advance. Usage: /gsd/plan-phase [phase] [--auto] [--research] [--skip-research] [--gaps] [--skip-verify]
---

<!-- GSD_HOME=~/.codeium/windsurf/get-shit-done -->

<process>

## 1. Initialize

[TOOL HARNESS: read_file, find_by_name, run_command]

Read to load all context:
- `.planning/STATE.md`
- `.planning/config.json`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md` (if exists)

From `config.json` extract: `model_profile`, `workflow.research` (research_enabled), `workflow.plan_check` (plan_checker_enabled), `workflow.auto_advance`, `commit_docs`, `nyquist_validation_enabled` (default false).

**If `.planning/` does not exist:** Error — run `/gsd/new-project` first.

## 2. Parse and Normalize Arguments

Extract from arguments: phase number, flags (`--research`, `--skip-research`, `--gaps`, `--skip-verify`, `--auto`).

Normalize phase number: `1` → `01`, `8` → `08`, `2.1` → `02.1`.

**If no phase number:** Detect next unplanned phase — find first phase in ROADMAP.md that has no directory with PLAN.md files in `.planning/phases/`.

## 3. Validate Phase

[TOOL HARNESS: read_file, find_by_name, run_command]

From already-read ROADMAP.md, find section matching phase number.
Extract: `phase_name`, `goal`, requirement IDs (lines containing REQ- identifiers).

**If phase not found:** Error — list available phases from ROADMAP.md.

Derive:
- `phase_slug` = lowercase hyphenated phase_name
- `padded_phase` = zero-padded number
- `phase_dir` = `.planning/phases/{padded_phase}-{phase_slug}`

**If phase directory missing:** run_command: `mkdir -p ".planning/phases/{padded_phase}-{phase_slug}"`

Check existing artifacts:
- `has_research` = `{padded_phase}-RESEARCH.md` exists in phase_dir
- `has_plans` = any `*-PLAN.md` exists in phase_dir
- `has_context` = `{padded_phase}-CONTEXT.md` exists in phase_dir

## 4. Load CONTEXT.md

[TOOL HARNESS: read_file]

Check if `{phase_dir}/{padded_phase}-CONTEXT.md` exists.

If exists: read it, display: `Using phase context from: {phase_dir}/{padded_phase}-CONTEXT.md`

**If CONTEXT.md does not exist:**

Use ask_user_question:
- question: "No CONTEXT.md found for Phase {X}. Plans will use research and requirements only — your design preferences won't be included. Continue or capture context first?"
- options:
  - label: "Continue without context" — description: Plan using research + requirements only
  - label: "Run discuss-phase first" — description: Capture design decisions before planning

If "Run discuss-phase first": Output "`/gsd/discuss-phase {X}`" → exit.

## 5. Handle Research

[TOOL HARNESS: read_file, write_to_file, run_command, mcp0_query-docs, search_web]

**Skip if:** `--gaps` flag, `--skip-research` flag, or `research_enabled=false` without `--research` override.

**If `has_research=true` AND no `--research` flag:** Use existing, skip to step 6.

**If RESEARCH.md missing OR `--research` flag:**

Display: `GSD ► RESEARCHING PHASE {X}`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-phase-researcher.md
  Act as gsd-phase-researcher.
  Read (all that exist):
  - `{phase_dir}/{padded_phase}-CONTEXT.md` (USER DECISIONS)
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  - `./CLAUDE.md` (if exists)
  - `.agents/skills/*.SKILL.md` (if directory exists)
  Research objective: "What do I need to know to PLAN Phase {phase_number}: {phase_name} well?"
  Phase goal: {goal from ROADMAP.md}
  Phase requirement IDs (MUST address): {phase_req_ids}
  Use mcp0_resolve-library-id + mcp0_query-docs and search_web for current information.
  Write to: `{phase_dir}/{padded_phase}-RESEARCH.md`
  Return: `## RESEARCH COMPLETE` or `## RESEARCH BLOCKED`
→ END ROLE

**Handle return:**
- `## RESEARCH COMPLETE`: Display confirmation, continue to step 5.5
- `## RESEARCH BLOCKED`: Display blocker, use ask_user_question:
  - label: "Provide context" — description: Add missing info, retry
  - label: "Skip research" — description: Continue without research
  - label: "Abort" — description: Exit workflow

## 5.5. Create Validation Strategy (if Nyquist enabled)

[TOOL HARNESS: read_file, write_to_file, run_command]

**Skip if:** `nyquist_validation_enabled=false` (default).

Check if `{phase_dir}/{padded_phase}-RESEARCH.md` contains `## Validation Architecture`.

**If found:**
1. Read `GSD_TEMPLATES/VALIDATION.md`
2. Write to `{phase_dir}/{padded_phase}-VALIDATION.md` (fill: `{N}` = phase number, `{phase-slug}`, `{date}`)
3. If `commit_docs=true`: run_command: `git add .planning/ && git commit -m "docs(phase-{N}): add validation strategy"`

**If not found:** Display: `⚠ Nyquist validation enabled but researcher did not produce a Validation Architecture section.`

## 6. Check Existing Plans

[TOOL HARNESS: find_by_name]

Check for existing `*-PLAN.md` files in `{phase_dir}`.

**If plans exist:** Use ask_user_question:
- question: "Existing plans found in Phase {X}. What would you like to do?"
- options:
  - label: "Add more plans" — description: Create additional plans alongside existing
  - label: "View existing" — description: Show plan list, then decide
  - label: "Replan from scratch" — description: Delete existing plans and replan

## 7. Resolve Context Paths

Paths already known from previous steps:
- `STATE_PATH` = `.planning/STATE.md`
- `ROADMAP_PATH` = `.planning/ROADMAP.md`
- `REQUIREMENTS_PATH` = `.planning/REQUIREMENTS.md`
- `RESEARCH_PATH` = `{phase_dir}/{padded_phase}-RESEARCH.md` (if exists)
- `CONTEXT_PATH` = `{phase_dir}/{padded_phase}-CONTEXT.md` (if exists)
- `VERIFICATION_PATH` = `{phase_dir}/{padded_phase}-VERIFICATION.md` (if exists, for --gaps)
- `UAT_PATH` = `{phase_dir}/{padded_phase}-UAT.md` (if exists, for --gaps)

## 8. Spawn gsd-planner

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search]

Display: `GSD ► PLANNING PHASE {X}`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-planner.md
  Act as gsd-planner.
  Planning context:
  - Phase: {phase_number}
  - Mode: standard (or gap_closure if --gaps)
  Read all that exist:
  - `.planning/STATE.md`
  - `.planning/ROADMAP.md`
  - `.planning/REQUIREMENTS.md`
  - `{phase_dir}/{padded_phase}-CONTEXT.md` (USER DECISIONS)
  - `{phase_dir}/{padded_phase}-RESEARCH.md`
  - `{phase_dir}/{padded_phase}-VERIFICATION.md` (if --gaps)
  - `{phase_dir}/{padded_phase}-UAT.md` (if --gaps)
  - `./CLAUDE.md` (if exists)
  - `.agents/skills/*.SKILL.md` (if exists)
  Phase requirement IDs (every ID MUST appear in a plan's `requirements` field): {phase_req_ids}
  Downstream consumer: `/gsd/execute-phase`. Plans need frontmatter (wave, depends_on, files_modified, autonomous), tasks in XML format, verification criteria, must_haves.
  Create PLAN.md files in `{phase_dir}`.
  Return: `## PLANNING COMPLETE`, `## CHECKPOINT REACHED`, or `## PLANNING INCONCLUSIVE`
→ END ROLE

## 9. Handle Planner Return

- **`## PLANNING COMPLETE`:** Display plan count. If `--skip-verify` OR `plan_checker_enabled=false`: skip to step 13. Otherwise: step 10.
- **`## CHECKPOINT REACHED`:** Present checkpoint to user, get response, re-enter planner role with continuation context.
- **`## PLANNING INCONCLUSIVE`:** Use ask_user_question:
  - label: "Add context and retry" — description: Provide missing info
  - label: "Retry as-is" — description: Re-enter planner role
  - label: "Handle manually" — description: Exit workflow

## 10. Spawn gsd-plan-checker

[TOOL HARNESS: read_file, grep_search]

Display: `GSD ► VERIFYING PLANS`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-plan-checker.md
  Act as gsd-plan-checker.
  Verification context:
  - Phase: {phase_number}
  - Phase Goal: {goal from ROADMAP.md}
  Read:
  - All `{phase_dir}/*-PLAN.md` files
  - `.planning/ROADMAP.md`
  - `.planning/REQUIREMENTS.md`
  - `{phase_dir}/{padded_phase}-CONTEXT.md` (if exists)
  - `{phase_dir}/{padded_phase}-RESEARCH.md` (if exists)
  - `./CLAUDE.md` (if exists)
  - `.agents/skills/*.SKILL.md` (if exists)
  Phase requirement IDs (MUST ALL be covered): {phase_req_ids}
  Return: `## VERIFICATION PASSED` or `## ISSUES FOUND {structured issue list}`
→ END ROLE

## 11. Handle Checker Return

- **`## VERIFICATION PASSED`:** Display confirmation, proceed to step 13.
- **`## ISSUES FOUND`:** Display issues, check iteration_count, proceed to step 12.

## 12. Revision Loop (Max 3 Iterations)

**Track `iteration_count` explicitly. State at each iteration: "Revision iteration N/3"**

**If iteration_count < 3:**

Display: `Sending back to planner for revision... (iteration {N}/3)`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-planner.md
  Act as gsd-planner in **revision mode**.
  Read:
  - All `{phase_dir}/*-PLAN.md` (existing plans)
  - `{phase_dir}/{padded_phase}-CONTEXT.md` (if exists)
  Checker issues: {structured_issues_from_checker}
  Make targeted updates only. Do NOT replan from scratch unless issues are fundamental.
  Return what changed.
→ END ROLE

Increment iteration_count → return to step 10.

**If iteration_count >= 3:**

Display: `Max iterations reached. {N} issues remain.`

Use ask_user_question:
- question: "Max plan verification iterations reached. How would you like to proceed?"
- options:
  - label: "Force proceed" — description: Accept plans as-is
  - label: "Provide guidance and retry" — description: Give direction, reset iteration count
  - label: "Abandon" — description: Exit, handle manually

## 13. Present Final Status

Route to `<offer_next>` OR auto_advance check (step 14).

## 14. Auto-Advance Check

[TOOL HARNESS: read_file]

Check `workflow.auto_advance` from already-read config.json.
Check `--auto` flag in arguments.

**If `--auto` OR `auto_advance=true`:**

Display: `GSD ► AUTO-ADVANCING TO EXECUTE`

Output: "Run `/gsd/execute-phase {X} --auto` next — `/clear` first for fresh context window."

<!-- [POSSIBLE IMPROVEMENT PI-1]: Windsurf may support workflow chaining in future.
     Currently cannot spawn execute-phase as a fresh context — user must run manually. -->

**If neither:** Show offer_next block.

</process>

<offer_next>
Display `GSD ► PHASE {X} PLANNED ✓` with wave/plan table and research/verification status.

## ▶ Next Up
`/gsd/execute-phase {X}` (/clear first)
Also: `cat .planning/phases/{phase-dir}/*-PLAN.md` | `/gsd/plan-phase {X} --research`
</offer_next>

<success_criteria>
- [ ] .planning/ directory validated
- [ ] Phase validated against ROADMAP.md
- [ ] Phase directory created if needed
- [ ] CONTEXT.md loaded early (step 4) and passed to ALL agent role-switches
- [ ] Research completed (unless --skip-research or --gaps or exists)
- [ ] gsd-phase-researcher role-switch executed with CONTEXT.md
- [ ] Existing plans checked
- [ ] gsd-planner role-switch executed with CONTEXT.md + RESEARCH.md
- [ ] Plans created (PLANNING COMPLETE or CHECKPOINT handled)
- [ ] gsd-plan-checker role-switch executed with CONTEXT.md
- [ ] Verification passed OR user override OR max iterations with user decision
- [ ] User sees status between agent role-switches
- [ ] User knows next steps
- [ ] iteration_count tracked explicitly throughout revision loop
</success_criteria>
