import Foundation

/// When homework is due, unless the student says otherwise.
public enum DueDay {
    /// The next school day after today: Monday to Friday. Holidays are not
    /// known yet, so the next school day is the next weekday (#11); the
    /// timetable's next lesson of the subject takes over in iteration 002.
    public static func nextSchoolDay(after now: Date, in calendar: Calendar) -> CalendarDay {
        var day = CalendarDay(now, in: calendar).adding(days: 1)
        while day.isoWeekday > 5 {
            day = day.adding(days: 1)
        }
        return day
    }

    /// The quick choices of the entry, besides the default and a date picker.
    public enum QuickChoice: CaseIterable, Sendable {
        case tomorrow
        case dayAfterTomorrow
        case inAWeek

        /// The day the choice stands for, counted from today. Weekends are not
        /// skipped: "tomorrow" on a Friday is Saturday, as the student says it.
        public func day(after now: Date, in calendar: Calendar) -> CalendarDay {
            let today = CalendarDay(now, in: calendar)
            return switch self {
            case .tomorrow: today.adding(days: 1)
            case .dayAfterTomorrow: today.adding(days: 2)
            case .inAWeek: today.adding(days: 7)
            }
        }
    }
}

/// What the student types for a piece of homework: a title, such as
/// "S. 42 Nr. 3", which lists show, and notes with the details, which only the
/// homework itself shows. The title is the one thing to type, so it is the one
/// thing required.
public enum HomeworkText {
    /// The title to store, trimmed of the spaces and lines around it; nil when
    /// nothing is left.
    public static func title(_ typed: String) -> String? {
        let title = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? nil : title
    }

    /// The notes to store: as typed, lines and all, without the space and
    /// empty lines around them. Empty when there are none.
    public static func notes(_ typed: String) -> String {
        typed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
