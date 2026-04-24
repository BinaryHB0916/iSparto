# iSparto 中文快速上手

iSparto 把 Claude Code 从单 Agent 变成一个开发团队——Lead 负责组织提示词，Developer (Codex) 负责实现代码，Teammates 负责并行协作，Doc Engineer 负责同步文档。你指挥团队，而不是对着单个 Agent 反复拉扯。

> 本文是中文用户快速上手入口，只覆盖安装和日常使用。深入的角色定义、工作流细节、故障排查、设计决策都在英文参考文档中（见文末说明）。

## 系统要求

| 项 | 要求 | 说明 |
|----|------|------|
| 平台 | macOS | Agent Team 模式需要 iTerm2 + tmux 3.x（下一行详见） |
| tmux | 3.x,v0.8.0 起硬性依赖 | Independent Reviewer 通过 `codex exec` 在 tmux pane 内启动;用 `brew install tmux` 安装 |
| Claude Max 订阅 | $100/月 | Claude Code + Auto 模式（Solo + Codex / Agent Team）|
| ChatGPT 订阅 | $20/月 | Codex CLI 同时给两个角色用:Developer(实现 + QA)和 Independent Reviewer(`codex exec` 在 tmux pane 内,跨厂商盲审) |
| Node.js | 18+ | 运行 Claude Code、Codex CLI 和 MCP Server |
| Git | 任意版本 | 版本控制 |
| 终端 | iTerm2 | Agent Team 用 iTerm2 做多 tmux pane 容器;tmux 本身单独安装(见上一行)|

合计月成本 $120，两个顶级模型（Claude Opus + Codex），没有额外的 API 费用。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash
```

一条命令搞定所有事情：从 GitHub Releases 下载校验过的安装器，检查/安装 Claude Code 和 Codex CLI，登录 Codex，把命令和模板复制到 `~/.claude/`，注册全局 MCP Server。你已有的 `~/.claude/settings.json` 不会被覆盖。安装前会自动创建一份快照，随时可以回滚。

**预览（不改动任何文件）：**

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash -s -- --dry-run
```

**升级：**

```bash
~/.isparto/install.sh --upgrade
```

**卸载：** 从快照完整恢复到安装前的状态，无需联网。

```bash
~/.isparto/install.sh --uninstall
```

## 第一次使用

装好以后进入一个项目目录，打开 Claude Code，根据项目情况选一条路径：

> 可选但推荐(尤其第一次在新机器上):先跑 `/env-nogo` 检查 iSparto 运行时全局 + 项目环境是否达标(对可自动修复的项会尝试自动修,例如缺的 npm 包,报告里会标成 `auto-fixed`),再跑 `/doctor` 看本地 iSparto 安装健康报告(tmux / Codex CLI / Claude CLI / hook 完整性 / repo 标记 / Codex config / VERSION ↔ git tag 一致性 七项离线检查,不改任何文件)。

**新建项目（全新）：**

```
/init-project
```

Lead 会引导你填写产品定位、技术栈、模块划分，然后生成 `CLAUDE.md` + `docs/` 骨架（product-spec、tech-spec、plan 等）。整个过程大约 10-20 分钟，结束后你就有了一个 iSparto 标准结构的项目。

**迁移已有项目：**

```
/migrate
```

Lead 会读你现有的代码和文档，推断项目定位，然后把 iSparto 框架叠加上去——保留原有工作产物，只补充 `CLAUDE.md` 和 `docs/` 缺失的部分。

> 如果 `/init-project` 或 `/migrate` 的结果不理想，跑 `/restore` 可以回滚到命令执行之前的状态。

## 日常工作流

每次坐下来开始工作：

```
/start-working
```

Lead 会读 `docs/plan.md` 汇报当前 Wave 状态、未完成任务、上次会话的问题记录，然后建议下一步。你批准或调整后，Lead 开始执行。

工作完成后：

```
/end-working
```

Lead 自动跑完 /end-working 的标准流程：Process Observer 审计（Step 5）→ 安全扫描 → commit → push → Doc Engineer pre-merge gate（Step 9）→ 创建 PR 并合并 → 输出简报。如果还在 Wave 中途，只推送不合并。

两个命令中间的时间里，你照常和 Lead 对话：提问、给任务、纠正方向。Lead 负责把你的意图拆成 Developer（Codex）能执行的结构化提示词，Developer 实现，Lead 审查输出，Teammate 在可以并行的时候分头执行。

有新需求时跑 `/plan`，Lead 先给出方案再等你确认，方案 approved 后才进 Wave。怀疑环境有问题随时可以跑 `/doctor`（本地离线，不改任何文件）。

## 遇到问题怎么办

**安装失败 / 命令不存在 / Codex 登录异常 / MCP Server 注册失败**——先看英文版故障排查文档：

- [docs/troubleshooting.md](../troubleshooting.md) — 常见问题和恢复路径

如果文档没覆盖你遇到的情况，欢迎到 GitHub 提 Issue：<https://github.com/BinaryHB0916/iSparto/issues>

## 深入文档（全部英文）

这份快速上手只是入口，iSparto 的完整参考文档都是英文的——这是 iSparto 的刻意选择（见 [CLAUDE.md > Documentation Language Convention](../../CLAUDE.md#documentation-language-convention)）。简单来说：

- **系统提示和参考文档**（Tier 1 + Tier 2）：英文，因为 AI Agent 把它们当指令读，英文能保证指令跟随的稳定性，也让不懂中文的开源贡献者能参与审查。
- **用户入口**（Tier 3，本文件 + `README.zh-CN.md` + `CONTRIBUTING.md`）：双语并行，给中英文用户都提供第一层入口。
- **历史记录**（Tier 4）：冻结不再修改。

所以如果你想深入了解 iSparto 的角色分工、开发流程、配置项、设计决策，请直接看英文版：

- [README.md](../../README.md) — 项目总览
- [docs/concepts.md](../concepts.md) — 核心概念
- [docs/roles.md](../roles.md) — 角色定义（Lead / Teammate / Developer / Doc Engineer / Process Observer / Independent Reviewer）
- [docs/workflow.md](../workflow.md) — 完整开发工作流
- [docs/configuration.md](../configuration.md) — 配置指南
- [docs/user-guide.md](../user-guide.md) — 用户手册
- [docs/troubleshooting.md](../troubleshooting.md) — 故障排查
- [docs/process-observer.md](../process-observer.md) — Process Observer 介绍
- [docs/security.md](../security.md) — 安全审计系统
- [docs/design-decisions.md](../design-decisions.md) — 设计决策记录

两条补充：

- iSparto 的所有 TODO / 延后项 / 规则修正建议都登记在 [docs/plan.md](../plan.md) 的 Backlog（Framework Rule Polish / Deferred to v0.8+ / External Direction 三类表格）。plan.md 是"现在在做什么 + 还需要做什么"，[docs/session-log.md](../session-log.md) 是历史执行记录，两者分工严格。
- 完整命令列表（包括本文未覆盖的 `/security-audit` 和 `/release`）见 [docs/user-guide.md](../user-guide.md)。

如果看英文文档时有具体翻译需求或者看不懂某段，欢迎开 Issue 说明具体哪一段，我会考虑后续是否需要增加针对性的中文说明。
