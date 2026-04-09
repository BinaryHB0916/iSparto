# Case Studies

This file is iSparto's growing collection of concrete end-to-end runs — each case tracks a real Wave or session that exercised the framework against its own workflow. The intent is not marketing: each entry records the flow, the decisions, and the measurable output so future readers can see how the pieces fit together.

v0.7.5 starts this file with a single case — the Session Log self-bootstrapping run from Wave 5. Future Waves extend this file rather than the README, so the README stays focused on the framework's pitch and this file carries the evidence of what the pitch actually looks like in practice.

## Case 1 — Session Log (self-bootstrapping, Wave 5)

iSparto used its own Agent Team workflow to build the "Session Log" feature — automatic session metrics collection in `/end-working` and `/start-working`. This was the first complete dogfooding run of the framework on itself.

### Flow

1. **`/start-working`** — Lead read `plan.md`, reported Wave 5 status, identified the session log feature as the next task.
2. **Branch** — Lead created `feat/session-log`.
3. **Task breakdown** — Lead assigned file ownership:
   - Developer A: `commands/end-working.md` (add session report generation)
   - Developer B: `commands/start-working.md` (add session log reading)
4. **Parallel development** — Both Developers ran simultaneously and completed their tasks.
5. **Codex Review** — Found 2 P2 issues:
   - `git diff --stat` misses staged/untracked files. Fixed to `git diff HEAD --stat`.
   - Diff output inside a Markdown table breaks rendering. Moved to a code block.
6. **Fix** — Lead applied both Codex findings.
7. **Doc audit** — Doc Engineer updated `workflow.md` and `plan.md`.
8. **Merge** — Merged to `main` via a `--no-ff` merge commit.

### Stats

| Metric | Value |
|--------|-------|
| Developers in parallel | 2 |
| Codex review passes | 1 |
| Issues caught by Codex | 2 (both fixed) |
| Files changed | 4 |
| Insertions / Deletions | +45 / -11 |
| Full cycle | Task breakdown, parallel dev, Codex review, fix, doc audit, merge |

### What this case demonstrates

Two Developers ran in parallel against disjoint file ownership without merge conflicts; the cross-model review gate (Lead reviewing Codex output) caught two real defects before any human review; documentation stayed in sync inside the same Wave rather than drifting into a follow-up commit. One single-sentence requirement produced a complete merged feature without the user acting as dispatcher between subtasks.
