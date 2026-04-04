---
title: "Jetpack Compose / XML → ArkUI Component Transformations"
migration_path: android-to-harmonyos
category: ui-components
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Jetpack Compose / XML → ArkUI Component Transformation Rules

## Context

This rule set defines how to convert Android UI code — both Jetpack Compose and legacy XML layouts — to HarmonyOS ArkUI declarative UI. Both Compose and ArkUI are declarative frameworks, but they differ in component model (functions vs structs), state management (remember vs decorators), and styling (Modifier chain vs method chain). Apply these rules when converting any screen, component, or layout file.

## Core Principles

- ArkUI uses struct-based components with `@Component` decorator; Compose uses `@Composable` functions
- ArkUI requires a `build()` method that defines the render tree
- Compose `remember { mutableStateOf() }` → ArkUI `@State` decorator
- Compose `Modifier` chain → ArkUI method chaining after component closure

---

## Rules

### RULE-UI-001: Basic Component Structure

**Source (Compose):**
```kotlin
@Composable
fun Greeting(name: String) {
    Text(text = "Hello $name!")
}
```

**Source (XML):**
```xml
<TextView
    android:id="@+id/greeting"
    android:text="Hello World!"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" />
```

**Target (ArkUI):**
```typescript
@Component
struct Greeting {
  @Prop name: string

  build() {
    Text(`Hello ${this.name}!`)
  }
}
```

**Mapping:**
- `@Composable fun` → `@Component struct`
- Function parameters → `@Prop` or `@State` decorated properties
- Function body → `build()` method
- String interpolation: `$variable` → `${this.variable}`
- Always use `this.` to access properties inside `build()`
- XML `TextView` → `Text()` component

---

### RULE-UI-002: Layout Containers

| Compose | XML | ArkUI | Notes |
|---|---|---|---|
| `Column { }` | `LinearLayout (vertical)` | `Column() { }` | Parentheses required in ArkUI |
| `Row { }` | `LinearLayout (horizontal)` | `Row() { }` | |
| `Box { }` | `FrameLayout` | `Stack() { }` | Overlay/stacking behavior |
| `LazyColumn { }` | `RecyclerView` | `List() { }` | See RULE-UI-004 |
| `LazyRow { }` | `RecyclerView (horizontal)` | `List().listDirection(Axis.Horizontal)` | |
| `Spacer()` | `Space` | `Blank()` | |
| `Surface { }` | `CardView` | `Column()` + styling | No direct Surface equivalent |
| `Scaffold { }` | `CoordinatorLayout` | Custom struct composition | Build manually |
| N/A | `ConstraintLayout` | `RelativeContainer()` | |
| N/A | `ScrollView` | `Scroll() { }` | |

**Source (Compose):**
```kotlin
Column(
    modifier = Modifier
        .fillMaxWidth()
        .padding(16.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp),
    horizontalAlignment = Alignment.CenterHorizontally
) {
    Text("Title")
    Text("Subtitle")
}
```

**Target (ArkUI):**
```typescript
Column({ space: 8 }) {
  Text('Title')
  Text('Subtitle')
}
.width('100%')
.padding(16)
.alignItems(HorizontalAlign.Center)
```

**Key Mappings:**
- `Modifier.fillMaxWidth()` → `.width('100%')`
- `Modifier.fillMaxHeight()` → `.height('100%')`
- `Modifier.fillMaxSize()` → `.width('100%').height('100%')`
- `Modifier.padding(X.dp)` → `.padding(X)` (vp units, approximately equal to dp)
- `Arrangement.spacedBy(X.dp)` → `{ space: X }` in constructor
- `Alignment.CenterHorizontally` → `.alignItems(HorizontalAlign.Center)`
- Modifier chain → method chaining after the closing brace

---

### RULE-UI-003: State Management

| Compose | ArkUI | Use Case |
|---|---|---|
| `remember { mutableStateOf(x) }` | `@State variable: Type = x` | Component-local mutable state |
| `rememberSaveable { }` | `@State` + `PersistentStorage` | State that survives config changes |
| Function parameter | `@Prop variable: Type` | One-way data from parent (copied) |
| Callback parameter | `@Link variable: Type` | Two-way binding with parent |
| `CompositionLocalProvider` | `@Provide` / `@Consume` | Passing data deep without prop drilling |
| `derivedStateOf { }` | Getter or `@Watch` | Computed values |
| `LaunchedEffect(key) { }` | `aboutToAppear()` + async calls | Side effects on appear |
| `DisposableEffect { }` | `aboutToDisappear()` | Cleanup on removal |

**Source (Compose):**
```kotlin
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }
    val isEven by remember { derivedStateOf { count % 2 == 0 } }

    Column {
        Text("Count: $count (${if (isEven) "even" else "odd"})")
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}
```

**Target (ArkUI):**
```typescript
@Component
struct Counter {
  @State count: number = 0

  get isEven(): boolean {
    return this.count % 2 === 0
  }

  build() {
    Column() {
      Text(`Count: ${this.count} (${this.isEven ? 'even' : 'odd'})`)
      Button('Increment')
        .onClick(() => {
          this.count++
        })
    }
  }
}
```

**Notes:**
- State changes automatically trigger re-render in both frameworks
- `@State` only tracks the first level of object properties — for nested objects use `@Observed` class + `@ObjectLink`
- `Button` text goes in the constructor in ArkUI; in Compose it's a content lambda

---

### RULE-UI-004: Lists and Scrollable Content

**Source (Compose):**
```kotlin
@Composable
fun UserList(users: List<User>) {
    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(users, key = { it.id }) { user ->
            UserCard(user = user)
        }
    }
}
```

**Source (XML + Adapter):**
```xml
<androidx.recyclerview.widget.RecyclerView
    android:id="@+id/recyclerView"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
```

**Target (ArkUI):**
```typescript
@Component
struct UserList {
  @Prop users: User[]

  build() {
    List({ space: 8 }) {
      ForEach(this.users, (user: User) => {
        ListItem() {
          UserCard({ user: user })
        }
      }, (user: User) => user.id.toString())
    }
    .padding(16)
    .width('100%')
  }
}
```

**Critical Rules:**
- `LazyColumn { items() }` → `List() { ForEach() { ListItem() } }`
- `ForEach` requires a **key generator** as the third argument — this is mandatory
- Every item inside `List` must be wrapped in `ListItem() { }`
- `items(list, key = { it.id })` → key generator function: `(item) => item.id.toString()`
- `RecyclerView` + `Adapter` → `List()` + `ForEach()` (no adapter needed)

---

### RULE-UI-005: Common UI Components

| Compose | XML | ArkUI | Notes |
|---|---|---|---|
| `Text("hello")` | `TextView` | `Text('hello')` | |
| `Image(painter)` | `ImageView` | `Image(src)` | src can be resource or URL |
| `Button(onClick) { Text() }` | `Button` | `Button('label').onClick()` | Label in constructor |
| `TextField(value, onValueChange)` | `EditText` | `TextInput({ text: val }).onChange()` | |
| `Switch(checked, onCheckedChange)` | `Switch` | `Toggle({ isOn: val }).onChange()` | |
| `Checkbox(checked, onCheckedChange)` | `CheckBox` | `Checkbox({ isChecked: val })` | |
| `Slider(value, onValueChange)` | `SeekBar` | `Slider({ value: val }).onChange()` | |
| `CircularProgressIndicator()` | `ProgressBar` | `LoadingProgress()` | |
| `LinearProgressIndicator(progress)` | `ProgressBar (horizontal)` | `Progress({ value: x, total: 100 })` | |
| `Divider()` | `View (1dp height)` | `Divider()` | |
| `Icon(imageVector)` | `ImageView` | `Image($r('sys.media.xxx'))` | System icons via resources |
| `AlertDialog` | `AlertDialog` | `AlertDialog.show()` | |

**TextField Example:**

**Source (Compose):**
```kotlin
@Composable
fun SearchBar() {
    var query by remember { mutableStateOf("") }

    TextField(
        value = query,
        onValueChange = { query = it },
        placeholder = { Text("Search...") },
        modifier = Modifier.fillMaxWidth()
    )
}
```

**Target (ArkUI):**
```typescript
@Component
struct SearchBar {
  @State query: string = ''

  build() {
    TextInput({ placeholder: 'Search...', text: this.query })
      .onChange((value: string) => {
        this.query = value
      })
      .width('100%')
  }
}
```

---

### RULE-UI-006: Styling and Theming

| Compose Modifier | ArkUI Method | Notes |
|---|---|---|
| `.background(Color.Red)` | `.backgroundColor('#FF0000')` | Use hex or `$r('sys.color.xxx')` |
| `.clip(RoundedCornerShape(8.dp))` | `.borderRadius(8)` | |
| `.border(1.dp, Color.Gray)` | `.border({ width: 1, color: Color.Gray })` | Object syntax |
| `.shadow(elevation = 4.dp)` | `.shadow({ radius: 4, color: '#33000000' })` | |
| `.alpha(0.5f)` | `.opacity(0.5)` | |
| `.clickable { }` | `.onClick(() => { })` | |
| `.size(48.dp)` | `.width(48).height(48)` | No combined size method |
| `.weight(1f)` | `.layoutWeight(1)` | Inside Row/Column |
| `.wrapContentWidth()` | Omit width | Default is wrap content |
| `.aspectRatio(1f)` | `.aspectRatio(1)` | |

**Card Example:**

**Source (Compose):**
```kotlin
Card(
    modifier = Modifier
        .fillMaxWidth()
        .padding(8.dp),
    elevation = CardDefaults.cardElevation(4.dp),
    shape = RoundedCornerShape(12.dp)
) {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("Card Title", style = MaterialTheme.typography.headlineSmall)
        Text("Card description goes here")
    }
}
```

**Target (ArkUI):**
```typescript
Column() {
  Text('Card Title')
    .fontSize(20)
    .fontWeight(FontWeight.Bold)
  Text('Card description goes here')
    .fontSize(14)
    .fontColor('#666666')
}
.width('100%')
.padding(16)
.margin(8)
.borderRadius(12)
.shadow({ radius: 4, color: '#33000000', offsetX: 0, offsetY: 2 })
.backgroundColor(Color.White)
```

**Notes:**
- No `Card` component in ArkUI — compose with `Column` + styling
- `MaterialTheme.typography.xxx` → explicit `.fontSize()` and `.fontWeight()`
- Use `$r('sys.color.ohos_id_color_primary')` for system theme colors
- HarmonyOS resource references: `$r('app.color.xxx')` for app colors, `$r('sys.color.xxx')` for system

---

### RULE-UI-007: Navigation

**Source (Compose Navigation):**
```kotlin
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen(navController) }
    composable("detail/{id}") { backStackEntry ->
        DetailScreen(id = backStackEntry.arguments?.getString("id"))
    }
}

// Navigating:
navController.navigate("detail/$itemId")
```

**Target (ArkUI Router):**
```typescript
// 1. Register pages in src/main/resources/base/profile/main_pages.json:
{
  "src": [
    "pages/Home",
    "pages/Detail"
  ]
}

// 2. Navigate:
import { router } from '@kit.ArkUI'

router.pushUrl({
  url: 'pages/Detail',
  params: { id: itemId }
})

// 3. Receive params in Detail page:
@Entry
@Component
struct Detail {
  @State id: string = ''

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    this.id = params?.['id'] ?? ''
  }

  build() {
    // ... use this.id
  }
}
```

**Key Differences:**
- Compose: route-based strings with path params → ArkUI: page file paths with params object
- `navController.navigate()` → `router.pushUrl()`
- `navController.popBackStack()` → `router.back()`
- `@Entry` decorator is required on pages that serve as navigation targets
- Page list must be declared in `main_pages.json`

---

### RULE-UI-008: Images and Resources

**Source (Compose):**
```kotlin
// Resource image
Image(
    painter = painterResource(id = R.drawable.logo),
    contentDescription = "Logo",
    modifier = Modifier.size(48.dp)
)

// Network image (Coil)
AsyncImage(
    model = imageUrl,
    contentDescription = "Photo"
)
```

**Target (ArkUI):**
```typescript
// Resource image
Image($r('app.media.logo'))
  .width(48)
  .height(48)
  .alt('Logo')  // Accessibility

// Network image (built-in support)
Image(imageUrl)
  .width('100%')
  .objectFit(ImageFit.Cover)
```

**Notes:**
- `R.drawable.xxx` → `$r('app.media.xxx')` — resources live in `resources/base/media/`
- No third-party library needed for network images — `Image()` handles URLs natively
- `ContentScale.Crop` → `.objectFit(ImageFit.Cover)`
- `ContentScale.Fit` → `.objectFit(ImageFit.Contain)`

---

### RULE-UI-009: Dialogs and Bottom Sheets

**Source (Compose):**
```kotlin
var showDialog by remember { mutableStateOf(false) }

if (showDialog) {
    AlertDialog(
        onDismissRequest = { showDialog = false },
        title = { Text("Confirm") },
        text = { Text("Are you sure?") },
        confirmButton = {
            TextButton(onClick = { showDialog = false }) {
                Text("Yes")
            }
        },
        dismissButton = {
            TextButton(onClick = { showDialog = false }) {
                Text("No")
            }
        }
    )
}
```

**Target (ArkUI):**
```typescript
@Component
struct MyPage {
  @State showDialog: boolean = false

  build() {
    Column() {
      Button('Show Dialog')
        .onClick(() => {
          this.showDialog = true
        })
    }
    .bindMenu(this.showDialog, () => {
      // Or use AlertDialog directly:
    })
  }
}

// Alternative: Imperative dialog
AlertDialog.show({
  title: 'Confirm',
  message: 'Are you sure?',
  primaryButton: {
    value: 'Yes',
    action: () => { /* confirm */ }
  },
  secondaryButton: {
    value: 'No',
    action: () => { /* cancel */ }
  }
})
```

---

### RULE-UI-010: Animation

| Compose | ArkUI | Notes |
|---|---|---|
| `animateFloatAsState(target)` | `.animation({ duration: 300 })` | Implicit animation |
| `AnimatedVisibility { }` | `if/else` + `.transition()` | Conditional + transition |
| `Crossfade(target) { }` | `.transition(TransitionEffect.OPACITY)` | |
| `rememberInfiniteTransition()` | `animator` API | More complex in ArkUI |

**Source (Compose):**
```kotlin
var expanded by remember { mutableStateOf(false) }
val height by animateDpAsState(if (expanded) 200.dp else 80.dp)

Box(modifier = Modifier.height(height).clickable { expanded = !expanded })
```

**Target (ArkUI):**
```typescript
@State expanded: boolean = false

build() {
  Column()
    .height(this.expanded ? 200 : 80)
    .onClick(() => { this.expanded = !this.expanded })
    .animation({ duration: 300, curve: Curve.EaseInOut })
}
```

---

## Anti-Patterns

### DO NOT: Replicate Compose's `remember` Semantics
```typescript
// WRONG
let count = remember(0)  // No such API in ArkTS

// CORRECT
@State count: number = 0
```

### DO NOT: Simulate a Modifier Object
```typescript
// WRONG
const myModifier = new Modifier().width('100%').padding(16)

// CORRECT — method chain directly on the component
Text('Hello')
  .width('100%')
  .padding(16)
```

### DO NOT: Port MaterialTheme Directly
```typescript
// WRONG
const primaryColor = MaterialTheme.colorScheme.primary

// CORRECT — use HarmonyOS resource system
const primaryColor = $r('sys.color.ohos_id_color_primary')
```

### DO NOT: Nest Components Inside Method Chains
```typescript
// WRONG
Column().width('100%') {  // Build block cannot come after methods
  Text('Hello')
}

// CORRECT — methods come AFTER the build block
Column() {
  Text('Hello')
}
.width('100%')
```

---

## Verification Checklist

- [ ] Every component is a `@Component struct` with a `build()` method
- [ ] State variables use `@State`, `@Prop`, or `@Link` decorators
- [ ] Method chaining is placed after the component's closing brace, not before
- [ ] `ForEach` includes a key generator function (third argument)
- [ ] Entry-point pages have `@Entry` decorator
- [ ] Colors use HarmonyOS resource references (`$r(...)`) or hex strings
- [ ] `dp` units converted to `vp` (generally 1:1)
- [ ] `RecyclerView` / `LazyColumn` converted to `List()` + `ForEach()` + `ListItem()`
- [ ] No `Modifier` objects — all styling via method chaining
- [ ] Network images use `Image(url)` directly (no Coil/Glide)
- [ ] Navigation uses `router` API with page registration in `main_pages.json`
- [ ] Import paths are `@kit.ArkUI`, `@ohos.router`, etc.
