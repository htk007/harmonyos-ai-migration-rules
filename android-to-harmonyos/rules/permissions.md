---
title: "Android Permissions → HarmonyOS Permissions"
migration_path: android-to-harmonyos
category: permissions
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: beginner
---

# Android Permissions → HarmonyOS Permissions Rules

## Context

This rule set maps Android runtime permissions to their HarmonyOS equivalents and covers the permission request flow differences. HarmonyOS uses a similar runtime permission model but with different permission names and a mandatory reason declaration.

## Permission Name Mapping

| Android Permission | HarmonyOS Permission | Grant Type |
|---|---|---|
| `INTERNET` | `ohos.permission.INTERNET` | system_grant |
| `CAMERA` | `ohos.permission.CAMERA` | user_grant |
| `RECORD_AUDIO` | `ohos.permission.MICROPHONE` | user_grant |
| `ACCESS_FINE_LOCATION` | `ohos.permission.APPROXIMATELY_LOCATION` + `ohos.permission.LOCATION` | user_grant |
| `ACCESS_COARSE_LOCATION` | `ohos.permission.APPROXIMATELY_LOCATION` | user_grant |
| `READ_CONTACTS` | `ohos.permission.READ_CONTACTS` | user_grant |
| `WRITE_CONTACTS` | `ohos.permission.WRITE_CONTACTS` | user_grant |
| `READ_CALENDAR` | `ohos.permission.READ_CALENDAR` | user_grant |
| `WRITE_CALENDAR` | `ohos.permission.WRITE_CALENDAR` | user_grant |
| `READ_EXTERNAL_STORAGE` | `ohos.permission.READ_MEDIA` | user_grant |
| `WRITE_EXTERNAL_STORAGE` | `ohos.permission.WRITE_MEDIA` | user_grant |
| `BLUETOOTH` | `ohos.permission.ACCESS_BLUETOOTH` | user_grant |
| `VIBRATE` | No permission needed | Auto-granted |
| `WAKE_LOCK` | `ohos.permission.KEEP_BACKGROUND_RUNNING` | system_grant |
| `POST_NOTIFICATIONS` | `ohos.permission.NOTIFICATION_CONTROLLER` | system_grant |
| `BODY_SENSORS` | `ohos.permission.READ_HEALTH_DATA` | user_grant |

**Grant Types:**
- `system_grant`: Automatically granted at install — just declare in module.json5
- `user_grant`: Must be requested at runtime — declare + request in code

---

## Rules

### RULE-PERM-001: Declaring Permissions

**Source (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**Target (module.json5):**
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
        // system_grant — no reason needed
      },
      {
        "name": "ohos.permission.CAMERA",
        "reason": "$string:camera_permission_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:location_permission_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:location_permission_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

**Notes:**
- `user_grant` permissions require `reason` and `usedScene` fields
- `reason` must reference a string resource explaining why the permission is needed
- `when`: `"inuse"` (only while app is in foreground) or `"always"`
- Fine location requires BOTH `APPROXIMATELY_LOCATION` and `LOCATION`

---

### RULE-PERM-002: Runtime Permission Request

**Source (Android):**
```kotlin
private val requestPermissionLauncher =
    registerForActivityResult(RequestPermission()) { isGranted ->
        if (isGranted) {
            openCamera()
        } else {
            showPermissionDenied()
        }
    }

fun checkAndRequestCamera() {
    when {
        ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED -> openCamera()
        shouldShowRequestPermissionRationale(Manifest.permission.CAMERA) ->
            showRationale()
        else -> requestPermissionLauncher.launch(Manifest.permission.CAMERA)
    }
}
```

**Target (HarmonyOS):**
```typescript
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'

async function checkAndRequestCamera(context: common.UIAbilityContext): Promise<boolean> {
  const atManager = abilityAccessCtrl.createAtManager()
  const permission: Permissions = 'ohos.permission.CAMERA'

  // Check current status
  const grantStatus = await atManager.checkAccessToken(
    await getTokenId(),
    permission
  )

  if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
    return true  // Already granted
  }

  // Request permission
  const result = await atManager.requestPermissionsFromUser(
    context,
    [permission]
  )

  return result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
}

// Helper to get token ID
async function getTokenId(): Promise<number> {
  const bundleInfo = await bundleManager.getBundleInfoForSelf(
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
  )
  return bundleInfo.appInfo.accessTokenId
}
```

---

### RULE-PERM-003: Multiple Permissions

**Source (Android):**
```kotlin
val permissions = arrayOf(
    Manifest.permission.CAMERA,
    Manifest.permission.RECORD_AUDIO
)
requestPermissions(permissions, REQUEST_CODE)
```

**Target (HarmonyOS):**
```typescript
const permissions: Permissions[] = [
  'ohos.permission.CAMERA',
  'ohos.permission.MICROPHONE'
]

const result = await atManager.requestPermissionsFromUser(context, permissions)

const allGranted = result.authResults.every(
  (status) => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
)

if (allGranted) {
  startRecording()
} else {
  showPermissionDenied()
}
```

---

## Anti-Patterns

### DO NOT: Forget Permission Reasons for user_grant
```json5
// WRONG — will fail build validation
{
  "name": "ohos.permission.CAMERA"
  // Missing reason and usedScene
}

// CORRECT
{
  "name": "ohos.permission.CAMERA",
  "reason": "$string:camera_reason",
  "usedScene": { "abilities": ["EntryAbility"], "when": "inuse" }
}
```

---

## Verification Checklist

- [ ] All Android permissions mapped to HarmonyOS equivalents
- [ ] `system_grant` permissions declared in module.json5 only
- [ ] `user_grant` permissions have `reason` and `usedScene` in module.json5
- [ ] Runtime permission checks use `abilityAccessCtrl` API
- [ ] Permission reason strings defined in `resources/base/element/string.json`
- [ ] Fine location requests both `APPROXIMATELY_LOCATION` and `LOCATION`
- [ ] Graceful fallback when permissions are denied
