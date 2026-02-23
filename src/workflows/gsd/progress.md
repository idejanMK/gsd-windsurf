---
description: Check project progress, summarize recent work, and route to next action. Usage: /gsd/progress
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Check project progress, summarize recent work and what's ahead, then intelligently route to the next action — either executing an existing plan or creating the next one. Provides situational awareness before continuing work.
</purpose>

<process>

## 1. Init Context

[TOOL HARNESS: read_file, find_by_name]

Check if `.planning/` directory exists.

**If not:** Display "No planning structure found. Run `/gsd/new-project` to start." → exit.

Read:
- `.planning/STATE.md`
- `.planning/ROADMAP.md` (if exists)
- `.planning/PROJECT.md` (if exists)
- `.planning/config.json` (if exists)

**If ROADMAP.md missing but PROJECT.md exists:** Go to Route F (between milestones).
**If both missing:** Display "Run `/gsd/new-project` to start." → exit.

## 2. Analyze Roadmap

[TOOL HARNESS: find_by_name, read_file]

From ROADMAP.md, extract all phases with:
- Phase number, name, goal
- Directory path in `.planning/phases/`

For each phase directory found: count `*-PLAN.md` and `*-SUMMARY.md` files.

Determine:
- `current_phase` = first phase with incomplete plans (plans > summaries) OR first unplanned phase
- `completed_count` = phases where all plans have summaries
- `phase_count` = total phases
- `progress_percent` = (completed_count / phase_count) * 100

## 3. Recent Work

[TOOL HARNESS: find_by_name, read_file]

Find the 2-3 most recently modified `*-SUMMARY.md` files.

From each, extract the one-liner (first substantive line after the title).

## 4. Report

[TOOL HARNESS: read_file]

Build progress bar: `[` + `█` × (progress_percent / 10) + `░` × (10 - progress_percent / 10) + `]`

Read STATE.md for: decisions, blockers, pending todos, paused_at.

Check for active debug sessions: find `*-UAT.md` files with `status: diagnosed`.

Present:
```
# {Project Name}

**Progress:** [██████░░░░] {X}%
**Profile:** {model_profile from config.json}

## Recent Work
- {Phase X, Plan Y}: {one-liner from SUMMARY.md}
- {Phase X, Plan Z}: {one-liner from SUMMARY.md}

## Current Position
Phase {N} of {total}: {phase-name}
Plan {M} of {phase-total}: {status}
CONTEXT: {✓ if CONTEXT.md exists | - if not}

## Key Decisions Made
- {from STATE.md decisions section}

## Blockers/Concerns
- {from STATE.md blockers section, or "None"}

## Pending Todos
- {count} pending — /gsd/check-todos to review

## Active Debug Sessions
- {count} active — /gsd/debug to continue
(Only show if count > 0)

## What's Next
{Next phase/plan objective}
```

## 5. Route

[TOOL HARNESS: find_by_name, read_file]

**Step 1: Count plans, summaries, and UAT gaps in current phase**

For current phase directory:
- Count `*-PLAN.md` files
- Count `*-SUMMARY.md` files
- Find `*-UAT.md` files with `status: diagnosed`

State: "This phase has {X} plans, {Y} summaries."

**Step 2: Route based on counts**

| Condition | Meaning | Action |
|-----------|---------|--------|
| uat_with_gaps > 0 | UAT gaps need fix plans | Route E |
| summaries < plans | Unexecuted plans exist | Route A |
| summaries = plans AND plans > 0 | Phase complete | Step 3 |
| plans = 0 | Phase not yet planned | Route B |

---

**Route A: Unexecuted plan exists**

Find first PLAN.md without matching SUMMARY.md. Read its `<objective>`.

```
---

## ▶ Next Up

**{phase}-{plan}: {Plan Name}** — {objective from PLAN.md}

`/gsd/execute-phase {phase}`

<sub>`/clear` first → fresh context window</sub>

---
```

---

**Route B: Phase needs planning**

Check if `{padded_phase}-CONTEXT.md` exists in phase directory.

**If CONTEXT.md exists:**
```
---

## ▶ Next Up

**Phase {N}: {Name}** — {Goal from ROADMAP.md}
<sub>✓ Context gathered, ready to plan</sub>

`/gsd/plan-phase {phase-number}`

<sub>`/clear` first → fresh context window</sub>

---
```

**If CONTEXT.md does NOT exist:**
```
---

## ▶ Next Up

**Phase {N}: {Name}** — {Goal from ROADMAP.md}

`/gsd/discuss-phase {phase}` — gather context and clarify approach

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/plan-phase {phase}` — skip discussion, plan directly
- `/gsd/list-phase-assumptions {phase}` — see Claude's assumptions

---
```

---

**Route E: UAT gaps need fix plans**
```
---

## ⚠ UAT Gaps Found

**{padded_phase}-UAT.md** has {N} gaps requiring fixes.

`/gsd/plan-phase {phase} --gaps`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/execute-phase {phase}` — execute phase plans
- `/gsd/verify-work {phase}` — run more UAT testing

---
```

---

**Step 3: Check milestone status (only when phase complete)**

Identify current phase number and highest phase number in ROADMAP.md.

| Condition | Action |
|-----------|--------|
| current phase < highest phase | Route C |
| current phase = highest phase | Route D |

---

**Route C: Phase complete, more phases remain**
```
---

## ✓ Phase {Z} Complete

## ▶ Next Up

**Phase {Z+1}: {Name}** — {Goal from ROADMAP.md}

`/gsd/discuss-phase {Z+1}` — gather context and clarify approach

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/plan-phase {Z+1}` — skip discussion, plan directly
- `/gsd/verify-work {Z}` — user acceptance test before continuing

---
```

---

**Route D: Milestone complete**
```
---

## 🎉 Milestone Complete

All {N} phases finished!

## ▶ Next Up

**Complete Milestone** — archive and prepare for next

`/gsd/complete-milestone`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/verify-work` — user acceptance test before completing milestone

---
```

---

**Route F: Between milestones (ROADMAP.md missing, PROJECT.md exists)**

Read MILESTONES.md for last completed milestone version.

```
---

## ✓ Milestone v{X.Y} Complete

Ready to plan the next milestone.

## ▶ Next Up

**Start Next Milestone** — questioning → research → requirements → roadmap

`/gsd/new-milestone`

<sub>`/clear` first → fresh context window</sub>

---
```

</process>

<success_criteria>
- [ ] Rich context provided (recent work, decisions, issues)
- [ ] Current position clear with visual progress bar
- [ ] What's next clearly explained with correct route
- [ ] Smart routing: execute-phase if plans exist, plan-phase if not
- [ ] UAT gaps detected and surfaced
- [ ] Between-milestone state handled (Route F)
</success_criteria>
