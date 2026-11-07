import Foundation
import SchulplanerKit
import SwiftData
import SwiftUI

/// What the screens do with homework: the rules of SchulplanerKit applied to
/// the stored tasks of kind homework, and every change saved at once.
@MainActor
struct Homework {
    let context: ModelContext

    enum Problem: Error, Equatable {
        /// No title: it is the one thing required.
        case emptyTitle
    }

    /// The calendar the rules count days in: Gregorian, as the stored days
    /// are, in the device's time zone.
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    /// Every piece of homework, soonest due first, then in the order written
    /// down: for `all()`, and for the list's query.
    static var allHomework: FetchDescriptor<SchoolTask> {
        let homework = TaskKind.homework.rawValue
        return FetchDescriptor(
            predicate: #Predicate { $0.kind == homework },
            sortBy: [SortDescriptor(\.dueDay), SortDescriptor(\.createdAt)]
        )
    }

    func all() throws -> [SchoolTask] {
        try context.fetch(Self.allHomework)
    }

    @discardableResult
    func add(subject: Subject, title: String, notes: String = "", due: CalendarDay, now: Date = .now) throws -> SchoolTask {
        guard let title = HomeworkText.title(title) else { throw Problem.emptyTitle }
        let task = SchoolTask(
            kind: TaskKind.homework.rawValue,
            title: title,
            notes: HomeworkText.notes(notes),
            dueDay: due.storedValue,
            subject: subject,
            createdAt: now
        )
        context.insert(task)
        try context.save()
        return task
    }

    func update(_ task: SchoolTask, subject: Subject, title: String, notes: String, due: CalendarDay) throws {
        guard let title = HomeworkText.title(title) else { throw Problem.emptyTitle }
        task.subject = subject
        task.title = title
        task.notes = HomeworkText.notes(notes)
        task.dueDay = due.storedValue
        try context.save()
    }

    /// Ticks homework off: records when it was done, for the timeline (004)
    /// and the rewards (005) to build on.
    func complete(_ task: SchoolTask, at now: Date = .now) throws {
        task.completedAt = now
        try context.save()
    }

    /// Ticks homework back to open, as undo or from the done section.
    func reopen(_ task: SchoolTask) throws {
        task.completedAt = nil
        try context.save()
    }

    func delete(_ task: SchoolTask) throws {
        context.delete(task)
        try context.save()
    }
}

extension SchoolTask {
    /// The due day, as the rules know it. A stored value that is not a day —
    /// which this app never writes — reads as none.
    var due: CalendarDay? {
        CalendarDay(storedValue: dueDay)
    }
}

extension EnvironmentValues {
    /// The screens' way to `Homework`, on the environment's model context.
    @MainActor var homework: Homework {
        Homework(context: modelContext)
    }
}
