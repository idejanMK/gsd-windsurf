---
trigger: always_on
---

# GSD Core — Windsurf Harness

GSD (Get Shit Done) framework harness for Windsurf/Cascade. Preserves all GSD principles: atomic commits, artifact enforcement, drift recovery, tool discipline, and context management.

---

## 1. Command Execution

When user runs `/gsd/*`:
- Reply "Got it." then immediately read the workflow file at `GSD_WORKFLOWS/{command}.md` completely before doing anything else
- Follow the workflow step-by-step. Do not skip steps, reorder them, or improvise
- Preserve ALL gates: approval prompts, checkpoints, artifact checks, commit steps

**Path constants:**

| Constant | Value |
|---|---|
| `GSD_HOME` | `~/.codeium/windsurf/get-shit-done` |
| `GSD_WORKFLOWS` | `~/.codeium/windsurf/windsurf/workflows/gsd` |
| `GSD_AGENTS` | `~/.codeium/windsurf/get-shit-done/agents` |
| `GSD_REFERENCES` | `~/.codeium/windsurf/get-shit-done/references` |
| `GSD_TEMPLATES` | `~/.codeium/windsurf/get-shit-done/templates` |

## 2. On-Demand Agent Loading (Role-Switch Pattern)

NEVER load agent instruction files unless the current workflow step explicitly says to.

When a workflow step says `→ ROLE SWITCH: Read GSD_AGENTS/gsd-X.md`:
1. Read that agent file completely
2. Adopt that role fully for the duration of that step only
3. When the step ends with `→ END ROLE`: stop acting as that agent
4. Do NOT carry that role's instructions or perspective into the next step

## 3. Tool Harness

Each workflow step declares `[TOOL HARNESS: ...]` — a list of allowed tools for that step.
Self-enforce strictly. Do not use tools outside the declared set for that step.

## 4. Commit Discipline

Every GSD task produces an atomic commit immediately upon completion:
```
type(scope): description
```
Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

Do not batch commits. Do not defer commits. Each GSD task = one commit.

Before committing `.planning/` files, read `.planning/config.json` → `commit_docs`:
- `true` → commit normally
- `false` → skip git operations for `.planning/` files silently

## 5. Artifact Enforcement

Do NOT declare any GSD command complete until ALL items in its `<success_criteria>` checklist are satisfied:
- Required files exist on disk
- Required commits have been made
- `STATE.md` and `ROADMAP.md` updated where required
- `offer_next` or auto-advance output delivered to user

## 6. Drift Recovery

If deviation from GSD framework is detected, or user says "Get on tracks" / "Back on tracks":

1. Run `git log --oneline -20` — GSD micro-commits are the most reliable trail
2. Identify the last GSD-compliant commit and which command was being executed
3. Read that command's workflow file to get the full required steps and artifacts
4. Audit what exists on disk vs what the workflow requires
5. Identify the gap: which steps were skipped or done outside GSD
6. Resolve ONLY the missing parts — do not redo correct work
7. Report: "Getting back on track" + findings (where deviation occurred, what was done, what was skipped, what steps resolve it)

## 7. Context Self-Monitoring

Windsurf has no automatic context monitor. Self-monitor:

- When many files have been loaded and responses are getting long: proactively commit current state and note it
- **WARNING** (~35% context remaining): wrap up current task, do not start new complex work
- **CRITICAL** (~25% context remaining): stop immediately, save state, inform user

Commits are the safety net. Commit early and often so work survives context resets.

## 8. Revision Loop Tracking

When inside a plan-phase revision loop:
- Track `iteration_count` explicitly in your response at each iteration
- State it clearly: "Revision iteration 2/3"
- Do not lose count across role-switches

## 9. MCP Tools

`mcp__context7__*` in original GSD maps to Windsurf's native `mcp0_query-docs` and `mcp0_resolve-library-id`. Use these directly in researcher role-switches — no substitution needed.

## 10. Learning & Improvement

If a better Windsurf-native solution is found during execution:
- Note it as `[POSSIBLE IMPROVEMENT]` in a comment
- Do NOT implement it without user approval
- Continue following the GSD framework as written
