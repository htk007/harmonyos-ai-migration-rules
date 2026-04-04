---
title: "Wear Compose → ArkUI Wearable Component Transformations"
migration_path: wearos-to-harmonyos
category: ui-components
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: intermediate
---

# Wear Compose → ArkUI Wearable Component Transformation Rules

## Context

This rule set defines how to convert WearOS UI code (Wear Compose Material) to HarmonyOS Wearable ArkUI components. Wearable UIs share unique constraints — small circular/rounded screens, glanceable design, crown/bezel input, and power efficiency. Both platforms are declarative, but differ in component naming, layout approach, and interaction patterns. Apply these rules when converting watch faces, workout screens, notification views, and other wearable UI.

## Key Differences

- WearOS typically uses circular layouts; HarmonyOS wearable supports both circular and rectangular
- Wear Compose `ScalingLazyColumn` (curved scrolling) → HarmonyOS `List` with wearable adaptations
- Wear Compose `Chip` → HarmonyOS wearable `Button` with rounded style
- Wear Compose `TimeText` → HarmonyOS system time display (usually handled by OS)
- Crown/Bezel input: Wear `rotaryInput` → HarmonyOS crown events

---

## Rules

### RULE-WEAR-UI-001: Basic Screen Structure

**Source (Wear Compose):**
```kotlin
@Composable
fun MainScreen() {
    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState) }
    ) {
        ScalingLazyColumn(
            state = scalingLazyListState,
            modifier = Modifier.fillMaxSize(),
            anchorType = ScalingLazyColumnAnchorType.ItemCenter
        ) {
            item { Title("My Watch App") }
            items(menuItems) { item ->
                Chip(
                    label = { Text(item.title) },
                    onClick = { navigate(item.route) },
                    icon = { Icon(item.icon, contentDescription = null) }
                )
            }
        }
    }
}
```

**Target (HarmonyOS Wearable ArkUI):**
```typescript
@Entry
@Component
struct MainScreen {
  @State menuItems: MenuItem[] = []

  build() {
    Column() {
      Text('My Watch App')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 36, bottom: 12 })

      List({ space: 8 }) {
        ForEach(this.menuItems, (item: MenuItem) => {
          ListItem() {
            Row() {
              Image(item.icon)
                .width(24).height(24)
                .fillColor(Color.White)
                .margin({ right: 8 })
              Text(item.title)
                .fontSize(16)
                .fontColor(Color.White)
            }
            .width('100%')
            .height(48)
            .borderRadius(24)
            .backgroundColor('#333333')
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              router.pushUrl({ url: item.route })
            })
          }
        }, (item: MenuItem) => item.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .padding({ left: 12, right: 12, bottom: 12 })
  }
}
```

**Notes:**
- `Scaffold` with `TimeText`, `Vignette`, `PositionIndicator` → handled by the HarmonyOS wearable system chrome; no need to implement manually
- `ScalingLazyColumn` (curved content scaling) → `List()` — HarmonyOS wearable handles edge curvature automatically on circular displays
- Wearable screens default to dark background (`Color.Black`)
- Font sizes should be smaller for wearable: titles 16–20, body 14–16, captions 10–12

---

### RULE-WEAR-UI-002: Wearable Component Mapping

| Wear Compose | HarmonyOS Wearable ArkUI | Notes |
|---|---|---|
| `Chip(label, onClick, icon)` | `Row()` styled as pill button | Rounded button with icon + text |
| `CompactChip` | Small `Button()` with `.borderRadius(20)` | |
| `ToggleChip` | `Row()` + `Toggle({isOn})` | Chip with toggle switch |
| `Card(onClick) { }` | `Column()` styled as card | |
| `AppCard / TitleCard` | `Column()` with title + content | |
| `Button` (circular) | `Button()` with `.borderRadius('50%')` | Circular icon button |
| `TimeText()` | System-managed | Don't implement — OS provides |
| `Vignette` | System-managed | Edge darkening for circular screens |
| `PositionIndicator` | System scroll indicator | Automatic on wearable List |
| `CurvedText` | `Text()` on circular layout | Limited support — use straight text |
| `ScalingLazyColumn` | `List()` | Standard scrollable list |
| `InlineSlider` | `Slider()` | |
| `Stepper(value) { }` | Custom +/- buttons | No direct Stepper equivalent |
| `SwipeToDismissBox { }` | System back gesture | HarmonyOS handles swipe-back |
| `CircularProgressIndicator` | `LoadingProgress()` or `Gauge()` | |
| `PageIndicator` | `Swiper()` indicator | Built into Swiper component |

---

### RULE-WEAR-UI-003: Chip → Styled Row/Button

**Source (Wear Compose):**
```kotlin
@Composable
fun WorkoutChip(workout: Workout, onClick: () -> Unit) {
    Chip(
        onClick = onClick,
        label = { Text(workout.name) },
        secondaryLabel = { Text("${workout.duration} min") },
        icon = {
            Icon(
                imageVector = Icons.Rounded.FitnessCenter,
                contentDescription = null,
                modifier = Modifier.size(ChipDefaults.IconSize)
            )
        },
        colors = ChipDefaults.primaryChipColors()
    )
}
```

**Target (HarmonyOS Wearable):**
```typescript
@Component
struct WorkoutChip {
  @Prop workout: Workout
  onTap: () => void = () => {}

  build() {
    Row() {
      Image($r('app.media.ic_fitness'))
        .width(24).height(24)
        .fillColor(Color.White)

      Column() {
        Text(this.workout.name)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
        Text(`${this.workout.duration} min`)
          .fontSize(12)
          .fontColor('#AAAAAA')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height(52)
    .borderRadius(26)
    .backgroundColor('#007AFF')
    .padding({ left: 14, right: 14 })
    .onClick(() => { this.onTap() })
  }
}
```

---

### RULE-WEAR-UI-004: Workout / Health Screens

**Source (Wear Compose):**
```kotlin
@Composable
fun ActiveWorkoutScreen(
    heartRate: Int,
    duration: Duration,
    calories: Double,
    distance: Double
) {
    Column(
        modifier = Modifier.fillMaxSize().background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Heart rate with icon
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Filled.Favorite, tint = Color.Red, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(4.dp))
            Text("$heartRate", style = MaterialTheme.typography.display1, color = Color.Red)
            Text(" bpm", style = MaterialTheme.typography.body2, color = Color.Gray)
        }

        Spacer(Modifier.height(8.dp))

        // Duration
        Text(
            duration.toComponents { h, m, s, _ -> "%02d:%02d:%02d".format(h, m, s) },
            style = MaterialTheme.typography.display3,
            color = Color.White
        )

        Spacer(Modifier.height(12.dp))

        // Stats row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            StatColumn("CAL", "%.0f".format(calories))
            StatColumn("KM", "%.2f".format(distance))
        }
    }
}

@Composable
fun StatColumn(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.title2, color = Color.White)
        Text(label, style = MaterialTheme.typography.caption3, color = Color.Gray)
    }
}
```

**Target (HarmonyOS Wearable):**
```typescript
@Entry
@Component
struct ActiveWorkoutScreen {
  @State heartRate: number = 0
  @State durationSeconds: number = 0
  @State calories: number = 0
  @State distance: number = 0

  build() {
    Column() {
      // Heart rate
      Row() {
        Image($r('app.media.ic_heart'))
          .width(20).height(20)
          .fillColor('#FF3B30')
        Text(`${this.heartRate}`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF3B30')
          .margin({ left: 4 })
        Text(' bpm')
          .fontSize(14)
          .fontColor('#8E8E93')
      }
      .justifyContent(FlexAlign.Center)

      // Duration
      Text(this.formatDuration(this.durationSeconds))
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .margin({ top: 8 })

      // Stats row
      Row() {
        this.statColumn('CAL', `${Math.round(this.calories)}`)
        this.statColumn('KM', this.distance.toFixed(2))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  statColumn(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text(label)
        .fontSize(10)
        .fontColor('#8E8E93')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  formatDuration(totalSeconds: number): string {
    const h = Math.floor(totalSeconds / 3600)
    const m = Math.floor((totalSeconds % 3600) / 60)
    const s = totalSeconds % 60
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }
}
```

---

### RULE-WEAR-UI-005: Page Swiper (Horizontal Paging)

**Source (Wear Compose):**
```kotlin
@Composable
fun PagerScreen() {
    val pagerState = rememberPagerState(pageCount = { 3 })

    HorizontalPager(state = pagerState) { page ->
        when (page) {
            0 -> HeartRatePage()
            1 -> StepsPage()
            2 -> SleepPage()
        }
    }
}
```

**Target (HarmonyOS Wearable):**
```typescript
@Entry
@Component
struct PagerScreen {
  @State currentIndex: number = 0

  build() {
    Swiper() {
      HeartRatePage()
      StepsPage()
      SleepPage()
    }
    .index(this.currentIndex)
    .indicator(true)
    .loop(false)
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .width('100%')
    .height('100%')
  }
}
```

---

### RULE-WEAR-UI-006: Circular Progress / Gauge

**Source (Wear Compose):**
```kotlin
@Composable
fun StepGoalProgress(steps: Int, goal: Int) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator(
            progress = steps.toFloat() / goal,
            modifier = Modifier.fillMaxSize().padding(4.dp),
            startAngle = 270f,
            strokeWidth = 8.dp,
            indicatorColor = Color.Green
        )
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("$steps", style = MaterialTheme.typography.display1, color = Color.White)
            Text("of $goal steps", style = MaterialTheme.typography.body2, color = Color.Gray)
        }
    }
}
```

**Target (HarmonyOS Wearable):**
```typescript
@Component
struct StepGoalProgress {
  @Prop steps: number
  @Prop goal: number

  build() {
    Stack() {
      Gauge({
        value: this.steps,
        min: 0,
        max: this.goal
      })
        .startAngle(270)
        .endAngle(270 + 360 * (this.steps / this.goal))
        .strokeWidth(8)
        .colors('#34C759')
        .width('100%')
        .height('100%')

      Column() {
        Text(`${this.steps}`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(`of ${this.goal} steps`)
          .fontSize(12)
          .fontColor('#8E8E93')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
```

---

## Wearable Design Guidelines

### Screen Dimensions
- Typical wearable: 192×192 to 466×466 pixels
- Always test on circular display — content near edges may be clipped
- Keep critical content in the center ~70% of the screen area

### Typography for Wearable
| Element | Size | Weight |
|---|---|---|
| Large metric (heart rate, steps) | 32–40 | Bold |
| Time / duration | 24–32 | Medium |
| Title | 16–20 | Bold |
| Body | 14–16 | Regular |
| Caption / label | 10–12 | Regular |

### Color
- Always use dark backgrounds (`Color.Black` or `#1C1C1E`)
- High contrast text (white or bright accent colors)
- Use color sparingly for emphasis (heart rate = red, steps = green, etc.)
- OLED screens: pure black saves battery

### Interaction
- Optimize for quick glances (< 5 seconds)
- Large tap targets (minimum 48×48 vp)
- Minimize text input — use voice, selection, or pre-set options
- Support crown/bezel scrolling where applicable

---

## Anti-Patterns

### DO NOT: Port Phone UI Directly to Wearable
```typescript
// WRONG — phone-sized layout on watch
Column() {
  TextInput({ placeholder: 'Search...' })  // Too small to type
  List() {
    // 20 items with detailed descriptions
  }
}

// CORRECT — wearable-optimized
Column() {
  // Large, glanceable metrics
  Text('10,432').fontSize(36)
  Text('steps today').fontSize(12)
}
```

### DO NOT: Implement TimeText / System Chrome Manually
```typescript
// WRONG — reimplementing OS features
Row() {
  Text(new Date().toLocaleTimeString())  // OS already shows time
}

// CORRECT — let the OS handle time display; focus on app content
```

---

## Verification Checklist

- [ ] Dark background used (`Color.Black` or very dark gray)
- [ ] Font sizes appropriate for wearable (max 40 for metrics, 12–16 for body)
- [ ] Tap targets at least 48×48 vp
- [ ] Content centered for circular display compatibility
- [ ] No manual TimeText / Vignette / PositionIndicator (OS handles these)
- [ ] `ScalingLazyColumn` → `List()` with proper spacing
- [ ] Chips → styled `Row()` or `Button()` with large border radius
- [ ] Circular progress → `Gauge()` component
- [ ] Horizontal paging → `Swiper()` component
- [ ] Text input minimized — prefer selection over typing
- [ ] ForEach includes key generator (3rd argument)
