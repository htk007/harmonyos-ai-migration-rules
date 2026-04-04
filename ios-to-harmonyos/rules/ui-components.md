---
title: "SwiftUI / UIKit → ArkUI Component Transformations"
migration_path: ios-to-harmonyos
category: ui-components
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# SwiftUI / UIKit → ArkUI Component Transformation Rules

## Context

This rule set defines how to convert iOS UI code — both SwiftUI (declarative) and UIKit (imperative/storyboard) — to HarmonyOS ArkUI. SwiftUI and ArkUI are both declarative frameworks with strong structural parallels, making this a relatively direct conversion. UIKit conversions require more restructuring. Apply these rules when converting any screen, view, or layout from an iOS application.

## Core Principles

- SwiftUI `View` struct with `body` → ArkUI `@Component struct` with `build()`
- SwiftUI `@State` / `@Binding` → ArkUI `@State` / `@Link`
- SwiftUI modifier chain → ArkUI method chain (very similar pattern)
- UIKit `UIViewController` → ArkUI `@Entry @Component` struct (fundamental shift)
- UIKit `UITableView` / `UICollectionView` → ArkUI `List()` + `ForEach()`

---

## Rules

### RULE-UI-001: Basic View Structure

**Source (SwiftUI):**
```swift
struct GreetingView: View {
    let name: String

    var body: some View {
        Text("Hello, \(name)!")
            .font(.title)
            .foregroundColor(.blue)
    }
}
```

**Source (UIKit):**
```swift
class GreetingViewController: UIViewController {
    var name: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "Hello, \(name)!"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .systemBlue
        view.addSubview(label)
    }
}
```

**Target (ArkUI):**
```typescript
@Component
struct GreetingView {
  @Prop name: string

  build() {
    Text(`Hello, ${this.name}!`)
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor('#007AFF')
  }
}
```

**Mapping:**
- SwiftUI `View` struct + `body` → `@Component struct` + `build()`
- UIKit `UIViewController` + `viewDidLoad()` → `@Entry @Component struct` + `build()` + `aboutToAppear()`
- SwiftUI `let` property → `@Prop` decorator
- `self` is implicit in Swift; `this.` is required in ArkTS

---

### RULE-UI-002: Layout Containers

| SwiftUI | UIKit | ArkUI | Notes |
|---|---|---|---|
| `VStack { }` | `UIStackView(.vertical)` | `Column() { }` | |
| `HStack { }` | `UIStackView(.horizontal)` | `Row() { }` | |
| `ZStack { }` | Overlapping subviews | `Stack() { }` | |
| `List { }` | `UITableView` | `List() { }` | |
| `ScrollView { }` | `UIScrollView` | `Scroll() { }` | |
| `LazyVStack { }` | `UITableView` | `List() { }` | Lazy loading built-in |
| `LazyHStack { }` | `UICollectionView` (horizontal) | `List().listDirection(Axis.Horizontal)` | |
| `Spacer()` | Auto Layout constraints | `Blank()` | |
| `Divider()` | `UIView` (1px separator) | `Divider()` | |
| `GeometryReader { }` | `view.bounds` | No direct equivalent | Use `.onAreaChange()` |
| `NavigationStack { }` | `UINavigationController` | `router` + page files | See Navigation rules |
| `TabView { }` | `UITabBarController` | `Tabs() { TabContent() }` | |

**Source (SwiftUI):**
```swift
VStack(alignment: .leading, spacing: 12) {
    Text("Title")
        .font(.headline)
    Text("Subtitle")
        .font(.subheadline)
        .foregroundColor(.secondary)
}
.padding()
.frame(maxWidth: .infinity)
```

**Target (ArkUI):**
```typescript
Column({ space: 12 }) {
  Text('Title')
    .fontSize(17)
    .fontWeight(FontWeight.Bold)
  Text('Subtitle')
    .fontSize(15)
    .fontColor('#8E8E93')
}
.padding(16)
.width('100%')
.alignItems(HorizontalAlign.Start)
```

**Key Mappings:**
- `VStack(spacing: X)` → `Column({ space: X })`
- `alignment: .leading` → `.alignItems(HorizontalAlign.Start)`
- `.padding()` (all sides, default 16) → `.padding(16)`
- `.frame(maxWidth: .infinity)` → `.width('100%')`
- `.frame(height: 200)` → `.height(200)`

---

### RULE-UI-003: State Management

| SwiftUI | ArkUI | Use Case |
|---|---|---|
| `@State var x = val` | `@State x: Type = val` | Component-local state |
| `@Binding var x: T` | `@Link x: Type` | Two-way binding with parent |
| `let x: T` (immutable prop) | `@Prop x: Type` | One-way data from parent (copied) |
| `@ObservedObject var vm` | `@State vm: ViewModel` | Observable class state |
| `@StateObject var vm` | `@State vm: ViewModel` | Owned observable state |
| `@EnvironmentObject` | `@Consume` / `@Provide` | Dependency injection through tree |
| `@Environment(\.colorScheme)` | System resource queries | OS-level settings |
| `@Published var x` | Property in `@Observed` class | Reactive class properties |
| `@AppStorage("key")` | `@StorageProp("key")` / `@StorageLink("key")` | Persistent key-value state |

**Source (SwiftUI):**
```swift
class CounterViewModel: ObservableObject {
    @Published var count = 0
    @Published var history: [Int] = []

    func increment() {
        count += 1
        history.append(count)
    }
}

struct CounterView: View {
    @StateObject private var viewModel = CounterViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Count: \(viewModel.count)")
                .font(.largeTitle)
            Button("Increment") {
                viewModel.increment()
            }
            Text("History: \(viewModel.history.map(String.init).joined(separator: ", "))")
                .font(.caption)
        }
    }
}
```

**Target (ArkUI):**
```typescript
@Observed
class CounterViewModel {
  count: number = 0
  history: number[] = []

  increment(): void {
    this.count += 1
    this.history = [...this.history, this.count]
  }
}

@Entry
@Component
struct CounterView {
  @State viewModel: CounterViewModel = new CounterViewModel()

  build() {
    Column({ space: 16 }) {
      Text(`Count: ${this.viewModel.count}`)
        .fontSize(34)
        .fontWeight(FontWeight.Bold)

      Button('Increment')
        .onClick(() => {
          this.viewModel.increment()
        })

      Text(`History: ${this.viewModel.history.join(', ')}`)
        .fontSize(12)
        .fontColor('#8E8E93')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
```

**Notes:**
- `ObservableObject` + `@Published` → `@Observed` class (properties are automatically reactive)
- `@StateObject` → `@State` with `@Observed` class
- Array mutations: use spread `[...arr, newItem]` for reactivity (reassignment triggers update)

---

### RULE-UI-004: Lists

**Source (SwiftUI):**
```swift
struct ContactListView: View {
    let contacts: [Contact]

    var body: some View {
        List {
            ForEach(contacts) { contact in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(contact.name)
                            .font(.headline)
                        Text(contact.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                // handle delete
            }
        }
    }
}
```

**Source (UIKit):**
```swift
class ContactListViewController: UITableViewController {
    var contacts: [Contact] = []

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.email
        return cell
    }
}
```

**Target (ArkUI):**
```typescript
@Component
struct ContactListView {
  @Prop contacts: Contact[]

  build() {
    List() {
      ForEach(this.contacts, (contact: Contact) => {
        ListItem() {
          Row() {
            Image($r('sys.media.ohos_ic_public_contacts'))
              .width(32)
              .height(32)
              .fillColor('#007AFF')

            Column() {
              Text(contact.name)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
              Text(contact.email)
                .fontSize(15)
                .fontColor('#8E8E93')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
          .padding(12)
        }
      }, (contact: Contact) => contact.id.toString())
    }
    .width('100%')
  }
}
```

**Critical:**
- SwiftUI `ForEach` with `Identifiable` → ArkUI `ForEach` with explicit key generator (3rd argument)
- UIKit `UITableView` + delegate/datasource → `List()` + `ForEach()` (no delegates needed)
- Swipe-to-delete: `.onDelete` → `ListItem().swipeAction()` in ArkUI

---

### RULE-UI-005: Common Components

| SwiftUI | UIKit | ArkUI | Notes |
|---|---|---|---|
| `Text("hello")` | `UILabel` | `Text('hello')` | |
| `Image("name")` | `UIImageView` | `Image($r('app.media.name'))` | |
| `Image(systemName:)` | `UIImage(systemName:)` | `Image($r('sys.media.xxx'))` | System icons differ |
| `Button("Tap") {}` | `UIButton` | `Button('Tap').onClick()` | |
| `TextField("hint", text:)` | `UITextField` | `TextInput({placeholder, text})` | |
| `SecureField` | `UITextField` (secure) | `TextInput().type(InputType.Password)` | |
| `TextEditor` | `UITextView` | `TextArea({text})` | Multiline |
| `Toggle(isOn:)` | `UISwitch` | `Toggle({isOn}).onChange()` | |
| `Slider(value:)` | `UISlider` | `Slider({value}).onChange()` | |
| `ProgressView()` | `UIActivityIndicatorView` | `LoadingProgress()` | |
| `ProgressView(value:)` | `UIProgressView` | `Progress({value, total})` | |
| `DatePicker` | `UIDatePicker` | `DatePicker()` | |
| `Picker` | `UIPickerView` | `Select()` or `TextPicker()` | |
| `Alert` | `UIAlertController` | `AlertDialog.show()` | |
| `Sheet` | Present modally | `router.pushUrl()` or `@CustomDialog` | |
| `NavigationLink` | Push VC | `router.pushUrl()` | |

**TextField Example:**

**Source (SwiftUI):**
```swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)

            Button("Sign In") { signIn() }
                .disabled(email.isEmpty || password.isEmpty)
        }
        .padding()
    }
}
```

**Target (ArkUI):**
```typescript
@Entry
@Component
struct LoginForm {
  @State email: string = ''
  @State password: string = ''

  build() {
    Column({ space: 16 }) {
      TextInput({ placeholder: 'Email', text: this.email })
        .type(InputType.Email)
        .onChange((value: string) => { this.email = value })
        .width('100%')

      TextInput({ placeholder: 'Password', text: this.password })
        .type(InputType.Password)
        .onChange((value: string) => { this.password = value })
        .width('100%')

      Button('Sign In')
        .width('100%')
        .enabled(this.email.length > 0 && this.password.length > 0)
        .onClick(() => { this.signIn() })
    }
    .padding(16)
  }

  signIn(): void {
    // authentication logic
  }
}
```

---

### RULE-UI-006: Styling and Modifiers

| SwiftUI Modifier | ArkUI Method | Notes |
|---|---|---|
| `.font(.title)` | `.fontSize(28).fontWeight(FontWeight.Bold)` | No font presets — explicit values |
| `.foregroundColor(.blue)` | `.fontColor('#007AFF')` | |
| `.background(Color.red)` | `.backgroundColor('#FF3B30')` | |
| `.cornerRadius(12)` | `.borderRadius(12)` | |
| `.shadow(radius: 4)` | `.shadow({ radius: 4, color: '#33000000' })` | |
| `.opacity(0.5)` | `.opacity(0.5)` | Same |
| `.padding()` | `.padding(16)` | ArkUI needs explicit value |
| `.padding(.horizontal, 20)` | `.padding({ left: 20, right: 20 })` | |
| `.frame(width:height:)` | `.width(X).height(Y)` | |
| `.frame(maxWidth: .infinity)` | `.width('100%')` | |
| `.overlay { }` | `Stack() { }` | Overlay via stacking |
| `.clipShape(Circle())` | `.borderRadius('50%')` or `.clip(true)` | |
| `.disabled(true)` | `.enabled(false)` | Inverted logic |

**iOS System Colors → HarmonyOS Equivalents:**

| iOS Color | Hex Value | HarmonyOS Resource |
|---|---|---|
| `.systemBlue` | `#007AFF` | `$r('sys.color.ohos_id_color_primary')` |
| `.systemRed` | `#FF3B30` | `$r('sys.color.ohos_id_color_warning')` |
| `.systemGreen` | `#34C759` | `#34C759` |
| `.label` | Dynamic | `$r('sys.color.ohos_id_color_text_primary')` |
| `.secondaryLabel` | Dynamic | `$r('sys.color.ohos_id_color_text_secondary')` |
| `.systemBackground` | Dynamic | `$r('sys.color.ohos_id_color_background')` |

---

### RULE-UI-007: Navigation

**Source (SwiftUI):**
```swift
struct AppView: View {
    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(value: item) {
                    Text(item.title)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationTitle("Items")
        }
    }
}
```

**Target (ArkUI):**
```typescript
// Register in main_pages.json: "pages/Items", "pages/Detail"

@Entry
@Component
struct ItemsPage {
  @State items: Item[] = []

  build() {
    Column() {
      Text('Items')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, bottom: 8 })

      List() {
        ForEach(this.items, (item: Item) => {
          ListItem() {
            Text(item.title)
              .fontSize(17)
              .width('100%')
              .padding(16)
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Detail',
              params: { itemId: item.id }
            })
          })
        }, (item: Item) => item.id.toString())
      }
    }
  }
}
```

**Key Mappings:**
- `NavigationStack` → page-based routing with `router`
- `NavigationLink` → `.onClick()` + `router.pushUrl()`
- `.navigationTitle()` → manual `Text` component as header
- `.navigationDestination(for:)` → separate `@Entry` page receiving params
- `@Environment(\.dismiss)` → `router.back()`

---

### RULE-UI-008: Tab View

**Source (SwiftUI):**
```swift
struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
```

**Target (ArkUI):**
```typescript
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0

  @Builder
  tabIcon(title: string, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .width(24).height(24)
        .fillColor(this.currentIndex === index ? '#007AFF' : '#8E8E93')
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007AFF' : '#8E8E93')
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .height(50)
    .width('100%')
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeView()
      }.tabBar(this.tabIcon('Home', $r('app.media.ic_home'), 0))

      TabContent() {
        SearchView()
      }.tabBar(this.tabIcon('Search', $r('app.media.ic_search'), 1))

      TabContent() {
        ProfileView()
      }.tabBar(this.tabIcon('Profile', $r('app.media.ic_profile'), 2))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
```

---

## Anti-Patterns

### DO NOT: Port SwiftUI View Modifiers as Separate Classes
```typescript
// WRONG — creating a modifier system
class ViewModifier { ... }
Text('Hello').modifier(new RoundedModifier())

// CORRECT — direct method chaining
Text('Hello')
  .borderRadius(12)
  .backgroundColor(Color.White)
```

### DO NOT: Use UIKit Patterns (Delegate/Datasource)
```typescript
// WRONG — UITableView delegate pattern
class MyListDelegate implements ListDelegate {
  numberOfRows(): number { ... }
  cellForRow(index: number): Component { ... }
}

// CORRECT — declarative List + ForEach
List() {
  ForEach(this.data, (item) => {
    ListItem() { /* content */ }
  }, (item) => item.id.toString())
}
```

### DO NOT: Replicate @Environment as Global Variables
```typescript
// WRONG — global mutable state
let globalColorScheme: string = 'light'

// CORRECT — use HarmonyOS resource system for theme-aware values
Text('Hello')
  .fontColor($r('sys.color.ohos_id_color_text_primary'))  // Adapts to dark mode
```

---

## Verification Checklist

- [ ] SwiftUI `View` structs → `@Component struct` with `build()`
- [ ] UIKit `UIViewController` → `@Entry @Component struct`
- [ ] `@State` / `@Binding` → `@State` / `@Link`
- [ ] `@ObservedObject` / `@StateObject` → `@State` with `@Observed` class
- [ ] SwiftUI modifier chain → ArkUI method chain (after build block)
- [ ] `NavigationStack` / `NavigationLink` → `router` API
- [ ] `TabView` → `Tabs` + `TabContent`
- [ ] `List` + `ForEach` → `List()` + `ForEach()` with key generator
- [ ] UIKit delegates/datasources eliminated — replaced with declarative patterns
- [ ] System colors replaced with HarmonyOS resource equivalents
- [ ] SF Symbols replaced with HarmonyOS system icons or custom resources
- [ ] `@Environment(\.dismiss)` → `router.back()`
