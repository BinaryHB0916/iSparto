# iSparto 产品规格

## 产品定位
iSparto 是一个开源的 AI Agent Team 工作流框架，把 Claude Code 单 Agent 变成一支有明确分工的团队。目标：让一个开发者拥有一支完整开发团队的产出能力。

## 目标用户
独立开发者（indie hacker / solo developer），有 Claude Max + ChatGPT 订阅，使用 macOS + iTerm2。

## 核心功能

### 免费版（开源核心工作流）
- **Agent Team 角色分工**: Team Lead 协调、Developer 写代码、Codex Reviewer 审查修复、Doc Engineer 文档同步
- **Wave 并行开发**: 一个 Wave 内多个 Developer 并行，tmux 分屏可视
- **7 个 Slash Commands**: /init-project, /migrate, /start-working, /end-working, /plan, /env-nogo, /restore
- **跨会话状态恢复**: plan.md 驱动，/start-working 自动恢复上下文
- **Codex 异源审查**: Codex 审 Claude 代码，覆盖不同模型的盲区
- **文档自动同步**: Doc Engineer 每个 Wave 审计代码和文档一致性
- **快照/恢复**: 每次操作前自动拍快照，/restore 一键回滚
- **Session log**: docs/session-log.md 记录每次会话的开发指标
- **版本追踪与更新日志**: --upgrade 支持版本升级
- **一键安装**: curl 一行命令搞定，支持 --dry-run 预览、--upgrade 升级、--uninstall 卸载

### Pro 版（付费，规划中）
- Real-time agent dashboard — agent 状态、进度、阻塞可视化
- Auto-retry & rollback — agent 失败自动重试/回滚
- Cost & token analytics — 每 wave 花费、预算告警
- Multi-project management — 多项目统一看板
- Wave history & replay — 回看每个 wave 的完整过程

## 技术约束
- 纯配置项目：Shell 脚本 + Markdown 模板 + MCP Server 注册
- 依赖 Claude Code Agent Team 模式（需 Claude Max $100/月）
- 依赖 Codex CLI（需 ChatGPT $20/月）
- 依赖 iTerm2 的 tmux 集成（macOS only）

## 竞品差异
其他 AI 编程工具（Cursor, Windsurf, Copilot, Claude Code 单会话）都是用户和单个 Agent 反复沟通。iSparto 把单个 Agent 变成一支有分工的团队，用户只对接 Lead，Lead 协调整个团队。
