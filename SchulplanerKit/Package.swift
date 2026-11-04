// swift-tools-version: 6.0

// The domain logic of Schulplaner (ADR-0002): what decides a date, an order, a
// plan or a score, as pure functions of plain values. It imports neither
// SwiftUI, UIKit nor SwiftData (ADR-0004); scripts/check-kit-imports.sh checks
// that in CI.

import PackageDescription

let package = Package(
    name: "SchulplanerKit",
    platforms: [
        .iOS(.v18),
        // Not a target platform: it lets `swift test` run on the Mac, in
        // seconds and without a simulator.
        .macOS(.v15),
    ],
    products: [
        .library(name: "SchulplanerKit", targets: ["SchulplanerKit"]),
    ],
    targets: [
        .target(name: "SchulplanerKit"),
        .testTarget(name: "SchulplanerKitTests", dependencies: ["SchulplanerKit"]),
    ]
)
