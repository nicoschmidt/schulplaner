import SchulplanerKit
import Testing

struct SubjectDeletionTests {
    @Test func aSubjectWithoutTasksIsDeletedWithoutAsking() {
        let deletion = SubjectDeletion(kindsOfTasks: [])
        #expect(deletion.homeworkCount == 0)
        #expect(!deletion.asksFirst)
    }

    @Test func theHomeworkThatGoesWithItIsCounted() {
        let deletion = SubjectDeletion(kindsOfTasks: [.homework, .homework, .homework])
        #expect(deletion.homeworkCount == 3)
        #expect(deletion.otherTaskCount == 0)
        #expect(deletion.asksFirst)
    }

    @Test func otherTasksAreCountedApart() {
        let deletion = SubjectDeletion(kindsOfTasks: [.homework, .studySession, .other])
        #expect(deletion.homeworkCount == 1)
        #expect(deletion.otherTaskCount == 2)
        #expect(deletion.asksFirst)
    }

    @Test func onlyOtherTasksStillAsk() {
        #expect(SubjectDeletion(kindsOfTasks: [.studySession]).asksFirst)
    }
}
