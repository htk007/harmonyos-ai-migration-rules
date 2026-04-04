---
title: "Gradle → hvigor Build System & Configuration"
migration_path: android-to-harmonyos
category: build-config
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: beginner
---

# Gradle → hvigor Build System & Configuration Rules

## Context

This rule set covers the migration of Android build configuration (Gradle, AndroidManifest.xml, ProGuard) to HarmonyOS equivalents (hvigor, module.json5, build-profile.json5). Apply these rules when setting up a new HarmonyOS project structure from an existing Android project, or when converting build scripts and configuration files.

---

## Project Structure Mapping

**Android:**
```
MyApp/
├── app/
│   ├── src/main/
│   │   ├── java/com/example/     # Source code
│   │   ├── res/                   # Resources
│   │   └── AndroidManifest.xml    # App manifest
│   ├── build.gradle.kts           # Module build script
│   └── proguard-rules.pro         # Code shrinking
├── build.gradle.kts               # Root build script
├── settings.gradle.kts            # Module declarations
└── gradle.properties              # Build properties
```

**HarmonyOS:**
```
MyApp/
├── entry/                          # Main module (≈ app/)
│   ├── src/main/
│   │   ├── ets/                   # ArkTS source code
│   │   │   ├── entryability/      # UIAbility (≈ Activity)
│   │   │   ├── pages/             # UI pages
│   │   │   └── components/        # Reusable components
│   │   ├── resources/             # Resources
│   │   │   ├── base/
│   │   │   │   ├── media/         # Images, icons
│   │   │   │   ├── element/       # Strings, colors, dimensions
│   │   │   │   └── profile/       # Page routes (main_pages.json)
│   │   │   └── en/                # Localized resources
│   │   └── module.json5           # Module config (≈ Manifest)
│   ├── build-profile.json5        # Module build config
│   ├── hvigorfile.ts              # Module build script
│   └── oh-package.json5           # Module dependencies
├── build-profile.json5            # Project build config
├── hvigorfile.ts                  # Root build script
└── oh-package.json5               # Root dependencies
```

---

## Rules

### RULE-BUILD-001: AndroidManifest.xml → module.json5

**Source (Android):**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapp">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:name=".MyApplication"
        android:label="My App"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity android:name=".DetailActivity" />

        <service android:name=".SyncService" />
    </application>
</manifest>
```

**Target (HarmonyOS):**
```json5
// entry/src/main/module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet"],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:layered_image",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["action.system.home"]
          }
        ]
      }
    ],
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.CAMERA",
        "reason": "$string:camera_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

**Key Mappings:**
| AndroidManifest | module.json5 | Notes |
|---|---|---|
| `<application>` | `"module"` root | |
| `<activity>` | `"abilities"` array | Each Activity → Ability |
| `android:name` | `"name"` / `"srcEntry"` | Class name + source path |
| `android:exported="true"` + LAUNCHER | `"exported": true` + `"skills"` | |
| `<uses-permission>` | `"requestPermissions"` | Permissions require reasons |
| `<service>` | Separate ServiceExtAbility | Or `"extensionAbilities"` |
| `package="com.example"` | `"bundleName"` in app.json5 | Project-level config |

---

### RULE-BUILD-002: build.gradle → hvigorfile.ts + oh-package.json5

**Source (Android — build.gradle.kts):**
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.dagger.hilt.android")
}

android {
    namespace = "com.example.myapp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"))
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("io.coil-kt:coil-compose:2.5.0")
    implementation("com.google.dagger:hilt-android:2.50")
    testImplementation("junit:junit:4.13.2")
}
```

**Target (HarmonyOS — hvigorfile.ts):**
```typescript
// entry/hvigorfile.ts
import { hapTasks } from '@ohos/hvigor-ohos-plugin'

export default {
  system: hapTasks,
  plugins: []
}
```

**Target (HarmonyOS — oh-package.json5):**
```json5
// entry/oh-package.json5
{
  "name": "entry",
  "version": "1.0.0",
  "description": "Main application module",
  "main": "",
  "author": "",
  "license": "Apache-2.0",
  "dependencies": {
    // HarmonyOS dependencies from ohpm registry
  },
  "devDependencies": {}
}
```

**Target (HarmonyOS — build-profile.json5):**
```json5
// entry/build-profile.json5
{
  "apiType": "stageModel",
  "buildOption": {
    "arkOptions": {
      "runtimeOnly": {
        "sources": []
      }
    }
  },
  "targets": [
    {
      "name": "default",
      "runtimeOS": "HarmonyOS"
    }
  ]
}
```

**Dependency Equivalents:**
| Android Dependency | HarmonyOS | Notes |
|---|---|---|
| `androidx.core:core-ktx` | Built into ArkTS SDK | Not needed |
| `lifecycle-viewmodel` | `@Observed` class pattern | Manual implementation |
| `retrofit2` / `okhttp3` | `@ohos.net.http` (built-in) | No third-party HTTP needed |
| `coil-compose` | `Image()` component (built-in) | Handles network images natively |
| `hilt-android` / `dagger` | Manual DI / service locator | No DI framework |
| `room` | `@ohos.data.relationalStore` | Built-in database |
| `junit` | Built-in test framework | `@ohos.test` |
| `navigation-compose` | `@ohos.router` | Built-in routing |

---

### RULE-BUILD-003: Resources Migration

| Android Resource | HarmonyOS Equivalent | Location |
|---|---|---|
| `res/drawable/` | `resources/base/media/` | Images, icons |
| `res/mipmap/` | `resources/base/media/` | App icon |
| `res/layout/` | ArkUI `build()` method | No XML layouts |
| `res/values/strings.xml` | `resources/base/element/string.json` | |
| `res/values/colors.xml` | `resources/base/element/color.json` | |
| `res/values/dimens.xml` | `resources/base/element/float.json` | |
| `res/values-es/` | `resources/es/element/` | Localization |
| `res/raw/` | `resources/rawfile/` | Raw files |

**String Resources:**

Android (`strings.xml`):
```xml
<resources>
    <string name="app_name">My App</string>
    <string name="welcome_message">Welcome, %s!</string>
</resources>
```

HarmonyOS (`string.json`):
```json
{
  "string": [
    {
      "name": "app_name",
      "value": "My App"
    },
    {
      "name": "welcome_message",
      "value": "Welcome, %s!"
    }
  ]
}
```

**Accessing Resources:**
- Android: `getString(R.string.app_name)` or `@string/app_name`
- HarmonyOS: `$r('app.string.app_name')` in ArkUI, or `getContext().resourceManager.getStringSync($r('app.string.app_name').id)` in code

---

### RULE-BUILD-004: Page Routes (main_pages.json)

Every navigable page in HarmonyOS must be registered:

```json
// entry/src/main/resources/base/profile/main_pages.json
{
  "src": [
    "pages/Index",
    "pages/Detail",
    "pages/Settings",
    "pages/Profile"
  ]
}
```

This replaces:
- Android's Activity declarations in Manifest
- Compose Navigation's `NavHost` route declarations
- Fragment transactions

---

### RULE-BUILD-005: App-Level Configuration

**Source (Android — settings.gradle.kts + root build.gradle.kts):**
```kotlin
// settings.gradle.kts
rootProject.name = "MyApp"
include(":app")
include(":feature-auth")
include(":core-common")
```

**Target (HarmonyOS):**
```json5
// Project root: build-profile.json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS"
      }
    ],
    "buildModeSet": [
      { "name": "debug" },
      { "name": "release" }
    ]
  },
  "modules": [
    { "name": "entry", "srcPath": "./entry", "targets": [{ "name": "default", "applyToProducts": ["default"] }] },
    { "name": "feature_auth", "srcPath": "./feature_auth", "targets": [{ "name": "default", "applyToProducts": ["default"] }] }
  ]
}

// Project root: AppScope/app.json5
{
  "app": {
    "bundleName": "com.example.myapp",
    "vendor": "example",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name",
    "minAPIVersion": 12
  }
}
```

---

## Anti-Patterns

### DO NOT: Look for build.gradle Equivalent Logic in hvigorfile.ts
```typescript
// WRONG — hvigorfile.ts is minimal; don't put dependency config here
export default {
  system: hapTasks,
  dependencies: { ... }  // NOT HERE
}

// CORRECT — dependencies go in oh-package.json5
```

### DO NOT: Put Page Routes in Code Only
```typescript
// WRONG — page not registered, will crash at runtime
router.pushUrl({ url: 'pages/UnregisteredPage' })

// CORRECT — register in main_pages.json first, then navigate
```

---

## Verification Checklist

- [ ] `module.json5` contains all abilities (converted from Activities)
- [ ] All permissions declared with reasons in `requestPermissions`
- [ ] Dependencies replaced with HarmonyOS built-in APIs or ohpm packages
- [ ] String/color/dimension resources migrated to JSON format
- [ ] All pages registered in `main_pages.json`
- [ ] `app.json5` has correct bundleName, version, and minAPIVersion
- [ ] Build profiles configured for debug and release
- [ ] Resource directories match HarmonyOS structure (`media/`, `element/`, `rawfile/`)
- [ ] No Android Gradle plugins referenced anywhere
