# Todo App — HarmonyOS (Converted)

A CRUD todo application demonstrating `@Observed` state, `List`/`ForEach`, and component composition.

## TodoItem.ets

```typescript
// src/main/ets/models/TodoItem.ets
@Observed
export class TodoItem {
  id: number
  title: string
  isCompleted: boolean

  constructor(id: number, title: string, isCompleted: boolean = false) {
    this.id = id
    this.title = title
    this.isCompleted = isCompleted
  }
}
```

## TodoViewModel.ets

```typescript
// src/main/ets/viewmodels/TodoViewModel.ets
import { TodoItem } from '../models/TodoItem'

@Observed
export class TodoViewModel {
  todos: TodoItem[] = []
  private nextId: number = 1

  addTodo(title: string): void {
    if (title.trim().length === 0) return
    this.todos = [...this.todos, new TodoItem(this.nextId++, title)]
  }

  toggleTodo(id: number): void {
    this.todos = this.todos.map((item) => {
      if (item.id === id) {
        return new TodoItem(item.id, item.title, !item.isCompleted)
      }
      return item
    })
  }

  deleteTodo(id: number): void {
    this.todos = this.todos.filter((item) => item.id !== id)
  }
}
```

## TodoPage.ets (Main Page)

```typescript
// src/main/ets/pages/Index.ets
import { TodoViewModel } from '../viewmodels/TodoViewModel'
import { TodoItem } from '../models/TodoItem'

@Entry
@Component
struct TodoPage {
  @State viewModel: TodoViewModel = new TodoViewModel()
  @State newTodoText: string = ''

  build() {
    Column() {
      Text('My Todos')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Row() {
        TextInput({ placeholder: 'Add a new todo...', text: this.newTodoText })
          .onChange((value: string) => {
            this.newTodoText = value
          })
          .layoutWeight(1)

        Button('Add')
          .margin({ left: 8 })
          .onClick(() => {
            this.viewModel.addTodo(this.newTodoText)
            this.newTodoText = ''
          })
      }
      .width('100%')
      .margin({ top: 16 })

      List({ space: 8 }) {
        ForEach(this.viewModel.todos, (todo: TodoItem) => {
          ListItem() {
            TodoItemCard({
              todo: todo,
              onToggle: () => this.viewModel.toggleTodo(todo.id),
              onDelete: () => this.viewModel.deleteTodo(todo.id)
            })
          }
        }, (todo: TodoItem) => todo.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@Component
struct TodoItemCard {
  @Prop todo: TodoItem
  onToggle: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    Row() {
      Checkbox()
        .select(this.todo.isCompleted)
        .onChange((value: boolean) => {
          this.onToggle()
        })

      Text(this.todo.title)
        .fontSize(16)
        .decoration({
          type: this.todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
        })
        .fontColor(this.todo.isCompleted ? '#999999' : '#333333')
        .layoutWeight(1)
        .margin({ left: 8 })

      Image($r('sys.media.ohos_ic_public_remove'))
        .width(24)
        .height(24)
        .fillColor('#FF3B30')
        .onClick(() => {
          this.onDelete()
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }
}
```

## Migration Notes

| Android Pattern | HarmonyOS Pattern | Rules Applied |
|---|---|---|
| `data class TodoItem` | `@Observed class TodoItem` | RULE-LT-005, BP-001 |
| `ViewModel` + `StateFlow` | `@Observed` class + `@State` | RULE-ARCH-002 |
| `LazyColumn { items() }` | `List() { ForEach(,,keyGen) }` | RULE-UI-004 |
| `Card { Row { } }` | `Row().shadow().borderRadius()` | RULE-UI-006 |
| `Checkbox(checked, onChange)` | `Checkbox().select().onChange()` | RULE-UI-005 |
| `IconButton { Icon() }` | `Image().onClick()` | RULE-UI-005 |
| `Modifier.weight(1f)` | `.layoutWeight(1)` | RULE-UI-002 |
| `TextDecoration.LineThrough` | `TextDecorationType.LineThrough` | RULE-UI-006 |
| Immutable list update via `copy()` | New object creation + array spread | RULE-LT-005 |
