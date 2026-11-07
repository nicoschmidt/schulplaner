import Foundation
import Testing

// The app's setup.
struct AppSetupTests {
    @Test func theAppSpeaksGermanFirst() {
        #expect(Bundle.main.developmentLocalization == "de")
    }
}
