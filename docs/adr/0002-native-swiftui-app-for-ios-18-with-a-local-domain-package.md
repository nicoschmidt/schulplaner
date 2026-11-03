# ADR-0002: Native SwiftUI app for iOS 18 and later, with the domain logic in a local Swift package

- **Status:** accepted
- **Date:** 2026-11-03
- **Deciders:** Maintainer
- **Supersedes:** —
- **Superseded by:** —

## Context

Iteration 001 starts the code base, and four choices made now are expensive
to reverse later: the platform technology, the minimum iOS version, where the
domain logic lives, and the bundle identifier.

Forces that are real:

- **An iPhone app** (`docs/vision.md`). Android, iPad and Mac are non-goals.
- **Students often have handed-down phones.** In Apple's figures of June 2026,
  14 % of all iPhones able to run iOS 26 were still on iOS 18, and 7 % on
  something older. Phones that cannot run iOS 26 at all — such as the iPhone XS
  and XR, which end at iOS 18 — do not appear in those figures. The
  maintainer's test device is one of them.
- **The first user's device runs the current iOS**, so nothing newer is ruled
  out on the phone that matters first.
- **Domain logic is tested deterministically** (`.claude/rules/process/quality.md`),
  and the study planner of iteration 003 is the core of the product. The
  project is developed with AI assistance, where a fast test loop decides how
  often changes are checked.
- **Hard rule 1** in `CLAUDE.md`: no third-party dependency without an ADR.
- **The bundle identifier** can practically not change once the app has been
  uploaded to TestFlight (iteration 007).

Forces that only look like constraints:

- Apple's on-device language model (Foundation Models, iOS 26) does not require
  iOS 26 as the minimum: it needs Apple Intelligence hardware anyway, so it is
  used behind an availability check whatever the minimum is.
- No paid developer membership exists yet. That limits distribution and iCloud,
  not the choice of technology.

## Decision drivers

- Reach: the app should run on the phones students actually have.
- A domain core that is tested in seconds and cannot drift into the UI.
- Nothing in the app that is not Apple's or ours, so that hard rule 1 holds by
  construction.
- As few moving parts as these allow.

## Options considered

### Technology

#### Option A: Native Swift and SwiftUI

- Good: first-class access to everything later iterations need — SwiftData
  and CloudKit, local notifications, widgets, Foundation Models.
- Good: no runtime that is not Apple's; nothing to vet under hard rule 1.
- Bad: iPhone and other Apple platforms only — which the vision accepts.

#### Option B: A cross-platform framework (Flutter, React Native)

- Good: Android would come almost for free.
- Bad: Android is a non-goal; the cost is paid for nothing.
- Bad: a third-party runtime and its package ecosystem inside an app for
  minors, against the intent of hard rule 1.
- Bad: iCloud sync, notifications and on-device models through plugins, one
  step behind Apple's APIs.

### Minimum iOS version

#### Option C: iOS 18

- Good: reaches the handed-down phones, including those that end at iOS 18,
  and the maintainer's test device.
- Good: SwiftData, Swift Testing and the SwiftUI of iOS 18 cover everything
  iterations 001–006 need, as far as they can be foreseen.
- Bad: features of iOS 26 and 27 — newer SwiftData capabilities among them —
  need an availability check and a fallback, or wait.

#### Option D: iOS 26

- Good: newer SwiftData features and the iOS 26 design without checks.
- Bad: excludes every phone that ends at iOS 18, and the maintainer's test
  device with them.

#### Option E: iOS 27

- Good: the simplest code base.
- Bad: the smallest reach; most handed-down phones are excluded.

### Where the domain logic lives

#### Option F: An app target plus a local Swift package `SchulplanerKit`

The rules — due dates, later the study planner, points and streaks — live in
a Swift package inside this repository. The app depends on the package; the
package cannot see the app.

- Good: the direction of dependency is enforced by the compiler: domain logic
  cannot reach into screens or into the app's storage code.
- Good: the package's tests run with `swift test` in seconds, without a
  simulator.
- Bad: one more manifest (`Package.swift`) and a visible seam; data that
  crosses it may need translating, depending on ADR-0004.

#### Option G: One app target

- Good: the simplest structure; no seam to cross.
- Bad: separation by convention only, which erodes over many sessions.
- Bad: tests of the rules need the app running in a simulator — a minute
  rather than seconds per run.

### Bundle identifier

#### Option H: `io.github.nicoschmidt.schulplaner`

- Good: derived from a namespace the maintainer controls today, without
  owning a domain.
- Bad: ties the identifier to the GitHub account name.

#### Option I: Reverse domain of an own domain

- Good: independent of GitHub.
- Bad: needs a domain that is kept for as long as the app exists.

## Decision

We choose **native Swift and SwiftUI (A)** for **iOS 18 and later (C)**, with
the **domain logic in a local Swift package `SchulplanerKit` (F)**, and the
bundle identifier **`io.github.nicoschmidt.schulplaner` (H)**.

A follows from the vision and hard rule 1: Android is a non-goal, and every
later iteration leans on Apple frameworks. C keeps the phones students
actually have in reach at a known, bounded cost — availability checks for
what is newer — while D and E would exclude devices to save code that can be
written behind a check. F makes the most important code of the product, the
rules and the planner, the fastest to test and impossible to tangle with the
UI; the seam it adds is the price of that guarantee. H needs nothing the
maintainer does not already have.

In detail:

- **Language and UI.** Swift 6 language mode with complete concurrency
  checking. SwiftUI for every screen; UIKit only where SwiftUI cannot do
  something, wrapped in one view.
- **Deployment.** Minimum iOS 18.0, iPhone only. APIs of later versions are
  used behind `if #available` with a fallback, or not at all.
- **Toolchain.** The current stable Xcode, pinned explicitly in CI.
- **Layout.** One Xcode project for the app; the package `SchulplanerKit` in
  the same repository, added to the project as a local package. The package
  imports neither SwiftUI nor UIKit. Whether it may import the storage
  framework is decided by ADR-0003 and ADR-0004.
- **Tests.** Swift Testing for new tests; the package's tests run with
  `swift test`, the app's with `xcodebuild test`.
- **Dependencies.** None beyond Apple's frameworks. A third-party package
  needs an ADR of its own and an entry on the allowlist that CI checks.
- **Identity.** Bundle identifier `io.github.nicoschmidt.schulplaner`; name on
  the home screen "Schulplaner". The App Store name is chosen before
  TestFlight (iteration 007), since "Schulplaner" may be taken there.

## Consequences

- Easy: testing the rules and the planner, quickly and without a device; using
  any Apple framework as it arrives; keeping hard rule 1, because nothing
  third-party is in the app.
- Hard: using an iOS 26 or 27 feature means writing its iOS 18 fallback too.
  Every newer API in a pull request needs its availability check.
- Committed to: the boundary between app and package. Code that decides
  something — a date, an order, a plan, a score — goes into `SchulplanerKit`
  with its tests; the app shows and stores.
- Committed to: checking changed screens on the smallest iPhone that runs
  iOS 18, the iPhone SE (2nd and 3rd generation) with its 4.7-inch screen;
  the definition-of-done item in `CLAUDE.md` means that device size.
- Revisit the minimum iOS version each June, when Apple publishes adoption
  figures, and earlier if a feature the product needs exists only on a newer
  iOS without a reasonable fallback, or if the fallbacks grow larger than the
  features.
- Revisit the package boundary if the code that translates between app and
  package outgrows the logic in the package.

## Follow-up

- #7 builds the Xcode project and the package as decided here, and gains one
  acceptance criterion: a CI check that `SchulplanerKit` imports neither
  SwiftUI nor UIKit.
- #8 adds the dependency allowlist, empty for now.
- #5 (ADR-0003) takes iOS 18 as the baseline for what the storage framework
  offers.
- The App Store name is captured as an idea, to be decided before
  iteration 007.
