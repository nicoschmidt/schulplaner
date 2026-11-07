import Foundation
import SwiftData

/// The first stored schema: subjects and tasks, as #10 shipped them. Kept as
/// it was, so that a store of this version can be migrated (`SchemaV2`).
///
/// Ready for iCloud sync from the start (ADR-0003, rules 1 and 2): no unique
/// attributes, every property optional or with a default, every relationship
/// optional with an inverse and never `deny`, order as an explicit sort value,
/// and a stable `id` on every entity. A change to any of this is a new schema
/// version with a migration stage and a test — never an edit here, once a
/// student has data in this version.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

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
        var title = ""
        /// A calendar day, `YYYY-MM-DD` (ADR-0004, rule 1).
        var dueDay = ""
        var completedAt: Date?
        var createdAt = Date.now
        var subject: Subject?

        init(kind: String, title: String, dueDay: String, subject: Subject?, createdAt: Date = .now) {
            self.kind = kind
            self.title = title
            self.dueDay = dueDay
            self.subject = subject
            self.createdAt = createdAt
        }
    }
}

