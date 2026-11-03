# Architecture

Derived from the accepted ADRs in [docs/adr/](adr/README.md) and updated in
the same pull request that accepts one. Where this document and an ADR
disagree, the ADR wins.

## Platform

A native iPhone app in Swift 6 and SwiftUI, for iOS 18 and later
([ADR-0002](adr/0002-native-swiftui-app-for-ios-18-with-a-local-domain-package.md)).
APIs of newer iOS versions are used behind availability checks with a
fallback. Bundle identifier `io.github.nicoschmidt.schulplaner`.

No dependencies beyond Apple's frameworks; a third-party package needs its
own ADR and an entry on the allowlist that CI checks.

## Structure

```
┌──────────────────────────────────┐
│  App (Xcode project)             │  screens (SwiftUI), storage,
│                                  │  notifications — shows and stores
└────────────────┬─────────────────┘
                 │ depends on
┌────────────────▼─────────────────┐
│  SchulplanerKit (Swift package)  │  domain logic — decides:
│  no SwiftUI, no UIKit            │  due dates, plans, scores
└──────────────────────────────────┘
```

- **App** — the Xcode project. Its tests run with `xcodebuild test`.
- **SchulplanerKit** — a local Swift package in this repository. It cannot
  see the app; anything that decides a date, an order, a plan or a score lives
  here, with Swift Testing tests that run with `swift test`. Whether it may
  use the storage framework is open until ADR-0004.

## Storage

SwiftData, on the device
([ADR-0003](adr/0003-store-data-with-swiftdata-in-a-cloudkit-compatible-model.md)).
iCloud sync is off until iteration 007; then it syncs through the private
database of the container `iCloud.io.github.nicoschmidt.schulplaner`, and
nowhere else. Until then, the iPhone's own backup covers the data.

Every stored model is ready for sync from its first version:

- no unique constraints; uniqueness rules are checked by the domain logic
- every property optional or with a default; every relationship optional,
  with an inverse, never `deny`; order as an explicit sort value
- every entity has a stable `id: UUID`
- the models live in a versioned schema with a migration plan; each change
  adds a version and a migration test; once the CloudKit schema is in
  production, changes are add-only
- tests use in-memory stores
