import SchulplanerKit
import SwiftData
import Testing
@testable import Schulplaner

/// The subjects as the screens change them, on an in-memory store.
@MainActor
struct SubjectsTests {
    let container: ModelContainer
    let subjects: Subjects

    init() throws {
        container = try Store.container(.memory)
        subjects = Subjects(context: container.mainContext)
    }

    private func names() throws -> [String] {
        try subjects.all().map(\.name)
    }

    @discardableResult
    private func add(_ names: String...) throws -> [Subject] {
        try subjects.add(names.map { .init(name: $0, colorKey: "gray", symbolName: "book.closed") })
    }

    @Test func subjectsAreAddedAtTheEndInTheOrderGiven() throws {
        try add("Deutsch", "Englisch")
        try add("Kunst")
        #expect(try names() == ["Deutsch", "Englisch", "Kunst"])
    }

    @Test func aNameIsStoredWithoutTheSpacesAroundIt() throws {
        try add("  Sport ")
        #expect(try names() == ["Sport"])
    }

    @Test func aSecondSubjectOfTheSameNameIsNotSaved() throws {
        try add("Mathematik")
        #expect(throws: Subjects.Problem.taken(by: "Mathematik")) { try add(" mathematik") }
        #expect(try names() == ["Mathematik"])
    }

    @Test func aListThatNamesASubjectTwiceAddsNone() throws {
        #expect(throws: Subjects.Problem.taken(by: "Latein")) { try add("Latein", "LATEIN") }
        #expect(try names().isEmpty)
    }

    @Test func anEmptyNameIsNotSaved() throws {
        #expect(throws: Subjects.Problem.empty) { try add("  ") }
    }

    @Test func aSubjectIsRenamedRecolouredAndGivenAnotherSymbol() throws {
        let subject = try add("Erdkunde")[0]
        try subjects.update(subject, name: "Geografie", colorKey: "green", symbolName: "globe.europe.africa")
        #expect((subject.name, subject.colorKey, subject.symbolName) == ("Geografie", "green", "globe.europe.africa"))
    }

    @Test func renamingKeepsTheRuleButNotAgainstItself() throws {
        let added = try add("Physik", "Chemie")
        try subjects.update(added[0], name: "PHYSIK", colorKey: "indigo", symbolName: "atom")
        #expect(throws: Subjects.Problem.taken(by: "Chemie")) {
            try subjects.update(added[0], name: "chemie", colorKey: "indigo", symbolName: "atom")
        }
        #expect(try names() == ["PHYSIK", "Chemie"])
    }

    @Test func checkLeavesOutTheSubjectBeingRenamed() throws {
        let added = try add("Musik", "Kunst")
        #expect(try subjects.check("musik", renaming: added[0]) == .valid("musik"))
        #expect(try subjects.check("Kunst", renaming: added[0]) == .taken(by: "Kunst"))
    }

    @Test func reorderingIsStored() throws {
        try add("Deutsch", "Mathematik", "Englisch")
        try subjects.move(from: [2], to: 0)
        #expect(try names() == ["Englisch", "Deutsch", "Mathematik"])
        #expect(try subjects.all().map(\.sortIndex) == [0, 1, 2])
    }

    @Test func theCountBeforeDeletingIsTheSubjectsHomework() throws {
        let added = try add("Geschichte", "Politik")
        let context = container.mainContext
        for title in ["Quelle lesen", "Zeitstrahl", "Referat"] {
            context.insert(SchoolTask(kind: "homework", title: title, dueDay: "2026-11-11", subject: added[0]))
        }
        context.insert(SchoolTask(kind: "homework", title: "Zeitung lesen", dueDay: "2026-11-11", subject: added[1]))
        context.insert(SchoolTask(kind: "lessonPrep", title: "Unbekannte Art", dueDay: "2026-11-11", subject: added[0]))
        try context.save()

        let deletion = subjects.deletion(of: added[0])
        #expect(deletion.homeworkCount == 3)
        #expect(deletion.otherTaskCount == 1)
        #expect(deletion.asksFirst)
        #expect(!subjects.deletion(of: try add("Ethik")[0]).asksFirst)
    }

    @Test func theQuestionNamesTheCount() {
        #expect(SubjectListView.message(for: SubjectDeletion(kindsOfTasks: [.homework])) ==
            "Mit dem Fach wird 1 Hausaufgabe gelöscht.")
        #expect(SubjectListView.message(for: SubjectDeletion(kindsOfTasks: [.homework, .homework, .other])) ==
            "Mit dem Fach werden 2 Hausaufgaben gelöscht. Dazu 1 weitere Aufgabe.")
    }
}
