You are the Team Lead. The user has run /start-working to begin a work session.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Report current status and suggest next steps. Do not write any code.

0. Session boundary check (ABSOLUTE FIRST — before branch guard, before reading any files, before any state mutation):
   - Read `docs/plan.md` and search for the literal marker line: `🚨 BLOCKING: Next Wave requires NEW SESSION` (this is a fixed system marker, not a user-facing string — match it as a literal)
   - If the marker is NOT present: skip this entire step and proceed to Step 0.5 (branch guard)
   - If the marker IS present:
     a. Hard-stop the flow. Do NOT continue to Step 0.5 until this step resolves.
     b. Ask the user (in user's language) to confirm whether this is a new session — i.e., a different Claude Code session from the one that originally wrote the BLOCKING marker. Wait for the user's reply.
     c. If the user confirms this IS a new session:
        - Write a session-boundary acknowledgement annotation immediately below the marker line in `docs/plan.md`. The annotation format is: `> ✅ Session boundary acknowledged YYYY-MM-DD by /start-working` (substitute today's date). This annotation is a literal because plan.md is Tier 4 and not user-facing.
        - Proceed to Step 0.5 (branch guard).
     d. If the user indicates this is the SAME session (i.e., the same session that wrote the marker):
        - Halt. Do NOT proceed to Step 0.5. Do NOT mutate any state.
        - Instruct the user (in user's language) to close this Claude Code session entirely and open a new one, then run `/start-working` again in the new session.

0.5. Branch guard (before reading any files or doing any work):
   - Run `git branch --show-current`
   - If on `main` or `master`: immediately run `git checkout -b feat/wip-MMDD` (where MMDD is today's date) to create a working branch
     - Inform the user (in user's language) that the session was on main and has been switched to the new feat/wip-MMDD working branch
   - If already on a feature/fix/docs/hotfix/release branch: proceed
   - This step MUST complete before reading CLAUDE.md or any other file

1. Read CLAUDE.md to confirm project context and development rules
2. Read docs/plan.md and report to the user:
   - Which Wave is currently active
   - What Teams are in this Wave and each team's status (not started / in progress / completed)
   - Remaining issues from the last session
   - Rejected approaches relevant to the current Wave's tasks (if any exist in plan.md's "Rejected Approaches" table)
   - If the current branch is named `feat/wip-MMDD` (placeholder from Step 0.5) and plan.md context suggests a better name (e.g., `feat/wave-3-auth`), rename it now with `git branch -m <better-name>`
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
     - Inform the user (in user's language) that the gh account has been auto-switched to $REPO_OWNER (the repository owner)
   - If gh is not installed, not authenticated, or only one account exists: skip silently
   - This step ensures `gh pr create` in /end-working uses the correct account
7. Verify project-level Process Observer hooks:
   - Check if .claude/settings.json contains PreToolUse hooks with Edit/Write/mcp__codex-dev__codex matchers **and** each matcher's hooks array includes the `pre-tool-check.sh` command
   - If the legacy matcher `mcp__codex-reviewer__codex` is found:
     - **Migration guard (mandatory before renaming):** Run `claude mcp list -s user 2>/dev/null | grep -q codex-dev` to verify the renamed MCP server (`codex-dev`) is actually registered at the user level. The local iSparto installation is responsible for registering this server during `install.sh --upgrade`; if the user has not upgraded yet, the registration is still under the old name.
     - If the guard passes (exit 0 — `codex-dev` is registered): rename the matcher to `mcp__codex-dev__codex` and inform the user (in user's language) that the hook matcher was migrated from codex-reviewer to codex-dev
     - If the guard fails (non-zero exit — `codex-dev` is NOT registered, indicating a stale install): leave the old matcher in place and do NOT rename it. A renamed matcher would point to a non-existent MCP server and silently disable hook interception, which is worse than the legacy state. Inform the user (in user's language) that the local iSparto installation is stale (only the legacy `codex-reviewer` MCP server is registered), so the project hook matcher migration has been skipped to preserve interception, and instruct them to run `~/.isparto/install.sh --upgrade` first and then re-run `/start-working` so the migration can complete. After informing the user, also skip the next bullet (the "If any matcher is missing or its hook command is absent: auto-add them" auto-add branch) — auto-adding a `mcp__codex-dev__codex` matcher on a stale install would re-introduce the same silent-disable bug — and proceed directly to Step 8.
   - If any matcher is missing or its hook command is absent:
     - **Migration guard (mandatory before auto-adding):** Run `claude mcp list -s user 2>/dev/null | grep -q codex-dev` to verify the `codex-dev` MCP server is actually registered at the user level. Writing a `mcp__codex-dev__codex` matcher on a stale install (where the server is still registered under the legacy name `codex-reviewer`) would point the matcher at a non-existent MCP server and silently disable hook interception, which is worse than leaving the matcher absent.
     - If the guard passes (exit 0 — `codex-dev` is registered): auto-add the missing matchers (same JSON as /init-project step 6) and inform the user (in user's language) that iSparto workflow hooks were added to the project settings
     - If the guard fails (non-zero exit — `codex-dev` is NOT registered, indicating a stale install): do NOT auto-add any matchers. A partial auto-add would leave the project in an inconsistent mid-state. Inform the user (in user's language) that the local iSparto installation is stale (only the legacy `codex-reviewer` MCP server is registered at the user level), so the project hook matcher auto-add has been skipped to preserve interception, and instruct them to run `~/.isparto/install.sh --upgrade` first and then re-run `/start-working` so the auto-add can complete. After informing the user, proceed directly to Step 8.
   - This auto-repair ensures projects created before the layered hooks architecture get patched on first /start-working
8. Determine the collaboration mode (transparent to user, no mode switch needed):
   - **Solo + Codex** (default): use unless both Agent Team conditions are met
   - **Agent Team**: upgrade when BOTH — (1) work is decomposable into independent parallel sub-tasks, AND (2) file count × change size per file justifies coordination overhead (5 files with large changes → Agent Team; 5 files with 1-line edits → Solo)
   - Announce your choice and reasoning briefly (e.g., "Single-module fix, I'll handle this Solo + Codex")
9. Present all the above information with your suggested next step. The user will review the briefing and respond naturally — they may say 'continue', adjust priorities, or raise concerns. Do not treat this as a formal gate requiring an explicit 'start' command.
