#!/bin/bash
# GSD for Windsurf - Uninstaller (macOS/Linux)

GSD_HOME="$HOME/.codeium/windsurf/get-shit-done"
RULE_FILE="$HOME/.codeium/windsurf/windsurf/rules/gsd-core.md"

if [[ "$OSTYPE" == "darwin"* ]]; then
  WINDSURF_WORKFLOWS="/Library/Application Support/Windsurf/workflows/gsd"
else
  WINDSURF_WORKFLOWS="/etc/windsurf/workflows/gsd"
fi

echo "GSD for Windsurf - Uninstalling..."
echo ""

# Remove workflows
if [ -d "$WINDSURF_WORKFLOWS" ]; then
    rm -rf "$WINDSURF_WORKFLOWS"
    echo "  Removed: $WINDSURF_WORKFLOWS"
else
    echo "  Not found (skipping): $WINDSURF_WORKFLOWS"
fi

# Remove rule
if [ -f "$RULE_FILE" ]; then
    rm -f "$RULE_FILE"
    echo "  Removed: $RULE_FILE"
else
    echo "  Not found (skipping): $RULE_FILE"
fi

# Remove agents/references/templates
if [ -d "$GSD_HOME" ]; then
    rm -rf "$GSD_HOME"
    echo "  Removed: $GSD_HOME"
else
    echo "  Not found (skipping): $GSD_HOME"
fi

echo ""
echo "GSD for Windsurf uninstalled."
echo "Restart Windsurf to deactivate /gsd/* workflows."
echo ""
echo "Note: Your project .planning/ directories are NOT removed."
echo "Delete them manually if you no longer need them."
