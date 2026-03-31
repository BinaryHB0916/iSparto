# iSparto

## Project Overview
iSparto 是一个 AI Agent Team 工作流框架，把 Claude Code 单 Agent 变成一支有分工的团队（Lead + Teammate + Developer + Doc Engineer + Process Observer）。目标用户是独立开发者，当前阶段：开源核心工作流已发布，dogfooding 中。

## Tech Stack
- Language: Shell (Bash), Markdown
- Framework: 无（纯配置项目，通过 Claude Code slash commands + MCP 驱动）
- Platform: macOS (iTerm2 + tmux)
- Build: 无构建步骤
- Other: Codex MCP Server (npx codex-mcp-server)

## Development Rules
- 使用用户的语言沟通和生成文档（仅限英文或中文）
- 任何代码/命令改动必须同步更新对应文档（README、docs/、命令头注释）
- 产品方向变更必须写入文档，不能只在对话里讨论
- 不确定的产品问题先问我，不要自己决定
- 完成任务后更新 docs/plan.md
- 不在 main 上直接开发；feat/ 做新功能，fix/ 修 bug，hotfix/ 紧急修复，docs/ 纯文档提交，release/ 发版
- install.sh 改动必须保持向后兼容（旧用户能正常卸载）
- 命令模板（commands/*.md）改动需确认不破坏现有用户的 /migrate 和 /init-project 流程
- 完成全部审查后自动创建 PR 并 merge 到 main，不需要用户手动 review
- 本项目是框架本身，hooks/ 下的 .sh 文件和 rules/ 下的 .json 文件由 Lead 直接编辑，遇到 Process Observer 代码直写拦截时 approve 即可（自引用边界情况）

## Collaboration Mode: Auto（Solo + Codex / Agent Team）

Lead 根据任务特征选择模式，用户无需干预。选择必须在执行前显式完成（见 Mode Selection Checkpoint）。

**Mode Selection Checkpoint（强制）：** Plan 批准后、执行第一步之前，Lead 必须显式评估并声明使用哪种模式。步骤：(1) 按文件所有权分组；(2) 对照上述两个条件判断；(3) 满足 → 声明 Agent Team 并 spawn Teammate；不满足 → 声明 Solo 并记录原因。这是强制步骤，不是可选优化——跳过此步骤视为流程偏差。

**Solo + Codex**（Lead 自己完成）—— 默认模式。
**Agent Team**（Lead spawn 队友并行）—— 同时满足两个条件时升级：
1. 可分解：任务能拆成独立并行的子任务（无文件重叠、无数据依赖）
2. 工作量值得：文件数 × 每文件工作量足以抵消并行协调开销

**Plan Mode:** Lead 自主判断是否进入 plan mode，用户无需指示。满足任一条件时自动进入：
- 改动跨越多个模块（Module Boundaries 表中 ≥2 个模块）
- 改动涉及核心设计（CLAUDE.md、workflow 定义、角色定义）
- 改动影响用户侧行为（slash commands、install 流程）
- 改动不可轻易回滚（数据格式变更、破坏性 API 变更）

不需要 plan mode：单模块内 bug fix、纯文档更新、格式化/typo。

适用于**写**（代码、文档、配置）和**读**（code review、文档审计、调研/debug）两类任务：
- 写：改 5 个文件每个大段逻辑 → Agent Team；改 5 个文件每个 1 行 → Solo
- 读：review 涉及多模块多文件 → Agent Team 按模块分组并行 review；少量文件 → Solo 串行 review

**Why Lead/Teammate do not write code directly:** Codex 通过结构化 prompt 产出的代码质量显著高于 Lead 模型（当前为 Opus）直写。Lead 模型的优势在上下文理解、任务拆解、prompt 组装和审查，而非无 bug 实现——直写代码小 bug 多、review 成本反而更高。因此所有代码实现必须经由 Developer (Codex)，Lead/Teammate 只负责组装 prompt 和审查输出。

**Roles:**
- Team Lead (main session): 协调全流程、合代码。不直接写代码（见上方架构动机）——组装结构化 prompt 调 Developer (Codex) 实现，然后审查 Developer 输出。Solo 模式下自己走 prompt→Developer→review 循环；Team 模式下委派 Teammate 并行走同样循环。可以独立做常规决策，不确定的事情必须上报用户。并行不限于写代码——代码审查、文档审计、调研任务都应尽可能并行执行。任务完成后主动对照 plan.md 建议下一步。
- Teammate (tmux, 仅 Agent Team 模式): 并行执行单元。在文件所有权范围内，遵循与 Lead 相同的 prompt→Developer→review 循环。不直接写代码（见上方架构动机）。每个 Teammate 独立调 Developer = 真正的并行 Codex 调用。
- Developer (Codex MCP): 按 Lead/Teammate 组装的结构化 prompt 实现代码。也承担 QA 冒烟测试（不同 prompt，由 Lead 统一编排）。模型配置见 docs/configuration.md。
- Doc Engineer (Lead sub-agent): 团队的 context 来源。每个 Wave 结束后：(1) 确保代码和文档同步，(2) 检查产品术语一致性，(3) 审计产品叙事整合。
- Process Observer (hooks + Sonnet sub-agent): 合规监督。**核心层**：Hooks 实时拦截灾难性操作和分支违规（不可绕过，无模型依赖）。**建议层**：Sonnet 4.6 事后审计回顾 session 合规性（降低 token 消耗；关键检查已由 Hooks 覆盖）。

**Development Workflow (Solo + Codex):**
0. **Mode Selection Checkpoint** — Lead 按文件分组、评估两个条件、声明 Solo（记录原因）
1. Lead 组装 implementation prompt → 调 Developer 实现代码 + 测试
2. Lead 审查 Developer 输出，有问题则组装修复 prompt 再调 Developer
3. Lead 组装 QA prompt → 调 Developer 冒烟测试（按触发表）
4. Lead 跑 Doc Engineer 审计（sub-agent）
5. Lead 跑 Process Observer 事后审计（sub-agent，与 Doc Engineer 可并行）
6. Lead 推分支 -> 建 PR -> merge 到 main -> 清理分支

/end-working 全自动执行（commit + push + 输出 briefing），不需要用户确认。分支任务全部完成时通过 gh CLI 建 PR 并 merge；gh 不可用时 push 分支并提示用户手动合并。未完成时只 push，不 merge。

**Development Workflow (Agent Team):**
0. **Mode Selection Checkpoint** — Lead 按文件分组、评估两个条件、声明 Agent Team + 定义 Teammate 数量
1. Lead 拆任务 → 定义文件所有权 + prompt 范围
2. Teammate(s) 各自走 prompt→Developer→review 循环
3. Lead 组装 QA prompt → 调 Developer 冒烟测试（增量，只测改动路径）
4. Lead 派 Doc Engineer 文档审计（最后一步，确保 QA 修复也被审计）
5. Lead 跑 Process Observer 事后审计（sub-agent，与 Doc Engineer 可并行）
6. Lead 推分支 -> 建 PR -> merge 到 main -> 清理分支

/end-working 全自动执行（commit + push + 输出 briefing），不需要用户确认。分支任务全部完成时自动建 PR 并 merge；未完成时只 push，不 merge。

**Developer Triggers:** 默认触发实现 + QA。部分跳过：纯视觉/配置微调（仅 QA）、行为模板 commands/*.md 和 templates/*.md（仅 Developer review，跳过 QA）、纯文档/格式化（均可跳过）。每个 Wave 至少包含一次批量审查。QA 按 plan.md 中定义的 acceptance script 执行。详见 docs/workflow.md 触发条件表。

**Branching & Merge:** main 锁定；feat/xxx 开发新功能，fix/xxx 修 bug，hotfix/xxx 紧急修复，docs/xxx 纯文档提交，release/vX.Y.Z 发版。完成全部审查后 Lead 自动建 PR 并 merge——不需要用户手动 review。

**Module Boundaries:**
| Module | Directory/Files | Description |
|--------|----------------|-------------|
| Bootstrap | bootstrap.sh | 薄引导入口（解析版本、校验 checksum、拉取 install.sh） |
| Installer | install.sh, isparto.sh | 安装/升级/卸载；isparto.sh 是本地 stub |
| Snapshot Engine | lib/snapshot.sh | 快照/恢复引擎 |
| Slash Commands | commands/*.md | 8 个行为定义（系统 prompt，驱动 Agent 行为，改动按 Tier 2b 处理） |
| Doc Templates | templates/*.md | 5 个结构模板（/init-project 生成文档的蓝图，改动按 Tier 2b 处理） |
| Project Template | CLAUDE-TEMPLATE.md | 新项目 CLAUDE.md 生成模板 |
| Framework Docs | docs/ (concepts, roles, workflow, configuration, user-guide, troubleshooting, design-decisions, security) | 面向用户的框架文档 |
| Project Docs | docs/ (product-spec, plan) | iSparto 自身的产品规格和开发计划 |
| Release Script | scripts/release.sh | 自动化发版（bump version → changelog → tag → gh release） |
| Assets | assets/*.svg | README 用的 SVG 图 |
| Process Observer | hooks/process-observer/, agents/ | 实时拦截（hooks 脚本 + 高危清单）+ 事后审计 + agent 定义 |
| READMEs | README.md, README.zh-CN.md | 双语 README |

## Operational Guardrails
- 删除文件前必须确认
- 不直接 commit 到 main——始终通过 PR merge
- install.sh 破坏性改动（改变 backup 格式、删除旧兼容逻辑）需要用户明确同意
- 高危操作由 Process Observer hooks 自动拦截，清单见 hooks/process-observer/rules/dangerous-operations.json

## User Preference Interface

Agent 团队将用户的 memory 视为**只读输入**，用于适配沟通方式；CLAUDE.md 是行为的唯一权威。

**领地原则：** Memory 管"跟谁做事"（用户偏好），CLAUDE.md 管"怎么做事"（工作流规则）。归属按话题领地判断，不按内容是否矛盾判断。

**三级响应模型：**

| 级别 | 偏好类型 | 示例 | Agent 团队响应 |
|------|---------|------|---------------|
| 第一级：无条件尊重 | 沟通语言、输入方式、输出风格、称呼习惯 | 语音输入纠错、不要总结、用中文 | 直接适配 |
| 第二级：有条件尊重 | 交互节奏、自主程度、关注重点 | 问号先讨论、常规决策不要问我、更关心性能 | 在工作流规则范围内适配；紧急拦截不等讨论 |
| 第三级：只记录不执行 | 跳过流程、改变顺序、降低安全标准 | 不要 Codex review、先 push 再 review、直接推 main | 不执行，告知用户"工作流要求 [Y]，因为 [原因]" |

**冲突协议：** 当 memory 与 CLAUDE.md 冲突时——执行 CLAUDE.md，向用户说明原因，不修改用户的 memory。如果用户想改规则，引导修改 CLAUDE.md。

**Agent 团队 memory 写入规则：**
- 允许：项目背景（project）、外部引用（reference）、用户画像（user）
- 禁止：工作流规则、流程变更、任何与 CLAUDE.md 现有内容重复的条目
- 写入前检查：该话题是否属于 CLAUDE.md 的领地？属于则不写

## Common Commands
- 安装测试: `./install.sh --dry-run`
- 快照测试: `bash lib/snapshot.sh list`
- Lint (无自动化，靠 Codex review)

## Documentation Index
- 产品规格 -> docs/product-spec.md
- 开发计划 -> docs/plan.md
- 框架概念 -> docs/concepts.md
- 角色定义 -> docs/roles.md
- 工作流 -> docs/workflow.md
- 配置指南 -> docs/configuration.md
- 用户交互 -> docs/user-guide.md
- 问题排查 -> docs/troubleshooting.md
- 设计决策 -> docs/design-decisions.md
- Process Observer -> docs/process-observer.md
- 安全审计系统 -> docs/security.md
