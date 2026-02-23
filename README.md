# GSD for Windsurf

GSD (Get Shit Done) framework ported to Windsurf/Cascade. Preserves all GSD principles — atomic commits, artifact enforcement, drift recovery, tool discipline — adapted to Windsurf's single-context, workflow-based architecture.

## Structure

```
gsd-refactoring/
├── src/
│   ├── agents/          # Agent role definitions (verbatim from GSD source)
│   ├── references/      # Reference docs (verbatim from GSD source)
│   ├── templates/       # Artifact templates (verbatim from GSD source)
│   ├── rules/           # gsd-core.md — always-on Windsurf harness rule
│   └── workflows/
│       └── gsd/         # All /gsd/* Windsurf workflows
├── install.ps1          # Installs to ~/.codeium/windsurf/
├── install.sh           # Installs to ~/.codeium/windsurf/ (macOS/Linux)
└── README.md
```

## Install

**Windows (PowerShell):**
```powershell
.\install.ps1
```

**macOS/Linux:**
```bash
./install.sh
```

The installer copies:
- `src/workflows/gsd/` → `~/.codeium/windsurf/windsurf/workflows/gsd/`
- `src/rules/gsd-core.md` → `~/.codeium/windsurf/windsurf/rules/gsd-core.md`
- `src/agents/`, `src/references/`, `src/templates/` → `~/.codeium/windsurf/get-shit-done/`

## Usage

### Global install — works in every project

GSD is installed **globally** into your Windsurf user profile (`~/.codeium/windsurf/`). You install it once and `/gsd/*` workflows are available in every Windsurf project automatically — no per-project setup required.

### Activating in a new project

Open any project in Windsurf and run:

```
/gsd/new-project
```

This creates a `.planning/` directory in your project root with all GSD artifacts (`PROJECT.md`, `ROADMAP.md`, `STATE.md`, `config.json`). The `.planning/` folder is project-specific — GSD tracks each project independently.

### Resuming an existing project

When returning to a project that already has `.planning/`:

```
/gsd/progress    — see where you left off and route to next action
/gsd/resume-work — full context restoration from previous session
```

### Available commands

Type `/gsd/` in any Windsurf chat to see all commands with descriptions. Key commands:

```
/gsd/new-project          — Initialize project (questioning -> research -> requirements -> roadmap)
/gsd/discuss-phase [N]    — Capture design decisions for a phase
/gsd/plan-phase [N]       — Create PLAN.md files with research + verification loop
/gsd/execute-phase [N]    — Execute all plans for a phase
/gsd/verify-work [N]      — Verify phase completion against requirements
/gsd/progress             — Show project status and route to next action
/gsd/help                 — Full command reference (all 33 commands)
```

> **Tip:** After each major command, run `/clear` to start a fresh context window before the next command. GSD workflows are designed to run in clean context.

## Architecture

Windsurf has no subagent spawning (`Task()`). GSD agents are implemented as **role-switches**: Cascade reads the agent's instruction file and adopts that role for the duration of a workflow step, then drops it cleanly.

Key substitutions from Claude Code → Windsurf:
- `Task()` → role-switch (read agent file, act as agent, END ROLE)
- `gsd-tools.cjs` → direct file reads + native git commands
- `@~/.claude/` paths → `~/.codeium/windsurf/get-shit-done/`
- PostToolUse hooks → self-monitoring rules in `gsd-core.md`
- `mcp__context7__*` → `mcp0_query-docs` (native Windsurf MCP)

## Source

Original GSD for Claude Code: https://github.com/gsd-build/get-shit-done
