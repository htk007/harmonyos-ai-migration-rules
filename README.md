<p align="center">
  <img src="https://img.shields.io/badge/HarmonyOS-5.0+-00C853?style=for-the-badge&logo=harmony-os&logoColor=white" alt="HarmonyOS 5.0+"/>
  <img src="https://img.shields.io/badge/AI--Powered-Migration-7C4DFF?style=for-the-badge&logo=openai&logoColor=white" alt="AI-Powered"/>
  <img src="https://img.shields.io/badge/License-Apache_2.0-blue?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/badge/Status-Phase_1_(MVP)-orange?style=for-the-badge" alt="Status"/>
</p>

# HarmonyOS Migration Rulesets

**AI-powered migration intelligence for moving apps to HarmonyOS — works with any AI coding assistant.**

> Stop teaching your AI assistant about HarmonyOS from scratch every time. This repo provides structured, battle-tested rule sets that any LLM can use to accurately transform Android, iOS, and WearOS code into idiomatic HarmonyOS (ArkTS/ArkUI).

---

## The Problem

Migrating apps to HarmonyOS today means:
- Developers learn platform differences through trial and error
- AI assistants hallucinate HarmonyOS APIs without proper guidance
- Every team reinvents the same mapping tables and conversion patterns
- Migration knowledge stays locked in individual heads or internal wikis

## The Solution

**A standardized, open-source collection of migration rule sets** — written in Markdown, structured for AI consumption, and compatible with every major AI coding tool.

```
Your existing app (Android/iOS/WearOS)
        ↓
  AI Tool + Migration Ruleset
        ↓
  Idiomatic HarmonyOS app (ArkTS/ArkUI)
```

Each rule set encodes platform knowledge as structured transformation rules that AI assistants can follow: component mappings, API equivalents, architecture patterns, anti-patterns to avoid, and verification checklists.

---

## Quick Start

### 1. Pick your migration path

| From | To | Status | Directory |
|---|---|---|---|
| Android (Kotlin/Java) | HarmonyOS (ArkTS) | ✅ Phase 1 | [`android-to-harmonyos/`](./android-to-harmonyos/) |
| iOS (Swift/SwiftUI) | HarmonyOS (ArkTS) | 🔜 Phase 2 | [`ios-to-harmonyos/`](./ios-to-harmonyos/) |
| WearOS | HarmonyOS Wearable | 🔜 Phase 3 | [`wearos-to-harmonyos/`](./wearos-to-harmonyos/) |

### 2. Choose your AI tool and load the rules

<details>
<summary><strong>Claude (claude.ai / API)</strong></summary>

Copy the contents of `android-to-harmonyos/templates/claude-skill.md` into your Claude project's custom instructions, or reference individual rule files in your prompt:

```
Use the following migration rules when converting my Android code to HarmonyOS:

[paste contents of android-to-harmonyos/_master-ruleset.md]

Now convert the following Kotlin file to ArkTS:
[your code]
```
</details>

<details>
<summary><strong>Cursor</strong></summary>

Copy the template file into your project:
```bash
mkdir -p .cursor/rules
cp android-to-harmonyos/templates/cursor.mdc .cursor/rules/harmonyos-migration.mdc
```
Cursor will automatically apply these rules when you work on migration tasks.
</details>

<details>
<summary><strong>GitHub Copilot</strong></summary>

Copy the template to your repo root:
```bash
cp android-to-harmonyos/templates/copilot-instructions.md .github/copilot-instructions.md
```
</details>

<details>
<summary><strong>Windsurf</strong></summary>

Copy the rules file to your project root:
```bash
cp android-to-harmonyos/templates/windsurfrules.md .windsurfrules
```
</details>

<details>
<summary><strong>Cline / Roo Code</strong></summary>

Copy the rules file to your project root:
```bash
cp android-to-harmonyos/templates/clinerules.md .clinerules
```
</details>

<details>
<summary><strong>Any other LLM (Gemini, GPT, Llama, internal LLMs)</strong></summary>

Use `android-to-harmonyos/templates/system-prompt.md` as your system prompt, or include `_master-ruleset.md` in your RAG pipeline.
</details>

### 3. Start migrating

Point your AI tool at your source code and ask it to convert. The rule sets guide the AI to produce correct, idiomatic HarmonyOS code.

---

## What's Inside

```
harmonyos-migration-rulesets/
│
├── android-to-harmonyos/          # Android → HarmonyOS migration
│   ├── rules/                     # Modular rule set files
│   │   ├── lang-transform.md      # Kotlin/Java → ArkTS
│   │   ├── ui-components.md       # Compose/XML → ArkUI
│   │   ├── architecture.md        # Android Arch → HarmonyOS Arch
│   │   ├── api-mapping.md         # Platform API equivalents
│   │   ├── build-config.md        # Gradle → hvigor
│   │   ├── data-storage.md        # Room/SharedPrefs → RDB/Preferences
│   │   ├── networking.md          # Retrofit → @ohos/net.http
│   │   ├── navigation.md          # Navigation Component → Router
│   │   ├── permissions.md         # Permission model mapping
│   │   ├── testing.md             # Test framework conversion
│   │   ├── pitfalls.md            # Common mistakes & fixes
│   │   └── best-practices.md      # HarmonyOS-specific best practices
│   │
│   ├── examples/                  # Before/after conversion samples
│   ├── templates/                 # Pre-formatted for each AI tool
│   └── _master-ruleset.md         # All rules in a single file
│
├── ios-to-harmonyos/              # iOS → HarmonyOS (Phase 2)
├── wearos-to-harmonyos/           # WearOS → HarmonyOS (Phase 3)
├── shared/                        # Cross-path HarmonyOS fundamentals
├── tools/                         # Validators, mergers, setup scripts
└── docs/                          # Guides and specifications
```

### Rule Set Categories

Each migration path includes rules for:

| Category | What It Covers |
|---|---|
| **Language Transform** | Syntax, types, null safety, async patterns |
| **UI Components** | Widget/component mapping with before/after examples |
| **Architecture** | MVVM, Clean Architecture pattern adaptation |
| **API Mapping** | Platform API equivalents (camera, sensors, storage, etc.) |
| **Build & Config** | Build system, manifest, project structure |
| **Data & Storage** | Database, file system, preferences |
| **Networking** | HTTP clients, WebSocket, interceptors |
| **Navigation** | Routing, deep links, page lifecycle |
| **Permissions** | Permission model differences and mapping |
| **Testing** | Unit test, UI test framework conversion |
| **Pitfalls** | Frequent mistakes during migration |
| **Best Practices** | Idiomatic HarmonyOS patterns |

---

## Rule Set Format

Every rule set follows a consistent structure for AI readability:

```markdown
---
title: "Rule Set Title"
migration_path: android-to-harmonyos
category: ui-components
version: 1.0.0
hmos_version: "5.0+"
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
---

# Title

## Context
What this rule set covers and when to apply it.

## Rules

### RULE-001: Rule Name
- **Source (Android):** Original pattern
- **Target (HarmonyOS):** Converted pattern
- **Code example** (before → after)
- **Notes:** Edge cases, caveats

## Anti-Patterns
What NOT to do during conversion.

## Verification Checklist
How to verify the conversion is correct.
```

See [docs/rule-format-spec.md](./docs/rule-format-spec.md) for the full specification.

---

## Roadmap

| Phase | Scope | Timeline | Status |
|---|---|---|---|
| **Phase 1** | Android → HarmonyOS (full rule set + examples + templates) | Weeks 1–4 | 🟢 In Progress |
| **Phase 2** | iOS → HarmonyOS (Swift/SwiftUI → ArkTS/ArkUI) | Weeks 5–8 | 🔲 Planned |
| **Phase 3** | WearOS → HarmonyOS Wearable | Weeks 9–12 | 🔲 Planned |
| **Phase 4** | Flutter, React Native → HarmonyOS + Community growth | Week 12+ | 🔲 Future |

---

## Contributing

We welcome contributions from the HarmonyOS community! Whether you're fixing a rule, adding examples, or creating a new migration path — every contribution makes migration easier for everyone.

See [CONTRIBUTING.md](./Contributing.md) for guidelines.

**Ways to contribute:**
- 🐛 Report incorrect rules or missing mappings
- ✨ Add new transformation rules with examples
- 📱 Share before/after migration samples from real apps
- 🔧 Create templates for additional AI tools
- 📖 Improve documentation and guides
- 🌍 Translate rule sets

---

## Why This Approach Works

**AI-tool agnostic.** Rule sets are plain Markdown — they work with Claude, Cursor, Copilot, Gemini, or your company's internal LLM. No vendor lock-in.

**Community-driven accuracy.** Every contribution improves the rules. A bug found once is fixed for everyone.

**Token-efficient.** Modular rule files mean you load only what you need. Working on UI? Load `ui-components.md`. Migrating networking? Load `networking.md`.

**Battle-tested patterns.** Rules include anti-patterns and pitfalls discovered during real migrations, not just API documentation.

---

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](./LICENSE) file for details.

---

<p align="center">
  <strong>Lower the barrier. Grow the ecosystem.</strong><br/>
  <sub>Built with ❤️ for the HarmonyOS developer community</sub>
</p>
