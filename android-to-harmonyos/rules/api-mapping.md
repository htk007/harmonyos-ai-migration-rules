---
title: "Android SDK → HarmonyOS Kit API Mapping"
migration_path: android-to-harmonyos
category: api-mapping
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Android SDK → HarmonyOS Kit API Mapping

## Context

This rule set provides a comprehensive mapping between Android SDK APIs and their HarmonyOS Kit equivalents. Use this as a reference when converting platform-specific code that interacts with device capabilities, system services, and OS features.

---

## Quick Reference Table

| Android API / Library | HarmonyOS Kit / API | Import |
|---|---|---|
| `android.content.SharedPreferences` | `@ohos.data.preferences` | `import { preferences } from '@kit.ArkData'` |
| `androidx.room` | `@ohos.data.relationalStore` | `import { relationalStore } from '@kit.ArkData'` |
| `android.net.ConnectivityManager` | `@ohos.net.connection` | `import { connection } from '@kit.NetworkKit'` |
| `java.net.HttpURLConnection` / Retrofit | `@ohos.net.http` | `import { http } from '@kit.NetworkKit'` |
| `android.location.LocationManager` | `@ohos.geoLocationManager` | `import { geoLocationManager } from '@kit.LocationKit'` |
| `android.hardware.camera2` | `@ohos.multimedia.camera` | `import { camera } from '@kit.CameraKit'` |
| `android.media.MediaPlayer` | `@ohos.multimedia.media` | `import { media } from '@kit.MediaKit'` |
| `android.bluetooth` | `@ohos.bluetooth` | `import { ble } from '@kit.ConnectivityKit'` |
| `android.hardware.SensorManager` | `@ohos.sensor` | `import { sensor } from '@kit.SensorServiceKit'` |
| `android.app.NotificationManager` | `@ohos.notificationManager` | `import { notificationManager } from '@kit.NotificationKit'` |
| `android.content.ClipboardManager` | `@ohos.pasteboard` | `import { pasteboard } from '@kit.BasicServicesKit'` |
| `android.os.Vibrator` | `@ohos.vibrator` | `import { vibrator } from '@kit.SensorServiceKit'` |
| `android.content.Intent` (share) | `@ohos.app.ability.Want` | `import { Want } from '@kit.AbilityKit'` |
| `android.webkit.WebView` | `Web` component | `import { webview } from '@kit.ArkWeb'` |
| `Firebase Cloud Messaging` | HarmonyOS Push Kit | `import { pushService } from '@kit.PushKit'` |
| `Firebase Analytics` | HiAnalytics | `import { hiAppEvent } from '@kit.PerformanceAnalysisKit'` |
| `Google Maps SDK` | Map Kit | `import { map } from '@kit.MapKit'` |
| `WorkManager` | Work Scheduler / Background Tasks | `import { workScheduler } from '@kit.BackgroundTasksKit'` |
| `AlarmManager` | Reminder Agent | `import { reminderAgentManager } from '@kit.BackgroundTasksKit'` |
| `DownloadManager` | `@ohos.request` | `import { request } from '@kit.BasicServicesKit'` |
| `Biometric / Fingerprint` | User Authentication | `import { userAuth } from '@kit.UserAuthenticationKit'` |

---

## Rules

### RULE-API-001: SharedPreferences → Preferences

**Source (Android):**
```kotlin
val prefs = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
prefs.edit()
    .putString("username", "john")
    .putInt("login_count", 5)
    .apply()

val username = prefs.getString("username", "")
```

**Target (HarmonyOS):**
```typescript
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

// Get preferences store (async)
const context = getContext(this) as common.UIAbilityContext
const store = await preferences.getPreferences(context, 'app_prefs')

// Write
await store.put('username', 'john')
await store.put('login_count', 5)
await store.flush()

// Read
const username = await store.get('username', '') as string
```

**Notes:**
- SharedPreferences is synchronous; HarmonyOS Preferences is async (returns Promise)
- `apply()` (async write) → `flush()` (explicit async write)
- `commit()` (sync write) → `await flush()` (awaited write)
- Data types supported: number, string, boolean, Array<number>, Array<string>, Array<boolean>

---

### RULE-API-002: Room Database → RelationalStore

**Source (Android — Room):**
```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String
)

@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: Long): UserEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(user: UserEntity)
}
```

**Target (HarmonyOS — RelationalStore):**
```typescript
import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

// Database setup
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'app.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const SQL_CREATE_USERS = `CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL
)`

// Initialize
const context = getContext(this) as common.UIAbilityContext
const store = await relationalStore.getRdbStore(context, STORE_CONFIG)
await store.executeSql(SQL_CREATE_USERS)

// Query
const predicates = new relationalStore.RdbPredicates('users')
predicates.equalTo('id', userId)
const resultSet = await store.query(predicates)

let user: User | null = null
if (resultSet.goToFirstRow()) {
  user = {
    id: resultSet.getLong(resultSet.getColumnIndex('id')),
    name: resultSet.getString(resultSet.getColumnIndex('name')),
    email: resultSet.getString(resultSet.getColumnIndex('email'))
  }
}
resultSet.close()

// Insert
const values: ValuesBucket = {
  id: user.id,
  name: user.name,
  email: user.email
}
await store.insert('users', values)
```

**Notes:**
- No ORM equivalent — use raw SQL with `RdbPredicates` or `executeSql()`
- Always close `ResultSet` after reading
- No `@Entity` / `@Dao` annotations — manual table creation and queries
- Consider creating a DAO-like wrapper class for maintainability

---

### RULE-API-003: Notification

**Source (Android):**
```kotlin
val notification = NotificationCompat.Builder(context, CHANNEL_ID)
    .setContentTitle("New Message")
    .setContentText("You have a new message")
    .setSmallIcon(R.drawable.ic_notification)
    .build()

NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
```

**Target (HarmonyOS):**
```typescript
import { notificationManager } from '@kit.NotificationKit'

const request: notificationManager.NotificationRequest = {
  id: 1,
  content: {
    notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
    normal: {
      title: 'New Message',
      text: 'You have a new message'
    }
  }
}

await notificationManager.publish(request)
```

---

### RULE-API-004: Location Services

**Source (Android):**
```kotlin
val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
locationManager.requestLocationUpdates(
    LocationManager.GPS_PROVIDER,
    5000L,  // interval
    10f,    // min distance
    locationListener
)
```

**Target (HarmonyOS):**
```typescript
import { geoLocationManager } from '@kit.LocationKit'

const request: geoLocationManager.LocationRequest = {
  priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
  scenario: geoLocationManager.LocationRequestScenario.UNSET,
  timeInterval: 5,
  distanceInterval: 10,
  maxAccuracy: 0
}

geoLocationManager.on('locationChange', request, (location) => {
  console.info(`Lat: ${location.latitude}, Lng: ${location.longitude}`)
})

// Stop listening
geoLocationManager.off('locationChange')
```

---

### RULE-API-005: Biometric Authentication

**Source (Android):**
```kotlin
val biometricPrompt = BiometricPrompt(this, executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            // success
        }
        override fun onAuthenticationFailed() {
            // failed
        }
    })

biometricPrompt.authenticate(promptInfo)
```

**Target (HarmonyOS):**
```typescript
import { userAuth } from '@kit.UserAuthenticationKit'

const authParam: userAuth.AuthParam = {
  challenge: new Uint8Array([1, 2, 3, 4]),
  authType: [userAuth.UserAuthType.FINGERPRINT],
  authTrustLevel: userAuth.AuthTrustLevel.ATL3
}

const widgetParam: userAuth.WidgetParam = {
  title: 'Verify your identity'
}

try {
  const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam)
  userAuthInstance.on('result', {
    onResult(result) {
      if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
        // Authentication succeeded
      }
    }
  })
  userAuthInstance.start()
} catch (error) {
  console.error('Auth error:', error)
}
```

---

### RULE-API-006: Intent / Share → Want

**Source (Android):**
```kotlin
val shareIntent = Intent(Intent.ACTION_SEND).apply {
    type = "text/plain"
    putExtra(Intent.EXTRA_TEXT, "Check this out!")
}
startActivity(Intent.createChooser(shareIntent, "Share via"))
```

**Target (HarmonyOS):**
```typescript
import { common, Want } from '@kit.AbilityKit'

const context = getContext(this) as common.UIAbilityContext
const want: Want = {
  action: 'ohos.want.action.sendData',
  type: 'text/plain',
  parameters: {
    'shareContent': 'Check this out!'
  }
}

await context.startAbility(want)
```

---

## Anti-Patterns

### DO NOT: Use Android Package Names
```typescript
// WRONG
import android.content.Context

// CORRECT
import { common } from '@kit.AbilityKit'
```

### DO NOT: Assume Synchronous APIs
```typescript
// WRONG — SharedPreferences was sync, but Preferences is async
const value = store.get('key', '')

// CORRECT
const value = await store.get('key', '')
```

---

## Verification Checklist

- [ ] All `android.*` imports replaced with `@kit.*` or `@ohos.*` imports
- [ ] Synchronous Android APIs converted to async HarmonyOS equivalents
- [ ] Context usage replaced with `common.UIAbilityContext`
- [ ] Resource references use `$r('app.xxx')` format
- [ ] Intent-based navigation replaced with Want-based routing
- [ ] System service access uses HarmonyOS Kit APIs
- [ ] Callback patterns match HarmonyOS event subscription (`.on()` / `.off()`)
