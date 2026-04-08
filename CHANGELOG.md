# Changelog

All notable changes to iSparto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-04-08

### Changed

- **Documentation language convention established (Wave 1)** — Four-tier language architecture adopted across the framework. Tier 1 (System Prompt Layer: `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `commands/*.md`, `agents/*.md`, `templates/*.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `install.sh`, `bootstrap.sh`) is English-only for AI instruction-following stability and open-source contributor parity. Tier 2 (Reference Documentation: `docs/*.md` except historical artifacts and the `docs/zh/` directory) is English-only as single source of truth. Tier 3 (User-Facing Entry: `README.md`, `README.zh-CN.md`, `docs/zh/quick-start.md`, `CONTRIBUTING.md`) is bilingual at the entry point. Tier 4 (Historical Artifacts: `docs/session-log.md`, `docs/framework-feedback-*.md`, historical entries in `docs/plan.md` and `CHANGELOG.md`) is frozen. Hard-coded user-facing strings rule (Principle 1): Tier 1 must not embed literal user-facing strings in any specific language — describe the intent in English and let the Lead generate the actual string at runtime.
- **Tier 1 Englishized (Wave 2)** — All 166 CJK lines across `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, 9 `commands/*.md` files, `agents/process-observer-audit.md`, `templates/gitignore-security-baseline.md`, `hooks/process-observer/scripts/pre-tool-check.sh`, and `hooks/process-observer/rules/workflow-rules.json` translated to English. 3 residual Principle 1 violations caught by the Wave 2 Independent Reviewer and converted to the intent-description pattern.
- **Tier 2 Englishized (Wave 3)** — All 392 CJK lines across `docs/process-observer.md`, `docs/configuration.md`, `docs/security.md`, `docs/product-spec.md`, `docs/design-decisions.md`, `docs/workflow.md`, `docs/roles.md`, and `docs/troubleshooting.md` translated to English. `docs/independent-review.md` added to the guardian Tier 2 exclusion list to preserve immutable IR audit-trail content. No Chinese mirror of `docs/`: `docs/zh/` is restricted to a single file.
- **CLAUDE-TEMPLATE.md sync sweep + Process Observer F1 IN-PROGRESS state (Wave 5)** — `CLAUDE-TEMPLATE.md` Process Observer role description aligned with `CLAUDE.md` Core/Advisory layer framing; Solo and Agent Team workflow step 4 both extended with the "must complete before step 6 push/merge, cannot be deferred to /end-working" qualifier. `agents/process-observer-audit.md` F1 check (Independent Review at Wave boundary) Status enum expanded from `PASS/FAIL/N/A` to `PASS/IN-PROGRESS/FAIL/N/A` — mid-session audits triggered before IR runs now report a correctness-preserving IN-PROGRESS state instead of a shoehorned WARN, which resolves to PASS on the next audit pass once IR appends its report.

### Added

- **`scripts/language-check.sh` mechanical guardian + Doc Engineer audit item 9 (Wave 1 → Wave 4)** — Shipped in Wave 1 in warning mode: scans Tier 1 and Tier 2 files for CJK characters, scans `commands/*.md` and `agents/*.md` additionally for Principle 1 violations via a verb/quoted-literal heuristic (with `e.g.` and `[...]` placeholder exemptions); `--self-test` mode runs synthetic fixtures without touching the repo. Principle 1 detector added in inter-Wave Hotfix #2. Promoted to a blocking gate in Wave 4 by adding item 9 ("Language convention check") to the Doc Engineer audit checklist invoked from `/end-working` — PRs introducing CJK content in Tier 1/Tier 2 or Principle 1 violations in `commands/`/`agents/` are now blocked until fixed. Wave 4 also added the audit-fix-reaudit loop pattern (bounded at 3 iterations) and a 6-step blocked recovery path for loop-bound exceedance.
- **`docs/zh/quick-start.md` Chinese onboarding entry (Wave 5)** — New Tier 3 file (117 lines) serving as the first entry point for Chinese-speaking users: install, first-use (`/init-project`, `/migrate`), daily workflow (`/start-working`, `/end-working`), and troubleshooting pointer. Footer links to `CLAUDE.md` > Documentation Language Convention explaining the single-source-of-truth design and why reference docs remain English-only.
- **`CONTRIBUTING.md` Documentation Language Convention section (Wave 5)** — New top-level section summarizing the four-tier architecture for contributors, four key rules (Principle 1, no-Chinese-mirror, README sync, new-entries-in-English), and documenting the `language-check.sh` PR blocking gate with the two local commands contributors should run before opening a PR (`bash scripts/language-check.sh` and `bash scripts/language-check.sh --self-test`).

## [0.6.19] - 2026-04-05

### Fixed

- **Installer hardening** — `install.sh` now validates Python3 availability upfront (moved from line 406 to Dependencies section), adds curl timeouts (`--connect-timeout 10 --max-time 60`), validates mktemp/tar operations, and syncs version parsing regex with `bootstrap.sh`.
- **Bootstrap semver validation** — `bootstrap.sh` now validates parsed version format before proceeding, preventing silent failures on malformed GitHub API responses.
- **Snapshot path traversal guard** — `lib/snapshot.sh` `resolve_path()` now rejects bare `..` in addition to `../`, `*/../*`, and `*/..` patterns, closing a directory escape edge case.
- **Independent Reviewer trigger chain** — repaired broken IR invocation chain: `end-working.md` now includes Wave Boundary Review (Step 3) with IR spawn on Wave completion; `/plan` triggers IR unconditionally (removed "user-visible behavior changes" gate); `process-observer-audit.md` adds F1 compliance check for IR execution; trigger conditions synced across `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `workflow.md`, and `roles.md`.

### Changed

- **README version examples updated** — install command examples now reference v0.6.18 (was 0.3.0). Troubleshooting link added after uninstall section in both English and Chinese READMEs.

## [0.6.18] - 2026-04-05

### Changed

- **`/release` zero-confirmation mode** — removed all confirmation gates; version auto-increments from VERSION file (patch default, `/release minor` and `/release major` supported). User runs `/release` → fully automated → outputs release link.
- **release.sh merge retry** — `gh pr merge` now retries once after 2s on failure, handling the race condition where main gets updated between PR creation and merge.

## [0.6.17] - 2026-04-05

### Added

- **`/release` slash command** — 4-step guided release process (version confirm → precondition check → execute script → post-release verify). Prevents Lead from improvising release steps. Follows the same principle as `/start-working` and `/end-working`: all ceremonial operations get step-by-step instructions.

### Changed

- **release.sh: removed local tag push** — replaced `git tag + git push origin <tag>` with `gh release create --target main`. Tag is now created via GitHub API, eliminating conflict with push-on-main hook.
- **Self-reference boundary expanded** — CLAUDE.md now covers all framework directories (commands/, templates/, scripts/, hooks/, agents/, docs/) instead of only hooks/*.sh and rules/*.json. Lead can directly edit any framework file when working on the iSparto project itself.

## [0.6.16] - 2026-04-05

### Added

- **Multi-model Developer strategy** — Developer role split into two tiers: `gpt-5.3-codex` (xhigh) for implementation, `gpt-5.4-mini` (high) for QA/quick fixes. Tier-to-model mapping documented in `docs/configuration.md` "Developer 分档模型策略" section. MCP model parameter validated: `gpt-5.4-mini` ✅, `gpt-5.3-codex-spark` ❌ (ChatGPT Plus auth limitation).
- **Model mapping table expanded** — added "选型理由" (rationale) column and Independent Reviewer row to `docs/configuration.md`.
- **Technology ecosystem tracking** — `docs/plan.md` new "技术生态追踪" table tracking 6 items: GPT-5.3-codex retirement, spark support, codex-plugin-cc integration, cross-session automation, Plugin hook coverage, multi-agent interop standards.
- **GitHub account auto-alignment** — `/start-working` (Step 6) and `/end-working` (Step 7) now detect repo owner from `git remote` URL, compare with `gh` active account, and auto-switch if mismatched. No-op for single-account users; silent skip if `gh` is not installed.

### Changed

- `docs/workflow.md` Tier 1 section: added model selection note referencing the Developer tier strategy.
- `CLAUDE.md` and `CLAUDE-TEMPLATE.md` Developer role descriptions updated to reflect two-tier model configuration.

## [0.6.15] - 2026-04-04

### Changed

- **MCP server renamed** `codex-reviewer` → `codex-dev` — tool call name becomes `mcp__codex-dev__codex`. `install.sh --upgrade` auto-migrates user-level MCP registration; `/start-working` auto-migrates project-level hook matchers. Old name preserved in cleanup lists for backward compatibility.
- **`.env` detection** in `pre-tool-check.sh` switched from `find` traversal to `git ls-files` index query — O(git index) instead of O(filesystem), skips `node_modules` and similar large directories.
- **install.sh inline Python extracted** to `lib/patch-settings.py` (~150 lines → 2-line calls). Subcommands: `patch-user` (user-level hook registration) and `clean-project` (project-level Bash hook cleanup).
- `settings.json` → `settings.example.json` — clarifies the repo root file is a reference template, not a project config.
- `end-working.md` step 4: corrected "can run in parallel" to "triggered sequentially by Lead" (Doc Engineer and Process Observer have no data dependency but are not parallelized).
- Doc Engineer audit checklist: added CLAUDE.md ↔ CLAUDE-TEMPLATE.md workflow section consistency check.

### Added

- `docs/independent-review.md` — placeholder for Independent Reviewer output target.
- `design-decisions.md`: MCP rename resolved; `settings.json` rename rationale; `extract_json_field` JSON parsing limitation (known limitation).

## [0.6.14] - 2026-04-03

### Added

- **Independent Reviewer role** — product-technical alignment blind reviewer, spawned as Teammate (tmux) with zero inherited context. Independently reads product-spec then tech-spec to verify the technical approach implements what the product requires. Mandatory at Phase 0, conditional at Wave boundaries. CRITICAL findings block development; after fix, must re-trigger reviewer to verify.
- **QA three-level verification tags** — acceptance script eval steps now require `[code]`, `[build]`, or `[runtime]` tags. Features with user-visible behavior MUST include at least one `[build]` and one `[runtime]` step. QA prompt now includes "MANDATORY: Build before testing" and requires evidence for every eval step.

### Changed

- `templates/plan-template.md` acceptance script format updated with verification level tags and explanatory comments
- `templates/plan-template.md` Completion Criteria split into three verification levels (`[code]`/`[build]`/`[runtime]`)
- `docs/roles.md` QA prompt template: added build-first mandate, three-level verification instructions, evidence requirements, updated report format
- `docs/roles.md` new Independent Reviewer section with role definition and trigger conditions
- `commands/plan.md` acceptance script guidance now requires verification level tags
- `commands/init-project.md` Phase 0 adds Independent Review step (Step 11) before user confirmation
- `docs/workflow.md` Phase 0 adds Independent Reviewer between Codex architecture review and user confirmation
- `docs/workflow.md` Solo and Agent Team workflows add step 3.5 for conditional Independent Review
- `docs/workflow.md` "Simulates key user operation paths" changed to "Runs the app and verifies key user operation paths at runtime"
- CLAUDE.md and CLAUDE-TEMPLATE.md workflow step 3 strengthened with build-first + verification levels
- CLAUDE.md and CLAUDE-TEMPLATE.md add Independent Reviewer to Roles and workflow step 3.5
- CLAUDE.md Module Boundaries table updated: agents/ split into Process Observer and Independent Reviewer entries

## [0.6.13] - 2026-04-03

### Added

- **Branch Protocol** — entrance defense for main branch protection: branch check moved from Step 7 to Step 0 in `start-working.md` (before reading any files), `plan.md` Step 4 adds branch guard before development, new Branch Protocol section in CLAUDE.md and CLAUDE-TEMPLATE.md
- **Audit-to-framework feedback mechanism** — Process Observer audit now classifies deviations as user-side (stays in session-log) vs framework-side (generates `docs/framework-feedback-MMDD.md` for iSparto improvement)
- **Audit output layering** — session briefing shows only FAIL items with actionable suggestions (all PASS = silent); full compliance report stays in Lead's internal context
- **Doc Engineer pre-merge gate** in `end-working.md` Step 7 — Doc Engineer audit is checked before PR creation

### Fixed

- Hook block messages for branch-gated rules now include actionable recovery command (`git checkout -b <type>/<name>`) instead of generic "not allowed"
- Compound commands (`git checkout -b X && git commit`) no longer incorrectly blocked by branch-gated hooks
- Dead link in CLAUDE-TEMPLATE.md: `~/.isparto/docs/` → GitHub repository URL (install.sh does not copy docs/ to ~/.isparto/)

### Changed

- `commands/end-working.md` session-log template: removed 3 internal metrics (Developers spawned, Codex reviews, Codex catches) — users see "what was done", not framework internals
- CLAUDE.md workflow step 4 (Doc Engineer): strengthened to "must complete before push/merge, not deferred to /end-working" (both Solo and Agent Team)
- CLAUDE.md Development Rules: plan.md update timing clarified to "in the same commit, not deferred to /end-working"
- `docs/workflow.md` Tier 2a "Pure visual" clarified: type changes (`LocalizedStringKey` vs `String`), locale API parameters, and string routing logic are Tier 1, not "copy text"
- `docs/workflow.md` Solo and Agent Team flows now include Branch guard step before reading plan.md

## [0.6.12] - 2026-04-03

### Added

- **Implementation Protocol** in CLAUDE.md and CLAUDE-TEMPLATE.md — mandatory 7-step sequence with explicit `mcp__codex-reviewer__codex` tool name, enforcing Codex-first code implementation for both Solo and Agent Team modes

### Changed

- `commands/plan.md` Step 4 now explicitly references Implementation Protocol with tool name at the plan→execution boundary
- Hook block messages in `pre-tool-check.sh` now include actionable guidance: tool name (`mcp__codex-reviewer__codex`) and prompt template reference (`docs/roles.md`)
- `workflow-rules.json` reason fields updated to match enhanced block messages
- `docs/workflow.md` Solo and Agent Team flows now reference Implementation Protocol

## [0.6.11] - 2026-04-01

### Fixed

- Bootstrap push-to-main: `push-on-main` and `git-push-main-direct` rules now allow initial push when remote has no main/master branch yet (detected via `git rev-parse --verify`)
- Git-rule false positives: added `matches_outside_quotes()` helper that strips quoted content before re-checking patterns, preventing commands like `gh pr create --body "...git push main..."` from being blocked; applied to 5 git rules (`commit/merge/push-on-main`, `git-push-main-direct`, `git-force-push-protected`); filesystem rules unaffected

### Changed

- `.sh` added to `workflow-rules.json` `allowed_extensions`, enabling Lead to directly edit hooks/ scripts per CLAUDE.md

## [0.6.10] - 2026-03-31

## [0.6.9] - 2026-03-31

### Changed

- Sensitive file detection rules (`commit-env-file`, `commit-env-file-bulk`, `commit-credentials`, `commit-ssh-keys`, `commit-aws-credentials`) removed from `dangerous-operations.json` — responsibility migrated to three-layer security system (`security-patterns.json`), which scans actual staged files and content instead of command string substrings, eliminating false positives

## [0.6.8] - 2026-03-31

### Added

- Three-layer security audit system: Layer 1 (real-time Write/Edit content scanning for critical secrets), Layer 2 (pre-commit full secret/PII/sensitive-file scanning), Layer 3 (`/security-audit` milestone-level full audit including git history and dependency checks)
- `security-patterns.json` — single source of truth for all security scanning patterns (12 secret patterns, 4 PII patterns, sensitive file globs, gitignore baseline)
- `pre-commit-security.sh` — pre-commit scanner that reads patterns from JSON, supports `.secureignore` whitelist
- `/security-audit` slash command — full project security audit with git history scanning (`-G` regex), dependency checks, and structured report output
- `.secureignore` convention — per-project whitelist for false positive management (format: `file:pattern_id:reason`)
- `gitignore-security-baseline.md` template — security .gitignore entries applied by `/init-project` and `/migrate`
- Security compliance check added to Doc Engineer audit checklist (item 8)
- Security review added to Codex QA prompt template
- Security rules added to Developer implementation prompt template
- `docs/security.md` — full documentation of the three-layer defense system

### Changed

- `pre-tool-check.sh` — Edit/Write branch now scans content for 5 critical secret patterns before allowing writes (L1 real-time gate)
- `/end-working` — security scan step inserted before git commit (L2 pre-commit gate)
- `/init-project` — adds security baseline to .gitignore and creates empty .secureignore
- `/migrate` — checks .gitignore against security baseline and runs full security scan on existing code
- `CLAUDE-TEMPLATE.md` — added security rules to Development Rules and Operational Guardrails
- `docs/process-observer.md` — added content security scanning (category 8) and three-layer comparison table
- `docs/roles.md` — security checks in Codex QA, Developer implementation, and Doc Engineer audit
- `install.sh` — copies `pre-commit-security.sh` and `security-patterns.json` to `$ISPARTO_HOME`

## [0.6.7] - 2026-03-30

### Added

- Self-validating startup: `/start-working` runs build/test smoke check from CLAUDE.md's "Common Commands" section after docs drift check — non-blocking (report only), skipped if no commands defined
- "Stateless Session" concept in `docs/concepts.md` — explicit declaration that each session starts with zero memory, all state reconstructed from plan.md + session-log.md + git + CLAUDE.md. Inspired by 12 Factor Agents (HumanLayer) Factor 12: Stateless Reducer
- CLAUDE-TEMPLATE.md exception documented in "不直写代码"动机集中化 design decision — template carries full copy since generated projects cannot reference framework internals

### Fixed

- Runtime health check command source: restricted to "Common Commands" section only, not the descriptive "Build" field in Tech Stack (Codex review P2)

## [0.6.6] - 2026-03-30

### Added

- Rejected approaches tracking: `templates/plan-template.md` adds "Rejected Approaches" table; `/end-working` records rejected paths, `/start-working` surfaces them, Lead role requires recording, Doc Engineer audits coverage
- "Behavioral Template" concept in `docs/concepts.md` — distinguishes executable system prompts (`commands/*.md`, `templates/*.md`) from passive documentation
- Tier 2b (Developer review only, no QA) in `docs/workflow.md` for behavioral template changes — balances correctness review with prompt engineering iteration speed

### Changed

- Centralized "no direct code" rationale: single definition in CLAUDE.md Collaboration Mode section; all other locations (`docs/roles.md`, `CLAUDE-TEMPLATE.md`) reference it instead of duplicating
- Module Boundaries table: Slash Commands and Doc Templates descriptions updated to reflect behavioral nature (system prompts, not passive docs)
- Tier 3 now explicitly excludes behavioral templates (`commands/*.md`, `templates/*.md`)
- `docs/design-decisions.md`: style unified to Chinese for all entries

## [0.6.5] - 2026-03-30

### Fixed

- Process Observer Audit agent definition file (`agents/process-observer-audit.md`) now installed by `install.sh` — without this file the Sonnet model downgrade from v0.6.4 silently fell back to Lead's Opus model

### Added

- iSparto framework reference line in `CLAUDE-TEMPLATE.md` for generated project CLAUDE.md files

## [0.6.4] - 2026-03-30

### Fixed

- Hooks registration layered: user-level registers only `Bash` (universal safety), project-level registers `Edit`/`Write`/`Codex` (iSparto workflow rules) — non-iSparto projects no longer affected by Edit/Write interception (PR #69 regression)
- `install.sh --upgrade` auto-cleans v0.6.3 residual workflow matchers (Edit/Write/Codex) from user-level `~/.claude/settings.json`
- `--dry-run` now reports pending workflow matcher cleanup from user-level settings
- `/start-working` auto-repair validates specific `pre-tool-check.sh` command per matcher, not just matcher existence
- Hardcoded model name `"gpt-5.3-codex"` removed from `docs/roles.md` Developer role definition — replaced with configuration table reference (completes role-model decoupling)

### Added

- `/start-working` project-level hooks auto-validation step — auto-adds missing Edit/Write/Codex hooks on session start
- `/init-project` and `/migrate` now register Edit/Write/Codex workflow hooks at project level
- MCP server name coupling recorded as known limitation in design-decisions.md

### Changed

- design-decisions.md: "Hooks 注册位置" updated to "Hooks 注册分层" reflecting layered architecture
- troubleshooting.md: updated hooks-related entries for layered architecture + added entry for PR #69 residue cleanup

## [0.6.3] - 2026-03-30

### Added

- Acceptance script (action/eval format) field in plan template — QA tests against pre-defined behavioral criteria instead of ad-hoc prompts
- Context window capacity as 4th Wave decoupling criterion alongside file/data/logic levels
- Module Memory placeholder in tech-spec template ("Decisions & Lessons Learned" per module), forming a three-layer memory model (Project/Module/Personal)
- `merge-on-main` and `push-on-main` hook rules — closes blind spots where git merge/push on main bypassed interception
- Process Observer core/suggestion layer distinction — Hooks = hard guarantee, Sub-agent = best-effort
- Self-development rule in CLAUDE.md for editing iSparto's own hook scripts

### Changed

- Hooks registration moved from project-level to user-level `~/.claude/settings.json` — upgrade once, all projects benefit
- QA smoke testing prompt template now references acceptance scripts from plan.md
- `pre-tool-check.sh` refactored: unified branch-gated `case` statement for commit/merge/push-on-main
- `/plan` command now requires acceptance scripts per team task in output

### Removed

- Local merge fallback from end-working (`git checkout main && git merge`) — contradicted "no direct ops on main" principle
- Project-level hooks JSON blocks from init-project.md and migrate.md (replaced by user-level registration)

## [0.6.2] - 2026-03-27

### Fixed

- isparto.sh: `exec` replaced with `bash`+`exit` so EXIT trap fires and temp file is cleaned up
- isparto.sh: snapshot restore failure now aborts uninstall to prevent data loss
- snapshot.sh: `--keep` value validated as positive integer (rejects non-numeric input)
- snapshot.sh: added corruption guard for missing `files.txt` in snapshots
- snapshot.sh: replaced unsafe `ls`-in-for-loop with glob+array in `cmd_prune()`
- release.sh: added error recovery for `gh pr create`/`gh pr merge` failures
- MPC→MCP typo corrected across 7 locations
- Checklist count corrected (13→14) in product-spec.md
- Doc Engineer compliance reference corrected (C1-C3→C1-C4) in workflow.md
- Developer model name standardized to `gpt-5.3-codex` across all docs
- Process Observer rule docs aligned with actual hook implementation
- CLAUDE-TEMPLATE.md: added Mode Selection Checkpoint and Plan Mode sections

### Removed

- Legacy manifest backup system from install.sh (replaced by snapshot engine)
- Git-clone migration cleanup from install.sh (release-based install is the only method)
- Unused `code_extensions` array from workflow-rules.json
- Dead code: unused `snap_type` variable, no-op `UPGRADE` branch, unused `severity` parameter

### Changed

- isparto.sh: deduplicated mcp/npm manifest handlers into shared helper functions
- pre-tool-check.sh: consolidated 3 duplicated awk JSON-extraction blocks into `extract_json_field()` helper
- bootstrap.sh: renamed `TMPDIR` to `BOOTSTRAP_TMPDIR` to avoid shadowing system variable
- release.sh: renamed `TMPDIR` to `RELEASE_TMPDIR` to avoid shadowing system variable
- install.sh: standardized all `~/` paths to `$HOME/` for quoting safety
- design-decisions.md: updated to reflect current role architecture
- session-log.md + plan.md: removed unreleased project names for privacy

## [0.6.1] - 2026-03-27

### Added

- Process Observer full workflow monitoring — expands from Bash-only (20 rules) to all tool calls: Edit/Write code file interception (blocks direct code editing by all roles except Developer), Codex MCP structured prompt enforcement (must contain ## heading), new workflow-rules.json with configurable extension lists
- install.sh and project templates (init-project, migrate) register 4 hook matchers: Bash, Edit, Write, mcp__codex-reviewer__codex

### Fixed

- install.sh --upgrade now skips redundant tarball download when already on the target version

## [0.6.0] - 2026-03-27

### Changed

- Role swap: Lead/Teammate no longer write code directly — they assemble structured prompts for Developer (Codex) and review output. Codex moves from Reviewer to primary implementer
- 5-role architecture: Lead, Teammate, Developer, Doc Engineer, Process Observer (QA merged into Developer as a prompt mode, replacing the former 4-role model)
- New Agent Model Configuration table in docs/configuration.md — single source of truth for role-model binding; all hardcoded model names removed from role definitions, workflows, READMEs, and SVG diagrams
- Terminology migration across 12 files, 6 modules: "Codex Reviewer" → "Developer", "Claude Developer" → "Teammate", model names replaced with configuration table references
- Implementation prompt template added to roles.md (replaces code review prompt for the new Developer role)
- Developer Trigger Conditions table (renamed from Codex Review Trigger Conditions) with updated terminology

## [0.5.4] - 2026-03-27

### Added

- User Preference Interface: territory-based boundary between Claude Code auto-memory and CLAUDE.md workflow rules, three-level preference response model (unconditional / conditional / record-only), conflict protocol, and agent team memory write rules
- Plan Mode auto-trigger: Lead autonomously enters plan mode for cross-module, core design, user-facing, or hard-to-reverse changes
- CLAUDE-TEMPLATE.md now includes User Preference Interface section (new projects inherit the rules via /init-project)
- docs/configuration.md: detailed User Preference Interface reference documentation
- docs/concepts.md: User Preference Interface added to Concept Quick Reference
- docs/user-guide.md: "Your Preferences and the Agent Team" section
- docs/design-decisions.md: recorded User Preference Interface and Plan Mode decisions

## [0.5.3] - 2026-03-26

### Changed

- Codex review trigger rules overhauled: default is now "trigger code review + QA" for all code changes (Tier 1); only pure visual/config changes (Tier 2, QA only) and pure doc/formatting (Tier 3, skip both) are exempt
- New Wave-level safety net: each Wave must include at least one batch Codex review regardless of individual change categorization
- Process Observer compliance checklist expanded: 13 → 14 items (added B4 Wave-level batch review check)

## [0.5.2] - 2026-03-26

### Added

- `install.sh --upgrade` now auto-patches project-level `.claude/settings.json` to register Process Observer hooks if missing (covers projects init'd before v0.5.0)
- Graceful fallback: warns if python3 is unavailable or settings.json is invalid, suggests `/migrate` as alternative

## [0.5.1] - 2026-03-26

### Added

- Process Observer C4 check: cross-references plan.md unchecked items against actual codebase state, catches implemented features that were not marked done

### Fixed

- All 7 command templates now detect user's language and respond accordingly (Chinese or English); previously always responded in English regardless of user input

## [0.5.0] - 2026-03-26

### Added

- Process Observer role: real-time interception via PreToolUse hooks (20 rules, 6 categories) + post-session compliance audit (13 check items, 5 checklists)
- dangerous-operations.json: configurable high-risk operation ruleset (git destructive, sensitive info leak, hook bypass, filesystem destructive, iSparto-specific, direct-on-main)
- hooks/process-observer/scripts/pre-tool-check.sh: shell-based hook script, no jq dependency, POSIX ERE patterns
- /end-working now includes Process Observer audit step with deviation report + rule correction suggestions
- /init-project and /migrate auto-register Process Observer hooks in project settings.json
- install.sh installs hooks to ~/.isparto/hooks/ and isparto.sh --uninstall cleans them up
- Three-phase product roadmap: v0.x (developer tool) → v1.x (autonomous dev team) → v2.x (CEO workbench)
- Three-layer capability model in product-spec.md (process autonomy → status visibility → requirement understanding)
- docs/process-observer.md: complete role documentation with audit checklists, deviation report template, and feedback loop mechanism

## [0.4.1] - 2026-03-25

### Fixed

- isparto.sh: use `exec` in do_upgrade() to prevent `;;` syntax error after self-overwrite during upgrade
- Upgrade output: compressed from ~40 lines to ~15 (changelog folded to Added + counts, deps/files/MCP collapsed, removed Next Step for upgrades)

## [0.4.0] - 2026-03-25

### Added

- Agent Team mode now triggers for read tasks (code review, doc audit, research) in addition to write tasks
- Platform check: install.sh warns on non-macOS systems

### Changed

- Collaboration Mode selection criteria refined: "decomposable + worth the overhead" applies to both read and write
- Extracted language instruction from 7 command templates into CLAUDE.md/CLAUDE-TEMPLATE.md (single source of truth)
- Simplified configuration.md: removed Memory Boundary section, shortened Multi-Device Sync to 3 lines
- release.sh uses PR flow instead of direct push to main

### Fixed

- isparto.sh: trap local variable scope bug (local var not accessible in EXIT trap after function returns)
- snapshot.sh: --latest flag now compares timestamps instead of relying on glob order
- Shell scripts: fixed trap quoting across bootstrap.sh, install.sh, isparto.sh, scripts/release.sh
- README: fixed notification count, Solo mode description, directory tree completeness, zh-CN self-reference link
- workflow.md: fixed release branch format, added Setup Assistant footnote

### Removed

- Pro version section from product-spec.md (open-source repo only contains free features)
- Screenshot placeholder notes from READMEs (will use video demos)
- Dead code: unused color variables, unreachable VERSION fallback branch, stale checksums.sha256 reference

## [0.3.0] - 2026-03-25

### Added

- Automated release script (scripts/release.sh): bump version, update changelog, tag, push, create GitHub Release with assets

### Fixed

- Upgrade from git-clone install no longer copies files to themselves

## [0.2.0] - 2026-03-25

### Changed

- Installer architecture: replaced git-clone approach with thin bootstrap + GitHub Releases
- bootstrap.sh: new thin entry point with SHA256 checksum verification and version pinning
- isparto.sh: new local stub for offline uninstall/restore and network upgrade
- install.sh: downloads release tarball instead of cloning git repo
- Automatic migration from old git-clone installs to release-based installs

### Fixed

- Upgrade from old versions no longer requires pressing Y for each file
- Self-update mechanism works reliably across all versions

## [0.1.0] - 2026-03-24

### Added

- Core workflow with 7 slash commands (/start-working, /end-working, /plan, /init-project, /migrate, /env-nogo, /restore)
- 4 document templates (product-spec, tech-spec, design-spec, plan)
- CLAUDE-TEMPLATE.md for bootstrapping new projects
- Install system (install.sh) with dry-run, uninstall, upgrade, and MCP registration support
- Bilingual README (English and Chinese)
- SVG assets for header banner and role architecture diagram
- Snapshot/restore system (lib/snapshot.sh) for saving and restoring project state
- /restore slash command integrated into install, migrate, and init-project flows
- Session log feature for tracking development sessions
- Self-bootstrap: iSparto migrated to its own workflow
- Real-world usage section in README with dogfooding results
- Upgrade system for updating iSparto in existing projects
