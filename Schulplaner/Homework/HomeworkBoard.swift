import Foundation
import SchulplanerKit

/// What the main screen shows of the homework, as of a moment: the open
/// homework in its groups, and what was done in the last seven days.
struct HomeworkBoard {
    let open: [(group: DueGroup, items: [SchoolTask])]
    /// Most recently done first.
    let done: [SchoolTask]

    /// `tasks` in the order the list wants within a group: soonest due first,
    /// then in the order written down.
    init(_ tasks: [SchoolTask], now: Date, calendar: Calendar) {
        open = DueGroup.grouped(tasks.filter { $0.completedAt == nil }, due: \.due, now: now, in: calendar)
        done = tasks
            .filter { task in
                task.completedAt.map { RecentlyDone.includes(doneAt: $0, now: now, in: calendar) } ?? false
            }
            .sorted { $0.completedAt! > $1.completedAt! }
    }

    var isEmpty: Bool { open.isEmpty && done.isEmpty }
}

extension DueGroup {
    var title: LocalizedStringResource {
        switch self {
        case .overdue: "Überfällig"
        case .today: "Heute"
        case .tomorrow: "Morgen"
        case .thisWeek: "Diese Woche"
        case .later: "Später"
        }
    }
}
