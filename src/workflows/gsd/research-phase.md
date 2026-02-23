---
description: Research how to implement a phase. Standalone research command. Usage: /gsd/research-phase [phase]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Research how to implement a phase. Spawns gsd-phase-researcher with phase context.

Standalone research command. For most workflows, use /gsd/plan-phase which integrates research automatically.
</purpose>

<process>

## 1. Resolve Model Profile

[TOOL HARNESS: read_file]

Read `.planning/config.json` → extract `model_profile`, `commit_docs`.

## 2. Normalize and Validate Phase

[TOOL HARNESS: read_file]

Read `.planning/ROADMAP.md`. Find section matching phase argument.

Normalize phase number: `1` → `01`, `2.1` → `02.1`.

**If phase not found:** Error — list available phases from ROADMAP.md. Exit.

Extract: `phase_name`, `goal`, `phase_slug`, `padded_phase`.
Derive: `phase_dir` = `.planning/phases/{padded_phase}-{phase_slug}`

## 3. Check Existing Research

[TOOL HARNESS: find_by_name]

Check for `{phase_dir}/{padded_phase}-RESEARCH.md`.

**If exists:** Use ask_user_question:
- question: "Research already exists for Phase {X}. What would you like to do?"
- options:
  - label: "Update research" — description: Re-run researcher to refresh findings
  - label: "View existing" — description: Show current RESEARCH.md
  - label: "Skip" — description: Use existing research as-is

If "View": read and display RESEARCH.md, then re-ask.
If "Skip": exit workflow.

## 4. Gather Phase Context

[TOOL HARNESS: read_file, find_by_name, run_command]

Read:
- `.planning/STATE.md`
- `.planning/REQUIREMENTS.md` (if exists)
- `{phase_dir}/{padded_phase}-CONTEXT.md` (if exists)

If phase_dir doesn't exist: run_command: `mkdir -p "{phase_dir}"`

## 5. Spawn Researcher

[TOOL HARNESS: read_file, write_to_file, run_command, mcp0_query-docs, search_web]

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► RESEARCHING PHASE {X}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning researcher...
```

→ ROLE SWITCH: Read GSD_AGENTS/gsd-phase-researcher.md
  Act as gsd-phase-researcher.
  Read (all that exist):
  - `{phase_dir}/{padded_phase}-CONTEXT.md` (USER DECISIONS)
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  - `./CLAUDE.md` (if exists)
  Research objective: "What do I need to know to PLAN Phase {phase_number}: {phase_name} well?"
  Phase description: {goal from ROADMAP.md}
  Use mcp0_resolve-library-id + mcp0_query-docs and search_web for current information.
  Write to: `{phase_dir}/{padded_phase}-RESEARCH.md`
  Return: `## RESEARCH COMPLETE {summary}`, `## CHECKPOINT REACHED`, or `## RESEARCH INCONCLUSIVE`
→ END ROLE

## 6. Handle Return

- **`## RESEARCH COMPLETE`:**

  If commit_docs=true:
  run_command: `git add "{phase_dir}/{padded_phase}-RESEARCH.md"`
  run_command: `git commit -m "docs({padded_phase}): add phase research"`

  Display summary from researcher. Use ask_user_question:
  - question: "Research complete. What would you like to do next?"
  - options:
    - label: "Plan phase" — description: Run /gsd/plan-phase {X}
    - label: "Dig deeper" — description: Re-run researcher with additional focus
    - label: "Review research" — description: Show full RESEARCH.md
    - label: "Done" — description: Exit, I'll plan manually

- **`## CHECKPOINT REACHED`:** Present checkpoint to user, get response, re-enter researcher role with continuation context.

- **`## RESEARCH INCONCLUSIVE`:** Display attempts. Use ask_user_question:
  - question: "Research was inconclusive. How would you like to proceed?"
  - options:
    - label: "Add context and retry" — description: Provide missing info
    - label: "Try different focus" — description: Specify a different research angle
    - label: "Plan without research" — description: Run /gsd/plan-phase {X} --skip-research

</process>

<success_criteria>
- [ ] Phase validated against ROADMAP.md
- [ ] Phase directory created if needed
- [ ] gsd-phase-researcher role-switch executed with CONTEXT.md (if exists)
- [ ] RESEARCH.md written to phase directory
- [ ] Research committed (if commit_docs=true)
- [ ] User knows next steps
</success_criteria>
