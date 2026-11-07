import SchulplanerKit
import Testing

struct TaskKindTests {
    @Test(arguments: TaskKind.allCases)
    func aKnownKindReadsAsItself(_ kind: TaskKind) {
        #expect(TaskKind(storedValue: kind.rawValue) == kind)
    }

    @Test(arguments: ["lessonPrep", "", "Homework"])
    func anUnknownKindReadsAsOther(_ stored: String) {
        #expect(TaskKind(storedValue: stored) == .other)
    }
}
