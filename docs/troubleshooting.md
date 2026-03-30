# Troubleshooting

## Installation Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| `python3 not found` during install | Python 3 is not installed or not in PATH | Install Python 3: `brew install python3` (macOS) or `apt install python3` (Linux), then re-run the installer |
| `npm: command not found` | Node.js/npm is not installed | Install Node.js from https://nodejs.org/ (LTS recommended) or via `brew install node` |
| Codex login fails | ChatGPT subscription is inactive or network issue | Verify your ChatGPT Plus subscription is active at https://chatgpt.com, then run `codex login` manually |

## Runtime Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Codex MCP status shows ✘ failed | MCP Server command is incorrect, or Codex CLI is not installed/not logged in | Verify that `codex --version` and `codex login status` work correctly, then run `claude mcp remove codex-reviewer -s user && claude mcp add codex-reviewer -s user -- npx -y codex-mcp-server` and restart Claude Code |
| Claude Code context window is full | Long sessions accumulate too many tokens | Run `/compact` to compress context. If still full, run `/end-working` to wrap up, then start a new session with `/start-working` to continue (plan.md ensures no context is lost) |
| Developer modified files they shouldn't have | File ownership directives were ignored | Team Lead rolls back the changes to that file, re-clarifies file ownership, and has the Developer redo the work. Add project-specific rules to CLAUDE.md to emphasize this |
| Merge conflicts (multiple Developers in parallel) | File ownership boundaries overlap, or shared files lack a clear modification order | Team Lead ensures file ownership does not overlap when splitting tasks. Assign shared file modifications to only one Developer, or define a clear order |
| Codex review returns empty results | Network issues or Codex service temporarily unavailable | Retry once. If it continues to fail, check `codex login status` — you may need to log in again |
| Codex remains unavailable | Codex service outage or account issue that cannot be resolved quickly | Team Lead escalates to the user: "Codex is unavailable." The user decides: continue development (skip Codex steps), wait for recovery, or handle otherwise |
| Not sure if install will break my config | Worried install.sh overwrites existing ~/.claude/ files | Run `./install.sh --dry-run` first — it shows exactly what would be installed or overwritten, without making any changes. All overwritten files are backed up; use `./install.sh --uninstall` to revert |
| Want to completely remove iSparto | Need to revert to pre-install state | Run `~/.isparto/install.sh --uninstall` — it restores backed-up files and removes everything iSparto created. npm packages (Claude Code, Codex CLI) are listed but not auto-removed since you may use them independently |
| Not sure if `/migrate` is safe for my project | Worried about unintended changes to an existing codebase | Run `/migrate --dry-run` first — it scans the project and shows the full migration plan without making any changes. Review the plan, then run `/migrate` when ready. A snapshot is automatically taken before any changes — run `/restore` to roll back |
| Want to undo `/migrate` or `/init-project` | Need to revert project-level changes made by iSparto | Run `/restore` in Claude Code — it lists available snapshots and walks you through restoration. Each `/migrate` and `/init-project` automatically creates a snapshot before making changes |
| `/start-working` finds code and docs out of sync | Documentation sync was incomplete during the last wrap-up | Have the Team Lead fix the inconsistencies first, then confirm before continuing development |
| Want to continue after stepping away briefly | Claude Code session is still active | Use `claude --continue` to resume the current session. If the session has expired, start a new session with `/start-working` |
| Agent Team teammates not visible | Not using iTerm2, or tmux integration is not enabled | Confirm you are running Claude Code in iTerm2; check that tmux integration is enabled in iTerm2 settings |
| Upgrade shows no changes / version not updated | Installed version is already the latest, or download failed | Run `~/.isparto/install.sh --upgrade` to re-check. Check `cat ~/.isparto/VERSION` to verify the installed version |
| Upgrade fails with checksum error | Downloaded file does not match the expected checksum | Re-run the upgrade command. If persistent, check your network connection or try `curl -fsSL .../bootstrap.sh \| bash` for a fresh install |
| session-log.md not created after /end-working | Using an older version of end-working.md that predates the session log feature | Run `~/.isparto/install.sh --upgrade` to update commands, then run `/end-working` again |
| /restore shows 'no snapshots found' | Snapshot script not installed, or operation was performed before the snapshot feature existed | Run `~/.isparto/install.sh --upgrade` to install the snapshot system. For operations done before the feature existed, use `git log` and `git checkout` to revert manually |
| Lead 直接写代码不被拦截 | 项目级 `.claude/settings.json` 缺少 Edit/Write matcher | 跑 `/migrate` 补全，或下次 `/start-working` 会自动校验补全 |
| 升级后旧项目 hooks 不生效 | 旧版 hooks 注册方式与当前分层架构不一致 | 跑 `~/.isparto/install.sh --upgrade` 更新用户级 Bash hook，再跑 `/start-working` 自动补全项目级工作流 hooks |
| 非 iSparto 项目被 Edit/Write hook 拦截 | 用户级错误注册了工作流 matcher（v0.6.3 遗留） | 跑 `~/.isparto/install.sh --upgrade`（新版自动清理用户级中的工作流 matcher） |
