import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: TaskStore

    let editingTask: TaskItem?

    @State private var title = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var withTime = true
    @State private var priority: TaskPriority = .medium

    var body: some View {
        NavigationStack {
            Form {
                Section("Задача") {
                    TextField("Название", text: $title)
                    TextField("Описание", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                    Picker("Приоритет", selection: $priority) {
                        ForEach(TaskPriority.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                }

                Section("Дата и время") {
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    Toggle("Указать время", isOn: $withTime)
                    if withTime {
                        DatePicker("Начало", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("Окончание", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle(editingTask == nil ? "Новая задача" : "Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: populateIfNeeded)
        }
    }

    private func populateIfNeeded() {
        guard let task = editingTask else { return }
        title = task.title
        note = task.note
        date = task.date
        priority = task.priority

        if let start = task.startTime, let end = task.endTime {
            withTime = true
            startTime = start
            endTime = end
        } else {
            withTime = false
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let task = TaskItem(
            id: editingTask?.id ?? UUID(),
            title: trimmedTitle,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            startTime: withTime ? startTime : nil,
            endTime: withTime ? endTime : nil,
            priority: priority,
            isCompleted: editingTask?.isCompleted ?? false,
            createdAt: editingTask?.createdAt ?? .now
        )

        store.addOrUpdate(task)
        dismiss()
    }
}
