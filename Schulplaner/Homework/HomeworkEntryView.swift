import SchulplanerKit
import SwiftData
import SwiftUI

/// Writing down homework in a few seconds: a tap on the subject, the title,
/// save. Notes with the details are there for whoever wants them, and shown
/// only here. The due day is already the next school day; quick choices and a
/// date picker change it. Also the place to edit or delete a piece of homework.
struct HomeworkEntryView: View {
    /// The homework being edited; none for new homework.
    let editing: SchoolTask?

    @Environment(\.homework) private var homework
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Subject.sortIndex), SortDescriptor(\Subject.createdAt)])
    private var subjects: [Subject]

    @State private var subject: Subject?
    @State private var title: String
    @State private var notes: String
    @State private var due: CalendarDay
    @State private var failed = false
    @FocusState private var titleFocused: Bool

    private let now: Date

    init(editing: SchoolTask? = nil, now: Date = .now) {
        self.editing = editing
        self.now = now
        _subject = State(initialValue: editing?.subject)
        _title = State(initialValue: editing?.title ?? "")
        _notes = State(initialValue: editing?.notes ?? "")
        _due = State(initialValue: editing?.due ?? DueDay.nextSchoolDay(after: now, in: Homework.calendar))
    }

    var body: some View {
        Form {
            Section("Fach") {
                FlowLayout {
                    ForEach(subjects) { option in
                        Chip(selected: option === subject, tint: SubjectPalette.color(for: option.colorKey).color) {
                            subject = option
                            titleFocused = true
                        } label: {
                            HStack(spacing: 6) {
                                SubjectBadge(option, size: 22)
                                Text(verbatim: option.name)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Was ist auf?") {
                TextField("z. B. S. 42 Nr. 3", text: $title)
                    .focused($titleFocused)
                    .submitLabel(.done)
                    .onSubmit(save)
            }

            Section("Notiz") {
                TextField("Einzelheiten, wenn nötig", text: $notes, axis: .vertical)
                    .lineLimit(3...)
            }

            Section("Bis wann?") {
                FlowLayout {
                    ForEach(DueDay.QuickChoice.allCases, id: \.self) { choice in
                        let day = choice.day(after: now, in: Homework.calendar)
                        Chip(selected: day == due) {
                            due = day
                        } label: {
                            Text(choice.label)
                        }
                    }
                }
                .padding(.vertical, 4)
                DatePicker("Fällig am", selection: dueDate, in: earliest..., displayedComponents: .date)
            }

            if let editing {
                Section {
                    if editing.completedAt == nil {
                        Button("Als erledigt markieren", systemImage: "checkmark.circle") {
                            saveAndMark(editing, done: true)
                        }
                        .disabled(!canSave)
                    } else {
                        Button("Wieder öffnen", systemImage: "arrow.uturn.backward.circle") {
                            saveAndMark(editing, done: false)
                        }
                        .disabled(!canSave)
                    }
                    Button("Hausaufgabe löschen", systemImage: "trash", role: .destructive) {
                        attempt { try homework.delete(editing) }
                    }
                } footer: {
                    if let completed = editing.completedAt {
                        Text("Erledigt am \(completed, format: .dateTime.weekday(.wide).day().month(.wide).hour().minute())")
                    }
                }
            }
        }
        .navigationTitle(editing == nil ? "Neue Hausaufgabe" : "Hausaufgabe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Group {
                    if #available(iOS 26, *) {
                        Button(role: .confirm, action: save)
                    } else {
                        Button("Sichern", action: save)
                    }
                }
                .disabled(!canSave)
            }
        }
        .alert("Die Hausaufgabe konnte nicht gesichert werden.", isPresented: $failed) {}
    }

    private var canSave: Bool {
        subject != nil && HomeworkText.title(title) != nil
    }

    /// The date picker's day, as the calendar day it stands for.
    private var dueDate: Binding<Date> {
        Binding {
            due.startOfDay(in: Homework.calendar)
        } set: {
            due = CalendarDay($0, in: Homework.calendar)
        }
    }

    /// Homework is due today or later; an older day stays choosable for
    /// homework that already has it.
    private var earliest: Date {
        min(CalendarDay(now, in: Homework.calendar), due).startOfDay(in: Homework.calendar)
    }

    private func save() {
        guard let subject, canSave else { return }
        attempt {
            if let editing {
                try homework.update(editing, subject: subject, title: title, notes: notes, due: due)
            } else {
                try homework.add(subject: subject, title: title, notes: notes, due: due, now: now)
            }
        }
    }

    /// Saves what was changed in the form, then ticks the homework off or
    /// back to open, and closes: one tap, like saving.
    private func saveAndMark(_ task: SchoolTask, done: Bool) {
        guard let subject, canSave else { return }
        attempt {
            try homework.update(task, subject: subject, title: title, notes: notes, due: due)
            if done {
                try homework.complete(task, at: .now)
            } else {
                try homework.reopen(task)
            }
        }
    }

    private func attempt(_ change: () throws -> Void) {
        do {
            try change()
            dismiss()
        } catch {
            failed = true
        }
    }
}

extension DueDay.QuickChoice {
    var label: LocalizedStringResource {
        switch self {
        case .tomorrow: "Morgen"
        case .dayAfterTomorrow: "Übermorgen"
        case .inAWeek: "In einer Woche"
        }
    }
}

#Preview("Neu") {
    NavigationStack {
        HomeworkEntryView()
    }
    .modelContainer(Store.preview)
}

#Preview("Erledigt") {
    // Done homework from the preview data, scrolled to the buttons at the end.
    let container = Store.preview
    let done = try! Homework(context: container.mainContext).all().first { $0.completedAt != nil }!
    return NavigationStack {
        HomeworkEntryView(editing: done)
            .defaultScrollAnchor(.bottom)
    }
    .modelContainer(container)
}
