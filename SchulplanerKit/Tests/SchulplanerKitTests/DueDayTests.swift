import Foundation
import SchulplanerKit
import Testing

struct DueDayTests {
    @Test(arguments: [
        // An ordinary weekday: the next day.
        (instant(2026, 11, 10), "2026-11-11"), // Tuesday → Wednesday
        (instant(2026, 11, 12), "2026-11-13"), // Thursday → Friday
        // Friday, Saturday and Sunday: Monday.
        (instant(2026, 11, 13), "2026-11-16"),
        (instant(2026, 11, 14), "2026-11-16"),
        (instant(2026, 11, 15), "2026-11-16"),
        // The turn of a month, and of a year.
        (instant(2026, 10, 30), "2026-11-02"), // Friday → Monday in November
        (instant(2026, 4, 30), "2026-05-01"),  // Thursday → Friday in May
        (instant(2026, 12, 31), "2027-01-01"), // Thursday → Friday in January
    ])
    func theDefaultIsTheNextSchoolDay(today: Date, expected: String) {
        #expect(DueDay.nextSchoolDay(after: today, in: calendar()).storedValue == expected)
    }

    @Test func lateOnSundayEveningTheDefaultIsStillMonday() {
        #expect(DueDay.nextSchoolDay(after: instant(2026, 11, 15, 23, 59), in: calendar()).storedValue == "2026-11-16")
    }

    @Test func justAfterMidnightTheNewDayCounts() {
        // 00:05 on a Saturday: the next school day is Monday, not Saturday.
        #expect(DueDay.nextSchoolDay(after: instant(2026, 11, 14, 0, 5), in: calendar()).storedValue == "2026-11-16")
    }

    @Test func theQuickChoicesCountCalendarDays() {
        let friday = instant(2026, 11, 27)
        let days = DueDay.QuickChoice.allCases.map { $0.day(after: friday, in: calendar()).storedValue }
        #expect(days == ["2026-11-28", "2026-11-29", "2026-12-04"])
    }
}

struct HomeworkNoteTests {
    @Test func theNoteIsStoredWithoutTheSpaceAroundIt() {
        #expect(HomeworkNote.normalized("  S. 42 Nr. 3 \n") == "S. 42 Nr. 3")
    }

    @Test(arguments: ["", "   ", "\n"])
    func anEmptyNoteIsNone(_ typed: String) {
        #expect(HomeworkNote.normalized(typed) == nil)
    }
}
