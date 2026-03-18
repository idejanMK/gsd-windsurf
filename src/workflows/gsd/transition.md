---
description: "Mark current phase complete and advance to next. Usage: /gsd/transition"
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Mark current phase complete and advance to next. This is the natural point where progress tracking and PROJECT.md evolution happen.

"Planning next phase" = "current phase is done"
</purpose>

<required_reading>
Read before starting:
- `.planning/STATE.md`
- `.planning/PROJECT.md`
- `.planning/ROADMAP.md`
- Current phase's plan files (`*-PLAN.md`)
- Current phase's summary files (`*-SUMMARY.md`)
</required_reading>

<process>

## 1. Load Project State

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/STATE.md` → parse current_phase, current position.
Read `.planning/PROJECT.md` → note accumulated context that may need updating.
Read `.planning/ROADMAP.md` → identify all phases, current phase details.
Read `.planning/config.json` → extract mode (yolo/interactive), commit_docs.

## 2. Verify Completion

[TOOL HARNESS: find_by_name]

Check current phase has all plan summaries:
- Count `*-PLAN.md` files in current phase directory
- Count `*-SUMMARY.md` files in current phase directory

**If all plans complete:**

Read config mode:

**YOLO mode:**
```
⚡ Auto-approved: Transition Phase [X] → Phase [X+1]
Phase [X] complete — all [Y] plans finished.

Proceeding to mark done and advance...
```
Proceed directly to cleanup_handoff step.

**Interactive mode:**
Use ask_user_question:
- question: "Phase [X] complete — all [Y] plans finished. Ready to mark done and move to Phase [X+1]?"
- options:
  - label: "Yes, advance" — description: Mark complete and advance
  - label: "Not yet" — description: Stay on current phase

**If plans incomplete:**

**SAFETY RAIL: Always confirm regardless of mode — skipping incomplete plans is destructive.**

Display:
```
Phase [X] has incomplete plans:
- {phase}-01-SUMMARY.md ✓ Complete
- {phase}-02-SUMMARY.md ✗ Missing
- {phase}-03-SUMMARY.md ✗ Missing

⚠️ Safety rail: Skipping plans requires confirmation (destructive action)
```

Use ask_user_question:
- question: "Phase [X] has incomplete plans. What would you like to do?"
- options:
  - label: "Continue current phase" — description: Execute remaining plans
  - label: "Mark complete anyway" — description: Skip remaining plans
  - label: "Review what's left" — description: Show remaining plan details

## 3. Cleanup Handoff

[TOOL HARNESS: find_by_name, run_command]

Check for lingering handoffs in current phase directory: `*/.continue-here*.md`

If found: delete them — phase is complete, handoffs are stale.
run_command: `Remove-Item ".planning/phases/{current_phase_dir}/.continue-here*.md" -ErrorAction SilentlyContinue`

## 4. Update ROADMAP.md and STATE.md

[TOOL HARNESS: read_file, write_to_file]

In ROADMAP.md:
- Mark the phase checkbox as `[x]` complete with today's date
- Update plan count to final (e.g., "3/3 plans complete")
- Update Progress table: Status → Complete, add date

In STATE.md:
- Advance current_phase to next phase
- Status → "Ready to plan"
- Current Plan → "Not started"

Extract: `completed_phase`, `plans_executed`, `next_phase`, `next_phase_name`.

Determine `is_last_phase`: check if completed_phase is the highest phase number in ROADMAP.md.

## 5. Evolve PROJECT.md

[TOOL HARNESS: read_file, write_to_file]

Read all phase summaries for completed phase.

Assess requirement changes:

1. **Requirements validated?** Any Active requirements shipped → move to Validated with phase reference: `- ✓ [Requirement] — Phase X`
2. **Requirements invalidated?** Any discovered unnecessary → move to Out of Scope with reason
3. **Requirements emerged?** Any new requirements discovered → add to Active
4. **Decisions to log?** Extract decisions from SUMMARY.md files → add to Key Decisions table
5. **"What This Is" still accurate?** If product meaningfully changed → update description

Update PROJECT.md footer: `*Last updated: {date} after Phase {X}*`

## 6. Update STATE.md Progress Bar

[TOOL HARNESS: read_file, write_to_file]

Calculate progress: (completed_phases / total_phases) * 100

Build progress bar: `[` + `█` × (progress_percent / 10) + `░` × (10 - progress_percent / 10) + `]`

Update progress bar line in STATE.md.

## 7. Update Project Reference

[TOOL HARNESS: write_to_file]

Update Project Reference section in STATE.md:
```markdown
## Project Reference

See: .planning/PROJECT.md (updated {today})

**Core value:** {Current core value from PROJECT.md}
**Current focus:** {Next phase name}
```

## 8. Review Accumulated Context

[TOOL HARNESS: read_file, write_to_file]

Review and update Accumulated Context section in STATE.md:

**Decisions:** Note recent decisions from this phase (3-5 max). Full log lives in PROJECT.md.

**Blockers/Concerns:**
- If addressed in this phase: Remove from list
- If still relevant: Keep with "Phase X" prefix
- Add new concerns from completed phase's summaries

## 9. Update Session Continuity

[TOOL HARNESS: write_to_file]

Update Session Continuity section in STATE.md:
```markdown
Last session: {today}
Stopped at: Phase {X} complete, ready to plan Phase {X+1}
Resume file: None
```

## 10. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add .planning/ROADMAP.md .planning/PROJECT.md .planning/STATE.md`
run_command: `git commit -m "docs: complete phase {X} - {phase_name}"`

## 11. Offer Next Phase

**MANDATORY: Verify milestone status before presenting next steps.**

**Route A: More phases remain in milestone**

Check if next phase has CONTEXT.md.

**YOLO mode:**

If CONTEXT.md exists:
```
Phase {X} marked complete.

Next: Phase {X+1} — {Name}

⚡ Auto-continuing: Plan Phase {X+1} in detail
```
Output: `/gsd/plan-phase {X+1}`

If CONTEXT.md does NOT exist:
```
Phase {X} marked complete.

Next: Phase {X+1} — {Name}

⚡ Auto-continuing: Discuss Phase {X+1} first
```
Output: `/gsd/discuss-phase {X+1}`

**Interactive mode:**

If CONTEXT.md does NOT exist:
```
## ✓ Phase {X} Complete

---

## ▶ Next Up

**Phase {X+1}: {Name}** — {Goal from ROADMAP.md}

`/gsd/discuss-phase {X+1}` — gather context and clarify approach

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/plan-phase {X+1}` — skip discussion, plan directly
- `/gsd/research-phase {X+1}` — investigate unknowns

---
```

If CONTEXT.md exists:
```
## ✓ Phase {X} Complete

---

## ▶ Next Up

**Phase {X+1}: {Name}** — {Goal from ROADMAP.md}
<sub>✓ Context gathered, ready to plan</sub>

`/gsd/plan-phase {X+1}`

<sub>`/clear` first → fresh context window</sub>

---
```

---

**Route B: Milestone complete (all phases done)**

**YOLO mode:**
```
Phase {X} marked complete.

🎉 Milestone {version} is 100% complete — all {N} phases finished!

⚡ Auto-continuing: Complete milestone and archive
```
Output: `/gsd/complete-milestone`

**Interactive mode:**
```
## ✓ Phase {X}: {Phase Name} Complete

🎉 Milestone {version} is 100% complete — all {N} phases finished!

---

## ▶ Next Up

**Complete Milestone {version}** — archive and prepare for next

`/gsd/complete-milestone`

<sub>`/clear` first → fresh context window</sub>

---
```

</process>

<partial_completion>
If user wants to move on but phase isn't fully complete:

Use ask_user_question:
- question: "Phase {X} has incomplete plans. How would you like to proceed?"
- options:
  - label: "Mark complete anyway" — description: Plans weren't needed
  - label: "Defer work to later phase" — description: Create a new phase for remaining work
  - label: "Stay and finish" — description: Execute remaining plans

If marking complete with incomplete plans:
- Update ROADMAP: "2/3 plans complete" (not "3/3")
- Note in transition message which plans were skipped
</partial_completion>

<success_criteria>
- [ ] Current phase plan summaries verified (all exist or user chose to skip)
- [ ] Stale handoffs deleted
- [ ] ROADMAP.md updated with completion status and plan count
- [ ] PROJECT.md evolved (requirements, decisions, description if needed)
- [ ] STATE.md updated (position, project reference, context, session)
- [ ] Progress bar updated
- [ ] Committed (if commit_docs=true)
- [ ] User knows next steps
</success_criteria>
