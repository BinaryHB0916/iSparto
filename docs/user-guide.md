# User Interaction Guide

> As a user, you only need to focus on the following interaction points when collaborating with the Agent Team.

## What You Initiate (6 Commands)

| Command | When | What You Do |
|---------|------|-------------|
| `/init-project` | New project kickoff, one-time | Provide product requirements description, review generated documents |
| `/migrate` | Adopting iSparto in an existing project, one-time | Review the migration plan, confirm before execution |
| `/start-working` | Start of each work session | Review the Team Lead's status report, confirm "start" |
| `/end-working` | End of each work session | Confirm the commit message |
| `/plan xxx` | When there's a new requirement | Describe the requirement, review the Team Lead's proposal |
| `/env-nogo` | When there are environment concerns | Review check results, fix items marked with a cross |

## When the Team Lead Comes to You (3 Scenarios)

| Scenario | When | What You Do |
|----------|------|-------------|
| Wave validation | After a Wave is completed | Review the change summary and documentation audit report, confirm everything looks good |
| Escalate for decision | When the Team Lead is unsure | The Team Lead explains the situation, you approve/decide |
| Commit confirmation | Before push | Review the commit message, confirm |

## What You Don't Need to Do

- No need to coordinate work between Developers — the Team Lead handles that
- No need to relay Codex review results to Developers — the Team Lead forwards them automatically
- No need to manually update documents — the Doc Engineer handles that
- No need to monitor the development process — just wait for notifications
- No need to do code review — Codex handles that
- No need to do smoke testing — Codex QA handles that

## What You Should Focus On

- **Documentation change summary at Wave validation** — especially sections marked with a warning for product decision changes
- **Decisions escalated by the Team Lead** — these are matters the Team Lead considers beyond their authority
- **Remaining issues in plan.md** — shown each time with /start-working, make sure nothing is missed
