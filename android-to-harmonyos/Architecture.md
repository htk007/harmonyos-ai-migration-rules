---
title: "Android Architecture → HarmonyOS Architecture"
migration_path: android-to-harmonyos
category: architecture
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: advanced
---

# Android Architecture → HarmonyOS Architecture Rules

## Context

This rule set covers the migration of Android application architecture patterns — including MVVM with ViewModel/LiveData, Clean Architecture layers, Dependency Injection (Hilt/Dagger), and app lifecycle management — to their HarmonyOS equivalents. Apply these rules when converting ViewModels, Repositories, Use Cases, and the overall module structure.

## Core Architecture Mapping

| Android Concept | HarmonyOS Equivalent | Notes |
|---|---|---|
| Activity | UIAbility | Entry point, lifecycle management |
| Fragment | Custom `@Component` struct | No Fragment equivalent; use components |
| ViewModel | `@Observed` class or ViewModel pattern | Manual implementation |
| LiveData / StateFlow | `@State` / `@Link` / `@Provide` / `@Consume` | Decorator-based reactivity |
| Application class | AbilityStage | App-level lifecycle |
| Service | ServiceExtensionAbility | Background tasks |
| BroadcastReceiver | CommonEventManager | Event subscription |
| ContentProvider | DataShareExtensionAbility | Data sharing |

---

## Rules

### RULE-ARCH-001: Activity → UIAbility

**Source (Android):**
```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun onResume() {
        super.onResume()
        // refresh data
    }

    override fun onDestroy() {
        super.onDestroy()
        // cleanup
    }
}
```

**Target (HarmonyOS):**
```typescript
// src/main/ets/entryability/EntryAbility.ets
import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Ability created — initialize resources
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Load the entry page
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load content')
        return
      }
    })
  }

  onForeground(): void {
    // Equivalent to onResume — refresh data
  }

  onBackground(): void {
    // Equivalent to onPause
  }

  onDestroy(): void {
    // Cleanup
  }
}
```

**Lifecycle Mapping:**
| Android | HarmonyOS | When |
|---|---|---|
| `onCreate()` | `onCreate()` + `onWindowStageCreate()` | Ability/UI initialization |
| `onStart()` | `onForeground()` | Coming to foreground |
| `onResume()` | `onForeground()` | Active state |
| `onPause()` | `onBackground()` | Going to background |
| `onStop()` | `onBackground()` | Background state |
| `onDestroy()` | `onWindowStageDestroy()` + `onDestroy()` | Cleanup |

---

### RULE-ARCH-002: ViewModel Pattern

**Source (Android):**
```kotlin
class UserViewModel(
    private val getUserUseCase: GetUserUseCase,
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val _uiState = MutableStateFlow(UserUiState())
    val uiState: StateFlow<UserUiState> = _uiState.asStateFlow()

    init {
        loadUser()
    }

    fun loadUser() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val user = getUserUseCase(userId)
                _uiState.update { it.copy(user = user, isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message, isLoading = false) }
            }
        }
    }
}

data class UserUiState(
    val user: User? = null,
    val isLoading: Boolean = false,
    val error: String? = null
)
```

**Target (HarmonyOS):**
```typescript
// UserViewModel.ets
@Observed
export class UserViewModel {
  user: User | null = null
  isLoading: boolean = false
  error: string | null = null

  private getUserUseCase: GetUserUseCase

  constructor(getUserUseCase: GetUserUseCase) {
    this.getUserUseCase = getUserUseCase
    this.loadUser()
  }

  async loadUser(): Promise<void> {
    this.isLoading = true
    this.error = null
    try {
      this.user = await this.getUserUseCase.execute()
      this.isLoading = false
    } catch (err) {
      this.error = (err as Error).message
      this.isLoading = false
    }
  }
}

// Usage in component
@Entry
@Component
struct UserPage {
  @State viewModel: UserViewModel = new UserViewModel(new GetUserUseCase())

  build() {
    Column() {
      if (this.viewModel.isLoading) {
        LoadingProgress()
      } else if (this.viewModel.error !== null) {
        Text(`Error: ${this.viewModel.error}`)
      } else if (this.viewModel.user !== null) {
        Text(this.viewModel.user.name)
      }
    }
  }
}
```

**Notes:**
- `@Observed` class + `@State` in component = reactive ViewModel pattern
- No `viewModelScope` — use `async/await` directly
- No `StateFlow` / `LiveData` — the `@Observed` decorator makes property changes trigger UI updates
- ViewModel survives within the component's lifecycle; for persistence across pages, use AppStorage

---

### RULE-ARCH-003: Repository Pattern

**Source (Android):**
```kotlin
class UserRepository(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource
) {
    suspend fun getUser(id: Long): Result<User> {
        return try {
            val user = remoteDataSource.fetchUser(id)
            localDataSource.saveUser(user)
            Result.success(user)
        } catch (e: Exception) {
            val cachedUser = localDataSource.getUser(id)
            if (cachedUser != null) {
                Result.success(cachedUser)
            } else {
                Result.failure(e)
            }
        }
    }
}
```

**Target (HarmonyOS):**
```typescript
import { relationalStore } from '@kit.ArkData'
import { http } from '@kit.NetworkKit'

interface ResultSuccess<T> { type: 'success'; data: T }
interface ResultFailure { type: 'failure'; error: string }
type Result<T> = ResultSuccess<T> | ResultFailure

class UserRepository {
  private remoteDataSource: UserRemoteDataSource
  private localDataSource: UserLocalDataSource

  constructor(remote: UserRemoteDataSource, local: UserLocalDataSource) {
    this.remoteDataSource = remote
    this.localDataSource = local
  }

  async getUser(id: number): Promise<Result<User>> {
    try {
      const user = await this.remoteDataSource.fetchUser(id)
      await this.localDataSource.saveUser(user)
      return { type: 'success', data: user }
    } catch (err) {
      const cachedUser = await this.localDataSource.getUser(id)
      if (cachedUser !== null) {
        return { type: 'success', data: cachedUser }
      }
      return { type: 'failure', error: (err as Error).message }
    }
  }
}
```

**Notes:**
- Repository pattern translates almost directly
- Kotlin `Result<T>` → custom discriminated union type
- `suspend` functions → `async` functions with `Promise<T>`
- Dependency injection is manual (see RULE-ARCH-005)

---

### RULE-ARCH-004: Clean Architecture Layers

**Android Clean Architecture:**
```
presentation/ (Activity, ViewModel, Compose UI)
domain/       (Use Cases, Entities, Repository Interfaces)
data/         (Repository Impl, DataSource, API, DB)
```

**HarmonyOS Equivalent:**
```
ets/
├── pages/           # @Entry components (≈ Activities)
├── components/      # @Component structs (≈ Compose composables)
├── viewmodels/      # @Observed classes (≈ ViewModels)
├── domain/
│   ├── entities/    # Data models
│   └── usecases/    # Use case classes
├── data/
│   ├── repositories/  # Repository implementations
│   ├── remote/        # HTTP data sources
│   └── local/         # Database/preferences data sources
└── common/          # Utilities, constants, extensions
```

**Module Structure Mapping:**
| Android (Gradle modules) | HarmonyOS (HAP/HSP) |
|---|---|
| `:app` module | Entry HAP module |
| `:feature-xxx` module | Feature HAP module |
| `:core` / `:common` library | HSP (HarmonyOS Shared Package) |
| `:domain` library | HSP or local library |
| Third-party AAR/JAR | HAR (HarmonyOS Archive) via ohpm |

---

### RULE-ARCH-005: Dependency Injection

**Source (Android — Hilt):**
```kotlin
@HiltAndroidApp
class MyApplication : Application()

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideHttpClient(): OkHttpClient = OkHttpClient.Builder().build()

    @Provides
    @Singleton
    fun provideApi(client: OkHttpClient): UserApi =
        Retrofit.Builder()
            .client(client)
            .baseUrl(BASE_URL)
            .build()
            .create(UserApi::class.java)
}

@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() { ... }
```

**Target (HarmonyOS — Manual DI / Service Locator):**
```typescript
// ServiceLocator.ets — Simple DI container
export class ServiceLocator {
  private static instance: ServiceLocator | null = null
  private services: Map<string, Object> = new Map()

  static getInstance(): ServiceLocator {
    if (ServiceLocator.instance === null) {
      ServiceLocator.instance = new ServiceLocator()
    }
    return ServiceLocator.instance!
  }

  register<T extends Object>(key: string, service: T): void {
    this.services.set(key, service)
  }

  get<T extends Object>(key: string): T {
    return this.services.get(key) as T
  }

  // Initialize in AbilityStage
  static setup(): void {
    const locator = ServiceLocator.getInstance()
    const httpClient = new HttpClient()
    const userApi = new UserApi(httpClient)
    const userRepository = new UserRepository(userApi, new UserLocalDataSource())

    locator.register('userRepository', userRepository)
  }
}

// Usage in ViewModel
class UserViewModel {
  private repository: UserRepository

  constructor() {
    this.repository = ServiceLocator.getInstance().get<UserRepository>('userRepository')
  }
}
```

**Notes:**
- No Hilt/Dagger equivalent in HarmonyOS — use manual DI or a service locator pattern
- Initialize the DI container in `AbilityStage.onCreate()` (equivalent to Application.onCreate())
- For simpler apps, constructor injection without a container is sufficient
- Community DI libraries may emerge — check ohpm registry

---

### RULE-ARCH-006: App Lifecycle (Application → AbilityStage)

**Source (Android):**
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize SDKs, DI, crash reporting
    }
}
```

**Target (HarmonyOS):**
```typescript
// src/main/ets/MyAbilityStage.ets
import { AbilityStage } from '@kit.AbilityKit'

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    // Initialize SDKs, DI, crash reporting
    ServiceLocator.setup()
  }
}

// Register in module.json5:
{
  "module": {
    "srcEntry": "./ets/MyAbilityStage.ets",
    ...
  }
}
```

---

## Anti-Patterns

### DO NOT: Create a ViewModel Base Class That Mimics Android ViewModel
```typescript
// WRONG — unnecessary abstraction
abstract class BaseViewModel extends ViewModel { ... }

// CORRECT — use @Observed directly, keep it simple
@Observed
class UserViewModel {
  // reactive properties
}
```

### DO NOT: Try to Replicate LiveData
```typescript
// WRONG — manual observer pattern
class LiveData<T> {
  private observers: Array<(value: T) => void> = []
  observe(callback: (value: T) => void) { ... }
}

// CORRECT — ArkUI's decorator system handles reactivity
@State data: string = ''  // Automatically reactive
```

### DO NOT: Over-Engineer DI
```typescript
// WRONG for small apps — full DI framework
@Injectable() @Singleton() class UserService { ... }

// CORRECT — simple constructor injection
class UserViewModel {
  constructor(private repo: UserRepository) {}
}
```

---

## Verification Checklist

- [ ] Activities converted to UIAbility with correct lifecycle methods
- [ ] Fragments replaced with `@Component` structs
- [ ] ViewModels use `@Observed` class pattern
- [ ] LiveData/StateFlow replaced with `@State`/`@Link` decorators
- [ ] Repository pattern preserves offline-first logic
- [ ] Module structure maps to HAP/HSP correctly
- [ ] Application class logic moved to AbilityStage
- [ ] DI setup happens in AbilityStage.onCreate()
- [ ] No Android Jetpack dependencies remain (Room, WorkManager, etc.)
- [ ] Coroutine scopes replaced with async/await patterns
