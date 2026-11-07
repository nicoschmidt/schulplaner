import Foundation
import SwiftData
import Testing
@testable import Schulplaner

/// Storage as ADR-0003 sets it up.
@MainActor
struct StoreTests {
    @Test func theStoreIsSchemaVersionOne() throws {
        let container = try Store.container(.memory)
        #expect(container.schema.version == Schema.Version(1, 0, 0))
        #expect(Set(container.schema.entities.map(\.name)) == ["Subject", "Task"])
    }

    @Test func iCloudSyncIsOff() throws {
        for location in [Store.Location.memory, .file(temporaryStoreURL())] {
            let container = try Store.container(location)
            #expect(container.configurations.allSatisfy { $0.cloudKitContainerIdentifier == nil })
        }
    }

    @Test func subjectsAreStillThereWhenTheAppStartsAgain() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        do {
            let container = try Store.container(.file(url))
            try Subjects(context: container.mainContext).add([
                .init(name: "Chemie", colorKey: "teal", symbolName: "flask"),
                .init(name: "Physik", colorKey: "indigo", symbolName: "atom"),
            ])
        }

        let reopened = try Store.container(.file(url))
        let names = try Subjects(context: reopened.mainContext).all().map(\.name)
        #expect(names == ["Chemie", "Physik"])
    }

    @Test func deletingASubjectDeletesItsTasks() throws {
        let container = try Store.container(.memory)
        let context = container.mainContext
        let subjects = Subjects(context: context)
        let (biology, music) = try {
            let added = try subjects.add([
                .init(name: "Biologie", colorKey: "green", symbolName: "leaf"),
                .init(name: "Musik", colorKey: "orange", symbolName: "music.note"),
            ])
            return (added[0], added[1])
        }()
        context.insert(SchoolTask(kind: "homework", title: "Zelle zeichnen", dueDay: "2026-11-12", subject: biology))
        context.insert(SchoolTask(kind: "homework", title: "Lied üben", dueDay: "2026-11-13", subject: music))
        try context.save()

        try subjects.delete(biology)

        let titles = try context.fetch(FetchDescriptor<SchoolTask>()).map(\.title)
        #expect(titles == ["Lied üben"])
    }
}

/// A store file in a directory of its own, so that SwiftData's side files
/// are cleaned up with it. SwiftData does not create the directory.
func temporaryStoreURL() -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory.appending(path: "Schulplaner.store")
}
