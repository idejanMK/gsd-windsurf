---
description: Verify milestone achieved its definition of done by aggregating phase verifications and checking cross-phase integration. Usage: /gsd/audit-milestone [version]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Verify milestone achieved its definition of done by aggregating phase verifications, checking cross-phase integration, and assessing requirements coverage. Reads existing VERIFICATION.md files (phases already verified during execute-phase), aggregates tech debt and deferred gaps, then spawns integration checker for cross-phase wiring.
</purpose>

<process>

## 0. Initialize Milestone Context

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/ROADMAP.md` → identify milestone version (from argument or detect current).
Read `.planning/REQUIREMENTS.md` → extract all REQ-IDs mapped to milestone phases.
Read `.planning/config.json` → extract `commit_docs`.

Identify all phase directories in scope for this milestone.

## 1. Determine Milestone Scope

From ROADMAP.md: parse version from arguments or detect current from milestone section.
Identify all phase directories in scope.
Extract milestone definition of done from ROADMAP.md.
Extract requirements mapped to this milestone from REQUIREMENTS.md.

## 2. Read All Phase Verifications

[TOOL HARNESS: read_file, find_by_name]

For each phase directory, read `{padded_phase}-VERIFICATION.md`.

From each VERIFICATION.md, extract:
- **Status:** passed | gaps_found
- **Critical gaps:** (if any — these are blockers)
- **Non-critical gaps:** tech debt, deferred items, warnings
- **Anti-patterns found:** TODOs, stubs, placeholders
- **Requirements coverage:** which requirements satisfied/blocked

If a phase is missing VERIFICATION.md: flag as "unverified phase" — this is a blocker.

## 3. Spawn Integration Checker

[TOOL HARNESS: read_file, grep_search, find_by_name]

Extract `MILESTONE_REQ_IDS` from REQUIREMENTS.md traceability table.

Display: `◆ Spawning integration checker...`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-integration-checker.md
  Act as gsd-integration-checker.
  Read:
  - All phase SUMMARY.md files
  - All phase PLAN.md files
  - `.planning/REQUIREMENTS.md`
  - `.planning/ROADMAP.md`
  Phases: {phase_dirs}
  Milestone Requirements: {MILESTONE_REQ_IDS — each REQ-ID with description and assigned phase}
  Verify cross-phase wiring and E2E user flows.
  MUST map each integration finding to affected requirement IDs where applicable.
  Return: integration gaps, broken flows, wiring issues.
→ END ROLE

## 4. Collect Results

Combine:
- Phase-level gaps and tech debt (from step 2)
- Integration checker's report (wiring gaps, broken flows)

## 5. Check Requirements Coverage (3-Source Cross-Reference)

[TOOL HARNESS: read_file, grep_search]

For each REQ-ID, cross-reference three independent sources:

**5a. REQUIREMENTS.md Traceability Table:** Extract all REQ-IDs, assigned phase, current status, checked-off state (`[x]` vs `[ ]`).

**5b. Phase VERIFICATION.md Requirements Tables:** For each phase's VERIFICATION.md, extract requirements table: Requirement | Source Plan | Status | Evidence.

**5c. SUMMARY.md Frontmatter:** For each phase's SUMMARY.md, extract `requirements-completed` from YAML frontmatter.

**5d. Status Determination Matrix:**

| VERIFICATION.md Status | SUMMARY Frontmatter | REQUIREMENTS.md | → Final Status |
|------------------------|---------------------|-----------------|----------------|
| passed | listed | `[x]` | **satisfied** |
| passed | listed | `[ ]` | **satisfied** (update checkbox) |
| passed | missing | any | **partial** (verify manually) |
| gaps_found | any | any | **unsatisfied** |
| missing | listed | any | **partial** (verification gap) |
| missing | missing | any | **unsatisfied** |

**5e. FAIL Gate and Orphan Detection:**

Any `unsatisfied` requirement MUST force `gaps_found` status on the milestone audit.

Orphan detection: Requirements in REQUIREMENTS.md traceability but absent from ALL phase VERIFICATION.md files → flagged as orphaned → treated as `unsatisfied`.

## 6. Aggregate into MILESTONE-AUDIT.md

[TOOL HARNESS: write_to_file, run_command]

Create `.planning/v{version}-MILESTONE-AUDIT.md`:

```yaml
---
milestone: {version}
audited: {timestamp}
status: passed | gaps_found | tech_debt
scores:
  requirements: N/M
  phases: N/M
  integration: N/M
  flows: N/M
gaps:
  requirements:
    - id: "{REQ-ID}"
      status: "unsatisfied | partial | orphaned"
      phase: "{assigned phase}"
      verification_status: "passed | gaps_found | missing | orphaned"
      evidence: "{specific evidence or lack thereof}"
  integration: [...]
  flows: [...]
tech_debt:
  - phase: 01-auth
    items:
      - "TODO: add rate limiting"
---
```

Plus full markdown report with tables for requirements, phases, integration, tech debt.

**Status values:**
- `passed` — all requirements met, no critical gaps, minimal tech debt
- `gaps_found` — critical blockers exist
- `tech_debt` — no blockers but accumulated deferred items need review

If commit_docs=true:
run_command: `git add ".planning/v{version}-MILESTONE-AUDIT.md"`
run_command: `git commit -m "docs: audit milestone {version}"`

## 7. Present Results

Route by status:

**If passed:**
```
## ✓ Milestone {version} — Audit Passed

**Score:** {N}/{M} requirements satisfied
**Report:** .planning/v{version}-MILESTONE-AUDIT.md

All requirements covered. Cross-phase integration verified. E2E flows complete.

---

## ▶ Next Up

**Complete milestone** — archive and tag

`/gsd/complete-milestone`

<sub>`/clear` first → fresh context window</sub>

---
```

**If gaps_found:**
```
## ⚠ Milestone {version} — Gaps Found

**Score:** {N}/{M} requirements satisfied
**Report:** .planning/v{version}-MILESTONE-AUDIT.md

### Unsatisfied Requirements
{For each unsatisfied requirement}
- **{REQ-ID}: {description}** (Phase {X}) — {reason}

### Cross-Phase Issues
{For each integration gap}

---

## ▶ Next Up

**Plan gap closure** — create phases to complete milestone

`/gsd/plan-milestone-gaps`

<sub>`/clear` first → fresh context window</sub>

---
```

**If tech_debt:**
```
## ⚡ Milestone {version} — Tech Debt Review

**Score:** {N}/{M} requirements satisfied
**Report:** .planning/v{version}-MILESTONE-AUDIT.md

All requirements met. No critical blockers. Accumulated tech debt needs review.

### Tech Debt by Phase
{For each phase with debt}

---

## ▶ Options

**A. Complete milestone** — accept debt, track in backlog
`/gsd/complete-milestone`

**B. Plan cleanup phase** — address debt before completing
`/gsd/plan-milestone-gaps`

---
```

</process>

<success_criteria>
- [ ] Milestone scope identified
- [ ] All phase VERIFICATION.md files read
- [ ] SUMMARY.md requirements-completed frontmatter extracted for each phase
- [ ] REQUIREMENTS.md traceability table parsed for all milestone REQ-IDs
- [ ] 3-source cross-reference completed (VERIFICATION + SUMMARY + traceability)
- [ ] Orphaned requirements detected
- [ ] Tech debt and deferred gaps aggregated
- [ ] Integration checker role-switch executed with milestone requirement IDs
- [ ] v{version}-MILESTONE-AUDIT.md created with structured requirement gap objects
- [ ] FAIL gate enforced — any unsatisfied requirement forces gaps_found status
- [ ] Results presented with actionable next steps
</success_criteria>
