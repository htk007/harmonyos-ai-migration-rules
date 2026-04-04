# Rule Set Format Specification

Version: 1.0.0

This document defines the standard format for all migration rule set files in this repository. Following this format ensures consistency, AI readability, and automated validation.

## File Structure

Every rule set file is a Markdown (`.md`) file with YAML frontmatter and structured sections.

## Frontmatter Schema

```yaml
---
title: string          # Human-readable rule set title
migration_path: enum   # android-to-harmonyos | ios-to-harmonyos | wearos-to-harmonyos
category: enum         # See categories below
version: semver        # e.g., "1.0.0"
hmos_version: string   # Minimum HarmonyOS version, e.g., "5.0+"
last_updated: date     # ISO date, e.g., 2026-04-03
ai_tools: string[]     # Compatible AI tools
complexity: enum       # beginner | intermediate | advanced
---
```

### Categories

| Value | Description |
|---|---|
| `lang-transform` | Language syntax and type system conversion |
| `ui-components` | UI widget/component mapping |
| `architecture` | App architecture pattern adaptation |
| `api-mapping` | Platform API equivalents |
| `build-config` | Build system, manifest, project config |
| `data-storage` | Database, file system, preferences |
| `networking` | HTTP, WebSocket, network layer |
| `navigation` | Routing, page management, deep links |
| `permissions` | Permission model mapping |
| `testing` | Test framework conversion |
| `pitfalls` | Common mistakes and their fixes |
| `best-practices` | Idiomatic HarmonyOS patterns |

## Required Sections

### 1. Context

A brief paragraph explaining what this rule set covers and when an AI assistant should apply these rules.

### 2. Rules

Each rule follows this structure:

```markdown
### RULE-{CATEGORY_PREFIX}-{NUMBER}: Rule Name

- **Source ({Platform}):** Description of the original pattern
- **Target (HarmonyOS):** Description of the target pattern
- **Code Example:**

  Source:
  ```{source_language}
  // Original code
  ```

  Target:
  ```typescript
  // Converted HarmonyOS code
  ```

- **Notes:** Edge cases, caveats, version-specific behavior
```

Rules are numbered with a category prefix for cross-referencing:
- `RULE-LT-001` for lang-transform
- `RULE-UI-001` for ui-components
- `RULE-ARCH-001` for architecture
- `RULE-API-001` for api-mapping
- etc.

### 3. Anti-Patterns

Patterns to explicitly avoid during migration. Format:

```markdown
### DO NOT: Description
​```typescript
// WRONG — explanation
incorrect code

// CORRECT — explanation
correct code
​```
```

### 4. Verification Checklist

A Markdown task list that developers (or AI tools) can use to verify the conversion:

```markdown
- [ ] Check item 1
- [ ] Check item 2
```

## Optional Sections

- **Mapping Table:** Quick-reference tables for 1:1 mappings
- **Migration Strategy:** Step-by-step migration approach for complex conversions
- **Related Rules:** Cross-references to other rule sets
- **Resources:** Links to official HarmonyOS documentation

## Style Guide

- Use fenced code blocks with language identifiers (`kotlin`, `swift`, `typescript`, `json`)
- ArkTS code should use `typescript` as the language identifier
- Keep rules atomic — one concept per rule
- Prefer concrete code examples over abstract descriptions
- Write for AI consumption: be explicit, avoid ambiguity, use consistent terminology
- Use "Source" and "Target" (not "Before/After" or "Old/New")

## File Naming

- Use lowercase kebab-case: `ui-components.md`, `lang-transform.md`
- Master ruleset: `_master-ruleset.md` (underscore prefix for sort order)
- Templates follow tool conventions: `cursor.mdc`, `copilot-instructions.md`
