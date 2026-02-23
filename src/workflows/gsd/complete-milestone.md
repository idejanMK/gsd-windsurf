---
description: Mark a shipped version as complete. Creates historical record, evolves PROJECT.md, reorganizes ROADMAP.md, tags release. Usage: /gsd/complete-milestone
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Mark a shipped version (v1.0, v1.1, v2.0) as complete. Creates historical record in MILESTONES.md, performs full PROJECT.md evolution review, reorganizes ROADMAP.md with milestone groupings, and tags the release in git.
</purpose>

<required_reading>
Read before starting:
- GSD_TEMPLATES/milestone.md
- GSD_TEMPLATES/milestone-archive.md
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/PROJECT.md`
</required_reading>

<archival_behavior>
When a milestone completes:
1. Extract full milestone details to `.planning/milestones/v{X.Y}-ROADMAP.md`
2. Archive requirements to `.planning/milestones/v{X.Y}-REQUIREMENTS.md`
3. Update ROADMAP.md — replace milestone details with one-line summary
4. Delete REQUIREMENTS.md (fresh one for next milestone)
5. Perform full PROJECT.md evolution review
6. Offer to create next milestone inline
</archival_behavior>

<process>

## 1. Verify Readiness

[TOOL HARNESS: read_file, find_by_name, run_command]

Read `.planning/ROADMAP.md` to identify all phases in this milestone.

For each phase, check: does a matching directory exist in `.planning/phases/`? Does every PLAN.md have a matching SUMMARY.md?

Read `.planning/REQUIREMENTS.md` traceability table: count total v1 requirements vs checked-off (`[x]`) requirements.

Present:
```
Milestone: {Name, e.g., "v1.0 MVP"}

Includes:
- Phase 1: Foundation (2/2 plans complete)
- Phase 2: Authentication (2/2 plans complete)

Total: {phase_count} phases, {total_plans} plans, all complete
Requirements: {N}/{M} v1 requirements checked off
```

**If requirements incomplete (N < M):**

Display unchecked requirements. Use ask_user_question:
- question: "Some requirements are not checked off. How would you like to proceed?"
- options:
  - label: "Proceed anyway" — description: Mark milestone complete with known gaps
  - label: "Run audit first" — description: Run /gsd/audit-milestone to assess gap severity
  - label: "Abort" — description: Return to development

If "Proceed anyway": note incomplete requirements in MILESTONES.md under `### Known Gaps`.

**If mode=yolo (from config.json):** Auto-approve scope verification, proceed to gather_stats.

**If mode=interactive:** Use ask_user_question:
- question: "Ready to mark this milestone as shipped?"
- options:
  - label: "Yes, ship it" — description: Mark complete and archive
  - label: "Wait" — description: Stop, I'll return when ready
  - label: "Adjust scope" — description: Change which phases are included

## 2. Gather Stats

[TOOL HARNESS: run_command]

run_command: `git log --oneline --grep="feat(" | Select-Object -First 20`
run_command: `git log --format="%ai" | Select-Object -Last 1` (start date)
run_command: `git log --format="%ai" | Select-Object -First 1` (end date)

Read all SUMMARY.md files in phase directories to count tasks and files modified.

Display:
```
Milestone Stats:
- Phases: {X-Y}
- Plans: {Z} total
- Tasks: {N} total (from phase summaries)
- Timeline: {Days} days ({Start} → {End})
```

## 3. Extract Accomplishments

[TOOL HARNESS: read_file, find_by_name]

Read all `*-SUMMARY.md` files in all phase directories.

Extract one-liner from each SUMMARY.md. Synthesize 4-6 key accomplishments.

Display:
```
Key accomplishments for this milestone:
1. {Achievement from phase 1}
2. {Achievement from phase 2}
...
```

## 4. Evolve PROJECT.md (Full Review)

[TOOL HARNESS: read_file, write_to_file]

Full PROJECT.md evolution review at milestone completion.

Read all phase summaries. Then review and update PROJECT.md:

1. **"What This Is" accuracy:** Compare description to what was built. Update if meaningfully changed.

2. **Core Value check:** Still the right priority? Update if the ONE thing has shifted.

3. **Requirements audit:**
   - All Active requirements shipped this milestone → Move to Validated: `- ✓ {Requirement} — v{X.Y}`
   - Remove requirements moved to Validated from Active section
   - Add new requirements for next milestone to Active
   - Audit Out of Scope — reasoning still valid?

4. **Context update:** Current codebase state (tech stack, LOC estimate), user feedback themes, known issues.

5. **Key Decisions audit:** Extract all decisions from milestone phase summaries. Add to Key Decisions table with outcomes. Mark ✓ Good, ⚠️ Revisit, or — Pending.

6. **Constraints check:** Any constraints changed? Update as needed.

Update "Last updated" footer: `*Last updated: {date} after v{X.Y} milestone*`

## 5. Reorganize ROADMAP.md

[TOOL HARNESS: read_file, write_to_file]

Update `.planning/ROADMAP.md` — group completed milestone phases under collapsible section:

```markdown
# Roadmap: {Project Name}

## Milestones

- ✅ **v{X.Y} {Name}** — Phases {A}-{B} (shipped {date})
- 🚧 **v{next} {Name}** — Phases {C}-{D} (planned)

## Phases

<details>
<summary>✅ v{X.Y} {Name} (Phases {A}-{B}) — SHIPPED {date}</summary>

- [x] Phase {A}: {Name} ({N}/{N} plans) — completed {date}
- [x] Phase {B}: {Name} ({N}/{N} plans) — completed {date}

</details>

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| {A}. {Name} | v{X.Y} | {N}/{N} | Complete | {date} |
```

## 6. Archive Milestone

[TOOL HARNESS: write_to_file, run_command, find_by_name]

run_command: `mkdir -p .planning/milestones`

**Archive ROADMAP.md:**

Read `.planning/ROADMAP.md`. Write to `.planning/milestones/v{X.Y}-ROADMAP.md` using GSD_TEMPLATES/milestone-archive.md as header structure. Include: milestone header (status, phases, date), full phase details, milestone summary (decisions, issues, tech debt).

**Archive REQUIREMENTS.md:**

Read `.planning/REQUIREMENTS.md`. Write to `.planning/milestones/v{X.Y}-REQUIREMENTS.md` with archive header: all requirements marked complete with outcomes, traceability table with final status.

**Create/update MILESTONES.md:**

Read existing `.planning/MILESTONES.md` (if exists). Append new entry using GSD_TEMPLATES/milestone.md as structure:
- Version, name, date shipped
- Stats (phases, plans, tasks, timeline)
- Key accomplishments (from step 3)
- Known gaps (if any from step 1)

**Update STATE.md:**

Update: `status = milestone complete`, `last_activity = {today} — Milestone v{X.Y} complete`.

**Phase archival (optional):**

Use ask_user_question:
- question: "Archive phase directories to milestones/?"
- options:
  - label: "Yes — archive phases" — description: Move to .planning/milestones/v{X.Y}-phases/
  - label: "Skip — keep phases in place" — description: Leave as raw execution history

If "Yes":
run_command: `mkdir -p .planning/milestones/v{X.Y}-phases`
Move each phase directory from `.planning/phases/` to `.planning/milestones/v{X.Y}-phases/`.

**Delete originals:**

run_command: `Remove-Item .planning/ROADMAP.md`
run_command: `Remove-Item .planning/REQUIREMENTS.md`

## 7. Handle Branches

[TOOL HARCHECK: run_command]

Read `branching_strategy` from `.planning/config.json`.

**If "none":** Skip to git_tag.

**If "phase" or "milestone":** Find relevant branches.

run_command: `git branch --list "gsd/*"` → list GSD branches.

If branches found: use ask_user_question:
- question: "Git branches detected. How would you like to handle them?"
- options:
  - label: "Squash merge to main (Recommended)" — description: Single clean commit per branch
  - label: "Merge with history" — description: Preserves all individual commits
  - label: "Delete without merging" — description: Already merged or not needed
  - label: "Keep branches" — description: Leave for manual handling

Execute chosen strategy. If commit_docs=false: strip `.planning/` from staging before merge commits.

## 8. Git Tag

[TOOL HARNESS: run_command]

run_command:
```
git tag -a v{X.Y} -m "v{X.Y} {Name}

Delivered: {one sentence}

Key accomplishments:
- {Item 1}
- {Item 2}
- {Item 3}

See .planning/MILESTONES.md for full details."
```

Display: "Tagged: v{X.Y}"

Use ask_user_question:
- question: "Push tag to remote?"
- options:
  - label: "Yes, push tag" — description: git push origin v{X.Y}
  - label: "No, keep local" — description: Tag stays local

If "Yes": run_command: `git push origin v{X.Y}`

## 9. Commit Milestone

[TOOL HARNESS: run_command]

run_command: `git add .planning/milestones/ .planning/MILESTONES.md .planning/PROJECT.md .planning/STATE.md`
run_command: `git commit -m "chore: complete v{X.Y} milestone"`

## 10. Offer Next

```
✅ Milestone v{X.Y} {Name} complete

Shipped:
- {N} phases ({M} plans)
- {One sentence of what shipped}

Archived:
- .planning/milestones/v{X.Y}-ROADMAP.md
- .planning/milestones/v{X.Y}-REQUIREMENTS.md

Summary: .planning/MILESTONES.md
Tag: v{X.Y}

---

## ▶ Next Up

**Start Next Milestone** — questioning → research → requirements → roadmap

`/gsd/new-milestone`

<sub>`/clear` first → fresh context window</sub>

---
```

</process>

<success_criteria>
- [ ] All phases verified complete (all plans have summaries)
- [ ] Requirements completion checked — incomplete surfaced with options
- [ ] Stats gathered from git log and summaries
- [ ] Key accomplishments extracted from SUMMARY.md files
- [ ] PROJECT.md full evolution review completed
- [ ] All shipped requirements moved to Validated in PROJECT.md
- [ ] Key Decisions updated with outcomes
- [ ] ROADMAP.md reorganized with milestone grouping
- [ ] Roadmap archive created (milestones/v{X.Y}-ROADMAP.md)
- [ ] Requirements archive created (milestones/v{X.Y}-REQUIREMENTS.md)
- [ ] MILESTONES.md entry created with stats and accomplishments
- [ ] REQUIREMENTS.md deleted (fresh for next milestone)
- [ ] STATE.md updated
- [ ] Git tag created (v{X.Y})
- [ ] Milestone commit made
- [ ] User knows next step (/gsd/new-milestone)
</success_criteria>
