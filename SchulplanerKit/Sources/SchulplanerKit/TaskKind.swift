/// What kind of thing to do a task is (ADR-0004). Stored as its raw value.
public enum TaskKind: String, CaseIterable, Sendable {
    case homework
    case studySession
    case other

    /// The kind a stored value stands for. A value this version does not know —
    /// written by a newer one on another device — reads as `other`, and is
    /// never rewritten (ADR-0004, rule 2).
    public init(storedValue: String) {
        self = TaskKind(rawValue: storedValue) ?? .other
    }
}
