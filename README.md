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

**Status:** early. The app builds and launches to a placeholder; nothing is
usable yet.

- [Vision](docs/vision.md) — the problem, the scope, and what is deliberately
  left out
- [Architecture decisions](docs/adr/README.md)
- [Iterations](docs/iterations/README.md) — the plan up to the first usable
  version

## Development setup

Step by step, for a Mac that has never built the app. CI builds with
**Xcode 27.1**, the version pinned in
[`.github/workflows/ci.yml`](.github/workflows/ci.yml); a newer Xcode 27
builds the project too.

1. **A Mac** with Apple silicon — Xcode 27 does not run on Intel — and
   macOS Tahoe 26.6 or later. Keep several tens of GB free for Xcode, its
   simulators and build data.
2. **Xcode** from the Mac App Store. On its first launch, accept the licence
   and install the iOS platform. Then, under *Xcode → Settings → Components*,
   add an **iOS 18** simulator runtime: iOS 18 is the minimum the app supports
   ([ADR-0002](docs/adr/0002-native-swiftui-app-for-ios-18-with-a-local-domain-package.md)),
   and the screens are checked on it.
3. **The command line tools point at that Xcode.** `xcode-select -p` shows
   `/Applications/Xcode.app/Contents/Developer`; otherwise:

   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

   `xcodebuild -version` then shows Xcode 27.1 or a later 27.x.
4. **Your Apple Account in Xcode**, for signing with your personal team:
   *Xcode → Settings → Accounts → +*. The team stays on your Mac, never in
   the repository: for a build on an iPhone, copy the example and put your
   team ID into the copy, which git ignores.

   ```bash
   cp Config/Signing.local.xcconfig.example Config/Signing.local.xcconfig
   ```

   Do not choose the team in Xcode's *Signing & Capabilities* tab: that
   writes it into the project, and CI fails. The simulator needs no team.
   Installing on an iPhone gets its own guide with #9.
5. **The repository.** Clone it, then once per clone:

   ```bash
   git config core.hooksPath .githooks
   ```

   For `scripts/process/`, `gh` and `jq` (`brew install gh jq`), and once
   `gh auth refresh -s project` for the board.
6. **Claude Code**, the way changes are made here: the VS Code extension, or
   the CLI. It loads `CLAUDE.md` and `.claude/rules/process/` from the
   repository. The procedures come from the `ai-dev-process` plugin, from
   the marketplace `nicoschmidt/ai-dev-process`.
7. **Xcode tools for Claude Code** (recommended), so that it can build, run
   the tests, render previews, read Xcode's issues and search Apple's
   documentation:
   - *Xcode → Settings → Intelligence → Model Context Protocol → Xcode
     Tools*: **Always**. The service starts only when an agent connects; a
     hammer in the menu bar shows it, and *Quit* there or
     `xcrun mcp-server stop` ends it.
   - In the Claude Code chat panel: `/mcp` → add a server — name `xcode`,
     type stdio, command `xcrun`, argument `mcpbridge`, scope **local**. Not
     *project*: that would commit a `.mcp.json`. With the CLI instead:

     ```bash
     claude mcp add --transport stdio xcode -- xcrun mcpbridge
     ```

   - In a new conversation, `/mcp` shows `xcode` as connected.
8. **Not for changes: Xcode's own coding assistant.** Its chat is fine for
   questions. Its agent is not known to load this repository's process
   rules, so changes go through Claude Code in the repository.

### Building and testing

```bash
bash scripts/build-and-test.sh
```

It runs the tests of the domain package `SchulplanerKit` with `swift test`,
in seconds, and then builds the app and runs every test on an iPhone
simulator, as CI does. `DESTINATION='platform=iOS Simulator,name=iPhone 16e,OS=18.6'`
in front of it picks another simulator. While working on the rules alone,
`swift test --package-path SchulplanerKit` is enough.

In Xcode, open `Schulplaner.xcodeproj`, choose the scheme **Schulplaner** and
an iPhone simulator: ⌘R runs the app, ⌘U runs every test.

| Where | What |
| --- | --- |
| `Schulplaner/` | the app: screens, later storage; `Localizable.xcstrings` holds every user-facing text |
| `SchulplanerTests/` | the app's tests |
| `SchulplanerKit/` | the domain logic, a local Swift package with its tests |
| `Config/` | build settings: signing, with the personal part in an ignored local file |
| `scripts/` | the test command and CI's checks; `scripts/process/` belongs to ai-dev-process |

## How it is developed

With AI assistance (Claude Code), following
[ai-dev-process](https://github.com/nicoschmidt/ai-dev-process): GitHub issues
are the only task list, decisions are recorded as ADRs before the code, and
every change goes through a reviewed pull request. See
[docs/process.md](docs/process.md) and [CLAUDE.md](CLAUDE.md).

## Licence

[MIT](LICENSE)
