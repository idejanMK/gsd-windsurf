---
description: Orchestrate parallel debug role-switches to investigate UAT gaps and find root causes. Usually invoked by verify-work.
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Orchestrate parallel debug role-switches to investigate UAT gaps and find root causes.

After UAT finds gaps, spawn one debug role-switch per gap. Each investigates autonomously with symptoms pre-filled from UAT. Collect root causes, update UAT.md gaps with diagnosis, then hand off to plan-phase --gaps with actual diagnoses.

Orchestrator stays lean: parse gaps, spawn agents, collect results, update UAT.
</purpose>

<core_principle>
**Diagnose before planning fixes.**

UAT tells us WHAT is broken (symptoms). Debug role-switches find WHY (root cause). plan-phase --gaps then creates targeted fixes based on actual causes, not guesses.

Without diagnosis: "Comment doesn't refresh" → guess at fix → maybe wrong
With diagnosis: "Comment doesn't refresh" → "useEffect missing dependency" → precise fix
</core_principle>

<process>

## 1. Parse Gaps

[TOOL HARNESS: read_file]

Read the UAT.md file passed from verify-work.

Extract gaps from the "Gaps" section (YAML format):
```yaml
- truth: "Comment appears immediately after submission"
  status: failed
  reason: "User reported: works but doesn't show until I refresh the page"
  severity: major
  test: 2
  artifacts: []
  missing: []
```

For each gap, also read the corresponding test from "Tests" section for full context.

Build gap list with: truth, severity, test_num, reason.

## 2. Report Diagnosis Plan

Display:
```
## Diagnosing {N} Gaps

Investigating root causes for each gap:

| Gap (Truth) | Severity |
|-------------|----------|
| {truth 1} | {severity} |
| {truth 2} | {severity} |

Each investigation will:
1. Create DEBUG-{slug}.md with symptoms pre-filled
2. Investigate (read code, form hypotheses, test)
3. Return root cause
```

## 3. Investigate Each Gap

[TOOL HARNESS: read_file, grep_search, find_by_name]

For each gap (sequentially — Windsurf is single context):

Display: `◆ Investigating: {truth_short}...`

Generate slug from truth: lowercase, spaces → hyphens.
debug_path = `.planning/debug/{slug}.md`

→ ROLE SWITCH: Read GSD_AGENTS/gsd-debugger.md (if exists) or act as systematic debugger.
  Act as a systematic debug investigator.
  Read:
  - Current phase UAT.md for full test context
  - `.planning/STATE.md`
  Symptoms pre-filled:
  - Truth expected: {truth}
  - Actual behavior: {reason from UAT}
  - Severity: {severity}
  - Test: {test_num} in UAT
  Goal: find_root_cause_only (plan-phase --gaps handles fixes)
  
  Investigation process:
  1. Read relevant source files based on the truth being tested
  2. Form hypothesis about root cause
  3. Verify hypothesis with grep/file reads
  4. Identify specific files and lines involved
  
  Write debug session to: {debug_path}
  Return:
  ```
  ## ROOT CAUSE FOUND
  
  **Root Cause:** {specific cause with evidence}
  
  **Evidence Summary:**
  - {key finding 1}
  - {key finding 2}
  
  **Files Involved:**
  - {file1}: {what's wrong}
  
  **Suggested Fix Direction:** {brief hint for plan-phase --gaps}
  ```
  
  OR if inconclusive:
  ```
  ## INVESTIGATION INCONCLUSIVE
  
  **Remaining possibilities:**
  - {possibility 1}
  - {possibility 2}
  ```
→ END ROLE

Parse return to extract: root_cause, files, debug_path, suggested_fix.

If inconclusive: root_cause = "Investigation inconclusive - manual review needed"

## 4. Update UAT.md

[TOOL HARNESS: read_file, write_to_file, run_command]

For each gap in the Gaps section, add diagnosis fields:

```yaml
- truth: "Comment appears immediately after submission"
  status: failed
  reason: "User reported: works but doesn't show until I refresh the page"
  severity: major
  test: 2
  root_cause: "useEffect in CommentList.tsx missing commentCount dependency"
  artifacts:
    - path: "src/components/CommentList.tsx"
      issue: "useEffect missing dependency"
  missing:
    - "Add commentCount to useEffect dependency array"
    - "Trigger re-render when new comment added"
  debug_session: .planning/debug/{slug}.md
```

Update status in frontmatter to "diagnosed".

Read `.planning/config.json` → check commit_docs.

If commit_docs=true:
run_command: `git add "{phase_dir}/{phase_num}-UAT.md"`
run_command: `git commit -m "docs({phase_num}): add root causes from diagnosis"`

## 5. Report Results

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► DIAGNOSIS COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Gap (Truth) | Root Cause | Files |
|-------------|------------|-------|
{For each gap: | {truth_short} | {root_cause_short} | {files} |}

Debug sessions: .planning/debug/
```

Return to verify-work orchestrator for automatic planning.
Do NOT offer manual next steps — verify-work handles the rest.

</process>

<failure_handling>
**Investigation fails to find root cause:**
- Mark gap as "needs manual review"
- Continue with other gaps
- Report incomplete diagnosis

**All investigations fail:**
- Something systemic (permissions, git, etc.)
- Report for manual investigation
- Fall back to plan-phase --gaps without root causes (less precise)
</failure_handling>

<success_criteria>
- [ ] Gaps parsed from UAT.md
- [ ] Each gap investigated via role-switch
- [ ] Root causes collected from all investigations
- [ ] UAT.md gaps updated with artifacts and missing
- [ ] Debug sessions saved to .planning/debug/
- [ ] Hand off to verify-work for automatic planning
</success_criteria>
