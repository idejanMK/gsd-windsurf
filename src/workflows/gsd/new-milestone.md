---
description: Start a new milestone cycle for an existing project. Brownfield equivalent of new-project. Usage: /gsd/new-milestone
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Start a new milestone cycle for an existing project. Loads project context, gathers milestone goals, updates PROJECT.md and STATE.md, optionally runs research, defines scoped requirements with REQ-IDs, spawns roadmapper to create phased execution plan, and commits all artifacts.
</purpose>

<process>

## 1. Load Context

[TOOL HARNESS: read_file, find_by_name]

Read:
- `.planning/PROJECT.md` (existing project, validated requirements, decisions)
- `.planning/MILESTONES.md` (what shipped previously — if exists)
- `.planning/STATE.md` (pending todos, blockers)
- `.planning/config.json` (workflow settings)
- `{phase_dir}/MILESTONE-CONTEXT.md` if exists (from a discuss-milestone command)

Extract from config.json: `commit_docs`, `model_profile`, `workflow.research`.

## 2. Gather Milestone Goals

**If MILESTONE-CONTEXT.md exists:**
- Use features and scope from it
- Present summary for confirmation via ask_user_question:
  - question: "Found milestone context. Use this as the basis for the new milestone?"
  - options:
    - label: "Yes, use this context" — description: Proceed with captured goals
    - label: "Start fresh" — description: Gather goals through conversation

**If no context file:**
- Present what shipped in last milestone (from MILESTONES.md)
- Ask (freeform): "What do you want to build next?"
- Use ask_user_question to explore features, priorities, constraints, scope

## 3. Determine Milestone Version

Parse last version from MILESTONES.md (or default to v1.0 if first milestone).

Suggest next version: v1.0 → v1.1, or v2.0 for major.

Use ask_user_question:
- question: "What version should this milestone be?"
- options:
  - label: "v{suggested}" — description: Suggested next version
  - label: "Custom" — description: I'll specify the version

## 4. Update PROJECT.md

[TOOL HARNESS: read_file, write_to_file]

Add/update Current Milestone section:

```markdown
## Current Milestone: v{X.Y} {Name}

**Goal:** {One sentence describing milestone focus}

**Target features:**
- {Feature 1}
- {Feature 2}
```

Update Active requirements section and "Last updated" footer.

## 5. Update STATE.md

[TOOL HARNESS: write_to_file]

Update:
```markdown
## Current Position

Phase: Not started (defining requirements)
Plan: —
Status: Defining requirements
Last activity: {today} — Milestone v{X.Y} started
```

Keep Accumulated Context section from previous milestone.

## 6. Cleanup and Commit

[TOOL HARNESS: run_command]

Delete MILESTONE-CONTEXT.md if exists (consumed).

If commit_docs=true:
run_command: `git add .planning/PROJECT.md .planning/STATE.md`
run_command: `git commit -m "docs: start milestone v{X.Y} {Name}"`

## 7. Research Decision

[TOOL HARNESS: read_file, write_to_file, run_command, mcp0_query-docs, search_web]

Use ask_user_question:
- question: "Research the domain ecosystem for new features before defining requirements?"
- options:
  - label: "Research first (Recommended)" — description: Discover patterns, features, architecture for NEW capabilities
  - label: "Skip research" — description: Go straight to requirements

Update config.json `workflow.research` to persist choice.

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
◆ Running 4 researchers sequentially (milestone-aware)...
  → Stack additions
  → New features
  → Architecture integration
  → Pitfalls when adding to existing system
```

For each researcher, read existing PROJECT.md to understand what's already built. Focus ONLY on what's needed for NEW features.

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Stack additions**.
  Read: `.planning/PROJECT.md`
  Research: "What stack additions/changes are needed for {new features}?"
  Focus: Specific libraries with versions for NEW capabilities. What NOT to add.
  Existing validated capabilities (DO NOT re-research): {from PROJECT.md Validated section}
  Use GSD_TEMPLATES/research-project/STACK.md as output template.
  Write to: `.planning/research/STACK.md`
→ END ROLE

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **New features**.
  Read: `.planning/PROJECT.md`
  Research: "How do {target features} typically work? Expected behavior?"
  Focus: Table stakes vs differentiators vs anti-features. Dependencies on existing.
  Existing features (already built): {from PROJECT.md Validated section}
  Use GSD_TEMPLATES/research-project/FEATURES.md as output template.
  Write to: `.planning/research/FEATURES.md`
→ END ROLE

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Architecture integration**.
  Read: `.planning/PROJECT.md`
  Research: "How do {target features} integrate with existing architecture?"
  Focus: Integration points, new components, data flow changes, suggested build order.
  Existing architecture: {from PROJECT.md or .planning/codebase/ if exists}
  Use GSD_TEMPLATES/research-project/ARCHITECTURE.md as output template.
  Write to: `.planning/research/ARCHITECTURE.md`
→ END ROLE

→ ROLE SWITCH: Read GSD_AGENTS/gsd-project-researcher.md
  Act as gsd-project-researcher for **Pitfalls**.
  Read: `.planning/PROJECT.md`
  Research: "Common mistakes when ADDING {target features} to existing {domain} system?"
  Focus: Warning signs, prevention strategy, integration pitfalls.
  Use GSD_TEMPLATES/research-project/PITFALLS.md as output template.
  Write to: `.planning/research/PITFALLS.md`
→ END ROLE

→ ROLE SWITCH: Read GSD_AGENTS/gsd-research-synthesizer.md
  Act as gsd-research-synthesizer.
  Read: `.planning/research/STACK.md`, `FEATURES.md`, `ARCHITECTURE.md`, `PITFALLS.md`
  Use GSD_TEMPLATES/research-project/SUMMARY.md as output template.
  Write to: `.planning/research/SUMMARY.md`
→ END ROLE

If commit_docs=true:
run_command: `git add .planning/research/`
run_command: `git commit -m "docs: add milestone v{X.Y} research"`

Display key findings from SUMMARY.md.

**If "Skip research":** Continue to Step 8.

## 8. Define Requirements

[TOOL HARNESS: read_file, write_to_file, run_command]

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► DEFINING REQUIREMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Read PROJECT.md: core value, current milestone goals, validated requirements (what exists).
If research exists: read FEATURES.md, extract feature categories.

Present features by category. For each category use ask_user_question (allowMultiple: true) to scope this milestone vs future vs out-of-scope.

Generate `.planning/REQUIREMENTS.md`:
- This milestone requirements grouped by category (checkboxes, REQ-IDs continuing from existing)
- Future requirements (deferred)
- Out of Scope (explicit exclusions)
- Traceability section (empty)

**REQ-ID format:** Continue numbering from existing requirements (e.g., if AUTH-03 exists, next is AUTH-04).

Present full requirements list for confirmation. If "adjust": return to scoping.

If commit_docs=true:
run_command: `git add .planning/REQUIREMENTS.md`
run_command: `git commit -m "docs: define milestone v{X.Y} requirements"`

## 9. Create Roadmap

[TOOL HARNESS: read_file, write_to_file, run_command]

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► CREATING ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning roadmapper...
```

**Starting phase number:** Read MILESTONES.md for last phase number. Continue from there (v1.0 ended at phase 5 → v1.1 starts at phase 6).

→ ROLE SWITCH: Read GSD_AGENTS/gsd-roadmapper.md
  Act as gsd-roadmapper.
  Read:
  - `.planning/PROJECT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/research/SUMMARY.md` (if exists)
  - `.planning/config.json`
  - `.planning/MILESTONES.md` (for phase numbering continuity)
  Instructions:
  1. Start phase numbering from {last_phase + 1}
  2. Derive phases from THIS MILESTONE's requirements only
  3. Map every requirement to exactly one phase
  4. Derive 2-5 success criteria per phase
  5. Validate 100% coverage
  6. Write immediately: `.planning/ROADMAP.md`, `.planning/STATE.md`, update REQUIREMENTS.md traceability
  7. Return: `## ROADMAP CREATED {summary}` or `## ROADMAP BLOCKED {blocker}`
→ END ROLE

**If ROADMAP BLOCKED:** Present blocker, work with user, re-enter roadmapper role.

**If ROADMAP CREATED:** Read ROADMAP.md, present inline as table. Ask for approval via ask_user_question. If "Adjust phases": get notes, re-enter roadmapper with revision context.

If commit_docs=true:
run_command: `git add .planning/ROADMAP.md .planning/STATE.md .planning/REQUIREMENTS.md`
run_command: `git commit -m "docs: create milestone v{X.Y} roadmap ({N} phases)"`

## 10. Done

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► MILESTONE INITIALIZED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Milestone v{X.Y}: {Name}** — {N} phases | {X} requirements | Ready to build ✓

## ▶ Next Up

**Phase {N}: {Phase Name}** — {Goal}

`/gsd/discuss-phase {N}`

<sub>`/clear` first → fresh context window</sub>

Also: `/gsd/plan-phase {N}` — skip discussion, plan directly
```

</process>

<success_criteria>
- [ ] PROJECT.md updated with Current Milestone section → committed
- [ ] STATE.md reset for new milestone → committed
- [ ] MILESTONE-CONTEXT.md consumed and deleted (if existed)
- [ ] Research completed (if selected) — 4 researcher role-switches, milestone-aware → committed
- [ ] REQUIREMENTS.md created with REQ-IDs continuing from existing → committed
- [ ] gsd-roadmapper role-switch executed with phase numbering context
- [ ] ROADMAP.md phases continue from previous milestone
- [ ] ROADMAP.md, STATE.md, REQUIREMENTS.md committed
- [ ] User knows next step: /gsd/discuss-phase {N}
</success_criteria>
