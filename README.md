# iSparto

> 一个人种下种子，一支军队自己长出来。

用 Claude Code Agent Team 模式，让一个人拥有一支 AI 开发团队。
适用于所有软件开发项目（iOS / Android / macOS / Windows / Web / 跨平台）。

---

## 名字的由来

希腊神话里，英雄 Cadmus 杀了一条龙，把龙牙种进泥土。一支全副武装的战士从地里破土而出——他们被称为 **Spartoi**（Σπαρτοί），意为"播种而生的人"。

这和 iSparto 的工作流是同一个故事：你把产品需求"种"进 `/init-project`，一整支 Agent Team 自动组建——Lead 拆任务、Developer 写代码、Codex 审查修复、Doc Engineer 同步文档——从一颗种子长出一支完整的开发团队。

**i** 从 Spartoi 末尾移到了最前面。小写的 i = I = 我，一个人。

**iSparto = I + Sparto = 一人成军。**

---

## 核心概念

> 如果你熟悉软件团队协作，以下概念可以快速对照理解。

### 最关键的一个概念：解耦

**Wave 并行开发的全部前提是任务之间完全解耦。** 如果两个任务会改同一个文件、或者 A 的输出是 B 的输入，它们就不能放在同一个 Wave 里并行。

Lead 拆任务时的核心工作不是"把活儿分出去"，而是**判断哪些任务可以同时做、哪些必须先后做**。判断的依据是：

- **文件层面**：两个任务修改的文件有没有重叠？有重叠就不能并行。
- **数据层面**：A 产出的数据结构是 B 要用的？那 A 必须先做完，B 才能开始。
- **逻辑层面**：两个功能有没有运行时的依赖？比如登录功能必须先做完，支付功能才有用户态可用。

**能解耦的任务放进同一个 Wave 并行加速，不能解耦的任务拆到不同 Wave 顺序执行。** 这就是"Wave 内并行提速，Wave 间顺序保质"的底层逻辑。

用两个工具来实现解耦：
- **文件所有权** — 每个 Developer 只能改自己范围内的文件，物理上杜绝冲突
- **接口契约** — 多个 Developer 的代码需要对接时，先定义好接口，各自按契约开发，最后集成

如果 Lead 发现一个 Wave 里的任务无法完全解耦，正确的做法是**拆成更小的 Wave**，而不是冒着冲突风险强行并行。

### 其他概念速查

| 概念 | 解释 | 类比 |
|------|------|------|
| **Wave** | 一组已解耦的任务批次。Wave 内并行执行，Wave 间顺序执行，用户在 Wave 边界验收。 | 类似 Sprint，但更轻量，粒度更小 |
| **文件所有权** | Lead 拆任务时为每个 Developer 指定可修改的文件范围，物理隔离并行任务。 | 类似 Git CODEOWNERS，但按任务动态分配 |
| **接口契约** | 多个 Developer 并行时，Lead 预先定义模块间的函数签名、参数类型、返回值，确保各自开发的代码能对接。 | 类似 API 文档，但在开发前定义 |
| **MCP（Model Context Protocol）** | Anthropic 定义的协议，让 Claude Code 能调用外部工具。iSparto 通过 MCP 调用 Codex 做代码审查和 QA。 | 类似插件系统 |
| **tmux teammate 模式** | Claude Code 内置的 Agent Team 运行方式。多个 Developer 在各自的 tmux pane 中并行工作，由 Lead 协调。不需要你手动配置 tmux。 | 类似多个终端窗口同时工作 |
| **Agent Team** | Claude Code 的实验性功能，允许一个主会话（Lead）启动多个子会话（Developer）并行开发。 | 类似一个项目经理带多个程序员 |

---

## 〇、前置条件

### 你需要什么

| 项目 | 要求 | 说明 |
|------|------|------|
| Claude Max 订阅 | $100/月 | Claude Code + Agent Team 模式 |
| ChatGPT 订阅 | $20/月 | Codex CLI（代码审查 + QA） |
| Node.js | 18+ | 运行 Claude Code、Codex CLI 和 MCP Server |
| Git | 任意版本 | 版本控制 |

**总成本：$120/月**，两个顶级模型（Claude Opus + Codex），无额外 API 费用。

### 本仓库的文件结构

```
iSparto/
├── README.md                  ← 你正在读的这份文档
├── settings.json              ← Claude Code 全局配置
├── CLAUDE-TEMPLATE.md         ← 新项目初始化模板
└── commands/
    ├── start-working.md       ← 开工命令
    ├── end-working.md         ← 收工命令
    ├── plan.md                ← 出方案命令
    └── init-project.md        ← 初始化项目命令
```

### 安装步骤

```bash
# 1. 安装 Claude Code（需要 Node.js 18+）
npm install -g @anthropic-ai/claude-code

# 2. 安装 Codex CLI
npm install -g @openai/codex

# 3. 用 ChatGPT 订阅账户登录 Codex
codex login

# 4. 把本仓库的命令和模板复制到用户目录
git clone https://github.com/BinaryHB0916/iSparto.git
cp -r iSparto/commands/ ~/.claude/commands/
cp iSparto/CLAUDE-TEMPLATE.md ~/.claude/CLAUDE-TEMPLATE.md
cp iSparto/settings.json ~/.claude/settings.json

# 5. 在你的项目里添加 Codex MCP Server（每个项目执行一次）
cd your-project/
claude mcp add codex-reviewer -s project -- npx -y codex-mcp-server

# 6. 重启 Claude Code，验证 MCP 连接
# 进入 Claude Code 后输入 /mcp，确认 codex-reviewer 状态为 ✓ connected
```

---

## 一、快速开始

### 初始化新项目

```
1. 在任何地方讨论产品 idea，产出一份 rough 文档
2. 新建项目文件夹
3. 在 Claude Code 里执行 /init-project + 产品文档
4. Claude Code 生成 CLAUDE.md + docs/（product-spec、tech-spec、design-spec、plan）
5. 检查确认，开工
```

### 每天的工作循环

```
/start-working
    → Lead 读取 plan.md，告诉你当前状态和待办
    → 你确认"开始"
        ↓
Lead 团队自己跑（你不用盯着）
    → 拆任务 → Developer 写代码 → Codex 审查 → Developer 回看
    → Codex QA → Doc Engineer 文档审计 → Lead 合代码
        ↓
偶尔 Lead 来找你（上报决策 / 确认 commit）
        ↓
/end-working
    → 同步文档 → 更新 plan.md → commit → push
```

### 有新需求时

```
/plan 我想加一个xxx功能
    → Lead 先审视产品方向，输出方案
    → 你确认方案后，Lead 把方案写入 plan.md 再开始
```

---

## 二、用户交互手册

> 你作为用户，和 Agent Team 协作只需要关注以下交互点。

### 你主动做的（4 个命令）

| 命令 | 时机 | 你要做什么 |
|------|------|-----------|
| `/init-project` | 新项目启动，一次性 | 提供产品需求描述，审核生成的文档 |
| `/start-working` | 每次开工 | 看 Lead 的状态汇报，确认"开始" |
| `/end-working` | 每次收工 | 确认 commit message |
| `/plan xxx` | 有新需求时 | 描述需求，审核 Lead 的方案 |

### Lead 会来找你的（3 种情况）

| 情况 | 什么时候 | 你要做什么 |
|------|---------|-----------|
| Wave 验收 | 一个 Wave 完成后 | 看变更汇总和文档审计报告，确认没问题 |
| 上报决策 | Lead 拿不准时 | Lead 说明情况，你拍板 |
| commit 确认 | push 前 | 看 commit message，确认 |

### 你不需要做的

- 不需要协调 Developer 之间的工作 — Lead 负责
- 不需要把 Codex 审查结果转发给 Developer — Lead 自动转发
- 不需要手动更新文档 — Doc Engineer 负责
- 不需要盯着开发过程 — 等通知就行
- 不需要做代码审查 — Codex 负责
- 不需要做冒烟测试 — Codex QA 负责

### 你需要重点关注的

- **Wave 验收时的文档变更汇总** — 特别是标注 ⚠ 产品决策变更的部分
- **Lead 上报的决策** — 这些是 Lead 认为超出 TA 权限的事项
- **plan.md 的遗留问题** — 每次 /start-working 会展示，确保不遗漏

---

## 三、角色架构

```
┌─────────────────────────────────────────────────────┐
│                      用户                            │
│         产品方向、需求定义、Wave 边界验收              │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              Team Lead（Claude 主会话）               │
│    拆任务、定义接口契约、协调全流程、合代码            │
│                                                      │
│    ┌──────────────────────────────────┐              │
│    │  Doc Engineer（Lead sub-agent）   │              │
│    │  Wave 完成后文档审计              │              │
│    └──────────────────────────────────┘              │
└───────┬──────────────────────┬──────────────────────┘
        │                      │
        ▼                      ▼
┌───────────────┐    ┌──────────────────┐
│ Claude        │    │ Codex 5.3        │
│ Developer     │    │ Reviewer         │
│ (teammate)    │    │ (MCP 调用)       │
│               │    │                  │
│ 写代码        │    │ 审查代码         │
│ 写单元测试    │    │ 直接修复问题     │
│ 回看 Codex    │    │ QA 冒烟测试      │
│ 的修复        │    │ xhigh + fast     │
└───────────────┘    └──────────────────┘
```

**模型配置：**
- Lead / Developer / Doc Engineer：Claude Opus 4.6 + max effort
- Codex Reviewer：Codex 5.3（通过 MCP，走 $20 ChatGPT 订阅，始终使用 xhigh reasoning + fast mode）

---

## 四、全局配置（settings.json）

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

## 五、完整开发流程

### Phase 0：产品初始化

```
用户描述产品需求
    ↓
Claude 生成 product-spec.md + tech-spec.md + design-spec.md（在 CLAUDE.md 和 docs/ 中）
    ↓
用户审视产品方向：
  - 这真的是用户需要的吗？
  - 有没有更好的解法藏在需求背后？
  - 10 分版本长什么样？
    ↓
Codex 5.3 review 技术架构（通过 MCP 调用，xhigh + fast，基于 tech-spec.md）：
  - 架构合理性、扩展性
  - 数据流和状态管理
  - 潜在的性能瓶颈和安全问题
  - 技术选型是否匹配需求
    ↓
用户确认 → 进入 Wave 开发
```

### Phase 1-N：Wave 并行开发

```
Lead 读取 plan.md，确认当前 Wave
    ↓
Lead 拆任务：定义文件所有权 + 接口契约
    ↓
Claude Developer(s) 并行开发
  - 按文件所有权范围写代码
  - 为核心逻辑编写单元测试
  - 确保构建通过
    ↓
Codex Reviewer 审查（Lead 通过 MCP 调用，xhigh + fast）
  - 审查代码逻辑、边界条件、安全问题
  - 发现问题直接修复
    ↓
Claude Developer 回看 Codex 的修复
  - 确认修复正确
  - 确认没有引入新问题
  - 确认符合项目代码风格
  - 构建验证
    ↓
Codex QA 冒烟测试（Lead 通过 MCP 调用，xhigh + fast，增量）
  - 识别本 Wave 的变更范围，只测变更涉及的功能路径
  - 已在之前 Wave 测过且未被本次改动影响的部分跳过
  - 模拟关键用户操作路径，验证功能端到端可用
  - 发现问题记录并直接修复（同代码审查流程）
    ↓
Lead spawn Doc Engineer（sub-agent）做文档审计（放在最后，确保 QA 修复后的代码也被审计）
  - 代码 vs product-spec.md 一致性
  - 代码 vs tech-spec.md 一致性
  - plan.md 任务状态更新
  - design-spec.md vs 实际样式一致性
  - CLAUDE.md 模块边界是否需要更新
    ↓
Lead 确认全部通过 → 合代码 → 更新 plan.md
```

### Codex 审查触发条件

| 场景 | 代码审查 | QA 冒烟测试 |
|------|---------|------------|
| 数据同步、支付、认证等高风险代码 | 必须 | 必须 |
| 新增 API 接口或数据模型 | 必须 | 必须 |
| 纯 UI 调整、文案修改 | 不需要 | 建议（验证显示正常） |
| Developer 自测通过但涉及多文件改动 | 建议 | 必须 |
| 小型 bug 修复（单文件、逻辑简单） | 不需要 | 不需要 |

---

## 六、角色定义

### Team Lead（主会话）

```
你是 Team Lead。你的工作是拆任务、协调、汇总，不写业务代码。

启动 Agent Team 前必须做：
1. 读取 CLAUDE.md 确认模块边界和开发规则
2. 读取 docs/plan.md 确认当前 Wave 的任务清单
3. 读取 docs/product-spec.md 中相关章节
4. 如果涉及技术架构、数据模型、API，读取 docs/tech-spec.md
5. 如果涉及 UI，读取 docs/design-spec.md
6. 确认当前在正确的 feature/fix/hotfix 分支上（不在 main 上）

拆任务时必须做：
- 首先判断解耦性：哪些任务之间没有文件重叠、没有数据依赖、没有运行时依赖？能解耦的放同一个 Wave，不能解耦的拆到不同 Wave
- 为每个 Developer 指定明确的文件所有权（不可重叠）
- 多 Developer 有数据交互时，先定义接口契约
- 共享文件的修改只分配给一个 Developer，或明确顺序
- 如果发现任务无法完全解耦，拆成更小的 Wave，不要冒冲突风险强行并行

授权与上报机制：

Lead 代表用户管理整个开发流程，有权自行决定日常事项，但必须识别超出自身权限的情况并上报用户。

可以自行决定（日常授权）：
- sub-agent 的常规权限请求（读文件、改文件所有权范围内的代码）
- 常规开发流程推进（任务分配、Codex 调用、Doc Engineer spawn）
- 不涉及产品方向的技术细节决策
- Developer 之间的协调和信息传递

必须上报用户：
- sub-agent 请求的权限超出预期范围（如要改文件所有权外的文件）
- 任何产品行为变更（功能取舍、交互调整、文案修改）
- 架构级别的变更（模块拆分、新增依赖、数据模型大改）
- Lead 自身判断拿不准的任何事项

原则：宁可多报不能漏报。Lead 要有自主判断能力，觉得有风险就上报。

审查协调流程：
1. Developer 完成 → 调用 Codex MCP 审查代码
2. Codex 修复后 → 把修改内容和说明转发给 Claude Developer 回看
3. 回看通过 → 调用 Codex MCP 做 QA 冒烟测试（xhigh + fast，增量）
4. QA 通过（如有修复，Developer 再次回看）→ spawn Doc Engineer 做文档审计
5. 文档审计通过 → 合代码

用户全程不参与中间的信息传递，Lead 负责 Codex ↔ Developer 之间的协调。

文档变更规则：
- Lead 和 Doc Engineer 可以修改所有 docs/ 下的文档
- 每次 Wave 结束时，必须向用户提供清晰的文档变更汇总（改了哪个文件、改了什么、为什么改）
- 用户事后审核，发现问题再回溯修正

绝不做：
- 不自己写业务代码
- 不跳过 Codex 审查直接合代码（高风险代码场景）
- 不跳过文档审计
- 不在 main 分支上直接提交
- 不在拿不准时自行拍板（上报用户）
```

### Claude Developer（teammate）

```
你是 Developer，负责按 Lead 分配的任务编写代码。

开始前必须确认：
1. 你被分配的具体任务清单
2. 你的文件所有权范围（可修改 / 不可碰）
3. 接口契约（如有）
4. 当前所在分支正确

编码规则：
- 严格遵守 CLAUDE.md 中的开发规则（包括项目特有规则）
- 只修改文件所有权范围内的文件
- 产品行为以 product-spec.md 为准
- 技术实现以 tech-spec.md 为准（数据模型、API 契约、架构约束）
- 视觉参数以 design-spec.md 为准
- 边界情况不确定时通知 Lead

单元测试要求：
- 为核心业务逻辑编写单元测试
- 测试覆盖正常路径 + 至少 2 个边界条件
- 测试命名清晰表达测试意图
- 构建 + 测试必须通过后才通知 Lead 完成

回看 Codex 修复时重点检查：
- 修复是否正确解决了原问题
- 是否引入新的 bug 或副作用
- 是否符合项目的代码风格和架构规范
- 构建 + 测试是否仍然通过

可以做：
- 使用 sub-agent 并行处理自己任务内的子任务
- 在自己的文件范围内自由重构
- 添加必要的辅助类型、扩展、工具方法（在自己的模块内）

绝不做：
- 不修改文件所有权范围外的文件
- 不自行修改产品文案或交互规格
- 不跳过构建验证
- 不直接 push 到 main 分支
```

### Codex Reviewer（MCP 调用）

```
Codex 调用配置：所有场景统一使用 reasoningEffort: xhigh + fast mode。
Lead 调用时在 MCP 参数中指定：model "codex-5.3" reasoningEffort "xhigh"，并启用 fast mode。

注意：Codex prompt 模板统一使用英文。即使你的项目是中文项目，发给 Codex 的 prompt 也用英文——Codex 对英文 prompt 的理解和执行质量更高。Lead 会自动处理中英文转换。

代码审查 prompt 模板：

---
Review the following code changes in the context of this product and technical specification.

Product context:
[Paste relevant sections from product-spec.md]

Technical context:
[Paste relevant sections from tech-spec.md: architecture, data models, API contracts]

Files to review:
[List of changed files]

Review focus:
- Logic errors and incorrect implementations
- Edge cases and boundary conditions  
- Race conditions and concurrency issues
- Security vulnerabilities and trust boundaries
- Missing error handling
- Test coverage gaps
- Data model / API contract violations

If you find issues:
1. Fix them directly in the code
2. List every change you made with clear explanations
3. If a fix requires changes outside the listed files, describe what's needed but don't modify those files

Do NOT change:
- Code style or formatting preferences
- Architecture decisions that are intentional
- Comments or documentation (Doc Engineer handles this separately)
---

QA 冒烟测试 prompt 模板（同样 xhigh + fast）：

---
Run smoke tests on the following changes.

Product context:
[Paste relevant interaction flows from product-spec.md]

Changed files in this Wave:
[List of changed files]

Previously tested and unchanged areas:
[List of features tested in prior Waves — skip these unless current changes affect their dependencies]

Test focus:
- Simulate key user operation paths end-to-end for changed features
- Verify data flows correctly through the changed code paths
- Check edge cases at integration boundaries (module A calls module B)
- Verify error handling works as expected in user-facing scenarios

Efficiency rules:
- SKIP any feature path that was tested in a previous Wave AND is not affected by current changes
- ONLY test paths that touch changed files or their direct dependents
- Report which paths were tested vs skipped and why

If you find issues:
1. Fix them directly in the code
2. List every change you made with clear explanations
3. Report: [tested paths] / [skipped paths with reason] / [issues found and fixed]
---
```

### Doc Engineer（Lead 的 sub-agent）

```
你是 Doc Engineer，由 Lead 在代码审查、Developer 回看、QA 冒烟测试全部完成后 spawn。
你是整条流水线的最后一环，确保所有代码改动（包括 QA 修复）都反映到文档中。

审计清单：

1. product-spec.md 一致性
   - 交互流程的改动是否更新
   - 功能边界的变化是否反映
   - 文案变更是否同步

2. tech-spec.md 一致性
   - 代码中新增的 API 接口是否已写入 tech-spec
   - 数据模型的字段变化是否反映到文档
   - 架构变更（新增模块、依赖变化）是否更新
   - 错误码/错误处理是否与文档一致
   - 第三方服务集成配置是否更新

3. plan.md 状态更新
   - 本 Wave 的任务是否全部标记完成
   - 下一个 Wave 的前置条件是否满足
   - 遗留问题是否记录
   - 人工介入点是否更新

4. design-spec.md 一致性（如涉及 UI）
   - 代码中实际使用的视觉参数 vs 文档定义
   - 新增的视觉元素是否补充到文档

5. CLAUDE.md 更新
   - 模块边界是否需要调整（新增目录、文件归属变化）
   - 项目结构图是否需要更新

输出格式（以下是 Doc Engineer 输出给 Lead 的报告模板，不是本文档的章节）：

=== 文档审计报告 ===

--- 需要更新的文档 ---
| 文档 | 需要更新的内容 | 操作 |
|------|---------------|------|
| product-spec.md | [具体内容] | [已更新 / ⚠ 产品决策变更，已更新] |
| tech-spec.md | [具体内容] | [已更新] |
| plan.md | [具体内容] | [已更新] |
| ... | ... | ... |

--- 无需更新 ---
[列出检查过但不需要改动的文档及原因]

--- 已自动更新 ---
[列出已经直接更新的文档和改动内容]

关键原则：
- 所有需要更新的文档直接改，不等人工确认
- 涉及产品决策的改动在报告中标注"⚠ 产品决策变更"，方便用户事后审核时重点关注
- 如实报告覆盖范围，不遗漏检查项
```

---

## 七、自定义命令（commands/）

### 1. start-working.md

```
开工流程：

1. 读取 docs/plan.md，确认：
   - 当前处于哪个 Wave
   - 本 Wave 有哪些 Team，各自状态（待开始 / 进行中 / 已完成）
   - 上次收工后的遗留问题
2. 快速检查：代码当前状态与 docs/ 文档是否一致，有无漂移
3. 确认当前分支（应在 feat/ 或 fix/ 或 hotfix/ 分支上，不在 main 上开发）
4. 判断接下来的工作模式：
   - 如果当前 Wave 有可并行的 Team → 建议启动 Agent Team
   - 如果是单任务或需要人工决策 → 走普通开发模式
5. 输出以上信息，等我确认后再开始，不要写任何代码
```

### 2. end-working.md

```
收工流程：

1. 检查本次所有改动和决策：
   - 代码改动是否与 docs/ 文档一致？不一致则更新文档
   - 对话中的口头决策是否已写入对应文档？
2. 更新 docs/plan.md：
   - 标记完成的任务
   - 如果当前 Wave 的所有 Team 都完成，标记 Wave 状态为已完成
   - 列出下次待办
   - 记录遗留问题和人工介入点
3. git add -A && git commit
4. git push

执行前先让我确认 commit message。
```

### 3. plan.md

```
针对我接下来描述的需求：

1. 先审视产品方向：
   - 这真的是用户需要的吗？
   - 有没有更好的解法藏在需求背后？
   - 10 分版本长什么样？
2. 读取相关的 docs/ 文档获取上下文
3. 输出实现方案：
   - 要改哪些文件、怎么改、有什么风险
   - 解耦分析：哪些任务之间没有文件重叠和数据依赖，可以并行？哪些必须顺序执行？
   - 如果可以并行，列出文件所有权划分（确保不重叠）
   - 如果并行任务之间有数据交互，定义接口契约
   - 是否需要 Codex 前置架构审视
   - 是否涉及高风险代码需要 Codex 审查
4. 等我确认方案后，先把方案追加到 docs/plan.md，再开始写代码

$ARGUMENTS
```

### 4. init-project.md

```
基于 ~/.claude/CLAUDE-TEMPLATE.md 模板初始化新项目：

1. 填写项目信息、确定技术栈和目标平台
2. 整理文档到 docs/（product-spec.md、tech-spec.md、design-spec.md 等）
3. 生成初始 docs/plan.md，按 Wave 组织开发计划
4. 初始化 git 仓库，创建 main 分支
5. 在 CLAUDE.md 中包含协作模式、模块边界、分支策略

$ARGUMENTS
```

---

## 八、分支策略

```
main              ← 稳定版，发布从这里出
  └── feat/xxx    ← 新功能开发，完成后 merge 回 main
  └── fix/xxx     ← 一般 bug 修复，完成后 merge 回 main
  └── hotfix/xxx  ← 线上紧急修复，从 main 拉出，修完 merge 回 main
  └── release/x.x ← 发布准备分支（如需要）
```

**规则：**
- main 不直接开发，锁定为当前发布版本
- 每个 Wave 对应一个 feature 分支
- 小修小补可在 fix/ 分支上快速合回
- merge 回 main 前必须通过 Doc Engineer 审计；Codex 代码审查和 QA 冒烟测试按触发条件表执行（不是每次都触发）
- Agent Team Developer 使用 git worktree 在各自分支工作

**Hotfix 流程：**
- 从 main 拉 hotfix/xxx 分支
- 走完整 Lead → Developer → Codex 审查 → Developer 回看 → Codex QA → Doc Engineer 流程
- 不设简化版——Agent Team 全流程是分钟级，不存在人类团队的等人瓶颈
- 触发条件表自动适配：单文件简单修复不触发代码审查和 QA，高风险修复全量触发
- 修完 merge 回 main，如有进行中的 feat/ 分支需要同步 hotfix 改动

---

## 九、Codex 5.3 集成

> 安装步骤见"〇、前置条件"。以下是使用场景和 prompt 模板。

### 三个使用场景

> 所有场景统一配置：reasoningEffort: xhigh + fast mode。

**场景 A：架构前置审视（Phase 0）**
产品初始化后、开发前，让 Codex 基于 tech-spec.md 审视整体技术架构。重点看架构合理性、扩展性、潜在瓶颈。

**场景 B：代码审查 + 修复（Phase 1-N）**
Developer 完成后，Codex 审查代码逻辑并直接修复问题。Claude Developer 再回看修复。

**场景 C：QA 冒烟测试（Phase 1-N）**
Developer 回看通过后，Codex 对变更功能做端到端冒烟测试（在 Doc Engineer 审计之前）。关键规则：增量测试——只测本 Wave 变更涉及的路径，上次测过且未受影响的跳过。这一步很慢，增量策略是效率关键。

---

## 十、文档命名规范

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

## 十一、CLAUDE-TEMPLATE.md

```markdown
# [项目名称]

## 项目概述
<!-- 一句话说清：这是什么、给谁用、当前阶段 -->
[描述]

## 技术栈
<!-- 根据项目实际情况填写 -->
- 语言：[Swift / Kotlin / TypeScript / Python / Rust / Go ...]
- 框架：[SwiftUI / Jetpack Compose / React / Next.js / Electron / Tauri / Flask ...]
- 平台：[iOS / Android / macOS / Windows / Web / 跨平台 ...]
- 构建：[Xcode / Gradle / Vite / Webpack / Cargo / CMake ...]
- 其他：[...]

## 开发规则
- 任何代码改动必须同步更新对应文档
- 产品决策变更必须写入文档，不能只存在于对话中
- 不确定的产品问题先问我，不要自行决定
- 完成任务后更新 docs/plan.md
- 不在 main 分支上直接开发，新功能走 feat/ 分支，bug 修复走 fix/ 分支，线上紧急修复走 hotfix/ 分支
- 核心业务逻辑必须有单元测试
<!-- 按项目需要增减项目特有规则，总数控制在10条以内 -->

## 协作模式：Agent Team

**角色：**
- Team Lead（主会话）：拆任务、协调全流程、合代码。不写业务代码。Lead 负责 Codex ↔ Developer 之间的信息传递，用户不参与中间协调。Lead 有权自行决定日常事项（常规权限审批、流程推进），但拿不准的事项必须上报用户，宁可多报不能漏报。
- Claude Developer（teammate）：写代码 + 单元测试。按文件所有权范围工作。回看 Codex 修复。
- Codex Reviewer（MCP）：审查代码 + 直接修复问题 + QA 冒烟测试。扫地僧角色——不参与日常开发，在关键节点把关，发现问题顺手修。统一使用 xhigh reasoning + fast mode。QA 增量测试只测变更路径。Lead 调用。
- Doc Engineer（Lead sub-agent）：Wave 完成后文档审计。确保代码和文档同步。

**开发流程：**
1. Lead 拆任务 → 定义文件所有权 + 接口契约
2. Developer 开发 + 单元测试
3. Lead 调用 Codex 审查代码 + 修复
4. Lead 转发修改给 Developer 回看
5. Lead 调用 Codex QA 冒烟测试（增量，只测变更路径）
6. Lead spawn Doc Engineer 文档审计（放最后，确保 QA 修复也被审计）
7. Lead 合代码

**Codex 审查触发：** 高风险代码必须触发代码审查 + QA，纯 UI 只需 QA，小修不需要。

**分支策略：** main 锁定，feat/xxx 开发，fix/xxx 修复，hotfix/xxx 线上紧急修复（从 main 拉，走完整流程）。

**模块边界：**
<!-- 根据项目实际结构填写 -->
| 模块 | 目录 | 说明 |
|------|------|------|
| ... | ... | ... |

## 操作护栏
<!-- 根据项目需要定义 -->
- 部署到生产环境必须获得批准
- git push 前必须确认
- 删除文件前必须确认
- 不在 main 分支上直接 commit

## 常用命令
<!-- 根据项目技术栈填写 -->
[构建命令]
[运行命令]
[测试命令]

## 文档索引
<!-- ⚠ 用文字"详见 docs/xxx.md"，不要用 @docs/xxx.md -->
<!-- 后者会每次自动把整个文件嵌入上下文，浪费大量 token -->
<!-- 前者让 Claude Code 需要时自己去读，按需加载 -->
- 产品规格 → docs/product-spec.md
- 技术规格 → docs/tech-spec.md（如有）
- 设计规格 → docs/design-spec.md（如有）
- 开发计划 → docs/plan.md
- 内容素材 → docs/content/（如有）
```

---

## 十二、plan.md 模板

```markdown
# [项目名称] — 开发计划

---

## 项目结构

<!-- 完整的文件树，随项目演进保持更新 -->

---

## 已完成阶段

<!-- 已完成的 Phase/Wave 压缩为单行标题，减少 token 占用 -->
### Phase X: xxx ✅
### Phase Y: yyy ✅

---

## Wave 并行开发计划

> Wave 内并行提速，Wave 间顺序保质，用户在 Wave 边界验收。
> 拆 Wave 的核心是解耦：同一 Wave 内的任务不能有文件重叠、数据依赖或运行时依赖。不能解耦就拆到下一个 Wave。

### Wave 总览

```
Wave 1（状态）
├── Team A: [任务名]
├── Team B: [任务名]
└── Team C: [任务名]

    ── 人工介入：[操作] ──

Wave 2（状态）
└── Team A: [任务名]

    ── 人工介入：[操作] ──

Wave N ...
```

---

### Wave 1 — [状态：进行中 / 待开始 / 已完成]

#### Team A: [任务名称]

**状态：** [待开始 / 进行中 / 已完成]

**任务清单：**
- [ ] 任务 1
- [ ] 任务 2
- [ ] 任务 3

**文件所有权：**
- Developer A 可新建：[文件列表]
- Developer A 可修改：[文件列表]
- Developer B 可修改：[文件列表]
- 不可碰：[文件列表]

**接口契约：**（如有多 Developer 协作）
<!-- 函数签名、参数类型、返回值、共享数据结构 -->

**Codex 审查：** [是/否] — [原因]

**完成标准：**
- 构建通过
- 单元测试通过
- Codex 代码审查通过（如触发）
- Developer 回看修复通过
- Codex QA 冒烟测试通过（如触发）
- Doc Engineer 文档审计通过
- plan.md 已更新

---

#### Team B: [任务名称]
<!-- 同上结构 -->

---

### Wave 2 — [状态]

**前置条件：** Wave 1 全部完成 + [其他条件]

#### Team A: [任务名称]
<!-- 同上结构 -->

---

## 人工介入点

| 时间点 | 操作 | 预计耗时 |
|--------|------|----------|
| Wave X 完成后 | [具体操作] | Xmin |
| Wave Y 开始前 | [外部依赖到位] | 外部流程 |

---

## 技术决策记录

| 决策 | 选择 | 原因 |
|------|------|------|
| ... | ... | ... |

---

## 待办（非代码）

1. ⏳ [待办项] — [说明]
2. ✅ [已完成项] — [说明]
```

---

## 十三、tech-spec.md 模板

```markdown
# [项目名称] — 技术规格

> 代码中的架构决策、数据结构、API 设计必须以此文档为准。修改技术方案时先更新本文档，再改代码。

---

## 架构概览

### 整体架构
<!-- 用文字描述系统的高层架构，如：纯客户端 / 客户端+云函数 / 前后端分离 / 微服务 -->
[描述]

### 架构图
<!-- 可选：ASCII 图或说明性描述 -->

### 关键架构约束
<!-- 列出不可随意变更的架构决策及其原因 -->
| 约束 | 原因 |
|------|------|
| ... | ... |

---

## 数据模型

### 核心实体
<!-- 每个实体列出字段、类型、约束 -->

#### [实体名称]
| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| ... | ... | ... | ... |

### 实体关系
<!-- 描述实体之间的关系：一对多、多对多等 -->

### 本地存储方案
<!-- 如适用：CoreData / SQLite / UserDefaults / 文件系统等 -->

---

## API 契约

### 内部接口
<!-- 模块间的关键接口定义：函数签名、参数、返回值 -->

### 外部 API
<!-- 如适用：后端接口、云函数、第三方 API -->

#### [接口名称]
- 端点：[URL / 函数名]
- 方法：[GET / POST / 云函数调用]
- 请求参数：
- 响应格式：
- 错误码：

---

## 状态管理

### 全局状态
<!-- 应用级别的状态：用户登录态、主题、语言等 -->

### 页面/模块状态
<!-- 各模块内部的状态管理方式 -->

---

## 第三方服务集成

| 服务 | 用途 | SDK/方式 | 配置要点 |
|------|------|----------|----------|
| ... | ... | ... | ... |

---

## 基础设施

### 环境配置
<!-- 开发/测试/生产环境的差异 -->

### 构建与部署
<!-- CI/CD、签名、发布流程等 -->

### 安全
<!-- 敏感数据处理、加密、权限控制 -->

---

## 错误处理

### 错误码体系
<!-- 如适用 -->

| 错误码 | 含义 | 处理方式 |
|--------|------|----------|
| ... | ... | ... |

### 异常兜底策略
<!-- 网络异常、数据异常、崩溃恢复等 -->
```

---

## 十四、design-spec.md 模板

```markdown
# [项目名称] — 设计规格

> 代码中的视觉参数必须严格引用此文档。修改设计时先更新本文档，再改代码。

---

## 色值

### 主色
| 名称 | 色值 | 用途 |
|------|------|------|
| primary | #XXXXXX | 主按钮、关键操作 |
| accent | #XXXXXX | 强调、高亮 |

### 背景色
| 名称 | 色值 | 用途 |
|------|------|------|
| bgPrimary | #XXXXXX | 页面主背景 |
| bgSecondary | #XXXXXX | 卡片、模块背景 |

### 文字色
| 名称 | 色值 | 用途 |
|------|------|------|
| textPrimary | #XXXXXX | 正文 |
| textSecondary | #XXXXXX | 辅助说明 |

### 语义色
| 名称 | 色值 | 用途 |
|------|------|------|
| success | #XXXXXX | 成功 |
| warning | #XXXXXX | 警告 |
| error | #XXXXXX | 错误 |

### 特殊色（项目独有）
<!-- 如有 -->

---

## 字体

### 字体族
| 名称 | 字体 | 用途 |
|------|------|------|
| primary | [字体名] | 正文 |
| display | [字体名] | 标题 |

### 字号
| 名称 | 大小 | 行高 | 字重 | 用途 |
|------|------|------|------|------|
| title1 | Xpt | X | bold | 页面大标题 |
| title2 | Xpt | X | semibold | 章节标题 |
| body | Xpt | X | regular | 正文 |
| caption | Xpt | X | regular | 辅助说明 |

---

## 间距

| 名称 | 值 | 用途 |
|------|-----|------|
| xs | Xpt | 紧凑间隔 |
| sm | Xpt | 元素内间距 |
| md | Xpt | 模块间间距 |
| lg | Xpt | 区块间间距 |
| xl | Xpt | 页面级间距 |

### 圆角
| 名称 | 值 | 用途 |
|------|-----|------|
| sm | Xpt | 小按钮、标签 |
| md | Xpt | 卡片、输入框 |
| lg | Xpt | 弹窗 |

---

## 阴影（如适用）
| 名称 | 参数 | 用途 |
|------|------|------|
| sm | offset blur spread color | 轻微浮起 |
| md | offset blur spread color | 卡片 |

---

## 动效（如适用）
| 名称 | 参数 | 用途 |
|------|------|------|
| fadeIn | duration, easing | 页面进入 |
| slideUp | duration, easing | 弹窗出现 |

---

## 氛围元素（项目独有，如适用）
<!-- 如勇芽的星空背景、月亮光晕等 -->
```

---

## 十五、Memory 边界定义（可选，适用于 Claude.ai 用户）

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

## 十六、多设备同步（可选）

如果你在多台电脑之间切换开发，可以通过云同步服务 + symlink 共享用户级配置。

### 需要同步的文件

```
~/.claude/
├── settings.json          ← 全局配置
├── CLAUDE-TEMPLATE.md     ← 新项目模板
└── commands/
    ├── start-working.md
    ├── end-working.md
    ├── plan.md
    └── init-project.md
```

### 不需要同步的

运行时数据（`~/.claude/` 下的 history、cache、debug 等）各设备独立，不同步。

### 参考方案

**macOS（iCloud Drive）：** 把上述文件放到 iCloud Drive 目录，用 symlink 映射回 `~/.claude/`。

**跨平台（Git 仓库）：** 单独建一个 `claude-config` 仓库，clone 到各设备后 symlink。

**原理：** Claude Code 启动时读取 `~/.claude/` 下的配置。只要该路径指向同步目录的 symlink，多台电脑就能共享配置。

---

## 十七、常见问题排查

| 问题 | 原因 | 解决 |
|------|------|------|
| Codex MCP 状态显示 ✘ failed | MCP Server 命令写错，或 Codex CLI 未安装/未登录 | 确认 `codex --version` 和 `codex login status` 正常，然后 `claude mcp remove codex-reviewer -s project && claude mcp add codex-reviewer -s project -- npx -y codex-mcp-server`，重启 Claude Code |
| Claude Code 上下文窗口满了 | 长会话积累太多 token | 执行 `/compact` 压缩上下文。如果仍然满，`/end-working` 收工后开新会话 `/start-working` 继续（plan.md 保证上下文不丢） |
| Developer 改了不该改的文件 | 文件所有权指令被忽略 | Lead 发现后回滚该文件的改动，重新明确文件所有权后让 Developer 重做。在 CLAUDE.md 里加项目特有规则强调 |
| merge 冲突（多 Developer 并行） | 文件所有权划分有重叠，或共享文件没有明确修改顺序 | Lead 拆任务时确保文件所有权不重叠。共享文件的修改只分配给一个 Developer，或明确顺序 |
| Codex 审查返回空结果 | 网络问题或 Codex 服务临时不可用 | 重试一次。如果持续失败，检查 `codex login status`，可能需要重新登录 |
| `/start-working` 发现代码和文档不一致 | 上次收工时文档同步不完整 | 先让 Lead 修复不一致，确认后再继续开发 |
| 短暂离开后想继续 | Claude Code 会话还在 | `claude --continue` 接回当前会话。如果会话已过期，开新会话 `/start-working` |

---

## 十八、设计决策记录

| 决策 | 选择 | 原因 |
|------|------|------|
| 去掉 Claude Reviewer | Codex 做唯一审查者 | 同源审查价值有限，异源审查覆盖盲区更有效 |
| Codex 架构前置审视 | Phase 0 就介入 | 在动手前拦截架构问题，成本远低于开发后返工 |
| Codex 角色定位 | 扫地僧 | 不参与日常开发，关键节点把关，发现问题顺手修 |
| Lead 负责信息传递 | Codex ↔ Developer 由 Lead 协调 | 用户不参与中间的复制粘贴，Lead 自动转发 |
| Doc Engineer 是 sub-agent | Lead spawn | 需要 Lead 的全局上下文，不需要独立 tmux pane |
| Developer 自带单元测试 | 编码时一起写 | 测试是代码的一部分，不应该是独立阶段 |
| 平台无关设计 | 模板不绑定任何技术栈 | 适用于 iOS / Android / macOS / Windows / Web / 跨平台 |
| 项目特有插件放项目级 | 不放全局 settings.json | swift-lsp 只对 iOS 有用，不污染其他项目 |
| 文档命名统一 | 全部 -spec 后缀 | product-spec、tech-spec、design-spec 一目了然 |
| 新增 tech-spec.md | 独立技术规格文档 | 产品行为（product-spec）与技术实现（tech-spec）职责分离，模板成本为零，项目不需要可不创建 |
| Lead 授权与上报机制 | Lead 自行决定日常事项，拿不准就上报 | 减少用户参与中间协调，同时确保关键决策不被绕过，宁可多报不能漏报 |
| Lead 文档变更权限 | Lead 可改所有文档，事后汇总报告 | Lead + Doc Engineer 是文档管理者，禁止改文档制造瓶颈；用户事后审核，产品决策变更标注 ⚠ 重点关注 |
| Codex 统一配置 | xhigh reasoning + fast mode | 所有 Codex 调用（架构审视、代码审查、QA）统一最高推理深度 + fast 模式 |
| Codex QA 冒烟测试 | 代码审查后增加 QA 环节 | 补齐人类团队 QA 角色的缺口；增量测试策略（只测变更路径）解决冒烟测试慢的问题 |
| Wave 并行的前提 | 任务完全解耦 | 文件不重叠 + 数据无依赖 + 运行时无依赖才能并行；不能解耦就拆到下一个 Wave，不冒冲突风险 |
| Hotfix 走完整流程 | 不设简化版 | Agent Team 全流程是分钟级，不存在人类团队的等人瓶颈；hotfix 恰恰最容易出二次事故，更不应该砍审查 |
| 项目命名 | iSparto | 希腊神话 Spartoi（种龙牙长军队）+ i 从末尾移到开头 = I = 一个人。一人成军 |
| 借鉴 gstack | 只取产品审视思路 | plan-ceo-review 理念好，/browse /qa 是 Web 专用不通用 |
| Effort level | max | Max 订阅 token 用不完，追求最高推理深度 |
| 成本 | $120/月 | Claude Max $100 + ChatGPT $20，两个顶级模型无额外费用 |
| Memory 粒度 | 里程碑级别 | 空间有限，细节由 plan.md 承载 |

---

## 十九、启动清单

- [ ] Claude Max + ChatGPT 订阅已开通
- [ ] Codex CLI 已安装并登录（`npm i -g @openai/codex && codex login`）
- [ ] `~/.claude/` 下的 settings.json、CLAUDE-TEMPLATE.md、commands/ 已就位
- [ ] 多设备同步已配置（如有多台电脑）
- [ ] 项目级 Codex MCP Server 已添加（`/mcp` 验证 ✓ connected）
- [ ] 项目级 `.claude/settings.json` 配置平台相关插件（如 iOS 加 swift-lsp）
- [ ] 项目 CLAUDE.md 已通过 `/init-project` 生成，包含协作模式 + 模块边界 + 分支策略
- [ ] 项目 docs/plan.md 按 Wave 模板组织
- [ ] 项目 docs/tech-spec.md 按模板创建（如有技术架构）
- [ ] 项目 docs/design-spec.md 按模板创建（如有 UI）
- [ ] 启动用 `claude --effort max`

---

## 二十、适配指南

> 本文档是通用模板。以下说明哪些部分可以直接用，哪些需要根据你的项目修改。

### 直接用，不用改

| 内容 | 说明 |
|------|------|
| 4 个自定义命令 | `/start-working`、`/end-working`、`/plan`、`/init-project` 通用于所有项目 |
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
| Codex QA 冒烟测试 | 触发条件表已定义，按需触发即可 |
