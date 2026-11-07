import SwiftData
import SwiftUI

/// The app's first screen: choosing subjects, as long as there are none; then
/// the place where homework will be (#11, #12), with the way to the subjects.
struct ContentView: View {
    @Query private var subjects: [Subject]

    var body: some View {
        NavigationStack {
            if subjects.isEmpty {
                SubjectPickerView(purpose: .firstLaunch)
            } else {
                ContentUnavailableView(
                    "Noch keine Hausaufgaben",
                    systemImage: "book.closed",
                    description: Text("Bald trägst du hier deine Hausaufgaben ein.")
                )
                .navigationTitle("Hausaufgaben")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            SubjectListView()
                        } label: {
                            Label("Fächer", systemImage: "books.vertical")
                        }
                    }
                }
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
