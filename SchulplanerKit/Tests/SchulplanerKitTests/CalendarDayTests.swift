import Foundation
import SchulplanerKit
import Testing

/// A Gregorian calendar in the given time zone, as the app's would be.
func calendar(_ timeZone: String = "Europe/Berlin") -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    return calendar
}

/// An instant given as local wall-clock time in that calendar.
func instant(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 10, _ minute: Int = 0,
             in calendar: Calendar = calendar()) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

struct CalendarDayTests {
    @Test func aStoredDayReadsAndWritesTheSame() throws {
        let day = try #require(CalendarDay(storedValue: "2026-03-07"))
        #expect((day.year, day.month, day.day) == (2026, 3, 7))
        #expect(day.storedValue == "2026-03-07")
    }

    @Test(arguments: ["", "2026-3-7", "07.03.2026", "2026-02-30", "2026-13-01", "2026-03-07T10:00", "abcd-ef-gh"])
    func anythingButADayIsNotOne(_ stored: String) {
        #expect(CalendarDay(storedValue: stored) == nil)
    }

    @Test func theDayOfAnInstantIsTheDayInTheCalendarsTimeZone() {
        // 23:30 in Berlin on 9 November is already 10 November in Tokyo.
        let lateEvening = instant(2026, 11, 9, 23, 30)
        #expect(CalendarDay(lateEvening, in: calendar()).storedValue == "2026-11-09")
        #expect(CalendarDay(lateEvening, in: calendar("Asia/Tokyo")).storedValue == "2026-11-10")
    }

    @Test func addingDaysCrossesMonthsAndYears() throws {
        let day = try #require(CalendarDay(storedValue: "2026-12-30"))
        #expect(day.adding(days: 3).storedValue == "2027-01-02")
        #expect(day.adding(days: -30).storedValue == "2026-11-30")
    }

    @Test func addingDaysIgnoresDaylightSaving() throws {
        // Summer time in Germany ends on 25 October 2026.
        let day = try #require(CalendarDay(storedValue: "2026-10-24"))
        #expect(day.adding(days: 1).storedValue == "2026-10-25")
        #expect(day.adding(days: 2).storedValue == "2026-10-26")
    }

    @Test func weekdaysCountFromMonday() throws {
        #expect(try #require(CalendarDay(storedValue: "2026-11-09")).isoWeekday == 1) // Monday
        #expect(try #require(CalendarDay(storedValue: "2026-11-15")).isoWeekday == 7) // Sunday
    }

    @Test func daysAreOrdered() throws {
        let earlier = try #require(CalendarDay(storedValue: "2026-11-30"))
        let later = try #require(CalendarDay(storedValue: "2026-12-01"))
        #expect(earlier < later)
    }

    @Test func theStartOfTheDayIsMidnightThere() throws {
        let day = try #require(CalendarDay(storedValue: "2026-11-09"))
        #expect(day.startOfDay(in: calendar()) == instant(2026, 11, 9, 0, 0))
    }
}
