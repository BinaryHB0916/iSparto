# [Project Name]

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
- Update docs/plan.md after completing tasks
- Do not develop directly on main branch; use feat/ branches for new features, fix/ branches for bug fixes, hotfix/ branches for urgent production fixes
- Core business logic must have unit tests
<!-- Add or remove project-specific rules as needed; keep the total under 10 -->

## Collaboration Mode: Auto (Solo + Codex / Agent Team)

Lead automatically selects the mode — no user action needed.

**Solo + Codex** (Lead completes the task alone) — the default mode.
**Agent Team** (Lead spawns teammates for parallel execution) — upgrade when BOTH conditions are met:
1. Decomposable: work can be split into independent parallel sub-tasks (no file overlap, no data dependency)
2. Sufficient volume: file count × workload per file justifies coordination overhead

Applies to both **write** (code, docs, config) and **read** (code review, doc audit, research/debug) tasks:
- Write: 5 files with large logic changes → Agent Team; 5 files with 1-line edits → Solo
- Read: review spans multiple modules → Agent Team splits by module for parallel review; few files → Solo serial review

**Roles:**
- Team Lead (main session): Coordinates the full workflow, merges code. In Solo + Codex mode, writes code directly. In Agent Team mode, delegates to Developer teammates. Lead handles information relay between Codex and Developer; the user does not participate in intermediate coordination. Lead may make routine decisions independently, but must escalate uncertain matters to the user. Parallelism applies to reading too — code review, documentation audit, and research tasks should be parallelized across agents when possible, not just code writing. After completing a task, Lead proactively suggests the next step from plan.md.
- Claude Developer (teammate, Agent Team only): Writes code + unit tests. Works within file ownership scope. Reviews Codex fixes.
- Codex Reviewer (MCP): Code review + direct fixes + QA smoke testing. Called by Lead per trigger table. Always uses xhigh reasoning.
- Doc Engineer (Lead sub-agent): The team's context source. After each Wave: (1) ensures code and docs stay in sync, (2) checks product terminology consistency, (3) audits product narrative integration.

**Development Workflow (Solo + Codex):**
1. Lead writes code + tests
2. Lead calls Codex for code review + fixes (per trigger table)
3. Lead calls Codex for QA smoke testing (per trigger table)
4. Lead runs Doc Engineer audit (as sub-agent)
5. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Development Workflow (Agent Team):**
1. Lead breaks down tasks -> defines file ownership + interface contracts
2. Developer develops + unit tests
3. Lead calls Codex for code review + fixes
4. Lead forwards changes to Developer for review
5. Lead calls Codex for QA smoke testing (incremental, only changed paths)
6. Lead spawns Doc Engineer for documentation audit (last step, ensures QA fixes are also audited)
7. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Codex Review Triggers:** High-risk code must trigger code review + QA; UI-only changes need QA only; minor fixes need neither.

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
- Design spec -> docs/design-spec.md (if applicable)
- Development plan -> docs/plan.md
- Session log -> docs/session-log.md (auto-generated by /end-working)
- Content assets -> docs/content/ (if applicable)
