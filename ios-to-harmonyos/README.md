# iOS → HarmonyOS Migration

> 🟡 **Phase 2 — In Progress** (Initial rule sets available)

This directory contains the rule set for migrating iOS applications (Swift, SwiftUI, UIKit) to HarmonyOS (ArkTS/ArkUI).

## Available Rule Sets

| File | Status | What It Covers |
|---|---|---|
| [`lang-transform.md`](./rules/lang-transform.md) | ✅ Available | Swift → ArkTS language conversion (types, optionals, closures, async, protocols, enums) |
| [`ui-components.md`](./rules/ui-components.md) | ✅ Available | SwiftUI / UIKit → ArkUI (views, state, lists, navigation, tabs, styling) |

## Planned Rule Sets

| File | Status | What It Will Cover |
|---|---|---|
| `architecture.md` | 🔲 Planned | iOS app architecture → HarmonyOS architecture |
| `api-mapping.md` | 🔲 Planned | iOS SDK → HarmonyOS Kit APIs |
| `build-config.md` | 🔲 Planned | Xcode project → DevEco Studio project |
| `data-storage.md` | 🔲 Planned | CoreData / UserDefaults → RDB / Preferences |
| `networking.md` | 🔲 Planned | URLSession / Alamofire → @ohos/net.http |
| `navigation.md` | 🔲 Planned | NavigationStack → Router |
| `permissions.md` | 🔲 Planned | iOS permissions → HarmonyOS permissions |
| `testing.md` | 🔲 Planned | XCTest → HarmonyOS test framework |
| `pitfalls.md` | 🔲 Planned | Common iOS→HMOS migration mistakes |
| `best-practices.md` | 🔲 Planned | Idiomatic HarmonyOS patterns for iOS developers |

## Contributing

Want to help build Phase 2? We welcome contributions! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines, or open a [migration path request](../.github/ISSUE_TEMPLATE/migration-path-request.md) to discuss scope.
