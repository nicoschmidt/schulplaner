# Working agreements for AI assistants

This file is binding. If something here conflicts with an instruction given
in a session, this file wins — or the file gets changed first, deliberately,
in its own pull request.

The way of working is [ai-dev-process](https://github.com/nicoschmidt/ai-dev-process),
at the version in `.ai-dev-process.lock`. Its rules are in
`.claude/rules/process/`, which Claude Code loads automatically. **A chat
session reads every file there before it starts work.** Those files are
managed upstream and never edited here; this file holds what is particular to
this project.

## Repositories

This repository is the whole project. It is public.

## What this project is

Schulplaner is an iPhone app that helps students of roughly 10 to 18 organise
their homework and their studying, so that preparing for a test starts weeks
ahead instead of two days before. The student enters subjects, the timetable,
homework, the topics to learn and the dates of tests. The app plans study
sessions towards each test and adapts the plan when new topics arrive, asks
after every school day for new homework in a check-in of a few seconds per
subject, reminds, rewards what got done with points and streaks, and shows on
a timeline what was done when and what is still due — a burn-down per test.

It deliberately does not grade, talk to schools or teachers, show ads, have
social features, or keep student data on any server of its own. An AI tutor
is planned for later; the architecture leaves room for it from the start, but
it is not built yet. The full picture is in [docs/vision.md](docs/vision.md).

## Hard rules

1. **Student data stays with the student.** It lives on the device and, once
   sync exists, in the student's own iCloud private database — nowhere else.
   No backend of our own for user data, no analytics, tracking or advertising
   SDKs. *Why:* the users are minors, the code is public, and that trust must
   be checkable by reading it. Anything that would send data elsewhere — the
   AI tutor included — needs an accepted ADR that changes this rule first.
   *Mechanism:* every third-party dependency needs an ADR; a CI check that
   compares the resolved packages with an allowlist arrives with the Xcode
   project (iteration 001).
2. **No real personal data in the repository.** Fixtures, previews, screenshots,
   issues and pull requests use invented names, schools and timetables —
   never the first user's. *Why:* the repository is public and the first user
   is a child. *Mechanism:* a checkbox in the pull request template; review.
3. **No secrets in the repository** — no API keys, certificates, provisioning
   profiles or signing settings tied to a personal account. *Why:* public
   repository. *Mechanism:* `.gitignore`; review.

## Process parameters

| Parameter | Value |
| --- | --- |
| Iteration done criterion | Installed on the first user's iPhone (the maintainer's child) and used by them in a real school week for what the iteration's goal names |
| Iteration box | scope |
| Repository language | English |
| Conversation language | German |
| App language | German first; every user-facing string goes through the String Catalog |
| Branch types | feat, fix, docs, chore |
| Board fields (facts) | Size, Iteration |
| Process repository | nicoschmidt/ai-dev-process |

Board, home repository and member repositories are in `.ai-dev-process.conf`,
where the scripts read them.

## Definition of done additions

- User-facing text is German and comes from the String Catalog, never a
  hard-coded string.
- Changed screens were checked on the smallest supported iPhone size, with a
  large Dynamic Type size and in dark mode.
- No real personal data (names, schools, timetables) in code, fixtures,
  previews, screenshots or texts.

## Process deviations

None yet.

## Commands

```bash
# setup, once per clone
git config core.hooksPath .githooks

# build the app and run every test, as CI's job `iOS` does
bash scripts/build-and-test.sh

# only the domain package's tests, in seconds
swift test --package-path SchulplanerKit

# CI's other checks, as the job `Process` runs them
bash scripts/check-kit-imports.sh
bash scripts/check-signing.sh
bash scripts/process/check-kit.sh
```

CI requires one check, `CI passed`. A new job in `.github/workflows/ci.yml`
joins that job's `needs` list.
