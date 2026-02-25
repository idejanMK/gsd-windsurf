#!/bin/bash
# GSD for Windsurf - Uninstaller (macOS/Linux)

GSD_HOME="$HOME/.codeium/windsurf/get-shit-done"
RULE_FILE="$HOME/.codeium/windsurf/windsurf/rules/gsd-core.md"

WINDSURF_WORKFLOWS="$HOME/.codeium/windsurf/global_workflows"

echo "GSD for Windsurf - Uninstalling..."
echo ""

# Remove workflows (gsd-*.md files + legacy gsd/ subfolder)
removed=0
for f in "$WINDSURF_WORKFLOWS"/gsd-*.md; do
    [ -f "$f" ] && rm -f "$f" && removed=$((removed+1))
done
[ -d "$WINDSURF_WORKFLOWS/gsd" ] && rm -rf "$WINDSURF_WORKFLOWS/gsd" && removed=$((removed+1))
if [ $removed -gt 0 ]; then
    echo "  Removed: $removed GSD workflow file(s) from $WINDSURF_WORKFLOWS"
else
    echo "  Not found (skipping): $WINDSURF_WORKFLOWS/gsd-*.md"
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
