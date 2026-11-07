import SwiftData

extension Store {
    /// An in-memory store with invented subjects and homework, for previews.
    @MainActor static let preview: ModelContainer = {
        let container = try! Store.container(.memory)
        let subjects = Subjects(context: container.mainContext)
        let added = try! subjects.add([
            Subjects.Draft(name: "Deutsch", colorKey: "red", symbolName: "book.closed"),
            Subjects.Draft(name: "Mathematik", colorKey: "blue", symbolName: "function"),
            Subjects.Draft(name: "Biologie", colorKey: "green", symbolName: "leaf"),
            Subjects.Draft(name: "Theater-AG", colorKey: "purple", symbolName: "theatermasks"),
        ])
        for title in ["Arbeitsblatt Brüche", "Seite 42, Nr. 3"] {
            container.mainContext.insert(SchoolTask(kind: "homework", title: title, dueDay: "2026-11-10", subject: added[1]))
        }
        try! container.mainContext.save()
        return container
    }()
}
