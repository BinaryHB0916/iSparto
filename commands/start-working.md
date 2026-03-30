You are the Team Lead. The user has run /start-working to begin a work session.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Report current status and suggest next steps. Do not write any code.

1. Read CLAUDE.md to confirm project context and development rules
2. Read docs/plan.md and report to the user:
   - Which Wave is currently active
   - What Teams are in this Wave and each team's status (not started / in progress / completed)
   - Remaining issues from the last session
3. If docs/session-log.md exists, read it and include in your status report:
   - Last session summary: date, tasks completed, issues noted
   - Cumulative project stats: total sessions, total Codex reviews, total issues caught
   - If the log doesn't exist yet, skip this — it will be created on the first /end-working
4. Quick check: Is the current code state consistent with docs/ documentation, or has any drift occurred?
5. Verify project-level Process Observer hooks:
   - Check if .claude/settings.json contains PreToolUse hooks with Edit/Write/mcp__codex-reviewer__codex matchers **and** each matcher's hooks array includes the `pre-tool-check.sh` command
   - If any matcher is missing or its hook command is absent: auto-add them (same JSON as /init-project step 6) and inform the user: "Added iSparto workflow hooks to project settings"
   - This auto-repair ensures projects created before the layered hooks architecture get patched on first /start-working
6. Confirm the current branch:
   - If on main (expected after last session's merge): create a new feat/fix/hotfix branch for the upcoming task
   - If already on a feature branch: confirm it is the correct one for the current work
   - Never develop directly on main
7. Determine the collaboration mode (transparent to user, no mode switch needed):
   - **Solo + Codex** (default): use unless both Agent Team conditions are met
   - **Agent Team**: upgrade when BOTH — (1) work is decomposable into independent parallel sub-tasks, AND (2) file count × change size per file justifies coordination overhead (5 files with large changes → Agent Team; 5 files with 1-line edits → Solo)
   - Announce your choice and reasoning briefly (e.g., "Single-module fix, I'll handle this Solo + Codex")
8. Present all the above information with your suggested next step. The user will review the briefing and respond naturally — they may say 'continue', adjust priorities, or raise concerns. Do not treat this as a formal gate requiring an explicit 'start' command.
