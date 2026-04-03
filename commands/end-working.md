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
3. Generate a session report and append it to `docs/session-log.md`:
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
     | Developers spawned | [number of teammate developers launched] |
     | Codex reviews | [number of times Codex was called for review/QA] |
     | Codex catches | [brief summary of issues Codex found and fixed, or "None"] |
     | Key decisions | [any product/technical decisions confirmed by user this session] |

     ### Files Changed
     ```
     [paste git diff HEAD --stat output here as a code block, not inside the table — raw diff output contains | characters that break Markdown tables]
     ```

     ### Notes
     [Any additional context worth preserving for future sessions]
     ```

   - This file will be committed together with the other changes in the next step
4. Spawn the "Process Observer Audit" agent (Sonnet model) to audit this session:
   - Audit scope: review the session against CLAUDE.md behavioral guidelines — branching conventions, Codex review triggers, Doc Engineer execution, PR workflow, unauthorized operations, plan.md accuracy
   - Input: `git log` (commits in this session), `git diff --stat` (file changes), current branch name, plan.md (check unchecked items against actual codebase state)
   - Output: deviation report (append to session briefing)
   - If rule correction suggestions are identified, record them in the briefing for the next /start-working session to reference
   - This step can run in parallel with the Doc Engineer audit in step 1
5. Security scan (before commit):
   - Execute `bash $HOME/.isparto/hooks/process-observer/scripts/pre-commit-security.sh`
   - If output contains BLOCK → stop the commit, report the specific issues and remediation suggestions to the user in the session briefing
   - If output contains WARNING → include warnings in the session briefing, proceed with commit
   - If passed → proceed to next step
6. Branch guard before commit:
   - Run `git branch --show-current` to check the current branch
   - If on main and there are uncommitted changes (session log, docs updates, etc.):
     - Create a `docs/session-log-MMDD` branch: `git checkout -b docs/session-log-MMDD`
     - This happens when the main work was already merged via PR before /end-working ran
   - If already on a feature branch: stay on it
   Then: git add relevant files && git commit && git push
7. If all tasks on the current branch are complete (all reviews passed, docs updated):
   - If Doc Engineer audit has NOT been run for this branch's changes: spawn Doc Engineer sub-agent now (pre-merge gate)
   - Create PR via `gh pr create`, merge via `gh pr merge --merge`
   - Delete local branch and switch back to main: `git checkout main && git pull && git branch -d <branch>` (remote branch is auto-deleted by GitHub on merge)
   - If `gh` CLI is NOT available: push the branch and inform the user to create and merge the PR manually on GitHub
   - If tasks are NOT complete (mid-Wave), just push — PR will be created when the branch is done

After completing all steps, output a brief session summary to the user (what changed, issues caught, next steps suggested). This is a briefing, not a confirmation gate — proceed without waiting for user approval.
