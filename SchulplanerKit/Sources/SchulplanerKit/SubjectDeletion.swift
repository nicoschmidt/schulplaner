/// What deleting a subject takes with it: all of its tasks (ADR-0004, rule 4).
/// The app asks first when there is anything, and says how much.
public struct SubjectDeletion: Equatable, Sendable {
    public let homeworkCount: Int
    /// Tasks of every other kind. None exist in iteration 001, but deleting a
    /// subject takes them too once they do.
    public let otherTaskCount: Int

    public init(kindsOfTasks: [TaskKind]) {
        homeworkCount = kindsOfTasks.filter { $0 == .homework }.count
        otherTaskCount = kindsOfTasks.count - homeworkCount
    }

    /// Whether the app asks before deleting: only when tasks go with it.
    public var asksFirst: Bool {
        homeworkCount + otherTaskCount > 0
    }
}
