import EventKit
import Foundation

@MainActor
final class CalendarService {
    private let eventStore = EKEventStore()

    func addTaskToCalendar(_ task: TaskItem) async throws {
        let granted = try await requestAccessIfNeeded()
        guard granted else { throw CalendarError.permissionDenied }

        let event = EKEvent(eventStore: eventStore)
        event.title = task.title
        event.notes = task.note
        event.startDate = task.calendarStartDate
        event.endDate = task.calendarEndDate
        event.calendar = eventStore.defaultCalendarForNewEvents

        try eventStore.save(event, span: .thisEvent)
    }

    private func requestAccessIfNeeded() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
}

enum CalendarError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Нет доступа к календарю. Разрешите доступ в Настройках iPhone."
        }
    }
}
