import Foundation

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low: return "Низкий"
        case .medium: return "Средний"
        case .high: return "Высокий"
        }
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var note: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var priority: TaskPriority
    var isCompleted: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        priority: TaskPriority = .medium,
        isCompleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    var calendarStartDate: Date {
        if let startTime { return merge(date: date, time: startTime) }
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
    }

    var calendarEndDate: Date {
        if let endTime {
            let merged = merge(date: date, time: endTime)
            if merged > calendarStartDate { return merged }
        }
        return calendarStartDate.addingTimeInterval(3600)
    }

    private func merge(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        let clock = calendar.dateComponents([.hour, .minute], from: time)
        var result = DateComponents()
        result.year = day.year
        result.month = day.month
        result.day = day.day
        result.hour = clock.hour
        result.minute = clock.minute
        return calendar.date(from: result) ?? date
    }
}
