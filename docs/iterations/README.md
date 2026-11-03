# Iterations

One file per iteration, named after its number and a short goal (for
example `001-homework.md`), copied from
[TEMPLATE.md](TEMPLATE.md). The rules are in
`.claude/rules/process/iterations.md`.

Iterations are tracked on the board via the `Iteration` field. This folder
holds the narrative the board cannot: why each slice, what was cut, and what
the iteration taught.

## Planned iterations

The iterations up to the first milestone are planned ahead, so that each one
knows what the next needs from it. Their goals change when an earlier one
teaches something — that is what planning ahead is for.

The done criterion for every one of them is in `CLAUDE.md`: on the first
user's iPhone, used in a real school week.

| Iteration | Goal in brief | Proves |
| --- | --- | --- |
| [000](000-setting-up.md) | Setting up — not an iteration | The process runs end to end |
| [001](001-homework.md) | The student writes down homework per subject, sees what is due when, and ticks it off | The app runs on the first user's iPhone and is opened daily; stack, data model and CI stand |
| 002 | After school, the app asks subject by subject for new homework, from the timetable | The low-threshold check-in becomes a habit; notifications work |
| 003 | For an announced test, the app plans study sessions over the days before and adapts when topics are added — **MVP** | The core problem: preparation starts early, the plan follows the topics |
| 004 | The student sees on a timeline what was done when, and a burn-down per test | Progress is visible, not just the to-do list |
| 005 | Done tasks earn points and streaks | Rewards motivate without pressure |
| 006 | Recurring tasks and routine blocks, such as vocabulary every day | Blocks are general, not only test sprints |
| 007 | Data syncs and is backed up through the student's iCloud; the app arrives via TestFlight | Needs the Apple Developer membership; the CloudKit-ready model pays off |
| 008 | An AI tutor answers questions about a topic and generates practice exercises | Starts with a spike and an ADR on where the model runs and what may leave the device |

Status is not kept here; it is on the board.
