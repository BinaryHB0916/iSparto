# Framework Feedback — 2026-04-09

Source: Process Observer post-session audit of Wave v0.7.4 Information Layering Policy session (2026-04-09). Audit result: 14/14 PASS, 0 workflow deviations. Two framework-side rule correction suggestions surfaced for iSparto core updates.

## Rule 1 — Branch Protocol should name "Edit tool invoked on main" as a violation

**Rule ID:** CLAUDE.md Branch Protocol (L1 "Never make any changes on the main branch" + "First action of every session" checklist).

**Gap description:** The Branch Protocol says "never make any changes on main" and lists the first-action checklist as `git branch --show-current` → checkout if needed. Process Observer hooks intercept commits, merges, and pushes on main — but do not intercept Edit/Write tool invocations (because these are not git operations). This means a session can accumulate uncommitted edits on main without any hook firing. The rule is written in commit-level language ("never commit to main") but the intended scope is broader ("never touch main"). Without explicit language, a Lead assessing compliance might read "no commit landed on main" as sufficient.

**Expected behavior:** The Branch Protocol should explicitly state that Edit/Write tool calls on main are a rule violation even when no commit results, and that the Lead must run `git branch --show-current` before the first Edit tool call, not just before the first commit. The correct recovery (checkout a new branch before committing, carrying over the uncommitted change) should also be named so future sessions follow the same path without improvisation.

**Session context:** After PR #177 (v0.7.4 feature work) merged to main, Lead started editing `docs/plan.md` to record the v0.7.5 polish candidate note while still on main, then noticed the violation and ran `git checkout -b docs/v074-polish-note` before committing. No commit landed on main — the deviation was "edit tool invoked on main", not "commit on main". The recovery was correct (branch created before commit, uncommitted change carried over intact, subsequent commit went to the right branch). Self-assessed in PR #178 body under Workflow audits.

**Suggested fix:** Amend CLAUDE.md Branch Protocol section to add one clarifying sentence: "'Never make any changes on main' includes Edit/Write tool invocations, not just git operations. The branch guard must complete before the first Edit tool call, not just before the first commit. If an Edit tool call on main is detected, the correct recovery is `git checkout -b <type>/<name>` before committing (the uncommitted change carries over with the checkout — no manual stash needed)."

## Rule 2 — Process Observer audit checklist should have an explicit Edit-on-main check

**Rule ID:** agents/process-observer-audit.md check A-series (branch protocol checks).

**Gap description:** The current audit checklist covers "branch is feat/fix/hotfix/docs/release (not main)" and "no direct commits to main" but does not explicitly cover "Edit/Write tool invoked on main before branch creation". The audit relies on the Lead's self-report for this distinction, which is fragile — if the Lead does not self-report, the gap is invisible to the auditor unless it shows up in tool-use telemetry that the audit agent may not inspect.

**Expected behavior:** The Process Observer audit checklist should have an explicit A-series check distinguishing "commit landed on main" (strong violation) from "Edit tool invoked on main before branch creation" (weak violation but still a violation). The weak form is self-recoverable and should PASS as long as recovery was clean (branch created before commit, uncommitted change carried over, commit went to correct branch). The audit should verify both the violation and the recovery, not rely on self-report.

**Session context:** The current audit PASSED the branch-guard check based on the Lead's self-report in the PO audit prompt. Without the self-report, the tool-invocation deviation would not have been audited — only the commit-level check would have run, and both commit-level checks passed. This is a coverage gap: the audit is blind to tool-invocation violations unless the Lead flags them.

**Suggested fix:** Add an A3 check to `agents/process-observer-audit.md`: "A3 — Edit/Write tool invocations on main: were any Edit/Write tool calls made while the current branch was main? If yes, verify the recovery path (branch created before commit, uncommitted change carried over, commit went to correct branch). PASS only if both violation and recovery are clean-recorded." This distinguishes the tool-invocation violation from the commit-on-main violation and gives the PO audit a specific item to verify rather than relying on self-report.

## Summary

Both rules are scope-clarification / audit-coverage gaps surfaced by the session's branch-guard self-assessed deviation. Neither is blocking — the deviation this session was caught and recovered cleanly. Fix priority: low; fold into the next framework polish round (could pair with the v0.7.5 Principle 5 scope-clamp candidate recorded in plan.md v0.7.4 Wave entry).
