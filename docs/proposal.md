# HarmonyOS AI Migration Rulesets — Open Source Project Proposal

## Executive Summary

**Problem:** Companies and individual developers looking to migrate their existing applications (Android, iOS, WearOS) to HarmonyOS face high costs, long timelines, and a steep platform learning curve.

**Our Solution:** An open-source GitHub repository containing standardized migration rule sets — packaged in Markdown files structured for AI consumption — that work with every major AI coding assistant (Claude, Cursor, Copilot, Gemini, internal LLMs, etc.).

**Core Insight:** Every AI coding tool today shares a common mechanism: `.md`-based instruction files (rulesets, skills, system prompts) that shape AI behavior. Our repository creates a **Migration Intelligence Layer** — an AI-tool-agnostic, community-driven knowledge base that encodes platform transformation knowledge in a standardized, machine-readable format.

---

## 1. Strategic Assessment

### 1.1 Why This Approach?

| Current State | Our Proposal |
|---|---|
| Migration guides are static documentation | Structured rules that AI can interpret and execute |
| Every developer learns from scratch | Accumulated knowledge in rule sets, instantly accessible via AI |
| Platform knowledge is scattered | Single repo, single source of truth, versioned |
| Company-specific tool dependency | AI-tool agnostic — works with any LLM |

### 1.2 Competitive Advantage

- **First mover:** No mobile ecosystem has published open-source AI-powered migration rule sets.
- **Community flywheel:** Open-source structure incentivizes contributions. Every PR expands the knowledge base.
- **Ecosystem accelerator:** Lowering the migration barrier = more HarmonyOS apps = stronger ecosystem.

### 1.3 Target Audience

1. **Enterprise development teams** — Companies with existing Android/iOS apps to migrate
2. **Independent developers** — Individuals expanding their apps to a new platform
3. **Agencies & consultancies** — Running migration projects for clients
4. **Internal teams** — HarmonyOS ecosystem team's own migration support operations

---

## 2. Project Scope

### 2.1 Migration Paths

```
Phase 1 (MVP)
├── Android → HarmonyOS (ArkTS/ArkUI)
│   ├── Kotlin/Java → ArkTS language transformation
│   ├── Jetpack Compose → ArkUI component mapping
│   ├── Android XML Layout → ArkUI declarative UI
│   ├── Android Manifest → module.json5 configuration
│   ├── Gradle → hvigorfile.ts build system
│   ├── Android Lifecycle → Ability Lifecycle
│   ├── SharedPreferences → Preferences API
│   ├── Room DB → RelationalStore
│   ├── Retrofit/OkHttp → @ohos/net.http
│   ├── Navigation Component → Router/Navigation
│   └── Firebase → HarmonyOS Push Kit / Cloud DB

Phase 2
├── iOS → HarmonyOS (ArkTS/ArkUI)
│   ├── Swift/SwiftUI → ArkTS/ArkUI
│   ├── UIKit → ArkUI component mapping
│   ├── CoreData → RelationalStore / Preferences
│   ├── Combine → HarmonyOS reactive patterns
│   ├── URLSession → @ohos/net.http
│   ├── Storyboard/XIB → ArkUI declarative UI
│   └── APNs → HarmonyOS Push Kit

Phase 3
├── WearOS → HarmonyOS Wearable
│   ├── Wear Compose → ArkUI Wearable components
│   ├── Health Services → HarmonyOS Health Kit
│   ├── Tiles → Service Widget / Card
│   ├── Watch Face → Clock Ability
│   └── Complications → HarmonyOS Widget Slots

Phase 4 (Expansion)
├── Flutter → HarmonyOS
├── React Native → HarmonyOS
└── Cross-platform framework conversions
```

### 2.2 Rule Set Categories

Each migration path includes rule set files across these categories:

| Category | Description | Example File |
|---|---|---|
| **Language Transform** | Language constructs, syntax, type system conversions | `lang-transform.md` |
| **UI Components** | UI component mapping and conversion rules | `ui-components.md` |
| **Architecture** | Architectural pattern transformations (MVVM, Clean Arch) | `architecture.md` |
| **APIs & Services** | Platform API equivalents | `api-mapping.md` |
| **Build & Config** | Build system, manifest, configuration files | `build-config.md` |
| **Data & Storage** | Database, file system, preferences | `data-storage.md` |
| **Networking** | HTTP, WebSocket, gRPC conversions | `networking.md` |
| **Navigation** | Page management, routing, deep linking | `navigation.md` |
| **Permissions** | Permission model mapping | `permissions.md` |
| **Testing** | Test framework conversions | `testing.md` |
| **Common Pitfalls** | Frequently encountered mistakes and fixes | `pitfalls.md` |
| **Best Practices** | HarmonyOS-specific idiomatic patterns | `best-practices.md` |

### 2.3 AI Tool Compatibility

Rule sets are designed for compatibility with:

| AI Tool | Integration Method |
|---|---|
| **Claude (claude.ai / API)** | Skill file / system prompt |
| **Cursor** | `.cursor/rules/` directory as `.mdc` rule |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **Windsurf** | `.windsurfrules` at project root |
| **Aider** | `.aider.conf.yml` conventions or system prompt |
| **Cline / Roo Code** | `.clinerules` file |
| **JetBrains AI** | Custom prompt template |
| **Gemini (Google AI Studio)** | System instruction |
| **Internal / Self-hosted LLMs** | System prompt / RAG pipeline |

---

## 3. Repository Structure (Initial Version)

```
harmonyos-migration-rulesets/
│
├── README.md                          # Project introduction, quick start
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # Apache 2.0
├── CHANGELOG.md
│
├── docs/
│   ├── getting-started.md             # Usage guide (per AI tool)
│   ├── rule-format-spec.md            # Rule set authoring format standard
│   ├── ai-tool-integration.md         # Integration guide per AI tool
│   └── faq.md
│
├── android-to-harmonyos/              # Phase 1 — MVP
│   ├── README.md
│   ├── _master-ruleset.md             # All rules in a single file
│   ├── rules/                         # Modular rule set files (12 files)
│   ├── examples/                      # Before/after conversion samples
│   └── templates/                     # Pre-formatted for each AI tool
│
├── ios-to-harmonyos/                  # Phase 2
├── wearos-to-harmonyos/              # Phase 3
│
├── shared/                            # Cross-path HarmonyOS fundamentals
│   ├── harmonyos-fundamentals.md
│   ├── arkts-language-guide.md
│   ├── arkui-component-catalog.md
│   └── distributed-capabilities.md
│
├── tools/                             # Validators, mergers, setup scripts
│   ├── rule-validator/
│   ├── rule-merger/
│   └── setup-scripts/
│
└── .github/
    ├── ISSUE_TEMPLATE/
    ├── PULL_REQUEST_TEMPLATE.md
    └── workflows/
```

---

## 4. Rule Set Format Standard

Every rule set file follows a consistent structure for AI readability:

```markdown
---
title: "Kotlin/Java → ArkTS Language Transformations"
migration_path: android-to-harmonyos
category: lang-transform
version: 1.0.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Title

## Context
What this rule set covers and when to apply it.

## Rules

### RULE-001: Rule Name
- **Source (Android):** Original pattern
- **Target (HarmonyOS):** Converted pattern
- **Code example:** before → after
- **Notes:** Edge cases, caveats

## Anti-Patterns
What NOT to do during conversion.

## Verification Checklist
How to verify correctness.
```

---

## 5. Implementation Roadmap

### Phase 1: MVP (Weeks 1–4)

| Week | Deliverable |
|---|---|
| W1 | Create repo skeleton, publish format standard, prepare CONTRIBUTING.md |
| W2 | Android → HMOS: `lang-transform.md`, `ui-components.md`, `build-config.md` |
| W3 | Android → HMOS: `api-mapping.md`, `data-storage.md`, `networking.md`, `navigation.md` |
| W4 | Remaining rule sets, 2 example apps (hello-world, todo-app), 3 AI tool templates (Cursor, Claude, Copilot) |

**Phase 1 Output:** Complete Android → HarmonyOS rule set + 2 examples + 6 tool templates

### Phase 2: iOS Support (Weeks 5–8)
- iOS → HarmonyOS rule sets
- Swift/SwiftUI → ArkTS/ArkUI conversion rules
- 2 additional example apps

### Phase 3: Wearable + Expansion (Weeks 9–12)
- WearOS → HarmonyOS Wearable rule sets
- Community contribution program launch
- Complete all AI tool templates

### Phase 4: Community & Scale (Week 12+)
- Flutter, React Native migration paths
- Community-contributed rule sets
- Rule set quality metrics and rating system

---

## 6. Success Metrics

| Metric | Target (6 months) | Target (12 months) |
|---|---|---|
| GitHub Stars | 500+ | 2,000+ |
| Community Contributors | 20+ | 100+ |
| Migration Paths | 3 | 6+ |
| Rule Set Files | 36+ | 80+ |
| Example Apps | 6 | 20+ |
| AI Tool Integrations | 6 | 10+ |
| Reported Migrated Apps | 50+ | 500+ |

---

## 7. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| HarmonyOS APIs change rapidly | Rule sets become outdated | Version tags, CI-based API compatibility checks |
| Low community engagement | Repo doesn't grow | Hackathons, DevRel events, contributor rewards |
| Rule set quality inconsistency | Incorrect conversions | Format validator, mandatory PR review, example-based testing |
| Legal / licensing concerns | Usage restrictions | Apache 2.0 license, careful handling of source platform references |

---

## 8. Next Steps

1. **Management Approval** — Present this proposal and allocate resources
2. **Repository Creation** — Create repo under the organization's GitHub
3. **Core Team** — Assign 2–3 engineers (1 Android expert, 1 iOS expert, 1 HarmonyOS expert)
4. **First Sprint** — Begin Phase 1, Week 1 objectives
5. **Internal Pilot** — Convert an existing Android app using the rule sets as validation
6. **Open Source Launch** — Blog post, social media, developer community announcement

---

*Prepared by: [Name] — Developer Advocate Engineering Manager, HarmonyOS Ecosystem*
*Date: April 3, 2026*
