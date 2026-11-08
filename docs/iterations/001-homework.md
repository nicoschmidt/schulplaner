# 001 — Homework

Closed on 8 November 2026, before the done criterion was met.

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

The maintainer closed the iteration on 8 November 2026, a Sunday. That day #12,
the last issue of the scope, was merged. **The done criterion was not met.**
The app was not yet on the first user's iPhone, and no school week had passed
with it. So it is not known yet whether the student opens the app every day,
which is what this iteration was meant to prove. Until #12, the app ran only
on the maintainer's iPhone, installed for #9, and in the simulator.

All nine issues of the scope shipped, and nothing was cut:

- **Decisions.** ADR-0002 (#4): a native SwiftUI app for iOS 18, iPhone only,
  with the domain rules in a package of their own, and no third-party package
  without an ADR. ADR-0003 (#5): SwiftData in versioned schemas, shaped so
  that iCloud sync can be switched on later, and switched off for now.
  ADR-0004 (#6): the core domain model.
- **Foundation.**
  - The Xcode project with `SchulplanerKit`, its tests, and CI on Xcode 27.1
    (#7).
  - CI checks that every package is allowed by an ADR, that the kit imports
    no UI or storage framework, and that no personal signing setting is in
    the project (#8).
  - The install guide for a free Apple Account and
    `scripts/install-on-iphone.sh` (#9).
- **What the student can do.**
  - Pick their subjects on first launch from common school subjects, then
    rename, recolour, reorder, add and delete them (#10).
  - Write down homework for a subject (#11). The homework has a title, notes,
    and a due day chosen with quick choices, and can be edited and deleted.
  - See open homework grouped by when it is due, tick it off with undo, find
    the last seven days' done homework under "Erledigt", and open it there
    (#12).

  The completion time is recorded from the first tick, for the timeline (004)
  and the rewards (005).

The scope grew twice in review. The maintainer asked for a title and notes on
homework in #11, which brought schema version 2 and its migration, and for
details of done homework in #12. Both went into the open pull request. The cut
order was not needed.

Every pull request ran its tests on the minimum iOS version (18.6) and on the
newest (27.2): at the end, 37 in the package and 38 in the app.

## Process learnings

- [project] **Closed before the school week.** The criterion asks for a week
  of use, and the last merge came on a Sunday. Waiting would have held the
  iteration open for the whole week; the maintainer closed it instead. That
  skips the one check that tells whether the iteration worked. The app now
  reaches the student in the week of 9 November. Two questions remain: does
  the criterion keep its week of use, and where do the week's findings go
  (#26).
- [generic] **Work started on issues still in Backlog.** #8 and #9 were
  started on "continue with the next issue" while the board still showed them
  in Backlog. Nobody had clicked Ready. Transferred from #22 as
  nicoschmidt/ai-dev-process#14.
- [generic] **Scope added in review.** Twice, the maintainer added a
  requirement while testing a pull request, and it went into that pull
  request. Neither request appears in its issue or in this file's scope, and
  this retro found them only through the commit messages. This is evidence for
  nicoschmidt/ai-dev-process#9.
- [generic] **Review corrections did leave a trace.** Every commit made at the
  maintainer's request says so in its first line of reasoning ("At the
  maintainer's request in review"). The review comment on #18, more detail in
  the domain model diagram, became a commit of its own. With these, the retro
  could find every correction. This is evidence for
  nicoschmidt/ai-dev-process#6: the convention worked without a rule.
- [generic] nicoschmidt/ai-dev-process#13, found while this iteration was
  planned, is still open upstream.
- Worked, keep: **walking through every changed screen.** The walk-throughs
  ran on a temporary iPhone SE simulator, with Xcode's device tools and the
  debug launch argument `-preview-data`. They found two defects that the tests
  had not: the editor's title cut off on a small iPhone with large text (#10),
  and the undo banner invisible while it slid in (#12). The tools cannot
  scroll or swipe, so controls below the fold went unseen. The pull request
  says so in each case.
- Worked, keep: **testing on the oldest and the newest iOS.** The fix for the
  cut-off title uses other buttons from iOS 26 on than on iOS 18. Both
  branches ran, because both versions were tested.
