# AI Tool Integration Guide

This guide explains how each AI coding tool consumes rule sets and how our templates are formatted for maximum compatibility.

## How AI Tools Use Rules

All modern AI coding assistants support some form of persistent instructions — a block of text that shapes the AI's behavior across interactions. Our rule sets are designed to fit into these mechanisms.

| AI Tool | Mechanism | File Format | Token Budget |
|---|---|---|---|
| Claude | Project Instructions / System Prompt | `.md` | ~200K context |
| Cursor | Rules for AI | `.mdc` in `.cursor/rules/` | Loaded per-file |
| GitHub Copilot | Custom Instructions | `.md` in `.github/` | ~4K instructions |
| Windsurf | Cascade Rules | `.windsurfrules` at root | Per-conversation |
| Cline / Roo Code | Custom Instructions | `.clinerules` at root | Per-conversation |
| Aider | Conventions | `.aider.conf.yml` | Per-session |
| JetBrains AI | Prompt Templates | Custom prompts | Per-prompt |
| Gemini | System Instructions | Plain text | ~32K system |
| Internal LLMs | System Prompt / RAG | `.md` or indexed | Varies |

## Template Design Principles

### Modular Loading
Each rule category is a standalone file. AI tools with limited context windows can load only the relevant modules.

### Master Ruleset
The `_master-ruleset.md` file combines all rules into one document. Use this when:
- Your AI tool has a large context window (Claude, Gemini)
- You're doing a comprehensive migration
- You want all rules available at once

### Tool-Specific Formatting

**Cursor (`.mdc`):**
Cursor uses MDC format with optional frontmatter. Our template includes `description` and `globs` fields so rules activate only on relevant file types.

**Copilot (`copilot-instructions.md`):**
GitHub Copilot reads from `.github/copilot-instructions.md`. Our template is concise to fit within Copilot's instruction budget, focusing on the most critical transformation rules.

**Windsurf (`.windsurfrules`):**
Plain Markdown with rules structured as directives. Loaded automatically when present in the project root.

**Cline (`.clinerules`):**
Similar to Windsurf — plain Markdown with clear directive formatting.

**System Prompt (`system-prompt.md`):**
A generic format that works with any LLM via API. Includes a role definition, rule summary, and key transformation tables.

## Creating Templates for New Tools

If you use an AI tool not yet supported:

1. Study how the tool ingests custom instructions
2. Adapt `_master-ruleset.md` to the tool's format
3. Optimize for the tool's token/context limits
4. Add setup instructions as comments at the top of the template
5. Submit a PR to `templates/`

## Token Optimization Strategies

For tools with limited context:

- Load only the rule categories you need right now
- Use mapping tables instead of verbose explanations
- Reference rule IDs (e.g., "apply RULE-UI-003") instead of repeating full rules
- Split large migrations into focused sessions (UI session, data session, etc.)
