import Foundation

/// A day of the calendar, without a time: when homework is due, not an instant
/// (ADR-0004, rule 1). Stored as `YYYY-MM-DD`, so that it does not move with
/// time zones or daylight saving.
///
/// Days are those of the Gregorian calendar, which the stored format names.
/// Rules that need "today" are given an instant and a calendar; the calendar's
/// time zone decides which day that instant falls on.
public struct CalendarDay: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    /// The day a stored `YYYY-MM-DD` names; nil for anything else, such as a
    /// value that is not a day of the calendar.
    public init?(storedValue: String) {
        let parts = storedValue.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
              let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2])
        else { return nil }
        let components = DateComponents(year: year, month: month, day: day)
        guard components.isValidDate(in: Self.gregorian) else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    /// The day on which the instant falls, in the calendar's time zone.
    public init(_ instant: Date, in calendar: Calendar) {
        var gregorian = Self.gregorian
        gregorian.timeZone = calendar.timeZone
        let components = gregorian.dateComponents([.year, .month, .day], from: instant)
        year = components.year!
        month = components.month!
        day = components.day!
    }

    /// `YYYY-MM-DD`, as it is stored.
    public var storedValue: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    public var description: String { storedValue }

    /// The day so many days later, or earlier for a negative number.
    public func adding(days: Int) -> CalendarDay {
        let later = Self.gregorian.date(byAdding: .day, value: days, to: noonUTC)!
        return CalendarDay(later, in: Self.gregorian)
    }

    /// 1 for Monday to 7 for Sunday, as ISO 8601 counts them.
    public var isoWeekday: Int {
        // Foundation counts Sunday as 1 and Saturday as 7.
        (Self.gregorian.component(.weekday, from: noonUTC) + 5) % 7 + 1
    }

    /// The start of the day in the calendar's time zone: for a date picker,
    /// or for "how many days until".
    public func startOfDay(in calendar: Calendar) -> Date {
        var gregorian = Self.gregorian
        gregorian.timeZone = calendar.timeZone
        return gregorian.date(from: DateComponents(year: year, month: month, day: day))!
    }

    public static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    // Arithmetic on days happens at noon UTC, far from any change of day.
    private static let gregorian: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private var noonUTC: Date {
        Self.gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}
