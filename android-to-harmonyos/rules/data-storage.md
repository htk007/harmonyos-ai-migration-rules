---
title: "Android Data & Storage → HarmonyOS Data & Storage"
migration_path: android-to-harmonyos
category: data-storage
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Android Data & Storage → HarmonyOS Data & Storage Rules

## Context

This rule set covers migration of all data persistence mechanisms — SharedPreferences, Room database, file storage, DataStore, and encrypted storage — to their HarmonyOS equivalents. Apply these rules when converting data layer code, repositories, and local storage operations.

## Quick Reference

| Android | HarmonyOS | Import |
|---|---|---|
| SharedPreferences | Preferences | `import { preferences } from '@kit.ArkData'` |
| Room / SQLite | RelationalStore (RDB) | `import { relationalStore } from '@kit.ArkData'` |
| DataStore (Proto/Prefs) | Preferences or KV Store | `import { distributedKVStore } from '@kit.ArkData'` |
| File I/O | File API | `import { fileIo } from '@kit.CoreFileKit'` |
| EncryptedSharedPreferences | Preferences with HUKS | `import { huks } from '@kit.UniversalKeystoreKit'` |
| Content Provider | DataShareExtensionAbility | `import { dataSharePredicates } from '@kit.ArkData'` |

---

## Rules

### RULE-DATA-001: SharedPreferences → Preferences

See RULE-API-001 in `api-mapping.md` for the core conversion.

**Additional patterns — Wrapper class:**

**Source (Android):**
```kotlin
class AppPreferences(context: Context) {
    private val prefs = context.getSharedPreferences("app", Context.MODE_PRIVATE)

    var isFirstLaunch: Boolean
        get() = prefs.getBoolean("first_launch", true)
        set(value) = prefs.edit().putBoolean("first_launch", value).apply()

    var authToken: String?
        get() = prefs.getString("auth_token", null)
        set(value) = prefs.edit().putString("auth_token", value).apply()

    fun clear() = prefs.edit().clear().apply()
}
```

**Target (HarmonyOS):**
```typescript
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

class AppPreferences {
  private store: preferences.Preferences | null = null

  async init(context: common.UIAbilityContext): Promise<void> {
    this.store = await preferences.getPreferences(context, 'app')
  }

  async getIsFirstLaunch(): Promise<boolean> {
    return (await this.store!.get('first_launch', true)) as boolean
  }

  async setIsFirstLaunch(value: boolean): Promise<void> {
    await this.store!.put('first_launch', value)
    await this.store!.flush()
  }

  async getAuthToken(): Promise<string | null> {
    const token = await this.store!.get('auth_token', '')
    return token === '' ? null : token as string
  }

  async setAuthToken(value: string | null): Promise<void> {
    await this.store!.put('auth_token', value ?? '')
    await this.store!.flush()
  }

  async clear(): Promise<void> {
    await this.store!.clear()
    await this.store!.flush()
  }
}
```

**Notes:**
- Every read/write is async — no synchronous property accessors
- Preferences does not support `null` values; use empty string or sentinel value
- `flush()` is required to persist changes to disk

---

### RULE-DATA-002: Room Database → RelationalStore

See RULE-API-002 in `api-mapping.md` for the core conversion.

**Additional pattern — DAO wrapper:**

```typescript
// UserDao.ets — DAO-like wrapper for maintainability
import { relationalStore, ValuesBucket } from '@kit.ArkData'

export class UserDao {
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }

  async getAll(): Promise<User[]> {
    const predicates = new relationalStore.RdbPredicates('users')
    const resultSet = await this.store.query(predicates)
    const users: User[] = []
    while (resultSet.goToNextRow()) {
      users.push(this.mapRow(resultSet))
    }
    resultSet.close()
    return users
  }

  async getById(id: number): Promise<User | null> {
    const predicates = new relationalStore.RdbPredicates('users')
    predicates.equalTo('id', id)
    const resultSet = await this.store.query(predicates)
    let user: User | null = null
    if (resultSet.goToFirstRow()) {
      user = this.mapRow(resultSet)
    }
    resultSet.close()
    return user
  }

  async insert(user: User): Promise<void> {
    const values: ValuesBucket = {
      id: user.id,
      name: user.name,
      email: user.email
    }
    await this.store.insert('users', values)
  }

  async update(user: User): Promise<void> {
    const values: ValuesBucket = { name: user.name, email: user.email }
    const predicates = new relationalStore.RdbPredicates('users')
    predicates.equalTo('id', user.id)
    await this.store.update(values, predicates)
  }

  async delete(id: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('users')
    predicates.equalTo('id', id)
    await this.store.delete(predicates)
  }

  private mapRow(resultSet: relationalStore.ResultSet): User {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      email: resultSet.getString(resultSet.getColumnIndex('email'))
    }
  }
}
```

---

### RULE-DATA-003: File Storage

**Source (Android):**
```kotlin
// Internal storage
val file = File(context.filesDir, "data.json")
file.writeText(jsonString)
val content = file.readText()

// Cache
val cacheFile = File(context.cacheDir, "temp.txt")
```

**Target (HarmonyOS):**
```typescript
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

const context = getContext(this) as common.UIAbilityContext

// Internal storage
const filePath = `${context.filesDir}/data.json`

// Write
const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
fileIo.writeSync(file.fd, jsonString)
fileIo.closeSync(file.fd)

// Read
const readFile = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
const stat = fileIo.statSync(filePath)
const buffer = new ArrayBuffer(stat.size)
fileIo.readSync(readFile.fd, buffer)
const content = String.fromCharCode(...new Uint8Array(buffer))
fileIo.closeSync(readFile.fd)

// Cache
const cachePath = `${context.cacheDir}/temp.txt`
```

**Directory Mapping:**
| Android | HarmonyOS | Access |
|---|---|---|
| `context.filesDir` | `context.filesDir` | App-private files |
| `context.cacheDir` | `context.cacheDir` | Cache files |
| `context.getExternalFilesDir()` | `context.distributedFilesDir` | Shared/distributed |
| `Environment.getExternalStorageDirectory()` | User file access via picker | No direct access |

---

### RULE-DATA-004: DataStore → Preferences or KV Store

**Source (Android — DataStore Preferences):**
```kotlin
val Context.dataStore by preferencesDataStore(name = "settings")
val THEME_KEY = stringPreferencesKey("theme")

// Read
val themeFlow: Flow<String> = context.dataStore.data.map { prefs ->
    prefs[THEME_KEY] ?: "light"
}

// Write
suspend fun setTheme(theme: String) {
    context.dataStore.edit { prefs ->
        prefs[THEME_KEY] = theme
    }
}
```

**Target (HarmonyOS — Preferences):**
```typescript
import { preferences } from '@kit.ArkData'

// For simple key-value settings, use Preferences (same as SharedPreferences migration)
const store = await preferences.getPreferences(context, 'settings')

// Read
const theme = (await store.get('theme', 'light')) as string

// Write
async function setTheme(theme: string): Promise<void> {
  await store.put('theme', theme)
  await store.flush()
}

// For reactive updates, use preferences.on('change')
store.on('change', (key: string) => {
  if (key === 'theme') {
    // React to change
  }
})
```

**Notes:**
- DataStore's `Flow` reactive approach → use `preferences.on('change')` for reactive updates
- For complex distributed data, use `distributedKVStore` instead

---

## Anti-Patterns

### DO NOT: Use Synchronous File I/O in UI Thread
```typescript
// WRONG — blocks UI
build() {
  const data = fileIo.readSync(...)  // Never in build()
}

// CORRECT — load in aboutToAppear, store in @State
@State data: string = ''

aboutToAppear() {
  this.loadData()
}

async loadData() {
  this.data = await readFile()
}
```

### DO NOT: Forget to Close ResultSet
```typescript
// WRONG — memory leak
const resultSet = await store.query(predicates)
return resultSet.getString(0)  // Never closed!

// CORRECT
const resultSet = await store.query(predicates)
try {
  // ... read data
} finally {
  resultSet.close()
}
```

---

## Verification Checklist

- [ ] All SharedPreferences converted to async Preferences API
- [ ] Room entities → SQL CREATE TABLE + DAO wrapper classes
- [ ] Room queries → RdbPredicates or raw SQL via executeSql
- [ ] ResultSet always closed after reading
- [ ] File paths use `context.filesDir` / `context.cacheDir`
- [ ] No synchronous I/O in build() or UI-thread methods
- [ ] DataStore flows replaced with `preferences.on('change')` if reactive updates needed
- [ ] Database initialization happens in AbilityStage or UIAbility.onCreate
