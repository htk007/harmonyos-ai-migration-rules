---
title: "Android Navigation → HarmonyOS Navigation"
migration_path: android-to-harmonyos
category: navigation
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Android Navigation → HarmonyOS Navigation Rules

## Context

This rule set covers migration of Android navigation patterns — Navigation Component, Intent-based navigation, Fragment transactions, and deep links — to HarmonyOS Router and Navigation APIs. Apply these rules when converting screen-to-screen navigation, parameter passing, back stack management, and bottom navigation patterns.

## Quick Reference

| Android | HarmonyOS | Notes |
|---|---|---|
| `NavController.navigate()` | `router.pushUrl()` | Push new page |
| `NavController.popBackStack()` | `router.back()` | Go back |
| `Intent(this, Activity::class)` | `router.pushUrl({ url: 'pages/X' })` | Page navigation |
| `startActivityForResult()` | `router.pushUrl()` + `router.getParams()` | Return with data |
| `NavHost` + `composable()` | `main_pages.json` + `@Entry` pages | Route registration |
| `BottomNavigation` | `Tabs` component | Bottom tab bar |
| Deep Links | `module.json5` skills + Want matching | |

---

## Rules

### RULE-NAV-001: Basic Navigation

**Source (Android — Compose Navigation):**
```kotlin
// NavHost setup
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen(navController) }
    composable("detail/{id}") { backStackEntry ->
        DetailScreen(id = backStackEntry.arguments?.getString("id") ?: "")
    }
    composable("settings") { SettingsScreen(navController) }
}

// Navigate forward
navController.navigate("detail/$itemId")

// Navigate back
navController.popBackStack()
```

**Target (HarmonyOS):**
```typescript
// 1. Register in main_pages.json
{
  "src": [
    "pages/Home",
    "pages/Detail",
    "pages/Settings"
  ]
}

// 2. Navigate forward
import { router } from '@kit.ArkUI'

router.pushUrl({
  url: 'pages/Detail',
  params: { id: itemId }
})

// 3. Navigate back
router.back()
```

---

### RULE-NAV-002: Passing Parameters

**Source (Android — Intent extras):**
```kotlin
val intent = Intent(this, DetailActivity::class.java).apply {
    putExtra("user_id", 123L)
    putExtra("user_name", "John")
}
startActivity(intent)

// In DetailActivity
val userId = intent.getLongExtra("user_id", -1)
val userName = intent.getStringExtra("user_name") ?: ""
```

**Target (HarmonyOS):**
```typescript
// Send
router.pushUrl({
  url: 'pages/Detail',
  params: {
    userId: 123,
    userName: 'John'
  }
})

// Receive in Detail page
@Entry
@Component
struct DetailPage {
  @State userId: number = -1
  @State userName: string = ''

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.userId = params['userId'] as number
      this.userName = params['userName'] as string
    }
  }

  build() {
    Column() {
      Text(`User: ${this.userName} (ID: ${this.userId})`)
    }
  }
}
```

---

### RULE-NAV-003: Bottom Navigation / Tab Layout

**Source (Android — Compose Bottom Navigation):**
```kotlin
@Composable
fun MainScreen() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = currentRoute == "home",
                    onClick = { navController.navigate("home") },
                    icon = { Icon(Icons.Filled.Home, "Home") },
                    label = { Text("Home") }
                )
                NavigationBarItem(
                    selected = currentRoute == "search",
                    onClick = { navController.navigate("search") },
                    icon = { Icon(Icons.Filled.Search, "Search") },
                    label = { Text("Search") }
                )
                NavigationBarItem(
                    selected = currentRoute == "profile",
                    onClick = { navController.navigate("profile") },
                    icon = { Icon(Icons.Filled.Person, "Profile") },
                    label = { Text("Profile") }
                )
            }
        }
    ) { paddingValues ->
        NavHost(navController, startDestination = "home",
                modifier = Modifier.padding(paddingValues)) {
            composable("home") { HomeTab() }
            composable("search") { SearchTab() }
            composable("profile") { ProfileTab() }
        }
    }
}
```

**Target (HarmonyOS — Tabs):**
```typescript
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0

  @Builder
  tabBuilder(title: string, index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#007AFF' : '#999999')
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007AFF' : '#999999')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(50)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeTab()
      }
      .tabBar(this.tabBuilder('Home', 0, $r('app.media.ic_home')))

      TabContent() {
        SearchTab()
      }
      .tabBar(this.tabBuilder('Search', 1, $r('app.media.ic_search')))

      TabContent() {
        ProfileTab()
      }
      .tabBar(this.tabBuilder('Profile', 2, $r('app.media.ic_profile')))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .barHeight(56)
  }
}
```

---

### RULE-NAV-004: Back Stack Management

| Android | HarmonyOS | Description |
|---|---|---|
| `navigate(route, popUpTo = ...)` | `router.replaceUrl()` | Replace current page |
| `popBackStack(route, inclusive)` | `router.back({ url: 'pages/X' })` | Back to specific page |
| `navigate(singleTop = true)` | `router.pushUrl({ url }, RouterMode.Single)` | Single instance |
| `clearBackStack()` | `router.clear()` | Clear all history |
| `finish()` | `router.back()` | Close current page |

**Standard mode vs Single mode:**
```typescript
// Standard — creates new instance every time
router.pushUrl({ url: 'pages/Detail' }, router.RouterMode.Standard)

// Single — reuses existing instance if it exists in the stack
router.pushUrl({ url: 'pages/Detail' }, router.RouterMode.Single)
```

---

### RULE-NAV-005: Navigation with Result

**Source (Android):**
```kotlin
// Launcher
val launcher = registerForActivityResult(StartActivityForResult()) { result ->
    if (result.resultCode == RESULT_OK) {
        val selectedItem = result.data?.getStringExtra("selected") ?: ""
    }
}
launcher.launch(Intent(this, PickerActivity::class.java))

// In PickerActivity
setResult(RESULT_OK, Intent().putExtra("selected", "item1"))
finish()
```

**Target (HarmonyOS):**
```typescript
// Page A — Navigate and expect result
router.pushUrl({ url: 'pages/Picker' })

// Retrieve result when returning (in onPageShow lifecycle)
onPageShow() {
  const params = router.getParams() as Record<string, Object>
  if (params?.['selected']) {
    this.selectedItem = params['selected'] as string
  }
}

// Page B (Picker) — Return with result
router.back({
  url: 'pages/PageA',
  params: { selected: 'item1' }
})
```

---

## Anti-Patterns

### DO NOT: Navigate Without Page Registration
```typescript
// WRONG — page not in main_pages.json
router.pushUrl({ url: 'pages/Unregistered' })  // Will crash

// CORRECT — always register first in main_pages.json
```

### DO NOT: Pass Complex Objects as Router Params
```typescript
// WRONG — large objects may cause issues
router.pushUrl({
  url: 'pages/Detail',
  params: { entireUserObject: complexUser }  // Too much data
})

// CORRECT — pass IDs, fetch data in target page
router.pushUrl({
  url: 'pages/Detail',
  params: { userId: complexUser.id }
})
```

---

## Verification Checklist

- [ ] All pages registered in `main_pages.json`
- [ ] Target pages have `@Entry` decorator
- [ ] `router.getParams()` has null checks and type casting
- [ ] Back stack behavior matches original app flow
- [ ] Bottom navigation uses `Tabs` component with `TabContent`
- [ ] No Android Intent, NavController, or Fragment references remain
- [ ] Complex data passed via ID reference, not entire objects
- [ ] Page lifecycle methods (`aboutToAppear`, `onPageShow`) used correctly
