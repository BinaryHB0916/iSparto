# iSparto 产品规格

## 产品定位
iSparto 是一个 AI Agent Team 工作流框架，把 Claude Code 单 Agent 变成一支有明确分工的开发团队。

**一句话愿景：** 让每个人都有一支自己的技术团队——像 CEO 一样说需求、看进度、收交付，不碰代码不碰终端。

**当前阶段：** 开源核心工作流已发布，以开发者工具形态服务独立开发者，dogfooding 验证中。

## 产品演进

iSparto 的演进分三个阶段，每个阶段服务不同用户角色：

```
v0.x  开发者工具      用户 = 开发者，手动触发流程
  ↓
v1.x  自治开发团队    用户 = 技术负责人，给任务，团队自己跑完全流程
  ↓
v2.x  CEO 工作台      用户 = 老板，说需求看结果，不碰过程
```

### v0.x — 开发者工具（当前）
把 Claude Code 的能力从单 agent 扩展为结构化团队。用户仍然是开发者，理解 git/分支/review 流程，通过 slash commands 触发工作流。核心价值：**一个人拥有一支团队的产出能力**。

### v1.x — 自治开发团队
用户不再需要手动驱动每个流程节点。说"做这个功能"，团队自己跑完 plan → code → review → test → merge。用户角色从"开发者"变成"技术负责人"，关注方向和验收，不关注过程。核心价值：**全流程自治，用户只管输入需求和验收结果**。

### v2.x — CEO 工作台
用户用自然语言描述业务需求，团队自己翻译成技术任务、执行、汇报进度、交付可运行的 demo。用户不需要任何技术背景。核心价值：**自然语言驱动的技术团队接口**。

## 目标用户

| 阶段 | 用户画像 | 核心场景 |
|------|---------|---------|
| v0.x | 独立开发者（indie hacker），熟悉 Claude Code + Git | 用 slash commands 驱动团队并行开发 |
| v1.x | 技术负责人 / 全栈创业者 | 给任务看结果，不用盯过程 |
| v2.x | 非技术创业者 / CEO / 产品经理 | 用自然语言管理一支 AI 开发团队 |

## 核心功能

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

## 技术约束
- 纯配置项目：Shell 脚本 + Markdown 模板 + MCP Server 注册
- 依赖 Claude Code Agent Team 模式（需 Claude Max $100/月）
- 依赖 Codex CLI（需 ChatGPT $20/月）
- 依赖 iTerm2 的 tmux 集成（macOS only）

## 竞品差异
其他 AI 编程工具（Cursor, Windsurf, Copilot, Claude Code 单会话）都是用户和单个 Agent 反复沟通。iSparto 把单个 Agent 变成一支有分工的团队，用户只对接 Lead，Lead 协调整个团队。

## 三层能力模型

实现产品演进需要逐层构建三个能力：

### 第一层：流程自治（v0.x → v1.x 的桥梁）
团队能自己跑完 plan → code → review → test → merge 全流程，不需要用户在中间审批。

- v0.x 已实现：Solo + Codex 模式、auto PR merge、end-working 全自动
- 缺口：跨 session 任务续接、多任务并行管理、失败自动重试与回滚

### 第二层：状态可见性（v1.x 的核心）
用户不写代码，但需要知道团队在干嘛、进展如何、有没有卡住。

- 进度摘要 — 每个任务的状态、完成度、阻塞项，用人话汇报
- Demo 预览 — 自动部署 preview 环境 + 截图 + 一句话说明变化
- 风险预警 — 主动上报复杂度超预期、依赖问题、技术风险
- Agent dashboard — 任务看板，可视化团队工作状态
- Cost & token analytics — 用量统计，帮用户理解投入产出

### 第三层：需求理解（v2.x 的核心）
用户说业务语言，团队自己翻译成技术任务。

- 需求拆解 — 业务需求 → 技术 task → 优先级排序
- 方案决策 — 团队提出技术方案，用户只确认方向
- 交付验收 — 可运行 demo + 变更说明，用户体验后给反馈
