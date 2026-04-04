---
title: "HarmonyOS Best Practices for Migrated Apps"
migration_path: android-to-harmonyos
category: best-practices
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# HarmonyOS Best Practices for Migrated Apps

## Context

This rule set provides idiomatic HarmonyOS patterns that migrated apps should adopt. Rather than just translating Android code 1:1, these practices ensure the converted app feels native to HarmonyOS and takes advantage of platform-specific capabilities. Apply these after the initial migration to improve code quality and user experience.

---

## Best Practices

### BP-001: Embrace ArkUI's Declarative State Model

Don't fight the state management system — lean into it.

```typescript
// GOOD — let the framework handle reactivity
@Component
struct ProductCard {
  @Prop product: Product
  @State isFavorite: boolean = false

  build() {
    Column() {
      Image(this.product.imageUrl)
        .width('100%')
        .aspectRatio(1.5)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)

      Text(this.product.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 })

      Row() {
        Text(`$${this.product.price}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B00')

        Blank()

        Image(this.isFavorite ? $r('app.media.heart_filled') : $r('app.media.heart_outline'))
          .width(24)
          .height(24)
          .onClick(() => { this.isFavorite = !this.isFavorite })
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .padding(12)
  }
}
```

---

### BP-002: Use HarmonyOS Resource System for Theming

Instead of hardcoding colors, use system and app resources for consistency with the OS theme.

```typescript
// GOOD — adapts to system light/dark mode automatically
Text('Title')
  .fontColor($r('sys.color.ohos_id_color_text_primary'))

Column()
  .backgroundColor($r('sys.color.ohos_id_color_background'))

// Define app-specific colors in resources/base/element/color.json
// and resources/dark/element/color.json for dark mode
Text('Accent')
  .fontColor($r('app.color.brand_primary'))
```

---

### BP-003: Use @Builder for Reusable UI Fragments

When you need reusable UI pieces that don't warrant a full component:

```typescript
@Component
struct SettingsPage {
  @Builder
  settingRow(icon: Resource, title: string, value: string) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 12 })
      Text(title).fontSize(16).layoutWeight(1)
      Text(value).fontSize(14).fontColor('#999999')
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16).height(16).fillColor('#CCCCCC')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  build() {
    Column() {
      this.settingRow($r('app.media.ic_language'), 'Language', 'English')
      Divider()
      this.settingRow($r('app.media.ic_theme'), 'Theme', 'Auto')
      Divider()
      this.settingRow($r('app.media.ic_about'), 'About', 'v1.0.0')
    }
  }
}
```

---

### BP-004: Leverage Distributed Capabilities

HarmonyOS's unique distributed features allow cross-device experiences. Consider these for migrated apps:

```typescript
// Distributed data sync across devices
import { distributedKVStore } from '@kit.ArkData'

// This allows the app to share data with the same app on other HarmonyOS devices
// Example: Reading progress, shopping cart, clipboard
```

Don't just replicate the Android app — consider what distributed features could enhance the experience.

---

### BP-005: Use AppStorage for Global State

For state that needs to persist across pages (equivalent to global ViewModel or shared state):

```typescript
// Initialize global state
AppStorage.setOrCreate('isLoggedIn', false)
AppStorage.setOrCreate('userName', '')

// Access in any component
@Component
struct Header {
  @StorageProp('userName') userName: string = ''

  build() {
    Text(`Welcome, ${this.userName}`)
  }
}

// Update from anywhere
AppStorage.set('userName', 'John')
AppStorage.set('isLoggedIn', true)
```

---

### BP-006: Proper Page Lifecycle Usage

Understand when to use each lifecycle method:

```typescript
@Entry
@Component
struct MyPage {
  aboutToAppear(): void {
    // Called ONCE when component is about to be created
    // Use for: initial data loading, one-time setup
  }

  onPageShow(): void {
    // Called EVERY TIME page becomes visible (including back navigation)
    // Use for: refreshing data, resuming animations, checking auth
  }

  onPageHide(): void {
    // Called when page becomes hidden
    // Use for: pausing timers, saving draft state
  }

  aboutToDisappear(): void {
    // Called ONCE when component is about to be destroyed
    // Use for: cleanup, unsubscribing, releasing resources
  }

  onBackPress(): boolean {
    // Handle hardware/gesture back
    // Return true to consume the event, false to proceed with default back
    return false
  }

  build() { ... }
}
```

---

### BP-007: Responsive Layout with GridRow/GridCol

Design for multiple device types from the start:

```typescript
@Component
struct ProductGrid {
  @Prop products: Product[]

  build() {
    GridRow({ columns: { sm: 2, md: 3, lg: 4 } }) {
      ForEach(this.products, (product: Product) => {
        GridCol() {
          ProductCard({ product: product })
        }
      }, (product: Product) => product.id.toString())
    }
    .padding(8)
  }
}
```

---

### BP-008: Error Boundary Pattern

Wrap risky operations with consistent error handling:

```typescript
@Observed
class PageState<T> {
  status: 'idle' | 'loading' | 'success' | 'error' = 'idle'
  data: T | null = null
  errorMessage: string = ''

  async load(fetcher: () => Promise<T>): Promise<void> {
    this.status = 'loading'
    try {
      this.data = await fetcher()
      this.status = 'success'
    } catch (err) {
      this.errorMessage = (err as Error).message
      this.status = 'error'
    }
  }
}

// Usage
@Entry
@Component
struct UserPage {
  @State state: PageState<User> = new PageState<User>()

  aboutToAppear() {
    this.state.load(() => userRepository.getUser(1))
  }

  build() {
    Column() {
      if (this.state.status === 'loading') {
        LoadingProgress().width(48).height(48)
      } else if (this.state.status === 'error') {
        Text(this.state.errorMessage)
        Button('Retry').onClick(() => {
          this.state.load(() => userRepository.getUser(1))
        })
      } else if (this.state.status === 'success' && this.state.data) {
        Text(this.state.data!.name)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

### BP-009: Performance — Lazy Loading and Component Reuse

```typescript
// Use LazyForEach for large lists instead of ForEach
class MyDataSource implements IDataSource {
  private data: Item[] = []

  totalCount(): number { return this.data.length }
  getData(index: number): Item { return this.data[index] }

  registerDataChangeListener(listener: DataChangeListener): void { ... }
  unregisterDataChangeListener(listener: DataChangeListener): void { ... }
}

@Component
struct PerformantList {
  private dataSource: MyDataSource = new MyDataSource()

  build() {
    List() {
      LazyForEach(this.dataSource, (item: Item) => {
        ListItem() {
          ItemCard({ item: item })
        }
      }, (item: Item) => item.id.toString())
    }
    .cachedCount(5)  // Pre-render 5 items off-screen
  }
}
```

---

### BP-010: Use Custom Dialogs with @CustomDialog

```typescript
@CustomDialog
struct ConfirmDialog {
  controller: CustomDialogController
  title: string = ''
  message: string = ''
  onConfirm: () => void = () => {}

  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Text(this.message)
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 24 })

      Row() {
        Button('Cancel')
          .fontColor('#999999')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.controller.close())
          .layoutWeight(1)

        Button('Confirm')
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .onClick(() => {
            this.onConfirm()
            this.controller.close()
          })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .padding(24)
  }
}

// Usage
@Entry
@Component
struct MyPage {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: 'Delete Item',
      message: 'This action cannot be undone.',
      onConfirm: () => this.deleteItem()
    }),
    alignment: DialogAlignment.Center
  })

  build() {
    Button('Delete')
      .onClick(() => this.dialogController.open())
  }
}
```

---

## Summary Checklist

- [ ] Using HarmonyOS resource system for colors and theming (not hardcoded values)
- [ ] State management uses appropriate decorators (`@State`, `@Prop`, `@Link`, `@ObjectLink`)
- [ ] Global state uses `AppStorage` or `@Provide`/`@Consume`
- [ ] Page lifecycle methods used correctly (aboutToAppear vs onPageShow)
- [ ] Large lists use `LazyForEach` with `IDataSource`
- [ ] Responsive layouts consider multiple device types
- [ ] Error states handled with loading/error/success pattern
- [ ] Considered distributed capabilities where applicable
- [ ] Reusable UI fragments use `@Builder` or `@Component`
- [ ] Custom dialogs use `@CustomDialog` pattern
