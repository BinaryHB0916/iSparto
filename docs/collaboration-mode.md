# Collaboration Mode

## Overview

This document defines how the Agent Team — Team Lead, Teammate, Developer, Doc Engineer, Process Observer, and Independent Reviewer — collaborates on development work. Two modes are supported: **Solo + Codex** (default, Lead works alone) and **Agent Team** (parallel Teammates). Lead selects the mode based on task characteristics; no user intervention needed. The selection must be completed explicitly before execution (see Mode Selection below).

Scope: Lead automatically picks the mode, defines the lifecycle steps, follows the Implementation Protocol for all code changes, and enforces the Branch Protocol before any mutation. This definition is authoritative for iSparto's own framework development; user projects inherit the same structure via `CLAUDE-TEMPLATE.md`.

## Mode Selection

**Mode Selection Checkpoint (mandatory):** After plan approval, before the first execution step, Lead must explicitly evaluate and declare which mode to use. Steps: (1) group by file ownership; (2) evaluate against the two conditions below; (3) if both met → declare Agent Team and spawn Teammates; if not → declare Solo and record the reason. This is a mandatory step, not an optional optimization — skipping it counts as a process deviation.

**Solo + Codex** (Lead completes the task alone) — the default mode.
**Agent Team** (Lead spawns teammates for parallel execution) — upgrade when BOTH conditions are met:
1. Decomposable: work can be split into independent parallel sub-tasks (no file overlap, no data dependency)
2. Sufficient volume: file count × workload per file is enough to offset the parallel coordination overhead

Applies to both **write** (code, docs, config) and **read** (code review, documentation audit, research/debug) tasks:
- Write: 5 files with large logic changes each → Agent Team; 5 files with 1-line edits each → Solo
- Read: review spans multiple modules and files → Agent Team splits by module for parallel review; few files → Solo serial review

**Why Lead/Teammate do not write code directly:** Codex produces significantly higher-quality code through structured prompts than the Lead model (currently Opus) writing directly. The Lead model's strengths lie in context understanding, task decomposition, prompt assembly, and review — not bug-free implementation. Direct code from the Lead model has frequent small bugs, and the review cost ends up higher. Therefore all code implementation must go through Developer (Codex); Lead/Teammate only assemble prompts and review output.

## Plan Mode

Lead autonomously decides whether to enter plan mode — no user instruction needed. Auto-enter when any condition is met:
- Changes span multiple modules (≥2 modules in the Module Boundaries table)
- Changes involve core design (CLAUDE.md, workflow definitions, role definitions)
- Changes affect user-facing behavior (slash commands, install flow)
- Changes are hard to reverse (data format changes, breaking API changes)

No plan mode needed: single-module bug fix, pure documentation updates, formatting/typo.

## Roles

- **Team Lead** (main session): Coordinates the full workflow and merges code. Does NOT write code directly (see architectural rationale in Mode Selection) — assembles structured prompts to call Developer (Codex) for implementation, then reviews Developer output. In Solo mode, runs the prompt→Developer→review loop alone; in Team mode, delegates to Teammates who run the same loop in parallel. May make routine decisions independently, but must escalate uncertain matters to the user. Parallelism is not limited to writing code — code review, documentation audit, and research tasks should be parallelized whenever possible. After completing a task, proactively suggests the next step against plan.md.
- **Teammate** (tmux, Agent Team mode only): Parallel execution unit. Within its assigned file ownership, follows the same prompt→Developer→review loop as Lead. Does not write code directly (see architectural rationale in Mode Selection). Each Teammate independently calls Developer = true parallel Codex invocations.
- **Developer** (Codex MCP): Implements code per structured prompts from Lead/Teammate. Also handles QA smoke testing (different prompt + different model, selected by Lead based on Tier). Two-tier models: implementation uses gpt-5.4 (xhigh), QA/quick fixes use gpt-5.4-mini (high). See [configuration.md](configuration.md) §Agent Model Configuration.
- **Doc Engineer** (Lead sub-agent): The team's context source. After each Wave: (1) ensures code and documentation stay in sync, (2) checks product terminology consistency, (3) audits product narrative integration.
- **Process Observer** (hooks + Sonnet sub-agent): Compliance oversight. **Core layer:** Hooks intercept catastrophic operations and branch violations in real time (cannot be bypassed, no model dependency). **Advisory layer:** Sonnet 4.6 post-session audit reviews session compliance (reduces token consumption; critical checks are already covered by Hooks).
- **Independent Reviewer** (Codex CLI in tmux pane): Product-technical alignment review. Spawned via `codex exec` with GPT-5.4 in a tmux pane — cross-provider isolation (OpenAI vs Anthropic) layered on top of zero inherited context. Independently reads product-spec and tech-spec to verify whether the technical approach is actually implementing the product requirements. Lead spawns with a fixed one-liner — no additional description or framing allowed. Report is written directly to docs/independent-review.md, not filtered through Lead. Mandatory at Phase 0; triggered at Wave completion. A third review mode (A-layer Peer Review at runtime) is defined in [a-layer-peer-review.md](design-principles/a-layer-peer-review.md).

## Lifecycle

### Solo + Codex

0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates the two conditions, declares Solo (records reason)
1. Lead assembles implementation prompt → calls Developer to implement code + tests
2. Lead reviews Developer output; if issues, assembles a fix prompt and calls Developer again
3. Lead assembles QA prompt → calls Developer for smoke testing (per trigger table) — Developer MUST build the project first, then verify each acceptance step at its tagged level: [code]/[build]/[runtime]. **Carve-out (trivial CLI acceptance):** When the entire acceptance script in plan.md is ≤5 deterministic bash commands whose verdict is determined solely by exit code (e.g., `bash scripts/language-check.sh --self-test`), Lead MAY execute the commands directly and record each command + exit code as acceptance evidence in plan.md, instead of wrapping them in a Developer QA prompt. Requires: no build step, no runtime app verification, no output-parsing. Does NOT apply to multi-step scripts, scripts requiring log interpretation, or anything tagged [build]/[runtime].
3.5 (Phase 0 only, or Wave completed) Lead spawns Independent Reviewer in a tmux pane via `codex exec` (fixed one-liner: `codex exec "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. Write your findings to docs/independent-review.md."`), waits for report. CRITICAL finding → stop development, resolve alignment first; after CRITICAL fix, must re-trigger Independent Reviewer to verify. **Wave-boundary skip carve-out:** at Wave boundary only (not Phase 0), IR may be skipped under the three-condition carve-out in `commands/end-working.md` Step 3 — no application-code files modified, no new product-behavior surface, Doc Engineer + Process Observer sub-agent audits both running in this `/end-working` invocation; skip requires a one-line rationale in the Wave entry. Default on doubt: run IR.
4. Lead runs Doc Engineer audit (as sub-agent). Doc Engineer audit must cover the final branch diff before PR creation/merge. Lead should run it in-session once code and docs are stable; if it has not already run for the final branch changes, /end-working Step 9 is the mandatory pre-merge fallback gate. It may not be deferred past PR creation/merge. **Ad-hoc fix exception:** if the session does not complete any Wave AND the changes have no code↔documentation sync risk (e.g., a bug fix that does not correspond to any plan.md entry), Doc Engineer may be skipped; record the skip in the session briefing. **Emergency hotfix exception (hotfix/ branches only):** when a hotfix/ branch contains ≤3 changed files limited to Tier 1 shell scripts (`*.sh`) and/or `CHANGELOG.md`, AND the session is an explicit emergency release window (e.g., a broken release actively blocking users), Lead may substitute Doc Engineer with (a) `bash scripts/language-check.sh` clean run, (b) manual inline review of each changed file, (c) an explicit session-log entry naming the exception. The standard audit is still required for any hotfix/ that does not meet all three conditions. **Automated release exception (release/ branches only):** when a `release/vX.Y.Z` branch is created by `scripts/release.sh` and contains exactly two changed files (`CHANGELOG.md` date-stamp transition from `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, and `VERSION` semver bump), Doc Engineer is skipped because the commit is mechanically generated. The preceding PR (the Wave or fix PR being released) is responsible for its own Doc Engineer audit; the release commit rides on that audit.
5. Process Observer post-session audit (as sub-agent) runs at /end-working Step 5 before security scan/commit; Doc Engineer fallback, if needed, runs at Step 9 before PR creation/merge.
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch. **Pre-PR alignment guard:** immediately before `gh pr create`, run `gh api /user --jq .login` and compare against `REPO_OWNER` (from `git remote get-url origin`); if mismatched, run `gh auth switch --user "$REPO_OWNER"` first. This protects against mid-session account drift between `/start-working` Step 6 and the PR create call — the earlier snapshot is not a guarantee, only a starting state. **Remote cleanup note:** remote branch deletion should ride on `gh pr merge --delete-branch` (automatic) or happen while still checked out on the feature branch — `git push origin --delete <branch>` from `main` is intercepted by the Process Observer `main-operation` hook.

/end-working runs fully autonomously (commit + push + briefing output); no user confirmation needed. When all branch tasks are complete, creates PR and merges via the gh CLI; if gh is unavailable, pushes the branch and prompts the user to merge manually. When not complete, only pushes without merging.

### Agent Team

0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates the two conditions, declares Agent Team + defines Teammate count
1. Lead breaks down tasks → defines file ownership + prompt scope
2. Teammate(s) each run the prompt→Developer→review loop
3. Lead assembles QA prompt → calls Developer for smoke testing (incremental, only changed paths) — Developer MUST build the project first, then verify each acceptance step at its tagged level: [code]/[build]/[runtime]. **Carve-out (trivial CLI acceptance):** When the entire acceptance script in plan.md is ≤5 deterministic bash commands whose verdict is determined solely by exit code (e.g., `bash scripts/language-check.sh --self-test`), Lead MAY execute the commands directly and record each command + exit code as acceptance evidence in plan.md, instead of wrapping them in a Developer QA prompt. Requires: no build step, no runtime app verification, no output-parsing. Does NOT apply to multi-step scripts, scripts requiring log interpretation, or anything tagged [build]/[runtime].
3.5 (Phase 0 only, or Wave completed) Lead spawns Independent Reviewer in a tmux pane via `codex exec` (fixed one-liner), waits for report. CRITICAL finding → stop development, resolve alignment first; after CRITICAL fix, must re-trigger. **Wave-boundary skip carve-out:** at Wave boundary only (not Phase 0), IR may be skipped under the three-condition carve-out in `commands/end-working.md` Step 3 — no application-code files modified, no new product-behavior surface, Doc Engineer + Process Observer sub-agent audits both running in this `/end-working` invocation; skip requires a one-line rationale in the Wave entry. Default on doubt: run IR.
4. Lead dispatches Doc Engineer for documentation audit (as sub-agent). Doc Engineer audit must cover the final branch diff before PR creation/merge. Lead should run it in-session once code and docs are stable; if it has not already run for the final branch changes, /end-working Step 9 is the mandatory pre-merge fallback gate. It may not be deferred past PR creation/merge. **Ad-hoc fix exception:** if the session does not complete any Wave AND the changes have no code↔documentation sync risk (e.g., a bug fix that does not correspond to any plan.md entry), Doc Engineer may be skipped; record the skip in the session briefing. **Emergency hotfix exception (hotfix/ branches only):** when a hotfix/ branch contains ≤3 changed files limited to Tier 1 shell scripts (`*.sh`) and/or `CHANGELOG.md`, AND the session is an explicit emergency release window (e.g., a broken release actively blocking users), Lead may substitute Doc Engineer with (a) `bash scripts/language-check.sh` clean run, (b) manual inline review of each changed file, (c) an explicit session-log entry naming the exception. The standard audit is still required for any hotfix/ that does not meet all three conditions. **Automated release exception (release/ branches only):** when a `release/vX.Y.Z` branch is created by `scripts/release.sh` and contains exactly two changed files (`CHANGELOG.md` date-stamp transition from `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, and `VERSION` semver bump), Doc Engineer is skipped because the commit is mechanically generated. The preceding PR (the Wave or fix PR being released) is responsible for its own Doc Engineer audit; the release commit rides on that audit.
5. Process Observer post-session audit (as sub-agent) runs at /end-working Step 5 before security scan/commit; Doc Engineer fallback, if needed, runs at Step 9 before PR creation/merge.
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch. **Pre-PR alignment guard:** immediately before `gh pr create`, run `gh api /user --jq .login` and compare against `REPO_OWNER` (from `git remote get-url origin`); if mismatched, run `gh auth switch --user "$REPO_OWNER"` first. This protects against mid-session account drift between `/start-working` Step 6 and the PR create call — the earlier snapshot is not a guarantee, only a starting state. **Remote cleanup note:** remote branch deletion should ride on `gh pr merge --delete-branch` (automatic) or happen while still checked out on the feature branch — `git push origin --delete <branch>` from `main` is intercepted by the Process Observer `main-operation` hook.

/end-working runs fully autonomously (commit + push + briefing output); no user confirmation needed. When all branch tasks are complete, auto-creates PR and merges; when not complete, only pushes without merging.

## Implementation Protocol

This protocol is mandatory and applies to every code change.

Lead and Teammate must NOT use Edit, Write, or Bash to directly create or modify code files. All code implementation must go through Developer (Codex) via the `mcp__codex-dev__codex` MCP tool. This is not a preference — it is a hard constraint enforced by Process Observer hooks.

Execution steps (every implementation task must follow):
1. Read the task scope from plan.md (or the user's request)
2. Read relevant context: product-spec.md, tech-spec.md, actual source code files
3. Assemble a structured prompt per the Implementation prompt template in docs/roles.md — the prompt must contain a `## ` heading (the hook validates this)
4. Call `mcp__codex-dev__codex`
5. Review Developer output: correctness, bugs, style, file scope
6. If issues → assemble a fix prompt → call `mcp__codex-dev__codex` again → review
7. Once review passes → proceed to QA (workflow step 3)

"Code file" = any file whose extension is not in workflow-rules.json allowed_extensions. When uncertain, use Developer.

This protocol applies to both Solo mode and Agent Team mode. In Solo mode, Lead executes all the steps itself; in Agent Team mode, each Teammate executes the same steps within its own file scope.

**Exception:** when the framework is editing its own framework files under the self-referential boundary, Lead edits directly. The boundary is defined in CLAUDE.md Development Rules (iSparto-specific) or in the equivalent project-level CLAUDE.md for user projects that inherit this structure.

## Branch Protocol

This protocol is mandatory and applies to every session.

Never make any changes on the main branch. main is only for receiving PR merges. **This includes Edit/Write tool invocations, not just commits, merges, and pushes.** The branch guard must complete before the first Edit/Write tool call, not just before the first commit. If an Edit/Write tool call on main is detected before branch creation, the correct recovery is `git checkout -b <type>/<name>` before committing — the uncommitted change carries over with the checkout, no manual stash needed.

First action of every session (before reading docs or code):
1. `git branch --show-current` to check the current branch
2. If on main → immediately `git checkout -b <type>/<name>` to create and switch
3. Branch types: feat/ for new features, fix/ for bug fixes, hotfix/ for urgent fixes, docs/ for pure documentation, release/ for releases
4. Only start work after confirming you are on the correct branch

This protocol is enforced by Process Observer hooks — commits, merges, and pushes on main will be intercepted.

## Developer Triggers

Default is to trigger implementation + QA. Partial skips: pure visual/config tweaks (QA only), behavioral templates commands/*.md and templates/*.md (Developer review only, skip QA), pure documentation/formatting (both can be skipped). Each Wave must include at least one batch review. QA runs against the acceptance script defined in plan.md. See the trigger condition table in docs/workflow.md for details.

## Branching and Merge

main is locked; feat/xxx for new features, fix/xxx for bug fixes, hotfix/xxx for urgent fixes, docs/xxx for pure documentation commits, release/vX.Y.Z for releases. After all reviews complete, Lead automatically creates a PR and merges — no manual user review needed. `/release` triggers the release flow: auto-create `release/vX.Y.Z` branch → bump VERSION → update CHANGELOG → PR → merge → GitHub Release (including tag and asset files). After a hotfix is merged, if an immediate release is needed, Lead must prompt the user to run `/release` — Lead must not execute release steps on its own.
