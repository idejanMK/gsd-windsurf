---
description: Check for GSD updates, display changelog, and install if confirmed. Usage: /gsd/update
---

<!-- GSD_HOME = ~/.codeium/windsurf/get-shit-done -->

<purpose>
Check for GSD updates, display changelog for versions between installed and latest, obtain user confirmation, and execute clean installation.
</purpose>

<process>

## 1. Get Installed Version

[TOOL HARNESS: read_file, run_command]

Check for VERSION file:
- `~/.codeium/windsurf/get-shit-done/VERSION`

If VERSION file exists: read installed version.

If VERSION file missing:
```
## GSD Update

**Installed version:** Unknown

Your installation doesn't include version tracking.

Running fresh install...
```
Proceed to install step (treat as version 0.0.0).

## 2. Check Latest Version

[TOOL HARNESS: run_command]

run_command: `npm view get-shit-done-cc version 2>$null`

If npm check fails:
```
Couldn't check for updates (offline or npm unavailable).

To update manually: run the GSD installer script (install.ps1 or install.sh)
```
Exit.

## 3. Compare Versions

**If installed == latest:**
```
## GSD Update

**Installed:** X.Y.Z
**Latest:** X.Y.Z

You're already on the latest version.
```
Exit.

**If installed > latest:**
```
## GSD Update

**Installed:** X.Y.Z
**Latest:** A.B.C

You're ahead of the latest release (development version?).
```
Exit.

## 4. Show Changes and Confirm

[TOOL HARNESS: read_url_content]

Fetch changelog from GitHub:
`https://raw.githubusercontent.com/glittercowboy/get-shit-done/main/CHANGELOG.md`

Extract entries between installed and latest versions.

Display:
```
## GSD Update Available

**Installed:** {installed}
**Latest:** {latest}

### What's New
────────────────────────────────────────────────────────────

{changelog entries between versions}

────────────────────────────────────────────────────────────

⚠️  **Note:** The installer performs a clean install of GSD folders:
- `windsurf/workflows/gsd/` will be wiped and replaced
- `get-shit-done/` will be wiped and replaced

Your custom files in other locations are preserved:
- Custom workflows not in `workflows/gsd/` ✓
- Custom rules not named `gsd-core.md` ✓
- Your project `.planning/` files ✓
```

Use ask_user_question:
- question: "Proceed with update?"
- options:
  - label: "Yes, update now" — description: Run installer to update GSD
  - label: "No, cancel" — description: Keep current version

If "Cancel": exit.

## 5. Run Update

[TOOL HARNESS: run_command]

Detect OS and run appropriate installer:

**Windows (PowerShell):**
run_command: `npx get-shit-done-cc --global`

**macOS/Linux:**
run_command: `npx get-shit-done-cc --global`

If install fails: show error and exit.

## 6. Display Result

```
╔═══════════════════════════════════════════════════════════╗
║  GSD Updated: v{installed} → v{latest}                    ║
╚═══════════════════════════════════════════════════════════╝

⚠️  Restart Windsurf to pick up the new workflows.

[View full changelog](https://github.com/glittercowboy/get-shit-done/blob/main/CHANGELOG.md)
```

</process>

<success_criteria>
- [ ] Installed version read correctly
- [ ] Latest version checked via npm
- [ ] Update skipped if already current
- [ ] Changelog fetched and displayed BEFORE update
- [ ] Clean install warning shown
- [ ] User confirmation obtained
- [ ] Update executed successfully
- [ ] Restart reminder shown
</success_criteria>
