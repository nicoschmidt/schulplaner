# ADR-0003: Store data with SwiftData, in a model that iCloud sync accepts from the first version

- **Status:** accepted
- **Date:** 2026-11-03
- **Deciders:** Maintainer
- **Supersedes:** —
- **Superseded by:** —

## Context

From iteration 001 on, the app stores subjects and homework on the device.
From iteration 007 on — once the paid developer membership exists — the same
data should sync through the student's own iCloud private database and be
backed up there. The vision asks for that to be a switch, not a migration.

Forces that are real:

- **Hard rule 1** in `CLAUDE.md`: student data stays on the device and in the
  student's own iCloud. No backend of our own; no third-party dependency
  without an ADR.
- **ADR-0002**: iOS 18 is the minimum, so iOS 18's storage APIs are the
  baseline.
- **iCloud sync constrains the model**, whichever Apple framework syncs it
  (Core Data or SwiftData through CloudKit):
  - no unique constraints, since CloudKit cannot check uniqueness atomically
    across devices
  - every attribute optional or with a default value
  - every relationship optional, with an inverse, and no `Deny` delete rule;
    no ordered relationships
  - once the CloudKit schema is deployed to production, changes are
    add-only: no deleting, renaming or retyping of entities or attributes
- **The data is small.** A student produces a few hundred tasks a year.
  Throughput and query power do not decide this.
- **Domain logic is tested deterministically**, and storage must therefore be
  replaceable by an in-memory store in tests.

Forces that only look like constraints:

- No paid membership yet. It rules out sync now, not a sync-ready model now.
- Sharing data between different people — a parent seeing the plan — is a
  non-goal of the vision. Storage does not need to support it.

## Decision drivers

- iCloud sync becomes a configuration change, not a data migration.
- Nothing that is not Apple's in the app (hard rule 1).
- Little code between the screens and the stored data.
- Storage replaceable in tests.

## Options considered

### Option A: SwiftData

Apple's current persistence framework (iOS 17+). Models are Swift classes;
SwiftUI views observe them directly. CloudKit sync to the private database is
built in and switched on in the model configuration.

- Good: Apple's own, so hard rule 1 holds without exception.
- Good: sync is a configuration value; the model rules above are the only
  preparation, and they can be met from the first version.
- Good: the least code between screens and data; in-memory stores for tests
  are one setting.
- Bad: young. iOS 17 and 18 shipped with well-known defects, and reports in
  2026 still mention rough edges, mostly around background contexts and large
  data sets — neither of which this app relies on.
- Bad: no sharing between different iCloud users, and less control over sync
  than lower-level options.

### Option B: Core Data with `NSPersistentCloudKitContainer`

Apple's mature persistence framework; CloudKit sync since iOS 13. SwiftData
uses the same store technology underneath.

- Good: Apple's own; years of production use with CloudKit sync, including
  sharing between users.
- Bad: considerably more code — a managed object model, contexts, fetch
  requests — and an API that predates SwiftUI.
- Bad: Apple's new work goes into SwiftData; Core Data is maintained but saw
  nothing new in 2026.

### Option C: SQLiteData (Point-Free)

An open-source library (MIT, 1.0 in September 2025) on top of SQLite and GRDB,
with CloudKit sync and sharing. Models are plain Swift values.

- Good: value-type models suit a domain package that knows no storage
  framework; SQL queries; sharing between users supported.
- Bad: third-party code with further dependencies in an app for minors; under
  hard rule 1 it needs an ADR of its own and an allowlist entry.
- Bad: the project then depends on a small company's maintenance for its
  most fundamental layer.

### Option D: Our own files, synced with `CKSyncEngine`

Apple's lower-level sync engine (iOS 17+) over a store of our own.

- Good: full control over format and conflict handling; Apple's own.
- Bad: storage, queries, change tracking and conflict resolution are ours to
  write and test — a large amount of work for a problem the other options
  have solved.

## Decision

We choose **SwiftData (A)**, because it is the only option that is Apple's
own, makes sync a configuration change, and keeps the code between screens
and data small — the three things this app needs from storage. Its defects
concentrate where this app does not go: large data sets and heavy background
work. B buys maturity with much more code, in a framework that is maintained
but no longer where Apple's new work goes; C brings sharing the vision does not want, at the price of
third-party code at the base; D rebuilds what A already does.

The rules, from the first stored model on:

1. **Sync-ready model.** No `@Attribute(.unique)`. Every stored property is
   optional or has a default value. Every relationship is optional, has an
   inverse and never uses the `deny` delete rule. Order is stored as an
   explicit sort value, never as an ordered relationship.
2. **Stable identity.** Every stored entity carries an `id: UUID` with a
   default, which never changes and is what other records and logs refer to.
3. **Uniqueness lives in the domain logic**, not in storage: a rule such as
   "two subjects cannot have the same name" is checked before saving. Once
   sync is on, the app must also cope with duplicates that two devices
   created at the same time.
4. **Sync off until iteration 007.** The model configuration names no CloudKit
   database. In 007 it switches to the private database of the container
   `iCloud.io.github.nicoschmidt.schulplaner` — the private database only,
   never the public or a shared one.
5. **Versioned schema from version 1.** The stored models are defined in a
   versioned schema with a migration plan from the first release, so that a
   student's data survives every update. Every change to a stored model adds
   a schema version and a test that a store of the previous version migrates.
   Until the CloudKit schema reaches production, renaming and removing go
   through such a migration; afterwards, changes are add-only.
6. **In-memory stores in tests.** Tests that touch storage use an in-memory
   configuration and never the device's store.
7. **Backup before sync.** Until 007, the student's data is backed up with the
   iPhone's own backup (iCloud Backup or the Mac), which includes app data.
   No export of our own in iteration 001.

Whether `SchulplanerKit` imports SwiftData, or the stored models stay in the
app and the package sees plain values, is decided by ADR-0004.

## Consequences

- Easy: switching sync on in 007; observing stored data from SwiftUI views;
  testing storage in memory.
- Hard: every stored property needs a sensible default; uniqueness and
  duplicate merging are our code; after 007, a mistake in the model can only
  be fixed by adding, never by removing.
- Committed to: the seven rules above, in every pull request that touches a
  stored model. Review checks them.
- Committed to: SwiftData's pace. Fixes to its defects arrive with iOS
  releases, and iOS 18 is the minimum.
- Revisit if sync defects in iteration 007 cannot be worked around, if sharing
  between different people becomes a goal (then C or B, which support it), or
  if SwiftData's defects start to reach the paths this app uses.

## Follow-up

- #6 (ADR-0004) designs the domain model within these rules, and decides
  whether the package sees SwiftData models or plain values.
- #10 is the first issue that stores data, and gains the acceptance criterion
  that sets storage up as decided here: versioned schema version 1 with a
  migration plan, sync off, in-memory stores in tests.
- Switching sync on in iteration 007 — the container, the private database
  and merging duplicates — is captured as an idea until 007 is planned.
