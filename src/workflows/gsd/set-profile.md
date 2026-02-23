---
description: Switch the model profile used by GSD agents. Usage: /gsd/set-profile <quality|balanced|budget>
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Switch the model profile used by GSD agents. Controls which model tier each agent uses, balancing quality vs token spend.
</purpose>

<process>

## 1. Validate Argument

Profile argument must be one of: `quality`, `balanced`, `budget`.

If invalid or missing:
```
Error: Invalid profile "{argument}"
Valid profiles: quality, balanced, budget

Usage: /gsd/set-profile <profile>
Example: /gsd/set-profile balanced
```
Exit.

## 2. Load Config

[TOOL HARNESS: read_file, write_to_file]

Read `.planning/config.json`. If missing: create with defaults.

## 3. Update Config

Update `model_profile` field in config.json:

```json
{
  "model_profile": "{quality|balanced|budget}"
}
```

Write updated config back to `.planning/config.json`.

## 4. Confirm

Display confirmation with model tier table for selected profile:

```
✓ Model profile set to: {profile}

Agents will now use:

| Agent | Tier |
|-------|------|
| gsd-planner | {tier for profile} |
| gsd-executor | {tier for profile} |
| gsd-verifier | {tier for profile} |
| gsd-phase-researcher | {tier for profile} |
| gsd-plan-checker | {tier for profile} |
| gsd-roadmapper | {tier for profile} |

Profile tiers:
- quality: Best quality, highest cost — use for critical planning
- balanced: Good quality/cost ratio — recommended for most work
- budget: Fastest, lowest cost — use for rapid iteration

Next spawned agents will use the new profile.
```

Profile → tier mapping:
- `quality`: All agents use highest capability
- `balanced`: Planning agents use higher capability, execution/verification use standard
- `budget`: All agents use standard/fast capability

</process>

<success_criteria>
- [ ] Argument validated (quality/balanced/budget)
- [ ] Config file read or created
- [ ] Config updated with new model_profile
- [ ] Confirmation displayed with tier table
</success_criteria>
