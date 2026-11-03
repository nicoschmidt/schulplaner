# ADR-0001: Record architecture decisions

- **Status:** accepted
- **Date:** 2026-11-02
- **Deciders:** Maintainer
- **Supersedes:** —
- **Superseded by:** —

## Context

This project is developed largely with AI assistance, across sessions that do
not share memory. An assistant that cannot see why a choice was made will
either re-litigate it or quietly violate it. The same is true of a human
returning to the project after a break.

## Decision drivers

- Continuity across sessions and across tools (Claude Code, chat).
- The reasoning behind a choice is more valuable than the choice itself.
- Decisions must live where the code lives, not in a chat history.

## Options considered

### Option A: Architecture Decision Records in the repository

Numbered markdown files under `docs/adr/`, written before the implementing
code, immutable once accepted.

- Good: versioned, reviewable in pull requests, readable by any session with
  repository access.
- Good: the history of superseded decisions survives.
- Bad: costs discipline; an unmaintained ADR set is worse than none.

### Option B: Keep decisions in chat history and issue comments

- Good: zero overhead at the moment of deciding.
- Bad: not readable by a fresh session, not diffable, not reviewable, and
  effectively lost within weeks.

## Decision

We choose **Option A**, following `.claude/rules/process/decisions.md`.

## Consequences

- Every architecturally significant pull request carries or references an
  ADR; the pull request template asks for it.
- `docs/architecture.md` is derived from accepted ADRs.
- The overhead is real and accepted: one short document per significant
  decision.

## Follow-up

The first decisions this project faces, each an ADR before the code it
shapes; they become issues when the iteration that needs them is planned:

- Platform and stack: native Swift and SwiftUI, the minimum iOS version, and
  no third-party dependencies without an ADR (iteration 001)
- Persistence: SwiftData with a CloudKit-compatible model, local only until
  the Apple Developer membership exists (iteration 001)
- The core domain model: subject, timetable, topic, task (homework, study
  session, other), test, block; how recurrence and reminders attach to tasks
  (iteration 001)
- Notifications: local notifications for the check-in and for reminders, and
  how scheduling stays within the system's limit on pending notifications
  (iteration 002)
- The study planner: how sessions are distributed before a test and
  re-planned, as deterministic logic without UI, storage or clock
  (iteration 003)
- The AI tutor: where the model runs and what, if anything, may leave the
  device — this changes hard rule 1 in `CLAUDE.md` if it allows anything
  (iteration 008)
