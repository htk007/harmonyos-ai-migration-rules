# Android → HarmonyOS Migration

This directory contains the complete rule set for migrating Android applications (Kotlin/Java, Jetpack Compose, XML layouts) to HarmonyOS (ArkTS/ArkUI).

## Quick Start

**Full migration:** Load [`_master-ruleset.md`](./_master-ruleset.md) into your AI tool.

**Targeted migration:** Load individual files from [`rules/`](./rules/) based on your current task.

## Rule Set Files

| File | What It Covers |
|---|---|
| [`lang-transform.md`](./rules/lang-transform.md) | Kotlin/Java → ArkTS language conversion |
| [`ui-components.md`](./rules/ui-components.md) | Jetpack Compose / XML → ArkUI components |
| [`architecture.md`](./rules/architecture.md) | MVVM, Clean Architecture adaptation |
| [`api-mapping.md`](./rules/api-mapping.md) | Android SDK → HarmonyOS Kit APIs |
| [`build-config.md`](./rules/build-config.md) | Gradle → hvigor, Manifest → module.json5 |
| [`data-storage.md`](./rules/data-storage.md) | Room / SharedPreferences → RDB / Preferences |
| [`networking.md`](./rules/networking.md) | Retrofit / OkHttp → @ohos/net.http |
| [`navigation.md`](./rules/navigation.md) | Navigation Component → Router / Navigation |
| [`permissions.md`](./rules/permissions.md) | Android permissions → HarmonyOS permissions |
| [`testing.md`](./rules/testing.md) | JUnit / Espresso → HarmonyOS test framework |
| [`pitfalls.md`](./rules/pitfalls.md) | Common migration mistakes and solutions |
| [`best-practices.md`](./rules/best-practices.md) | Idiomatic HarmonyOS patterns |

## Examples

| Example | Description |
|---|---|
| [`hello-world/`](./examples/hello-world/) | Minimal app conversion — single screen, basic UI |
| [`todo-app/`](./examples/todo-app/) | CRUD app with storage, list UI, navigation |

## AI Tool Templates

| Tool | Template File |
|---|---|
| Claude | [`templates/claude-skill.md`](./templates/claude-skill.md) |
| Cursor | [`templates/cursor.mdc`](./templates/cursor.mdc) |
| GitHub Copilot | [`templates/copilot-instructions.md`](./templates/copilot-instructions.md) |
| Windsurf | [`templates/windsurfrules.md`](./templates/windsurfrules.md) |
| Cline | [`templates/clinerules.md`](./templates/clinerules.md) |
| Generic LLM | [`templates/system-prompt.md`](./templates/system-prompt.md) |
