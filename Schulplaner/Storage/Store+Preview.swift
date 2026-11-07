import Foundation
import SchulplanerKit
import SwiftData

extension Store {
    /// An in-memory store with invented subjects and homework, due in the days
    /// after today: for previews, and for the app started with
    /// `-preview-data` in a debug build, to look at screens with something on
    /// them. Never the device's store.
    @MainActor static let preview: ModelContainer = {
        let container = try! Store.container(.memory)
        let subjects = try! Subjects(context: container.mainContext).add([
            Subjects.Draft(name: "Deutsch", colorKey: "red", symbolName: "book.closed"),
            Subjects.Draft(name: "Mathematik", colorKey: "blue", symbolName: "function"),
            Subjects.Draft(name: "Englisch", colorKey: "indigo", symbolName: "bubble.left.and.bubble.right"),
            Subjects.Draft(name: "Biologie", colorKey: "green", symbolName: "leaf"),
            Subjects.Draft(name: "Theater-AG", colorKey: "purple", symbolName: "theatermasks"),
        ])
        let homework = Homework(context: container.mainContext)
        let today = CalendarDay(.now, in: Homework.calendar)
        for (subject, title, notes, days) in [
            (1, "Arbeitsblatt Brüche", "", 1),
            (0, "Gedicht auswendig lernen", "Die ersten drei Strophen.\nVortrag am Anfang der Stunde.", 2),
            (2, "Vokabeln Unit 3", "", 2),
            (1, "S. 42 Nr. 3 und 4", "Bei Nr. 4 nur die geraden Aufgaben.", 4),
            (3, "Zelle beschriften", "", 7),
        ] {
            try! homework.add(subject: subjects[subject], title: title, notes: notes, due: today.adding(days: days))
        }
        return container
    }()
}
