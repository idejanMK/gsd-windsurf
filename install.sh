#!/usr/bin/env bash
# GSD for Windsurf — Installer (macOS/Linux)

set -e

GSD_HOME="$HOME/.codeium/windsurf/get-shit-done"
WINDSURF_RULES="$HOME/.codeium/windsurf/windsurf/rules"

WINDSURF_WORKFLOWS="$HOME/.codeium/windsurf/global_workflows"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "GSD for Windsurf — Installing..."
echo ""

mkdir -p "$GSD_HOME/agents" "$GSD_HOME/references" "$GSD_HOME/templates"
mkdir -p "$WINDSURF_WORKFLOWS" "$WINDSURF_RULES"

# Remove stale gsd/ subfolder from old install
rm -rf "$WINDSURF_WORKFLOWS/gsd"

cp -r "$SCRIPT_DIR/src/agents/"* "$GSD_HOME/agents/"
echo "  agents/          -> $GSD_HOME/agents/"

cp -r "$SCRIPT_DIR/src/references/"* "$GSD_HOME/references/"
echo "  references/      -> $GSD_HOME/references/"

cp -r "$SCRIPT_DIR/src/templates/"* "$GSD_HOME/templates/"
echo "  templates/       -> $GSD_HOME/templates/"

for f in "$SCRIPT_DIR/src/workflows/gsd/"*.md; do
  cp "$f" "$WINDSURF_WORKFLOWS/gsd-$(basename "$f")"
done
echo "  workflows/gsd/*.md -> $WINDSURF_WORKFLOWS/gsd-*.md"

cp "$SCRIPT_DIR/src/rules/gsd-core.md" "$WINDSURF_RULES/gsd-core.md"
echo "  rules/gsd-core.md -> $WINDSURF_RULES/gsd-core.md"

echo ""
echo "GSD for Windsurf installed successfully."
echo "Restart Windsurf to activate /gsd/* workflows."
