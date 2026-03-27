<p align="center">
  <img src="assets/header.svg" alt="iSparto" width="100%"/>
</p>

<p align="center">
  <a href="README.zh-CN.md">中文版</a>
</p>

---

**iSparto turns Claude Code from a single AI into a development team** — Lead assembles prompts, Developer (Codex) implements, Teammates parallelize, Doc Engineer syncs documentation. You direct the team, not the agent.

### Who is this for

Solo developers on macOS who want to multiply their output with Claude Code. Requires Claude Max and ChatGPT subscriptions.

> **Platform: macOS only.** Agent Team mode requires iTerm2's built-in tmux integration. Solo + Codex mode may work on other platforms, but is untested.

| Item | Requirement | Notes |
|------|-------------|-------|
| Claude Max subscription | $100/month | Claude Code + Auto mode (Solo + Codex / Agent Team) |
| ChatGPT subscription | $20/month | Codex CLI (code review + QA) |
| Node.js | 18+ | Runs Claude Code, Codex CLI, and MCP Server |
| Git | Any version | Version control |
| Terminal | iTerm2 (macOS) | Agent Team tmux mode relies on iTerm2's built-in tmux integration; no separate tmux installation needed |

**Total cost: $120/month** — two top-tier models (Claude Opus + Codex), no additional API fees.

### How iSparto Differs from Existing Tools

Existing AI coding tools (Cursor, Windsurf, Copilot, Claude Code single session) all follow the same pattern — **you go back and forth with a single Agent**. The Agent has no team, no division of labor; everything depends on you and it trading messages back and forth.

iSparto turns a single Agent into **a team with clear roles**: Lead assembles structured prompts, Developer (Codex) implements, Teammates parallelize, and Doc Engineer keeps documentation in sync. Instead of directing an Agent line by line, you confirm the direction and accept the results.

| | Single-Agent Tools | iSparto |
|--|---------------------|---------|
| Collaboration mode | You go back and forth with a single Agent | Lead auto-selects: Solo + Codex for small tasks, Agent Team for parallel work |
| AI organization | Single Agent, no division of labor | Team-based (Lead + Teammate + Developer + Doc Engineer) |
| Parallelism | None — single-threaded conversation | Solo mode (default) for small tasks; Agent Team for parallel execution within a Wave |
| Code review | Agent reviews its own code (same source) | Lead reviews Developer (Codex) output (cross-model quality gate) |
| Cross-session state | Lost — must re-explain context every time | Driven by plan.md; `/start-working` auto-restores state |
| Documentation sync | Manual maintenance | Doc Engineer auto-audits every Wave |

**In short: other tools have you directing one Agent. iSparto has you directing an entire team.**

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash
```

One command handles everything: downloads a verified installer from GitHub Releases, checks/installs Claude Code and Codex CLI, logs into Codex, copies commands and templates to `~/.claude/`, and registers the global MCP Server. Your existing `~/.claude/settings.json` is never modified. A snapshot of your original files is automatically created before any changes — you can always revert to your pre-install state.

**Preview before installing:** add `--dry-run` to see what would happen without making any changes:

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash -s -- --dry-run
```

**Install a specific version:**

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash -s -- --version=0.3.0
```

**Upgrade:** re-run to pull the latest version and see what's new:

```bash
~/.isparto/install.sh --upgrade
```

> Upgrade updates framework components only (commands, templates, snapshot engine). Your project files (CLAUDE.md, docs/, code, settings) are never touched.

**Uninstall:** reverts all changes and restores your original files from the backup snapshot (works offline):

```bash
~/.isparto/install.sh --uninstall
```

<details>
<summary>Alternative: manual clone</summary>

```bash
git clone https://github.com/BinaryHB0916/iSparto.git
cd iSparto && ./install.sh              # or: ./install.sh --dry-run
```
</details>

---

## Quick Start

### Initialize a New Project

```bash
mkdir my-app && cd my-app
claude --effort max
/env-nogo                        # optional — confirm environment readiness
/init-project I want to build an xxx   # generates CLAUDE.md + docs/, Codex architecture pre-review
```

A snapshot is automatically taken before any files are created. If anything goes wrong, run `/restore` to roll back.

### Migrate an Existing Project

```bash
cd existing-project/
claude --effort max
/migrate --dry-run               # preview migration plan without executing (recommended for first run)
/migrate                         # scans project, proposes migration plan, preserves all existing content
```

A snapshot of your existing files is automatically taken before any changes. Run `/restore` at any time to roll back to the pre-migration state.

### Daily Work Cycle

```
/start-working
    → Lead reads plan.md, reports current status and TODOs
    → You confirm "go ahead"
        ↓
Lead's team runs on its own (you don't need to watch)
    → Break down tasks → Developer writes code → Codex reviews → Developer reviews fixes
    → Codex QA → Doc Engineer documentation audit → Lead merges code
        ↓
Occasionally Lead comes to you (escalate decisions / confirm commits)
        ↓
/end-working
    → Sync documentation → Update plan.md → commit → push
```

### When You Have New Requirements

```
/plan I want to add an xxx feature
    → Lead first reviews the product direction, produces a proposal
    → After you confirm the proposal, Lead writes it into plan.md and begins work
```

---

## Role Architecture

<p align="center">
  <img src="assets/role-architecture.svg" alt="Role Architecture" width="100%"/>
</p>

- Lead / Teammate / Doc Engineer: Claude primary sessions (see [model configuration](docs/configuration.md#agent-model-configuration))
- Developer: Codex via MCP (see [model configuration](docs/configuration.md#agent-model-configuration))

---

## Real-World Usage

iSparto used its own Agent Team workflow to develop itself. Below is the first complete dogfooding run — building the "Session Log" feature (automatic session metrics collection in `/end-working` and `/start-working`).

### Flow

1. **`/start-working`** — Lead read `plan.md`, reported Wave 5 status, identified the session log feature as the next task.
2. **Branch** — Lead created `feat/session-log`.
3. **Task breakdown** — Lead assigned file ownership:
   - Developer A: `commands/end-working.md` (add session report generation)
   - Developer B: `commands/start-working.md` (add session log reading)
4. **Parallel development** — Both Developers ran simultaneously and completed their tasks.
5. **Codex Review** — Found 2 P2 issues:
   - `git diff --stat` misses staged/untracked files. Fixed to `git diff HEAD --stat`.
   - Diff output inside a Markdown table breaks rendering. Moved to a code block.
6. **Fix** — Lead applied both Codex findings.
7. **Doc audit** — Doc Engineer updated `workflow.md` and `plan.md`.
8. **Merge** — Merged to `main` via `--no-ff` merge commit.

### Stats

| Metric | Value |
|--------|-------|
| Developers in parallel | 2 |
| Codex review passes | 1 |
| Issues caught by Codex | 2 (both fixed) |
| Files changed | 4 |
| Insertions / Deletions | +45 / -11 |
| Full cycle | Task breakdown, parallel dev, Codex review, fix, doc audit, merge |


---

## Getting Started Checklist

**One-time setup (`./install.sh` handles this automatically):**

- [ ] Claude Max + ChatGPT subscriptions active
- [ ] Terminal is iTerm2 (macOS, required for Agent Team split panes)
- [ ] `./install.sh` completed (Claude Code, Codex CLI, config files, MCP)
- [ ] Multi-device sync configured (if using multiple computers, see [configuration.md](docs/configuration.md#multi-device-sync-optional))

**Each new project (`/init-project` handles this automatically):**

- [ ] Launch with `claude --effort max`
- [ ] `/env-nogo` check passed (optional)
- [ ] `/init-project` has generated CLAUDE.md + docs/
- [ ] Project-level `.claude/settings.json` configured with platform-specific plugins (e.g., swift-lsp for iOS, optional)

---

## Repository Structure and Documentation Index

```
iSparto/
├── README.md                  ← The document you are reading now
├── README.zh-CN.md            ← Chinese version / 中文版
├── CLAUDE.md                  ← Project instructions for Claude Code
├── CONTRIBUTING.md            ← Contribution guidelines
├── settings.json              ← Reference template for project-level .claude/settings.json
├── CLAUDE-TEMPLATE.md         ← Template for generating new project CLAUDE.md
├── LICENSE
├── .gitignore
├── VERSION                    ← Current version (semver)
├── CHANGELOG.md               ← Release notes
├── bootstrap.sh               ← Thin entry point (version resolve + checksum verify)
├── install.sh                 ← Main installer (versioned per release)
├── isparto.sh                 ← Local stub (upgrade/uninstall/version)
├── scripts/
│   └── release.sh             ← Automated release script (bump version → changelog → tag → gh release)
├── lib/
│   └── snapshot.sh            ← Snapshot/restore engine (factory reset capability)
├── commands/
│   ├── start-working.md       ← Start working command
│   ├── end-working.md         ← End working command
│   ├── plan.md                ← Planning command
│   ├── init-project.md        ← Initialize project command
│   ├── env-nogo.md            ← Environment readiness check
│   ├── migrate.md             ← Migrate existing project to iSparto
│   └── restore.md             ← Restore project to a previous snapshot
├── templates/
│   ├── product-spec-template.md
│   ├── tech-spec-template.md
│   ├── design-spec-template.md
│   └── plan-template.md
└── docs/
    ├── product-spec.md        ← Product spec (iSparto's own, for self-bootstrapping)
    ├── plan.md                ← Development plan by Wave
    ├── session-log.md         ← Auto-generated session metrics (created by /end-working)
    ├── concepts.md            ← Core concepts (decoupling, Wave, file ownership) ⭐ Recommended reading
    ├── user-guide.md          ← User interaction guide (7 commands + 2 notifications) ⭐ Recommended reading
    ├── roles.md               ← Role definitions + Codex prompt templates
    ├── workflow.md            ← Full development workflow + branching strategy + Codex integration
    ├── configuration.md       ← Global configuration + adaptation guide + multi-device sync
    ├── troubleshooting.md     ← Common troubleshooting
    └── design-decisions.md    ← Design decision records
```

---

## Origin of the Name

In Greek mythology, the hero Cadmus slew a dragon and sowed its teeth into the earth. A host of fully armed warriors sprang from the ground — they were called **Spartoi** (Σπαρτοί), meaning "the sown ones."

This is the same story as iSparto's workflow: you sow your product requirements into `/init-project`, and an entire Agent Team assembles itself — Lead breaks down tasks, Developer writes code, Codex reviews and fixes, Doc Engineer keeps documentation in sync — a complete development team grown from a single seed.

The **i** was moved from the end of Spartoi to the front. Lowercase i = I = me, one person.

**iSparto = I + Sparto = one-person army.**

---

## License

[MIT](LICENSE)
