# Vision

## The problem

A student learns that a test is coming, and starts studying three days
before — sometimes only then finding out which topics it covers at all.
Homework is noted on a scrap of paper, in a planner nobody opens, or not at
all. What it costs: cramming, stress and weaker results; parents who nag and
the arguments that follow; and, above all, a student who does not get the
chance to learn how to organise themselves.

The information is there in time — topics are taught weeks ahead, homework is
given every day. What is missing is a place where it lands with almost no
effort, and something that turns it into a plan early enough.

## What we build

An iPhone app for students of roughly 10 to 18. The student keeps their
subjects and timetable in it. After every school day the app asks, subject by
subject, whether there is new homework — a check-in that takes seconds,
where "page 42, no. 3" or "worksheet" is enough. Every subject collects the
topics to learn, as they come up in class. When a test is announced, the app
builds a study block towards it — sessions spread over the days before, each
repeating some of the topics — and adapts it when new topics are added.
Tasks can be scheduled, recur and remind with banners and sounds. Points and
streaks reward what got done, and a timeline shows what was learned and done
when, and what is still due by when: a burn-down per test.

Later, an AI tutor answers questions about a topic and generates practice
exercises. The architecture leaves room for it from the start.

## Product principles

- **Low threshold beats completeness.** The daily check-in takes under a
  minute; "nothing today" is one tap per subject. Anything that feels like a
  chore will not be used.
- **The plan adapts; the student does not re-plan.** New topics, a missed
  session or a moved test date change the plan automatically.
- **Done is as visible as due.** Progress is shown, not just the to-do list.
- **Motivation by progress, not by pressure.** Streaks forgive a weekend or a
  holiday; reminders are friendly and few.
- **The student owns it.** The app helps the student organise themselves;
  it is not a monitoring tool for parents.

## Measure of success

Measured with the first user, over a normal school month:

- Homework is entered through the check-in on at least four of five school
  days.
- For every test in that month, the study block exists at least seven days
  before the test, and at least three quarters of its sessions are done.
- After six weeks the first user still opens the app on their own, without a
  parent prompting it.

## Scope

- Subjects, and the timetable
- Homework per subject, entered quickly in the daily check-in after school
- Topics to learn per subject, added continuously
- Tasks — homework, study sessions and others — with date and time,
  recurrence and reminders (banner, sound)
- Blocks of tasks: a study sprint before a test, a vocabulary block before a
  vocabulary test, blocks of recurring tasks
- Automatic planning of study sessions towards a test, re-planned when topics
  are added or sessions are missed
- Timeline and calendar of what was done and what is due, with a burn-down
  per test or block
- Rewards: points and streaks
- Sync and backup through the student's own iCloud
- Later: an AI tutor for questions and practice exercises per topic

## Non-goals

- **Android, iPad and Mac apps** — one platform done well first. iPad may
  follow, since SwiftUI makes it cheap.
- **A parent view or parental monitoring** — it works against the goal of
  self-responsibility. May be reconsidered, by its own decision, once the app
  is used.
- **Class, teacher or school features; sharing between students** — needs
  accounts and servers, and moves away from the single student.
- **Import from school systems** (WebUntis and others) — useful, but each
  system is its own integration. Revisit once the manual way works.
- **Grade tracking** — a different product; tempting, but not the problem.
- **Ads, in-app purchases, accounts of our own** — see the constraints.

## Constraints

- **An iPhone app**, open source on GitHub under the MIT licence.
- **Minors' data.** Student data stays on the device and in the student's own
  iCloud private database; no own backend, no tracking (hard rule 1 in
  `CLAUDE.md`). GDPR applies; in Germany consent to data processing needs a
  parent below 16. Apple's rules for apps aimed at children apply if the app
  is ever listed in the Kids category.
- **No paid Apple Developer membership yet.** Until there is one, the app
  reaches the first user's iPhone through Xcode's free provisioning: it must
  be reinstalled from the Mac every seven days, and neither iCloud nor
  TestFlight is available. The data model is kept CloudKit-compatible from the
  start, so that iCloud becomes a switch rather than a migration.
- **The AI tutor needs a decision of its own.** An open-source app cannot ship
  an API key. The options are an on-device model (Apple's Foundation Models,
  only on devices with Apple Intelligence), a key the family brings, or a
  backend — each with different privacy consequences for minors. An ADR
  decides before any tutor code is written.
- **Development with Claude Code**, following ai-dev-process.

## Language of the domain

The app speaks German; code, issues and documents speak English. One English
term per concept, used everywhere:

| English (code, docs) | German (app) | Meaning |
| --- | --- | --- |
| Subject | Fach | A school subject, with colour and symbol |
| Timetable, lesson | Stundenplan, Stunde | Which subject is taught when |
| Homework | Hausaufgabe | A task given in class, due on a date |
| Topic | Thema / Lerninhalt | Something to learn for a subject |
| Test | Klassenarbeit / Test | A dated assessment covering topics |
| Study session | Lerneinheit | A scheduled task to learn or repeat topics |
| Task | Aufgabe | Anything to do: homework, a study session, other |
| Block | Block / Sprint | A group of tasks with a purpose, e.g. before a test |
| Check-in | Hausaufgaben-Abfrage | The short daily question after school |
| Points, streak | Punkte, Serie | Rewards for what got done |
