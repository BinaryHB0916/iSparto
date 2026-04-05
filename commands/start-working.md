You are the Team Lead. The user has run /start-working to begin a work session.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Report current status and suggest next steps. Do not write any code.

0. Branch guard (FIRST — before reading any files or doing any work):
   - Run `git branch --show-current`
   - If on `main` or `master`: immediately run `git checkout -b feat/wip-MMDD` (where MMDD is today's date) to create a working branch
     - Report to user: "当前在 main，已切换到 feat/wip-MMDD"
   - If already on a feature/fix/docs/hotfix/release branch: proceed
   - This step MUST complete before reading CLAUDE.md or any other file

1. Read CLAUDE.md to confirm project context and development rules
2. Read docs/plan.md and report to the user:
   - Which Wave is currently active
   - What Teams are in this Wave and each team's status (not started / in progress / completed)
   - Remaining issues from the last session
   - Rejected approaches relevant to the current Wave's tasks (if any exist in plan.md's "Rejected Approaches" table)
   - If the current branch is named `feat/wip-MMDD` (placeholder from Step 0) and plan.md context suggests a better name (e.g., `feat/wave-3-auth`), rename it now with `git branch -m <better-name>`
3. If docs/session-log.md exists, read it and include in your status report:
   - Last session summary: date, tasks completed, issues noted
   - Cumulative project stats: total sessions, total Codex reviews, total issues caught
   - If the log doesn't exist yet, skip this — it will be created on the first /end-working
4. Quick check: Is the current code state consistent with docs/ documentation, or has any drift occurred?
5. Runtime health check (if applicable):
   - Check CLAUDE.md's "Common Commands" section for explicit build/test commands (e.g., `npm run build`, `swift build`, `./gradlew test`). Do NOT use the "Build" field in Tech Stack — it is descriptive (e.g., "Xcode", "Vite"), not executable
   - If a build command exists: run it and verify it succeeds
   - If a test command exists: run the test suite and verify it passes
   - Report failures in the briefing but do not block — user decides whether to fix first or proceed with new work
   - If no explicit build/test commands are found: skip this step
   - This step catches environment issues invisible to documentation checks: dependency updates, build environment drift, incomplete syncs from previous sessions
6. GitHub account alignment (if applicable):
   - Run: `REPO_OWNER=$(git remote get-url origin 2>/dev/null | sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#')`
   - Run: `GH_USER=$(gh api /user --jq .login 2>/dev/null)`
   - If both are non-empty and REPO_OWNER ≠ GH_USER:
     - Run `gh auth switch --user "$REPO_OWNER"` to align
     - Report to user: "gh 账号已自动切换到 $REPO_OWNER（仓库 owner）"
   - If gh is not installed, not authenticated, or only one account exists: skip silently
   - This step ensures `gh pr create` in /end-working uses the correct account
7. Verify project-level Process Observer hooks:
   - Check if .claude/settings.json contains PreToolUse hooks with Edit/Write/mcp__codex-dev__codex matchers **and** each matcher's hooks array includes the `pre-tool-check.sh` command
   - If old matcher `mcp__codex-reviewer__codex` is found: rename it to `mcp__codex-dev__codex` and inform the user: "Migrated hook matcher: codex-reviewer → codex-dev"
   - If any matcher is missing or its hook command is absent: auto-add them (same JSON as /init-project step 6) and inform the user: "Added iSparto workflow hooks to project settings"
   - This auto-repair ensures projects created before the layered hooks architecture get patched on first /start-working
8. Determine the collaboration mode (transparent to user, no mode switch needed):
   - **Solo + Codex** (default): use unless both Agent Team conditions are met
   - **Agent Team**: upgrade when BOTH — (1) work is decomposable into independent parallel sub-tasks, AND (2) file count × change size per file justifies coordination overhead (5 files with large changes → Agent Team; 5 files with 1-line edits → Solo)
   - Announce your choice and reasoning briefly (e.g., "Single-module fix, I'll handle this Solo + Codex")
9. Present all the above information with your suggested next step. The user will review the briefing and respond naturally — they may say 'continue', adjust priorities, or raise concerns. Do not treat this as a formal gate requiring an explicit 'start' command.
