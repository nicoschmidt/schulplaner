import Combine
import SchulplanerKit
import SwiftData
import SwiftUI

/// The main screen: open homework by when it is due, overdue first, to tick
/// off; what was done in the last seven days, to tick back; and the way to
/// write down more.
struct HomeworkListView: View {
    @Query(Homework.allHomework) private var tasks: [SchoolTask]

    @Environment(\.homework) private var homework
    @Environment(\.scenePhase) private var scenePhase

    /// The moment the groups are computed for: renewed when the day changes
    /// while the app is open, and when it returns to the foreground.
    @State private var now = Date.now
    @State private var adding = false
    @State private var editing: SchoolTask?
    @State private var showsDone = false
    /// Homework just ticked off, while its undo is offered.
    @State private var justDone: SchoolTask?
    @State private var failed = false

    var body: some View {
        let board = HomeworkBoard(tasks, now: now, calendar: Homework.calendar)

        List {
            if board.open.isEmpty, !board.done.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Alles erledigt",
                        systemImage: "checkmark.seal",
                        description: Text("Gerade ist nichts offen. Gut gemacht!")
                    )
                }
                .listRowBackground(Color.clear)
            }

            ForEach(board.open, id: \.group) { group, items in
                Section(group.title) {
                    ForEach(items) { task in
                        openRow(task)
                    }
                    .onDelete { offsets in
                        attempt { for index in offsets { try homework.delete(items[index]) } }
                    }
                }
            }

            if !board.done.isEmpty {
                Section {
                    DisclosureGroup(isExpanded: $showsDone) {
                        ForEach(board.done) { task in
                            doneRow(task)
                        }
                    } label: {
                        Text("Erledigt (\(board.done.count))")
                    }
                } footer: {
                    Text("Was du in den letzten sieben Tagen erledigt hast.")
                }
            }
        }
        .overlay {
            if board.isEmpty {
                ContentUnavailableView(
                    "Noch keine Hausaufgaben",
                    systemImage: "book.closed",
                    description: Text("Trag ein, was aufgegeben wurde.")
                )
            }
        }
        .navigationTitle("Hausaufgaben")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    SubjectListView()
                } label: {
                    Label("Fächer", systemImage: "books.vertical")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if let justDone {
                    undoBanner(for: justDone)
                }
                Button {
                    adding = true
                } label: {
                    Label("Hausaufgabe eintragen", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
        .sheet(isPresented: $adding) {
            NavigationStack {
                HomeworkEntryView()
            }
        }
        .sheet(item: $editing) { task in
            NavigationStack {
                HomeworkEntryView(editing: task)
            }
        }
        .task(id: justDone) {
            // The undo stays for a few seconds, then goes.
            guard justDone != nil else { return }
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled { justDone = nil }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { now = .now }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
            now = .now
        }
        .alert("Die Änderung konnte nicht gesichert werden.", isPresented: $failed) {}
    }

    private func openRow(_ task: SchoolTask) -> some View {
        HStack(spacing: 12) {
            Button {
                tick(task)
            } label: {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(Text("Abhaken"))

            Button {
                editing = task
            } label: {
                HomeworkRow(task: task)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Bearbeiten"))
        }
        .swipeActions(edge: .leading) {
            Button("Erledigt", systemImage: "checkmark") { tick(task) }
                .tint(.green)
        }
    }

    private func doneRow(_ task: SchoolTask) -> some View {
        HStack(spacing: 12) {
            Button {
                attempt { try homework.reopen(task) }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(Text("Wieder öffnen"))

            Button {
                editing = task
            } label: {
                HomeworkRow(task: task, done: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Bearbeiten"))
        }
    }

    private func undoBanner(for task: SchoolTask) -> some View {
        HStack {
            Text("„\(task.title)“ erledigt")
                .lineLimit(2)
            Spacer()
            Button("Rückgängig") {
                attempt { try homework.reopen(task) }
                justDone = nil
            }
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
    }

    private func tick(_ task: SchoolTask) {
        attempt { try homework.complete(task) }
        justDone = task
    }

    private func attempt(_ change: () throws -> Void) {
        do { try change() } catch { failed = true }
    }
}

/// One piece of homework: its subject's badge, the title, and subject and day.
/// Done homework shows struck through.
struct HomeworkRow: View {
    let task: SchoolTask
    var done = false

    var body: some View {
        HStack(spacing: 12) {
            if let subject = task.subject {
                SubjectBadge(subject)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: task.title)
                    .strikethrough(done)
                    .foregroundStyle(done ? .secondary : .primary)
                Group {
                    if let due = task.due {
                        Text("\(task.subject?.name ?? "") · \(due.startOfDay(in: Homework.calendar), format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))")
                    } else {
                        Text(verbatim: task.subject?.name ?? "")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeworkListView()
    }
    .modelContainer(Store.preview)
}
