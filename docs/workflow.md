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

## Phase 1-N: Wave Parallel Development

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
Codex Reviewer reviews (executed based on trigger condition table, see below)
  - Reviews code logic, edge conditions, security issues
  - Directly fixes issues found
    |
Claude Developer reviews Codex fixes (if review was triggered)
  - Confirms fix is correct
  - Confirms no new issues introduced
  - Confirms adherence to project code style
  - Build verification
    |
Codex QA smoke testing (executed based on trigger condition table, see below)
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
    |
Team Lead confirms all passes -> merge code -> update plan.md
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
| `/start-working` | [commands/start-working.md](../commands/start-working.md) | Team Lead | Report current status (Wave progress, remaining issues, session history), wait for user confirmation before launching the team |
| `/end-working` | [commands/end-working.md](../commands/end-working.md) | Team Lead | Ensure all changes and decisions are persisted, update plan.md, generate session report to session-log.md, commit & push |
| `/plan` | [commands/plan.md](../commands/plan.md) | Team Lead | Review product direction, output implementation plan (with decoupling analysis), wait for user confirmation before writing to plan.md |
| `/init-project` | [commands/init-project.md](../commands/init-project.md) | Team Lead | Generate project skeleton and documentation system (CLAUDE.md + docs/), Codex architecture pre-review, prepare for Wave development |
| `/env-nogo` | [commands/env-nogo.md](../commands/env-nogo.md) | Setup Assistant | Check whether global and project environments meet iSparto runtime requirements |
| `/migrate` | [commands/migrate.md](../commands/migrate.md) | Setup Assistant | Migrate an existing project to iSparto workflow — scan, propose, execute after confirmation. Supports `--dry-run` to preview only |
| `/restore` | [commands/restore.md](../commands/restore.md) | Setup Assistant | Restore project to a previous snapshot — list snapshots, preview changes, execute after confirmation |

---

## Branching Strategy

```
main              <- Stable version, releases are made from here
  +-- feat/xxx    <- New feature development, merged back to main when complete
  +-- fix/xxx     <- General bug fixes, merged back to main when complete
  +-- hotfix/xxx  <- Urgent production fixes, branched from main, merged back to main when fixed
  +-- release/x.x <- Release preparation branch (if needed)
```

**Rules:**
- No direct development on main — it is locked to the current release version
- Each Wave corresponds to a feature branch (e.g., `feat/wave-1-auth`)
- Within a Wave, the Team Lead breaks tasks into decoupled sub-tasks, and each Developer works in an isolated working directory via git worktree for parallel development (automatically managed by Claude Code Agent Team, no manual operation needed), relying on file ownership to prevent conflicts
- Minor fixes can be quickly merged back on fix/ branches
- Before merging back to main, documentation audit by Doc Engineer is required; Codex code review and QA smoke testing are executed based on the trigger condition table (not triggered every time)

**Hotfix Workflow:**
- Branch hotfix/xxx from main
- Follow the full Team Lead -> Developer -> Codex review -> Developer review -> Codex QA -> Doc Engineer workflow
- No simplified version — the Agent Team full workflow takes minutes, without the human team's bottleneck of waiting for people
- The trigger condition table auto-adapts: single-file simple fixes do not trigger code review or QA; high-risk fixes trigger the full suite
- After fixing, merge back to main; if there are in-progress feat/ branches, sync the hotfix changes

---

## Codex 5.3 Integration

> For the Codex role definition and three prompt templates, see [roles.md -> Codex Reviewer](roles.md#codex-reviewer).

Codex intervenes in three scenarios, all configured with xhigh reasoning (via `codex` tool; `review` tool uses server defaults):

| Scenario | Timing | Details |
|----------|--------|---------|
| A. Architecture pre-review | Phase 0, after product initialization, before development | roles.md -> Codex Reviewer -> Architecture pre-review prompt template |
| B. Code review + fixes | Phase 1-N, after Developer completes | roles.md -> Codex Reviewer -> Code review prompt template |
| C. QA smoke testing | Phase 1-N, after Developer review passes | roles.md -> Codex Reviewer -> QA smoke testing prompt template |
