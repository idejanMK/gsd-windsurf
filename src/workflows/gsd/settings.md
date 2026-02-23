---
description: Interactive configuration of GSD workflow settings and model profile. Usage: /gsd/settings
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Interactive configuration of GSD workflow agents (research, plan_check, verifier) and model profile selection. Updates .planning/config.json with user preferences. Optionally saves settings as global defaults for future projects.
</purpose>

<process>

## 1. Load Current Config

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/config.json` if exists. If missing, create with defaults from GSD_TEMPLATES/config.json.

Parse current values (default to `true` if not present):
- `workflow.research` — spawn researcher during plan-phase
- `workflow.plan_check` — spawn plan checker during plan-phase
- `workflow.verifier` — spawn verifier during execute-phase
- `workflow.nyquist_validation` — validation architecture research during plan-phase
- `workflow.auto_advance` — auto-chain stages
- `model_profile` — which model tier each agent uses (default: `balanced`)
- `git.branching_strategy` — branching approach (default: `"none"`)

## 2. Present Settings

Use ask_user_question for each setting (allowMultiple: false):

**1. Model Profile:**
- question: "Which model profile for agents?"
- options:
  - label: "Quality" — description: Best quality, highest cost
  - label: "Balanced (Recommended)" — description: Good quality/cost ratio
  - label: "Budget" — description: Fastest, lowest cost

**2. Plan Researcher:**
- question: "Spawn Plan Researcher? (researches domain before planning)"
- options:
  - label: "Yes (Recommended)" — description: Research phase goals before planning
  - label: "No" — description: Skip research, plan directly

**3. Plan Checker:**
- question: "Spawn Plan Checker? (verifies plans before execution)"
- options:
  - label: "Yes (Recommended)" — description: Verify plans meet phase goals
  - label: "No" — description: Skip plan verification

**4. Execution Verifier:**
- question: "Spawn Execution Verifier? (verifies phase completion)"
- options:
  - label: "Yes (Recommended)" — description: Verify must-haves after execution
  - label: "No" — description: Skip post-execution verification

**5. Auto-Advance:**
- question: "Auto-advance pipeline? (discuss → plan → execute automatically)"
- options:
  - label: "No (Recommended)" — description: Manual /clear between stages for clean context
  - label: "Yes" — description: Output next command automatically

**6. Nyquist Validation:**
- question: "Enable Nyquist Validation? (researches test coverage during planning)"
- options:
  - label: "Yes (Recommended)" — description: Research automated test coverage during plan-phase
  - label: "No" — description: Skip validation research (good for rapid prototyping)

**7. Git Branching:**
- question: "Git branching strategy?"
- options:
  - label: "None (Recommended)" — description: Commit directly to current branch
  - label: "Per Phase" — description: Create branch for each phase (gsd/phase-{N}-{name})
  - label: "Per Milestone" — description: Create branch for entire milestone (gsd/{version}-{name})

## 3. Update Config

[TOOL HARNESS: write_to_file]

Merge new settings into existing config.json:

```json
{
  "model_profile": "quality" | "balanced" | "budget",
  "workflow": {
    "research": true/false,
    "plan_check": true/false,
    "verifier": true/false,
    "auto_advance": true/false,
    "nyquist_validation": true/false
  },
  "git": {
    "branching_strategy": "none" | "phase" | "milestone"
  }
}
```

Write updated config to `.planning/config.json`.

## 4. Save as Defaults

Use ask_user_question:
- question: "Save these as default settings for all new projects?"
- options:
  - label: "Yes" — description: New projects start with these settings (saved to ~/.gsd/defaults.json)
  - label: "No" — description: Only apply to this project

**If "Yes":**

[TOOL HARNESS: write_to_file, run_command]

run_command: `mkdir -p "$env:USERPROFILE\.gsd"`

Write `~/.gsd/defaults.json` with current settings (minus project-specific fields).

## 5. Confirm

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► SETTINGS UPDATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Setting              | Value |
|----------------------|-------|
| Model Profile        | {quality/balanced/budget} |
| Plan Researcher      | {On/Off} |
| Plan Checker         | {On/Off} |
| Execution Verifier   | {On/Off} |
| Auto-Advance         | {On/Off} |
| Nyquist Validation   | {On/Off} |
| Git Branching        | {None/Per Phase/Per Milestone} |
| Saved as Defaults    | {Yes/No} |

These settings apply to future /gsd/plan-phase and /gsd/execute-phase runs.

Quick commands:
- /gsd/set-profile <profile> — switch model profile only
- /gsd/plan-phase --research — force research this run
- /gsd/plan-phase --skip-research — skip research this run
- /gsd/plan-phase --skip-verify — skip plan check this run
```

</process>

<success_criteria>
- [ ] Current config read (or created with defaults)
- [ ] User presented with 7 settings
- [ ] Config updated with model_profile, workflow, and git sections
- [ ] User offered to save as global defaults
- [ ] Changes confirmed to user
</success_criteria>
