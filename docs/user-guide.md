# User Interaction Guide

> As a user, you only need to focus on the following interaction points when collaborating with the Agent Team.

## Prerequisites

iSparto requires the following on your machine:

- **macOS** with **iTerm2** terminal (Agent Team mode dependency)
- **tmux 3.x** — **required since v0.8.0**. The Independent Reviewer is invoked via `codex exec` in a tmux pane (cross-provider blind review). Earlier versions treated tmux as recommended; v0.8.0+ treats it as a hard dependency. Install on macOS with `brew install tmux`. `install.sh` and `/migrate` exit early if tmux is missing.
- **Claude Code** with a [Claude Max](https://claude.ai) subscription
- **Codex CLI** with a [ChatGPT Plus](https://chatgpt.com) subscription
- **Node.js 18+**

Run `/env-nogo` at any time to verify your environment.

## What You Initiate (9 Commands)

| Command | When | What You Do |
|---------|------|-------------|
| `/init-project` | New project kickoff, one-time | Provide product requirements description, review generated documents |
| `/migrate` | Adopting iSparto in an existing project, one-time | Review the migration plan, confirm before execution. Use `--dry-run` to preview without executing |
| `/start-working` | Start of each work session | Review the Team Lead's status briefing and next-step suggestion, respond naturally |
| `/end-working` | End of each work session | Receive session briefing (fully autonomous — commit, PR merge, and push are automatic) |
| `/plan xxx` | When there's a new requirement | Describe the requirement, review the Team Lead's proposal |
| `/env-nogo` | When there are environment concerns | Review check results, fix items marked with a cross |
| `/doctor` | Before starting on a new machine, after upgrade, or when suspecting environment rot | Review the 7-check health report; address any FAIL before continuing, WARN items are informational |
| `/restore` | When you want to undo a migration or init | Review snapshot details, confirm restore to roll back all changes |
| `/security-audit` | Before a release or milestone | Receive the full audit report (code + .gitignore + git history + dependencies); fix any CRITICAL/HIGH items before proceeding |

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

## /doctor — Environment Health Check

`/doctor` is a local-only, offline diagnosis for the iSparto installation. It runs in under a second and emits seven check lines (D1–D7) plus a summary.

**When to run it:**
- First time on a new machine (or after an iCloud sync lands a stale `~/.isparto/`)
- Immediately after `~/.isparto/install.sh --upgrade`
- When something feels off — hooks not firing, Codex MCP timing out, tmux commands failing

**What each line means:**
- `[PASS]` — check satisfied, no action needed
- `[WARN]` — non-blocking; typically a "state is acceptable but not optimal" (e.g., Codex config absent and defaults will apply, or VERSION ahead of the latest git tag because of a merged-not-released window)
- `[FAIL]` — blocking; the follow-up `(fix: ...)` hint names the concrete remediation (e.g., `brew install tmux`)

**What it does NOT do:** no auto-fix, no network probes (does not ping Claude API or handshake Codex MCP), no coupling into `/start-working` or `/end-working` (those stay fast by not invoking `/doctor` implicitly). Run it when you want it; ignore it when you don't.

## Token Budget Awareness

The Independent Reviewer appears at three points in the workflow: Phase 0 (full spec review at project initialization), Wave Boundary (scope-limited review at Wave completion), and A-layer interrupts (validating Lead's decision-interruption classification). For a visual timeline of when IR triggers and what it reads at each point, see the [IR trigger diagram in workflow.md](workflow.md#independent-reviewer--trigger-points-across-the-wave-lifecycle).

iSparto runs on fixed-price subscriptions — no invocation increases your bill. The practical impact of token consumption is context window pressure: if you notice frequent `/compact` runs, consider running `/end-working` to start a fresh session. All state is preserved in plan.md — nothing is lost across sessions. For a detailed breakdown by role, see [Token Budget Awareness in configuration.md](configuration.md#token-budget-awareness).

## Your Preferences and the Agent Team (User Preference Interface)

Your personal preferences are stored in Claude Code's auto-memory and respected by the agent team automatically — no manual configuration needed.

**User Preference Interface**: Three response levels — immediate, discuss-first, record-only. See [CLAUDE.md](../CLAUDE.md) §User Preference Interface for the full rule.
