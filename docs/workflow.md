# Complete Development Workflow

## Phase 0: Product Initialization

```
User describes product requirements
    |
Claude generates product-spec.md + tech-spec.md + design-spec.md (in CLAUDE.md and docs/)
    |
User reviews product direction:
  - Is this really what the user needs?
  - Is there a better solution hidden behind the requirement?
  - What does the 10/10 version look like?
    |
Codex 5.3 reviews technical architecture (Team Lead invokes via MCP, xhigh reasoning, based on tech-spec.md):
  - Architecture fitness and scalability
  - Data flow and state management
  - Potential performance bottlenecks and security issues
  - Whether tech choices match requirements
    |
User confirms -> enter Wave development
```

## Collaboration Mode Selection

The Team Lead automatically selects the collaboration mode based on task characteristics. This is transparent to the user — no explicit mode switch is needed.

**Solo + Codex** — Lead completes the task alone. This is the **default mode**.

**Agent Team** — Lead spawns teammates for parallel execution. Upgrade to Agent Team when **both** conditions are met:

| Condition | Question | Examples |
|-----------|----------|----------|
| 1. Decomposable | Can the work be split into independent parallel sub-tasks? (no file overlap, no data dependency) | 2+ features in different modules → yes; sequential steps in one module → no |
| 2. Sufficient volume | Is file count × workload per file large enough to justify coordination overhead? | See examples by task type below |

This applies to both **write** and **read** tasks:

| Task type | Agent Team example | Solo example |
|-----------|-------------------|--------------|
| **Write** (code, docs, config) | 5 files with large logic changes each | 5 files with 1-line edits each |
| **Read** (code review, doc audit, research/debug) | Review spans multiple modules/files → split by module, parallel review | Review covers a few files → serial review |

If either condition is not met, stay in Solo + Codex. The file count "≤ 3" is a quick heuristic, not a hard rule — what matters is whether parallel coordination saves more time than it costs.

**Shared across both modes** (no difference):
- Codex review / QA → triggered per the Codex Review Trigger Conditions table below
- Doc Engineer documentation audit → always the final step
- Branching → feat/fix/hotfix branches, never develop on main
- Merge → after full workflow, Lead auto-creates PR and merges to main (no manual user review needed — Codex review during development is the quality gate)

## Phase 1-N: Wave Development

### Solo + Codex Workflow

```
Team Lead reads plan.md, confirms current Wave
    |
Team Lead writes code directly
  - Implements the task
  - Writes unit tests for core logic
  - Ensures build passes
    |
Codex Reviewer reviews (per trigger table below)
  - Reviews code logic, edge conditions, security issues
  - Directly fixes issues found
    |
Team Lead reviews Codex fixes (if any)
  - Confirms fix is correct
  - Confirms no new issues introduced
    |
Codex QA smoke testing (per trigger table below)
    |
Team Lead runs Doc Engineer audit (as sub-agent)
  - Same checklist as Agent Team mode (see Doc Engineer role in roles.md)
    |
Process Observer compliance audit (as sub-agent)
  - Branch convention check
  - Codex review compliance check
  - Doc Engineer compliance check
  - Ownership violation check
  - Outputs deviation report to session briefing
    |
Team Lead pushes branch -> creates PR -> merges to main -> cleans up branch
```

### Agent Team Workflow

```
Team Lead reads plan.md, confirms current Wave
    |
Team Lead breaks down tasks: defines file ownership + interface contracts
    |
Claude Developer(s) develop in parallel
  - Write code within file ownership scope
  - Write unit tests for core logic
  - Ensure build passes
    |
Codex Reviewer reviews (per trigger table below)
  - Reviews code logic, edge conditions, security issues
  - Directly fixes issues found
    |
Claude Developer reviews Codex fixes (if review was triggered)
  - Confirms fix is correct
  - Confirms no new issues introduced
  - Confirms adherence to project code style
  - Build verification
    |
Codex QA smoke testing (per trigger table below)
  - Identifies the change scope of this Wave, only tests feature paths affected by changes
  - Skips areas tested in previous Waves that are not affected by current changes
  - Simulates key user operation paths, verifies end-to-end functionality
  - Records and directly fixes issues found (same workflow as code review)
    |
Team Lead spawns Doc Engineer (sub-agent) for documentation audit (placed last to ensure QA-fixed code is also audited)
  - Code vs product-spec.md consistency
  - Code vs tech-spec.md consistency
  - plan.md task status update
  - design-spec.md vs actual styles consistency
  - Whether CLAUDE.md module boundaries need updating
  - Product terminology consistency across all docs (command counts, feature names match, no internal API terms in user-facing docs)
  - Product narrative integration: do new features fit coherently into the overall product story (README, product-spec, Quick Start, troubleshooting) — audit from the user's perspective, not just the changed files
    |
Process Observer compliance audit (as sub-agent, after Doc Engineer)
  - Branch convention check (A1-A3)
  - Codex review compliance check (B1-B3)
  - Doc Engineer compliance check (C1-C3)
  - PR workflow compliance check (D1-D2)
  - Ownership violation check (E1-E2)
  - Outputs deviation report to session briefing
    |
Team Lead pushes branch -> creates PR -> merges to main -> cleans up branch
```

## Codex Review Trigger Conditions

| Scenario | Code Review | QA Smoke Testing |
|----------|-------------|------------------|
| High-risk code: data sync, payments, authentication | Required | Required |
| New API endpoints or data models | Required | Required |
| Pure UI adjustments, copy changes | Not required | Recommended (verify display is correct) |
| Developer self-tested but involves multi-file changes | Recommended | Required |
| Small bug fixes (single file, simple logic) | Not required | Not required |

---

## Custom Commands (commands/)

> For the full content of each command, see the source files in the `commands/` directory. Below is a summary of each command's responsibilities.

| Command | Source File | Execution Role | Responsibility |
|---------|-------------|----------------|----------------|
| `/start-working` | [commands/start-working.md](../commands/start-working.md) | Team Lead | Report current status (Wave progress, remaining issues, session history), suggest next step; user reviews briefing and responds naturally |
| `/end-working` | [commands/end-working.md](../commands/end-working.md) | Team Lead | Ensure all changes are persisted, update plan.md, generate session report, auto commit + PR merge, output session briefing |
| `/plan` | [commands/plan.md](../commands/plan.md) | Team Lead | Review product direction, output implementation plan (with decoupling analysis), wait for user confirmation before writing to plan.md |
| `/init-project` | [commands/init-project.md](../commands/init-project.md) | Team Lead | Generate project skeleton and documentation system (CLAUDE.md + docs/), Codex architecture pre-review, prepare for Wave development |
| `/env-nogo` | [commands/env-nogo.md](../commands/env-nogo.md) | Setup Assistant* | Check whether global and project environments meet iSparto runtime requirements |
| `/migrate` | [commands/migrate.md](../commands/migrate.md) | Setup Assistant* | Migrate an existing project to iSparto workflow — scan, propose, execute after confirmation. Supports `--dry-run` to preview only |
| `/restore` | [commands/restore.md](../commands/restore.md) | Setup Assistant* | Restore project to a previous snapshot — list snapshots, preview changes, execute after confirmation |

\* **Setup Assistant** is not a separate role — it is the Team Lead acting in a setup/maintenance capacity. These commands use a distinct persona to clearly separate setup operations from development workflow.

---

## Branching Strategy

```
main              <- Stable version, releases are made from here
  +-- feat/xxx    <- New feature development, merged back to main when complete
  +-- fix/xxx     <- General bug fixes, merged back to main when complete
  +-- hotfix/xxx  <- Urgent production fixes, branched from main, merged back to main when fixed
  +-- release/vX.Y.Z <- Release preparation branch (if needed)
```

**Rules:**
- No direct development on main — it is locked to the current release version
- Each Wave corresponds to a feature branch (e.g., `feat/wave-1-auth`)
- Within a Wave (Agent Team mode), the Team Lead breaks tasks into decoupled sub-tasks, and each Developer works in an isolated working directory via git worktree for parallel development (automatically managed by Claude Code Agent Team, no manual operation needed), relying on file ownership to prevent conflicts
- Minor fixes can be quickly merged back on fix/ branches
- After the full workflow completes (Codex review + Doc Engineer audit), Lead auto-creates PR and merges to main — no manual user review needed

**Merge workflow (both modes):**
1. Lead pushes the feature/fix/hotfix branch
2. If `gh` CLI is available: create PR via `gh pr create`, merge via `gh pr merge --merge`
3. If `gh` CLI is NOT available: merge locally via `git checkout main && git merge --no-ff <branch> && git push`
4. Lead deletes the branch (local + remote) and switches back to main

Note: Auto PR merge only happens when all tasks on the current branch are complete (all reviews passed, docs updated). If work is mid-Wave, the branch is pushed but not merged — the PR will be created when the branch is done.

**Hotfix Workflow:**
- Branch hotfix/xxx from main
- The mode selection table applies: simple single-file hotfixes use Solo + Codex; complex hotfixes use Agent Team
- The trigger condition table auto-adapts: single-file simple fixes do not trigger code review or QA; high-risk fixes trigger the full suite
- After fixing, merge back to main via PR; if there are in-progress feat/ branches, sync the hotfix changes

---

## Codex 5.3 Integration

> For the Codex role definition and three prompt templates, see [roles.md -> Codex Reviewer](roles.md#codex-reviewer).

Codex intervenes in three scenarios, all configured with xhigh reasoning (via `codex` tool; `review` tool uses server defaults):

| Scenario | Timing | Details |
|----------|--------|---------|
| A. Architecture pre-review | Phase 0, after product initialization, before development | roles.md -> Codex Reviewer -> Architecture pre-review prompt template |
| B. Code review + fixes | Phase 1-N, after Developer completes | roles.md -> Codex Reviewer -> Code review prompt template |
| C. QA smoke testing | Phase 1-N, after Developer review passes | roles.md -> Codex Reviewer -> QA smoke testing prompt template |

---

## Process Observer Integration

Process Observer 在两个层面集成到工作流中：

### Hooks 配置（实时拦截）

通过 Claude Code PreToolUse hook 实现。hook 脚本在每次工具调用前被触发，检查命令是否匹配高危操作清单（git push --force、直接 commit 到 main、敏感文件泄露等）。匹配时阻止执行并输出原因。

hook 的配置和高危操作清单详见 [docs/process-observer.md -> 实时拦截](process-observer.md#实时拦截hooks)。

### 事后审计触发

在 /end-working 流程中，**Doc Engineer 文档审计之后、推分支/建 PR 之前**，Team Lead 派生 Process Observer sub-agent 执行合规审计。审计对照 5 个 Checklist（共 13 个检查项）输出偏差报告。

审计报告输出到 session briefing 中，不自动修改文件。下次 /start-working 时 Lead 在 briefing 中提醒用户上次审计偏差。

完整审计 Checklist 和偏差报告模板详见 [docs/process-observer.md -> 事后审计](process-observer.md#事后审计sub-agent)。
