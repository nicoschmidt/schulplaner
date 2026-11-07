import Foundation
import SchulplanerKit
import Testing

private func day(_ stored: String) -> CalendarDay {
    CalendarDay(storedValue: stored)!
}

struct DueGroupTests {
    // Wednesday, 11 November 2026, in the morning.
    let wednesday = instant(2026, 11, 11)

    @Test(arguments: [
        ("2026-11-02", DueGroup.overdue),  // last week
        ("2026-11-10", .overdue),          // yesterday
        ("2026-11-11", .today),
        ("2026-11-12", .tomorrow),
        ("2026-11-13", .thisWeek),         // Friday
        ("2026-11-15", .thisWeek),         // Sunday: the week's last day
        ("2026-11-16", .later),            // next Monday
        ("2027-01-04", .later),
    ])
    func everyGroup(due: String, group: DueGroup) {
        #expect(DueGroup.of(day(due), now: wednesday, in: calendar()) == group)
    }

    @Test func onSundayMondayIsTomorrowAndTheWeekIsOver() {
        let sunday = instant(2026, 11, 15)
        #expect(DueGroup.of(day("2026-11-16"), now: sunday, in: calendar()) == .tomorrow)
        #expect(DueGroup.of(day("2026-11-17"), now: sunday, in: calendar()) == .later)
    }

    @Test func onSaturdaySundayIsTomorrowAndMondayIsLater() {
        let saturday = instant(2026, 11, 14)
        #expect(DueGroup.of(day("2026-11-15"), now: saturday, in: calendar()) == .tomorrow)
        #expect(DueGroup.of(day("2026-11-16"), now: saturday, in: calendar()) == .later)
    }

    @Test func atMidnightTomorrowBecomesTodayAndTodayOverdue() {
        let lateMonday = instant(2026, 11, 9, 23, 59)
        let earlyTuesday = instant(2026, 11, 10, 0, 1)
        #expect(DueGroup.of(day("2026-11-10"), now: lateMonday, in: calendar()) == .tomorrow)
        #expect(DueGroup.of(day("2026-11-10"), now: earlyTuesday, in: calendar()) == .today)
        #expect(DueGroup.of(day("2026-11-09"), now: lateMonday, in: calendar()) == .today)
        #expect(DueGroup.of(day("2026-11-09"), now: earlyTuesday, in: calendar()) == .overdue)
    }

    @Test func theWeekEndsAcrossAMonth() {
        // Thursday, 29 October: the week runs to Sunday, 1 November.
        let thursday = instant(2026, 10, 29)
        #expect(DueGroup.of(day("2026-11-01"), now: thursday, in: calendar()) == .thisWeek)
        #expect(DueGroup.of(day("2026-11-02"), now: thursday, in: calendar()) == .later)
    }

    @Test func groupsComeInOrderWithoutEmptyOnesAndKeepTheItemsOrder() {
        let items: [(String, String?)] = [
            ("a", "2026-11-20"), ("b", "2026-11-11"), ("c", "2026-11-01"),
            ("d", "2026-11-11"), ("e", nil), ("f", "2026-11-25"),
        ]
        let groups = DueGroup.grouped(items, due: { $0.1.flatMap(CalendarDay.init(storedValue:)) }, now: wednesday, in: calendar())
        #expect(groups.map(\.group) == [.overdue, .today, .later])
        #expect(groups.map { $0.items.map(\.0) } == [["c"], ["b", "d"], ["a", "e", "f"]])
    }

    @Test func nothingGivesNoGroups() {
        #expect(DueGroup.grouped([Int](), due: { _ in nil }, now: wednesday, in: calendar()).isEmpty)
    }
}

struct RecentlyDoneTests {
    let now = instant(2026, 11, 11, 18, 0)

    @Test(arguments: [
        (instant(2026, 11, 11, 7, 30), true),   // this morning
        (instant(2026, 11, 5, 0, 0), true),     // the first moment of the seventh day
        (instant(2026, 11, 4, 23, 59), false),  // the day before that
        (instant(2026, 10, 20), false),
    ])
    func theLastSevenDaysTodayIncluded(done: Date, listed: Bool) {
        #expect(RecentlyDone.includes(doneAt: done, now: now, in: calendar()) == listed)
    }
}
