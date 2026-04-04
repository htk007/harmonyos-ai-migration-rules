---
title: "Android → HarmonyOS Complete Migration Ruleset"
migration_path: android-to-harmonyos
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
description: "Combined ruleset containing all transformation rules for Android to HarmonyOS migration. Load this single file for comprehensive coverage."
---

# Android → HarmonyOS Complete Migration Ruleset

> This is the combined master ruleset. For modular files, see the `rules/` directory.

---

## 1. Language Transformation (Kotlin/Java → ArkTS)

### Types
| Kotlin/Java | ArkTS |
|---|---|
| `Int`/`Long`/`Float`/`Double` | `number` |
| `Boolean` | `boolean` |
| `String` | `string` |
| `Array<T>` / `List<T>` | `T[]` or `Array<T>` |
| `Map<K,V>` | `Map<K,V>` |
| `Unit`/`void` | `void` |

### Variables
- `val x = 5` → `const x: number = 5`
- `var x = 5` → `let x: number = 5`
- Always include type annotations

### Nullability
- `String?` → `string | null`
- `?.` → `?.` (same), `?:` → `??`, `!!` → `!`

### Functions
- `fun x(a: T): R` → `function x(a: T): R`
- `suspend fun` → `async function` returning `Promise<T>`
- No extension functions — use standalone utility functions
- String templates: `"$x"` → `` `${x}` ``

### Classes
- `data class` → `@Observed class` with explicit constructor
- `sealed class` → discriminated union with `type` field
- `enum class` → `enum`

### Collections
- `list.any{}` → `list.some()`, `list.all{}` → `list.every()`
- `{ x -> expr }` → `(x) => expr`
- `listOf()` → `[]`, `mapOf()` → `new Map()`

### Async
- `CoroutineScope.launch{}` → `async/await` or `.then().catch()`
- `withContext(Dispatchers.IO)` → not needed
- `Flow<T>` → callbacks or `@Watch` decorator

### Rules
- No `any` type
- No structural typing for classes — use `new Constructor()`
- No `lateinit` — initialize all properties

---

## 2. UI Components (Compose/XML → ArkUI)

### Component Structure
- `@Composable fun` → `@Component struct` with `build()` method
- Function params → `@Prop` (one-way) / `@Link` (two-way)
- Navigation targets → add `@Entry` decorator

### Layouts
| Compose/XML | ArkUI |
|---|---|
| `Column` / `LinearLayout(vertical)` | `Column()` |
| `Row` / `LinearLayout(horizontal)` | `Row()` |
| `Box` / `FrameLayout` | `Stack()` |
| `LazyColumn` / `RecyclerView` | `List()` |
| `Spacer` | `Blank()` |
| `Scaffold` | Custom composition |

### State
| Compose | ArkUI |
|---|---|
| `remember { mutableStateOf() }` | `@State` |
| Parameter | `@Prop` (copy) / `@Link` (reference) |
| `CompositionLocalProvider` | `@Provide` / `@Consume` |
| `derivedStateOf` | getter or `@Watch` |
| `LaunchedEffect` | `aboutToAppear()` |

### Lists — CRITICAL
```typescript
List() {
  ForEach(data, (item: T) => {
    ListItem() { /* content */ }
  }, (item: T) => item.id.toString())  // KEY GENERATOR REQUIRED
}
```

### Styling (Modifier → Method Chain)
- Methods go AFTER the build block: `Column() { }.width('100%')`
- `fillMaxWidth()` → `.width('100%')`
- `padding(16.dp)` → `.padding(16)`
- `background(color)` → `.backgroundColor(color)`
- `clip(RoundedCornerShape(8))` → `.borderRadius(8)`
- `clickable{}` → `.onClick(() => {})`
- `weight(1f)` → `.layoutWeight(1)`

### Components
| Compose/XML | ArkUI |
|---|---|
| `Text("x")` | `Text('x')` |
| `Button(onClick){Text()}` | `Button('label').onClick()` |
| `TextField(value,onChange)` | `TextInput({text}).onChange()` |
| `Image(painterResource)` | `Image($r('app.media.x'))` |
| `Checkbox(checked,onChange)` | `Checkbox().select().onChange()` |
| `Switch` | `Toggle({isOn}).onChange()` |
| `AlertDialog` | `AlertDialog.show({})` |

### Resources
- `R.drawable.x` → `$r('app.media.x')`
- `R.string.x` → `$r('app.string.x')`
- System: `$r('sys.color.ohos_id_color_primary')`

---

## 3. Architecture

### Component Mapping
| Android | HarmonyOS |
|---|---|
| Activity | UIAbility |
| Fragment | @Component struct |
| ViewModel | @Observed class |
| LiveData/StateFlow | @State/@Link decorators |
| Application | AbilityStage |
| Service | ServiceExtensionAbility |
| BroadcastReceiver | CommonEventManager |
| Hilt/Dagger | Manual DI / service locator |

### Lifecycle
| Android | HarmonyOS |
|---|---|
| `onCreate()` | `onCreate()` + `onWindowStageCreate()` |
| `onResume()` | `onForeground()` |
| `onPause()` | `onBackground()` |
| `onDestroy()` | `onDestroy()` |

---

## 4. API Mapping

| Android | HarmonyOS | Import |
|---|---|---|
| SharedPreferences | `preferences` (async) | `@kit.ArkData` |
| Room/SQLite | `relationalStore` | `@kit.ArkData` |
| Retrofit/OkHttp | `http.createHttp()` | `@kit.NetworkKit` |
| Navigation Component | `router` | `@kit.ArkUI` |
| LocationManager | `geoLocationManager` | `@kit.LocationKit` |
| Camera2 | `camera` | `@kit.CameraKit` |
| NotificationManager | `notificationManager` | `@kit.NotificationKit` |
| BiometricPrompt | `userAuth` | `@kit.UserAuthenticationKit` |
| WebSocket | `webSocket` | `@kit.NetworkKit` |
| ConnectivityManager | `connection` | `@kit.NetworkKit` |
| Intent (share) | Want | `@kit.AbilityKit` |
| Context | `common.UIAbilityContext` | `@kit.AbilityKit` |

---

## 5. Build & Configuration

### Project Structure
| Android | HarmonyOS |
|---|---|
| `src/main/java/` | `src/main/ets/` |
| `src/main/res/` | `src/main/resources/` |
| `AndroidManifest.xml` | `module.json5` |
| `build.gradle` | `hvigorfile.ts` + `oh-package.json5` |
| `settings.gradle` | `build-profile.json5` |

### Manifest → module.json5
- Activities → `"abilities"` array
- Permissions → `"requestPermissions"` (user_grant needs `reason`)
- All pages registered in `main_pages.json`

### Dependencies
Most Android libraries have built-in HarmonyOS equivalents — Retrofit, Coil, Room, Navigation all have platform-native alternatives requiring no third-party packages.

---

## 6. Navigation

- `navController.navigate(route)` → `router.pushUrl({ url, params })`
- `navController.popBackStack()` → `router.back()`
- Params via object, not URL path segments
- Bottom nav: `Scaffold` + `NavigationBar` → `Tabs` + `TabContent`
- All pages need `@Entry` + `main_pages.json` registration

---

## 7. Permissions

| Android | HarmonyOS | Grant |
|---|---|---|
| `INTERNET` | `ohos.permission.INTERNET` | system_grant |
| `CAMERA` | `ohos.permission.CAMERA` | user_grant |
| `RECORD_AUDIO` | `ohos.permission.MICROPHONE` | user_grant |
| `ACCESS_FINE_LOCATION` | `APPROXIMATELY_LOCATION` + `LOCATION` | user_grant |
| `BLUETOOTH` | `ohos.permission.ACCESS_BLUETOOTH` | user_grant |

Runtime request: `abilityAccessCtrl.createAtManager().requestPermissionsFromUser(context, permissions)`

---

## 8. Critical Rules Summary

1. **Method chains AFTER build block:** `Column() { ... }.width('100%')` ✅
2. **ForEach key generator required:** Always provide 3rd argument ✅
3. **No `any` type:** Define proper interfaces ✅
4. **Destroy HTTP requests:** Always in `finally` block ✅
5. **No sync I/O in `build()`:** Use `aboutToAppear()` ✅
6. **`@State` is shallow:** Use `@Observed` + `@ObjectLink` for nested ✅
7. **`@Entry` on nav targets:** Plus register in `main_pages.json` ✅
8. **Resources:** `$r('app.media.x')`, `$r('app.string.x')`, `$r('sys.color.xxx')` ✅
9. **Context:** `common.UIAbilityContext` from `@kit.AbilityKit` ✅
10. **Async APIs:** Preferences, RelationalStore, HTTP are ALL async ✅
