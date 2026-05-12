# Independent Review — 2026-05-12

## My understanding of the product (from product-spec only)

iSparto is a workflow framework that turns Claude Code from a single-agent coding assistant into an AI development team with explicit roles, coordinated workflows, parallel execution, quality gates, documentation synchronization, state recovery, and safety oversight.

The current product stage is v0.x: a developer tool for users who already understand Claude Code, Git, branches, and reviews. These users manually trigger slash commands, but expect one person to command the output capacity of a structured team. The product direction then evolves toward v1.x autonomous team execution and v2.x natural-language CEO-style requirement intake, but those later stages are described as future capability layers rather than the current open-source core.

When users use the current product, they expect to install iSparto with one command, initialize or migrate a project, start and resume work through slash commands, coordinate several agent roles, run parallel Wave-based development, recover context across sessions through `plan.md`, review work through cross-model gates, keep docs in sync, take snapshots before operations, restore safely, log sessions, and run compliance/security oversight.

The key functional requirements I identify from the product spec are:

1. Provide an Agent Team workflow with separated roles: Team Lead, Developer/Codex, parallel Teammates, Doc Engineer, Independent Reviewer, and Process Observer.
2. Support Wave-based parallel development with multiple Developers running in parallel and visualized through tmux split panes.
3. Provide the ten renamed slash commands: `/init-isparto`, `/migrate-isparto`, `/start-isparto`, `/end-isparto`, `/plan-isparto`, `/env-isparto`, `/doctor-isparto`, `/restore-isparto`, `/security-isparto`, and `/release-isparto`.
4. Support cross-session state recovery driven by `plan.md`, including automatic context restoration from `/start-isparto`.
5. Provide cross-model quality gates where the Lead reviews Developer/Codex output.
6. Provide automatic documentation synchronization through a Doc Engineer audit every Wave.
7. Provide snapshot and restore behavior: automatic snapshots before every operation and one-click rollback through `/restore-isparto`.
8. Maintain `docs/session-log.md` with development metrics for every session.
9. Provide Process Observer compliance oversight through L1 real-time Write/Edit scanning, L2 pre-commit secret/PII scanning, L3 milestone security audit, post-hoc session compliance review, deviation reporting, and rule-improvement feedback.
10. Provide version tracking and changelog support, including `--upgrade`.
11. Provide one-line installation with `--dry-run`, `--upgrade`, and `--uninstall`.
12. Stay within the stated technical constraints: pure configuration project using shell scripts, Markdown templates, and MCP server registration; depend on Claude Code Agent Team mode, Codex CLI, and iTerm2 tmux integration on macOS.
13. Progress toward the three-layer capability model: workflow autonomy, state visibility, and requirement understanding, with current v0.x delivery and explicitly named future gaps.

## Alignment Assessment

`docs/tech-spec.md` is required by the review procedure but is not present in the repository. The only matching file found is `templates/tech-spec-template.md`, which is a template and not an authored technical specification. Because there is no technical specification to evaluate, no product requirement has authoritative technical coverage.

| # | Product Requirement | Tech Approach | Aligned? | Severity | Detail |
|---|-------------------|---------------|----------|----------|--------|
| 1 | Agent Team role separation across Lead, Developer/Codex, Teammates, Doc Engineer, Independent Reviewer, and Process Observer | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines how roles are configured, invoked, coordinated, or bounded. |
| 2 | Wave-based parallel development with multiple Developers and tmux split-pane visualization | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines Wave lifecycle, parallel process orchestration, pane setup, synchronization, or failure behavior. |
| 3 | Ten slash commands with the `-isparto` names | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach maps each command to scripts, templates, behavior, arguments, or compatibility/migration rules. |
| 4 | Cross-session state recovery driven by `plan.md`, including `/start-isparto` context restoration | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines the `plan.md` contract, parser expectations, recovery sequence, or stale-state handling. |
| 5 | Cross-model quality gate where Lead reviews Codex output | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines review handoff, acceptance criteria, reviewer isolation, or enforcement. |
| 6 | Automatic documentation synchronization through Doc Engineer audits every Wave | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines what is audited, when it runs, how discrepancies are detected, or how docs are updated. |
| 7 | Automatic snapshot before every operation and `/restore-isparto` one-click rollback | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines snapshot scope, storage, restore semantics, exclusions, or recovery safety. |
| 8 | Session metrics recorded in `docs/session-log.md` for every session | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines metric schema, update triggers, append behavior, or conflict handling. |
| 9 | Process Observer three-layer security/compliance oversight plus post-hoc audit and rule feedback loop | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines L1/L2/L3 implementation, hook integration, detection rules, reporting, or non-interference guarantees. |
| 10 | Version tracking, changelog, and `--upgrade` support | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines version source, upgrade flow, changelog maintenance, or backward compatibility handling. |
| 11 | One-line install with `--dry-run`, `--upgrade`, and `--uninstall` | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach defines install targets, idempotency, dry-run reporting, upgrade/uninstall behavior, or platform checks. |
| 12 | Pure configuration architecture with shell scripts, Markdown templates, and MCP registration; Claude Code, Codex CLI, and macOS/iTerm2/tmux dependencies | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach confirms the architecture or explains how external dependencies are detected, validated, and integrated. |
| 13 | Three-layer evolution toward workflow autonomy, state visibility, and requirement understanding | No `docs/tech-spec.md` present | N | CRITICAL | No technical approach distinguishes delivered v0 behavior from future-layer work, so scope boundaries and sequencing are not technically grounded. |

## Uncovered Requirements

All functional requirements identified from `docs/product-spec.md` are uncovered because `docs/tech-spec.md` does not exist:

- Agent Team role separation.
- Wave-based parallel development and tmux visualization.
- Ten `-isparto` slash commands.
- `plan.md`-driven cross-session recovery.
- Cross-model quality gate.
- Automatic documentation synchronization.
- Snapshot and restore.
- Session metrics logging.
- Process Observer security/compliance oversight.
- Version tracking, changelog, and upgrade behavior.
- One-line install, dry-run, upgrade, and uninstall behavior.
- Pure configuration architecture and external dependency handling.
- Product evolution capability layering and scope boundaries.

## Unjustified Technical Work

None identified from `docs/tech-spec.md`, because that file is absent. This does not prove there is no scope creep in the repository; it only means there is no technical specification whose components can be traced back to product requirements under this review procedure.

## Recommendation

BLOCK.

The review cannot proceed to an alignment approval because the required technical specification is missing. This is a CRITICAL Phase 0 misalignment: the product spec makes concrete promises, but there is no authoritative technical approach demonstrating how those promises are implemented. A `docs/tech-spec.md` should be authored or restored, and the Independent Reviewer should be re-triggered after that file exists.
