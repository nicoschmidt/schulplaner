import Foundation

/// The rule for a subject's name: not empty, and not the name of another
/// subject — ignoring case and the spaces around it. Storage cannot enforce
/// it (ADR-0003, rule 3), so the app asks here before it saves.
public enum SubjectName {
    public enum Verdict: Equatable, Sendable {
        /// The name to store: trimmed of surrounding spaces.
        case valid(String)
        case empty
        /// Another subject is already called that; its name as it is stored.
        case taken(by: String)
    }

    /// Checks a proposed name against the names of the other subjects. When a
    /// subject is renamed, its own current name is not among them.
    public static func check(_ proposed: String, against others: [String]) -> Verdict {
        let name = trimmed(proposed)
        guard !name.isEmpty else { return .empty }
        if let existing = others.first(where: { sameName(trimmed($0), name) }) {
            return .taken(by: existing)
        }
        return .valid(name)
    }

    static func trimmed(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Case-insensitive, also for umlauts: "ÄRZTE" and "ärzte" are the same name.
    static func sameName(_ first: String, _ second: String) -> Bool {
        first.compare(second, options: [.caseInsensitive], range: nil, locale: Locale(identifier: "de_DE"))
            == .orderedSame
    }
}
