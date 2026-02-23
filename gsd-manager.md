---
trigger: always_on
---

1. strictly follow GSD framework commands, workflows, use agents and templates when working on the project

learn how to improve how you use GSD framework, by updating this file when you find new ways to improve it. ask user for approval before making any changes to this file.

2. when user runs gsd commands (only then):
    - reply with "Got it." then continue with your reply...
    - make your tasks plan strictly based on the GSD framework instructions given in the commands (.md files) and follow them strictly.

3. if by any chance you deviated from the GSD framework:
    - tell user "I need to get back on track with the GSD framework"
    - then follow the drift recovery procedure (see rule 4)

4. if user says "Get on tracks" OR "Back on tracks" OR if drift is detected:
    Drift recovery procedure:
    a. run `git log --oneline -20` — GSD micro-commits are the most reliable trail; the last docs/feat/fix commit reveals exactly where GSD-compliant work stopped
    b. from the commit messages identify the last GSD command being executed (e.g. feat(07-01), docs(phase-7)) and the point where commits stopped following GSD conventions
    c. read that command's workflow file to get the full list of required steps and artifacts
    d. audit what exists on disk: planning docs (SUMMARYs, VERIFICATION.md, STATE.md, ROADMAP.md) — cross-reference against what the workflow requires
    e. identify the gap: which required steps were skipped or done outside the GSD framework
    f. resolve only the missing parts — following the GSD workflow from the point of deviation to completion
    g. do NOT redo work that was already done correctly
    - tell user "I am getting back on track with the GSD framework" and present full detailed report on your finding (where you deviated, why, how, what was done, what was skipped, what was done outside the GSD framework) and full plan of the steps you are taking to resolve the gap.

5. after completing any GSD command:
    - read the full workflow file to confirm ALL required steps are done (not just the code tasks)
    - required artifacts vary by command — common ones: SUMMARY.md per plan, VERIFICATION.md per phase, STATE.md updated, ROADMAP.md updated, offer_next delivered
    - do NOT declare a command complete until all its required artifacts exist (are being created or updated) and the gsd directive of atomic commits is followed (each commit is a complete GSD command). 