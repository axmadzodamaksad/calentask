# CalenTask (iOS, SwiftUI)

Нативное iPhone-приложение задачника на SwiftUI.

## Что умеет
- Создание, редактирование, удаление задач.
- Поиск, фильтрация по статусу и сортировка.
- Локальное хранение задач в `UserDefaults`.
- Добавление задачи как события в Apple Calendar через `EventKit`.

## Структура
- `CalenTask/CalenTaskApp.swift` — entry point SwiftUI приложения.
- `CalenTask/Models/TaskItem.swift` — модель задачи и логика времени события.
- `CalenTask/ViewModels/TaskStore.swift` — состояние, фильтры, сортировка, persistence.
- `CalenTask/Services/CalendarService.swift` — доступ к календарю и создание событий.
- `CalenTask/Views/*.swift` — экран списка, карточка задачи, форма редактирования.

## Как запустить
1. Установите XcodeGen (если нужен автоген проекта):
   - `brew install xcodegen`
2. В корне проекта выполните:
   - `xcodegen generate`
3. Откройте `CalenTask.xcodeproj` в Xcode.
4. Запустите на iPhone Simulator или реальном устройстве.

## Требуемые разрешения
Приложение запрашивает доступ к календарю (`NSCalendarsUsageDescription`) для создания событий из задач.
