---
description: Display the complete GSD command reference. Usage: /gsd/help
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Display the complete GSD command reference. Output ONLY the reference content. Do NOT add project-specific analysis, git status, next-step suggestions, or any commentary beyond the reference.
</purpose>

<reference>
# GSD Command Reference

**GSD** (Get Shit Done) creates hierarchical project plans optimized for solo agentic development with Windsurf Cascade.

## Quick Start

1. `/gsd/new-project` - Initialize project (includes research, requirements, roadmap)
2. `/gsd/plan-phase 1` - Create detailed plan for first phase
3. `/gsd/execute-phase 1` - Execute the phase

## Core Workflow

```
/gsd/new-project → /gsd/plan-phase → /gsd/execute-phase → repeat
```

### Project Initialization

**`/gsd/new-project`**
Initialize new project through unified flow.

One command takes you from idea to ready-for-planning:
- Deep questioning to understand what you're building
- Optional domain research (parallel researcher role-switches)
- Requirements definition with v1/v2/out-of-scope scoping
- Roadmap creation with phase breakdown and success criteria

Creates all `.planning/` artifacts:
- `PROJECT.md` — vision and requirements
- `config.json` — workflow mode (interactive/yolo)
- `research/` — domain research (if selected)
- `REQUIREMENTS.md` — scoped requirements with REQ-IDs
- `ROADMAP.md` — phases mapped to requirements
- `STATE.md` — project memory

Usage: `/gsd/new-project`

**`/gsd/map-codebase`**
Map an existing codebase for brownfield projects.

- Analyzes codebase with parallel mapper role-switches
- Creates `.planning/codebase/` with 7 focused documents
- Covers stack, architecture, structure, conventions, testing, integrations, concerns
- Use before `/gsd/new-project` on existing codebases

Usage: `/gsd/map-codebase`

### Phase Planning

**`/gsd/discuss-phase <number>`**
Help articulate your vision for a phase before planning.

- Captures how you imagine this phase working
- Creates CONTEXT.md with your vision, essentials, and boundaries
- Use when you have ideas about how something should look/feel

Usage: `/gsd/discuss-phase 2`

**`/gsd/research-phase <number>`**
Comprehensive ecosystem research for niche/complex domains.

- Discovers standard stack, architecture patterns, pitfalls
- Creates RESEARCH.md with "how experts build this" knowledge
- Use for 3D, games, audio, shaders, ML, and other specialized domains
- Goes beyond "which library" to ecosystem knowledge

Usage: `/gsd/research-phase 3`

**`/gsd/list-phase-assumptions <number>`**
See what Cascade is planning to do before it starts.

- Shows Cascade's intended approach for a phase
- Lets you course-correct if Cascade misunderstood your vision
- No files created - conversational output only

Usage: `/gsd/list-phase-assumptions 3`

**`/gsd/plan-phase <number>`**
Create detailed execution plan for a specific phase.

- Generates `.planning/phases/XX-phase-name/XX-YY-PLAN.md`
- Breaks phase into concrete, actionable tasks
- Includes verification criteria and success measures
- Multiple plans per phase supported (XX-01, XX-02, etc.)

Usage: `/gsd/plan-phase 1`
Result: Creates `.planning/phases/01-foundation/01-01-PLAN.md`

### Execution

**`/gsd/execute-phase <phase-number>`**
Execute all plans in a phase.

- Groups plans by wave (from frontmatter), executes waves sequentially
- Plans within each wave run via role-switches
- Verifies phase goal after all plans complete
- Updates REQUIREMENTS.md, ROADMAP.md, STATE.md

Usage: `/gsd/execute-phase 5`

### Quick Mode

**`/gsd/quick`**
Execute small, ad-hoc tasks with GSD guarantees but skip optional agents.

Quick mode uses the same system with a shorter path:
- Spawns planner + executor role-switches (skips researcher, checker, verifier)
- Quick tasks live in `.planning/quick/` separate from planned phases
- Updates STATE.md tracking (not ROADMAP.md)

Use when you know exactly what to do and the task is small enough to not need research or verification.

Usage: `/gsd/quick`
Usage: `/gsd/quick Fix the login button color`
Usage: `/gsd/quick --full` (enables plan-checking + verification)
Result: Creates `.planning/quick/NNN-slug/PLAN.md`, `.planning/quick/NNN-slug/SUMMARY.md`

### Roadmap Management

**`/gsd/add-phase <description>`**
Add new phase to end of current milestone.

Usage: `/gsd/add-phase "Add admin dashboard"`

**`/gsd/insert-phase <after> <description>`**
Insert urgent work as decimal phase between existing phases.

Usage: `/gsd/insert-phase 7 "Fix critical auth bug"`
Result: Creates Phase 7.1

**`/gsd/remove-phase <number>`**
Remove a future phase and renumber subsequent phases.

Usage: `/gsd/remove-phase 17`
Result: Phase 17 deleted, phases 18-20 become 17-19

### Milestone Management

**`/gsd/new-milestone <name>`**
Start a new milestone through unified flow.

Usage: `/gsd/new-milestone "v2.0 Features"`

**`/gsd/complete-milestone <version>`**
Archive completed milestone and prepare for next version.

Usage: `/gsd/complete-milestone 1.0.0`

### Progress Tracking

**`/gsd/progress`**
Check project status and intelligently route to next action.

Usage: `/gsd/progress`

### Session Management

**`/gsd/resume-work`**
Resume work from previous session with full context restoration.

Usage: `/gsd/resume-work`

**`/gsd/pause-work`**
Create context handoff when pausing work mid-phase.

Usage: `/gsd/pause-work`

### Debugging

**`/gsd/diagnose-issues`**
Orchestrate parallel debug role-switches to investigate UAT gaps and find root causes.

Usage: Invoked automatically by verify-work when gaps are found.

### Todo Management

**`/gsd/add-todo [description]`**
Capture idea or task as todo from current conversation.

Usage: `/gsd/add-todo` (infers from conversation)
Usage: `/gsd/add-todo Add auth token refresh`

**`/gsd/check-todos [area]`**
List pending todos and select one to work on.

Usage: `/gsd/check-todos`
Usage: `/gsd/check-todos api`

### User Acceptance Testing

**`/gsd/verify-work [phase]`**
Validate built features through conversational UAT.

Usage: `/gsd/verify-work 3`

### Milestone Auditing

**`/gsd/audit-milestone [version]`**
Audit milestone completion against original intent.

Usage: `/gsd/audit-milestone`

**`/gsd/plan-milestone-gaps`**
Create phases to close gaps identified by audit.

Usage: `/gsd/plan-milestone-gaps`

### Configuration

**`/gsd/settings`**
Configure workflow toggles and model profile interactively.

Usage: `/gsd/settings`

**`/gsd/set-profile <profile>`**
Quick switch model profile for GSD agents.

- `quality` — Best quality, highest cost
- `balanced` — Good quality/cost ratio (default)
- `budget` — Fastest, lowest cost

Usage: `/gsd/set-profile budget`

### Utility Commands

**`/gsd/cleanup`**
Archive accumulated phase directories from completed milestones.

Usage: `/gsd/cleanup`

**`/gsd/health [--repair]`**
Validate `.planning/` directory integrity and report actionable issues.

Usage: `/gsd/health`
Usage: `/gsd/health --repair`

**`/gsd/help`**
Show this command reference.

**`/gsd/update`**
Update GSD to latest version with changelog preview.

Usage: `/gsd/update`

## Files & Structure

```
.planning/
├── PROJECT.md            # Project vision
├── ROADMAP.md            # Current phase breakdown
├── STATE.md              # Project memory & context
├── config.json           # Workflow mode & gates
├── todos/                # Captured ideas and tasks
│   ├── pending/          # Todos waiting to be worked on
│   └── done/             # Completed todos
├── debug/                # Active debug sessions
│   └── resolved/         # Archived resolved issues
├── milestones/
│   ├── v1.0-ROADMAP.md       # Archived roadmap snapshot
│   ├── v1.0-REQUIREMENTS.md  # Archived requirements
│   └── v1.0-phases/          # Archived phase dirs (via /gsd/cleanup)
│       ├── 01-foundation/
│       └── 02-core-features/
├── codebase/             # Codebase map (brownfield projects)
│   ├── STACK.md
│   ├── ARCHITECTURE.md
│   ├── STRUCTURE.md
│   ├── CONVENTIONS.md
│   ├── TESTING.md
│   ├── INTEGRATIONS.md
│   └── CONCERNS.md
└── phases/
    ├── 01-foundation/
    │   ├── 01-01-PLAN.md
    │   └── 01-01-SUMMARY.md
    └── 02-core-features/
        ├── 02-01-PLAN.md
        └── 02-01-SUMMARY.md
```

## Workflow Modes

Set during `/gsd/new-project`:

**Interactive Mode**
- Confirms each major decision
- Pauses at checkpoints for approval
- More guidance throughout

**YOLO Mode**
- Auto-approves most decisions
- Executes plans without confirmation
- Only stops for critical checkpoints

Change anytime by editing `.planning/config.json`

## Planning Configuration

Configure how planning artifacts are managed in `.planning/config.json`:

**`commit_docs`** (default: `true`)
- `true`: Planning artifacts committed to git
- `false`: Planning artifacts kept local-only

**`workflow.research`** (default: `true`)
- Spawn researcher during plan-phase

**`workflow.plan_check`** (default: `true`)
- Spawn plan checker during plan-phase

**`workflow.verifier`** (default: `true`)
- Spawn verifier during execute-phase

## Common Workflows

**Starting a new project:**
```
/gsd/new-project        # Unified flow: questioning → research → requirements → roadmap
/clear
/gsd/plan-phase 1       # Create plans for first phase
/clear
/gsd/execute-phase 1    # Execute all plans in phase
```

**Resuming work after a break:**
```
/gsd/progress  # See where you left off and continue
```

**Adding urgent mid-milestone work:**
```
/gsd/insert-phase 5 "Critical security fix"
/gsd/plan-phase 5.1
/gsd/execute-phase 5.1
```

**Completing a milestone:**
```
/gsd/complete-milestone 1.0.0
/clear
/gsd/new-milestone  # Start next milestone
```

**Capturing ideas during work:**
```
/gsd/add-todo                    # Capture from conversation context
/gsd/add-todo Fix modal z-index  # Capture with explicit description
/gsd/check-todos                 # Review and work on todos
/gsd/check-todos api             # Filter by area
```

## Getting Help

- Read `.planning/PROJECT.md` for project vision
- Read `.planning/STATE.md` for current context
- Check `.planning/ROADMAP.md` for phase status
- Run `/gsd/progress` to check where you're up to
</reference>
