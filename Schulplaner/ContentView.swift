import SwiftUI

// A placeholder until the first screen arrives with #10: the app launches, in
// German, with every string from the String Catalog.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Noch nichts hier",
                systemImage: "book.closed",
                description: Text("Bald trägst du hier deine Hausaufgaben ein.")
            )
            .navigationTitle("Hausaufgaben")
        }
    }
}

#Preview {
    ContentView()
}
