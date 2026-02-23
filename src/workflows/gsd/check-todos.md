---
description: List pending todos, select one, and route to appropriate action. Usage: /gsd/check-todos [area]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
List all pending todos, allow selection, load full context for the selected todo, and route to appropriate action.
</purpose>

<process>

## 1. Init Context

[TOOL HARNESS: find_by_name, read_file]

Find all `*.md` files in `.planning/todos/pending/`.

If none found:
```
No pending todos.

Todos are captured during work sessions with /gsd/add-todo.

---

Would you like to:
1. Continue with current phase (/gsd/progress)
2. Add a todo now (/gsd/add-todo)
```
Exit.

## 2. Parse Filter

Check for area filter in arguments:
- `/gsd/check-todos` → show all
- `/gsd/check-todos api` → filter to area:api only

## 3. List Todos

[TOOL HARNESS: read_file]

Read each todo file's frontmatter (title, area, created).

If area filter: show only matching area.

Calculate relative age from `created` timestamp.

Display as numbered list:
```
Pending Todos:

1. Add auth token refresh (api, 2d ago)
2. Fix modal z-index issue (ui, 1d ago)
3. Refactor database connection pool (database, 5h ago)

---

Reply with a number to view details, or:
- `/gsd/check-todos [area]` to filter by area
- `q` to exit
```

Wait for user response (freeform).

If `q` or "quit": exit.
If invalid number: "Invalid selection. Reply with a number (1-{N}) or `q` to exit."

## 4. Load Context

[TOOL HARNESS: read_file]

Read selected todo file completely. Display:

```
## {title}

**Area:** {area}
**Created:** {date} ({relative time} ago)
**Files:** {list or "None"}

### Problem
{problem section content}

### Solution
{solution section content}
```

If `files` field has entries: briefly summarize each file's relevance.

## 5. Check Roadmap

[TOOL HARNESS: read_file]

If `.planning/ROADMAP.md` exists:
1. Check if todo's area matches an upcoming phase
2. Check if todo's files overlap with a phase's scope
3. Note any match for action options

## 6. Offer Actions

**If todo maps to a roadmap phase:**

Use ask_user_question:
- question: "This todo relates to Phase {N}: {name}. What would you like to do?"
- options:
  - label: "Work on it now" — description: Move to done, start working
  - label: "Add to phase plan" — description: Include when planning Phase {N}
  - label: "Brainstorm approach" — description: Think through before deciding
  - label: "Put it back" — description: Return to list

**If no roadmap match:**

Use ask_user_question:
- question: "What would you like to do with this todo?"
- options:
  - label: "Work on it now" — description: Move to done, start working
  - label: "Create a phase" — description: /gsd/add-phase with this scope
  - label: "Brainstorm approach" — description: Think through before deciding
  - label: "Put it back" — description: Return to list

## 7. Execute Action

[TOOL HARNESS: run_command, write_to_file, read_file]

**Work on it now:**
run_command: `Move-Item ".planning/todos/pending/{filename}" ".planning/todos/done/"`
Update STATE.md todo count. Present problem/solution context. Begin work or ask how to proceed.

If commit_docs=true:
run_command: `git add .planning/todos/`
run_command: `git commit -m "docs: start work on todo - {title}"`

**Add to phase plan:**
Note todo reference in phase planning notes. Keep in pending. Return to list or exit.

**Create a phase:**
Display: "Run `/gsd/add-phase {description from todo}` in a fresh context."
Keep in pending.

**Brainstorm approach:**
Keep in pending. Start discussion about problem and approaches.

**Put it back:**
Return to step 3 (list_todos).

## 8. Update STATE.md

[TOOL HARNESS: read_file, write_to_file]

After any action that changes todo count:
Count files in `.planning/todos/pending/`. Update STATE.md "### Pending Todos" section.

</process>

<success_criteria>
- [ ] All pending todos listed with title, area, age
- [ ] Area filter applied if specified
- [ ] Selected todo's full context loaded
- [ ] Roadmap context checked for phase match
- [ ] Appropriate actions offered
- [ ] Selected action executed
- [ ] STATE.md updated if todo count changed
- [ ] Changes committed to git (if todo moved to done/)
</success_criteria>
