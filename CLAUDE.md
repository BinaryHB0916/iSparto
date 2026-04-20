# iSparto

## Project Overview
iSparto is an AI Agent Team workflow framework that turns single-agent Claude Code into a team with distinct roles (Lead + Teammate + Developer + Doc Engineer + Process Observer). Target users are independent developers. Current stage: open-source core workflow released, dogfooding in progress.

## Tech Stack
- Language: Shell (Bash), Markdown
- Framework: None (pure configuration project, driven by Claude Code slash commands + MCP)
- Platform: macOS (iTerm2 + tmux 3.x — tmux required since v0.8.0 for Independent Reviewer's `codex exec` invocation in a tmux pane)
- Build: No build step
- Other: Codex MCP Server (npx codex-mcp-server)

## Development Rules
- Communicate and generate documentation in the user's language (English or Chinese only)
- Any code/command change must synchronously update the corresponding documentation (README, docs/, command header comments)
- Product direction changes must be written into documentation, not just discussed in conversation
- Ask me first about uncertain product questions; do not decide on your own
- **plan.md update cadence:** update `docs/plan.md` either per-task (in the same commit as the task work) OR per-Wave (in the T10/close-out commit that lists all task completions with commit hashes — the Wave-close approach is acceptable when the Wave runs as a single atomic work session on a dedicated branch). Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates, because that is the step that knows the Wave is fully complete. If a fix session does not correspond to any plan.md entry (e.g., a bug fix not tied to any Wave), no plan.md update is required.
- **plan.md verification-count accuracy:** when a Wave completion entry records a commit count, compute it mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` — not by estimation. For entries authored pre-commit (standard `/end-working` cadence, where the Wave entry ships inside the same commit it documents), write the projected count and re-verify via the same command immediately after the commit lands; if mismatch, amend before push. Applies to every Wave close-out. The `<wave-base>` is the commit where the Wave branch diverged from the target branch.
- **Single TODO source (plan.md Backlog is authoritative):** All TODOs, deferred actions, framework rule-fix candidates, and open commitments — including Process Observer audit findings about the framework itself, user-direction commitments surfaced in conversation, and Wave-internal deferrals — must be written to `docs/plan.md`'s Backlog section. Writing new backlog-type content to any other file is a workflow violation. Specifically forbidden channels: (a) creating `docs/framework-feedback-*.md` files (pattern retired 2026-04-17); (b) embedding deferred items in Wave-entry prose (e.g., "Out of scope" paragraphs) without a parallel Backlog row; (c) storing project-level work items in `memory/` — memory is for awareness information (user preferences, project facts, external references) only, not work; (d) listing "next-session to-dos" only in `docs/session-log.md` Notes without a Backlog row. `/end-working` performs a TODO-homing audit that blocks the commit if any new backlog-type content lands outside `docs/plan.md`.
- Do not develop directly on main; feat/ for new features, fix/ for bug fixes, hotfix/ for urgent fixes, docs/ for pure documentation commits, release/ for releases
- install.sh changes must remain backward compatible (existing users must still be able to uninstall)
- Changes to command templates (commands/*.md) must be verified not to break existing users' /migrate and /init-project flows
- After completing all reviews, automatically create PR and merge to main — no manual user review needed
- Releases must use the `/release` command — manual `git tag`, `git push origin <tag>`, or any operation on main is not allowed. The release flow is fully automated by `scripts/release.sh`
- This project is the framework itself; all Tier 1 System Prompt Layer files (as defined in Documentation Language Convention) fall within the self-referential boundary — Lead edits directly, and Process Observer interceptions can be approved. This includes both subdirectory files (`commands/`, `templates/`, `scripts/`, `hooks/`, `agents/`, `docs/`, `lib/`) and root-level files (`CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `bootstrap.sh`, `install.sh`, `isparto.sh`). Tier 2/3/4 documentation (other `docs/*.md`, `README*.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`) is also in scope for direct Lead edits under the same framework self-referential principle.

## Documentation Language Convention

iSparto adopts a four-tier language architecture for all documentation and system prompts:

- **Tier 1 — System Prompt Layer (English only):** CLAUDE.md, CLAUDE-TEMPLATE.md, commands/*.md, agents/*.md, templates/*.md, hooks/**/*.sh, hooks/**/*.json, bootstrap.sh, install.sh, isparto.sh, scripts/*.sh, lib/*.sh. These files are read by AI agents as instructions; English ensures instruction-following stability and enables review by non-Chinese-speaking contributors.
- **Tier 2 — Reference Documentation (English only):** All files under docs/ (including subdirectories such as `docs/design-principles/*.md`) except Tier 4 historical artifacts and the docs/zh/ directory. Single source of truth in English; no Chinese mirror to avoid synchronization burden.
- **Tier 3 — User-Facing Entry (Bilingual or English with Chinese pointer):** README.md, README.zh-CN.md, docs/zh/quick-start.md, CONTRIBUTING.md. Maintained as parallel Chinese and English versions where applicable to serve both audiences at the entry point.
- **Tier 4 — Historical Artifacts (frozen):** `docs/session-log.md`, `docs/plan.md` (wholly Tier 4 — both historical Wave entries and forward-looking sections such as the Backlog, Rejected Approaches, and Tech Ecosystem Tracking table are exempt from the English-only rule; new plan.md entries default to English but may mix in CJK where a user conversation would lose nuance from translation), and historical entries in `CHANGELOG.md`. (The `docs/framework-feedback-*.md` pattern was retired 2026-04-17 per the Single TODO source rule above; any remaining historical references to it in session-log.md / CHANGELOG.md stay as frozen history.) Tier 4 files are not modified retroactively; new `CHANGELOG.md` entries use English. The `scripts/language-check.sh` guardian's Tier 2 exclusion list reflects this (see `TIER2_EXCLUDED_FILES` in the script).

**Hard-coded user-facing strings rule:** Tier 1 files must not embed literal user-facing strings in any specific language. Describe the intent in English and let the Lead generate the actual string in the user's language at runtime.

Example — describing the wrong pattern without embedding a target-language literal:

- WRONG: embedding a literal non-English user-facing string in a Report/Inform/Output field of a command or agent definition
- RIGHT: describing the intent, e.g., "Report to user (in user's language) that the gh account has been auto-switched to $REPO_OWNER"

**Illustrative-example rule:** When documenting a wrong pattern, describe it; do not embed a literal string in the target language. A literal example would itself trigger the language-check.sh guardian.

This convention is enforced by `scripts/language-check.sh`, integrated into the Doc Engineer audit step of `/end-working` starting from Wave 4. The guardian runs two orthogonal scans: (1) Tier 1 (System Prompt Layer) and Tier 2 (Reference Documentation) are scanned for CJK characters; (2) `commands/*.md` and `agents/*.md` are additionally scanned for Principle 1 violations (literal user-facing English strings missing the `(in user's language)` qualifier — the most obvious cases are caught mechanically by a verb/quoted-literal heuristic, with `e.g.` and `[...]` placeholder exemptions). Run `bash scripts/language-check.sh --self-test` to exercise the Principle 1 detector against built-in fixtures. The guardian blocks the commit if any violation is found.

## Collaboration Mode

See [docs/collaboration-mode.md](docs/collaboration-mode.md) for the full collaboration-mode definition — mode selection, plan mode, roles, lifecycle, implementation protocol, branch protocol, developer triggers, and branching/merge rules. Step-level execution of the lifecycle is defined in [commands/start-working.md](commands/start-working.md) and [commands/end-working.md](commands/end-working.md); the phase-level view lives in [docs/collaboration-mode.md](docs/collaboration-mode.md) §Lifecycle.

**iSparto-specific exception.** When iSparto is editing its own framework files under the self-referential boundary (see Development Rules above), Lead edits directly and the Implementation Protocol's Codex requirement does not apply. User projects that inherit this workflow via `CLAUDE-TEMPLATE.md` do NOT inherit the exception.

## Module Boundaries

| Module | Directory/Files | Description |
|--------|----------------|-------------|
| Bootstrap | bootstrap.sh | Thin bootstrap entry (parses version, verifies checksum, fetches install.sh) |
| Installer | install.sh, isparto.sh | Install/upgrade/uninstall; isparto.sh is the local stub |
| Snapshot Engine | lib/snapshot.sh | Snapshot/restore engine |
| Slash Commands | commands/*.md | 10 behavior definitions (system prompts driving Agent behavior; changes handled per Tier 2b) |
| Doctor | commands/doctor.md, scripts/doctor-check.sh | `/doctor` slash command + the 7-check bash/python3 script it invokes (local-only environment health: tmux / codex CLI / claude CLI / hook integrity / repo markers / codex config / VERSION ↔ git tag) |
| Doc Templates | templates/*.md | 5 structural templates (blueprints that /init-project generates docs from; changes handled per Tier 2b) |
| Project Template | CLAUDE-TEMPLATE.md | Template used to generate CLAUDE.md for new projects |
| Framework Docs | docs/ (concepts, roles, workflow, configuration, user-guide, troubleshooting, design-decisions, security) | User-facing framework documentation |
| Project Docs | docs/ (product-spec, plan) | iSparto's own product specification and development plan |
| Release Script | scripts/release.sh | Automated release (bump version → changelog → tag → gh release) |
| Assets | assets/*.svg | SVG images used by the README |
| Process Observer | hooks/process-observer/, agents/process-observer-audit.md | Real-time interception (hook scripts + dangerous-operations list) + post-session audit |
| Independent Reviewer | agents/independent-reviewer.md | Product-technical alignment blind review (Codex CLI in tmux pane — GPT-5.4, cross-provider isolation on top of zero inherited context) |
| READMEs | README.md, README.zh-CN.md | Bilingual README |

## Operational Guardrails
- Confirm before deleting files
- Do not commit directly to main — always merge through a PR
- Breaking changes to install.sh (changing backup format, removing legacy compatibility logic) require explicit user consent
- Dangerous operations are automatically intercepted by Process Observer hooks; see hooks/process-observer/rules/dangerous-operations.json for the full list

## User Preference Interface

The agent team treats the user's memory as **read-only input** used to adapt communication style; CLAUDE.md is the sole authority for behavior.

**Territory principle:** Memory governs "who you work with" (user preferences); CLAUDE.md governs "how to work" (workflow rules). Ownership is determined by topic domain, not by whether content conflicts.

**Three-level response model:**

| Level | Preference Type | Examples | Agent Team Response |
|-------|----------------|----------|---------------------|
| Level 1: Unconditional respect | Communication language, input method, output style, naming preferences | Voice input correction, no summaries, use Chinese | Adapt directly |
| Level 2: Conditional respect | Interaction pace, autonomy level, focus areas | Discuss before executing on questions, skip routine confirmations, prioritize performance | Adapt within workflow rule boundaries; urgent interceptions do not wait for discussion |
| Level 3: Record only, do not execute | Skipping process steps, changing order, lowering safety standards | Skip Codex review, push before review, push directly to main | Do not execute; inform the user (in user's language) that the workflow requires [Y] because [reason] |

**Conflict protocol:** When memory contradicts CLAUDE.md — execute CLAUDE.md, explain the reason to the user, do not modify the user's memory. If the user wants to change a rule, guide them to modify CLAUDE.md.

**Agent team memory write rules:**
- Allowed: project context (project type), external references (reference type), user profile (user type)
- Forbidden: workflow rules, process changes, any entry that duplicates existing CLAUDE.md content
- Pre-write check: does this topic belong to CLAUDE.md's territory? If yes, do not write

**Runtime output layering:** see `docs/design-principles/information-layering-policy.md`. Lead must classify every user-facing output as A-layer (decision interruption), B-layer (decision preparation at natural pause points: `/start-working` open, `/end-working` close, `/plan` proposal), or C-layer (silent archive) before emitting it. The Policy is enforced structurally via fixed B-layer briefing shapes in `commands/start-working.md`, `commands/end-working.md`, and `commands/plan.md`; Lead's runtime judgment narrows to word choice, not layer assignment. A-layer outputs are subject to Independent Reviewer A-layer Peer Review (see `docs/design-principles/a-layer-peer-review.md`).

## Common Commands
- Install test: `./install.sh --dry-run`
- Snapshot test: `bash lib/snapshot.sh list`
- Lint (no automation; relies on Codex review)

## Documentation Index
- Product spec -> docs/product-spec.md
- Development plan -> docs/plan.md
- Product roadmap -> docs/roadmap.md (v1.x / v2.x long-range vision; plan.md handles current v0.x phase)
- Framework concepts -> docs/concepts.md
- Role definitions -> docs/roles.md
- Workflow -> docs/workflow.md
- Collaboration mode -> docs/collaboration-mode.md
- Configuration guide -> docs/configuration.md
- User guide -> docs/user-guide.md
- Troubleshooting -> docs/troubleshooting.md
- Design decisions -> docs/design-decisions.md
- Process Observer -> docs/process-observer.md
- Security audit system -> docs/security.md
- Information Layering Policy -> docs/design-principles/information-layering-policy.md
- Conversation style guide -> docs/design-principles/conversation-style.md
- A-layer Peer Review -> docs/design-principles/a-layer-peer-review.md
- Case studies -> docs/case-studies.md
- Repository structure -> docs/repo-structure.md
- Dogfood log -> docs/dogfood-log.md
