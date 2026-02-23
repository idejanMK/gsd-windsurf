---
description: Remove an unstarted future phase from the roadmap and renumber subsequent phases. Usage: /gsd/remove-phase <phase-number>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Remove an unstarted future phase from the project roadmap, delete its directory, renumber all subsequent phases to maintain a clean linear sequence, and commit the change. The git commit serves as the historical record of removal.
</purpose>

<process>

## 1. Parse Arguments

Argument: phase number to remove (integer or decimal).
- `/gsd/remove-phase 17` → phase = 17
- `/gsd/remove-phase 16.1` → phase = 16.1

If no argument:
```
ERROR: Phase number required
Usage: /gsd/remove-phase <phase-number>
Example: /gsd/remove-phase 17
```
Exit.

## 2. Init Context

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/ROADMAP.md`. If missing: error, exit.
Read `.planning/STATE.md` → extract current_phase.
Read `.planning/config.json` → extract commit_docs.

Find phase in ROADMAP.md. If not found: error, exit.
Find phase directory in `.planning/phases/`.

## 3. Validate Future Phase

Compare target phase to current phase from STATE.md.
Target must be > current phase number.

If target <= current phase:
```
ERROR: Cannot remove Phase {target}

Only future phases can be removed:
- Current phase: {current}
- Phase {target} is current or completed

To abandon current work, use /gsd/pause-work instead.
```
Exit.

## 4. Check for Executed Plans

[TOOL HARNESS: find_by_name]

Check if phase directory contains any `*-SUMMARY.md` files.

If SUMMARY.md files found: use ask_user_question:
- question: "Phase {target} has executed plans (SUMMARY.md files). Removing it will delete completed work. Proceed?"
- options:
  - label: "Yes, force remove" — description: Delete everything including completed work
  - label: "Cancel" — description: Keep the phase

If "Cancel": exit.

## 5. Confirm Removal

Use ask_user_question:
- question: "Remove Phase {target}: {Name}? This will delete the directory and renumber subsequent phases."
- options:
  - label: "Yes, remove it" — description: Delete and renumber
  - label: "Cancel" — description: Keep the phase

If "Cancel": exit.

## 6. Execute Removal

[TOOL HARNESS: read_file, write_to_file, run_command]

**Delete phase directory:**
run_command: `Remove-Item -Recurse -Force ".planning/phases/{target-dir}"`

**Renumber subsequent phases in ROADMAP.md:**

For each phase with number > target (in ascending order):
- Rename directory: `{N}` → `{N-1}` (or `{N.M}` → `{N-1.M}` for decimals after integer removal)
- Rename all files inside: update phase number prefix
- Update ROADMAP.md: update phase header, depends_on references, progress table

**Update STATE.md:**
- Decrement phase count
- If current_phase > target: decrement current_phase

## 7. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add .planning/`
run_command: `git commit -m "chore: remove phase {target} ({original-phase-name})"`

The commit message preserves the historical record.

## 8. Completion

Display:
```
Phase {target} ({original-name}) removed.

Changes:
- Deleted: .planning/phases/{target}-{slug}/
- Renumbered: {N} directories and {M} files
- Updated: ROADMAP.md, STATE.md
- Committed: chore: remove phase {target} ({original-name})

---

## What's Next

- `/gsd/progress` — see updated roadmap status
- Continue with current phase

---
```

</process>

<anti_patterns>
- Don't remove completed phases (have SUMMARY.md files) without explicit user confirmation
- Don't remove current or past phases
- Don't add "removed phase" notes to STATE.md — git commit is the record
- Don't modify completed phase directories
</anti_patterns>

<success_criteria>
- [ ] Target phase validated as future/unstarted
- [ ] User confirmed removal
- [ ] Phase directory deleted
- [ ] Subsequent phases renumbered in directories and ROADMAP.md
- [ ] STATE.md updated
- [ ] Committed with descriptive message
- [ ] User informed of changes
</success_criteria>
