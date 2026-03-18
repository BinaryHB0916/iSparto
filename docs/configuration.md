# 配置与适配

## 全局配置（settings.json）

```json
{
  "model": "opus",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  },
  "effortLevel": "max",
  "teammateMode": "tmux"
}
```

**注意：** `enabledPlugins` 不放在全局配置中，按项目需要在项目级 `.claude/settings.json` 中配置（如 iOS 项目加 swift-lsp，Web 项目加其他）。

**注意：** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 是实验性标记，截至 2026 年 3 月仍需手动开启。后续 Claude Code 版本可能将其设为默认行为，届时可移除此环境变量。

**⚠ 已知问题：** `effortLevel: "max"` 可能被 `/model` UI 静默降级（Claude Code GitHub issue 讨论中）。应对：
- settings.json + 环境变量双写（上面已配）
- 每次启动用 `claude --effort max` 三重保险
- 避免在会话中使用 `/model` 命令

---

## 文档命名规范

```
docs/
├── product-spec.md     ← 产品规格（页面、交互流程、功能边界、文案）
├── tech-spec.md        ← 技术规格（架构、数据模型、API 契约、状态管理、基础设施、第三方集成）
├── design-spec.md      ← 设计规格（色值、字体、间距、氛围元素、组件样式）
├── plan.md             ← 开发计划（Wave 编排、任务状态、人工介入点）
└── content/            ← 内容素材（如有）
```

所有规格文档统一 `-spec` 后缀：product-spec、tech-spec、design-spec。

### 文档职责边界

| 文件 | 管什么 | 一句话 |
|------|--------|--------|
| product-spec.md | 页面、交互流程、功能边界、文案 | **产品做什么** |
| tech-spec.md | 架构、数据模型、API 契约、状态管理、基础设施、第三方服务集成 | **技术上怎么建** |
| design-spec.md | 色值、字体、间距、动效、氛围元素 | **视觉上怎么看** |
| plan.md | Wave 编排、任务状态、遗留问题、人工介入点 | **当前做到哪** |

---

## 模板文件

项目初始化时使用的模板文件：

| 模板 | 用途 |
|------|------|
| `CLAUDE-TEMPLATE.md`（根目录） | 项目 CLAUDE.md 的生成模板 |
| `templates/product-spec-template.md` | 产品规格文档模板 |
| `templates/tech-spec-template.md` | 技术规格文档模板（可选） |
| `templates/design-spec-template.md` | 设计规格文档模板（可选） |
| `templates/plan-template.md` | 开发计划文档模板 |

---

## 适配指南

> 本项目是通用模板。以下说明哪些部分可以直接用，哪些需要根据你的项目修改。

### 直接用，不用改

| 内容 | 说明 |
|------|------|
| 5 个自定义命令 | `/start-working`、`/end-working`、`/plan`、`/init-project`、`/env-nogo` 通用于所有项目 |
| 角色定义 | Lead、Developer、Codex Reviewer、Doc Engineer 的职责和规则 |
| 触发条件表 | 代码审查 + QA 冒烟测试的触发逻辑 |
| 分支策略 | main / feat / fix / hotfix 的分支模型 |
| 授权与上报机制 | Lead 的决策边界 |
| 文档同步规则 | 代码改了文档必须跟 |
| settings.json | 全局配置直接复制 |

### 必须根据项目修改

| 内容 | 怎么改 |
|------|--------|
| CLAUDE.md 的项目概述 | `/init-project` 时自动生成，填写你的产品描述 |
| 技术栈 | 根据项目实际语言/框架/平台填写 |
| 常用命令 | 替换为你的构建/运行/测试命令 |
| 模块边界 | 根据项目目录结构填写 |
| 项目级插件 | iOS 加 swift-lsp，Web 加其他，在项目级 `.claude/settings.json` 配置 |

### 可选启用

| 内容 | 什么时候启用 |
|------|-------------|
| tech-spec.md | 有后端/云函数/复杂架构时创建，纯前端简单项目可跳过 |
| design-spec.md | 有 UI 的项目创建，纯后端/CLI 工具可跳过 |
| content/ 目录 | 项目有内容素材（故事脚本、文案等）时创建 |
| Memory 边界定义 | 使用 Claude.ai 网页版讨论产品时参考 |
| 多设备同步 | 在多台电脑之间切换开发时配置 |

---

## Memory 边界定义（可选，适用于 Claude.ai 用户）

> 如果你使用 Claude.ai（网页版）讨论产品方向和技术决策，可以利用 Claude 的 Memory 功能记住跨项目的长期信息。以下是建议的存储边界——什么放 Memory，什么放项目文档。

### 存入 Memory

| 层级 | 内容 | 变化频率 |
|------|------|----------|
| 身份信息 | 个人背景、公司结构、法律实体 | 几乎不变 |
| 偏好配置 | 沟通风格、工具偏好、工作习惯 | 偶尔变 |
| 品牌架构 | 品牌层级、平台 ID、命名规范 | 很少变 |
| 技术栈快照 | 当前工具链和配置 | 工具更换时 |
| 里程碑记录 | 产品和公司关键节点 | 每个里程碑 |
| 决策原则 | 决策框架和红线 | 很少变 |
| 已知失败模式 | 认知偏差和易犯错误 | 积累新的 |

### 不存入 Memory

| 类别 | 原因 |
|------|------|
| Wave/Team 级别进度 | 粒度太细，由 plan.md 承载 |
| 具体代码改动 | 属于项目文档 |
| 临时讨论 | 无结论的探讨 |
| 敏感凭证 | 安全风险 |

---

## 多设备同步（可选）

如果你在多台电脑之间切换开发，可以通过云同步服务 + symlink 共享用户级配置。

### 需要同步的文件

```
~/.claude/
├── settings.json          ← 全局配置
├── CLAUDE-TEMPLATE.md     ← 新项目模板
├── commands/
│   ├── start-working.md
│   ├── end-working.md
│   ├── plan.md
│   ├── init-project.md
│   └── env-nogo.md
└── templates/
    ├── product-spec-template.md
    ├── tech-spec-template.md
    ├── design-spec-template.md
    └── plan-template.md
```

### 不需要同步的

运行时数据（`~/.claude/` 下的 history、cache、debug 等）各设备独立，不同步。

### 参考方案

**macOS（iCloud Drive）：** 把上述文件放到 iCloud Drive 目录，用 symlink 映射回 `~/.claude/`。

**跨平台（Git 仓库）：** 单独建一个 `claude-config` 仓库，clone 到各设备后 symlink。

**原理：** Claude Code 启动时读取 `~/.claude/` 下的配置。只要该路径指向同步目录的 symlink，多台电脑就能共享配置。
