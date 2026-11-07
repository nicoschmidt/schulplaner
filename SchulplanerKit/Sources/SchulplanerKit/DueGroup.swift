import Foundation

/// When open homework is due, as the main screen groups it. Weeks run Monday
/// to Sunday.
public enum DueGroup: Int, CaseIterable, Comparable, Sendable {
    /// Before today.
    case overdue
    case today
    case tomorrow
    /// After tomorrow, up to and including this week's Sunday.
    case thisWeek
    /// After this week.
    case later

    /// The group of a due day, seen from now.
    public static func of(_ due: CalendarDay, now: Date, in calendar: Calendar) -> DueGroup {
        let today = CalendarDay(now, in: calendar)
        let sunday = today.adding(days: 7 - today.isoWeekday)
        switch due {
        case ..<today: return .overdue
        case today: return .today
        case today.adding(days: 1): return .tomorrow
        case ...sunday: return .thisWeek
        default: return .later
        }
    }

    /// The items in their groups, in the order of the groups; empty groups
    /// are left out. Within a group, items keep the order they came in. An
    /// item without a due day it can read goes to `later`.
    public static func grouped<Item>(
        _ items: [Item],
        due: (Item) -> CalendarDay?,
        now: Date,
        in calendar: Calendar
    ) -> [(group: DueGroup, items: [Item])] {
        var byGroup: [DueGroup: [Item]] = [:]
        for item in items {
            let group = due(item).map { of($0, now: now, in: calendar) } ?? .later
            byGroup[group, default: []].append(item)
        }
        return allCases.compactMap { group in
            byGroup[group].map { (group: group, items: $0) }
        }
    }

    public static func < (lhs: DueGroup, rhs: DueGroup) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Which done homework the main screen still lists: what was done on one of
/// the last seven days, today included.
public enum RecentlyDone {
    public static let days = 7

    public static func includes(doneAt completed: Date, now: Date, in calendar: Calendar) -> Bool {
        let today = CalendarDay(now, in: calendar)
        let day = CalendarDay(completed, in: calendar)
        return day > today.adding(days: -days) && day <= today
    }
}
