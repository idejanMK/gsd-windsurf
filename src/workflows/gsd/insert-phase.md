---
description: Insert a decimal phase for urgent work between existing integer phases. Usage: /gsd/insert-phase <after> <description>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Insert a decimal phase for urgent work discovered mid-milestone between existing integer phases. Uses decimal numbering (72.1, 72.2, etc.) to preserve the logical sequence of planned phases while accommodating urgent insertions without renumbering the entire roadmap.
</purpose>

<process>

## 1. Parse Arguments

First argument: integer phase number to insert after.
Remaining arguments: phase description.

Example: `/gsd/insert-phase 72 Fix critical auth bug`
→ after = 72, description = "Fix critical auth bug"

If arguments missing:
```
ERROR: Both phase number and description required
Usage: /gsd/insert-phase <after> <description>
Example: /gsd/insert-phase 72 Fix critical auth bug
```
Exit.

Validate first argument is an integer.

## 2. Init Context

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/ROADMAP.md`. If missing:
```
ERROR: No roadmap found (.planning/ROADMAP.md)
```
Exit.

Read `.planning/config.json` → extract `commit_docs`.

Verify target phase exists in ROADMAP.md. If not found:
```
ERROR: Phase {after} not found in roadmap.
```
Exit.

## 3. Insert Phase

[TOOL HARNESS: read_file, write_to_file, run_command]

Find existing decimal phases after `{after}` in ROADMAP.md and on disk.
Calculate next decimal: if `{after}.1` exists → use `{after}.2`, etc.

Generate slug from description: lowercase, spaces → hyphens.

Create phase directory: run_command: `mkdir -p ".planning/phases/{after}.{N}-{slug}"`

Insert phase entry into ROADMAP.md immediately after Phase `{after}` section:

```markdown
### Phase {after}.{N}: {Description} (INSERTED)

**Goal:** {description}
**Depends on:** Phase {after}
**Plans:** TBD
**Note:** Urgent insertion — addresses {description}

**Success criteria:**
- [ ] TBD

**Requirements:** TBD
```

## 4. Update STATE.md

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/STATE.md`. Under "## Accumulated Context" → "### Roadmap Evolution" add:
```
- Phase {after}.{N} inserted after Phase {after}: {description} (URGENT)
```

## 5. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add .planning/ROADMAP.md .planning/STATE.md`
run_command: `git commit -m "chore: insert urgent phase {after}.{N} - {description}"`

## 6. Completion

Display:
```
Phase {after}.{N} inserted after Phase {after}:
- Description: {description}
- Directory: .planning/phases/{after}.{N}-{slug}/
- Status: Not planned yet
- Marker: (INSERTED) — indicates urgent work

Roadmap updated: .planning/ROADMAP.md
Project state updated: .planning/STATE.md

---

## ▶ Next Up

**Phase {after}.{N}: {description}** — urgent insertion

`/gsd/plan-phase {after}.{N}`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- Review if Phase {next_integer} dependencies still make sense
- `/gsd/progress` — see updated roadmap

---
```

</process>

<anti_patterns>
- Don't use this for planned work at end of milestone (use /gsd/add-phase)
- Don't insert before Phase 1 (decimal 0.1 makes no sense)
- Don't renumber existing phases
- Don't modify the target phase content
- Don't create plans yet (that's /gsd/plan-phase)
</anti_patterns>

<success_criteria>
- [ ] Phase number and description provided
- [ ] Target phase validated in ROADMAP.md
- [ ] Decimal phase number calculated correctly
- [ ] Phase directory created
- [ ] ROADMAP.md updated with (INSERTED) marker
- [ ] STATE.md updated with roadmap evolution note
- [ ] Committed (if commit_docs=true)
- [ ] User informed of dependency implications
</success_criteria>
