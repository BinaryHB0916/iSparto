# 常见问题排查

| 问题 | 原因 | 解决 |
|------|------|------|
| Codex MCP 状态显示 ✘ failed | MCP Server 命令写错，或 Codex CLI 未安装/未登录 | 确认 `codex --version` 和 `codex login status` 正常，然后 `claude mcp remove codex-reviewer -s project && claude mcp add codex-reviewer -s project -- npx -y codex-mcp-server`，重启 Claude Code |
| Claude Code 上下文窗口满了 | 长会话积累太多 token | 执行 `/compact` 压缩上下文。如果仍然满，`/end-working` 收工后开新会话 `/start-working` 继续（plan.md 保证上下文不丢） |
| Developer 改了不该改的文件 | 文件所有权指令被忽略 | Lead 发现后回滚该文件的改动，重新明确文件所有权后让 Developer 重做。在 CLAUDE.md 里加项目特有规则强调 |
| merge 冲突（多 Developer 并行） | 文件所有权划分有重叠，或共享文件没有明确修改顺序 | Lead 拆任务时确保文件所有权不重叠。共享文件的修改只分配给一个 Developer，或明确顺序 |
| Codex 审查返回空结果 | 网络问题或 Codex 服务临时不可用 | 重试一次。如果持续失败，检查 `codex login status`，可能需要重新登录 |
| `/start-working` 发现代码和文档不一致 | 上次收工时文档同步不完整 | 先让 Lead 修复不一致，确认后再继续开发 |
| 短暂离开后想继续 | Claude Code 会话还在 | `claude --continue` 接回当前会话。如果会话已过期，开新会话 `/start-working` |
| Agent Team teammate 不可见 | 未使用 iTerm2，或 tmux 集成未启用 | 确认在 iTerm2 中运行 Claude Code；检查 iTerm2 设置中 tmux 集成是否开启 |
