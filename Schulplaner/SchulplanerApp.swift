import SwiftData
import SwiftUI

@main
struct SchulplanerApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try Store.container()
        } catch {
            // Without its store the app has nothing to show; the message is
            // in the crash log.
            fatalError("The store could not be opened: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
