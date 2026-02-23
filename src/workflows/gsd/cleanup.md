---
description: Archive accumulated phase directories from completed milestones into .planning/milestones/. Usage: /gsd/cleanup
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Archive accumulated phase directories from completed milestones into `.planning/milestones/v{X.Y}-phases/`. Identifies which phases belong to each completed milestone, shows a dry-run summary, and moves directories on confirmation.
</purpose>

<required_reading>
Read before starting:
- `.planning/MILESTONES.md`
- `.planning/milestones/` directory listing
- `.planning/phases/` directory listing
</required_reading>

<process>

## 1. Identify Completed Milestones

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/MILESTONES.md` to identify completed milestones and their versions.

Extract each milestone version (e.g., v1.0, v1.1, v2.0).

Check which milestone archive dirs already exist in `.planning/milestones/`:
- Find directories matching `v*-phases` pattern

Filter to milestones that do NOT already have a `-phases` archive directory.

If all milestones already have phase archives:
```
All completed milestones already have phase directories archived. Nothing to clean up.
```
Exit.

## 2. Determine Phase Membership

[TOOL HARNESS: read_file, find_by_name]

For each completed milestone without a `-phases` archive, read the archived ROADMAP snapshot:
`.planning/milestones/v{X.Y}-ROADMAP.md`

Extract phase numbers and names from the archived roadmap.

Check which of those phase directories still exist in `.planning/phases/`.

Match phase directories to milestone membership. Only include directories that still exist.

## 3. Show Dry-Run

Display:
```
## Cleanup Summary

### v{X.Y} — {Milestone Name}
These phase directories will be archived:
- 01-foundation/
- 02-auth/
- 03-core-features/

Destination: .planning/milestones/v{X.Y}-phases/

### v{X.Z} — {Milestone Name}
These phase directories will be archived:
- 04-security/
- 05-hardening/

Destination: .planning/milestones/v{X.Z}-phases/
```

If no phase directories remain to archive:
```
No phase directories found to archive. Phases may have been removed or archived previously.
```
Exit.

Use ask_user_question:
- question: "Proceed with archiving these phase directories?"
- options:
  - label: "Yes — archive listed phases" — description: Move directories to milestones/
  - label: "Cancel" — description: Keep phases in place

If "Cancel": exit.

## 4. Archive Phases

[TOOL HARNESS: run_command]

For each milestone, move phase directories:

run_command: `mkdir -p ".planning/milestones/v{X.Y}-phases"`

For each phase directory belonging to this milestone:
run_command: `Move-Item ".planning/phases/{dir}" ".planning/milestones/v{X.Y}-phases/"`

Repeat for all milestones in the cleanup set.

## 5. Commit

[TOOL HARNESS: run_command]

Read `.planning/config.json` → check `commit_docs`.

If commit_docs=true:
run_command: `git add .planning/milestones/ .planning/phases/`
run_command: `git commit -m "chore: archive phase directories from completed milestones"`

## 6. Report

Display:
```
Archived:
{For each milestone}
- v{X.Y}: {N} phase directories → .planning/milestones/v{X.Y}-phases/

.planning/phases/ cleaned up.
```

</process>

<success_criteria>
- [ ] All completed milestones without existing phase archives identified
- [ ] Phase membership determined from archived ROADMAP snapshots
- [ ] Dry-run summary shown and user confirmed
- [ ] Phase directories moved to `.planning/milestones/v{X.Y}-phases/`
- [ ] Changes committed (if commit_docs=true)
</success_criteria>
