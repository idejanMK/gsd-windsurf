---
description: Initialize a new project — questioning, research, requirements, roadmap. Usage: /gsd/new-project [--auto]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Initialize a new project through unified flow: questioning, research (optional), requirements, roadmap. One workflow takes you from idea to ready-for-planning.
</purpose>

<required_reading>
Read before starting:
- GSD_HOME/references/ui-brand.md
- GSD_HOME/references/questioning.md
- GSD_HOME/templates/project.md
- GSD_HOME/templates/requirements.md
</required_reading>

<auto_mode>
## Auto Mode Detection

Check if `--auto` flag is present in arguments.

**If auto mode:**
- Skip brownfield mapping offer (assume greenfield)
- Skip deep questioning (extract context from provided document)
- Config: YOLO mode implicit; ask depth/git/agents in Step 2a first
- After config: run Steps 6-9 automatically with smart defaults

**Document requirement:** Auto mode requires an idea document — file reference or pasted text.

If no document content provided:
```
Error: --auto requires an idea document.

Usage:
  /gsd/new-project --auto @your-idea.md
  /gsd/new-project --auto [paste or write your idea here]
```
</auto_mode>

<process>

## 1. Setup

[TOOL HARNESS: read_file, run_command, find_by_name]

**MANDATORY FIRST — execute before any user interaction:**

Check for existing files:
- Read `.planning/STATE.md` if exists → `project_exists = true`
- Read `.planning/config.json` if exists
- Use find_by_name to check for `package.json`, `*.csproj`, `requirements.txt`, `go.mod`, `Cargo.toml` in root → `has_existing_code`
- Check `.planning/codebase/` exists with files → `has_codebase_map`
- `needs_codebase_map = has_existing_code AND NOT has_codebase_map`

Check git: run_command `git rev-parse --git-dir 2>$null`
- If exit code non-zero: `has_git = false`

**If `project_exists` is true:** Error — project already initialized. Use `/gsd/progress`.

**If `has_git` is false:** run_command: `git init`

## 2. Brownfield Offer

**If auto mode:** Skip to Step 4.

**If `needs_codebase_map` is true:**

Use ask_user_question:
- question: "I detected existing code. Map the codebase first for better planning?"
- options:
  - label: "Map codebase first" — description: Run /gsd/map-codebase to understand existing architecture (Recommended)
  - label: "Skip mapping" — description: Proceed with project initialization

If "Map codebase first": Output "Run `/gsd/map-codebase` first, then return to `/gsd/new-project`" → exit.

## 2a. Auto Mode Config (auto mode only)

Collect config upfront before processing the idea document.

Use ask_user_question for each (allowMultiple: false):

1. Depth: "How thorough should planning be?"
   - label: "Quick" — description: Ship fast (3-5 phases, 1-3 plans each)
   - label: "Standard (Recommended)" — description: Balanced scope and speed (5-8 phases, 3-5 plans each)
   - label: "Comprehensive" — description: Thorough coverage (8-12 phases, 5-10 plans each)

2. Git Tracking: "Commit planning docs to git?"
   - label: "Yes (Recommended)" — description: Planning docs tracked in version control
   - label: "No" — description: Keep .planning/ local-only

3. Research: "Research before planning each phase?"
   - label: "Yes (Recommended)" — description: Investigate domain, find patterns, surface gotchas
   - label: "No" — description: Plan directly from requirements

4. Plan Check: "Verify plans before execution?"
   - label: "Yes (Recommended)" — description: Catch gaps before execution starts
   - label: "No" — description: Execute plans without verification

5. AI Models: "Which AI models for planning agents?"
   - label: "Balanced (Recommended)" — description: Good quality/cost ratio
   - label: "Quality" — description: Deeper analysis, more thorough
   - label: "Budget" — description: Fastest, lowest cost

Create `.planning/config.json` from selections (use GSD_HOME/templates/config.json as base):
```json
{
  "mode": "yolo",
  "depth": "[selected]",
  "parallelization": false,
  "commit_docs": true,
  "model_profile": "[selected]",
  "workflow": {
    "research": true,
    "plan_check": true,
    "verifier": true,
    "auto_advance": true
  }
}
```

If commit_docs = No: run_command: `echo ".planning/" >> .gitignore`

run_command: `mkdir -p .planning`
run_command: `git add .planning/config.json`
run_command: `git commit -m "chore: add project config"`

Proceed to Step 4 (skip Steps 3 and 5).

## 3. Deep Questioning

**If auto mode:** Skip. Extract project context from provided document → Step 4.

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► QUESTIONING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Open the conversation (freeform, NOT ask_user_question):**

"What do you want to build?"

Wait for response. Then follow threads — ask follow-up questions that dig into what they said. Consult GSD_HOME/references/questioning.md for techniques: challenge vagueness, make abstract concrete, surface assumptions, find edges, reveal motivation.

**Decision gate:** When you could write a clear PROJECT.md:

Use ask_user_question:
- question: "I think I understand what you're after. Ready to create PROJECT.md?"
- options:
  - label: "Create PROJECT.md" — description: Let's move forward
  - label: "Keep exploring" — description: I want to share more

Loop until "Create PROJECT.md" selected.

## 4. Write PROJECT.md

[TOOL HARNESS: read_file, write_to_file, run_command]

**If auto mode:** Synthesize from provided document.

Synthesize all context into `.planning/PROJECT.md` using GSD_HOME/templates/project.md as structure.

For greenfield: initialize requirements as hypotheses (Active section).
For brownfield (codebase map exists): read `.planning/codebase/ARCHITECTURE.md` and `STACK.md`, infer Validated requirements from existing code.

Initialize Key Decisions from anything decided during questioning.

run_command: `mkdir -p .planning`
run_command: `git add .planning/PROJECT.md`
run_command: `git commit -m "docs: initialize project"`

## 5. Workflow Preferences

**If auto mode:** Skip — config collected in Step 2a. Proceed to Step 5.5.

[TOOL HARNESS: read_file, write_to_file, run_command]

Check for saved defaults at GSD_HOME/defaults.json:

Use ask_user_question:
- question: "Use your saved default settings?"
- options:
  - label: "Yes (Recommended)" — description: Use saved defaults, skip settings questions
  - label: "No" — description: Configure settings manually

If "Yes" and defaults.json exists: use those values, skip to commit config.

Otherwise ask each setting:

1. Mode: "How do you want to work?"
   - label: "YOLO (Recommended)" — description: Auto-approve, just execute
   - label: "Interactive" — description: Confirm at each step

2. Depth: "How thorough should planning be?"
   - label: "Quick" — description: Ship fast (3-5 phases)
   - label: "Standard (Recommended)" — description: Balanced (5-8 phases)
   - label: "Comprehensive" — description: Thorough (8-12 phases)

3. Git Tracking: "Commit planning docs to git?"
   - label: "Yes (Recommended)" — description: Tracked in version control
   - label: "No" — description: Keep .planning/ local-only

4. Research: "Research before planning each phase?"
   - label: "Yes (Recommended)" — description: Investigate domain first
   - label: "No" — description: Plan directly from requirements

5. Plan Check: "Verify plans before execution?"
   - label: "Yes (Recommended)" — description: Catch gaps early
   - label: "No" — description: Skip verification

6. Verifier: "Verify work after each phase?"
   - label: "Yes (Recommended)" — description: Confirm deliverables match goals
   - label: "No" — description: Trust execution

7. AI Models: "Which AI models?"
   - label: "Balanced (Recommended)" — description: Good quality/cost ratio
   - label: "Quality" — description: Deeper analysis
   - label: "Budget" — description: Fastest, lowest cost

Create `.planning/config.json` from selections.

If commit_docs = No: run_command: `echo ".planning/" >> .gitignore`

run_command: `git add .planning/config.json`
run_command: `git commit -m "chore: add project config"`

## 5.5. Resolve Model Profile

From config.json `model_profile`: quality / balanced / budget.
This determines which model tier to use for researcher/roadmapper role-switches.

## 6. Research Decision

[TOOL HARNESS: read_file, write_to_file, run_command, mcp0_query-docs, search_web]

**If auto mode:** Default to research. Skip ask.

Use ask_user_question:
- question: "Research the domain ecosystem before defining requirements?"
- options:
  - label: "Research first (Recommended)" — description: Discover standard stacks, expected features, architecture patterns
  - label: "Skip research" — description: I know this domain well

**If "Research first":**

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► RESEARCHING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

run_command: `mkdir -p .planning/research`

Display:
```
◆ Running 4 researchers sequentially...
  → Stack research
  → Features research
  → Architecture research
  → Pitfalls research
```

Note: Windsurf executes sequentially — each researcher role-switch is independent.

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Stack** dimension.
  Read: `.planning/PROJECT.md`
  Research: "What's the standard 2025 stack for [domain]?"
  Use mcp0_resolve-library-id + mcp0_query-docs for library docs, search_web for current versions.
  Use GSD_TEMPLATES/research-project/STACK.md as output template.
  Write to: `.planning/research/STACK.md`
  Return: ## RESEARCH COMPLETE or ## RESEARCH BLOCKED
→ END ROLE

Display: `✓ Stack research complete`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Features** dimension.
  Read: `.planning/PROJECT.md`
  Research: "What features do [domain] products have? Table stakes vs differentiators?"
  Use GSD_TEMPLATES/research-project/FEATURES.md as output template.
  Write to: `.planning/research/FEATURES.md`
→ END ROLE

Display: `✓ Features research complete`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Architecture** dimension.
  Read: `.planning/PROJECT.md`
  Research: "How are [domain] systems typically structured? Major components?"
  Use GSD_TEMPLATES/research-project/ARCHITECTURE.md as output template.
  Write to: `.planning/research/ARCHITECTURE.md`
→ END ROLE

Display: `✓ Architecture research complete`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Pitfalls** dimension.
  Read: `.planning/PROJECT.md`
  Research: "What do [domain] projects commonly get wrong? Critical mistakes?"
  Use GSD_TEMPLATES/research-project/PITFALLS.md as output template.
  Write to: `.planning/research/PITFALLS.md`
→ END ROLE

Display: `✓ Pitfalls research complete`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-research-synthesizer.md
  Act as gsd-research-synthesizer.
  Read: `.planning/research/STACK.md`, `FEATURES.md`, `ARCHITECTURE.md`, `PITFALLS.md`
  Use GSD_TEMPLATES/research-project/SUMMARY.md as output template.
  Write to: `.planning/research/SUMMARY.md`
→ END ROLE

run_command: `git add .planning/research/`
run_command: `git commit -m "docs: add project research"`

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► RESEARCH COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Key Findings: [from SUMMARY.md — stack, table stakes, watch-outs]
```

**If "Skip research":** Continue to Step 7.

## 7. Define Requirements

[TOOL HARNESS: read_file, write_to_file, run_command]

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► DEFINING REQUIREMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Read PROJECT.md → extract core value, constraints, scope boundaries.
If research exists: read `research/FEATURES.md` → extract feature categories.

**If auto mode:** Auto-include all table stakes + features from provided document. Skip per-category questions. Generate REQUIREMENTS.md and commit directly.

**Interactive mode:** Present features by category. For each category use ask_user_question (allowMultiple: true) to scope v1 vs v2 vs out-of-scope. Then ask if anything was missed.

Generate `.planning/REQUIREMENTS.md` using GSD_TEMPLATES/requirements.md:
- v1 Requirements grouped by category (checkboxes, REQ-IDs: `CATEGORY-NN`)
- v2 Requirements (deferred)
- Out of Scope (explicit exclusions with reasoning)
- Traceability section (empty, filled by roadmap)

**Interactive mode only:** Present full requirements list, ask "Does this capture what you're building? (yes / adjust)"

run_command: `git add .planning/REQUIREMENTS.md`
run_command: `git commit -m "docs: define v1 requirements"`

## 8. Create Roadmap

[TOOL HARNESS: read_file, write_to_file, run_command]

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► CREATING ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning roadmapper...
```

→ ROLE SWITCH: Read GSD_AGENTS/gsd-roadmapper.md
  Act as gsd-roadmapper.
  Read:
  - `.planning/PROJECT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/research/SUMMARY.md` (if exists)
  - `.planning/config.json`
  Instructions:
  1. Derive phases from requirements (don't impose structure)
  2. Map every v1 requirement to exactly one phase
  3. Derive 2-5 success criteria per phase (observable user behaviors)
  4. Validate 100% coverage
  5. Write immediately: `.planning/ROADMAP.md` and `.planning/STATE.md`
     Use GSD_TEMPLATES/roadmap.md and GSD_TEMPLATES/state.md as structure
  6. Update `.planning/REQUIREMENTS.md` traceability section
  7. Return: ## ROADMAP CREATED {summary} or ## ROADMAP BLOCKED {blocker}
→ END ROLE

**If ## ROADMAP BLOCKED:** Present blocker, work with user to resolve, re-enter roadmapper role.

**If ## ROADMAP CREATED:**

Read ROADMAP.md and present it inline as a table.

**If auto mode:** Auto-approve, commit directly.

**Interactive mode — approval gate:**

Use ask_user_question:
- question: "Does this roadmap structure work for you?"
- options:
  - label: "Approve" — description: Commit and continue
  - label: "Adjust phases" — description: Tell me what to change
  - label: "Review full file" — description: Show raw ROADMAP.md

If "Adjust phases": get user notes, re-enter roadmapper role with revision context, loop until approved.
If "Review full file": read and display raw ROADMAP.md, re-ask.

**After approval:**

run_command: `git add .planning/ROADMAP.md .planning/STATE.md .planning/REQUIREMENTS.md`
run_command: `git commit -m "docs: create roadmap ([N] phases)"`

## 9. Done

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PROJECT INITIALIZED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**[Project Name]** — [N] phases | [X] requirements | Ready to build ✓

| Artifact       | Location                    |
|----------------|-----------------------------|
| Project        | .planning/PROJECT.md        |
| Config         | .planning/config.json       |
| Research       | .planning/research/         |
| Requirements   | .planning/REQUIREMENTS.md   |
| Roadmap        | .planning/ROADMAP.md        |
```

**If auto mode:**

Output: "Run `/gsd/discuss-phase 1 --auto` next — `/clear` first for fresh context window"

**If interactive mode:**

```
───────────────────────────────────────────────────────────────

## ▶ Next Up

**Phase 1: [Phase Name]** — [Goal from ROADMAP.md]

`/gsd/discuss-phase 1`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `/gsd/plan-phase 1` — skip discussion, plan directly

───────────────────────────────────────────────────────────────
```

</process>

<success_criteria>
- [ ] .planning/ directory created
- [ ] Git repo initialized
- [ ] Brownfield detection completed
- [ ] Deep questioning completed (threads followed, not rushed)
- [ ] PROJECT.md captures full context → committed
- [ ] config.json has workflow mode, depth, parallelization → committed
- [ ] Research completed (if selected) — 4 researcher role-switches + synthesizer → committed
- [ ] REQUIREMENTS.md created with REQ-IDs → committed
- [ ] gsd-roadmapper role-switch executed with full context
- [ ] ROADMAP.md created with phases, requirement mappings, success criteria
- [ ] STATE.md initialized
- [ ] REQUIREMENTS.md traceability updated
- [ ] User knows next step
- [ ] All artifacts committed atomically at each step
</success_criteria>
