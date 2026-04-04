#!/bin/bash
# Setup HarmonyOS Migration Rules for Cursor
# Run this from your project root

REPO_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../../android-to-harmonyos/templates"

mkdir -p "$REPO_PATH/.cursor/rules"
cp "$RULES_DIR/cursor.mdc" "$REPO_PATH/.cursor/rules/harmonyos-migration.mdc"

echo "✅ HarmonyOS migration rules installed for Cursor"
echo "   Location: $REPO_PATH/.cursor/rules/harmonyos-migration.mdc"
echo "   Cursor will automatically apply these rules in your project."
