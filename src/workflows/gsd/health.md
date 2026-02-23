---
description: Validate .planning/ directory integrity and report actionable issues. Usage: /gsd/health [--repair]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Validate `.planning/` directory integrity and report actionable issues. Checks for missing files, invalid configurations, inconsistent state, and orphaned plans. Optionally repairs auto-fixable issues.
</purpose>

<process>

## 1. Parse Arguments

Check if `--repair` flag is present in arguments.

## 2. Run Health Check

[TOOL HARNESS: read_file, find_by_name, run_command]

Perform checks manually (no gsd-tools):

**Check E001:** Does `.planning/` directory exist?
**Check E002:** Does `.planning/PROJECT.md` exist?
**Check E003:** Does `.planning/ROADMAP.md` exist?
**Check E004:** Does `.planning/STATE.md` exist?
**Check E005:** Does `.planning/config.json` exist and parse as valid JSON?

**Check W001:** Does PROJECT.md have required sections (What This Is, Core Value, Requirements)?
**Check W002:** Does STATE.md reference a phase that exists in ROADMAP.md?
**Check W003:** Does config.json exist? (if not, repairable)
**Check W004:** Are config.json field values valid (mode, model_profile, etc.)?
**Check W005:** Do phase directories follow `NN-name` format?
**Check W006:** Are all phases in ROADMAP.md present as directories in `.planning/phases/`?
**Check W007:** Are all directories in `.planning/phases/` present in ROADMAP.md?

**Check I001:** Find PLAN.md files without matching SUMMARY.md (may be in progress).

Collect: `errors[]`, `warnings[]`, `info[]`, `repairable_count`.

Determine status: "healthy" (no errors/warnings) | "degraded" (warnings only) | "broken" (errors).

## 3. Format Output

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: {HEALTHY | DEGRADED | BROKEN}
Errors: {N} | Warnings: {N} | Info: {N}
```

**If errors exist:**
```
## Errors

- [E001] .planning/ directory not found
  Fix: Run /gsd/new-project to create

- [E004] STATE.md not found
  Fix: Run /gsd/health --repair to regenerate
```

**If warnings exist:**
```
## Warnings

- [W002] STATE.md references phase 5, but only phases 1-3 exist
  Fix: Run /gsd/health --repair to regenerate

- [W005] Phase directory "1-setup" doesn't follow NN-name format
  Fix: Rename to match pattern (e.g., 01-setup)
```

**If info exists:**
```
## Info

- [I001] 02-implementation/02-01-PLAN.md has no SUMMARY.md
  Note: May be in progress
```

**Footer (if repairable issues and --repair NOT used):**
```
---
{N} issues can be auto-repaired. Run: /gsd/health --repair
```

## 4. Offer Repair

**If repairable issues exist AND --repair NOT used:**

Use ask_user_question:
- question: "{N} issues can be auto-repaired. Run repairs now?"
- options:
  - label: "Yes, repair" — description: Fix auto-repairable issues
  - label: "No, just report" — description: Keep current state

If "Yes": re-run with repair logic.

## 5. Perform Repairs (if --repair or user said yes)

[TOOL HARNESS: write_to_file, read_file]

**Repairable actions:**

- **E004 / W003 — STATE.md missing:** Read ROADMAP.md, reconstruct STATE.md using GSD_TEMPLATES/state.md structure. Note: "Regenerated from roadmap — session history lost."
- **W003 — config.json missing:** Create `.planning/config.json` with defaults from GSD_TEMPLATES/config.json.
- **E005 — config.json parse error:** Reset to defaults (warn: loses custom settings).
- **W002 — STATE.md references invalid phase:** Update STATE.md current_phase to first incomplete phase from ROADMAP.md.

Display repairs performed:
```
## Repairs Performed

- ✓ config.json: Created with defaults
- ✓ STATE.md: Regenerated from roadmap
```

## 6. Verify Repairs

If repairs were performed: re-run all checks (step 2) and report final status.

</process>

<error_codes>

| Code | Severity | Description | Repairable |
|------|----------|-------------|------------|
| E001 | error | .planning/ directory not found | No |
| E002 | error | PROJECT.md not found | No |
| E003 | error | ROADMAP.md not found | No |
| E004 | error | STATE.md not found | Yes |
| E005 | error | config.json parse error | Yes |
| W001 | warning | PROJECT.md missing required section | No |
| W002 | warning | STATE.md references invalid phase | Yes |
| W003 | warning | config.json not found | Yes |
| W004 | warning | config.json invalid field value | No |
| W005 | warning | Phase directory naming mismatch | No |
| W006 | warning | Phase in ROADMAP but no directory | No |
| W007 | warning | Phase on disk but not in ROADMAP | No |
| I001 | info | Plan without SUMMARY (may be in progress) | No |

</error_codes>

<success_criteria>
- [ ] All checks performed (E001-E005, W001-W007, I001)
- [ ] Status determined: healthy/degraded/broken
- [ ] Issues displayed with fix instructions
- [ ] Repairable issues offered for auto-repair
- [ ] Repairs performed if requested
- [ ] Final status reported after repairs
</success_criteria>
