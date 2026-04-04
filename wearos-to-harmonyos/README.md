# WearOS → HarmonyOS Wearable Migration

> 🟡 **Phase 3 — In Progress** (Initial rule sets available)

This directory contains the rule set for migrating WearOS applications to HarmonyOS Wearable.

## Available Rule Sets

| File | Status | What It Covers |
|---|---|---|
| [`ui-components.md`](./rules/ui-components.md) | ✅ Available | Wear Compose → ArkUI Wearable (chips, lists, workout screens, gauges, paging) |
| [`api-mapping.md`](./rules/api-mapping.md) | ✅ Available | Health Services, Tiles, Watch-Phone Sync, Sensors → HarmonyOS APIs |

## Planned Rule Sets

| File | Status | What It Will Cover |
|---|---|---|
| `lang-transform.md` | 🔲 Planned | Kotlin (Wear) → ArkTS language conversion |
| `build-config.md` | 🔲 Planned | Wear module → HarmonyOS wearable HAP |
| `watch-face.md` | 🔲 Planned | Watch Face API → Clock Ability |
| `complications.md` | 🔲 Planned | Complications → Widget Slots |
| `pitfalls.md` | 🔲 Planned | Common wearable migration mistakes |

## Contributing

Want to help build Phase 3? See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
