# HarmonyOS Migration Rules — Android → HarmonyOS (ArkTS/ArkUI)

## Rules for Code Conversion

When converting Android (Kotlin/Java/Compose/XML) to HarmonyOS:

1. **Language:** `val`→`const`, `var`→`let` with types. `String?`→`string | null`. `suspend`→`async`/`Promise<T>`. `data class`→`@Observed class`. No `any`. No extension functions.

2. **UI:** `@Composable fun`→`@Component struct` with `build()`. `remember{mutableStateOf()}`→`@State`. Method chains AFTER build block. ForEach needs key generator (3rd arg). `Button(onClick){Text()}`→`Button('label').onClick()`.

3. **APIs:** SharedPreferences→`preferences` (async). Room→`relationalStore`. Retrofit→`http.createHttp()` (destroy in finally). NavController→`router`. `R.drawable.x`→`$r('app.media.x')`.

4. **Architecture:** Activity→UIAbility. ViewModel→`@Observed` class. Hilt→manual DI. Application→AbilityStage.

5. **Critical:** `@Entry` on nav targets + `main_pages.json`. No sync I/O in `build()`. `@State` first-level only — `@Observed`+`@ObjectLink` for nested.
