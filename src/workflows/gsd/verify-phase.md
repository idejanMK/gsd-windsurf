---
description: Verify phase goal achievement through goal-backward analysis. Usually invoked by execute-phase. Usage: /gsd/verify-phase <phase>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Verify phase goal achievement through goal-backward analysis. Check that the codebase delivers what the phase promised, not just that tasks completed.

Executed by gsd-verifier role-switch from execute-phase.md. Can also be run standalone.
</purpose>

<core_principle>
**Task completion ≠ Goal achievement**

A task "create chat component" can be marked complete when the component is a placeholder. The task was done — but the goal "working chat interface" was not achieved.

Goal-backward verification:
1. What must be TRUE for the goal to be achieved?
2. What must EXIST for those truths to hold?
3. What must be WIRED for those artifacts to function?

Then verify each level against the actual codebase.
</core_principle>

<required_reading>
Read before starting:
- GSD_HOME/references/verification-patterns.md
- GSD_HOME/templates/verification-report.md
</required_reading>

<process>

## 1. Load Context

[TOOL HARNESS: read_file, find_by_name]

Phase number from argument (required).

Read:
- `.planning/ROADMAP.md` → find phase section, extract phase_name, goal, phase_slug, padded_phase
- `.planning/REQUIREMENTS.md` (if exists) → extract requirements for this phase
- `.planning/config.json` → extract commit_docs

Find phase directory. List all `*-PLAN.md` and `*-SUMMARY.md` files.

Extract **phase goal** from ROADMAP.md (the outcome to verify, not tasks).
Extract **requirements** from REQUIREMENTS.md if it exists.

## 2. Establish Must-Haves

[TOOL HARNESS: read_file]

**Option A: Must-haves in PLAN frontmatter**

Read each PLAN.md frontmatter for `must_haves` field.
Returns: `{ truths: [...], artifacts: [...], key_links: [...] }`
Aggregate all must_haves across plans for phase-level verification.

**Option B: Success Criteria from ROADMAP.md (if no must_haves in frontmatter)**

Parse `success_criteria` array from ROADMAP.md phase section.
Use each Success Criterion directly as a **truth** (observable, testable behaviors).
Derive **artifacts** (concrete file paths for each truth).
Derive **key links** (critical wiring where stubs hide).

**Option C: Derive from phase goal (fallback)**

If no must_haves AND no Success Criteria:
1. State the goal from ROADMAP.md
2. Derive **truths** (3-7 observable behaviors, each testable)
3. Derive **artifacts** (concrete file paths for each truth)
4. Derive **key links** (critical wiring where stubs hide)

## 3. Verify Truths

[TOOL HARNESS: read_file, grep_search, find_by_name]

For each observable truth, determine if the codebase enables it.

**Status:** ✓ VERIFIED (all supporting artifacts pass) | ✗ FAILED (artifact missing/stub/unwired) | ? UNCERTAIN (needs human)

For each truth: identify supporting artifacts → check artifact status → check wiring → determine truth status.

## 4. Verify Artifacts

For each artifact in must_haves:

**Level 1 — Exists:** Does the file exist on disk?
**Level 2 — Substantive:** Is it real implementation (not stub/placeholder)?
- Check for: "placeholder", "coming soon", "TODO", empty returns, log-only functions
- Minimum meaningful content (>20 lines for components, >10 for utilities)

**Level 3 — Wired:** Is it imported and used?

```
grep -r "import.*{artifact_name}" src/
grep -r "{artifact_name}" src/ | grep -v "import"
```

WIRED = imported AND used. ORPHANED = exists but not imported/used.

| Exists | Substantive | Wired | Status |
|--------|-------------|-------|--------|
| ✓ | ✓ | ✓ | ✓ VERIFIED |
| ✓ | ✓ | ✗ | ⚠️ ORPHANED |
| ✓ | ✗ | - | ✗ STUB |
| ✗ | - | - | ✗ MISSING |

## 5. Verify Wiring

For each key link in must_haves:

| Pattern | Check | Status |
|---------|-------|--------|
| Component → API | fetch/axios call to API path, response used | WIRED / PARTIAL / NOT_WIRED |
| API → Database | DB query on model, result returned via res.json() | WIRED / PARTIAL / NOT_WIRED |
| Form → Handler | onSubmit with real implementation (not console.log/empty) | WIRED / STUB / NOT_WIRED |
| State → Render | useState variable appears in JSX | WIRED / NOT_WIRED |

## 6. Verify Requirements

[TOOL HARNESS: read_file, grep_search]

If REQUIREMENTS.md exists: for each requirement assigned to this phase:
- Parse description → identify supporting truths/artifacts
- Status: ✓ SATISFIED / ✗ BLOCKED / ? NEEDS HUMAN

## 7. Scan Anti-Patterns

[TOOL HARNESS: grep_search]

Extract files modified in this phase from SUMMARY.md. Scan each:

| Pattern | Severity |
|---------|----------|
| TODO/FIXME/XXX/HACK | ⚠️ Warning |
| Placeholder content ("coming soon", "will be here") | 🛑 Blocker |
| Empty returns (`return null`, `return {}`, `return []`) | ⚠️ Warning |
| Log-only functions | ⚠️ Warning |

Categorize: 🛑 Blocker (prevents goal) | ⚠️ Warning (incomplete) | ℹ️ Info (notable).

## 8. Identify Human Verification Items

Items that always need human verification:
- Visual appearance
- User flow completion
- Real-time behavior (WebSocket/SSE)
- External service integration
- Performance feel
- Error message clarity

Format each as: Test Name → What to do → Expected result → Why can't verify programmatically.

## 9. Determine Status

**passed:** All truths VERIFIED, all artifacts pass levels 1-3, all key links WIRED, no blocker anti-patterns.

**gaps_found:** Any truth FAILED, artifact MISSING/STUB, key link NOT_WIRED, or blocker found.

**human_needed:** All automated checks pass but human verification items remain.

Score: `verified_truths / total_truths`

## 10. Generate Fix Plans (if gaps_found)

[TOOL HARNESS: write_to_file]

1. **Cluster related gaps:** API stub + component unwired → "Wire frontend to backend". Multiple missing → "Complete core implementation".

2. **Generate plan per cluster:** Objective, 2-3 tasks (files/action/verify each), re-verify step. Keep focused: single concern per plan.

3. **Order by dependency:** Fix missing → fix stubs → fix wiring → verify.

## 11. Create Report

[TOOL HARNESS: write_to_file, run_command]

Write `{phase_dir}/{padded_phase}-VERIFICATION.md` using GSD_TEMPLATES/verification-report.md structure.

Sections: frontmatter (phase/timestamp/status/score), goal achievement, artifact table, wiring table, requirements coverage, anti-patterns, human verification, gaps summary, fix plans (if gaps_found).

If commit_docs=true:
run_command: `git add "{phase_dir}/{padded_phase}-VERIFICATION.md"`
run_command: `git commit -m "docs({padded_phase}): add phase verification report"`

## 12. Return Status

Return: status (`passed` | `gaps_found` | `human_needed`), score (N/M must-haves), report path.

If gaps_found: list gaps + recommended fix plan names.
If human_needed: list items requiring human testing.

</process>

<success_criteria>
- [ ] Must-haves established (from frontmatter, ROADMAP success criteria, or derived)
- [ ] All truths verified with status and evidence
- [ ] All artifacts checked at all three levels (exists, substantive, wired)
- [ ] All key links verified
- [ ] Requirements coverage assessed (if applicable)
- [ ] Anti-patterns scanned and categorized
- [ ] Human verification items identified
- [ ] Overall status determined
- [ ] Fix plans generated (if gaps_found)
- [ ] VERIFICATION.md created with complete report
</success_criteria>
