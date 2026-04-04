# HarmonyOS Fundamentals

A quick reference for core HarmonyOS concepts relevant to all migration paths.

## Application Model (Stage Model)

HarmonyOS uses the **Stage Model** as its primary application framework:

```
Application
├── AbilityStage            (≈ Application class — app lifecycle)
├── UIAbility               (≈ Activity — a UI window)
│   └── WindowStage         (manages the window)
│       └── Pages           (ArkUI @Entry components)
├── ExtensionAbility        (background capabilities)
│   ├── ServiceExtAbility   (≈ Service)
│   ├── DataShareExtAbility (≈ ContentProvider)
│   └── FormExtAbility      (widget/card)
└── AbilityContext           (runtime context for each ability)
```

## ArkTS Language Essentials

ArkTS is a superset of TypeScript with additional constraints for performance and safety:

- **Stricter typing:** No `any`, limited union types in some contexts
- **Class-based:** Prefers classes over structural typing
- **Decorators:** `@Component`, `@State`, `@Entry`, `@Observed`, etc.
- **Module system:** Uses ES module imports with `@ohos/` and `@kit.` prefixes

## ArkUI Component Lifecycle

```
@Entry @Component struct MyPage {
  aboutToAppear()    → Component is about to be created (once)
  onPageShow()       → Page becomes visible (every time)
  build()            → Render the UI (called on state change)
  onPageHide()       → Page becomes hidden
  aboutToDisappear() → Component is about to be destroyed (once)
  onBackPress()      → Hardware/gesture back pressed
}
```

## State Management Decorators

| Decorator | Scope | Reactivity | Use When |
|---|---|---|---|
| `@State` | Component-local | First-level properties | Local mutable state |
| `@Prop` | Parent → Child | One-way (copy) | Passing data down |
| `@Link` | Parent ↔ Child | Two-way (reference) | Shared mutable state |
| `@Provide` / `@Consume` | Ancestor → Descendant | Two-way across tree | Deep prop drilling |
| `@Observed` + `@ObjectLink` | Class properties | Nested object tracking | Complex state objects |
| `@StorageProp` / `@StorageLink` | AppStorage | Global persistence | Cross-page state |

## Resource System

```
resources/
├── base/               (default resources)
│   ├── media/          (images, icons)
│   ├── element/        (strings, colors, dimensions)
│   │   ├── string.json
│   │   ├── color.json
│   │   └── float.json
│   ├── profile/        (configuration)
│   │   └── main_pages.json
│   └── rawfile/        (raw files)
├── en/                 (English locale)
├── zh/                 (Chinese locale)
└── dark/               (dark mode overrides)
    └── element/
        └── color.json
```

**Access patterns:**
- In ArkUI: `$r('app.media.icon')`, `$r('app.string.hello')`, `$r('app.color.primary')`
- System resources: `$r('sys.color.ohos_id_color_primary')`, `$r('sys.media.ohos_ic_public_arrow_right')`
- In code: `getContext().resourceManager.getStringSync($r('app.string.hello').id)`

## HarmonyOS Kit Imports

Common import patterns:

```typescript
// UI and navigation
import { router } from '@kit.ArkUI'

// Ability and context
import { UIAbility, common, Want, AbilityConstant } from '@kit.AbilityKit'

// Data and storage
import { preferences, relationalStore } from '@kit.ArkData'

// Networking
import { http, webSocket, connection } from '@kit.NetworkKit'

// Media
import { camera } from '@kit.CameraKit'
import { media } from '@kit.MediaKit'

// Device capabilities
import { geoLocationManager } from '@kit.LocationKit'
import { sensor, vibrator } from '@kit.SensorServiceKit'
import { notificationManager } from '@kit.NotificationKit'

// Security
import { abilityAccessCtrl } from '@kit.AbilityKit'
import { userAuth } from '@kit.UserAuthenticationKit'

// Files
import { fileIo } from '@kit.CoreFileKit'
```

## Device Types

HarmonyOS apps can target multiple device types:

| Device Type | Identifier | Notes |
|---|---|---|
| Phone | `phone` | Primary target |
| Tablet | `tablet` | Larger screen, responsive layout |
| Wearable | `wearable` | Circular/small screen |
| TV | `tv` | Large screen, remote control |
| Car | `car` | Automotive HMI |
| 2in1 (Laptop) | `2in1` | Keyboard + touch |

Declare supported devices in `module.json5`:
```json5
"deviceTypes": ["phone", "tablet"]
```

## Distributed Capabilities

HarmonyOS unique features for cross-device experiences:

- **Distributed Data:** Sync data across devices automatically
- **Distributed Ability:** Start abilities on other devices
- **Distributed File System:** Access files across devices
- **Distributed Input:** Use one device to control another
