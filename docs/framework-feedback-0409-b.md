## Framework feedback — 2026-04-09 Session #b (Principle 5 total-collapse polish)

### F1 — gh account alignment re-verify is missing before mid-session `gh pr create`

**Observed session:** `docs/principle5-total-collapse` (PR #181, 2026-04-09)

**Symptom:** First `gh pr create` attempt failed with `GraphQL: must be a collaborator (createPullRequest)` even though `/start-working` Step 6 had reported `REPO_OWNER=BinaryHB0916` and `GH_USER=BinaryHB0916` at session open. The active `gh` account had silently drifted to `dadalus0916` between Step 6 and the PR create call.

**Root cause:** The gh alignment check lives in two places:

1. `commands/start-working.md` Step 6 — runs once at session open.
2. `commands/end-working.md` Step 8 — runs once before `gh pr create` in the `/end-working` flow.

But the Solo and Agent Team workflows in `CLAUDE.md` both list **workflow step 6: "Lead pushes branch -> creates PR -> merges to main -> cleans up branch"** — and this step can execute inside a `/start-working` session (when the task is finished and PR'd before `/end-working` is invoked), not via `/end-working`. When that happens, the gh alignment snapshot taken at `/start-working` Step 6 is the only check, and it is stale by the time the mid-session `gh pr create` fires. The `dadalus0916` drift in this session happened between those two events.

**Recovery this session:** Manual `gh auth switch --user BinaryHB0916` + explicit `gh api /user --jq .login` re-verify + retry `gh pr create`. No data lost — the branch + commit were already pushed. But the recovery was unguided; the failure mode surfaced as a raw `GraphQL: must be a collaborator` error, which is easy to misdiagnose as a permissions problem rather than an account-drift problem.

**Proposed fix:** Add a **pre-`gh pr create` alignment guard** as a generic Lead protocol that applies to any `gh pr create` invocation, regardless of which command flow wraps it. Two candidate implementations:

1. **Document-level fix (lightweight):** Add a bullet to `CLAUDE.md` Solo + Agent Team workflow step 6 ("Lead pushes branch -> creates PR -> merges to main") instructing Lead to run `gh api /user --jq .login` and compare against `REPO_OWNER` immediately before `gh pr create`, auto-switching via `gh auth switch --user "$REPO_OWNER"` if mismatched. Mirrors the existing `/start-working` Step 6 and `/end-working` Step 8 logic, but pinned to the generic workflow step that owns `gh pr create`.

2. **Structural fix (more robust):** Extract the gh alignment check into a reusable shell snippet at `scripts/gh-align-check.sh` that can be sourced or invoked by any command template before `gh pr create`. The snippet takes no arguments, reads `git remote get-url origin`, runs `gh api /user --jq .login`, auto-switches if mismatched, and exits 0 on success / 1 on failure. `commands/start-working.md` Step 6, `commands/end-working.md` Step 8, and CLAUDE.md workflow step 6 all call it. Eliminates copy-paste divergence.

**Recommended:** Document-level fix is cheaper and matches the current pattern (all gh alignment logic lives inline in command templates, not in shared scripts). Structural fix is over-engineering for a 3-line snippet until the same pattern repeats in a third command.

**Priority:** Medium. The race window is narrow but real — any time Lead creates a PR without going through `/end-working`, the alignment is a stale snapshot. This session hit the race; next time it may be harder to diagnose because the error message (`must be a collaborator`) points at permissions, not account drift.

**Conditional on:** User confirms they use a multi-account `gh` setup (as evidenced by the `gh auth status` output showing two accounts: `dadalus0916` and `BinaryHB0916`). Single-account users are not affected by this race.

**Affected files if accepted:**
- `CLAUDE.md` Solo + Agent Team workflow step 6 (add alignment guard bullet)
- Optionally: `commands/start-working.md` Step 6 note that it's a snapshot, not a guarantee

**Session log evidence:** `docs/session-log.md` 2026-04-09 Session (#b) Notes section documents the symptom, root cause, and recovery path. This framework-feedback file is the durable rule-correction artifact.
