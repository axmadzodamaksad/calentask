import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var store: TaskStore

    @State private var showingCreate = false
    @State private var editingTask: TaskItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                filterBar

                if store.filteredTasks.isEmpty {
                    ContentUnavailableView(
                        "Пока нет задач",
                        systemImage: "checklist",
                        description: Text("Создайте первую задачу и добавьте ее в Apple Calendar")
                    )
                } else {
                    List {
                        ForEach(store.filteredTasks) { task in
                            TaskRowView(
                                task: task,
                                onToggle: { store.toggleCompletion(task) },
                                onCalendar: {
                                    Task { await store.addToCalendar(task) }
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { editingTask = task }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { store.delete(task) } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("CalenTask")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreate = true
                    } label: {
                        Label("Добавить", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $store.searchText, prompt: "Поиск по названию и описанию")
            .sheet(isPresented: $showingCreate) {
                TaskEditorView(editingTask: nil)
                    .environmentObject(store)
            }
            .sheet(item: $editingTask) { task in
                TaskEditorView(editingTask: task)
                    .environmentObject(store)
            }
            .alert("CalenTask", isPresented: .constant(store.alertMessage != nil), actions: {
                Button("OK") { store.alertMessage = nil }
            }, message: {
                Text(store.alertMessage ?? "")
            })
        }
    }

    private var filterBar: some View {
        HStack(spacing: 12) {
            Picker("Статус", selection: $store.statusFilter) {
                ForEach(TaskStore.StatusFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.menu)

            Picker("Сортировка", selection: $store.sortOption) {
                ForEach(TaskStore.SortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
