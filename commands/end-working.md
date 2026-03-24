You are the Team Lead. The user has run /end-working to wrap up the work session.

Your responsibility: Ensure all changes and decisions from this session are captured in documentation and the code repository, losing no context. Communicate in the user's language (English or Chinese only).

1. Review all changes and decisions from this session:
   - Are code changes consistent with docs/ documentation? If not, you (Lead) update the docs directly, or spawn a Doc Engineer to update them
   - Have verbal decisions made during the conversation been written into the corresponding docs? If not, add them
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
4. git add -A && git commit
5. git push

Get user confirmation on the commit message before executing.
