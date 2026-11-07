import SchulplanerKit
import SwiftData
import SwiftUI

/// The homework written down, soonest due first: to add to, to edit and to
/// delete. Grouping by when it is due, and ticking off, come with #12.
struct HomeworkListView: View {
    @Query(Homework.allHomework) private var tasks: [SchoolTask]

    @Environment(\.homework) private var homework
    @State private var adding = false
    @State private var editing: SchoolTask?
    @State private var failed = false

    var body: some View {
        List {
            ForEach(tasks) { task in
                Button {
                    editing = task
                } label: {
                    HomeworkRow(task: task)
                }
                .foregroundStyle(.primary)
                .accessibilityHint(Text("Bearbeiten"))
            }
            .onDelete { offsets in
                do {
                    for index in offsets { try homework.delete(tasks[index]) }
                } catch {
                    failed = true
                }
            }
        }
        .overlay {
            if tasks.isEmpty {
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
            Button {
                adding = true
            } label: {
                Label("Hausaufgabe eintragen", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
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
        .alert("Die Hausaufgabe konnte nicht gelöscht werden.", isPresented: $failed) {}
    }
}

/// One piece of homework: its subject's badge, the note, and subject and day.
struct HomeworkRow: View {
    let task: SchoolTask

    var body: some View {
        HStack(spacing: 12) {
            if let subject = task.subject {
                SubjectBadge(subject)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: task.title)
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
