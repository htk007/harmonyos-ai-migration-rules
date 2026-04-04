# Hello World — HarmonyOS (Converted)

This is the migrated HarmonyOS (ArkTS/ArkUI) code.

## EntryAbility.ets

```typescript
// src/main/ets/entryability/EntryAbility.ets
import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('EntryAbility onCreate')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load content:', JSON.stringify(err))
        return
      }
    })
  }

  onForeground(): void {}
  onBackground(): void {}
  onDestroy(): void {}
}
```

## Index.ets (Main Page)

```typescript
// src/main/ets/pages/Index.ets
@Entry
@Component
struct Index {
  @State name: string = ''
  @State greeting: string = ''

  build() {
    Column() {
      Text('Hello World')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Blank().height(24)

      TextInput({ placeholder: 'Enter your name', text: this.name })
        .onChange((value: string) => {
          this.name = value
        })
        .width('100%')

      Blank().height(16)

      Button('Greet Me')
        .width('100%')
        .onClick(() => {
          this.greeting = `Hello, ${this.name}! Welcome to HarmonyOS.`
        })

      if (this.greeting.length > 0) {
        Blank().height(24)
        Text(this.greeting)
          .fontSize(18)
          .fontColor($r('sys.color.ohos_id_color_primary'))
      }
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

## module.json5

```json5
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
    ]
  }
}
```

## main_pages.json

```json
{
  "src": [
    "pages/Index"
  ]
}
```

## Migration Notes

| Android | HarmonyOS | Rule Applied |
|---|---|---|
| `ComponentActivity` + `setContent` | `UIAbility` + `loadContent` | RULE-ARCH-001 |
| `@Composable fun GreetingScreen` | `@Entry @Component struct Index` | RULE-UI-001 |
| `remember { mutableStateOf("") }` | `@State name: string = ''` | RULE-UI-003 |
| `TextField(value, onValueChange)` | `TextInput({text}).onChange()` | RULE-UI-005 |
| `Button(onClick) { Text() }` | `Button('label').onClick()` | RULE-UI-005 |
| `Modifier.fillMaxSize().padding(24.dp)` | `.width('100%').height('100%').padding(24)` | RULE-UI-002 |
| `MaterialTheme.colorScheme.primary` | `$r('sys.color.ohos_id_color_primary')` | RULE-UI-006 |
| `Spacer(Modifier.height(24.dp))` | `Blank().height(24)` | RULE-UI-002 |
