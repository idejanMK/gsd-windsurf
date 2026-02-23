# GSD Framework — Windsurf Port Plan

Refactor the GSD framework (v1.16.0) from a Claude Code-specific tool into a standalone, portable Windsurf-native project that any developer can install and use across all their projects.

---

## Repository Strategy

**New standalone repo — completely separate from any existing project.**

- Create new GitHub repo: `gsd-windsurf`
- Clone to a neutral location: `D:\Code\Tools\gsd-windsurf\` (or wherever you keep tools)
- **Not** inside DocScanAppDesktop or any GSD-managed project — avoids `.windsurf/` conflicts
- Open as its own workspace in Windsurf when working on it

**Prerequisites (one-time):**
- GitHub account ✅
- Git installed ✅
- Windsurf installed ✅
- No npm, no Node.js required — output is pure `.md` files

**New repo structure:**
```
gsd-windsurf/
├── .windsurf/
│   ├── rules/
│   │   └── gsd-core.md          ← always-on GSD behavior rules
│   └── workflows/               ← one .md per GSD command (slash commands)
│       ├── gsd-new-project.md
│       ├── gsd-plan-phase.md
│       ├── gsd-execute-phase.md
│       └── ... (all 25 commands)
├── skills/                      ← agent role bundles (replaces .claude/agents/)
│   ├── gsd-planner/
│   │   ├── SKILL.md
│   │   └── gsd-planner-instructions.md
│   ├── gsd-executor/
│   ├── gsd-debugger/
│   └── ... (all 11 agents)
├── references/                  ← shared reference docs (unchanged from original)
├── templates/                   ← unchanged from original
├── INSTALL.md                   ← how to copy into a project
└── README.md
```

---

## Core Architecture Changes

### Problem → Solution Map

| Claude Code Mechanism | Windsurf Equivalent |
|---|---|
| `/gsd:command` slash commands (`.claude/commands/gsd/`) | `/gsd-command` Windsurf Workflows (`.windsurf/workflows/`) |
| `Task(subagent_type="gsd-planner")` | Cascade reads `@skill gsd-planner` inline — role-switches itself |
| `node gsd-tools.js init ...` | PowerShell/Bash scripts OR inline Cascade file reads + grep |
| `C:/Users/ideja/.claude/get-shit-done/` hardcoded paths | Relative paths from project root `.gsd/` |
| `allowed-tools: Task` | Cascade's native tool calling (no declaration needed) |
| `AskUserQuestion` | `ask_user_question` (Windsurf's built-in) |
| `TodoWrite` | `todo_list` (Windsurf's built-in) |
| `SlashCommand` | Windsurf Workflow calls another workflow |

---

## Phase 1 — Repo Setup & Structure

1. Create new GitHub repo `gsd-windsurf` (public, MIT license)
2. Initialize with `README.md`, `INSTALL.md`, `.gitignore`
3. Create directory skeleton: `.windsurf/workflows/`, `.windsurf/rules/`, `skills/`, `references/`, `templates/`
4. Copy `references/` and `templates/` from existing GSD verbatim (no changes needed)
5. Create `INSTALL.md` — instructions for copying `.windsurf/` and `skills/` into any project

---

## Phase 2 — Rules (Replaces `.claude/CLAUDE.md` + settings)

Create `.windsurf/rules/gsd-core.md` — **Always On** activation mode:

```markdown
---
trigger: always_on
---
# GSD Framework Rules
- When user runs /gsd-* workflows, follow them strictly
- Reply "Got it." then continue
- After completing any GSD command, confirm all required artifacts exist
- Required artifacts vary by command: SUMMARY.md, VERIFICATION.md, STATE.md, ROADMAP.md
- Offer next steps (offer_next) after every command
- Micro-commit after every meaningful unit of work
- Commit message format: type(scope): description
```

Create `.windsurf/rules/gsd-drift-recovery.md` — **Manual** activation mode (user @mentions when needed):
- Contains the full drift recovery procedure (git log audit → gap identification → resolution)

---

## Phase 3 — Skills (Replaces `.claude/agents/`)

Windsurf Skills are the direct equivalent of Claude Code agents. Each skill = a folder with `SKILL.md` + the agent instructions file.

**Global skills** (go in `~/.codeium/windsurf/skills/`) so they work across ALL projects:

| Skill folder | Maps from agent | When Cascade invokes it |
|---|---|---|
| `gsd-planner/` | `gsd-planner.md` | Planning a phase |
| `gsd-executor/` | `gsd-executor.md` | Executing a plan |
| `gsd-debugger/` | `gsd-debugger.md` | Debugging sessions |
| `gsd-phase-researcher/` | `gsd-phase-researcher.md` | Researching a phase |
| `gsd-project-researcher/` | `gsd-project-researcher.md` | New project research |
| `gsd-verifier/` | `gsd-verifier.md` | Verifying phase completion |
| `gsd-plan-checker/` | `gsd-plan-checker.md` | Checking plan quality |
| `gsd-codebase-mapper/` | `gsd-codebase-mapper.md` | Mapping codebase |
| `gsd-roadmapper/` | `gsd-roadmapper.md` | Building roadmaps |
| `gsd-integration-checker/` | `gsd-integration-checker.md` | Milestone audit |
| `gsd-research-synthesizer/` | `gsd-research-synthesizer.md` | Synthesizing research |

Each `SKILL.md` format:
```markdown
---
name: gsd-planner
description: GSD planning agent — invoked when planning a phase, creating PLAN.md files, or running /gsd-plan-phase
---
[content of gsd-planner.md agent instructions]
```

**Key difference from Claude Code:** Instead of `Task(subagent_type="gsd-planner")`, workflows instruct Cascade to `@gsd-planner` — Cascade role-switches inline, reading the skill's instructions and acting as that agent for the duration of the task.

---

## Phase 4 — Workflows (Replaces `.claude/commands/gsd/`)

Each GSD command becomes a `.windsurf/workflows/gsd-[name].md` file.

**Workflow file format** (Windsurf):
```markdown
---
description: [what this workflow does — shown in slash command list]
---
[step-by-step instructions]
```

**Invocation:** User types `/gsd-plan-phase 3` in Cascade.

### Command → Workflow Mapping

| Original command | New workflow file | Complexity |
|---|---|---|
| `gsd:new-project` | `gsd-new-project.md` | High |
| `gsd:plan-phase` | `gsd-plan-phase.md` | High (spawns 3 agents) |
| `gsd:execute-phase` | `gsd-execute-phase.md` | High (wave execution) |
| `gsd:debug` | `gsd-debug.md` | High (spawns debugger) |
| `gsd:verify-work` | `gsd-verify-work.md` | Medium |
| `gsd:map-codebase` | `gsd-map-codebase.md` | Medium (4 parallel agents) |
| `gsd:new-milestone` | `gsd-new-milestone.md` | Medium |
| `gsd:complete-milestone` | `gsd-complete-milestone.md` | Medium |
| `gsd:audit-milestone` | `gsd-audit-milestone.md` | Medium |
| `gsd:research-phase` | `gsd-research-phase.md` | Medium |
| `gsd:quick` | `gsd-quick.md` | Medium |
| `gsd:discuss-phase` | `gsd-discuss-phase.md` | Low |
| `gsd:add-phase` | `gsd-add-phase.md` | Low |
| `gsd:insert-phase` | `gsd-insert-phase.md` | Low |
| `gsd:remove-phase` | `gsd-remove-phase.md` | Low |
| `gsd:add-todo` | `gsd-add-todo.md` | Low |
| `gsd:check-todos` | `gsd-check-todos.md` | Low |
| `gsd:pause-work` | `gsd-pause-work.md` | Low |
| `gsd:resume-work` | `gsd-resume-work.md` | Low |
| `gsd:progress` | `gsd-progress.md` | Low |
| `gsd:plan-milestone-gaps` | `gsd-plan-milestone-gaps.md` | Low |
| `gsd:list-phase-assumptions` | `gsd-list-phase-assumptions.md` | Low |
| `gsd:settings` | `gsd-settings.md` | Low |
| `gsd:help` | `gsd-help.md` | Low |
| `gsd:update` | `gsd-update.md` | Low (npm → git pull) |

### Key Workflow Rewrites

**`gsd-plan-phase.md`** — replaces `Task()` with inline skill invocation:
```
## Step 5: Research Phase
@gsd-phase-researcher — research Phase {X} and write RESEARCH.md

## Step 8: Plan Phase  
@gsd-planner — create PLAN.md files for Phase {X}

## Step 10: Verify Plans
@gsd-plan-checker — verify all PLAN.md files
```

**`gsd-execute-phase.md`** — replaces `Task(subagent_type="gsd-executor")` with:
```
For each plan in wave {N}:
@gsd-executor — execute {plan_file}, commit each task, write SUMMARY.md
```

**`gsd-debug.md`** — replaces `node gsd-tools.js state load` with:
```
Read .planning/STATE.md for current state
@gsd-debugger — investigate issue: {description}
```

---

## Phase 5 — Replace gsd-tools.js

`gsd-tools.js` is a 116KB Node.js CLI that does: state loading, roadmap parsing, model resolution, phase indexing, commit helpers. In Windsurf, Cascade does this natively.

**Replacement strategy — no binary needed:**

| gsd-tools.js function | Windsurf replacement |
|---|---|
| `init plan-phase` (load state/roadmap/requirements) | Cascade reads files directly with `read_file` tool |
| `roadmap get-phase` | Cascade greps ROADMAP.md for phase section |
| `resolve-model gsd-planner` | Hardcoded in workflow: "use best available model" |
| `state-snapshot` | Cascade reads STATE.md directly |
| `phase-plan-index` | Cascade lists `find_by_name` in phase directory |
| `commit "docs(phase-X): ..."` | Cascade runs `git add` + `git commit` via terminal |
| `state load` | Cascade reads STATE.md |

**Model profiles:** Replace `resolve-model` with a simple rule in `gsd-core.md`:
```
Model selection: Use the best available model for planning and execution.
For research/verification tasks, any capable model is sufficient.
```

---

## Phase 6 — Path Portability

Replace ALL `C:/Users/ideja/.claude/get-shit-done/` references with relative paths.

**New convention:** GSD resources live in `.gsd/` at project root (or are global skills):
- `references/` → `.gsd/references/`  
- `templates/` → `.gsd/templates/`
- `workflows/` → `.windsurf/workflows/` (Windsurf-native)
- `agents/` → global skills at `~/.codeium/windsurf/skills/`

Workflows reference templates as: `Read .gsd/templates/phase-prompt.md`

---

## Phase 7 — Installation UX

Two installation modes:

**Global (recommended):** Skills installed once, work in all projects
```
1. Clone gsd-windsurf repo
2. Run install.ps1 (Windows) / install.sh (Mac/Linux)
   - Copies skills/ → ~/.codeium/windsurf/skills/
   - Copies .windsurf/ → ~/.codeium/windsurf/ (global workflows + rules)
3. Per-project: copy .gsd/ folder to project root
```

**Per-project:** Everything in `.windsurf/` — no global install needed
```
1. Clone gsd-windsurf repo
2. Copy .windsurf/ and .gsd/ to your project
3. Done
```

---

## Windsurf-Native Enhancements (Beyond Claude Code GSD)

These are new capabilities GSD didn't have in Claude Code:

1. **Cascade Hooks** — auto-run after code writes:
   - `post_write_code`: auto-format, lint check
   - `post_cascade_response`: log GSD command completions for analytics

2. **AGENTS.md** — place in `.planning/` to give Cascade automatic context about the planning structure whenever it touches planning files

3. **Plan Mode** — Windsurf's built-in plan mode can be used for the `gsd-plan-phase` workflow before switching to Code mode for execution

4. **Worktrees** — `gsd-execute-phase` can leverage Windsurf's native worktree support for branch-per-phase execution

5. **Memories** — GSD STATE.md decisions can be mirrored as Cascade memories for cross-session persistence without reading STATE.md every time

---

## Execution Order

| Phase | Work | Effort |
|---|---|---|
| 1 | Repo setup + directory structure | 1h |
| 2 | Rules files (gsd-core + drift-recovery) | 1h |
| 3 | All 11 Skills (SKILL.md wrappers around existing agent .md files) | 2h |
| 4a | Low-complexity workflows (15 commands) | 3h |
| 4b | Medium-complexity workflows (6 commands) | 4h |
| 4c | High-complexity workflows (4 commands: plan-phase, execute-phase, debug, map-codebase) | 6h |
| 5 | Remove gsd-tools.js dependencies from all workflows | 3h |
| 6 | Path portability pass (replace all hardcoded paths) | 1h |
| 7 | Install scripts + README | 2h |
| — | **Total** | **~23h** |

---

## Open Questions for You

1. **Repo name:** `gsd-windsurf` or `windsurf-gsd` or something else?
2. **Skills scope:** Global (`~/.codeium/windsurf/skills/`) so they work in all projects, or per-project (`.windsurf/skills/`) requiring copy per project?
3. **gsd-tools.js:** Keep it as optional helper (still works if Node is installed) or remove entirely and go pure-Cascade?
4. **Workflow naming:** `/gsd-plan-phase` (hyphen) or keep `/gsd:plan-phase` style? (Windsurf workflows use `/name` format, colons not supported)
5. **Start point:** Begin with Phase 4a (low-complexity workflows, quick wins) or Phase 3 (skills, foundational)?
