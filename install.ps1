# GSD for Windsurf — Installer (Windows PowerShell)

$GSD_HOME = "$env:USERPROFILE\.codeium\windsurf\get-shit-done"
$WINDSURF_WORKFLOWS = "$env:USERPROFILE\.codeium\windsurf\global_workflows"
$WINDSURF_RULES = "$env:USERPROFILE\.codeium\windsurf\windsurf\rules"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "GSD for Windsurf - Installing..."
Write-Host ""

# Create target directories
New-Item -ItemType Directory -Force -Path $GSD_HOME | Out-Null
New-Item -ItemType Directory -Force -Path "$GSD_HOME\agents" | Out-Null
New-Item -ItemType Directory -Force -Path "$GSD_HOME\references" | Out-Null
New-Item -ItemType Directory -Force -Path "$GSD_HOME\templates" | Out-Null
New-Item -ItemType Directory -Force -Path $WINDSURF_WORKFLOWS | Out-Null

# Remove stale gsd/ subfolder if present from old install
if (Test-Path "$WINDSURF_WORKFLOWS\gsd") { Remove-Item "$WINDSURF_WORKFLOWS\gsd" -Recurse -Force }
New-Item -ItemType Directory -Force -Path $WINDSURF_RULES | Out-Null

# Copy agents (verbatim)
Copy-Item "$SCRIPT_DIR\src\agents\*" "$GSD_HOME\agents\" -Force
Write-Host "  agents/          -> $GSD_HOME\agents\"

# Copy references (verbatim)
Copy-Item "$SCRIPT_DIR\src\references\*" "$GSD_HOME\references\" -Force
Write-Host "  references/      -> $GSD_HOME\references\"

# Copy templates (verbatim, recursive)
Copy-Item "$SCRIPT_DIR\src\templates\*" "$GSD_HOME\templates\" -Recurse -Force
Write-Host "  templates/       -> $GSD_HOME\templates\"

# Copy workflows — prefix each file with gsd- so they appear as /gsd-* in the picker
Get-ChildItem "$SCRIPT_DIR\src\workflows\gsd\*.md" | ForEach-Object {
    Copy-Item $_.FullName "$WINDSURF_WORKFLOWS\gsd-$($_.Name)" -Force
}
Write-Host "  workflows/gsd/*.md -> $WINDSURF_WORKFLOWS\gsd-*.md"

# Copy rules
Copy-Item "$SCRIPT_DIR\src\rules\gsd-core.md" "$WINDSURF_RULES\gsd-core.md" -Force
Write-Host "  rules/gsd-core.md -> $WINDSURF_RULES\gsd-core.md"

Write-Host ""
Write-Host "GSD for Windsurf installed successfully."
Write-Host "Restart Windsurf to activate /gsd/* workflows."
