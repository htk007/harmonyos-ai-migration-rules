---
title: "WearOS APIs → HarmonyOS Wearable APIs"
migration_path: wearos-to-harmonyos
category: api-mapping
version: 0.1.0
hmos_version: "5.0+"
last_updated: 2026-04-03
ai_tools: [claude, cursor, copilot, windsurf, cline, gemini]
complexity: advanced
---

# WearOS APIs → HarmonyOS Wearable API Mapping Rules

## Context

This rule set maps WearOS-specific APIs — Health Services, Tiles, Watch Face, Complications, and sensor access — to their HarmonyOS Wearable equivalents. Wearable apps have unique platform integrations that go beyond standard mobile APIs. Apply these rules when converting health/fitness apps, watch faces, tile-based glanceable UIs, and apps that use wearable-specific sensors.

## Quick Reference

| WearOS API | HarmonyOS Wearable | Import |
|---|---|---|
| Health Services (heart rate, steps) | Health Kit / Sensor Service | `@kit.SensorServiceKit` |
| Exercise Client | Health Kit Workout | `@kit.HealthServiceKit` |
| Tiles API | Service Widget (Card) | ArkUI Card framework |
| Watch Face API | Clock Ability | Clock Extension |
| Complications | Widget Slots | Widget capability |
| DataClient (phone↔watch sync) | Distributed Data | `@kit.ArkData` |
| MessageClient | Distributed Ability | `@kit.AbilityKit` |
| Ongoing Activity | Background Task | `@kit.BackgroundTasksKit` |
| Rotary Input (crown/bezel) | Crown Event | Input event handling |
| Vibration (haptic) | Vibrator | `@kit.SensorServiceKit` |

---

## Rules

### RULE-WEAR-API-001: Heart Rate Monitoring

**Source (WearOS — Health Services):**
```kotlin
val healthClient = HealthServices.getClient(context)
val measureClient = healthClient.measureClient

// Check capability
val capabilities = measureClient.getCapabilitiesAsync().await()
val supportsHeartRate = DataType.HEART_RATE_BPM in capabilities.supportedDataTypesMeasure

// Register listener
val callback = object : MeasureCallback {
    override fun onAvailabilityChanged(dataType: DeltaDataType<*, *>, availability: Availability) {
        if (availability is DataTypeAvailability) {
            // handle availability change
        }
    }

    override fun onDataReceived(data: DataPointContainer) {
        val heartRate = data.getData(DataType.HEART_RATE_BPM)
        heartRate.forEach { dataPoint ->
            val bpm = dataPoint.value
            updateHeartRate(bpm.toInt())
        }
    }
}

measureClient.registerMeasureCallback(DataType.HEART_RATE_BPM, callback)

// Unregister
measureClient.unregisterMeasureCallback(DataType.HEART_RATE_BPM, callback)
```

**Target (HarmonyOS Wearable):**
```typescript
import { sensor } from '@kit.SensorServiceKit'

// Subscribe to heart rate sensor
sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
  const heartRate: number = data.heartRate
  this.updateHeartRate(heartRate)
}, { interval: 1000000000 })  // Interval in nanoseconds (1 second)

// Unsubscribe
sensor.off(sensor.SensorId.HEART_RATE)
```

**Notes:**
- WearOS Health Services is a high-level abstraction with capabilities negotiation; HarmonyOS uses direct sensor subscriptions
- HarmonyOS sensor interval is in nanoseconds
- Permission required: `ohos.permission.READ_HEALTH_DATA`
- Always unsubscribe in `aboutToDisappear()` to save battery

---

### RULE-WEAR-API-002: Step Counter

**Source (WearOS — Health Services Passive):**
```kotlin
val passiveClient = healthClient.passiveMonitoringClient

val config = PassiveListenerConfig.builder()
    .setDataTypes(setOf(DataType.STEPS_DAILY, DataType.DISTANCE_DAILY))
    .build()

val callback = object : PassiveListenerCallback {
    override fun onNewDataPointsReceived(dataPoints: DataPointContainer) {
        val steps = dataPoints.getData(DataType.STEPS_DAILY).lastOrNull()?.value
        val distance = dataPoints.getData(DataType.DISTANCE_DAILY).lastOrNull()?.value
        updateDailyStats(steps?.toInt() ?: 0, distance ?: 0.0)
    }
}

passiveClient.setPassiveListenerCallback(config, callback)
```

**Target (HarmonyOS Wearable):**
```typescript
import { sensor } from '@kit.SensorServiceKit'

// Pedometer (step counter)
sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
  const steps: number = data.steps
  this.updateSteps(steps)
}, { interval: 5000000000 })  // 5 seconds

// Pedometer detection (walking/running detection)
sensor.on(sensor.SensorId.PEDOMETER_DETECTION, (data: sensor.PedometerDetectionResponse) => {
  const isMoving: boolean = data.scalar > 0
  this.updateMovementStatus(isMoving)
})

// Cleanup
aboutToDisappear() {
  sensor.off(sensor.SensorId.PEDOMETER)
  sensor.off(sensor.SensorId.PEDOMETER_DETECTION)
}
```

**Notes:**
- Permission required: `ohos.permission.ACTIVITY_MOTION`
- Daily aggregation may need to be computed in app logic — HarmonyOS sensor provides raw step count
- Use `PersistentStorage` or `Preferences` to store daily reset point

---

### RULE-WEAR-API-003: Workout / Exercise Tracking

**Source (WearOS — Exercise Client):**
```kotlin
val exerciseClient = healthClient.exerciseClient

// Configure exercise
val config = ExerciseConfig.builder(ExerciseType.RUNNING)
    .setDataTypes(setOf(
        DataType.HEART_RATE_BPM,
        DataType.DISTANCE_TOTAL,
        DataType.CALORIES_TOTAL,
        DataType.SPEED
    ))
    .setExerciseGoals(listOf(
        ExerciseGoal.createOneTimeGoal(
            DataTypeCondition(DataType.DISTANCE_TOTAL, 5000.0, ComparisonType.GREATER_THAN_OR_EQUAL)
        )
    ))
    .build()

// Start
exerciseClient.startExerciseAsync(config).await()

// Receive updates via ExerciseUpdateCallback
val callback = object : ExerciseUpdateCallback {
    override fun onExerciseUpdateReceived(update: ExerciseUpdate) {
        val heartRate = update.latestMetrics.getData(DataType.HEART_RATE_BPM)?.lastOrNull()?.value
        val distance = update.latestMetrics.getData(DataType.DISTANCE_TOTAL)?.lastOrNull()?.value
        val calories = update.latestMetrics.getData(DataType.CALORIES_TOTAL)?.lastOrNull()?.value
        updateWorkoutMetrics(heartRate, distance, calories)
    }

    override fun onExerciseEventReceived(event: ExerciseEvent) { }
    override fun onLapSummaryReceived(lapSummary: ExerciseLapSummary) { }
}

exerciseClient.setUpdateCallback(callback)

// End
exerciseClient.endExerciseAsync().await()
```

**Target (HarmonyOS Wearable):**
```typescript
import { sensor } from '@kit.SensorServiceKit'

// HarmonyOS approach: subscribe to individual sensors for workout tracking
class WorkoutTracker {
  private isActive: boolean = false
  private startTime: number = 0

  onHeartRateUpdate: (hr: number) => void = () => {}
  onStepUpdate: (steps: number) => void = () => {}

  async start(): Promise<void> {
    this.isActive = true
    this.startTime = Date.now()

    // Heart rate sensor
    sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
      if (this.isActive) {
        this.onHeartRateUpdate(data.heartRate)
      }
    }, { interval: 1000000000 })

    // Pedometer for steps/distance
    sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
      if (this.isActive) {
        this.onStepUpdate(data.steps)
      }
    }, { interval: 1000000000 })

    // Accelerometer for speed/cadence calculation
    sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
      if (this.isActive) {
        // Calculate speed from accelerometer data
      }
    }, { interval: 500000000 })
  }

  stop(): void {
    this.isActive = false
    sensor.off(sensor.SensorId.HEART_RATE)
    sensor.off(sensor.SensorId.PEDOMETER)
    sensor.off(sensor.SensorId.ACCELEROMETER)
  }

  getElapsedSeconds(): number {
    return Math.floor((Date.now() - this.startTime) / 1000)
  }
}

// Usage in component
@Entry
@Component
struct WorkoutScreen {
  @State tracker: WorkoutTracker = new WorkoutTracker()
  @State heartRate: number = 0
  @State steps: number = 0

  aboutToAppear() {
    this.tracker.onHeartRateUpdate = (hr: number) => { this.heartRate = hr }
    this.tracker.onStepUpdate = (s: number) => { this.steps = s }
    this.tracker.start()
  }

  aboutToDisappear() {
    this.tracker.stop()
  }

  build() {
    // Workout UI — see RULE-WEAR-UI-004 in ui-components.md
  }
}
```

**Notes:**
- WearOS Exercise Client is a unified API; HarmonyOS requires composing individual sensor subscriptions
- Calorie calculation must be done manually (or via Health Kit if available)
- Use `BackgroundTasksKit` for long-running workouts when app goes to background
- Distance estimation from pedometer: `steps × stride_length`

---

### RULE-WEAR-API-004: Tiles → Service Widget (Card)

**Source (WearOS — Tiles API):**
```kotlin
class FitnessTileService : TileService() {
    override fun onTileRequest(requestParams: RequestBuilders.TileRequest) =
        Futures.immediateFuture(
            Tile.Builder()
                .setResourcesVersion("1")
                .setTileTimeline(
                    Timeline.fromLayoutElement(
                        LayoutElementBuilders.Column.Builder()
                            .addContent(
                                Text.Builder()
                                    .setText("10,432")
                                    .setFontStyle(FontStyle.Builder().setSize(sp(32f)).build())
                                    .build()
                            )
                            .addContent(
                                Text.Builder()
                                    .setText("steps today")
                                    .setFontStyle(FontStyle.Builder().setSize(sp(14f)).build())
                                    .build()
                            )
                            .build()
                    )
                )
                .build()
        )
}
```

**Target (HarmonyOS Wearable — Service Widget):**
```typescript
// Service Widget (Card) — defined as a Form Extension Ability
// The UI is defined in ArkUI and rendered by the system

// FormAbility.ets
import { FormExtensionAbility, formProvider, formInfo } from '@kit.FormKit'

export default class FitnessCardAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data: Record<string, Object> = {
      steps: 10432,
      stepsLabel: 'steps today'
    }
    return formBindingData.createFormBindingData(JSON.stringify(data))
  }

  onUpdateForm(formId: string): void {
    // Fetch latest step data and update card
    const data: Record<string, Object> = {
      steps: this.getCurrentSteps(),
      stepsLabel: 'steps today'
    }
    const bindingData = formBindingData.createFormBindingData(JSON.stringify(data))
    formProvider.updateForm(formId, bindingData)
  }
}

// Card UI layout (card.ets)
@Entry
@Component
struct FitnessCard {
  @LocalStorageProp('steps') steps: number = 0
  @LocalStorageProp('stepsLabel') stepsLabel: string = 'steps today'

  build() {
    Column() {
      Text(`${this.steps}`)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text(this.stepsLabel)
        .fontSize(14)
        .fontColor('#AAAAAA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

**Notes:**
- WearOS Tiles use `LayoutElementBuilders` (protobuf-like); HarmonyOS widgets use standard ArkUI
- Tiles auto-refresh via `onTileRequest`; HarmonyOS widgets via `onUpdateForm` + scheduled updates
- Register widget in `module.json5` under `"extensionAbilities"` with `type: "form"`
- Card size and update frequency are declared in `form_config.json`

---

### RULE-WEAR-API-005: Phone-Watch Communication

**Source (WearOS — DataClient / MessageClient):**
```kotlin
// Send message to phone
val messageClient = Wearable.getMessageClient(context)
val nodes = Wearable.getNodeClient(context).connectedNodes.await()

for (node in nodes) {
    messageClient.sendMessage(
        node.id,
        "/sync/workout",
        workoutData.toByteArray()
    ).await()
}

// Receive on watch
messageClient.addListener { messageEvent ->
    if (messageEvent.path == "/sync/settings") {
        val settings = parseSettings(messageEvent.data)
        applySettings(settings)
    }
}

// Sync data
val dataClient = Wearable.getDataClient(context)
val putDataReq = PutDataMapRequest.create("/workout/latest").apply {
    dataMap.putInt("steps", steps)
    dataMap.putDouble("distance", distance)
    dataMap.putLong("timestamp", System.currentTimeMillis())
}.asPutDataRequest()

dataClient.putDataItem(putDataReq).await()
```

**Target (HarmonyOS — Distributed Data / Ability):**
```typescript
import { distributedKVStore } from '@kit.ArkData'

// HarmonyOS distributed data — automatically syncs across devices
class WatchPhoneSync {
  private kvStore: distributedKVStore.SingleKVStore | null = null

  async init(context: common.UIAbilityContext): Promise<void> {
    const kvManager = distributedKVStore.createKVManager({
      bundleName: 'com.example.fitness',
      context: context
    })

    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: true,  // Automatically sync to paired devices
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    }

    this.kvStore = await kvManager.getKVStore('fitness_sync', options) as distributedKVStore.SingleKVStore
  }

  // Send workout data (syncs automatically to phone)
  async syncWorkout(steps: number, distance: number): Promise<void> {
    await this.kvStore!.put('workout_steps', steps.toString())
    await this.kvStore!.put('workout_distance', distance.toString())
    await this.kvStore!.put('workout_timestamp', Date.now().toString())
  }

  // Listen for data from phone
  onDataChanged(callback: (key: string, value: string) => void): void {
    this.kvStore!.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL,
      (changeData: distributedKVStore.ChangeNotification) => {
        for (const entry of changeData.insertEntries) {
          callback(entry.key, entry.value.value as string)
        }
        for (const entry of changeData.updateEntries) {
          callback(entry.key, entry.value.value as string)
        }
      }
    )
  }
}
```

**Notes:**
- WearOS uses explicit MessageClient/DataClient; HarmonyOS uses distributed KV store with automatic sync
- `autoSync: true` handles the phone↔watch communication transparently
- No need to discover nodes — HarmonyOS distributes data to all logged-in devices
- For one-time messages, use distributed ability (`context.startAbility()` targeting the phone app)

---

### RULE-WEAR-API-006: Vibration / Haptic Feedback

**Source (WearOS):**
```kotlin
val vibrator = getSystemService(Vibrator::class.java)
vibrator.vibrate(VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE))

// Pattern
vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 100, 50, 100), -1))
```

**Target (HarmonyOS Wearable):**
```typescript
import { vibrator } from '@kit.SensorServiceKit'

// Single vibration
vibrator.startVibration({
  type: 'time',
  duration: 100
})

// Pattern
vibrator.startVibration({
  type: 'preset',
  effectId: 'haptic.clock.timer',  // Pre-defined effect
  count: 2
})

// Stop vibration
vibrator.stopVibration()
```

---

## Anti-Patterns

### DO NOT: Keep Sensors Active When Not Needed
```typescript
// WRONG — sensors drain battery
aboutToAppear() {
  sensor.on(sensor.SensorId.HEART_RATE, callback)
  // Never unsubscribed!
}

// CORRECT — always clean up
aboutToDisappear() {
  sensor.off(sensor.SensorId.HEART_RATE)
}
```

### DO NOT: Port Phone-Scale Data Sync to Watch
```typescript
// WRONG — syncing entire database to watch
await kvStore.put('all_workouts', JSON.stringify(allWorkouts))  // Too much data

// CORRECT — sync only what's needed for the watch
await kvStore.put('today_steps', todaySteps.toString())
await kvStore.put('active_goal', activeGoal.toString())
```

---

## Verification Checklist

- [ ] Health sensors subscribed with appropriate intervals (not too frequent)
- [ ] All sensor subscriptions cleaned up in `aboutToDisappear()`
- [ ] Required permissions declared: `READ_HEALTH_DATA`, `ACTIVITY_MOTION`
- [ ] Battery impact considered — sensors disabled when not visible
- [ ] Tiles converted to Service Widget / Card with form extension
- [ ] Phone-watch sync uses distributed KV store with `autoSync`
- [ ] Data synced to paired device is minimal and essential
- [ ] Vibration uses preset effects where possible (more power efficient)
- [ ] Watch Face uses Clock Ability extension (not a regular app)
- [ ] Background workout tracking uses `BackgroundTasksKit`
