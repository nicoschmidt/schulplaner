import Foundation
import SwiftData

/// The models of the current schema version. A new version moves these.
typealias Subject = SchemaV2.Subject
typealias SchoolTask = SchemaV2.Task

/// Every schema version, oldest first, and how to get from one to the next
/// (ADR-0003, rule 5).
enum SchulplanerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            // Version 2 adds Task.notes, with a default: nothing to convert.
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self),
        ]
    }
}

/// Where the app's data lives: on the device, never in iCloud until
/// iteration 007 (ADR-0003, rule 4), and in memory in tests (rule 6).
enum Store {
    enum Location {
        /// The device's store, in the app's container.
        case device
        /// Gone when the container is: for tests and previews.
        case memory
        /// A file of one's own: for tests that reopen a store.
        case file(URL)
    }

    static func container(_ location: Location = .device) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV2.self)
        let configuration = switch location {
        case .device:
            ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        case .memory:
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        case let .file(url):
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        }
        return try ModelContainer(
            for: schema,
            migrationPlan: SchulplanerMigrationPlan.self,
            configurations: configuration
        )
    }
}
