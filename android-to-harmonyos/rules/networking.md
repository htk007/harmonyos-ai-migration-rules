---
title: "Android Networking → HarmonyOS Networking"
migration_path: android-to-harmonyos
category: networking
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Android Networking → HarmonyOS Networking Rules

## Context

This rule set covers migration of Android networking code — Retrofit, OkHttp, Volley, and raw HttpURLConnection — to HarmonyOS `@ohos.net.http` and related APIs. HarmonyOS provides a built-in HTTP client that eliminates the need for third-party networking libraries.

## Quick Reference

| Android | HarmonyOS | Notes |
|---|---|---|
| Retrofit + OkHttp | `http.createHttp()` | Built-in, no library needed |
| OkHttp Interceptors | Manual request/response handling | No interceptor chain |
| Gson / Moshi (JSON) | `JSON.parse()` / `JSON.stringify()` | Built-in JSON support |
| WebSocket (OkHttp) | `webSocket.createWebSocket()` | Built-in WebSocket |
| ConnectivityManager | `connection.createNetConnection()` | Network state monitoring |

---

## Rules

### RULE-NET-001: GET Request

**Source (Android — Retrofit):**
```kotlin
interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): User
}

// Usage
val user = api.getUser(123)
```

**Source (Android — OkHttp):**
```kotlin
val client = OkHttpClient()
val request = Request.Builder()
    .url("$BASE_URL/users/$id")
    .build()

val response = client.newCall(request).execute()
val user = gson.fromJson(response.body?.string(), User::class.java)
```

**Target (HarmonyOS):**
```typescript
import { http } from '@kit.NetworkKit'

async function getUser(id: number): Promise<User> {
  const httpRequest = http.createHttp()
  try {
    const response = await httpRequest.request(
      `${BASE_URL}/users/${id}`,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        expectDataType: http.HttpDataType.OBJECT
      }
    )

    if (response.responseCode === http.ResponseCode.OK) {
      return response.result as User
    } else {
      throw new Error(`HTTP ${response.responseCode}`)
    }
  } finally {
    httpRequest.destroy()
  }
}
```

**Notes:**
- Always call `httpRequest.destroy()` after use to release resources
- `expectDataType: HttpDataType.OBJECT` auto-parses JSON response
- No need for Gson/Moshi — use `HttpDataType.OBJECT` or `JSON.parse()`

---

### RULE-NET-002: POST Request

**Source (Android — Retrofit):**
```kotlin
@POST("users")
suspend fun createUser(@Body user: CreateUserRequest): User
```

**Target (HarmonyOS):**
```typescript
async function createUser(userData: CreateUserRequest): Promise<User> {
  const httpRequest = http.createHttp()
  try {
    const response = await httpRequest.request(
      `${BASE_URL}/users`,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(userData),
        expectDataType: http.HttpDataType.OBJECT
      }
    )

    if (response.responseCode === http.ResponseCode.OK) {
      return response.result as User
    } else {
      throw new Error(`HTTP ${response.responseCode}`)
    }
  } finally {
    httpRequest.destroy()
  }
}
```

---

### RULE-NET-003: API Service Pattern

**Source (Android — Retrofit service with multiple endpoints):**
```kotlin
interface ApiService {
    @GET("users")
    suspend fun getUsers(): List<User>

    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): User

    @POST("users")
    suspend fun createUser(@Body user: CreateUserRequest): User

    @PUT("users/{id}")
    suspend fun updateUser(@Path("id") id: Long, @Body user: UpdateUserRequest): User

    @DELETE("users/{id}")
    suspend fun deleteUser(@Path("id") id: Long): Response<Unit>
}
```

**Target (HarmonyOS — API service class):**
```typescript
import { http } from '@kit.NetworkKit'

const BASE_URL = 'https://api.example.com/v1'

class ApiService {
  private async request<T>(url: string, options: http.HttpRequestOptions): Promise<T> {
    const httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(url, {
        ...options,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await this.getToken()}`,
          ...options.header
        },
        expectDataType: http.HttpDataType.OBJECT
      })

      if (response.responseCode >= 200 && response.responseCode < 300) {
        return response.result as T
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  async getUsers(): Promise<User[]> {
    return this.request<User[]>(`${BASE_URL}/users`, {
      method: http.RequestMethod.GET
    })
  }

  async getUser(id: number): Promise<User> {
    return this.request<User>(`${BASE_URL}/users/${id}`, {
      method: http.RequestMethod.GET
    })
  }

  async createUser(user: CreateUserRequest): Promise<User> {
    return this.request<User>(`${BASE_URL}/users`, {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(user)
    })
  }

  async updateUser(id: number, user: UpdateUserRequest): Promise<User> {
    return this.request<User>(`${BASE_URL}/users/${id}`, {
      method: http.RequestMethod.PUT,
      extraData: JSON.stringify(user)
    })
  }

  async deleteUser(id: number): Promise<void> {
    await this.request<void>(`${BASE_URL}/users/${id}`, {
      method: http.RequestMethod.DELETE
    })
  }

  private async getToken(): Promise<string> {
    // Retrieve from secure storage
    return ''
  }
}
```

---

### RULE-NET-004: WebSocket

**Source (Android — OkHttp WebSocket):**
```kotlin
val client = OkHttpClient()
val request = Request.Builder().url("wss://example.com/ws").build()

client.newWebSocket(request, object : WebSocketListener() {
    override fun onOpen(webSocket: WebSocket, response: Response) { }
    override fun onMessage(webSocket: WebSocket, text: String) { }
    override fun onClosing(webSocket: WebSocket, code: Int, reason: String) { }
    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) { }
})
```

**Target (HarmonyOS):**
```typescript
import { webSocket } from '@kit.NetworkKit'

const ws = webSocket.createWebSocket()

ws.on('open', (err, value) => {
  console.info('WebSocket connected')
  ws.send('Hello server')
})

ws.on('message', (err, value) => {
  console.info(`Received: ${value}`)
})

ws.on('close', (err, value) => {
  console.info('WebSocket closed')
})

ws.on('error', (err) => {
  console.error('WebSocket error:', err)
})

ws.connect('wss://example.com/ws')

// Close when done
ws.close()
```

---

### RULE-NET-005: Network State Monitoring

**Source (Android):**
```kotlin
val connectivityManager = getSystemService(ConnectivityManager::class.java)
val networkCallback = object : ConnectivityManager.NetworkCallback() {
    override fun onAvailable(network: Network) { /* online */ }
    override fun onLost(network: Network) { /* offline */ }
}
connectivityManager.registerDefaultNetworkCallback(networkCallback)
```

**Target (HarmonyOS):**
```typescript
import { connection } from '@kit.NetworkKit'

const netConnection = connection.createNetConnection()

netConnection.on('netAvailable', () => {
  console.info('Network available')
})

netConnection.on('netUnavailable', () => {
  console.info('Network unavailable')
})

netConnection.register(() => {})

// Check current state
const hasNet = await connection.hasDefaultNet()
```

---

## Anti-Patterns

### DO NOT: Forget to Destroy HTTP Requests
```typescript
// WRONG — resource leak
const req = http.createHttp()
const res = await req.request(url, options)
return res.result  // req never destroyed!

// CORRECT — always destroy in finally
const req = http.createHttp()
try {
  const res = await req.request(url, options)
  return res.result
} finally {
  req.destroy()
}
```

### DO NOT: Parse JSON Manually When Not Needed
```typescript
// WRONG — unnecessary when expectDataType is OBJECT
const response = await req.request(url, { expectDataType: http.HttpDataType.STRING })
const data = JSON.parse(response.result as string)

// CORRECT — let the framework parse
const response = await req.request(url, { expectDataType: http.HttpDataType.OBJECT })
const data = response.result as MyType
```

---

## Verification Checklist

- [ ] All Retrofit interfaces converted to API service classes
- [ ] Every `http.createHttp()` has a matching `destroy()` in finally block
- [ ] Base URL configured centrally
- [ ] Auth token injection centralized in base request method
- [ ] JSON parsing uses `HttpDataType.OBJECT` or `JSON.parse()`
- [ ] No Retrofit/OkHttp/Volley dependencies remain
- [ ] WebSocket connections properly opened and closed
- [ ] Network permission (`ohos.permission.INTERNET`) declared in module.json5
- [ ] Error handling covers HTTP error codes and network failures
