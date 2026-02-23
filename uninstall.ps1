# GSD for Windsurf - Uninstaller (Windows PowerShell)

$GSD_HOME = "$env:USERPROFILE\.codeium\windsurf\get-shit-done"
$WINDSURF_WORKFLOWS = "C:\ProgramData\Windsurf\workflows\gsd"
$WINDSURF_RULES = "$env:USERPROFILE\.codeium\windsurf\windsurf\rules"

Write-Host "GSD for Windsurf - Uninstalling..."
Write-Host ""

# Remove workflows
if (Test-Path $WINDSURF_WORKFLOWS) {
    Remove-Item $WINDSURF_WORKFLOWS -Recurse -Force
    Write-Host "  Removed: $WINDSURF_WORKFLOWS"
} else {
    Write-Host "  Not found (skipping): $WINDSURF_WORKFLOWS"
}

# Remove rule
$RULE_FILE = "$WINDSURF_RULES\gsd-core.md"
if (Test-Path $RULE_FILE) {
    Remove-Item $RULE_FILE -Force
    Write-Host "  Removed: $RULE_FILE"
} else {
    Write-Host "  Not found (skipping): $RULE_FILE"
}

# Remove agents/references/templates
if (Test-Path $GSD_HOME) {
    Remove-Item $GSD_HOME -Recurse -Force
    Write-Host "  Removed: $GSD_HOME"
} else {
    Write-Host "  Not found (skipping): $GSD_HOME"
}

Write-Host ""
Write-Host "GSD for Windsurf uninstalled."
Write-Host "Restart Windsurf to deactivate /gsd/* workflows."
Write-Host ""
Write-Host "Note: Your project .planning/ directories are NOT removed."
Write-Host "Delete them manually if you no longer need them."
