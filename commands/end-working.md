You are the Team Lead. The user has run /end-working to wrap up the work session.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Ensure all changes and decisions from this session are captured in documentation and the code repository, losing no context.

1. Review all changes and decisions from this session:
   - Are code changes consistent with docs/ documentation? If not, you (Lead) update the docs directly, or spawn a Doc Engineer to update them
   - Have verbal decisions made during the conversation been written into the corresponding docs? If not, add them
   - Were any approaches tried and rejected/rolled back during this session? If yes, append them to the "Rejected Approaches" table in docs/plan.md (date, module/feature, what was tried, why rejected, notes on alternatives or conditions for revisiting)
2. Update docs/plan.md:
   - Mark completed tasks
   - If all Teams in the current Wave are finished, mark the Wave status as completed
   - List next-session to-dos
   - Record remaining issues and manual intervention points
3. Wave Boundary Review (conditional):
   - Trigger: Step 2 marked the current Wave status as completed
   - If triggered:
     a. Spawn Independent Reviewer as Teammate (tmux mode) with the following fixed prompt — do NOT add any context, framing, or explanation:
        "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. This is a Wave Boundary Review."
     b. Wait for the reviewer to complete and append findings to docs/independent-review.md
     c. If CRITICAL finding: in the session briefing, inform user (in user's language) that the Independent Reviewer found CRITICAL issues; add a next-session to-do entry instructing that the CRITICAL findings must be resolved before starting the next Wave. Do NOT block the current commit/push — code is already written, blocking commit would lose work.
     d. If no CRITICAL findings (PROCEED): in the session briefing, inform user (in user's language) that Independent Review passed for the current Wave.
   - If not triggered (mid-Wave session, Wave not completed): skip, do not mention in briefing
4. Generate a session report and append it to `docs/session-log.md`:
   - Gather all metrics from the current session context (you know all of this from coordinating the team)
   - Run `git diff HEAD --stat` to get complete file change stats (captures both staged and unstaged changes vs last commit)
   - If `docs/session-log.md` does not exist, create it with a top-level header `# Session Log`
   - Append a new entry in the following format:

     ```markdown
     ## YYYY-MM-DD Session

     | Metric | Value |
     |--------|-------|
     | Project | [project name from CLAUDE.md] |
     | Wave | [current Wave number and name] |
     | Tasks completed | [list of tasks marked done this session] |
     | Key decisions | [any product/technical decisions confirmed by user this session] |

     ### Files Changed
     ```
     [paste git diff HEAD --stat output here as a code block, not inside the table — raw diff output contains | characters that break Markdown tables]
     ```

     ### Notes
     [Any additional context worth preserving for future sessions]
     ```

   - This file will be committed together with the other changes in the next step
5. Spawn the "Process Observer Audit" agent (Sonnet model) to audit this session:
   - Audit scope: review the session against CLAUDE.md behavioral guidelines — branching conventions, Codex review triggers, Doc Engineer execution, PR workflow, unauthorized operations, plan.md accuracy
   - Input: `git log` (commits in this session), `git diff --stat` (file changes), current branch name, plan.md (check unchecked items against actual codebase state)
   - Output: the agent returns a full compliance report (for Lead's internal reference) and a user-facing summary
   - In the session briefing, only include the user-facing summary:
     - If all checks PASS: do not mention the audit in the briefing (user should not notice)
     - If any checks FAIL: list only the failed items with actionable recovery suggestions, not the full compliance table
   - If rule correction suggestions are identified, record them in the briefing for the next /start-working session to reference
   - If the audit identifies any "Framework-side" rule corrections:
     a. Generate a brief Markdown file: `docs/framework-feedback-MMDD.md`
     b. Include: rule ID, gap description, expected behavior, session context
     c. Save to docs/ (will be committed with session changes)
     d. Inform user (in user's language) that the audit found N framework improvement suggestions saved to docs/framework-feedback-MMDD.md, suggesting they can submit them to the iSparto project
   - This step has no data dependency on step 1 (Doc Engineer audit), but both are triggered sequentially by the Lead within the same session.
6. Security scan (before commit):
   - Execute `bash $HOME/.isparto/hooks/process-observer/scripts/pre-commit-security.sh`
   - If output contains BLOCK → stop the commit, report the specific issues and remediation suggestions to the user in the session briefing
   - If output contains WARNING → include warnings in the session briefing, proceed with commit
   - If passed → proceed to next step
7. Branch guard before commit:
   - Run `git branch --show-current` to check the current branch
   - If on main and there are uncommitted changes (session log, docs updates, etc.):
     - Create a `docs/session-log-MMDD` branch: `git checkout -b docs/session-log-MMDD`
     - This happens when the main work was already merged via PR before /end-working ran
   - If already on a feature branch: stay on it
   Then: git add relevant files && git commit && git push
8. GitHub account alignment (before PR):
   - Run: `REPO_OWNER=$(git remote get-url origin 2>/dev/null | sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#')`
   - Run: `GH_USER=$(gh api /user --jq .login 2>/dev/null)`
   - If both are non-empty and REPO_OWNER ≠ GH_USER:
     - Run `gh auth switch --user "$REPO_OWNER"` to align
     - Note in the session briefing (in user's language) that the gh account was auto-switched to $REPO_OWNER
   - If gh is not available or switch fails: proceed — step 9 will fall back to "push branch and inform user to create PR manually"
9. If all tasks on the current branch are complete (all reviews passed, docs updated):
   - If Doc Engineer audit has NOT been run for this branch's changes: spawn Doc Engineer sub-agent now (pre-merge gate)
   - If the Doc Engineer audit reports FAIL on any item (including item 9 language convention check or item 8 security compliance check): Lead reads the failing items from the report, edits the affected files directly (per the self-referential boundary for framework files, or via Developer for non-framework code), then **spawns a fresh Doc Engineer sub-agent** (zero inherited context) for a full re-audit. Loop bounded at 3 iterations. Do not proceed to `gh pr create` while the audit is in FAIL state.
   - If the third re-audit still FAILs (loop bound exceeded), execute the **6-step blocked recovery path** defined in `docs/roles.md` Doc Engineer Key Principles: (1) stop the loop; (2) generate a blocked-audit report capturing the final FAIL state; (3) write a blocked-audit entry to `docs/plan.md` under a "Blocked audits" section; (4) `git push -u origin <current-branch>` to preserve WIP; (5) report to the user (in user's language) that Doc Engineer audit hit the loop bound, the WIP branch is pushed, and manual intervention is required; (6) exit `/end-working` without creating or merging a PR. Do not leave recovery to Lead's improvisation.
   - Create PR via `gh pr create`, merge via `gh pr merge --merge`. Use the following PR body template (pass via HEREDOC to preserve formatting) — the `Mode Selection` and audit-source lines make the workflow-compliance artifacts visible in PR metadata so later audits can verify B1 (Mode Selection Checkpoint) and C3/F1 (audit execution source) without replaying the session:
     ```markdown
     ## Summary
     <1-3 bullets summarizing the change>

     ## Mode Selection
     [Solo + Codex / Agent Team] — <reason from the Mode Selection Checkpoint at workflow step 0; if Agent Team, list Teammate count and file ownership groups>

     ## Test plan
     - [ ] <acceptance step 1 from plan.md>
     - [ ] <acceptance step 2 from plan.md>

     ## Workflow audits
     - Doc Engineer audit: [sub-agent run ✅ / Lead self-assessed ✅ / skipped — reason] (see docs/workflow.md Hotfix Workflow for skip/substitute paths)
     - Process Observer audit: [sub-agent run ✅ / Lead self-assessed ✅]
     - Independent Reviewer: [Wave boundary PROCEED ✅ / not triggered — reason]
     ```
     The distinction between `sub-agent run ✅` and `Lead self-assessed ✅` for Doc Engineer and Process Observer matters: the sub-agent path is the default and provides the strongest audit guarantee (fresh context, zero inherited bias); the Lead-self-assessed path is reserved for the narrow exception cases defined in CLAUDE.md Solo/Agent Team workflow step 4 (ad-hoc fix / emergency hotfix) and must always cite the exception reason.
   - Delete local branch and switch back to main: `git checkout main && git pull && git branch -d <branch>` (remote branch is auto-deleted by GitHub on merge)
   - If `gh` CLI is NOT available: push the branch and inform the user to create and merge the PR manually on GitHub
   - If tasks are NOT complete (mid-Wave), just push — PR will be created when the branch is done

After completing all steps, output a brief session summary to the user (what changed, issues caught, next steps suggested). This is a briefing, not a confirmation gate — proceed without waiting for user approval.
