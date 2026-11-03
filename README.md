# Schulplaner

An iPhone app that helps students organise homework and studying — so that
preparing for a test starts weeks ahead, not two days before.

- After every school day, a check-in of a few seconds asks subject by subject
  for new homework.
- Topics to learn are collected per subject as they come up in class.
- For an announced test, the app plans study sessions over the days before
  and adapts the plan when new topics are added.
- Reminders, points and streaks, and a timeline with a burn-down per test
  show what is done and what is still due.

Student data stays on the device and in the student's own iCloud — no server
of ours, no tracking, no ads.

**Status:** early. The project is being set up; nothing is usable yet.

- [Vision](docs/vision.md) — the problem, the scope, and what is deliberately
  left out
- [Architecture decisions](docs/adr/README.md)
- [Iterations](docs/iterations/README.md) — the plan up to the first usable
  version

## How it is developed

With AI assistance (Claude Code), following
[ai-dev-process](https://github.com/nicoschmidt/ai-dev-process): GitHub issues
are the only task list, decisions are recorded as ADRs before the code, and
every change goes through a reviewed pull request. See
[docs/process.md](docs/process.md) and [CLAUDE.md](CLAUDE.md).

## Licence

[MIT](LICENSE)
