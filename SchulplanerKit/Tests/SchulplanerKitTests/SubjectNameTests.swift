import SchulplanerKit
import Testing

struct SubjectNameTests {
    @Test func aNewNameIsStoredWithoutTheSpacesAroundIt() {
        #expect(SubjectName.check("  Mathematik ", against: ["Deutsch"]) == .valid("Mathematik"))
    }

    @Test(arguments: ["", "   ", "\n\t"])
    func aNameOfNothingButSpacesIsEmpty(_ proposed: String) {
        #expect(SubjectName.check(proposed, against: []) == .empty)
    }

    @Test(arguments: ["Mathematik", "mathematik", "MATHEMATIK", " Mathematik  "])
    func theSameNameIgnoringCaseAndSpacesIsTaken(_ proposed: String) {
        #expect(SubjectName.check(proposed, against: ["Deutsch", "Mathematik"]) == .taken(by: "Mathematik"))
    }

    @Test func aStoredNameWithStraySpacesStillCounts() {
        #expect(SubjectName.check("Kunst", against: ["Kunst "]) == .taken(by: "Kunst "))
    }

    @Test func umlautsAreComparedWithoutCase() {
        #expect(SubjectName.check("ÖKONOMIE", against: ["Ökonomie"]) == .taken(by: "Ökonomie"))
    }

    @Test func aSimilarNameIsNotTheSame() {
        #expect(SubjectName.check("Mathe", against: ["Mathematik"]) == .valid("Mathe"))
        #expect(SubjectName.check("Englisch LK", against: ["Englisch"]) == .valid("Englisch LK"))
    }

    @Test func renamingASubjectToItsOwnNameIsAllowed() {
        // The app leaves the subject's own name out of the others.
        #expect(SubjectName.check("Physik", against: ["Chemie"]) == .valid("Physik"))
    }
}
