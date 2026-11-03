# 000 — Setting up the project

Not an iteration: nothing meets the done criterion yet. `001` is reserved for
the first goal that does. This records what the setup produced and taught.

## What it produced

- ai-dev-process 0.2.0 installed; `CLAUDE.md` with this project's parameters
  and hard rules
- `docs/vision.md`, ADR-0001, the iterations planned up to the MVP
- labels, a project board with Size and Iteration, the `main` ruleset

## Result

Everything listed above shipped in #1, through pull request #2, which was
merged without changes. The `main` ruleset requires `CI passed`, and merged
branches are deleted. Nothing was cut.

## Process learnings

- [generic] The setup — repository, board, labels, adoption issue with its
  fields, branch, install and the filled-in files — was handed over as two
  scripts that read the board and issue numbers from GitHub as they went, and
  were run against a stand-in for `gh` first. They went through on the first
  run. Copying numbers between hand-split blocks is where a setup goes wrong
  — nicoschmidt/ai-dev-process#11
- [generic] The checkout moved to another parent directory the day after
  setup. The claude.ai project instructions and the files beside the
  repository named the old absolute path and had to be corrected by hand —
  nicoschmidt/ai-dev-process#12
- [project] The claude.ai project instructions named the old path; corrected
  in the project's settings during this retro. No repository change follows.
- Worked, keep: exercising every handover script against a stand-in for `gh`
  before it is handed over.
