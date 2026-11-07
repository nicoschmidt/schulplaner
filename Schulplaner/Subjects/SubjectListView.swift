import SchulplanerKit
import SwiftData
import SwiftUI

/// The student's subjects: to edit, reorder, delete, and add to.
struct SubjectListView: View {
    @Environment(\.subjects) private var subjects
    @Query(sort: [SortDescriptor(\Subject.sortIndex), SortDescriptor(\Subject.createdAt)])
    private var all: [Subject]

    @State private var editing: Subject?
    @State private var adding = false
    @State private var pending: PendingDeletion?
    @State private var failed = false

    /// A subject that takes tasks with it, waiting for the student's answer.
    struct PendingDeletion {
        let subject: Subject
        let deletion: SubjectDeletion
    }

    var body: some View {
        List {
            ForEach(all) { subject in
                Button {
                    editing = subject
                } label: {
                    SubjectLabel(subject)
                }
                .foregroundStyle(.primary)
                .accessibilityHint(Text("Bearbeiten"))
            }
            .onMove { source, destination in
                attempt { try subjects.move(from: source, to: destination) }
            }
            .onDelete { offsets in
                guard let index = offsets.first else { return }
                askToDelete(all[index])
            }
        }
        .overlay {
            if all.isEmpty {
                ContentUnavailableView("Keine Fächer", systemImage: "books.vertical")
            }
        }
        .navigationTitle("Fächer")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Fächer hinzufügen", systemImage: "plus") { adding = true }
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }
        .sheet(item: $editing) { subject in
            NavigationStack {
                SubjectEditor(subject: subject)
            }
        }
        .sheet(isPresented: $adding) {
            NavigationStack {
                SubjectPickerView(purpose: .addMore)
            }
        }
        .confirmationDialog(
            pending.map { Text("„\($0.subject.name)“ löschen?") } ?? Text(verbatim: ""),
            isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
            titleVisibility: .visible,
            presenting: pending
        ) { pending in
            Button("Fach und Aufgaben löschen", role: .destructive) {
                attempt { try subjects.delete(pending.subject) }
            }
        } message: { pending in
            Text(Self.message(for: pending.deletion))
        }
        .alert("Die Änderung konnte nicht gesichert werden.", isPresented: $failed) {}
    }

    private func askToDelete(_ subject: Subject) {
        let deletion = subjects.deletion(of: subject)
        if deletion.asksFirst {
            pending = PendingDeletion(subject: subject, deletion: deletion)
        } else {
            attempt { try subjects.delete(subject) }
        }
    }

    private func attempt(_ change: () throws -> Void) {
        do { try change() } catch { failed = true }
    }

    /// How many tasks go with the subject, in words.
    static func message(for deletion: SubjectDeletion) -> String {
        var sentences: [String] = []
        if deletion.homeworkCount > 0 {
            sentences.append(String(localized: "Mit dem Fach werden \(deletion.homeworkCount) Hausaufgaben gelöscht."))
        }
        if deletion.otherTaskCount > 0 {
            sentences.append(String(localized: "Dazu \(deletion.otherTaskCount) weitere Aufgaben."))
        }
        return sentences.joined(separator: " ")
    }
}

#Preview {
    NavigationStack {
        SubjectListView()
    }
    .modelContainer(Store.preview)
}
