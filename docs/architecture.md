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
  use the storage framework is open until ADR-0003 and ADR-0004.
