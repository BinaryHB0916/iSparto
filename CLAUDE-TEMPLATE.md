# [Project Name]

本项目使用 iSparto 工作流框架（isparto.dev）管理 Agent Team 协作。框架文档见 ~/.isparto/docs/。

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
- Update docs/plan.md immediately after completing tasks (in the same commit, not deferred to /end-working)
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
- Developer (Codex MCP): Implements code per structured prompts from Lead/Teammate. Also handles QA smoke testing (different prompt, orchestrated by Lead). Model configuration: see docs/configuration.md.
- Doc Engineer (Lead sub-agent): The team's context source. After each Wave: (1) ensures code and docs stay in sync, (2) checks product terminology consistency, (3) audits product narrative integration.
- Process Observer (hooks + Lead sub-agent): Compliance oversight. Hooks intercept catastrophic operations in real time (irreversible / shared state / data loss); post-session audit reviews execution against behavioral guidelines, outputs deviation report + rule correction suggestions.

**Development Workflow (Solo + Codex):**
0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates two conditions, declares Solo (records reason)
1. Lead assembles implementation prompt → calls Developer to implement code + tests
2. Lead reviews Developer output; if issues, assembles fix prompt → calls Developer again
3. Lead assembles QA prompt → calls Developer for smoke testing (per trigger table)
4. Lead runs Doc Engineer audit (as sub-agent)
5. Lead runs Process Observer post-session audit (as sub-agent, can run in parallel with Doc Engineer)
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Development Workflow (Agent Team):**
0. **Mode Selection Checkpoint** — Lead groups by file ownership, evaluates two conditions, declares Agent Team + defines Teammate count
1. Lead breaks down tasks → defines file ownership + prompt scope
2. Teammate(s) each run prompt→Developer→review loop in parallel
3. Lead assembles QA prompt → calls Developer for smoke testing (incremental, only changed paths)
4. Lead spawns Doc Engineer for documentation audit (last step, ensures QA fixes are also audited)
5. Lead runs Process Observer post-session audit (as sub-agent, can run in parallel with Doc Engineer)
6. Lead pushes branch -> creates PR -> merges to main -> cleans up branch

/end-working is fully autonomous (commit + push + briefing). When all branch tasks are complete, Lead auto-creates PR and merges; when mid-Wave, only pushes without merging.

**Implementation Protocol（强制 — 适用于每一次代码变更）：**

Lead 和 Teammate 不得使用 Edit、Write、Bash 直接创建或修改代码文件。所有代码实现必须通过 `mcp__codex-reviewer__codex` MCP 工具调用 Developer (Codex)。这不是偏好，而是由 Process Observer hooks 强制执行的硬性约束。

执行步骤（每个实现任务必须遵循）：
1. 从 plan.md（或用户请求）读取任务范围
2. 读取相关上下文：product-spec.md、tech-spec.md、实际源代码文件
3. 按 docs/roles.md 的 Implementation prompt template 组装结构化 prompt — prompt 必须包含 `## ` 标题（hook 会验证）
4. 调用 `mcp__codex-reviewer__codex`
5. Review Developer 输出：正确性、bug、风格、文件范围
6. 有问题 → 组装修复 prompt → 再次调用 `mcp__codex-reviewer__codex` → review
7. 通过 review → 进入 QA（工作流步骤 3）

"代码文件" = 扩展名不在 workflow-rules.json allowed_extensions 中的文件。不确定时，用 Developer。

此协议同时适用于 Solo 模式和 Agent Team 模式。Solo 模式下 Lead 自己执行全部步骤；Agent Team 模式下每个 Teammate 在各自文件范围内执行同样步骤。

例外：见 Development Rules 中的自引用边界（iSparto 框架编辑自身 hooks/rules）。

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
