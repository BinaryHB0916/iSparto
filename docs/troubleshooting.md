# Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Codex MCP status shows ✘ failed | MCP Server command is incorrect, or Codex CLI is not installed/not logged in | Verify that `codex --version` and `codex login status` work correctly, then run `claude mcp remove codex-reviewer -s project && claude mcp add codex-reviewer -s project -- npx -y codex-mcp-server` and restart Claude Code |
| Claude Code context window is full | Long sessions accumulate too many tokens | Run `/compact` to compress context. If still full, run `/end-working` to wrap up, then start a new session with `/start-working` to continue (plan.md ensures no context is lost) |
| Developer modified files they shouldn't have | File ownership directives were ignored | Team Lead rolls back the changes to that file, re-clarifies file ownership, and has the Developer redo the work. Add project-specific rules to CLAUDE.md to emphasize this |
| Merge conflicts (multiple Developers in parallel) | File ownership boundaries overlap, or shared files lack a clear modification order | Team Lead ensures file ownership does not overlap when splitting tasks. Assign shared file modifications to only one Developer, or define a clear order |
| Codex review returns empty results | Network issues or Codex service temporarily unavailable | Retry once. If it continues to fail, check `codex login status` — you may need to log in again |
| Codex remains unavailable | Codex service outage or account issue that cannot be resolved quickly | Team Lead escalates to the user: "Codex is unavailable." The user decides: continue development (skip Codex steps), wait for recovery, or handle otherwise |
| `/start-working` finds code and docs out of sync | Documentation sync was incomplete during the last wrap-up | Have the Team Lead fix the inconsistencies first, then confirm before continuing development |
| Want to continue after stepping away briefly | Claude Code session is still active | Use `claude --continue` to resume the current session. If the session has expired, start a new session with `/start-working` |
| Agent Team teammates not visible | Not using iTerm2, or tmux integration is not enabled | Confirm you are running Claude Code in iTerm2; check that tmux integration is enabled in iTerm2 settings |
