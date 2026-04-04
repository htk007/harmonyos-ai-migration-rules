---
title: "Android Testing → HarmonyOS Testing"
migration_path: android-to-harmonyos
category: testing
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Android Testing → HarmonyOS Testing Rules

## Context

This rule set covers migration of Android test code — JUnit, Espresso, Mockito, and Compose testing — to the HarmonyOS testing framework. Apply these rules when converting unit tests, UI tests, and integration tests.

## Quick Reference

| Android | HarmonyOS | Notes |
|---|---|---|
| JUnit 4/5 | `@ohos.test` | Built-in test framework |
| `@Test` | `it('description', () => {})` | BDD-style syntax |
| `@Before` / `@After` | `beforeEach` / `afterEach` | |
| `assertEquals()` | `expect(value).assertEqual(expected)` | |
| Espresso | `@ohos.UiTest` | UI automation |
| Mockito | Manual mocks or interfaces | No mocking framework |
| Robolectric | N/A | No equivalent needed |

---

## Rules

### RULE-TEST-001: Unit Test Structure

**Source (Android — JUnit):**
```kotlin
class UserRepositoryTest {
    private lateinit var repository: UserRepository
    private lateinit var mockApi: FakeUserApi

    @Before
    fun setup() {
        mockApi = FakeUserApi()
        repository = UserRepository(mockApi)
    }

    @Test
    fun `getUser returns user when API succeeds`() {
        mockApi.setResponse(User(1, "John"))
        val result = runBlocking { repository.getUser(1) }
        assertEquals("John", result.name)
    }

    @Test
    fun `getUser throws when API fails`() {
        mockApi.setShouldFail(true)
        assertThrows<Exception> {
            runBlocking { repository.getUser(1) }
        }
    }

    @After
    fun tearDown() {
        // cleanup
    }
}
```

**Target (HarmonyOS):**
```typescript
import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium'

export default function UserRepositoryTest() {
  describe('UserRepository', () => {
    let repository: UserRepository
    let fakeApi: FakeUserApi

    beforeEach(() => {
      fakeApi = new FakeUserApi()
      repository = new UserRepository(fakeApi)
    })

    it('getUser returns user when API succeeds', 0, async () => {
      fakeApi.setResponse(new User(1, 'John'))
      const result = await repository.getUser(1)
      expect(result.name).assertEqual('John')
    })

    it('getUser throws when API fails', 0, async () => {
      fakeApi.setShouldFail(true)
      try {
        await repository.getUser(1)
        expect(false).assertTrue()  // Should not reach here
      } catch (error) {
        expect(error).not().assertUndefined()
      }
    })

    afterEach(() => {
      // cleanup
    })
  })
}
```

---

### RULE-TEST-002: Assertion Mapping

| JUnit / Hamcrest | HarmonyOS (`@ohos/hypium`) |
|---|---|
| `assertEquals(expected, actual)` | `expect(actual).assertEqual(expected)` |
| `assertTrue(condition)` | `expect(condition).assertTrue()` |
| `assertFalse(condition)` | `expect(condition).assertFalse()` |
| `assertNull(value)` | `expect(value).assertNull()` |
| `assertNotNull(value)` | `expect(value).not().assertNull()` |
| `assertThrows<E> { }` | try/catch + assertion |
| `assertThat(x, is(y))` | `expect(x).assertEqual(y)` |

---

### RULE-TEST-003: UI Testing

**Source (Android — Espresso):**
```kotlin
@Test
fun clickButton_showsMessage() {
    onView(withId(R.id.myButton)).perform(click())
    onView(withId(R.id.messageText)).check(matches(withText("Hello!")))
}
```

**Target (HarmonyOS — UiTest):**
```typescript
import { Driver, ON } from '@ohos.UiTest'

it('click button shows message', 0, async () => {
  const driver = Driver.create()
  await driver.delayMs(1000)

  const button = await driver.findComponent(ON.id('myButton'))
  await button.click()

  const messageText = await driver.findComponent(ON.id('messageText'))
  const text = await messageText.getText()
  expect(text).assertEqual('Hello!')
})
```

---

## Verification Checklist

- [ ] JUnit `@Test` methods converted to `it()` blocks inside `describe()`
- [ ] `@Before` / `@After` converted to `beforeEach` / `afterEach`
- [ ] Assertions use `expect().assertXxx()` pattern
- [ ] Async tests use `async` with `await`
- [ ] Mocked dependencies use interface-based fakes
- [ ] UI tests use `Driver` and `ON` selectors
- [ ] Test files registered in test runner configuration
