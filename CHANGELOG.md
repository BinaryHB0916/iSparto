# Changelog

All notable changes to iSparto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **v0.8.0 documentation alignment — READMEs, reference docs, CLAUDE-TEMPLATE.md** — Back-propagate the 10-command slash command inventory to user-facing and reference docs (`/release` shipped in v0.6.17 but was missing from `docs/user-guide.md`, `docs/product-spec.md`, and `docs/workflow.md` Custom Commands). Correct DE/PO audit ordering across `docs/workflow.md`, `docs/roles.md`, `docs/collaboration-mode.md`, and `CLAUDE-TEMPLATE.md` to match `commands/end-working.md` Step 5 (PO) / Step 9 (DE pre-merge gate); remove the "cannot be deferred to /end-working" over-constraint that conflicted with Step 9's fallback design, normalize the Agent Team "(last step, ensures QA fixes are also audited)" parenthetical to "(as sub-agent)", and replace the step-5 "can run in parallel with Doc Engineer" wording with the Step-order-aligned form. Sync `README.md` + `README.zh-CN.md` for tmux hard-dependency (since v0.8.0) and Codex-second-consumer (Independent Reviewer via `codex exec` in tmux pane) framing; bilingual divergence on the Sonnet advisory audit layer also closed. Fix `--version=0.6.18` → `--version=0.8.0` in both README install examples. Add Wave-Boundary IR one-liner context-tag reminder to `docs/workflow.md` matching `commands/end-working.md` Step 3a canonical form. Replace stale PO inline bullet enumeration in `docs/workflow.md` diagrams with a single pointer to `agents/process-observer-audit.md`'s canonical 19-row checklist. No functional changes.

- **v0.8.0 documentation alignment Phase 3 — README v0.8.0 discoverability + new-concept Quick Reference** — Surface v0.8.0 runtime-expectation changes in both READMEs via a single-sentence pointer to `CHANGELOG.md` (tmux 3.x hard dep + Codex CLI serving Developer and Independent Reviewer), and define "Wave" inline at its first README mention (L28 table row) with a link to `docs/concepts.md` Wave Parallelism section. Extend `docs/concepts.md` Quick Reference table with three new rows covering A-layer Peer Review, Guardian Scripts family (5 scripts), and the v0.8.0 Observation-period Tracker. Closes the v0.8.0 Doc Alignment arc; no new content created — all additions attach to existing structures. No functional changes.

- **v0.8.0 documentation alignment Phase 2 — Chinese quick-start + PO audit E6 pointer** — Bring `docs/zh/quick-start.md` up to v0.8.0: tmux 3.x hard dependency surfaced as its own row in the Prerequisites table, ChatGPT subscription description expanded to cover both Codex consumers (Developer + Independent Reviewer), `/plan` + `/env-nogo` + `/doctor` added to the daily-flow and first-use coverage, daily-flow Step-5 PO / Step-9 DE ordering replaces the prior "commit + push + Doc Engineer + Process Observer" DE-before-PO phrasing, and `docs/plan.md` Backlog identified as the single TODO source with an explicit link-out pointing to `docs/user-guide.md` for the two commands not covered in the onboarding doc (`/security-audit` and `/release`). Correct `agents/process-observer-audit.md` E6 row's stale line-number navigation aid ("plan.md around line 963") by anchoring the precondition on heading-text alone — title starts with `### v0.8.0` AND contains the ASCII substring `Tracker` (disambiguates against the L105 v0.8.0 model-upgrade Wave-entry heading that shares the `### v0.8.0` prefix; stays ASCII-only per Tier 1 language convention). No functional changes.

## [0.8.0] - 2026-04-20

> Date stamp resolved at release time to the merge day's CST (Asia/Shanghai), aligning with the iSparto commit-count Rule 2 timing convention.

### Added

- **`scripts/gh-account-guard.sh` gh account mid-session drift guard (FR-13)** — new bash+python3 script (527 lines, `--help` / `--self-test` / unknown-argument-exits-2) invoked from `commands/end-working.md` Step 9 immediately before `gh pr create` to close the gap between `/start-working` Step 6 and `/end-working` Step 8's session-boundary alignment snapshots. Extracts `REPO_OWNER` from `git remote get-url origin` and `GH_USER` from `gh api /user --jq .login`; three outcomes — exit 0 silent when aligned / no probe data / auto-switch recovered (`gh auth switch --user <REPO_OWNER>` flips the active account back and the re-probe matches), exit 2 A-layer intercept when the auto-switch cannot recover (halts before PR creation to prevent wrong-account attribution). Self-test runs three fixtures (aligned / mismatch-auto-recovers / mismatch-unrecoverable) against stubbed `git` + `gh` binaries in a PATH-isolated sandbox with no network or real gh-state mutation. Portable by design — no dependency on user-level `~/.claude/settings.json` PreToolUse hooks; works on a fresh `git clone` of an iSparto fork on macOS without any prior user-level setup. `commands/end-working.md` Step 9 gains a 4-line bullet wiring the guard between the Doc Engineer re-audit loop and `gh pr create`, with a silent-skip path when the script is absent (stale-install tolerance; next `install.sh --upgrade` lands it). Style mirrors `scripts/session-health.sh` (bash wrapper + python3 heredoc, same option parsing, same shell-collected-inputs / python-pure-formatting split). Part of v0.8.0 observation-period Wave 4.

- **`/start-working` Session Health Preview** — new fixed structure appended to `/start-working`'s Step 9 B-layer briefing, displaying current branch, last commit, uncommitted-file count (+ first 5 filenames when non-empty), BLOCKING marker state (present with rationale excerpt / clear), and v0.8.0 observation-period status (Wave N/5 + real-IR progress toward Release Gate 条件 2 when active). Assembled by the new `scripts/session-health.sh` mechanical helper (bash wrapper + python3 heredoc — mirrors `scripts/doctor-check.sh` / `scripts/language-check.sh` style) with `--self-test` fixtures validating output format and `--help` printing usage. Reduces the per-session-kickoff cognitive load of manually running `git status` / `git log` / `grep BLOCKING` to reconstruct context. `commands/start-working.md` Step 9 C-layer forbidden-items list updated to exempt Session Health Preview content (branch, file counts, observation metrics). Part of v0.8.0 observation-period Wave 3.

- **`/doctor` slash command for local environment health check** — new `commands/doctor.md` + `scripts/doctor-check.sh` (7 checks: tmux availability, Codex CLI availability, Claude Code version, hook-file integrity, iSparto repo markers + BLOCKING acknowledgement state, Codex `config.toml` sanity, VERSION ↔ git-tag consistency). Offline and network-free — runs in under a second; `--self-test` validates the output-format pipeline with synthetic fixtures. Per-check lines emit `[PASS|WARN|FAIL] D<n>: <name> — <result>` with a `(fix: <hint>)` suffix on WARN/FAIL; exit 0 = no FAIL, 1 = one or more FAIL, 2 = internal error. Mirrors `scripts/language-check.sh` / `scripts/policy-lint.sh` style (bash wrapper + python3 heredoc + color output + `--self-test`). `install.sh` deploys the script to `~/.isparto/scripts/doctor-check.sh` (executable) so `/doctor` works from any working directory; `isparto.sh --uninstall` cleans up the new `$ISPARTO_HOME/scripts/` tree. `docs/user-guide.md` adds a `/doctor` section; `CLAUDE.md` Module Boundaries gains a Doctor row. Explicitly excluded: no `--fix` auto-remediation, no network probes, no coupling into `/start-working` or other commands. Part of v0.8.0 observation-period Wave 2.

### Changed

- **Role-model upgrade — Claude roles to Opus 4.7, Developer to GPT-5.4** — Lead, Teammate, and Doc Engineer migrate from `claude-opus-4-6` to `claude-opus-4-7` (Lead at effort=max, Teammate/Doc Engineer at effort=xhigh). Developer's implementation tier moves from `gpt-5.3-codex` to `gpt-5.4` (effort=xhigh); QA/quick-fix tier remains `gpt-5.4-mini` (effort=high). Process Observer Audit stays on `claude-sonnet-4-6` per its checklist-verification scope; Process Observer Hooks stay shell-only. `~/.codex/config.toml` adds `service_tier = "fast"` so Fast Mode applies uniformly across MCP and `codex exec` invocations without per-call overrides. Acknowledged trade-off: Opus 4.7's literal-instruction-following profile differs from 4.6 — risk-mitigated via the 5-Wave observation tracker in `docs/plan.md`. `docs/configuration.md` Role-Model Mapping Table, Developer Tiered Model Strategy, Configuration Points, Switching Models, and the new Fast Mode Configuration subsection updated end-to-end.

- **Independent Reviewer migrated from Claude Code sub-agent to OpenAI Codex CLI in tmux pane** — IR's frontmatter changes from `model: opus` to `runtime: codex-cli` + `invocation: "codex exec" in a tmux pane, NOT Claude Code sub-agent`. Spawn shape moves from the Task tool's `subagent_type` invocation to the fixed one-liner `codex exec "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. Write your findings to docs/independent-review.md."` (Wave Boundary mode appends `This is a Wave Boundary Review.`). Cross-provider training-distribution independence (GPT-5.4 vs Lead's Claude) is now layered on top of the existing zero-context-inheritance property — two structural blind-review properties replace one. Spawn references updated across `commands/end-working.md`, `commands/init-project.md`, `commands/plan.md`, `docs/workflow.md`, `docs/collaboration-mode.md`, `docs/concepts.md`, `docs/roles.md`. `docs/repo-structure.md` adds a Runtime note flagging IR as the only Codex-CLI-runtime agent in `agents/`; the only other agent (`process-observer-audit.md`) remains a Claude Code sub-agent.

- **`docs/concepts.md` tmux teammate mode definition rewritten** — Teammate concept clarified as **context isolation, not concurrency workaround**: each Teammate runs its own tmux Claude Code session carrying full branch context (scoped codebase reading, Developer prompt assembly, output review), while Lead's main session stays pure governance. Codex MCP natively supports concurrent threadId-scoped sessions, so Teammates exist for the context-isolation property — not because parallelism requires them. Aligns with the IR migration's same context-isolation rationale.

- **`docs/design-decisions.md` model rows superseded by v0.8.0 entries** — Three rows updated: Independent Reviewer model + runtime (added cross-provider rationale + Codex CLI migration path), Developer two-tier model (gpt-5.3-codex → gpt-5.4 with Fast Mode note), and a new IR migration risk-mitigation row documenting the per-role partial-revert protocol. Old rows that named gpt-5.3-codex as Developer default are replaced rather than appended-to so the file reflects current state.

- **Process Observer audit canonical 18-row checklist enumeration (FR-24)** — `agents/process-observer-audit.md` preamble declares `Canonical checklist coverage: 18 rows across 6 categories (A-F)` with an explicit row-to-scope mapping table (A1-A3 branch conventions + ordering / B1-B2 code review triggers + Doc Engineer spawn verification / C1-C2 Doc Engineer execution + code-doc correspondence / D1-D4 PR workflow (merge, cleanup, body template, gh account alignment) / E1-E6 out-of-scope operations + plan.md accuracy + BLOCKING marker decision + verification-count + observation-period tracker / F1 Independent Reviewer execution at Wave boundary). Each of the 18 rows now carries an explicit `Status` state-set (PASS/FAIL, PASS/WARN, PASS/IN-PROGRESS/FAIL, or PASS/IN-PROGRESS/FAIL/N/A) so the agent self-verifies completeness without inferring rows from per-invocation prompt prose. Summary line adds a total count-check (`X + Y + Z + W == 18`) and routes a `Meta: row-count mismatch` FAIL-level meta-deviation through the Rule Corrections Suggested Framework-side block (not a new table row, to avoid double-counting). Scope bullets converge from 7 historic items to 6 letters (E category absorbs "Unauthorized operations" + "plan.md accuracy" under six concrete E1-E6 sub-rows). Replaces the previous 5-explicit-row + `| ... |` placeholder pattern that required per-invocation full checklist reassembly. Wave 2 PO report (13 rows) vs Wave 3 PO report (18 rows) cross-invocation inconsistency motivated the codification. Part of v0.8.0 observation-period Wave 4.

- **Doc Engineer audit mechanical re-execution of acceptance assertions (FR-26)** — `docs/roles.md` Doc Engineer protocol gains a rule: when auditing a plan.md Wave entry whose Acceptance list contains grep/bash/shell-style assertions (e.g., `grep -c "pattern" file — returns N`, `git log ... | wc -l — expected N`, `bash scripts/<x>.sh --self-test — exit 0`), DE must independently re-execute each such command and paste both the exit code and any matched lines into the audit report rather than trusting the Lead's prose claim "already verified PASS". Scope limited to safely idempotent, read-only commands (grep, wc, git log, `bash <script> --self-test`); state-mutating commands (git commit, git push, gh pr create) are excluded. Triggered by the Wave 2 real-world case where recorded grep pattern `^| /doctor |` read `1 — PASS` in plan.md but returned `0` on live re-execution because the table cell quoted the command name with backticks. `commands/end-working.md` Step 9 gains a cross-reference line pointing auditors to the new rule in `docs/roles.md`. Part of v0.8.0 observation-period Wave 3.

- **Process Observer audit observation-tracker-row consistency check (FR-27)** — `agents/process-observer-audit.md` gains a new E-series check verifying that when the current Wave falls within the v0.8.0 observation-period window (Waves 0-4) and this `/end-working` marks the Wave as completed, the tracker row for the Wave has been filled with data rather than left as the `(待填)` placeholder. Four states — PASS (row filled, commit landed), IN-PROGRESS (row not yet filled but commit hasn't landed either — the expected mid-flow state), FAIL (commit landed AND row still `(待填)` — workflow violation that bypasses observation-period data collection), N/A (Wave outside observation window, or no Wave completed this session). Resolution-timing, irreversibility, partial-revert, and N/A-vs-`(待填)` rules codified in prose above the `docs/plan.md` §v0.8.0 升级观察期 Tracker table: the `(待填)` → data transition must happen inside the Wave's `/end-working` commit; filled data rows must not revert to `(待填)`; partial-revert Waves keep the row and append `REVERT: <reason> — Wave X 重起算` to the 备注 column; positive non-applicability is recorded as `N/A — <short reason>` (distinct from the negative `(待填)` state). Part of v0.8.0 observation-period Wave 3.

- **Independent Reviewer Wave-boundary skip carve-out codified (FR-19)** — `commands/end-working.md` Step 3 gains a three-condition skip carve-out (no application-code files modified + no new product-behavior surface + Doc Engineer and Process Observer sub-agent audits both running in the same `/end-working` invocation). Codifies the ~6-Wave precedent of ad-hoc skip-rationale prose into an explicit rule with mandatory one-line rationale in the Wave entry. Default on doubt remains "run IR". Mirrored in `docs/workflow.md`, `docs/collaboration-mode.md`, `docs/roles.md`, and `docs/design-decisions.md`. Step 9 PR template's Independent Reviewer line gains a `carve-out skip — <short reason>` bucket alongside the existing PROCEED / not triggered options. Part of v0.8.0 observation-period Wave 1.

- **plan.md / session-log.md / CHANGELOG authoring + transition contract codified** — `commands/end-working.md` Step 4 gains a new contract section with three parts: (A) authoring rule defining plan.md as strictly "Where we are now" with a three-question placement test for content ownership across plan.md / session-log.md / CHANGELOG.md; (B) transition rule mandating a six-step migration protocol at every Wave/FR/maintenance completion (identify in-progress entry → migrate narrative → delete from plan.md → update "已完成 Wave 索引" table → sync CHANGELOG → verify via DE audit item 11); (C) enforcement via the new `scripts/plan-md-contract-check.sh` mechanical detector blocking commits on violation. `docs/roles.md` Doc Engineer protocol expands to 11 audit items with the new item 11 "plan.md / session-log.md / CHANGELOG separation check" (mechanical gate + semantic verification over the latest commit's plan.md diff). `agents/process-observer-audit.md` canonical checklist coverage increments from 18 to 19 rows with new E7 "plan.md contract shape respected for maintenance / Wave PRs" (scope mapping table + summary count-check formula `X+Y+Z+W+V == 19` synced). `docs/configuration.md` Document Responsibility Boundaries table extended with an Enforcement column linking each boundary to its enforcement mechanism. Pre-v0.8.0 governance-maintenance session type formally defined (non-Wave maintenance sessions: branch → parallel Teammate dispatch → DE audit → PR → merge, no IR / full PO audit / F8b tracker row / new plan.md Wave entry).

### Unchanged

- 6-role + 1-hook architecture (Lead / Teammate / Developer / Doc Engineer / Process Observer Hooks + Audit / Independent Reviewer)
- Solo + Codex vs Agent Team mode-selection logic (file ownership + workload thresholds in `docs/collaboration-mode.md` §Mode Selection)
- All Developer prompt templates (Architecture pre-review / Implementation / QA smoke testing) — only the model field changes; prompt structure preserved
- Mode Selection Checkpoint enforcement in `commands/start-working.md` and `commands/end-working.md`
- Doc Engineer's `language-check.sh` (item 9) + `policy-lint.sh` (item 10) audit items both unchanged
- Information Layering Policy (A/B/C-layer classification) and A-layer Peer Review trigger conditions

### Migration Notes

- **Breaking dependency — tmux is now required (was recommended):** The Independent Reviewer's runtime moved from a Claude Code sub-agent to `codex exec` invoked in a tmux pane, so tmux became a hard install dependency. `install.sh` exits with `Error: tmux is required since iSparto v0.8.0` if tmux is absent; `/migrate` performs the same pre-flight check before scanning. macOS users install with `brew install tmux` (3.x). Upgrade path for existing v0.7.x users: install tmux first, then run `~/.isparto/install.sh --upgrade`. This is the v0.8.0 line's only breaking-environment change; all in-repo file content remains backward compatible.
- **External pre-validation gates (run before adopting v0.8.0):** (1) confirm `mcp__codex-dev__codex` accepts `model: gpt-5.4` (ChatGPT Plus account); (2) verify `~/.codex/config.toml` contains `service_tier = "fast"` (or skip and accept the default tier — IR/Developer still work); (3) verify `codex exec "..."` in a tmux pane can read `agents/` and write `docs/`. If gate 3 fails, downgrade IR to v0.8.1 timing and stay on the v0.7.8 IR Claude sub-agent path for this Wave; per-role partial revert protocol is documented in `docs/design-decisions.md`.
- **Avoiding default model downgrades:** Opus 4.7 may downgrade to Sonnet under default `claude` invocations. To pin Opus 4.7 across all sessions, launch with `claude --effort max` and explicitly disable adaptive thinking when starting a Lead session. Each `/start-working` should verify Lead's model context.
- **Observation period:** First 5 Waves post-upgrade are observation period. Track per-Wave in `docs/plan.md` v0.8.0 升级观察期 Tracker — fields are DocEng over-strictness, Lead escalation anomalies, Teammate literal-instruction-following symptoms. ≥ 2 same-field anomalies trigger the partial-revert path (revert affected Claude roles only; preserve IR Codex CLI migration).

## [0.7.8] - 2026-04-17

### Added

- **`scripts/policy-lint.sh` v1 — Information Layering Policy mechanical guardian** — New Tier 1 script mirroring `scripts/language-check.sh` structure (bash wrapper + python3 heredoc + `--self-test` fixtures + exit 0/1/2 semantics). Single detector in v1 scans the most recent `docs/session-log.md` entry for the 5 ceremonial wrapper phrases enumerated as C-layer forbidden in `commands/end-working.md` (`Session complete` / `Ready for next session` / `Doc Engineer audit passed` / `Process Observer audit passed` / `Security scan passed`) — hard failure on hit. 8 self-test fixtures (5 positive + 3 negative). Bullet-stack and A-layer wording detectors intentionally excluded from v1 to preserve signal purity. Integrated as new Doc Engineer audit item 10 in `docs/roles.md` parallel to item 9's language-check invocation; `commands/end-working.md` re-audit trigger list updated accordingly (#209).
- **Canary schema drift check in `hooks/process-observer/scripts/pre-tool-check.sh`** — New python3 block inspects `tool_input` after `INPUT=$(cat)`; if the object shape deviates from current assumptions (not a plain dict, or the known fields `command`/`file_path`/`prompt` are not strings), writes a single-line stderr warning naming the tool + field + actual type. Fail-open (no block, no exit-code impact). Silent when python3 is absent or `tool_input` is missing. Canary scope is the current 3-field set; future tool-type additions will need their field names appended (#208).

### Changed

- **`commands/start-working.md` Step 3 read-pattern fix** — Lead no longer reads the entire `docs/session-log.md` into context. Retrieval now locates the last `^## .* Session` heading via `grep | tail -1`, then `sed -n '<N>,$p'` reads from that heading to end-of-file. Empty-grep case (file exists but contains no session heading yet — e.g., only the `# Session Log` top header) takes the same skip branch as file-missing, preventing `sed -n ',$p'` empty-parameter stalls. Cumulative-stats collection bullet (total sessions / total Codex reviews / historical issue counts) removed — Step 9 C-layer rules already forbid emitting those metrics in the briefing, so scanning the whole log to compute them was dead work. New explicit bullet forbids aggregate-metric collection to prevent accidental reintroduction. Per-session token waste that compounds over long project histories is now eliminated (#209).
- **BLOCKING marker rule narrowed from mechanical "any Tier 1 change" to semantic gate on `CLAUDE.md` only** — Two-step refinement landed across PR #206 (semantic gate) and PR #207 (scope narrowing). PR #206 replaced the mechanical rule "any Tier 1 file modification emits a BLOCKING marker" with a semantic gate: a master question ("would a Lead operating on pre-change cached content take a materially different action from a Lead on post-change content?") plus a 3-question decision aid (behavior change? new identifier? contract/interface change?) with default-on-doubt = emit BLOCKING and a mandatory skip-rationale prose line when the gate says skip. PR #207 then narrowed the gate trigger further from "any Tier 1 file" to "`CLAUDE.md` only" — the only file Claude Code injects into its session-start system prompt via the `# claudeMd` context block. Other Tier 1 files (`commands/*.md`, `agents/*.md`, `templates/*.md`, `CLAUDE-TEMPLATE.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `bootstrap.sh`, `install.sh`, `isparto.sh`) are read on-demand at Skill-tool / Agent-tool / `/init-project` / runtime-hook-dispatch / external-shell-execution time, so stale-cache risk is structurally zero for them. Literal marker sentinel (`🚨 BLOCKING: Next Wave requires NEW SESSION`) preserved so `commands/start-working.md` Step 0's detector stays stable (#206, #207).
- **`hooks/process-observer/scripts/pre-tool-check.sh` JSON parser switched from awk to python3** — `extract_json_field` function (previously awk-based, documented in `docs/design-decisions.md` row 56 as unable to handle `\uXXXX` Unicode escapes or nested objects) replaced with a python3-backed implementation. Preserves function signature and fail-open-on-decode-error semantics; lookup order searches `tool_input` first, falls back to top-level payload — preserves existing call sites and the bare-payload smoke-test fixture. 344 → 408 lines net (#208).
- **`install.sh` hardened with `read_version_file` POSIX helper + fatal/tolerant caller split** — New ~25-line function trims all whitespace via `tr -d '[:space:]'`, validates against `^[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.-]+)?$` (semver-ish with optional pre-release/build tail), returns trimmed string on stdout or exits 1 with clear stderr error. Three call sites replaced: local-repo INSTALL_VERSION read is fatal on malformed VERSION (developer path — bugs should surface loudly); installed-VERSION reads for upgrade-idempotency check and OLD_VERSION display are tolerant (`2>/dev/null || true`) to preserve the CLAUDE.md backward-compatibility rule (existing users with corrupted VERSION can still upgrade — treated as if VERSION is missing, full reinstall path — and still uninstall). POSIX-compliant (no bashisms, no jq, no python3 dependency at install-time). 512 → 542 lines net (#208).
- **CLAUDE.md + CLAUDE-TEMPLATE.md plan.md commit-count verification timing (Rule 2)** — The existing rule "compute the count mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` at the time the entry is written — not by estimation" was timing-ambiguous for Wave close-out entries written as part of the commit they document (standard `/end-working` cadence). The entry is authored a moment before the commit exists, so the command returns `0` when the committed target is `1`. Rule 2 updates the clause to explicitly acknowledge the pre-commit case: "For entries authored pre-commit (standard `/end-working` cadence, where the Wave entry ships inside the same commit it documents), write the projected count and re-verify via the same command immediately after the commit lands; if mismatch, amend before push." Process Observer audit classification can now cleanly distinguish IN-PROGRESS (pre-commit) from PASS (post-commit verified) instead of the prior fragile "PASS (projected)" state. Same clause added to `CLAUDE-TEMPLATE.md` for downstream projects (#208).
- **Documentation structure — Collaboration Mode extracted from CLAUDE.md to `docs/collaboration-mode.md`, A-layer Peer Review extracted from `agents/independent-reviewer.md` to `docs/design-principles/a-layer-peer-review.md`** — Wave A of v0.7.8's planning consolidation. `docs/collaboration-mode.md` now owns the full collaboration-mode definition (mode selection, plan mode, roles, lifecycle, implementation protocol, branch protocol, developer triggers, branching/merge rules); CLAUDE.md's Collaboration Mode section shrunk to a pointer plus the iSparto-specific exception (framework self-referential boundary). `docs/design-principles/a-layer-peer-review.md` (new Tier 2 file, 124 lines) now owns the A-layer Peer Review Mode 3 definition (invocation trigger, tool permissions including deep-IR gate, four judgment axes, verdict format, conflict resolution, scope); `agents/independent-reviewer.md` shrinks from 214 → 109 lines. CLAUDE.md Documentation Index gains pointers to the new files; CLAUDE.md Module Boundaries promoted to its own `## Module Boundaries` heading. CLAUDE-TEMPLATE.md intentionally unchanged per plan to avoid two-way sync overhead. `docs/roles.md` Team Lead system prompt and other cross-references migrated to plan-standard pointer format `**Rule**: TL;DR. See [path](path) §anchor for the full rule.` (#204).
- **Documentation structure — cross-file pointer standardization across `docs/concepts.md`, `docs/roles.md`, `docs/workflow.md`, `docs/user-guide.md`** — Wave B of v0.7.8's planning consolidation. All cross-file rule references consolidated to a single standard pointer format (`See [path](path) §anchor`) with TL;DR ≤ 30 characters and the anchor resolving to an actual `##`/`###` heading that can be mechanically verified with `grep "See \[.*\](.*\.md) §"`. Specific touch points: `docs/concepts.md` heading renamed from "The Most Critical Concept: Decoupling" to "Wave Parallelism" so the plan's `§Wave Parallelism` anchor resolves to an actual heading; Team Lead system prompt's "First assess decoupling..." bullet replaced with a standardized `**Wave Parallelism**: ... See [concepts.md](concepts.md) §Wave Parallelism` pointer; `docs/workflow.md §Developer (Codex) Integration` pre-existing blockquote pointer converted to plan-standard format; `docs/roles.md §Developer (Codex MCP Call)` model bullets consolidated from 4 to 3 with a standardized `**Model Assignment**` pointer; `docs/user-guide.md §User Preference Interface` three-bullet restatement replaced with a standardized pointer. Net line delta ≈ −1 across 5 files; value delivered is pointer-standardization discipline and anchor traceability, not raw line reduction (#205).
- **`docs/framework-feedback-0417.md` Rules 1–5 documented** — Five framework-side rule refinement candidates recorded across the Wave sequence of 2026-04-17: Rule 1 (BLOCKING marker over-coarse — addressed by Semantic Gate + Gate Narrowing same day), Rule 2 (plan.md commit-count timing ambiguity — addressed by Wave C + Rule 2 same day), Rule 3 (BLOCKING literal sentinel vs rationale write-together rule — deferred), Rule 4 (IR skip at Wave boundary lacks explicit exit criteria — deferred), Rule 5 (BLOCKING marker acknowledgement path undefined for mid-session CLAUDE.md updates via system-reminder injection — deferred). Rules 3–5 are tracked as next-framework-polish or v0.8 roadmap planning candidates; none is blocking current work (#208, #209).

## [0.7.7] - 2026-04-14

### Added

- **Process Observer on architecture diagrams — card, monitored zone, solder-joint connectors** — Both `assets/role-architecture.svg` and `assets/role-architecture-zh.svg` gain a first-class PROCESS OBSERVER card in the bottom-right slot (gold solid border, distinct from Independent Reviewer's zero-context dashed styling), with `Full-process oversight` / `全流程监察` as the primary body line. Prior to this release PO had no visual reference in the diagram even though the README bullets listed it as one of the six roles. A dashed gold perimeter frames the four Claude roles whose tool calls PO hooks intercept (Team Lead including the Doc Engineer sub-card, Independent Reviewer, Teammate, Developer), labeled `OBSERVED ZONE` / `监管范围`; the frame has a notch carved out at the bottom-right so the PO card sits visually outside the monitored area. Ten short gold solder-joint connectors (six on top, four on left) weld PO's top and left edges to the frame's notch edges — a circuit-board metaphor for PO's always-on oversight of the zone (#200).

### Changed

- **README realigned with the homepage four-line value prop** — `README.md` and `README.zh-CN.md` rewritten across 7 sections (Lead paragraph, Core idea, comparison table, Who this is for, Role Architecture bullets, Dogfood Log, Origin of the Name coda) to match the homepage proposition: `Open-source Agent Team framework for Claude Code` · `Built for solopreneurs` · `One command spins up the whole agent team — all working in perfect sync` · `Team Lead · Teammate · Independent Reviewer · Developer · Doc Engineer · Process Observer`. Prior restraint-narrative vocabulary (`restrained`, `one-person army`, `full AI development team`, `Claude Code Agent Team mode`, `team with clear roles`, `克制`, `停止倾倒`, `克制叙事`, `一人成军`) removed from active Tier 1/2/3 files; remaining occurrences are confined to Tier 4 frozen artifacts per convention. GitHub repo description and topics updated: description replaced with the new value prop; topics drop `agent-team`/`ai-development` and add `solopreneur` (#197).
- **Install section "Preview before installing" reframed to lead with "Dry run"** — Both READMEs update the preview-heading wording to `**Dry run (Preview) before installing:**` / `**安装前 Dry run(预览):**`, placing the technical term first and the user-facing word as parenthetical clarifier. Matches the convention for developer documentation where the concrete flag name (`--dry-run`) is the primary reference (#199).
- **`docs/product-spec.md` Competitive Differentiation aligned with new Agent Team vocabulary** — Line 63 rewritten to use the six-role vocabulary and the `one command spins up the whole agent team` phrasing, replacing the prior `team with clear role separation` language. Line 58's `Claude Code Agent Team mode` retained as a reference to Claude Code's own feature (#200).

### Fixed

- **Teammate role described as writing code prompts, not writing code directly** — `README.md` and `README.zh-CN.md` Core idea section second paragraph: `Teammate writes code` → `Teammate writes code prompts in parallel` / `Teammate 并行写代码 prompt`. Teammate follows the same prompt→Developer→review loop as Lead per CLAUDE.md — it does not write code directly. The initial value-prop rewrite (#197) inadvertently introduced the incorrect verb; this is the follow-up correction (#198).

## [0.7.6] - 2026-04-12

### Added

- **Independent Reviewer in role-architecture diagrams** — Both `assets/role-architecture.svg` and `assets/role-architecture-zh.svg` now include the Independent Reviewer as a first-class node at the Lead level (gold theme, dashed border encoding zero-context inheritance). Previous diagrams showed only 4 nodes (USER → Lead+Doc Engineer → Teammate + Developer); users encountering IR at runtime had no visual reference for where it fits. Connection lines, matrix rain coverage, and card spacing polished across 4 iterative rounds (#190, #191, #192, #193).

- **IR token cost documentation across framework docs** — New `Token Budget Awareness` subsection in `docs/configuration.md` with a 5-column per-invocation × cumulative cost table covering all roles. IR row rationale in the Role-Model Mapping Table extended to explain why Opus is required. New Opus cost tradeoff row in `docs/design-decisions.md`. IR Quick Reference entry in `docs/concepts.md`. Token budget awareness section in `docs/user-guide.md` with cross-references. IR trigger sequence mermaid timeline diagram in `docs/workflow.md`. Token annotation at first IR occurrence in workflow.md Phase 0 block (#190).

### Changed

- **Framework-feedback close-out (0409 series)** — Closed framework-feedback items 0409 R1/R2, 0409-b F1, 0409-c F1/F2, 0409-d F1/F2 covering rule gaps, design-principle refinements, and documentation consistency (#187, #188, #189).

## [0.7.5] - 2026-04-09

### Added

- **v0.7.5 README restraint-narrative Wave** — Both READMEs (`README.md`, `README.zh-CN.md`) rewritten from feature-list framing to restraint-as-core-differentiation framing under a ≤ 220-line soft budget (each landed at 205 lines). Internal jargon (`Solo + Codex`, `Agent Team`, `Process Observer`) removed from the user-facing surface; reader-perspective language replaces it. The Chinese README anchors the new pitch on the word 「克制」. Three new files carry content extracted from the README so it can stay focused: `docs/case-studies.md` (Tier 2 English, end-to-end dogfooding case collection seeded with the Wave 5 Session Log self-bootstrapping run), `docs/repo-structure.md` (Tier 2 English, the annotated repository tree previously embedded in the README, now authoritative for structural changes), and `docs/dogfood-log.md` (Tier 4 Chinese, subjective per-cycle session-experience log seeded with cycle #1 covering the v0.7.4 → v0.7.5 transition). README sections 8/9/10 point at these files instead of inlining the content. The four-tier language guardian (`scripts/language-check.sh`) gains `docs/dogfood-log.md` to its `TIER2_EXCLUDED_FILES` list as a Tier 4 historical artifact.

### Changed

- **Information Layering Policy — Principle 5 total-collapse clarification** — `docs/design-principles/information-layering-policy.md` Principle 5 gains a new closing paragraph making explicit that dynamic layer-classification has been **totally** collapsed: outside the three covered pause points (`/start-working` opening, `/end-working` closing, `/plan` proposal-presentation) there is no surface where Lead dynamically re-classifies an output's layer — Principle 1 has already allocated A-layer to 5 mechanical triggers, Principle 2 has already allocated B-layer to the three pause points, and the residual default is C-layer. Lead's runtime judgment survives only for word choice inside pre-pinned structure. Closes a latent reading gap caught during v0.7.4 post-merge review where a future reader (or Lead during a refactor) might invoke an implicit "dynamic classification" clause that does not exist. Non-structural clarification only — no command template, agent role, or workflow rule changes.
- **Information Layering Policy — Principle 2 static-by-default symmetry patch (v0.7.5)** — Principle 2 gains a new closing paragraph stating that the three B-layer pause points are themselves **static and pre-defined** at command-template load time (`commands/start-working.md`, `commands/end-working.md`, `commands/plan.md`), not chosen by Lead at runtime. This pairs symmetrically with Principle 5's total-collapse: A-layer entry is bound by Principle 1's 5 mechanical triggers, B-layer entry is bound by Principle 2's 3 pre-defined pause points, C-layer is the residual default — Lead has no fourth path to dynamically assign a layer at runtime. The overlap with Principle 5 is deliberate so the Policy stays jump-into-any-principle readable.
- **Process Observer audit checklist — branch guard precedence rule (v0.7.5)** — `agents/process-observer-audit.md` Full Compliance Report gains check A3: "branch guard precedes first modifying tool call". The rule marks WARN (not FAIL) when the session's first Edit/Write/Bash modifying call occurred on `main` before switching to a feat/fix/hotfix/docs/release branch. Closes the PR 178 process deviation at the audit layer — previously the post-session audit could only catch the violation indirectly through "main has commits", and could miss the precedence error entirely when the work was later moved off main without leaving commits behind.

## [0.7.4] - 2026-04-09

### Added

- **Information Layering Policy (v0.7.4)** — New design-principle layer governing how the Lead classifies user-facing output at runtime. Every output must be classified into one of three layers before emission: **A-layer** (decision interruption that blocks the user, restricted to 5 mechanically-identifiable trigger types in Policy Principle 1), **B-layer** (decision preparation at natural pause points — the opening briefing of `/start-working`, the closing briefing of `/end-working`, the proposal step of `/plan`), or **C-layer** (silent archive, logged to `docs/session-log.md` and commit history, never emitted to the user). The Policy is enforced structurally via fixed B-layer briefing shapes in the three command templates, not via Lead runtime self-discipline. New files: `docs/design-principles/information-layering-policy.md` (7 principles including "IR only reviews A-layer", "cross-session recovery surface is protected B-layer", "IR prevails on A-layer conflict delivered single-voice") and `docs/design-principles/conversation-style.md` (A-layer wording rule "I plan to X, because Y. If you disagree, I can switch to Z. Continue?" with 3 before-after samples for `/start-working`, `/plan`, `/end-working`). `docs/concepts.md` gains a new first-class concept section "Runtime Output Layering (A/B/C)" alongside Wave / Solo + Codex / Agent Team. `docs/design-decisions.md` gains a new row recording "IR prevails on A-layer conflict" as a workflow decision with date 2026-04-09.

### Changed

- **Command template output behavior restructured per Policy (v0.7.4)** — `commands/start-working.md` Step 9 rewritten from "Present all the above information with your suggested next step" to a fixed 3-sentence B-layer briefing shape: (1) state-variable sentence naming current Wave status and next task (protected cross-session recovery surface — Wave is preserved as state variable, not silenced as noise), (2) optional blocker sentence only when non-empty, (3) next-action sentence using the A-layer wording rule. C-layer items explicitly silenced: branch auto-create, hook verification green, gh auto-switch, health check green, Process Observer armed, Doc Engineer idle, retrospective narration, operational metrics. `commands/end-working.md` closing briefing similarly restructured to a 3-5 sentence fixed shape (what shipped + what Codex/audits caught + what's next) with "Session complete" / "Ready for next session" / passing-audit announcements explicitly banned. `commands/plan.md` Step 3 proposal output rewritten to forbid menu-delegation ("here are three options, which would you like?") — proposals must recommend one path and name one alternative using the A-layer wording rule. All three command templates gain a top-of-file `Reference: docs/design-principles/information-layering-policy.md` line.
- **Independent Reviewer role extended with A-layer Peer Review (Mode 3)** — `agents/independent-reviewer.md` adds a new mode alongside the existing Phase 0 alignment review and Wave Boundary Review. A-layer Peer Review is invoked only when the Lead classifies an output as A-layer per Policy Principle 1; B-layer and C-layer classifications are Lead-autonomous and do not reach IR. The review covers four judgment axes (classification, framing, correctness, single-voice integrity) and supports a deep-IR gate for security/architecture/irreversible-operation judgments that require running scripts or tests (read-only by default; script execution requires user authorization surfaced through the Lead as a separate A-layer interrupt). Conflict resolution: IR prevails; Lead re-emits the corrected A-layer output as Lead-voice. Single-voice delivery: IR does not speak directly to the user — all corrections flow through the Lead so the user experiences one voice throughout.
- **CLAUDE.md + CLAUDE-TEMPLATE.md sync for Information Layering Policy (v0.7.4)** — Documentation Index in both files gains pointers to the new Policy and conversation-style files. User Preference Interface section in both files gains a new sub-paragraph directing the Lead to apply the Policy to every user-facing output before emitting it. No migration of existing sections.

## [0.7.3] - 2026-04-08

### Fixed

- **`claude mcp list -s user` compatibility bug in install.sh + start-working.md hook migration guards** — `install.sh` section 6 (3 sites: DRY_RUN registered branch, DRY_RUN migrate branch, real-run migrate branch) and `commands/start-working.md` Step 7 (2 sites: rename guard, auto-add guard) were running `claude mcp list -s user 2>/dev/null | grep -q <name>`, which silently fails because Claude Code removed the `-s` scope flag from `mcp list` around v1.0.58 when the command was reworked to do live health probing. With stderr muted, the migration guards were fail-closed forever — the codex-reviewer → codex-dev MCP server migration appeared to skip on installs where the rename should have triggered, and the hook matcher auto-add branch in start-working Step 7 was silently short-circuited. Replaced all 5 sites with `claude mcp get <name> >/dev/null 2>&1` (clean 0/1 exit-code semantics, scope-agnostic — matches the actual intent since we only care whether the matcher will resolve). Added a 10-line maintenance comment block above install.sh section 6 naming `claude mcp get` as the replacement and instructing future maintainers to grep for `claude mcp get` if the lookup path itself ever breaks in a future Claude Code release. `mcp add -s user` and `mcp remove -s user` continue to accept the scope flag and are unchanged.

### Changed

- **`docs/roadmap.md` split out from `docs/plan.md`** — long-range v1.x/v2.x vision content moved out of `docs/plan.md` into a new `docs/roadmap.md`. `docs/plan.md` now focuses on the current v0.x phase (active Waves + deferred items) so Lead's per-session read stays tight; `docs/roadmap.md` holds the long-range commercialization and platform roadmap that is referenced but not touched session-to-session. `CLAUDE.md` Documentation Index updated with a pointer to the new file. Pure reorganization — no content loss.

## [0.7.2] - 2026-04-08

### Changed

- **Self-referential boundary clarified for Tier 1 root-level files** — `CLAUDE.md` self-referential boundary now explicitly covers both subdirectory Tier 1 files (`commands/`, `templates/`, `scripts/`, `hooks/`, `agents/`, `docs/`, `lib/`) and root-level Tier 1 files (`CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `bootstrap.sh`, `install.sh`, `isparto.sh`). Tier 2/3/4 documentation (other `docs/*.md`, `README*.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`) is also in scope for direct Lead edits under the same framework self-referential principle. Closes ambiguity that caused Lead to over-delegate root-level framework edits to Codex.
- **Doc Engineer hotfix exceptions formalized** — Solo + Agent Team workflow step 4 and `docs/workflow.md` Hotfix Workflow section now define two narrow substitute/skip paths: (1) **Emergency hotfix substitute** for `hotfix/` branches with ≤3 changed files limited to Tier 1 `*.sh` and/or `CHANGELOG.md` during an explicit emergency release window — Lead may substitute DE with `language-check.sh` (iSparto) or an inline lint/self-test (user projects), manual inline review of each changed file, and an explicit session-log entry naming the exception; (2) **Ad-hoc fix skip** for sessions that don't complete any Wave and have no code↔documentation sync risk. The standard audit remains required for any `hotfix/` that doesn't meet all three conditions.
- **plan.md update cadence and verification-count accuracy rules added** — `docs/plan.md` and user-project plan.md files may now be updated either per-task (in the same commit as the task work) or per-Wave (in a close-out commit that lists all task completions with commit hashes). Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates. Wave close-out entries that record a commit count must compute it mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` — not by estimation. Both rules propagate to user projects via `CLAUDE-TEMPLATE.md` and `templates/plan-template.md`.
- **plan.md reclassified as wholly Tier 4** — `docs/plan.md` is now fully exempt from the Tier 4 English-only rule, including forward-looking sections (Next-Steps roadmap, Tech Ecosystem Tracking table). New plan.md entries default to English but may mix in CJK where a user conversation would lose nuance from translation. Previously the Tier 4 description only named historical Wave entries explicitly, leaving forward-looking sections in a gray zone that conflicted with preserving user-conversation nuance.
- **F1 Independent Reviewer spawn-source dual-path + PR body template extended** — `agents/process-observer-audit.md` F1 row wording now explicitly accepts both Independent Reviewer spawn paths as equally valid: (a) Lead-initiated mid-session spawn (after task work completes, before `/end-working` is invoked), or (b) `/end-working` Step 3 auto-spawn at Wave boundary. Acceptance criterion for either path: fixed one-liner prompt used AND report appended to `docs/independent-review.md`. `commands/end-working.md` Step 9 PR body template now includes `## Mode Selection` (dogfoods the Mode Selection Checkpoint artifact) and `## Workflow audits` (distinguishes `sub-agent run ✅` from `Lead self-assessed ✅` for Doc Engineer and Process Observer). Makes workflow-compliance artifacts visible in PR metadata so later audits can verify B1/C3/F1 without replaying the session.

## [0.7.1] - 2026-04-08

### Fixed

- **macOS upgrade path broken in v0.7.0** — `bootstrap.sh` and `install.sh` version parser used `sed 's/.*"\(v\?\)\([0-9][^"]*\)".*/\2/'`, where `\?` is a GNU sed extension unsupported by macOS BSD sed. On macOS the pattern silently failed to match, returning the raw JSON line as the version string and tripping the semver validator with `Invalid version format: '  "tag_name": "v0.7.0",'`. Every `~/.isparto/install.sh --upgrade` invocation on macOS hit this. Replaced with BSD-compatible `sed -E 's/.*"v?([0-9][^"]*)".*/\1/'` in both files.

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
