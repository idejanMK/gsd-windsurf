---
description: Capture an idea, task, or issue as a structured todo for later work. Usage: /gsd/add-todo [description]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Capture an idea, task, or issue that surfaces during a GSD session as a structured todo for later work. Enables "thought → capture → continue" flow without losing context.
</purpose>

<process>

## 1. Init Context

[TOOL HARNESS: read_file, find_by_name, run_command]

Read `.planning/config.json` → extract `commit_docs`.

Ensure directories exist:
run_command: `mkdir -p .planning/todos/pending .planning/todos/done`

Find existing todo files in `.planning/todos/pending/` to check for duplicates and existing areas.

## 2. Extract Content

**With arguments:** Use as the title/focus.
- `/gsd/add-todo Add auth token refresh` → title = "Add auth token refresh"

**Without arguments:** Analyze recent conversation to extract:
- The specific problem, idea, or task discussed
- Relevant file paths mentioned
- Technical details (error messages, line numbers, constraints)

Formulate:
- `title`: 3-10 word descriptive title (action verb preferred)
- `problem`: What's wrong or why this is needed
- `solution`: Approach hints or "TBD" if just an idea
- `files`: Relevant paths with line numbers from conversation

## 3. Infer Area

Infer area from file paths:

| Path pattern | Area |
|--------------|------|
| `src/api/*`, `api/*` | `api` |
| `src/components/*`, `src/ui/*` | `ui` |
| `src/auth/*`, `auth/*` | `auth` |
| `src/db/*`, `database/*` | `database` |
| `tests/*`, `__tests__/*` | `testing` |
| `docs/*` | `docs` |
| `.planning/*` | `planning` |
| `scripts/*`, `bin/*` | `tooling` |
| No files or unclear | `general` |

Use existing area from pending todos if similar match exists.

## 4. Check Duplicates

[TOOL HARNESS: grep_search]

Search for key words from title in existing `.planning/todos/pending/` files.

If potential duplicate found: read the existing todo, compare scope.

If overlapping: use ask_user_question:
- question: "Similar todo exists: '{existing_title}'. What would you like to do?"
- options:
  - label: "Skip" — description: Keep existing todo
  - label: "Replace" — description: Update existing with new context
  - label: "Add anyway" — description: Create as separate todo

## 5. Create File

[TOOL HARNESS: write_to_file]

Generate filename: `{YYYY-MM-DD}-{slug}.md` where slug = title lowercased, spaces → hyphens.

Write to `.planning/todos/pending/{date}-{slug}.md`:

```markdown
---
created: {ISO timestamp}
title: {title}
area: {area}
files:
  - {file:lines if any}
---

## Problem

{problem description — enough context for future Cascade to understand weeks later}

## Solution

{approach hints or "TBD"}
```

## 6. Update STATE.md

[TOOL HARNESS: read_file, write_to_file]

If `.planning/STATE.md` exists:
- Count total pending todos (files in `.planning/todos/pending/`)
- Update "### Pending Todos" under "## Accumulated Context" with new count and title

## 7. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add ".planning/todos/pending/{filename}" .planning/STATE.md`
run_command: `git commit -m "docs: capture todo - {title}"`

## 8. Confirm

Display:
```
Todo saved: .planning/todos/pending/{filename}

  {title}
  Area: {area}
  Files: {count} referenced

---

Would you like to:
1. Continue with current work
2. Add another todo (/gsd/add-todo)
3. View all todos (/gsd/check-todos)
```

</process>

<success_criteria>
- [ ] Directory structure exists
- [ ] Todo file created with valid frontmatter
- [ ] Problem section has enough context for future Cascade
- [ ] No duplicates (checked and resolved)
- [ ] Area consistent with existing todos
- [ ] STATE.md updated if exists
- [ ] Todo and state committed to git (if commit_docs=true)
</success_criteria>
