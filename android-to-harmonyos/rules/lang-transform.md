---
title: "Kotlin/Java → ArkTS Language Transformations"
migration_path: android-to-harmonyos
category: lang-transform
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Kotlin/Java → ArkTS Language Transformation Rules

## Context

This rule set defines how to convert Android Kotlin and Java language constructs to HarmonyOS ArkTS. ArkTS is a superset of TypeScript with additional static analysis constraints and UI-specific decorators. Apply these rules whenever converting Android source files that contain business logic, data models, utility classes, or any non-UI Kotlin/Java code.

## Key Differences

- ArkTS enforces **strict typing** — no `any` type, no implicit casts
- ArkTS restricts some TypeScript features: no structural typing for classes, limited union types in certain contexts
- HarmonyOS uses **decorators** extensively: `@Component`, `@State`, `@Entry`, `@Observed`, etc.
- Async operations use `async/await` with `Promise<T>` (similar to Kotlin coroutines conceptually)

---

## Rules

### RULE-LT-001: Basic Types

| Kotlin/Java | ArkTS | Notes |
|---|---|---|
| `Int` / `int` | `number` | No separate integer type |
| `Long` / `long` | `number` | Precision loss for very large values |
| `Float` / `float` | `number` | |
| `Double` / `double` | `number` | |
| `Boolean` / `boolean` | `boolean` | |
| `String` | `string` | Lowercase in ArkTS |
| `Char` / `char` | `string` | Single character is still `string` |
| `Byte` / `byte` | `number` | |
| `Array<T>` / `T[]` | `T[]` or `Array<T>` | Both forms supported |
| `List<T>` | `Array<T>` | No separate List interface |
| `Map<K,V>` | `Map<K,V>` | ES6 Map |
| `Set<T>` | `Set<T>` | ES6 Set |
| `Unit` / `void` | `void` | |
| `Nothing` | `never` | |
| `Any` / `Object` | `Object` | Not `any` — ArkTS restricts `any` |

---

### RULE-LT-002: Nullable Types

**Source (Kotlin):**
```kotlin
val name: String? = null
val length = name?.length ?: 0
val forced = name!!
```

**Target (ArkTS):**
```typescript
let name: string | null = null
let length: number = name?.length ?? 0
let forced: string = name!  // Non-null assertion (use sparingly)
```

**Source (Java):**
```java
@Nullable String name = null;
int length = name != null ? name.length() : 0;
```

**Target (ArkTS):**
```typescript
let name: string | null = null
let length: number = name !== null ? name.length : 0
```

**Notes:**
- Kotlin `?:` (Elvis operator) → ArkTS `??` (nullish coalescing)
- Kotlin `?.` (safe call) → ArkTS `?.` (optional chaining) — same syntax
- Kotlin `!!` → ArkTS `!` (non-null assertion) — use sparingly
- ArkTS distinguishes `null` and `undefined`; prefer `null` for explicit absence

---

### RULE-LT-003: Variable Declarations

| Kotlin | ArkTS | Notes |
|---|---|---|
| `val x = 5` | `const x: number = 5` | Immutable |
| `var x = 5` | `let x: number = 5` | Mutable |
| `lateinit var x: String` | `let x: string = ''` | No lateinit; initialize or use `!` |
| `const val X = 5` | `const X: number = 5` | Compile-time constant |
| `companion object { val X = 5 }` | `static readonly X: number = 5` | Inside class |

**Notes:**
- ArkTS requires explicit type annotations in many contexts — always include them
- No `lateinit` equivalent; use default values or `undefined` with null checks

---

### RULE-LT-004: Functions

**Source (Kotlin):**
```kotlin
fun greet(name: String, greeting: String = "Hello"): String {
    return "$greeting, $name!"
}

fun sum(a: Int, b: Int): Int = a + b

// Extension function
fun String.addExclamation(): String = "$this!"
```

**Target (ArkTS):**
```typescript
function greet(name: string, greeting: string = "Hello"): string {
  return `${greeting}, ${name}!`
}

function sum(a: number, b: number): number {
  return a + b
}

// No extension functions — use utility function
function addExclamation(str: string): string {
  return `${str}!`
}
```

**Notes:**
- Kotlin single-expression functions (`= expr`) → ArkTS block body with return
- Kotlin extension functions have no direct equivalent — use standalone utility functions
- Kotlin named arguments are not supported — use parameter order or option objects
- String templates: `"$var"` / `"${expr}"` → `` `${var}` `` / `` `${expr}` ``

---

### RULE-LT-005: Classes and Data Classes

**Source (Kotlin):**
```kotlin
data class User(
    val id: Long,
    val name: String,
    val email: String? = null
)

class UserRepository(
    private val api: UserApi,
    private val db: UserDao
) {
    suspend fun getUser(id: Long): User {
        return api.fetchUser(id)
    }
}
```

**Target (ArkTS):**
```typescript
@Observed
class User {
  id: number
  name: string
  email: string | null

  constructor(id: number, name: string, email: string | null = null) {
    this.id = id
    this.name = name
    this.email = email
  }
}

class UserRepository {
  private api: UserApi
  private db: UserDao

  constructor(api: UserApi, db: UserDao) {
    this.api = api
    this.db = db
  }

  async getUser(id: number): Promise<User> {
    return await this.api.fetchUser(id)
  }
}
```

**Notes:**
- Kotlin `data class` → ArkTS `class` with `@Observed` decorator (if used in UI state)
- `data class` auto-generated `copy()`, `equals()`, `toString()` must be implemented manually if needed
- Kotlin `suspend fun` → ArkTS `async` function returning `Promise<T>`
- Kotlin primary constructor → ArkTS explicit `constructor()`
- `private val` parameters → `private` properties + constructor assignment

---

### RULE-LT-006: Enums and Sealed Classes

**Source (Kotlin):**
```kotlin
enum class Status {
    LOADING, SUCCESS, ERROR
}

sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
    object Loading : Result<Nothing>()
}
```

**Target (ArkTS):**
```typescript
enum Status {
  LOADING,
  SUCCESS,
  ERROR
}

// Sealed class → discriminated union
interface ResultSuccess<T> {
  type: 'success'
  data: T
}

interface ResultError {
  type: 'error'
  message: string
}

interface ResultLoading {
  type: 'loading'
}

type Result<T> = ResultSuccess<T> | ResultError | ResultLoading
```

**Notes:**
- Kotlin `enum class` → ArkTS `enum` (similar syntax)
- Kotlin `sealed class` → ArkTS discriminated union with `type` field
- Use `switch` on the `type` field for exhaustive matching (like Kotlin `when`)

---

### RULE-LT-007: Coroutines → Async/Await

**Source (Kotlin):**
```kotlin
class DataManager {
    private val scope = CoroutineScope(Dispatchers.IO)

    suspend fun fetchData(): List<Item> {
        return withContext(Dispatchers.IO) {
            api.getItems()
        }
    }

    fun loadData() {
        scope.launch {
            try {
                val items = fetchData()
                withContext(Dispatchers.Main) {
                    updateUI(items)
                }
            } catch (e: Exception) {
                handleError(e)
            }
        }
    }
}
```

**Target (ArkTS):**
```typescript
class DataManager {
  async fetchData(): Promise<Item[]> {
    return await this.api.getItems()
  }

  loadData(): void {
    this.fetchData()
      .then((items: Item[]) => {
        this.updateUI(items)
      })
      .catch((error: Error) => {
        this.handleError(error)
      })
  }
}
```

**Notes:**
- `CoroutineScope` / `Dispatchers` → No direct equivalent; HarmonyOS manages threading
- `suspend fun` → `async` function returning `Promise<T>`
- `withContext(Dispatchers.IO)` → Not needed; use `@ohos.taskpool` for CPU-intensive work
- `launch { }` → Call async function with `.then().catch()` or use `async/await`
- `Flow<T>` → Use callback patterns or HarmonyOS `Emitter`

---

### RULE-LT-008: Collections and Functional Operations

| Kotlin | ArkTS | Notes |
|---|---|---|
| `list.map { }` | `list.map((item) => { })` | Arrow function syntax |
| `list.filter { }` | `list.filter((item) => { })` | |
| `list.forEach { }` | `list.forEach((item) => { })` | |
| `list.find { }` | `list.find((item) => { })` | |
| `list.any { }` | `list.some((item) => { })` | Different name |
| `list.all { }` | `list.every((item) => { })` | Different name |
| `list.flatMap { }` | `list.flatMap((item) => { })` | |
| `list.sortedBy { it.name }` | `list.sort((a, b) => a.name.localeCompare(b.name))` | Mutates in place |
| `list.groupBy { }` | Manual implementation | No built-in groupBy |
| `list.associate { }` | `new Map(list.map(i => [key, val]))` | |
| `listOf(1, 2, 3)` | `[1, 2, 3]` | Array literal |
| `mutableListOf()` | `let arr: T[] = []` | |
| `mapOf("a" to 1)` | `new Map([["a", 1]])` | |

**Notes:**
- Kotlin `it` → ArkTS requires explicit parameter name
- Kotlin lambda `{ x -> expr }` → ArkTS arrow function `(x) => expr`
- Kotlin `list.sorted()` returns new list; ArkTS `list.sort()` mutates — use `[...list].sort()` for non-mutating

---

### RULE-LT-009: Interfaces and Abstract Classes

**Source (Kotlin):**
```kotlin
interface Repository<T> {
    suspend fun getAll(): List<T>
    suspend fun getById(id: Long): T?
    fun getCount(): Int = 0  // Default implementation
}
```

**Target (ArkTS):**
```typescript
interface Repository<T> {
  getAll(): Promise<T[]>
  getById(id: number): Promise<T | null>
}

// Default implementations via abstract class
abstract class BaseRepository<T> implements Repository<T> {
  abstract getAll(): Promise<T[]>
  abstract getById(id: number): Promise<T | null>

  getCount(): number {
    return 0
  }
}
```

**Notes:**
- Kotlin interfaces with default methods → ArkTS interface + abstract class
- ArkTS interfaces cannot have method implementations
- Kotlin `override` keyword → Not required in ArkTS but good practice to comment

---

### RULE-LT-010: Error Handling

**Source (Kotlin):**
```kotlin
try {
    val result = riskyOperation()
} catch (e: IOException) {
    handleIO(e)
} catch (e: Exception) {
    handleGeneral(e)
} finally {
    cleanup()
}
```

**Target (ArkTS):**
```typescript
try {
  let result = riskyOperation()
} catch (error) {
  if (error instanceof Error) {
    // No multi-catch — use instanceof checks
    handleGeneral(error)
  }
} finally {
  cleanup()
}
```

**Notes:**
- ArkTS has a single `catch` block — use `instanceof` for type checking
- Kotlin `runCatching { }` → ArkTS try/catch wrapper or custom Result type
- HarmonyOS APIs often use error codes via `BusinessError` — check API docs

---

## Anti-Patterns

### DO NOT: Use `any` Type
```typescript
// WRONG — ArkTS restricts `any`
let data: any = fetchData()

// CORRECT — Use proper types
let data: UserData = fetchData()
```

### DO NOT: Use Java-Style Getters/Setters
```typescript
// WRONG — Unnecessary boilerplate
class User {
  private _name: string = ''
  getName(): string { return this._name }
  setName(name: string): void { this._name = name }
}

// CORRECT — Use direct properties (ArkTS is not Java)
class User {
  name: string = ''
}
```

### DO NOT: Translate Android Context
```typescript
// WRONG — No Android Context in HarmonyOS
function doSomething(context: Context) { ... }

// CORRECT — Use HarmonyOS Ability context or UIAbilityContext
import { common } from '@kit.AbilityKit'
function doSomething(context: common.UIAbilityContext) { ... }
```

### DO NOT: Use Structural Typing Assumptions
```typescript
// WRONG — ArkTS restricts structural typing for classes
let obj: MyClass = { field1: "value", field2: 42 }

// CORRECT — Use constructor
let obj: MyClass = new MyClass("value", 42)
```

---

## Verification Checklist

- [ ] All `val`/`var` converted to `const`/`let` with type annotations
- [ ] Nullable types use `T | null` (not `T?`)
- [ ] String templates use backtick syntax `` `${}` ``
- [ ] `suspend` functions are `async` returning `Promise<T>`
- [ ] No `any` type used anywhere
- [ ] Collection operations use correct ArkTS names (`some`, `every`, `find`)
- [ ] Lambda syntax uses arrow functions `(x) => expr`
- [ ] Data classes have explicit constructors
- [ ] Sealed classes converted to discriminated unions
- [ ] Error handling uses single catch with instanceof checks
- [ ] Import paths use `@ohos/` or `@kit.` format
- [ ] No extension functions — converted to utility functions
- [ ] No `lateinit` — all properties initialized
