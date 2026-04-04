# HarmonyOS Migration Rules (Android → HarmonyOS)

## Directives

When converting Android code to HarmonyOS, apply these transformations:

### Language
- Kotlin `val`→`const`, `var`→`let`, always with type annotations
- `String?`→`string | null`, `?:`→`??`, `suspend fun`→`async` returning `Promise<T>`
- `data class`→`@Observed class`, `sealed class`→discriminated union
- No `any` type. No extension functions. No structural typing for classes.

### UI
- `@Composable fun`→`@Component struct` with `build()`
- `remember { mutableStateOf() }`→`@State`, params→`@Prop`/`@Link`
- Method chains AFTER build block: `Column() { ... }.width('100%')`
- `LazyColumn { items() }`→`List() { ForEach(data, builder, keyGen) }` — 3rd arg required
- `Button(onClick){Text()}`→`Button('label').onClick()`
- `@Entry` required on navigation target pages + register in `main_pages.json`

### APIs
- SharedPreferences→`preferences` from `@kit.ArkData` (async)
- Room→`relationalStore` from `@kit.ArkData`
- Retrofit→`http` from `@kit.NetworkKit` (destroy in finally)
- Navigation→`router` from `@kit.ArkUI`
- Resources: `R.drawable.x`→`$r('app.media.x')`, `R.string.x`→`$r('app.string.x')`

### Architecture
- Activity→UIAbility, ViewModel→`@Observed` class, LiveData→`@State`
- Hilt→manual DI, Application→AbilityStage
