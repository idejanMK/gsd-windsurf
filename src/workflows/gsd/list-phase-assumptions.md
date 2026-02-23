---
description: Surface Claude's assumptions about a phase before planning to enable early corrections. Usage: /gsd/list-phase-assumptions <phase>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Surface Cascade's assumptions about a phase before planning, enabling users to correct misconceptions early.

Key difference from discuss-phase: This is ANALYSIS of what Cascade thinks, not INTAKE of what user knows. No file output — purely conversational to prompt discussion.
</purpose>

<process>

## 1. Validate Phase

[TOOL HARNESS: read_file]

Phase number from argument (required).

If argument missing:
```
Error: Phase number required.

Usage: /gsd/list-phase-assumptions [phase-number]
Example: /gsd/list-phase-assumptions 3
```
Exit.

Read `.planning/ROADMAP.md`. Find section matching phase number.

If phase not found:
```
Error: Phase {N} not found in roadmap.

Available phases:
{list phases from ROADMAP.md}
```
Exit.

Extract: phase number, phase name, phase description/goal, scope details.

## 2. Analyze Phase

[TOOL HARNESS: read_file]

Also read:
- `.planning/PROJECT.md` (if exists)
- `.planning/REQUIREMENTS.md` (if exists)
- `.planning/STATE.md` (if exists)
- `.planning/codebase/STACK.md` (if exists)

Based on roadmap description and project context, identify assumptions across five areas:

**1. Technical Approach:**
What libraries, frameworks, patterns, or tools would Cascade use?
- "I'd use X library because..."
- "I'd follow Y pattern because..."
- "I'd structure this as Z because..."

**2. Implementation Order:**
What would Cascade build first, second, third?
- "I'd start with X because it's foundational"
- "Then Y because it depends on X"
- "Finally Z because..."

**3. Scope Boundaries:**
What's included vs excluded in Cascade's interpretation?
- "This phase includes: A, B, C"
- "This phase does NOT include: D, E, F"
- "Boundary ambiguities: G could go either way"

**4. Risk Areas:**
Where does Cascade expect complexity or challenges?
- "The tricky part is X because..."
- "Potential issues: Y, Z"
- "I'd watch out for..."

**5. Dependencies:**
What does Cascade assume exists or needs to be in place?
- "This assumes X from previous phases"
- "External dependencies: Y, Z"
- "This will be consumed by..."

Mark assumptions with confidence levels:
- "Fairly confident: ..." (clear from roadmap)
- "Assuming: ..." (reasonable inference)
- "Unclear: ..." (could go multiple ways)

## 3. Present Assumptions

Display:
```
## My Assumptions for Phase {N}: {Phase Name}

### Technical Approach
{List assumptions about how to implement}

### Implementation Order
{List assumptions about sequencing}

### Scope Boundaries
**In scope:** {what's included}
**Out of scope:** {what's excluded}
**Ambiguous:** {what could go either way}

### Risk Areas
{List anticipated challenges}

### Dependencies
**From prior phases:** {what's needed}
**External:** {third-party needs}
**Feeds into:** {what future phases need from this}

---

**What do you think?**

Are these assumptions accurate? Let me know:
- What I got right
- What I got wrong
- What I'm missing
```

Wait for user response (freeform).

## 4. Gather Feedback

**If user provides corrections:**

Acknowledge corrections:
```
Key corrections:
- {correction 1}
- {correction 2}

This changes my understanding significantly. {Summarize new understanding}
```

**If user confirms assumptions:**
```
Assumptions validated.
```

Continue to offer_next.

## 5. Offer Next

Display:
```
What's next?
1. Discuss context (/gsd/discuss-phase {N}) — Let me ask you questions to build comprehensive context
2. Plan this phase (/gsd/plan-phase {N}) — Create detailed execution plans
3. Re-examine assumptions — I'll analyze again with your corrections
4. Done for now
```

Wait for user selection (freeform).

If "Discuss context": Note that CONTEXT.md will incorporate any corrections discussed here.
If "Plan this phase": Proceed knowing assumptions are understood.
If "Re-examine": Return to step 2 with updated understanding.

</process>

<success_criteria>
- [ ] Phase number validated against ROADMAP.md
- [ ] Assumptions surfaced across five areas: technical approach, implementation order, scope, risks, dependencies
- [ ] Confidence levels marked where appropriate
- [ ] "What do you think?" prompt presented
- [ ] User feedback acknowledged
- [ ] Clear next steps offered
</success_criteria>
