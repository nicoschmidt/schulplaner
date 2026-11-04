import SchulplanerKit
import Testing

// The example test of #7: it proves that the package's tests build and run,
// with `swift test` and in the app's scheme. Rules bring their own tests.
@Test func thePackageIsThere() {
    #expect(SchulplanerKit.isLinked)
}
