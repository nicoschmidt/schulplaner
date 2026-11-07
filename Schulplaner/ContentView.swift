import SwiftData
import SwiftUI

/// The app's first screen: choosing subjects, as long as there are none; then
/// the homework, with the way to the subjects.
struct ContentView: View {
    @Query private var subjects: [Subject]

    var body: some View {
        NavigationStack {
            if subjects.isEmpty {
                SubjectPickerView(purpose: .firstLaunch)
            } else {
                HomeworkListView()
            }
        }
    }
}

#Preview("Erster Start") {
    ContentView()
        .modelContainer(try! Store.container(.memory))
}

#Preview("Mit Fächern") {
    ContentView()
        .modelContainer(Store.preview)
}
