# 001 — Homework

Planned. Not started.

## Goal

The student writes down homework per subject on their own iPhone, sees what
is due when, and ticks it off.

## Why this slice

The app can only help with tests once it is on the student's phone and opened
every day, and homework is the daily reason to open it. The slice is thin on
features but forces every foundation the later iterations stand on: the
platform and minimum iOS version, how data is stored so that iCloud sync is a
switch later, a domain model shaped for tests, blocks, recurrence and rewards,
a test setup that CI runs, and the way the app gets onto an iPhone without a
paid developer account. Completion times are recorded from the first tick, so
the timeline (004) and rewards (005) have history to show when they arrive.

## Scope

Epic: #3.

Decisions first, in this order:

- #4 — spike: decide platform, minimum iOS version and dependency
  policy (ADR-0002)
- #5 — spike: decide how data is stored so that iCloud sync is a
  switch later (ADR-0003)
- #6 — spike: decide the core domain model (ADR-0004)

Then the foundation:

- #7 — chore: Xcode project with test target and CI
- #8 — chore: CI check that every package dependency is allowed by an
  ADR
- #9 — docs: put the app on an iPhone without a paid developer
  account

Then what the student can do:

- #10 — feat: manage subjects
- #11 — feat: write down homework for a subject
- #12 — feat: see what is due when, and tick homework off

## Out of scope

- Timetable, the daily check-in after school, and a default due date from the
  next lesson of the subject — iteration 002
- Notifications and reminders of any kind — 002 and 003
- Topics, tests and the study planner — 003
- Timeline, burn-down, points and streaks — 004 and 005, built on the
  completion times recorded here
- Recurring tasks — 006
- iCloud sync and TestFlight — 007, once the developer membership exists
- Photos of worksheets, widgets, iPad layout, languages other than German —
  not planned yet; captured as ideas if they come up

## If it grows

Cut in this order, each into an issue for a later iteration:

1. Reordering subjects; a fixed alphabetical order remains
2. The curated list of symbols for subjects; the colour alone remains
3. Editing homework; deleting and writing it again remains
4. The "Erledigt" section of the last seven days; undo right after ticking off
   remains
5. The "Diese Woche" group; it merges into "Später"

Not cut: the three decisions, CI running the tests, the install guide, and
recording when homework was done.

## Result

To be written when the goal is reached: what shipped, what did not.

## Process learnings

<!-- Inputs: issues labelled `process` since the start, review corrections in
     the merged pull requests, issues that were cut. Mark every learning:
     [project] → a change to CLAUDE.md, through an issue here
     [generic] → the process repository: transfer the issue, or draft one -->

To be written in the retro.
