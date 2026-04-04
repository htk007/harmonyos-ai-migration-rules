#!/bin/bash
# Setup HarmonyOS Migration Rules for Claude
# This script outputs the instructions for using rules with Claude

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../../android-to-harmonyos"

echo "═══════════════════════════════════════════════════════"
echo "  HarmonyOS Migration Rules — Claude Setup Guide"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Option 1: Claude Project (Recommended)"
echo "  1. Go to claude.ai → Projects → Create Project"
echo "  2. Open Project Instructions"
echo "  3. Paste the contents of:"
echo "     $RULES_DIR/templates/claude-skill.md"
echo "  4. Upload your Android source files and start converting"
echo ""
echo "Option 2: Per-Conversation"
echo "  1. Start a new conversation"
echo "  2. Paste the master ruleset at the beginning:"
echo "     $RULES_DIR/_master-ruleset.md"
echo "  3. Then paste your code and ask for conversion"
echo ""
echo "Option 3: Modular (Token-Efficient)"
echo "  Load only the rules you need from:"
echo "     $RULES_DIR/rules/"
echo ""
ls -1 "$RULES_DIR/rules/"*.md 2>/dev/null | while read f; do
  echo "     $(basename "$f")"
done
echo ""
echo "═══════════════════════════════════════════════════════"
