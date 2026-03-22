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
- Any code change must include corresponding documentation updates
- Product decision changes must be written into docs, not just discussed in conversation
- Ask me first about uncertain product questions; do not decide on your own
- Update docs/plan.md after completing tasks
- Do not develop directly on main branch; use feat/ branches for new features, fix/ branches for bug fixes, hotfix/ branches for urgent production fixes
- Core business logic must have unit tests
<!-- Add or remove project-specific rules as needed; keep the total under 10 -->

## Collaboration Mode: Agent Team

**Roles:**
- Team Lead (main session): Breaks down tasks, coordinates the full workflow, merges code. Does not write business code. Lead handles information relay between Codex and Developer; the user does not participate in intermediate coordination. Lead may make routine decisions independently (standard approvals, process advancement), but must escalate uncertain matters to the user -- better to over-report than under-report.
- Claude Developer (teammate): Writes code + unit tests. Works within file ownership scope. Reviews Codex fixes.
- Codex Reviewer (MCP): Code review + direct fixes + QA smoke testing. A hidden-master role -- does not participate in daily development; gates quality at key checkpoints and fixes issues on the spot. Always uses xhigh reasoning. QA incremental testing only covers changed paths. Called by Lead.
- Doc Engineer (Lead sub-agent): Documentation audit after Wave completion. Ensures code and docs stay in sync.

**Development Workflow:**
1. Lead breaks down tasks -> defines file ownership + interface contracts
2. Developer develops + unit tests
3. Lead calls Codex for code review + fixes
4. Lead forwards changes to Developer for review
5. Lead calls Codex for QA smoke testing (incremental, only changed paths)
6. Lead spawns Doc Engineer for documentation audit (last step, ensures QA fixes are also audited)
7. Lead merges code

**Codex Review Triggers:** High-risk code must trigger code review + QA; UI-only changes need QA only; minor fixes need neither.

**Branching Strategy:** main is locked; feat/xxx for development, fix/xxx for bug fixes, hotfix/xxx for urgent production fixes (branched from main, full workflow required).

**Module Boundaries:**
<!-- Fill in based on actual project structure -->
| Module | Directory | Description |
|--------|-----------|-------------|
| ... | ... | ... |

## Operational Guardrails
<!-- Define based on project needs -->
- Deploying to production requires approval
- Must confirm before git push
- Must confirm before deleting files
- Do not commit directly to main branch

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
- Content assets -> docs/content/ (if applicable)
