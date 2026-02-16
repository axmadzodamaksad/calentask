import SwiftUI

@main
struct CalenTaskApp: App {
    @StateObject private var store = TaskStore()

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(store)
        }
    }
}
