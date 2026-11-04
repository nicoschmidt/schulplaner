import Foundation
import SchulplanerKit
import Testing

// The app's own tests: today its setup, later the code that translates its
// stored models into the plain values of SchulplanerKit (ADR-0004).
struct AppSetupTests {
    @Test func theAppSpeaksGermanFirst() {
        #expect(Bundle.main.developmentLocalization == "de")
    }

    @Test func theAppLinksTheDomainPackage() {
        #expect(SchulplanerKit.isLinked)
    }
}
