---
description: Restore full project context and resume work. Usage: /gsd/resume-project
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Instantly restore full project context so "Where were we?" has an immediate, complete answer.
</purpose>

<required_reading>
Read before starting:
- GSD_HOME/references/continuation-format.md
</required_reading>

<trigger>
Use this workflow when:
- Starting a new session on an existing project
- User says "continue", "what's next", "where were we", "resume"
- Any planning operation when .planning/ already exists
- User returns after time away from project
</trigger>

<process>

## 1. Initialize

[TOOL HARNESS: read_file, find_by_name]

Check if `.planning/` directory exists.

**If not:** "This is a new project. Run `/gsd/new-project` to start." → exit.

Read:
- `.planning/STATE.md` (if exists)
- `.planning/PROJECT.md` (if exists)
- `.planning/ROADMAP.md` (if exists)
- `.planning/config.json` (if exists)

**If STATE.md missing but ROADMAP.md or PROJECT.md exists:** Offer to reconstruct STATE.md (see reconstruction section).
**If planning/ missing entirely:** Route to /gsd/new-project.

## 2. Load State

From STATE.md extract:
- **Project Reference**: Core value and current focus
- **Current Position**: Phase X of Y, Plan A of B, Status
- **Progress**: Visual progress bar
- **Recent Decisions**: Key decisions affecting current work
- **Pending Todos**: Ideas captured during sessions
- **Blockers/Concerns**: Issues carried forward
- **Session Continuity**: Where we left off, any resume files

From PROJECT.md extract:
- **What This Is**: Current accurate description
- **Requirements**: Validated, Active, Out of Scope
- **Key Decisions**: Full decision log with outcomes
- **Constraints**: Hard limits on implementation

## 3. Check Incomplete Work

[TOOL HARNESS: find_by_name, read_file]

Look for incomplete work:

1. **Continue-here files:** Find `*/.continue-here*.md` in `.planning/phases/`
2. **Incomplete plans:** Find `*-PLAN.md` files without matching `*-SUMMARY.md`
3. **UAT gaps:** Find `*-UAT.md` files with `status: diagnosed`

**If .continue-here file exists:**
- Read it for specific resumption context
- Flag: "Found mid-plan checkpoint"

**If PLAN without SUMMARY exists:**
- Flag: "Found incomplete plan execution"

## 4. Present Status

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  PROJECT STATUS                                               ║
╠══════════════════════════════════════════════════════════════╣
║  Building: {one-liner from PROJECT.md "What This Is"}         ║
║                                                               ║
║  Phase: {X} of {Y} - {Phase name}                            ║
║  Plan:  {A} of {B} - {Status}                                ║
║  Progress: {██████░░░░} {XX}%                                ║
║                                                               ║
║  Last activity: {date} - {what happened}                     ║
╚══════════════════════════════════════════════════════════════╝

{If incomplete work found:}
⚠️  Incomplete work detected:
    - {.continue-here file or incomplete plan}

{If pending todos exist:}
📋 {N} pending todos — /gsd/check-todos to review

{If blockers exist:}
⚠️  Carried concerns:
    - {blocker 1}
```

## 5. Determine Next Action

Based on project state, determine the most logical next action:

**If .continue-here file exists:**
→ Primary: Resume from checkpoint (read .continue-here.md, continue from `<next_action>`)
→ Option: Start fresh on current plan

**If incomplete plan (PLAN without SUMMARY):**
→ Primary: Complete the incomplete plan
→ Option: Abandon and move on

**If phase in progress, all plans complete:**
→ Primary: Transition to next phase

**If phase ready to plan:**
→ Check if CONTEXT.md exists:
  - If missing: Primary = Discuss phase vision
  - If exists: Primary = Plan the phase

**If phase ready to execute:**
→ Primary: Execute next plan

## 6. Offer Options

Present contextual options:

```
What would you like to do?

{Primary action based on state}
1. {Execute phase / Plan phase / Discuss phase / Resume checkpoint}

{Secondary options:}
2. Review current phase status
3. Check pending todos ({N} pending)
4. Something else
```

Wait for user selection (freeform).

## 7. Route to Workflow

Based on selection, output the appropriate next command:

- **Execute plan:**
  ```
  ---

  ## ▶ Next Up

  **{phase}-{plan}: {Plan Name}** — {objective from PLAN.md}

  `/gsd/execute-phase {phase}`

  <sub>`/clear` first → fresh context window</sub>

  ---
  ```

- **Plan phase:**
  ```
  ---

  ## ▶ Next Up

  **Phase {N}: {Name}** — {Goal from ROADMAP.md}

  `/gsd/plan-phase {phase-number}`

  <sub>`/clear` first → fresh context window</sub>

  ---

  **Also available:**
  - `/gsd/discuss-phase {N}` — gather context first
  - `/gsd/research-phase {N}` — investigate unknowns

  ---
  ```

- **Transition:** Run `/gsd/transition` workflow.
- **Check todos:** Read `.planning/todos/pending/`, present summary.
- **Something else:** Ask what they need.

## 8. Update Session

[TOOL HARNESS: write_to_file, run_command]

Update STATE.md `last_session` section:
```
Last session: {now}
Stopped at: Session resumed, proceeding to {action}
```

Read `.planning/config.json` → if commit_docs=true:
run_command: `git add .planning/STATE.md`
run_command: `git commit -m "docs(state): resume session"`

</process>

<reconstruction>
If STATE.md is missing but other artifacts exist:

"STATE.md missing. Reconstructing from artifacts..."

1. Read PROJECT.md → Extract "What This Is" and Core Value
2. Read ROADMAP.md → Determine phases, find current position
3. Scan `*-SUMMARY.md` files → Extract decisions, concerns
4. Count pending todos in `.planning/todos/pending/`
5. Check for `.continue-here` files → Session continuity

Reconstruct and write STATE.md using GSD_TEMPLATES/state.md as structure, then proceed normally.

This handles cases where:
- Project predates STATE.md introduction
- File was accidentally deleted
- Cloning repo without full .planning/ state
</reconstruction>

<quick_resume>
If user says "continue" or "go":
- Load state silently
- Determine primary action
- Execute immediately without presenting options

"Continuing from {state}... {action}"
</quick_resume>

<success_criteria>
- [ ] STATE.md loaded (or reconstructed)
- [ ] Incomplete work detected and flagged
- [ ] Clear status presented to user
- [ ] Contextual next actions offered
- [ ] User knows exactly where project stands
- [ ] Session continuity updated
</success_criteria>
