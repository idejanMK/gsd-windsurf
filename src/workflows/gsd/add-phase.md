---
description: Add a new phase to the end of the current milestone roadmap. Usage: /gsd/add-phase <description>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Add a new integer phase to the end of the current milestone in the roadmap. Automatically calculates next phase number, creates phase directory, and updates roadmap structure.
</purpose>

<process>

## 1. Parse Arguments

All arguments become the phase description.
- `/gsd/add-phase Add authentication` → description = "Add authentication"

If no arguments:
```
ERROR: Phase description required
Usage: /gsd/add-phase <description>
Example: /gsd/add-phase Add authentication system
```
Exit.

## 2. Init Context

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/ROADMAP.md`. If missing:
```
ERROR: No roadmap found (.planning/ROADMAP.md)
Run /gsd/new-project to initialize.
```
Exit.

Read `.planning/config.json` → extract `commit_docs`.

## 3. Add Phase

[TOOL HARNESS: read_file, write_to_file, run_command]

From ROADMAP.md: find the highest existing integer phase number. Next phase = max + 1. Zero-pad to 2 digits.

Generate slug from description: lowercase, spaces → hyphens, remove special chars.

Create phase directory: run_command: `mkdir -p ".planning/phases/{NN}-{slug}"`

Insert phase entry into ROADMAP.md after the last phase section:

```markdown
### Phase {N}: {Description}

**Goal:** {description}
**Depends on:** Phase {N-1}
**Plans:** TBD

**Success criteria:**
- [ ] TBD

**Requirements:** TBD
```

## 4. Update STATE.md

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/STATE.md`. Under "## Accumulated Context" → "### Roadmap Evolution" add:
```
- Phase {N} added: {description}
```

If "Roadmap Evolution" section doesn't exist, create it.

## 5. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add .planning/ROADMAP.md .planning/STATE.md`
run_command: `git commit -m "chore: add phase {N} - {description}"`

## 6. Completion

Display:
```
Phase {N} added to current milestone:
- Description: {description}
- Directory: .planning/phases/{NN}-{slug}/
- Status: Not planned yet

Roadmap updated: .planning/ROADMAP.md

---

## ▶ Next Up

**Phase {N}: {description}**

`/gsd/plan-phase {N}`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/add-phase <description>` — add another phase
- `/gsd/progress` — review updated roadmap

---
```

</process>

<success_criteria>
- [ ] Phase description provided
- [ ] ROADMAP.md exists
- [ ] Next phase number calculated correctly
- [ ] Phase directory created
- [ ] ROADMAP.md updated with new phase entry
- [ ] STATE.md updated with roadmap evolution note
- [ ] Committed (if commit_docs=true)
- [ ] User informed of next steps
</success_criteria>
