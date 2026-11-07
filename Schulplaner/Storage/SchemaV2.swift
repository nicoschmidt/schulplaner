import Foundation
import SwiftData

/// The second stored schema: a task gains notes, beside its title — the title
/// is what lists show, the notes are the details behind it. Migrated from
/// version 1 without loss: every task gets empty notes.
///
/// Follows the same rules as version 1 (ADR-0003, rules 1 and 2). The models
/// are copies of version 1's with the change, because each schema version has
/// models of its own.
enum SchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Subject.self, Task.self]
    }

    @Model
    final class Subject {
        var id = UUID()
        var name = ""
        /// A key of `SubjectPalette.colors`.
        var colorKey = SubjectPalette.fallbackColor.key
        /// An SF Symbol of `SubjectPalette.symbols`.
        var symbolName = SubjectPalette.fallbackSymbol.name
        var sortIndex = 0
        var createdAt = Date.now

        /// Deleting a subject deletes its tasks (ADR-0004, rule 4).
        @Relationship(deleteRule: .cascade, inverse: \Task.subject)
        var tasks: [Task]? = []

        init(name: String, colorKey: String, symbolName: String, sortIndex: Int, createdAt: Date = .now) {
            self.name = name
            self.colorKey = colorKey
            self.symbolName = symbolName
            self.sortIndex = sortIndex
            self.createdAt = createdAt
        }
    }

    /// Everything to do: homework now, study sessions and more later (ADR-0004).
    /// Called `SchoolTask` in the app's code, where `Task` is Swift's own.
    @Model
    final class Task {
        var id = UUID()
        /// The raw value of `TaskKind`; read through `TaskKind(storedValue:)`.
        var kind = "homework"
        /// What lists show: short, such as "S. 42 Nr. 3".
        var title = ""
        /// The details, as long as the student likes; shown only with the
        /// task itself. New in version 2.
        var notes = ""
        /// A calendar day, `YYYY-MM-DD` (ADR-0004, rule 1).
        var dueDay = ""
        var completedAt: Date?
        var createdAt = Date.now
        var subject: Subject?

        init(kind: String, title: String, notes: String = "", dueDay: String, subject: Subject?, createdAt: Date = .now) {
            self.kind = kind
            self.title = title
            self.notes = notes
            self.dueDay = dueDay
            self.subject = subject
            self.createdAt = createdAt
        }
    }
}
