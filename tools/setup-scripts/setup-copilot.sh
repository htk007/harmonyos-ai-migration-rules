#!/bin/bash
# Setup HarmonyOS Migration Rules for GitHub Copilot
# Run this from your project root

REPO_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../../android-to-harmonyos/templates"

mkdir -p "$REPO_PATH/.github"
cp "$RULES_DIR/copilot-instructions.md" "$REPO_PATH/.github/copilot-instructions.md"

echo "✅ HarmonyOS migration rules installed for GitHub Copilot"
echo "   Location: $REPO_PATH/.github/copilot-instructions.md"
echo "   Copilot will use these instructions in your project."
