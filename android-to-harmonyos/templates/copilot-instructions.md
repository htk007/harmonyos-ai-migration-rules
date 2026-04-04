# HarmonyOS Migration — Android to HarmonyOS

When working in this project, convert Android patterns to HarmonyOS:

## Key Conversions
- Kotlin `val`/`var` → ArkTS `const`/`let` with types. No `any`.
- `@Composable fun` → `@Component struct` + `build()`. Methods chain AFTER build block.
- `remember { mutableStateOf() }` → `@State`. Params → `@Prop`/`@Link`.
- `LazyColumn { items() }` → `List() { ForEach(data, builder, keyGen) }`. Key generator required.
- `suspend fun` → `async` returning `Promise<T>`.
- SharedPreferences → `preferences` from `@kit.ArkData` (async).
- Retrofit → `http` from `@kit.NetworkKit`. Always destroy in `finally`.
- NavController → `router` from `@kit.ArkUI`. Pages need `@Entry` + `main_pages.json`.
- `R.drawable.x` → `$r('app.media.x')`. Context → `common.UIAbilityContext`.
- Activity → UIAbility. ViewModel → `@Observed` class. Hilt → manual DI.

## Critical Rules
1. `Column() { ... }.width('100%')` — methods AFTER build block
2. ForEach always needs key generator as 3rd argument
3. Never use `any` type — define interfaces
4. Destroy HTTP requests in `finally` block
5. No sync I/O in `build()` — load in `aboutToAppear()`
6. `@Entry` required on all navigation target pages
