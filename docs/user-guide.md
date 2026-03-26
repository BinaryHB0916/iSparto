# User Interaction Guide

> As a user, you only need to focus on the following interaction points when collaborating with the Agent Team.

## What You Initiate (7 Commands)

| Command | When | What You Do |
|---------|------|-------------|
| `/init-project` | New project kickoff, one-time | Provide product requirements description, review generated documents |
| `/migrate` | Adopting iSparto in an existing project, one-time | Review the migration plan, confirm before execution. Use `--dry-run` to preview without executing |
| `/start-working` | Start of each work session | Review the Team Lead's status briefing and next-step suggestion, respond naturally |
| `/end-working` | End of each work session | Receive session briefing (fully autonomous — commit, PR merge, and push are automatic) |
| `/plan xxx` | When there's a new requirement | Describe the requirement, review the Team Lead's proposal |
| `/env-nogo` | When there are environment concerns | Review check results, fix items marked with a cross |
| `/restore` | When you want to undo a migration or init | Review snapshot details, confirm restore to roll back all changes |

**Upgrading iSparto:** Run `~/.isparto/install.sh --upgrade` to pull the latest version and see what's new.

## When the Team Lead Comes to You (2 Scenarios)

| Scenario | When | What You Do |
|----------|------|-------------|
| Wave completion briefing | After a Wave is completed | Receive the change summary and documentation audit report (informational — no confirmation needed, development continues automatically) |
| Escalate for decision | When the Team Lead is unsure | The Team Lead explains the situation, you approve/decide |

## What You Don't Need to Do

- No need to coordinate work between Developers — the Team Lead handles that
- No need to relay Codex review results to Developers — the Team Lead forwards them automatically
- No need to manually update documents — the Doc Engineer handles that
- No need to monitor the development process — just wait for notifications
- No need to do code review — Codex handles that
- No need to do smoke testing — Codex QA handles that
- No need to manually track development metrics — session-log.md records them automatically at the end of each session
- No need to worry about dangerous operations (force push, commit to main, leak secrets) — Process Observer hooks automatically intercept them in real time

## What You Should Focus On

- **Wave completion briefings** — review change summaries, especially sections marked with a warning for product decision changes
- **Decisions escalated by the Team Lead** — these are matters the Team Lead considers beyond their authority
- **Remaining issues in plan.md** — shown each time with /start-working, make sure nothing is missed
- **Product direction decisions** — /plan proposals, /migrate migration plans, /restore actions still require your confirmation
- **Compliance audit reports** — shown in /end-working session briefing; review any FAIL or WARNING items, and decide whether to adopt the suggested corrections next session
