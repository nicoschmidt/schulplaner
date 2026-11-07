import Foundation
import SchulplanerKit
import SwiftData
import Testing
@testable import Schulplaner

/// What the main screen shows, from the stored homework, on an in-memory store.
@MainActor
struct HomeworkBoardTests {
    let container: ModelContainer
    let homework: Homework
    let subject: Subject

    // Wednesday, 11 November 2026, 10:00 in Berlin.
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return calendar
    }()
    var now: Date { calendar.date(from: DateComponents(year: 2026, month: 11, day: 11, hour: 10))! }

    init() throws {
        container = try Store.container(.memory)
        homework = Homework(context: container.mainContext)
        subject = try Subjects(context: container.mainContext).add([
            .init(name: "Mathematik", colorKey: "blue", symbolName: "function"),
        ])[0]
    }

    @discardableResult
    private func add(_ title: String, due: String, minute: Int = 0) throws -> SchoolTask {
        try homework.add(subject: subject, title: title, due: CalendarDay(storedValue: due)!, now: now.addingTimeInterval(Double(minute) * 60))
    }

    private func board() throws -> HomeworkBoard {
        HomeworkBoard(try homework.all(), now: now, calendar: calendar)
    }

    @Test func openHomeworkIsGroupedOverdueFirst() throws {
        try add("Später", due: "2026-11-20")
        try add("Heute", due: "2026-11-11")
        try add("Überfällig", due: "2026-11-09")
        try add("Morgen", due: "2026-11-12")
        try add("Sonntag", due: "2026-11-15")

        let open = try board().open
        #expect(open.map(\.group) == [.overdue, .today, .tomorrow, .thisWeek, .later])
        #expect(open.map { $0.items.map(\.title) } == [["Überfällig"], ["Heute"], ["Morgen"], ["Sonntag"], ["Später"]])
    }

    @Test func tickingOffRecordsWhenAndMovesItToDone() throws {
        let task = try add("Arbeitsblatt", due: "2026-11-12")
        try homework.complete(task, at: now)

        #expect(task.completedAt == now)
        let board = try board()
        #expect(board.open.isEmpty)
        #expect(board.done.map(\.title) == ["Arbeitsblatt"])
    }

    @Test func undoAndTickingBackMakeItOpenAgain() throws {
        let task = try add("Arbeitsblatt", due: "2026-11-12")
        try homework.complete(task, at: now)
        try homework.reopen(task)

        #expect(task.completedAt == nil)
        #expect(try board().open.map(\.group) == [.tomorrow])
        #expect(try board().done.isEmpty)
    }

    @Test func doneShowsTheLastSevenDaysMostRecentFirst() throws {
        let day = 24.0 * 3600
        let earlier = try add("Vor drei Tagen", due: "2026-11-09")
        let recent = try add("Heute früh", due: "2026-11-11")
        let old = try add("Vor zwei Wochen", due: "2026-10-28")
        try homework.complete(earlier, at: now - 3 * day)
        try homework.complete(recent, at: now - 3600)
        try homework.complete(old, at: now - 14 * day)

        #expect(try board().done.map(\.title) == ["Heute früh", "Vor drei Tagen"])
        // Done long ago is no longer listed, but its completion time is kept.
        #expect(old.completedAt == now - 14 * day)
    }

    @Test func doneHomeworkCanBeEditedAndStaysDone() throws {
        let task = try add("Arbeitsblatt", due: "2026-11-12")
        try homework.complete(task, at: now)

        try homework.update(task, subject: subject, title: "Arbeitsblatt Brüche", notes: "Rückseite auch", due: CalendarDay(storedValue: "2026-11-12")!)

        #expect(task.completedAt == now)
        #expect(try board().done.map(\.title) == ["Arbeitsblatt Brüche"])
    }

    @Test func editedAndThenOpenedAgainFromItsDetails() throws {
        let task = try add("Arbeitsblatt", due: "2026-11-12")
        try homework.complete(task, at: now)

        // What the detail view's "Wieder öffnen" does: save, then reopen.
        try homework.update(task, subject: subject, title: "Arbeitsblatt", notes: "", due: CalendarDay(storedValue: "2026-11-13")!)
        try homework.reopen(task)

        #expect(task.completedAt == nil)
        #expect(try board().open.map(\.group) == [.thisWeek])
    }

    @Test func withNothingAtAllTheBoardIsEmpty() throws {
        #expect(try board().isEmpty)
        let task = try add("Arbeitsblatt", due: "2026-11-12")
        try homework.complete(task, at: now)
        #expect(try board().open.isEmpty)
        #expect(!(try board().isEmpty))
    }
}
