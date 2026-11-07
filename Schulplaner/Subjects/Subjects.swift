import SchulplanerKit
import SwiftData
import SwiftUI

/// What the screens do with subjects: the rules of SchulplanerKit applied to
/// the stored models, and every change saved at once. The screens hold no
/// rule of their own.
@MainActor
struct Subjects {
    let context: ModelContext

    /// A new subject, as the student chose or typed it.
    struct Draft: Equatable {
        var name: String
        var colorKey: String
        var symbolName: String
    }

    enum Problem: Error, Equatable {
        case empty
        case taken(by: String)
    }

    /// Every subject, in the student's order.
    func all() throws -> [Subject] {
        try context.fetch(FetchDescriptor<Subject>(sortBy: [SortDescriptor(\.sortIndex), SortDescriptor(\.createdAt)]))
    }

    /// The name rule, against every subject but the one being renamed.
    func check(_ name: String, renaming subject: Subject? = nil) throws -> SubjectName.Verdict {
        let others = try all().filter { $0 !== subject }.map(\.name)
        return SubjectName.check(name, against: others)
    }

    /// Adds subjects at the end, in the order given. Adds none when one of
    /// the names breaks the rule, also against another name in the same list.
    @discardableResult
    func add(_ drafts: [Draft]) throws -> [Subject] {
        var names = try all().map(\.name)
        var accepted: [Draft] = []
        for draft in drafts {
            let name = try validName(draft.name, against: names)
            names.append(name)
            accepted.append(Draft(name: name, colorKey: draft.colorKey, symbolName: draft.symbolName))
        }
        var next = (try all().map(\.sortIndex).max() ?? -1) + 1
        let subjects = accepted.map { draft in
            defer { next += 1 }
            let subject = Subject(name: draft.name, colorKey: draft.colorKey, symbolName: draft.symbolName, sortIndex: next)
            context.insert(subject)
            return subject
        }
        try context.save()
        return subjects
    }

    /// Renames, recolours or gives another symbol.
    func update(_ subject: Subject, name: String, colorKey: String, symbolName: String) throws {
        let others = try all().filter { $0 !== subject }.map(\.name)
        subject.name = try validName(name, against: others)
        subject.colorKey = colorKey
        subject.symbolName = symbolName
        try context.save()
    }

    /// Reorders as a list does when rows are dragged, and stores the order.
    func move(from source: IndexSet, to destination: Int) throws {
        var ordered = try all()
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, subject) in ordered.enumerated() where subject.sortIndex != index {
            subject.sortIndex = index
        }
        try context.save()
    }

    /// What deleting the subject would take with it, for the question before.
    func deletion(of subject: Subject) -> SubjectDeletion {
        SubjectDeletion(kindsOfTasks: (subject.tasks ?? []).map { TaskKind(storedValue: $0.kind) })
    }

    /// Deletes the subject and, by the cascade rule, its tasks.
    func delete(_ subject: Subject) throws {
        context.delete(subject)
        try context.save()
    }

    private func validName(_ name: String, against others: [String]) throws -> String {
        switch SubjectName.check(name, against: others) {
        case let .valid(name): name
        case .empty: throw Problem.empty
        case let .taken(by: existing): throw Problem.taken(by: existing)
        }
    }
}

extension EnvironmentValues {
    /// The screens' way to `Subjects`, on the environment's model context.
    @MainActor var subjects: Subjects {
        Subjects(context: modelContext)
    }
}
