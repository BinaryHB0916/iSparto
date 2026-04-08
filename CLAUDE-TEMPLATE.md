# [Project Name]

This project uses the iSparto workflow framework (isparto.dev) to manage Agent Team collaboration. Framework documentation is available at https://github.com/BinaryHB0916/iSparto/tree/main/docs .

## Project Overview
<!-- One sentence: what it is, who it's for, current stage -->
[Description]

## Tech Stack
<!-- Fill in based on the actual project -->
- Language: [Swift / Kotlin / TypeScript / Python / Rust / Go ...]
- Framework: [SwiftUI / Jetpack Compose / React / Next.js / Electron / Tauri / Flask ...]
- Platform: [iOS / Android / macOS / Windows / Web / Cross-platform ...]
- Build: [Xcode / Gradle / Vite / Webpack / Cargo / CMake ...]
- Other: [...]

## Development Rules
- Communicate and generate documents in the user's language (English or Chinese only)
- Any code change must include corresponding documentation updates
- Product decision changes must be written into docs, not just discussed in conversation
- Ask me first about uncertain product questions; do not decide on your own
- **plan.md update cadence:** update `docs/plan.md` either per-task (in the same commit as the task work) OR per-Wave (in a close-out commit that lists all task completions with commit hashes — acceptable when the Wave runs as a single atomic work session on a dedicated branch). Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates. If a fix session does not correspond to any plan.md entry (e.g., a bug fix not tied to any Wave), no plan.md update is required.
- **plan.md verification-count accuracy:** when a Wave completion entry records a commit count, compute it mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` at the time the entry is written — not by estimation.
- Do not develop directly on main branch; use feat/ branches for new features, fix/ branches for bug fixes, hotfix/ branches for urgent production fixes
- Core business logic must have unit tests
- Sensitive data (API keys, tokens, passwords, personal information) must NOT be hardcoded in source code — use environment variables or config file references
- .gitignore must cover the security baseline (see ~/.claude/templates/gitignore-security-baseline.md)
<!-- Add or remove project-specific rules as needed; keep the total under 10 -->

## Collaboration Mode: Auto (Solo + Codex / Agent Team)

Lead automatically selects the mode — no user action needed.

Lead automatically selects the mode based on criteria below. Selection must be completed explicitly before execution (see Mode Selection Checkpoint).

**Mode Selection Checkpoint (mandatory):** After plan approval, before the first execution step, Lead must explicitly evaluate and declare which mode to use. Steps: (1) group by file ownership; (2) evaluate against the two conditions below; (3) if both met → declare Agent Team and spawn Teammates; if not → declare Solo and record the reason. This is a mandatory step, not an optional optimization — skipping it is a process deviation.

**Solo + Codex** (Lead completes the task alone) — the default mode.
**Agent Team** (Lead spawns teammates for parallel execution) — upgrade when BOTH conditions are met:
1. Decomposable: work can be split into independent parallel sub-tasks (no file overlap, no data dependency)
2. Sufficient volume: file count × workload per file justifies coordination overhead

**Plan Mode:** Lead autonomously decides whether to enter plan mode — no user instruction needed. Auto-enter when any condition is met:
- Changes span multiple modules (≥2 modules in Module Boundaries table)
- Changes involve core design (CLAUDE.md, workflow definitions, role definitions)
- Changes affect user-facing behavior (slash commands, install flow)
- Changes are hard to reverse (data format changes, breaking API changes)

No plan mode needed: single-module bug fix, pure doc updates, formatting/typo.

Applies to both **write** (code, docs, config) and **read** (code review, doc audit, research/debug) tasks:
- Write: 5 files with large logic changes → Agent Team; 5 files with 1-line edits → Solo
- Read: review spans multiple modules → Agent Team splits by module for parallel review; few files → Solo serial review

**Why Lead/Teammate do not write code directly:** Codex produces significantly higher-quality code through structured prompts than the Lead model (currently Opus) writing directly. The Lead model excels at context understanding, task decomposition, prompt assembly, and review — not bug-free implementation. Direct code from the Lead model has frequent small bugs that cost more review time than they save. Therefore all code implementation must go through Developer (Codex); Lead/Teammate only assemble prompts and review output.

**Roles:**
- Team Lead (main session): Coordinates the full workflow, merges code. Does NOT write code directly (see rationale above) — assembles structured prompts for the Developer (Codex), then reviews Developer output. In Solo + Codex mode, runs the prompt→Developer→review loop alone. In Agent Team mode, delegates scoped tasks to Teammates who each run the same loop in parallel. Lead may make routine decisions independently, but must escalate uncertain matters to the user. Parallelism applies to reading too — code review, documentation audit, and research tasks should be parallelized across agents when possible. After completing a task, Lead proactively suggests the next step from plan.md.
- Teammate (tmux, Agent Team only): Parallel execution unit. Follows the same prompt→Developer→review loop as Lead, scoped to assigned file ownership. Does not write code directly (see rationale above). Each Teammate independently calls Developer = true parallel Codex invocations.
- Developer (Codex MCP): Implements code per structured prompts from Lead/Teammate. Also handles QA smoke testing (different prompt + different model, selected by Lead based on Tier). Two-tier models: implementation uses gpt-5.3-codex (xhigh), QA/quick fixes use gpt-5.4-mini (high). See docs/configuration.md.
- Doc Engineer (Lead sub-agent): The team's context source. After each Wave: (1) ensures code and docs stay in sync, (2) checks product terminology consistency, (3) audits product narrative integration.
- Process Observer (hooks + Sonnet sub-agent): Compliance oversight. **Core layer:** Hooks intercept catastrophic operations and branch violations in real time (cannot be bypassed, no model dependency). **Advisory layer:** Sonnet 4.6 post-session audit reviews session compliance (reduces token consumption; critical checks are already covered by Hooks).
- Independent Reviewer (Teammate — tmux): Product-technical alignment reviewer. Spawned as a Teammate (zero inherited context), independently reads product-spec then tech-spec to verify the technical approach actually implements what the product requires. Lead spawns with a fixed one-liner — no additional context or framing allowed. Report written directly to docs/independent-review.md, not filtered through Lead. Mandatory at Phase 0; triggered at Wave boundaries (when Wave completed).

**Development Workflow (Solo + Codex):**
0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates two conditions, declares Solo (records reason)
1. Lead assembles implementation prompt → calls Developer to implement code + tests
2. Lead reviews Developer output; if issues, assembles fix prompt → calls Developer again
3. Lead assembles QA prompt → calls Developer for smoke testing (per trigger table) — Developer MUST build the project first, then verify each acceptance step at its tagged level: [code]/[build]/[runtime]
3.5 (Phase 0 only, or Wave completed) Lead spawns Independent Reviewer (Teammate, fixed prompt: "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute."), waits for report. CRITICAL finding → stop development, resolve alignment first; after CRITICAL fix, must re-trigger Independent Reviewer to verify
4. Lead runs Doc Engineer audit (as sub-agent) — must complete before step 6 push/merge, cannot be deferred to /end-working. **Ad-hoc fix exception:** if the session does not complete any Wave AND the changes have no code↔documentation sync risk (e.g., a bug fix that does not correspond to any plan.md entry), Doc Engineer may be skipped; record the skip in the session briefing. **Emergency hotfix exception (hotfix/ branches only):** when a hotfix/ branch contains ≤3 changed files limited to Tier 1 shell scripts (`*.sh`) and/or `CHANGELOG.md`, AND the session is an explicit emergency release window (e.g., a broken release actively blocking users), Lead may substitute Doc Engineer with (a) an inline lint/self-test run if the project provides one, (b) manual inline review of each changed file, (c) an explicit session-log entry naming the exception. The standard audit is still required for any hotfix/ that does not meet all three conditions.
5. Lead runs Process Observer post-session audit (as sub-agent, can run in parallel with Doc Engineer)
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Development Workflow (Agent Team):**
0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates two conditions, declares Agent Team + defines Teammate count
1. Lead breaks down tasks → defines file ownership + prompt scope
2. Teammate(s) each run prompt→Developer→review loop in parallel
3. Lead assembles QA prompt → calls Developer for smoke testing (incremental, only changed paths) — Developer MUST build the project first, then verify each acceptance step at its tagged level: [code]/[build]/[runtime]
3.5 (Phase 0 only, or Wave completed) Lead spawns Independent Reviewer (Teammate, fixed prompt), waits for report. CRITICAL finding → stop development, resolve alignment first; after CRITICAL fix, must re-trigger
4. Lead spawns Doc Engineer for documentation audit (last step, ensures QA fixes are also audited) — must complete before step 6 push/merge, cannot be deferred to /end-working. **Ad-hoc fix exception:** if the session does not complete any Wave AND the changes have no code↔documentation sync risk (e.g., a bug fix that does not correspond to any plan.md entry), Doc Engineer may be skipped; record the skip in the session briefing. **Emergency hotfix exception (hotfix/ branches only):** when a hotfix/ branch contains ≤3 changed files limited to Tier 1 shell scripts (`*.sh`) and/or `CHANGELOG.md`, AND the session is an explicit emergency release window (e.g., a broken release actively blocking users), Lead may substitute Doc Engineer with (a) an inline lint/self-test run if the project provides one, (b) manual inline review of each changed file, (c) an explicit session-log entry naming the exception. The standard audit is still required for any hotfix/ that does not meet all three conditions.
5. Lead runs Process Observer post-session audit (as sub-agent, can run in parallel with Doc Engineer)
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Implementation Protocol (mandatory — applies to every code change):**

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

Exception: see the self-referential boundary in Development Rules (iSparto framework editing its own framework files).

**Branch Protocol (mandatory — applies to every session):**

Never make any changes on the main branch. main is only for receiving PR merges.

First action of every session (before reading docs or code):
1. `git branch --show-current` to check the current branch
2. If on main → immediately `git checkout -b <type>/<name>` to create and switch
3. Branch types: feat/ for new features, fix/ for bug fixes, hotfix/ for urgent fixes, docs/ for pure documentation, release/ for releases
4. Only start work after confirming you are on the correct branch

This protocol is enforced by Process Observer hooks — commits, merges, and pushes on main will be blocked.

**Developer Triggers:** Default is to trigger implementation + QA. Partial skip: pure visual / config tweaks (QA only), behavioral templates commands/*.md and templates/*.md (Developer review only, skip QA), pure documentation / formatting (skip both). Each Wave must include at least one batch review. QA tests against the acceptance script defined in plan.md. See docs/workflow.md for the full trigger table.

**Branching & Merge:** main is locked; feat/xxx for development, fix/xxx for bug fixes, hotfix/xxx for urgent fixes. After full workflow, Lead auto-creates PR and merges — no manual user review needed.

**Module Boundaries:**
<!-- Fill in based on actual project structure -->
| Module | Directory | Description |
|--------|-----------|-------------|
| ... | ... | ... |

## Operational Guardrails
<!-- Define based on project needs -->
- Deploying to production requires approval
- Must confirm before deleting files
- Do not commit directly to main branch
- Use /restore to roll back if /init-project or /migrate produces unexpected results
- Dangerous operations are automatically intercepted by Process Observer hooks; see hooks/process-observer/rules/dangerous-operations.json for the full list
- Pre-commit security scan runs automatically before every commit; secrets found will block the commit

## User Preference Interface

The agent team treats user memory as **read-only input** to adapt communication style; CLAUDE.md is the sole authority for behavior.

**Territory principle:** Memory governs "who you work with" (user preferences). CLAUDE.md governs "how to work" (workflow rules). Ownership is determined by topic domain, not by whether content conflicts.

**Three-level response model:**

| Level | Preference Type | Examples | Agent Team Response |
|-------|----------------|----------|-------------------|
| Level 1: Unconditional respect | Communication language, input method, output style, naming preferences | Voice input correction, no summaries, use Chinese | Adapt directly |
| Level 2: Conditional respect | Interaction pace, autonomy level, focus areas | Discuss before executing, skip routine confirmations, prioritize performance | Adapt within workflow boundaries; urgent interceptions don't wait |
| Level 3: Record only | Skip process steps, change order, lower safety | Skip Codex review, push before review, push to main directly | Do not execute; inform user: "Workflow requires [Y] because [reason]" |

**Conflict protocol:** When memory contradicts CLAUDE.md — execute CLAUDE.md, explain why to the user, do not modify user's memory. If the user wants to change a rule, guide them to modify CLAUDE.md.

**Agent team memory write rules:**
- Allowed: project context (project type), external references (reference type), user profile (user type)
- Forbidden: workflow rules, process changes, anything that duplicates existing CLAUDE.md content
- Pre-write check: does this topic belong to CLAUDE.md's territory? If yes, do not write

## Common Commands
<!-- Fill in based on project tech stack -->
[Build command]
[Run command]
[Test command]

## Documentation Index
<!-- Use text like "see docs/xxx.md", not @docs/xxx.md -->
<!-- The latter auto-embeds the entire file into context every time, wasting tokens -->
<!-- The former lets Claude Code read it on demand, loading only when needed -->
- Product spec -> docs/product-spec.md
- Tech spec -> docs/tech-spec.md (if applicable)
  <!-- tech-spec.md "Decisions & Lessons Learned" section serves as Module Memory — review at Wave start -->
- Design spec -> docs/design-spec.md (if applicable)
- Development plan -> docs/plan.md
- Session log -> docs/session-log.md (auto-generated by /end-working)
- Content assets -> docs/content/ (if applicable)
