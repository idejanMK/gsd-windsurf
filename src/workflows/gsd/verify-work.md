---
description: Validate built features through conversational testing with persistent UAT state. Usage: /gsd/verify-work [phase]
---

<!-- GSD_HOME=~/.codeium/windsurf/get-shit-done | Show expected, ask if reality matches. User tests, Claude records. One test at a time. "yes"/"y"/empty=pass, else=issue. -->

<process>

## 1. Initialize

[TOOL HARNESS: read_file, find_by_name]

If arguments contain a phase number: normalize it (e.g., `1` → `01`).

Read `.planning/config.json` → extract `commit_docs`, `model_profile`.

If phase provided: find phase directory in `.planning/phases/` matching `{padded_phase}-*`. Extract `phase_name`.

## 2. Check Active Sessions

[TOOL HARNESS: find_by_name, read_file]

Find all `*-UAT.md` files in `.planning/phases/` subdirectories.

**If active sessions exist AND no phase argument:**

Read each file's frontmatter (status, phase) and Current Test section.

Display:
```
## Active UAT Sessions

| # | Phase | Status | Current Test | Progress |
|---|-------|--------|--------------|----------|
| 1 | 04-comments | testing | 3. Reply to Comment | 2/6 |
| 2 | 05-auth | testing | 1. Login Form | 0/4 |

Reply with a number to resume, or provide a phase number to start new.
```

Wait for user response (freeform — NOT ask_user_question).
- Number (1, 2) → load that file → `resume_from_file`
- Phase number → treat as new session → `create_uat_file`

**If active sessions exist AND phase argument provided:**

Check if session exists for that phase. If yes: use ask_user_question:
- question: "Active UAT session found for Phase {X}. Resume or restart?"
- options:
  - label: "Resume" — description: Continue from where testing stopped
  - label: "Restart" — description: Delete existing session and start fresh

**If no active sessions AND no phase argument:**
```
No active UAT sessions.

Provide a phase number to start testing (e.g., /gsd/verify-work 4)
```

**If no active sessions AND phase argument:** Continue to `find_summaries`.

## 3. Find Summaries

[TOOL HARNESS: find_by_name, read_file]

Find all `*-SUMMARY.md` files in phase directory.

Read each SUMMARY.md to extract testable deliverables.

## 4. Extract Tests

From each SUMMARY.md, parse:
1. **Accomplishments** — Features/functionality added
2. **User-facing changes** — UI, workflows, interactions

Focus on USER-OBSERVABLE outcomes, not implementation details.

For each deliverable, create a test:
- `name`: Brief test name
- `expected`: What the user should see/experience (specific, observable)

Skip internal/non-observable items (refactors, type changes, etc.).

## 5. Create UAT File

[TOOL HARNESS: write_to_file, run_command]

Build test list from extracted deliverables.

Create `.planning/phases/{phase_dir}/{padded_phase}-UAT.md` using GSD_TEMPLATES/UAT.md as structure:

```markdown
---
status: testing
phase: {padded_phase}-{phase_slug}
source: [{list of SUMMARY.md files}]
started: {ISO timestamp}
updated: {ISO timestamp}
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 1
name: [first test name]
expected: |
  [what user should observe]
awaiting: user response

## Tests

### 1. [Test Name]
expected: [observable behavior]
result: [pending]

...

## Summary

total: [N]
passed: 0
issues: 0
pending: [N]
skipped: 0

## Gaps

[none yet]
```

Proceed to `present_test`.

## 6. Present Test

[TOOL HARNESS: read_file]

Read Current Test section from UAT file.

Display checkpoint box: `CHECKPOINT: Verification Required` with test number, name, expected behavior, then `→ Type "pass" or describe what's wrong`.

Wait for user response (plain text, NOT ask_user_question).

## 7. Process Response

[TOOL HARNESS: write_to_file]

**If response indicates pass:** "yes", "y", "ok", "pass", "next", "approved", "✓", or empty.

Update Tests section: `result: pass`

**If response indicates skip:** "skip", "can't test", "n/a"

Update Tests section: `result: skipped`, `reason: [user's reason]`

**If response is anything else:** Treat as issue description.

Infer severity:
- crash, error, exception, fails, broken, unusable → `blocker`
- doesn't work, wrong, missing, can't → `major`
- slow, weird, off, minor, small → `minor`
- color, font, spacing, alignment, visual → `cosmetic`
- Default: `major`

Update Tests section:
```
result: issue
reported: "{verbatim user response}"
severity: {inferred}
```

Append to Gaps section:
```yaml
- truth: "{expected behavior from test}"
  status: failed
  reason: "User reported: {verbatim user response}"
  severity: {inferred}
  test: {N}
  artifacts: []
  missing: []
```

**After any response:**

Update Summary counts. Update `frontmatter.updated` timestamp.

**Batched writes:** Write to file only when: issue found | every 5 passed tests | session complete.

If more tests remain → update Current Test → return to step 6.
If no more tests → proceed to `complete_session`.

## 8. Resume From File

[TOOL HARNESS: read_file]

Read the full UAT file. Find first test with `result: [pending]`.

Display:
```
Resuming: Phase {phase} UAT
Progress: {passed + issues + skipped}/{total}
Issues found so far: {issues count}

Continuing from Test {N}...
```

Update Current Test section. Proceed to step 6.

## 9. Complete Session

[TOOL HARNESS: write_to_file, run_command]

Update frontmatter: `status: complete`, `updated: [now]`

Clear Current Test section: `[testing complete]`

If `commit_docs=true`:
run_command: `git add .planning/phases/{phase_dir}/{padded_phase}-UAT.md`
run_command: `git commit -m "test({padded_phase}): complete UAT - {passed} passed, {issues} issues"`

Present summary:
```
## UAT Complete: Phase {phase}

| Result | Count |
|--------|-------|
| Passed | {N}   |
| Issues | {N}   |
| Skipped| {N}   |
```

**If issues == 0:**
```
All tests passed. Ready to continue.

- `/gsd/plan-phase {next}` — Plan next phase
- `/gsd/execute-phase {next}` — Execute next phase
```
Exit.

**If issues > 0:** Proceed to `diagnose_issues`.

## 10. Diagnose Issues

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name]

Display:
```
{N} issues found. Diagnosing root causes...
```

For each issue in UAT Gaps section:

→ ROLE SWITCH: Read GSD_AGENTS/gsd-debugger.md
  Act as gsd-debugger.
  Read:
  - `{phase_dir}/{padded_phase}-UAT.md` (issue details)
  - All `{phase_dir}/*-SUMMARY.md` (what was built)
  - All `{phase_dir}/*-PLAN.md` (what was planned)
  - Relevant source files mentioned in SUMMARY.md
  Investigate root cause for: "{issue truth}" — "{user reported}"
  Use grep_search and read_file to find the bug.
  Return: ROOT CAUSE FOUND {description} or DEBUG INCONCLUSIVE {findings}
→ END ROLE

Update UAT.md Gaps section with root cause for each issue.

If `commit_docs=true`:
run_command: `git add .planning/phases/{phase_dir}/{padded_phase}-UAT.md`
run_command: `git commit -m "docs({padded_phase}): add root cause diagnoses to UAT"`

Proceed to `plan_gap_closure`.

## 11. Plan Gap Closure

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search]

Display: `GSD ► PLANNING FIXES`

Initialize `iteration_count = 1`.

→ ROLE SWITCH: Read GSD_AGENTS/gsd-planner.md
  Act as gsd-planner in gap_closure mode.
  Read:
  - `{phase_dir}/{padded_phase}-UAT.md` (UAT with diagnoses)
  - `.planning/STATE.md`
  - `.planning/ROADMAP.md`
  Create fix plans in `{phase_dir}`. Plans must be executable prompts for `/gsd/execute-phase`.
  Return: `## PLANNING COMPLETE` or `## PLANNING INCONCLUSIVE`
→ END ROLE

**If PLANNING COMPLETE:** Proceed to `verify_gap_plans`.
**If PLANNING INCONCLUSIVE:** Report, offer manual intervention.

## 12. Verify Gap Plans

[TOOL HARNESS: read_file, grep_search]

Display: `GSD ► VERIFYING FIX PLANS`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-plan-checker.md
  Act as gsd-plan-checker.
  Read: all `{phase_dir}/*-PLAN.md` files (gap closure plans)
  Phase Goal: Close diagnosed gaps from UAT
  Return: `## VERIFICATION PASSED` or `## ISSUES FOUND {structured list}`
→ END ROLE

**If VERIFICATION PASSED:** Proceed to `present_ready`.
**If ISSUES FOUND:** Proceed to revision_loop.

## 13. Revision Loop (Max 3)

**Track `iteration_count` explicitly. State: "Revision iteration N/3"**

**If iteration_count < 3:**

Display: `Sending back to planner for revision... (iteration {N}/3)`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-planner.md
  Act as gsd-planner in revision mode.
  Read: all `{phase_dir}/*-PLAN.md` (existing plans)
  Checker issues: {structured_issues_from_checker}
  Make targeted updates only. Return what changed.
→ END ROLE

Increment iteration_count → return to step 12.

**If iteration_count >= 3:**

Display: `Max iterations reached. {N} issues remain.`

Use ask_user_question:
- question: "Max iterations reached. How would you like to proceed?"
- options:
  - label: "Force proceed" — description: Execute plans despite remaining issues
  - label: "Provide guidance and retry" — description: Give direction, reset iteration count
  - label: "Abandon" — description: Exit, run /gsd/plan-phase manually

## 14. Present Ready

Display `GSD ► FIXES READY ✓` with gap/root-cause/fix-plan table.

## ▶ Next Up
`/gsd/execute-phase {phase} --gaps-only` (/clear first)

</process>

<update_rules>
**Batched writes for efficiency:**

| Section | Rule | When Written |
|---------|------|--------------|
| Frontmatter.status | OVERWRITE | Start, complete |
| Frontmatter.updated | OVERWRITE | On any file write |
| Current Test | OVERWRITE | On any file write |
| Tests.{N}.result | OVERWRITE | On any file write |
| Summary | OVERWRITE | On any file write |
| Gaps | APPEND | When issue found |

On context reset: file shows last checkpoint. Resume from there.
</update_rules>

<success_criteria>
- [ ] UAT file created with all tests from SUMMARY.md
- [ ] Tests presented one at a time with expected behavior
- [ ] User responses processed as pass/issue/skip
- [ ] Severity inferred from description (never asked)
- [ ] Batched writes: on issue, every 5 passes, or completion
- [ ] Committed on completion
- [ ] If issues: gsd-debugger role-switch diagnoses each root cause
- [ ] If issues: gsd-planner role-switch creates fix plans (gap_closure mode)
- [ ] If issues: gsd-plan-checker role-switch verifies fix plans
- [ ] If issues: revision loop until plans pass (max 3 iterations)
- [ ] Ready for `/gsd/execute-phase --gaps-only` when complete
</success_criteria>
