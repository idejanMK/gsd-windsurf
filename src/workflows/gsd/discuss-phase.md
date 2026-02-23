---
description: Extract implementation decisions for a phase before planning. Usage: /gsd/discuss-phase [phase] [--auto]
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Extract implementation decisions that downstream agents need. Analyze the phase to identify gray areas, let the user choose what to discuss, then deep-dive each selected area until satisfied.

You are a thinking partner, not an interviewer. The user is the visionary — you are the builder. Capture decisions that will guide research and planning.
</purpose>

<downstream_awareness>
CONTEXT.md feeds into:
1. **gsd-phase-researcher** — reads CONTEXT.md to know WHAT to research
2. **gsd-planner** — reads CONTEXT.md to know WHAT decisions are locked

Your job: Capture decisions clearly enough that downstream agents can act without asking the user again.
Not your job: Figure out HOW to implement. That's what research and planning do.
</downstream_awareness>

<scope_guardrail>
**CRITICAL: No scope creep.**

The phase boundary comes from ROADMAP.md and is FIXED. Discussion clarifies HOW to implement what's scoped, never WHETHER to add new capabilities.

When user suggests scope creep:
```
"[Feature X] would be a new capability — that's its own phase.
Want me to note it for the roadmap backlog?

For now, let's focus on [phase domain]."
```

Capture the idea in a "Deferred Ideas" section. Don't lose it, don't act on it.
</scope_guardrail>

<process>

## 1. Initialize

[TOOL HARNESS: read_file, find_by_name]

Phase number from argument (required).

Read:
- `.planning/ROADMAP.md` — find phase section, extract phase_name, goal, phase_slug, padded_phase
- `.planning/STATE.md`
- `.planning/config.json` → extract commit_docs, auto_advance

**If phase not found in ROADMAP.md:**
```
Phase [X] not found in roadmap.

Use /gsd/progress to see available phases.
```
Exit workflow.

Find phase directory: `.planning/phases/{padded_phase}-{phase_slug}` (may not exist yet).

Check:
- `has_context` = `{padded_phase}-CONTEXT.md` exists in phase_dir
- `has_plans` = any `*-PLAN.md` exists in phase_dir
- `plan_count` = count of PLAN.md files

## 2. Check Existing

**If CONTEXT.md exists:**

Use ask_user_question:
- question: "Phase {X} already has context. What do you want to do?"
- options:
  - label: "Update it" — description: Review and revise existing context
  - label: "View it" — description: Show me what's there
  - label: "Skip" — description: Use existing context as-is

If "Update": read existing CONTEXT.md, continue to analyze_phase.
If "View": display CONTEXT.md content, then use ask_user_question: "Update or skip?"
If "Skip": exit workflow.

**If CONTEXT.md does not exist AND has_plans is true:**

Use ask_user_question:
- question: "Phase {X} already has {plan_count} plan(s) created without user context. Your decisions here won't affect existing plans unless you replan."
- options:
  - label: "Continue and replan after" — description: Capture context, then run /gsd/plan-phase {X} to replan
  - label: "View existing plans" — description: Show plans before deciding
  - label: "Cancel" — description: Skip discuss-phase

If "Continue and replan after": continue to analyze_phase.
If "View existing plans": display plan files, then offer "Continue" / "Cancel".
If "Cancel": exit workflow.

**If CONTEXT.md does not exist AND has_plans is false:** Continue to analyze_phase.

## 3. Analyze Phase

[TOOL HARNESS: read_file]

Analyze the phase to identify gray areas worth discussing.

From ROADMAP.md phase section, determine:

1. **Domain boundary** — What capability is this phase delivering?
2. **Gray areas** — Implementation decisions the user cares about that could go multiple ways:
   - Something users SEE → visual presentation, interactions, states
   - Something users CALL → interface contracts, responses, errors
   - Something users RUN → invocation, output, behavior modes
   - Something users READ → structure, tone, depth, flow
   - Something being ORGANIZED → criteria, grouping, handling exceptions

Generate phase-specific gray areas (not generic categories):
```
Phase: "User authentication"
→ Session handling, Error responses, Multi-device policy, Recovery flow

Phase: "CLI for database backups"
→ Output format, Flag design, Progress reporting, Error recovery
```

**Claude handles these (don't ask):** Technical implementation, architecture patterns, performance optimization, scope.

## 4. Present Gray Areas

Display domain boundary:
```
Phase {X}: {Name}
Domain: {What this phase delivers}

We'll clarify HOW to implement this.
(New capabilities belong in other phases.)
```

Use ask_user_question (allowMultiple: true):
- question: "Which areas do you want to discuss for {phase_name}?"
- options: Generate 3-4 phase-specific gray areas, each with concrete label and 1-2 questions as description. Highlight recommended choice.

Do NOT include "skip" or "you decide" as an option here.

## 5. Discuss Areas

For each selected area, conduct a focused discussion loop.

**Philosophy: 4 questions, then check.**

For each area:

1. Announce: `Let's talk about [Area].`

2. Ask 4 questions using ask_user_question:
   - question: Specific decision for this area
   - options: 2-3 concrete choices (not abstract), with recommended choice highlighted
   - Include "You decide" as an option when reasonable

3. After 4 questions, check:
   Use ask_user_question:
   - question: "More questions about {area}, or move to next?"
   - options:
     - label: "More questions" — description: Keep exploring this area
     - label: "Next area" — description: Move on

   If "More questions" → ask 4 more, then check again.
   If "Next area" → proceed to next selected area.

4. After all initially-selected areas complete:

   Summarize what was captured. Use ask_user_question:
   - question: "We've discussed {list areas}. Which gray areas remain unclear?"
   - options:
     - label: "Explore more gray areas" — description: Identify additional areas to discuss
     - label: "I'm ready for context" — description: Capture decisions and move on

   If "Explore more gray areas": identify 2-4 additional gray areas, return to step 4.
   If "I'm ready for context": proceed to write_context.

**Scope creep handling:** If user mentions something outside phase domain, note it as deferred idea and redirect.

## 6. Write Context

[TOOL HARNESS: write_to_file, run_command]

Find or create phase directory:

If phase_dir doesn't exist: run_command: `mkdir -p ".planning/phases/{padded_phase}-{phase_slug}"`

Write `{phase_dir}/{padded_phase}-CONTEXT.md`:

```markdown
# Phase {X}: {Name} - Context

**Gathered:** {date}
**Status:** Ready for planning

<domain>
## Phase Boundary

{Clear statement of what this phase delivers — the scope anchor}

</domain>

<decisions>
## Implementation Decisions

### {Category 1 discussed}
- {Decision captured}
- {Another decision if applicable}

### {Category 2 discussed}
- {Decision captured}

### Claude's Discretion
{Areas where user said "you decide" — note Claude has flexibility here}

</decisions>

<specifics>
## Specific Ideas

{Any particular references, examples, or "I want it like X" moments}

{If none: "No specific requirements — open to standard approaches"}

</specifics>

<deferred>
## Deferred Ideas

{Ideas that came up but belong in other phases}

{If none: "None — discussion stayed within phase scope"}

</deferred>

---

*Phase: {padded_phase}-{phase_slug}*
*Context gathered: {date}*
```

## 7. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add "{phase_dir}/{padded_phase}-CONTEXT.md"`
run_command: `git commit -m "docs({padded_phase}): capture phase context"`

Update STATE.md: set `last_session.stopped_at` = "Phase {X} context gathered", `last_session.resume_file` = path to CONTEXT.md.

If commit_docs=true:
run_command: `git add .planning/STATE.md`
run_command: `git commit -m "docs(state): record phase {X} context session"`

## 8. Auto-Advance Check

[TOOL HARNESS: read_file]

Check `--auto` flag in arguments and `workflow.auto_advance` from config.json.

**If `--auto` OR `auto_advance=true`:**

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► AUTO-ADVANCING TO PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context captured. Launching plan-phase...
```

Output: "Run `/gsd/plan-phase {X} --auto` next — `/clear` first for fresh context window."

<!-- [POSSIBLE IMPROVEMENT PI-1]: Windsurf may support workflow chaining in future. -->

**If not auto-advance:** Show confirm_creation block.

## 9. Confirm Creation

```
Created: {phase_dir}/{padded_phase}-CONTEXT.md

## Decisions Captured

### {Category}
- {Key decision}

{If deferred ideas:}
## Noted for Later
- {Deferred idea} — future phase

---

## ▶ Next Up

**Phase {X}: {Name}** — {Goal from ROADMAP.md}

`/gsd/plan-phase {X}`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `/gsd/plan-phase {X} --skip-research` — plan without research
- Review/edit CONTEXT.md before continuing

---
```

</process>

<success_criteria>
- [ ] Phase validated against ROADMAP.md
- [ ] Gray areas identified through intelligent analysis (not generic questions)
- [ ] User selected which areas to discuss
- [ ] Each selected area explored until user satisfied
- [ ] Scope creep redirected to deferred ideas
- [ ] CONTEXT.md captures actual decisions, not vague vision
- [ ] Deferred ideas preserved for future phases
- [ ] STATE.md updated with session info
- [ ] User knows next steps
</success_criteria>
