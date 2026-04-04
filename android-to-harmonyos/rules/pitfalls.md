---
title: "Common Migration Pitfalls — Android → HarmonyOS"
migration_path: android-to-harmonyos
category: pitfalls
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: beginner
---

# Common Migration Pitfalls — Android → HarmonyOS

## Context

This rule set catalogs the most frequently encountered mistakes when migrating Android applications to HarmonyOS. Each pitfall includes the symptom, root cause, and correct approach. Consult this when debugging migration issues or as a pre-flight checklist before testing converted code.

---

## Pitfalls

### PITFALL-001: Placing Method Chains Before the Build Block

**Symptom:** Compilation error or unexpected layout behavior.

```typescript
// WRONG — methods before the content block
Column().width('100%').padding(16) {
  Text('Hello')
}

// CORRECT — methods AFTER the content block
Column() {
  Text('Hello')
}
.width('100%')
.padding(16)
```

**Why:** ArkUI requires the build block (content closure) immediately after the constructor call. Method chains must follow the closing brace.

---

### PITFALL-002: Missing ForEach Key Generator

**Symptom:** List renders incorrectly, items flicker on state update, or unexpected reordering.

```typescript
// WRONG — no key generator (second function argument)
ForEach(this.items, (item: Item) => {
  ListItem() { Text(item.name) }
})

// CORRECT — always provide a unique key generator
ForEach(this.items, (item: Item) => {
  ListItem() { Text(item.name) }
}, (item: Item) => item.id.toString())
```

**Why:** Without a key generator, ArkUI cannot efficiently diff the list and may recreate all items on every state change.

---

### PITFALL-003: Using `any` Type

**Symptom:** ArkTS compilation error — `any` type is restricted.

```typescript
// WRONG
let data: any = JSON.parse(response)

// CORRECT — define a proper type or interface
interface ApiResponse {
  id: number
  name: string
}
let data: ApiResponse = JSON.parse(response) as ApiResponse
```

**Why:** ArkTS enforces stricter typing than standard TypeScript. The `any` type is restricted to prevent runtime errors and improve performance.

---

### PITFALL-004: Forgetting @Entry on Navigation Target Pages

**Symptom:** Runtime crash when navigating — `router.pushUrl` fails silently or throws an error.

```typescript
// WRONG — missing @Entry
@Component
struct DetailPage {
  build() { ... }
}

// CORRECT — @Entry required for pages that are navigation targets
@Entry
@Component
struct DetailPage {
  build() { ... }
}
```

**Why:** Only `@Entry` decorated components can be loaded as standalone pages via `router.pushUrl()`. Without it, the page cannot be found.

---

### PITFALL-005: Treating State as Deeply Reactive

**Symptom:** UI does not update when modifying nested object properties.

```typescript
// WRONG — nested property change not detected
@State user: User = new User('John', new Address('NYC'))

updateCity() {
  this.user.address.city = 'LA'  // UI will NOT update
}

// CORRECT — use @Observed class + @ObjectLink, or replace the entire object
@Observed
class User {
  name: string
  address: Address
  constructor(name: string, address: Address) {
    this.name = name
    this.address = address
  }
}

@Observed
class Address {
  city: string
  constructor(city: string) { this.city = city }
}

// Option A: With @ObjectLink in child component
@Component
struct AddressView {
  @ObjectLink address: Address
  build() {
    Text(this.address.city)  // Will update reactively
  }
}

// Option B: Replace the entire object
updateCity() {
  this.user = new User(this.user.name, new Address('LA'))
}
```

**Why:** `@State` only observes first-level property assignments. Nested property mutations are not tracked unless the nested class is `@Observed` and accessed via `@ObjectLink`.

---

### PITFALL-006: Not Destroying HTTP Request Objects

**Symptom:** Memory leaks, connection pool exhaustion, app becomes unresponsive after many API calls.

```typescript
// WRONG — never destroyed
async function fetchData() {
  const req = http.createHttp()
  const res = await req.request(url, options)
  return res.result  // req leaks!
}

// CORRECT — always destroy
async function fetchData() {
  const req = http.createHttp()
  try {
    const res = await req.request(url, options)
    return res.result
  } finally {
    req.destroy()
  }
}
```

---

### PITFALL-007: Synchronous Operations in build()

**Symptom:** UI freezes, janky scrolling, ANR-like behavior.

```typescript
// WRONG — file I/O in build method
build() {
  const data = fileIo.readSync(filePath)  // Blocks UI thread!
  Text(data)
}

// CORRECT — load asynchronously in lifecycle method
@State data: string = ''

aboutToAppear() {
  this.loadData()
}

async loadData() {
  const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
  // ... async read
  this.data = content
}
```

**Why:** The `build()` method runs on the UI thread and must return quickly. All I/O, network, and heavy computation should happen in lifecycle methods or async functions.

---

### PITFALL-008: Incorrect Resource Reference Format

**Symptom:** Images or strings don't load, blank spaces in UI.

```typescript
// WRONG — Android-style resource reference
Image(R.drawable.icon)
Text(getString(R.string.hello))

// WRONG — incorrect prefix
Image($r('drawable.icon'))

// CORRECT — HarmonyOS resource format
Image($r('app.media.icon'))
Text($r('app.string.hello'))
```

**Resource prefixes:**
- `app.media.xxx` — images and icons (from `resources/base/media/`)
- `app.string.xxx` — strings (from `resources/base/element/string.json`)
- `app.color.xxx` — colors
- `app.float.xxx` — dimensions
- `sys.color.xxx` — system theme colors
- `sys.media.xxx` — system icons

---

### PITFALL-009: Forgetting to Register Pages in main_pages.json

**Symptom:** Navigation crash — `router.pushUrl` error stating the page doesn't exist.

```json5
// WRONG — DetailPage not registered
{
  "src": [
    "pages/Index"
  ]
}

// CORRECT — all navigable pages listed
{
  "src": [
    "pages/Index",
    "pages/Detail",
    "pages/Settings"
  ]
}
```

---

### PITFALL-010: Using Object Literals for Class Instances

**Symptom:** ArkTS compilation error — structural typing is restricted for classes.

```typescript
class User {
  name: string = ''
  age: number = 0
}

// WRONG — ArkTS restricts structural typing for classes
let user: User = { name: 'John', age: 30 }

// CORRECT — use constructor
let user: User = new User()
user.name = 'John'
user.age = 30

// Or add a constructor
class User {
  name: string
  age: number
  constructor(name: string, age: number) {
    this.name = name
    this.age = age
  }
}
let user: User = new User('John', 30)
```

---

### PITFALL-011: Android Context Usage

**Symptom:** Compilation error — no `Context` class available.

```typescript
// WRONG — Android Context doesn't exist
function init(context: Context) { ... }

// CORRECT — use HarmonyOS context types
import { common } from '@kit.AbilityKit'

function init(context: common.UIAbilityContext) { ... }

// Or in a component
const context = getContext(this) as common.UIAbilityContext
```

---

### PITFALL-012: Async Preferences Without Await

**Symptom:** Data reads return Promise objects instead of values; writes don't persist.

```typescript
// WRONG — missing await
const name = store.get('name', '')  // Returns Promise, not string!
store.put('name', 'John')           // Write might not complete
store.flush()                        // Flush might not complete

// CORRECT — await every operation
const name = await store.get('name', '') as string
await store.put('name', 'John')
await store.flush()
```

---

## Quick Reference: Most Common Mistakes

| # | Mistake | Fix |
|---|---|---|
| 1 | Method chains before build block | Move chains after closing `}` |
| 2 | Missing ForEach key generator | Add third argument to ForEach |
| 3 | Using `any` type | Define proper interfaces/types |
| 4 | Missing `@Entry` on pages | Add `@Entry` to navigation targets |
| 5 | Expecting deep state reactivity | Use `@Observed` + `@ObjectLink` |
| 6 | HTTP request not destroyed | Always `destroy()` in `finally` |
| 7 | Sync I/O in `build()` | Load data in `aboutToAppear()` |
| 8 | Wrong resource prefix | Use `app.media.`, `app.string.` etc. |
| 9 | Unregistered pages | Add to `main_pages.json` |
| 10 | Object literals for classes | Use `new Constructor()` |
