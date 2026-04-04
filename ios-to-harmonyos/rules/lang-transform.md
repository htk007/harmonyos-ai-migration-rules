---
title: "Swift → ArkTS Language Transformations"
migration_path: ios-to-harmonyos
category: lang-transform
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Swift → ArkTS Language Transformation Rules

## Context

This rule set defines how to convert iOS Swift language constructs to HarmonyOS ArkTS. Swift and ArkTS share several modern language features (optionals, type inference, closures), but differ fundamentally in type system philosophy, memory management, and module structure. Apply these rules when converting Swift source files containing business logic, data models, networking, and utility code.

## Key Differences

- Swift uses value types extensively (`struct`); ArkTS uses `class` for reactive objects
- Swift optionals (`T?`) → ArkTS union types (`T | null`)
- Swift `guard let` / `if let` → ArkTS null checks with type narrowing
- Swift protocols → ArkTS interfaces (no default implementations in interfaces)
- Swift extensions → standalone utility functions
- Swift `async/await` → ArkTS `async/await` with `Promise<T>` (very similar)

---

## Rules

### RULE-LT-001: Basic Types

| Swift | ArkTS | Notes |
|---|---|---|
| `Int` | `number` | No separate integer type in ArkTS |
| `Double` / `Float` / `CGFloat` | `number` | All numeric types → `number` |
| `Bool` | `boolean` | |
| `String` | `string` | Lowercase |
| `Character` | `string` | Single char is still `string` |
| `[T]` / `Array<T>` | `T[]` or `Array<T>` | |
| `[K: V]` / `Dictionary<K,V>` | `Map<K,V>` | |
| `Set<T>` | `Set<T>` | |
| `Void` | `void` | |
| `Never` | `never` | |
| `Any` / `AnyObject` | `Object` | Not `any` — ArkTS restricts it |
| `Data` | `ArrayBuffer` or `Uint8Array` | |
| `Date` | `Date` | Same name, slightly different API |
| `URL` | `string` | No URL type — use plain string |
| `(T, U)` (tuple) | `[T, U]` or interface | Tuples → arrays or named interfaces |

---

### RULE-LT-002: Optionals and Null Safety

**Source (Swift):**
```swift
var name: String? = nil
let length = name?.count ?? 0
let forced = name!

// guard let (early return)
guard let unwrapped = name else { return }
print(unwrapped)

// if let (conditional binding)
if let unwrapped = name {
    print(unwrapped)
}

// Optional chaining with method call
let uppercased = name?.uppercased()
```

**Target (ArkTS):**
```typescript
let name: string | null = null
let length: number = name?.length ?? 0
let forced: string = name!

// guard let → null check with early return
if (name === null) { return }
// name is narrowed to string after this point
console.info(name)

// if let → null check
if (name !== null) {
  console.info(name)
}

// Optional chaining
let uppercased: string | undefined = name?.toUpperCase()
```

**Key Mappings:**
- `T?` → `T | null`
- `?.` → `?.` (same syntax)
- `??` → `??` (same syntax)
- `!` (force unwrap) → `!` (non-null assertion)
- `guard let x = y else { return }` → `if (y === null) { return }`
- `if let x = y { }` → `if (y !== null) { }`
- Swift distinguishes `nil` only; ArkTS has both `null` and `undefined`

---

### RULE-LT-003: Variable Declarations

| Swift | ArkTS | Notes |
|---|---|---|
| `let x = 5` | `const x: number = 5` | Immutable |
| `var x = 5` | `let x: number = 5` | Mutable |
| `lazy var x = compute()` | Initialize in `aboutToAppear()` | No lazy properties |
| `static let x = 5` | `static readonly x: number = 5` | Inside class |

**Notes:**
- Swift `let` (immutable) → ArkTS `const`
- Swift `var` (mutable) → ArkTS `let`
- ArkTS requires explicit type annotations in most contexts
- No `lazy` keyword — initialize eagerly or in lifecycle methods

---

### RULE-LT-004: Functions and Closures

**Source (Swift):**
```swift
func greet(name: String, greeting: String = "Hello") -> String {
    return "\(greeting), \(name)!"
}

// Trailing closure
let sorted = names.sorted { $0 < $1 }

// Closure with explicit types
let transform: (String) -> Int = { str in
    return str.count
}

// Shorthand arguments
let doubled = numbers.map { $0 * 2 }
```

**Target (ArkTS):**
```typescript
function greet(name: string, greeting: string = "Hello"): string {
  return `${greeting}, ${name}!`
}

// Trailing closure → arrow function
let sorted: string[] = names.sort((a, b) => a.localeCompare(b))

// Closure → arrow function with types
let transform: (str: string) => number = (str: string): number => {
  return str.length
}

// Shorthand → explicit parameter
let doubled: number[] = numbers.map((n) => n * 2)
```

**Key Mappings:**
- `func name() -> T` → `function name(): T`
- String interpolation: `"\(expr)"` → `` `${expr}` ``
- Trailing closures → arrow functions passed as arguments
- `$0`, `$1` shorthand → explicit parameter names required
- Swift `{ }` closures → `() => {}` arrow functions
- Named arguments not supported — use positional or option objects

---

### RULE-LT-005: Structs, Classes, and Enums

**Source (Swift):**
```swift
struct User {
    let id: Int
    var name: String
    var email: String?

    func displayName() -> String {
        return email != nil ? "\(name) (\(email!))" : name
    }
}

// Value type usage
var user = User(id: 1, name: "John", email: nil)
var copy = user  // independent copy
copy.name = "Jane"  // doesn't affect `user`
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

  displayName(): string {
    return this.email !== null ? `${this.name} (${this.email})` : this.name
  }
}

// Class is reference type — clone manually if value semantics needed
let user = new User(1, 'John', null)
let copy = new User(user.id, user.name, user.email)
copy.name = 'Jane'
```

**Notes:**
- Swift `struct` (value type) → ArkTS `class` (reference type). If value semantics are needed, clone manually.
- Use `@Observed` when the class will be used in UI state
- Swift memberwise initializer is automatic; ArkTS needs explicit `constructor()`
- `self.` → `this.`

---

### RULE-LT-006: Enums

**Source (Swift):**
```swift
enum NetworkError: Error {
    case noConnection
    case timeout(seconds: Int)
    case serverError(code: Int, message: String)
}

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

// Pattern matching
switch state {
case .idle:
    print("Idle")
case .loading:
    print("Loading...")
case .success(let data):
    print("Got \(data)")
case .failure(let error):
    print("Error: \(error)")
}
```

**Target (ArkTS):**
```typescript
// Simple enum (no associated values)
// → standard ArkTS enum
enum NetworkErrorType {
  NO_CONNECTION,
  TIMEOUT,
  SERVER_ERROR
}

// Enum with associated values → discriminated union
interface NetworkErrorNoConnection {
  type: 'noConnection'
}
interface NetworkErrorTimeout {
  type: 'timeout'
  seconds: number
}
interface NetworkErrorServer {
  type: 'serverError'
  code: number
  message: string
}
type NetworkError = NetworkErrorNoConnection | NetworkErrorTimeout | NetworkErrorServer

// Generic enum with associated values → discriminated union
interface StateIdle { type: 'idle' }
interface StateLoading { type: 'loading' }
interface StateSuccess<T> { type: 'success'; data: T }
interface StateFailure { type: 'failure'; error: Error }
type LoadingState<T> = StateIdle | StateLoading | StateSuccess<T> | StateFailure

// Pattern matching → switch on type field
switch (state.type) {
  case 'idle':
    console.info('Idle')
    break
  case 'loading':
    console.info('Loading...')
    break
  case 'success':
    console.info(`Got ${(state as StateSuccess<string>).data}`)
    break
  case 'failure':
    console.info(`Error: ${(state as StateFailure).error.message}`)
    break
}
```

---

### RULE-LT-007: Protocols → Interfaces

**Source (Swift):**
```swift
protocol Repository {
    associatedtype Item
    func getAll() async throws -> [Item]
    func getById(_ id: Int) async throws -> Item?
}

protocol Displayable {
    var displayTitle: String { get }
    func formattedDescription() -> String
}

// Default implementation via extension
extension Displayable {
    func formattedDescription() -> String {
        return "[\(displayTitle)]"
    }
}
```

**Target (ArkTS):**
```typescript
// Protocol → interface (no associated types — use generics)
interface Repository<Item> {
  getAll(): Promise<Item[]>
  getById(id: number): Promise<Item | null>
}

interface Displayable {
  displayTitle: string
  formattedDescription(): string
}

// Default implementation → abstract class
abstract class BaseDisplayable implements Displayable {
  abstract displayTitle: string

  formattedDescription(): string {
    return `[${this.displayTitle}]`
  }
}
```

**Notes:**
- `protocol` → `interface`
- `associatedtype` → generic type parameter `<T>`
- Protocol extensions with default implementations → abstract class
- `async throws` → `async` returning `Promise<T>` (errors via try/catch)

---

### RULE-LT-008: Error Handling

**Source (Swift):**
```swift
enum AppError: Error {
    case notFound
    case unauthorized(reason: String)
}

func fetchUser(id: Int) async throws -> User {
    guard id > 0 else { throw AppError.notFound }
    return try await api.getUser(id)
}

do {
    let user = try await fetchUser(id: 123)
    print(user.name)
} catch AppError.unauthorized(let reason) {
    print("Unauthorized: \(reason)")
} catch {
    print("Error: \(error)")
}
```

**Target (ArkTS):**
```typescript
class AppError extends Error {
  code: 'notFound' | 'unauthorized'
  reason: string

  constructor(code: 'notFound' | 'unauthorized', reason: string = '') {
    super(reason)
    this.code = code
    this.reason = reason
  }
}

async function fetchUser(id: number): Promise<User> {
  if (id <= 0) {
    throw new AppError('notFound')
  }
  return await api.getUser(id)
}

try {
  const user = await fetchUser(123)
  console.info(user.name)
} catch (error) {
  if (error instanceof AppError && error.code === 'unauthorized') {
    console.info(`Unauthorized: ${error.reason}`)
  } else {
    console.info(`Error: ${(error as Error).message}`)
  }
}
```

---

### RULE-LT-009: Async/Await and Concurrency

**Source (Swift):**
```swift
func loadDashboard() async throws -> Dashboard {
    async let profile = fetchProfile()
    async let posts = fetchPosts()
    async let notifications = fetchNotifications()

    return Dashboard(
        profile: try await profile,
        posts: try await posts,
        notifications: try await notifications
    )
}

// Task group
func fetchAllUsers(ids: [Int]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask { try await fetchUser(id: id) }
        }
        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

**Target (ArkTS):**
```typescript
async function loadDashboard(): Promise<Dashboard> {
  // Parallel execution with Promise.all
  const [profile, posts, notifications] = await Promise.all([
    fetchProfile(),
    fetchPosts(),
    fetchNotifications()
  ])

  return new Dashboard(profile, posts, notifications)
}

// Task group → Promise.all
async function fetchAllUsers(ids: number[]): Promise<User[]> {
  return await Promise.all(
    ids.map((id) => fetchUser(id))
  )
}
```

**Key Mappings:**
- `async let` + `await` (structured concurrency) → `Promise.all()`
- `withThrowingTaskGroup` → `Promise.all()` or `Promise.allSettled()`
- `Task { }` → standalone `async` call or `.then()`
- `@MainActor` → not needed (UI updates happen automatically with `@State`)

---

### RULE-LT-010: Extensions → Utility Functions

**Source (Swift):**
```swift
extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    func truncated(to length: Int) -> String {
        if self.count <= length { return self }
        return String(self.prefix(length)) + "..."
    }
}
```

**Target (ArkTS):**
```typescript
// No extensions — use utility functions
function isValidEmail(str: string): boolean {
  const regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
  return regex.test(str)
}

function truncated(str: string, length: number): string {
  if (str.length <= length) return str
  return str.substring(0, length) + '...'
}

// Usage: isValidEmail(myString) instead of myString.isValidEmail
```

---

## Anti-Patterns

### DO NOT: Use Swift-Style Optional Binding
```typescript
// WRONG — no if-let in ArkTS
if let name = user.name {
  console.info(name)
}

// CORRECT — null check
if (user.name !== null) {
  console.info(user.name)
}
```

### DO NOT: Expect Value Type Semantics from Classes
```typescript
// WRONG — expecting struct copy behavior
let userA = new User(1, 'John')
let userB = userA      // This is a REFERENCE, not a copy
userB.name = 'Jane'    // Also changes userA.name!

// CORRECT — explicit clone if needed
let userB = new User(userA.id, userA.name)
```

### DO NOT: Use Self/Type References Like Swift
```typescript
// WRONG
class MyClass {
  static func create() -> Self { ... }
  func copy() -> Self { ... }
}

// CORRECT — use explicit type name
class MyClass {
  static create(): MyClass { return new MyClass() }
  copy(): MyClass { return new MyClass() }
}
```

---

## Verification Checklist

- [ ] All `let` (immutable) → `const`, `var` (mutable) → `let`
- [ ] Optionals `T?` → `T | null` with explicit union types
- [ ] `guard let` / `if let` converted to null checks
- [ ] String interpolation `"\(x)"` → `` `${x}` ``
- [ ] Structs converted to classes with `@Observed` where needed
- [ ] Swift enums with associated values → discriminated unions
- [ ] Protocols → interfaces (default impls → abstract classes)
- [ ] `async/await` preserved, `throws` → try/catch with Promise
- [ ] `async let` parallel calls → `Promise.all()`
- [ ] Extensions → standalone utility functions
- [ ] No `any`/`AnyObject` — all types explicit
- [ ] Import paths use `@kit.*` or `@ohos.*` format
