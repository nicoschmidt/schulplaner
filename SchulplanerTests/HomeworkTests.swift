import Foundation
import SchulplanerKit
import SwiftData
import Testing
@testable import Schulplaner

/// Homework as the entry writes it down, on an in-memory store.
@MainActor
struct HomeworkTests {
    let container: ModelContainer
    let homework: Homework
    let math: Subject
    let german: Subject

    init() throws {
        container = try Store.container(.memory)
        homework = Homework(context: container.mainContext)
        let added = try Subjects(context: container.mainContext).add([
            .init(name: "Mathematik", colorKey: "blue", symbolName: "function"),
            .init(name: "Deutsch", colorKey: "red", symbolName: "book.closed"),
        ])
        (math, german) = (added[0], added[1])
    }

    private func day(_ stored: String) -> CalendarDay {
        CalendarDay(storedValue: stored)!
    }

    @Test func homeworkIsStoredAsATaskOfKindHomework() throws {
        let now = Date(timeIntervalSince1970: 1_794_000_000)
        try homework.add(subject: math, note: "  S. 42 Nr. 3 ", due: day("2026-11-16"), now: now)

        let task = try #require(try homework.all().first)
        #expect(task.kind == "homework")
        #expect(task.title == "S. 42 Nr. 3")
        #expect(task.dueDay == "2026-11-16")
        #expect(task.subject === math)
        #expect(task.createdAt == now)
        #expect(task.completedAt == nil)
    }

    @Test func aNoteOfNothingIsNotSaved() throws {
        #expect(throws: Homework.Problem.emptyNote) {
            try homework.add(subject: math, note: " ", due: day("2026-11-16"))
        }
        #expect(try homework.all().isEmpty)
    }

    @Test func homeworkIsListedSoonestDueFirstThenInTheOrderWrittenDown() throws {
        let start = Date(timeIntervalSince1970: 1_794_000_000)
        try homework.add(subject: math, note: "Später", due: day("2026-12-01"), now: start)
        try homework.add(subject: german, note: "Zuerst eingetragen", due: day("2026-11-16"), now: start)
        try homework.add(subject: math, note: "Danach eingetragen", due: day("2026-11-16"), now: start + 60)

        #expect(try homework.all().map(\.title) == ["Zuerst eingetragen", "Danach eingetragen", "Später"])
    }

    @Test func homeworkIsEdited() throws {
        let task = try homework.add(subject: math, note: "Arbeitsblatt", due: day("2026-11-16"))
        try homework.update(task, subject: german, note: "Gedicht lernen", due: day("2026-11-18"))
        #expect((task.subject === german, task.title, task.dueDay) == (true, "Gedicht lernen", "2026-11-18"))

        #expect(throws: Homework.Problem.emptyNote) {
            try homework.update(task, subject: german, note: "", due: day("2026-11-18"))
        }
        #expect(task.title == "Gedicht lernen")
    }

    @Test func homeworkIsDeletedAndItsSubjectStays() throws {
        let task = try homework.add(subject: math, note: "Arbeitsblatt", due: day("2026-11-16"))
        try homework.delete(task)
        #expect(try homework.all().isEmpty)
        #expect(try Subjects(context: container.mainContext).all().count == 2)
    }

    @Test func otherKindsOfTaskAreNotHomework() throws {
        container.mainContext.insert(SchoolTask(kind: "studySession", title: "Vokabeln", dueDay: "2026-11-16", subject: german))
        try container.mainContext.save()
        #expect(try homework.all().isEmpty)
    }

    @Test func theQuestionBeforeDeletingASubjectCountsItsHomework() throws {
        try homework.add(subject: math, note: "S. 42", due: day("2026-11-16"))
        try homework.add(subject: math, note: "S. 43", due: day("2026-11-17"))
        try homework.add(subject: german, note: "Lesen", due: day("2026-11-17"))

        let deletion = Subjects(context: container.mainContext).deletion(of: math)
        #expect(deletion.homeworkCount == 2)
    }

    @Test func aStoredDueDayIsReadAsACalendarDay() throws {
        let task = try homework.add(subject: math, note: "S. 42", due: day("2026-11-16"))
        #expect(task.due == day("2026-11-16"))
        task.dueDay = "Montag"
        #expect(task.due == nil)
    }
}
