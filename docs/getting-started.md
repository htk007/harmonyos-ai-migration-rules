# Getting Started

This guide walks you through using HarmonyOS Migration Rulesets with your preferred AI coding tool.

## Prerequisites

- An existing Android, iOS, or WearOS app you want to migrate
- Access to an AI coding assistant (Claude, Cursor, Copilot, etc.)
- Basic familiarity with HarmonyOS development concepts

## Step 1: Choose Your Migration Path

Identify your source platform and find the corresponding directory:

| Your App Platform | Directory | Status |
|---|---|---|
| Android (Kotlin/Java, Jetpack Compose, XML) | `android-to-harmonyos/` | ✅ Available |
| iOS (Swift, SwiftUI, UIKit) | `ios-to-harmonyos/` | 🔜 Coming Soon |
| WearOS (Wear Compose) | `wearos-to-harmonyos/` | 🔜 Coming Soon |

## Step 2: Choose What to Load

You have two options:

**Option A: Master Ruleset (recommended for full migrations)**
Load `_master-ruleset.md` — contains all rules in a single file. Best when you're migrating an entire app and want comprehensive coverage.

**Option B: Modular Rules (recommended for targeted tasks)**
Load individual files from `rules/` — pick only the categories relevant to your current task. Best for token efficiency and focused work.

| Task | Load These Rules |
|---|---|
| Converting UI screens | `ui-components.md` + `navigation.md` |
| Migrating data layer | `data-storage.md` + `networking.md` |
| Setting up project | `build-config.md` + `permissions.md` |
| Full app migration | `_master-ruleset.md` |

## Step 3: Set Up Your AI Tool

### Claude (claude.ai)

**Option 1 — Project Instructions:**
1. Create a new Project in Claude
2. Paste the master ruleset into Project Instructions
3. Upload your source files and ask Claude to convert them

**Option 2 — Per-conversation:**
1. Start a new conversation
2. Paste the relevant rule files at the beginning
3. Then paste your source code and ask for conversion

### Cursor

```bash
# From your project root:
mkdir -p .cursor/rules
cp path/to/android-to-harmonyos/templates/cursor.mdc .cursor/rules/harmonyos-migration.mdc
```

Cursor will automatically apply migration rules when you're working in the project.

### GitHub Copilot

```bash
cp path/to/android-to-harmonyos/templates/copilot-instructions.md .github/copilot-instructions.md
```

### Windsurf

```bash
cp path/to/android-to-harmonyos/templates/windsurfrules.md .windsurfrules
```

### Cline / Roo Code

```bash
cp path/to/android-to-harmonyos/templates/clinerules.md .clinerules
```

### Generic LLM (API, internal tools, etc.)

Use `templates/system-prompt.md` as your system prompt. For RAG pipelines, index the individual rule files for retrieval.

## Step 4: Migrate

Start with a small, self-contained component to validate the workflow. A good first target is a single screen or utility class.

**Recommended migration order:**
1. Project setup and build config
2. Data models and types
3. Data layer (storage, networking)
4. UI components (screen by screen)
5. Navigation and routing
6. Permissions and platform integrations
7. Testing

## Tips for Best Results

- **Be specific in your prompts.** Instead of "convert this app," try "convert this ViewModel following the architecture rules."
- **Migrate incrementally.** One file or module at a time produces better results than trying to convert everything at once.
- **Verify with the checklists.** Each rule set includes a verification checklist — use it.
- **Report issues.** If a rule produces incorrect output, open an issue so we can fix it for everyone.
