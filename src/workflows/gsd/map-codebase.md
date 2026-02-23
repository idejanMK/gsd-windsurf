---
description: Analyze codebase and produce structured documents in .planning/codebase/. Usage: /gsd/map-codebase
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Orchestrate codebase mapper agents to analyze codebase and produce structured documents in .planning/codebase/. Each agent explores a specific focus area and writes documents directly.

Output: .planning/codebase/ with 7 structured documents.
</purpose>

<philosophy>
Document quality over length. Include enough detail to be useful as reference. Always include actual file paths formatted with backticks. Agents run sequentially in Windsurf (no true parallelism).
</philosophy>

<process>

## 1. Init Context

[TOOL HARNESS: read_file, find_by_name]

Read `.planning/config.json` → extract `commit_docs`, `model_profile`.

Check if `.planning/codebase/` exists and what files it contains.

## 2. Check Existing

**If `.planning/codebase/` exists with files:**

Display:
```
.planning/codebase/ already exists with these documents:
[List files found]

What's next?
```

Use ask_user_question:
- question: "Codebase map already exists. What would you like to do?"
- options:
  - label: "Refresh" — description: Delete existing and remap entire codebase
  - label: "Update specific docs" — description: Keep existing, only update selected documents
  - label: "Skip" — description: Use existing codebase map as-is

If "Refresh": run_command: `Remove-Item -Recurse -Force .planning/codebase` → continue to create_structure.
If "Update": use ask_user_question (allowMultiple: true) to select which documents to update → continue to spawn_agents (filtered).
If "Skip": exit workflow.

**If doesn't exist:** Continue to create_structure.

## 3. Create Structure

[TOOL HARNESS: run_command]

run_command: `mkdir -p .planning/codebase`

Expected output files: STACK.md, INTEGRATIONS.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md

## 4. Spawn Agents (Sequential)

[TOOL HARNESS: read_file, write_to_file, run_command, grep_search, find_by_name]

Display:
```
◆ Running 4 codebase mappers sequentially...
  → Tech focus (STACK.md, INTEGRATIONS.md)
  → Architecture focus (ARCHITECTURE.md, STRUCTURE.md)
  → Quality focus (CONVENTIONS.md, TESTING.md)
  → Concerns focus (CONCERNS.md)
```

Note: Windsurf executes sequentially — each mapper role-switch is independent.

**Agent 1: Tech Focus**

→ ROLE SWITCH: Read GSD_AGENTS/gsd-codebase-mapper.md
  Act as gsd-codebase-mapper with focus: tech.
  Analyze this codebase for technology stack and external integrations.
  Use GSD_TEMPLATES/codebase/stack.md and GSD_TEMPLATES/codebase/integrations.md as structure.
  Write:
  - `.planning/codebase/STACK.md` — Languages, runtime, frameworks, dependencies, configuration
  - `.planning/codebase/INTEGRATIONS.md` — External APIs, databases, auth providers, webhooks
  Explore thoroughly. Include actual file paths with backticks.
  Return: `## Mapping Complete` with file paths and line counts.
→ END ROLE

Display: `✓ Tech mapping complete: STACK.md, INTEGRATIONS.md`

**Agent 2: Architecture Focus**

→ ROLE SWITCH: Read GSD_AGENTS/gsd-codebase-mapper.md
  Act as gsd-codebase-mapper with focus: arch.
  Analyze this codebase architecture and directory structure.
  Use GSD_TEMPLATES/codebase/architecture.md and GSD_TEMPLATES/codebase/structure.md as structure.
  Write:
  - `.planning/codebase/ARCHITECTURE.md` — Pattern, layers, data flow, abstractions, entry points
  - `.planning/codebase/STRUCTURE.md` — Directory layout, key locations, naming conventions
  Explore thoroughly. Include actual file paths with backticks.
  Return: `## Mapping Complete` with file paths and line counts.
→ END ROLE

Display: `✓ Architecture mapping complete: ARCHITECTURE.md, STRUCTURE.md`

**Agent 3: Quality Focus**

→ ROLE SWITCH: Read GSD_AGENTS/gsd-codebase-mapper.md
  Act as gsd-codebase-mapper with focus: quality.
  Analyze this codebase for coding conventions and testing patterns.
  Use GSD_TEMPLATES/codebase/conventions.md and GSD_TEMPLATES/codebase/testing.md as structure.
  Write:
  - `.planning/codebase/CONVENTIONS.md` — Code style, naming, patterns, error handling
  - `.planning/codebase/TESTING.md` — Framework, structure, mocking, coverage
  Explore thoroughly. Include actual file paths with backticks.
  Return: `## Mapping Complete` with file paths and line counts.
→ END ROLE

Display: `✓ Quality mapping complete: CONVENTIONS.md, TESTING.md`

**Agent 4: Concerns Focus**

→ ROLE SWITCH: Read GSD_AGENTS/gsd-codebase-mapper.md
  Act as gsd-codebase-mapper with focus: concerns.
  Analyze this codebase for technical debt, known issues, and areas of concern.
  Use GSD_TEMPLATES/codebase/concerns.md as structure.
  Write:
  - `.planning/codebase/CONCERNS.md` — Tech debt, bugs, security, performance, fragile areas
  Explore thoroughly. Include actual file paths with backticks.
  Return: `## Mapping Complete` with file paths and line counts.
→ END ROLE

Display: `✓ Concerns mapping complete: CONCERNS.md`

## 5. Verify Output

[TOOL HARNESS: find_by_name, run_command]

Verify all documents created successfully:
run_command: `Get-ChildItem .planning/codebase/ | Select-Object Name, Length`

Check: all 7 documents exist and are non-empty (>20 lines each).

If any missing or empty: note which agent may have failed.

## 6. Scan for Secrets

[TOOL HARNESS: grep_search]

**CRITICAL SECURITY CHECK:** Scan output files for accidentally leaked secrets.

Use grep_search on `.planning/codebase/` for patterns:
- `sk-[a-zA-Z0-9]{20,}` (OpenAI keys)
- `ghp_[a-zA-Z0-9]{36}` (GitHub tokens)
- `AKIA[A-Z0-9]{16}` (AWS keys)
- `-----BEGIN.*PRIVATE KEY` (private keys)
- `eyJ[a-zA-Z0-9_-]+\.eyJ` (JWTs with payload)

**If secrets found:**
```
⚠️  SECURITY ALERT: Potential secrets detected in codebase documents!

Found patterns that look like API keys or tokens.

Action required:
1. Review the flagged content
2. Remove real secrets before committing
3. Consider adding sensitive files to Windsurf ignore list

Pausing before commit. Reply "safe to proceed" if flagged content is not sensitive.
```

Wait for user confirmation before committing.

**If no secrets found:** Continue to commit.

## 7. Commit

[TOOL HARNESS: run_command]

If commit_docs=true:
run_command: `git add .planning/codebase/`
run_command: `git commit -m "docs: map existing codebase"`

## 8. Offer Next

Display:
```
Codebase mapping complete.

Created .planning/codebase/:
- STACK.md — Technologies and dependencies
- ARCHITECTURE.md — System design and patterns
- STRUCTURE.md — Directory layout and organization
- CONVENTIONS.md — Code style and patterns
- TESTING.md — Test structure and practices
- INTEGRATIONS.md — External services and APIs
- CONCERNS.md — Technical debt and issues

---

## ▶ Next Up

**Initialize project** — use codebase context for planning

`/gsd/new-project`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- Re-run mapping: `/gsd/map-codebase`
- Review specific file: `cat .planning/codebase/STACK.md`

---
```

</process>

<success_criteria>
- [ ] .planning/codebase/ directory created
- [ ] 4 gsd-codebase-mapper role-switches executed (tech, arch, quality, concerns)
- [ ] All 7 codebase documents exist and are non-empty
- [ ] Secret scan completed before commit
- [ ] Committed (if commit_docs=true)
- [ ] Clear completion summary with file list
- [ ] User offered clear next steps
</success_criteria>
