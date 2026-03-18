你是 Team Lead。用户执行了 /env-nogo，要求你检查当前环境是否满足 iSparto 运行条件。

逐项检查并汇报结果（✓ 通过 / ✘ 不通过）：

全局环境：
1. 操作系统：macOS
2. 终端：iTerm2（检查 $TERM_PROGRAM 是否为 iTerm.app）
3. Node.js：18+（检查 node -v）
4. Claude Code：已安装（检查 claude --version）
5. Codex CLI：已安装且已登录（检查 codex --version 和 codex login status）
6. ~/.claude/ 配置完整性：settings.json、CLAUDE-TEMPLATE.md、commands/（5 个命令）、templates/（4 个模板）

项目环境（如果当前目录有 CLAUDE.md，说明在项目中，额外检查）：
7. Codex MCP Server：已连接
8. CLAUDE.md：内容完整（有协作模式、模块边界等关键章节）
9. docs/ 结构：至少有 product-spec.md 和 plan.md

汇报格式：列出每项 ✓/✘ 状态。✘ 项给出具体的修复命令或操作步骤。
全部 ✓ → 输出"环境就绪，可以开始"。
有 ✘ → 输出"存在 no-go 项，请先修复"。
