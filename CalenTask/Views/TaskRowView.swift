import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onCalendar: () -> Void

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                    Text(task.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            if !task.note.isEmpty {
                Text(task.note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label(task.priority.title, systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(priorityColor)

                Spacer()

                Button("В календарь", systemImage: "calendar.badge.plus") {
                    onCalendar()
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
