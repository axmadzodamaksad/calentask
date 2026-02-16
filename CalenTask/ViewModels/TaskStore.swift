import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var searchText = ""
    @Published var statusFilter: StatusFilter = .all
    @Published var sortOption: SortOption = .dateAsc
    @Published var alertMessage: String?

    private let storageKey = "calentask.ios.tasks.v1"
    private let calendarService = CalendarService()

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all
        case active
        case completed

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: return "Все"
            case .active: return "Активные"
            case .completed: return "Выполненные"
            }
        }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case dateAsc
        case dateDesc
        case priority
        case newest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dateAsc: return "Дата ↑"
            case .dateDesc: return "Дата ↓"
            case .priority: return "Приоритет"
            case .newest: return "Сначала новые"
            }
        }
    }

    init() {
        load()
    }

    var filteredTasks: [TaskItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return tasks
            .filter { task in
                let byStatus: Bool
                switch statusFilter {
                case .all: byStatus = true
                case .active: byStatus = !task.isCompleted
                case .completed: byStatus = task.isCompleted
                }

                guard byStatus else { return false }
                guard !query.isEmpty else { return true }

                let haystack = "\(task.title) \(task.note)".lowercased()
                return haystack.contains(query)
            }
            .sorted(by: sortPredicate)
    }

    func addOrUpdate(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        persist()
    }

    func delete(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        persist()
    }

    func toggleCompletion(_ task: TaskItem) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isCompleted.toggle()
        persist()
    }

    func addToCalendar(_ task: TaskItem) async {
        do {
            try await calendarService.addTaskToCalendar(task)
            alertMessage = "Событие добавлено в календарь"
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    private func sortPredicate(lhs: TaskItem, rhs: TaskItem) -> Bool {
        switch sortOption {
        case .dateAsc:
            return lhs.calendarStartDate < rhs.calendarStartDate
        case .dateDesc:
            return lhs.calendarStartDate > rhs.calendarStartDate
        case .priority:
            if lhs.priority != rhs.priority {
                return priorityRank(lhs.priority) < priorityRank(rhs.priority)
            }
            return lhs.calendarStartDate < rhs.calendarStartDate
        case .newest:
            return lhs.createdAt > rhs.createdAt
        }
    }

    private func priorityRank(_ p: TaskPriority) -> Int {
        switch p {
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            alertMessage = "Не удалось сохранить задачи"
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            tasks = []
        }
    }
}
