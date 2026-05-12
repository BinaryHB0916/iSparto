# iSparto vNext Agent Orchestra Framework 总设计方案

状态：待 review 草案  
目标用户：先服务项目作者本人，再服务一人公司和独立开发者  
第一目标：让 AI coding agent 安全到足够进入日常高频自用流程

## 1. 总结

iSparto vNext 是一个本地优先、模型无关的 Agent Orchestra Framework。

它是：

- 模型无关的 Agent 协作编排框架。
- 角色驱动的工作流系统。
- Spec-driven 的任务执行框架。
- 内置 policy enforcement、worktree 隔离和 evidence ledger 的监督层。

它允许 Claude Code、Codex、Kimi 以及未来其他 CLI 型 Agent 参与代码工作，但工作流、权限、证据、检查和安全门禁必须由 iSparto 统一接管。

核心承诺：

> Agent 可以帮助实现、审查、测试和写文档，但不能脱离 iSparto 的监督流程自由行动。任何脱框、绕过、越权或证据不一致，都必须被阻止、halt，或在报告中明确上报。

第一版不是企业治理平台，也不是 LangSmith、Langfuse 这类观测平台的替代品。

第一版是一个本地优先、CLI-first 的 Agent Orchestra Framework，服务的是一人公司和独立开发者：他们想更大胆地使用 Agent，但不能接受 Agent 在用户不知情的情况下把仓库搞乱。

## 2. 已确认的产品决策

- 第一目标用户是项目作者本人，其次是相似的独立开发者。
- 旧框架的核心方法不变：角色分离、spec 驱动、plan 约束、文档证据链和 gate 闭环必须完整迁移。
- 第一批执行后端：Claude Code CLI、Codex CLI、Kimi CLI。
- 执行后端不能直接变成用户工作流入口；模型必须嵌入角色，由角色配置决定使用哪个 CLI / model。
- Adapter 策略：先做通用 CLI Executor Adapter，再加 Claude / Codex / Kimi 的 profile。
- 第一版实现语言：Python。
- 第一版隔离方式：Git worktree + 任务分支 + 日志隔离。
- Solo 模式也使用独立 worktree；Agent Team 模式延续并标准化现有的 worktree 隔离思想。
- `Teammate` 不再是 vNext 固定核心角色；它在旧架构中是为了并发拼接 Codex prompt 的过渡角色。vNext 中并行执行由 Team Lead 派生动态子 Agent / Worker，或由 Role Orchestrator 直接启动独立 role instance。
- 分支名必须人类可读，由需求自动生成，不能用纯 session 编号做分支名。
- Agent 可以在自己的任务分支上 commit 和 push，但必须经过 gate。
- Agent 绝不能 commit 或 push 到 `main`、`master` 等保护分支。
- 每个 session、每个 agent 都必须有独立日志，不能把多 Agent 行为混在一条不可追溯的记录里。
- Halt 策略必须非常严格。
- 任何绕过、疑似绕过、未登记变更、ledger 和 Git 状态不一致，都必须在最终报告里显著提示。
- 监督必须是机器可执行的 policy / hook / gate，不依赖自然语言理解或模型自觉。
- v1 必须诚实区分预防型控制和检测型控制：黑盒 CLI 内部行为在没有 hook 能力前不能声称被实时拦截。
- 旧 iSparto dogfood 出来的纪律必须作为 carry-over baseline，而不是重新设计时的可选项。
- 第一版用户命令必须覆盖日常工作、初始化、迁移、安全审计和发布闭环。
- vNext 必须提供旧框架迁移与共存路径，不能让已安装 v0.x 的项目断档。
- vNext 在当前仓库内重构，不新开仓库。
- 现有 Claude Code 绑定式架构进入 legacy/reference 状态，不再作为长期架构继续扩展。

## 3. 第一版不做什么

- 不做 SaaS 后台。
- 不做团队权限系统。
- 不做多租户服务。
- 不做独立桌面客户端。
- 不替代完整 LLM observability 平台。
- 不深入解析每个模型厂商 CLI 内部的私有 tool call 协议。
- 不承诺第一版能对黑盒 CLI 内部每个 tool call 做 in-flight 逐动作拦截。
- 不在第一版支持所有 Agent 框架。
- 不做云端同步。

第一版要做的是一个本地优先、CLI-first 的 Agent 协作编排框架。它不需要大而全，但必须强到足够成为作者本人每天使用 Agent 前的默认入口。

## 4. 设计原则

1. 模型无关核心。
   Core 里的数据结构不能出现 Claude、Codex、Kimi、OpenAI、Anthropic、Moonshot 等供应商概念。

2. 角色优先，CLI 后端化。
   用户面对的是 Team Lead、Developer、Independent Reviewer、Doc Engineer、Process Observer 这些稳定角色，以及 Team Lead 动态派生出来的 Worker 实例，不是 `claude`、`codex`、`kimi` 这些模型工具。第一版所有模型和 Agent 工具通过外部 CLI 接入，但 CLI 只是角色的执行后端。

3. Supervisor 拥有流程控制权。
   Agent 可以执行任务，但不能拥有 session 状态、权限、gate、accept、rollback 的控制权。

4. 只信证据，不信 Agent 自述。
   报告必须来自 ledger、Git 状态、文件变更、policy 结果、命令结果，而不是来自 Agent 自己说“我完成了”。

5. 高风险情况默认 fail closed。
   关键事件未知、格式异常、证据缺失、状态不一致时，默认 block 或 halt，而不是静默放行。

6. 工作流必须人类可读。
   分支名、报告、命令、incident 文件都必须能直接看懂，不能要求用户解码内部编号。

7. Framework 必须保护自己。
   Agent 默认不能修改 iSparto policy、ledger、hooks、`.isparto/**`、framework 实现文件，除非任务显式授权。

8. Spec-driven，而不是 chat-driven。
   Agent 的任务必须能追溯到 user request、spec、plan entry、gate failure 或 incident recovery。Agent 不能只根据聊天上下文自行扩大任务范围。

9. Prompt 不是安全边界。
   Prompt 可以表达协作协议，但不能承担监督职责。流程控制、权限判断、拦截、halt、审计必须由代码、policy、hooks、gate、worktree 和 ledger 实现。

10. 监督必须机器可执行。
    所有关键监督规则都必须落到结构化事件和代码判断上。自然语言说明只能作为解释层，不能作为 allow / deny / halt 的依据。

### Spec-Driven Role Workflow

vNext 必须完整平移旧框架中最核心的工作方式：角色分离 + spec 驱动 + plan 约束 + 文档证据链。

基础流向：

```text
user request
  -> product-spec / tech-spec / design-spec
  -> plan.md
  -> role execution
  -> gate results
  -> ledger
  -> session-log / independent-review / changelog / PR evidence
```

关键规则：

- `product-spec.md` 定义做什么和为什么做。
- `tech-spec.md` 定义系统结构、技术约束和实现边界。
- `design-spec.md` 定义体验、交互和产品表达。
- `plan.md` 是当前可执行状态源，只保留当前任务、下一步、阻塞项和导航上下文。
- `session-log.md` 是历史完成记录，不应反向污染当前 plan。
- `independent-review.md` 是独立审查证据，不应被 Lead 过滤后再写入。
- `CHANGELOG.md` 和 PR body 是用户可见 release / merge evidence。
- Agent 的每个任务必须声明来源：`user_request`、`spec_requirement`、`plan_entry`、`gate_failure` 或 `incident_recovery`。
- 没有来源的行动默认视为 scope expansion，进入 warn / block / halt 路径。

文档不是唯一事实源。vNext 的事实源是 ledger、Git diff、gate result 和 policy decision；文档是人类可读的 evidence view。二者必须能互相校验。

### Role Contract

每个稳定 Role 必须有机器可读 contract，而不只是自然语言职责描述。

Role contract 至少包含：

- 输入：允许读取哪些 spec、plan、diff、ledger、代码文件。
- 输出：必须产出什么 artifact 或 event。
- 允许动作：能 read、write、run、review、commit、push 中的哪些动作。
- 禁止动作：不能改哪些路径，不能跳过哪些 gate。
- 触发条件：什么时候必须运行，什么时候可以跳过。
- 失败处理：fail 后 retry、escalate、halt、rollback 中哪一种。
- evidence：输出写到哪里，如何被 session report 引用。

示例：

```yaml
role_contracts:
  developer:
    inputs: ["tech-spec.md", "plan.md", "assigned_files"]
    outputs: ["code_diff", "test_diff", "implementation_events"]
    allowed_actions: ["file.write:scope", "command.run:allowed_test_commands"]
    denied_paths: [".isparto/**", ".env", "isparto.policy.json"]
    required_gates: ["scope", "secret", "tests"]

  independent_reviewer:
    inputs: ["product-spec.md", "tech-spec.md", "final_diff"]
    outputs: ["docs/independent-review.md", "review_events"]
    allowed_actions: ["file.write:review_report"]
    denied_actions: ["source_code.write", "commit", "push"]
```

### Mode Selection

Solo / Agent Team 选择也必须从旧框架迁移为机器可检查的流程。

Team Lead 可以提出模式判断，但最终必须记录结构化依据：

- 文件数量。
- 每个文件变更规模。
- 是否能按 ownership 拆分。
- 是否存在跨模块耦合。
- 并行收益是否大于协调成本。
- 是否需要独立 Worker / Developer instance。

模式选择结果必须写入 ledger 和 report。跳过模式选择是流程偏差。

### Wave Lifecycle

Wave 必须从旧框架迁移为 vNext 的基本调度单元。

Wave 是一批可以解耦执行的任务组，也是 Agent Team 并行、边界审计、计划更新和 session 汇总的自然节拍。

层级：

```text
Project
  -> Session
    -> Wave
      -> Task Group
        -> Role / Worker execution
```

Wave 状态：

```text
planned -> running -> gated -> completed -> logged
```

Wave 规则：

- `plan.md` 以 Wave 组织当前可执行任务，而不是只列散乱 TODO。
- Agent Team 只能在 Wave 内进行并行拆分。
- Team Lead 在 Wave 开始前定义 task groups、file ownership、worker/worktree 分配。
- 每个 Worker / Developer instance 必须绑定到某个 Wave 和 task group。
- Wave boundary 是 Doc Engineer、Independent Reviewer、Process Observer、security gate、session close gate 的主要挂载点。
- Wave 完成后，当前 narrative 和完成证据进入 `docs/session-log.md`，`docs/plan.md` 只保留下一步和当前状态。

Wave 事件必须进入 ledger：

```text
wave_planned
wave_started
task_group_started
task_group_completed
wave_gate_started
wave_gate_failed
wave_completed
wave_logged
```

没有 Wave 边界的 ad-hoc fix 可以存在，但必须显式标记为 `ad_hoc_session`，并说明为什么不进入 Wave。

### Information Layering

旧框架中的 A/B/C layer 需要保留，用于防止强监察变成噪音系统。

- A-layer：必须打断用户或 halt，例如危险行为、重大方向冲突、保护分支 push、secret 泄露。
- B-layer：帮助用户做决策，例如 session summary、risk summary、merge readiness。
- C-layer：只写入 ledger / report，例如普通通过项、健康检查细节、自动修复记录。

所有 gate 结果都必须分类。不是所有信息都打扰用户，但所有信息都必须可追溯。

### Gate Pipeline

旧框架中的 QA、Doc Engineer、Independent Reviewer、Process Observer、security scan、plan contract 都要迁移成明确 gate。

第一版 gate pipeline：

- `mode_selection_gate`：确认 Solo / Agent Team 选择有依据。
- `scope_gate`：确认所有修改在 allowed scope。
- `implementation_gate`：确认 Developer / Worker 输出存在且可追溯。
- `qa_gate`：确认测试或验收命令结果。
- `doc_sync_gate`：确认代码和文档一致性，必要时触发 Doc Engineer。
- `independent_review_gate`：Phase 0 / Wave boundary / 重大技术替代时触发。
- `process_observer_gate`：检查流程是否跳步、绕过、证据缺失。
- `security_gate`：secret、敏感文件、危险命令、PII 规则。
- `session_close_gate`：确认 ledger、diff、plan、report、branch 状态一致。

每个 gate 都必须定义输入、执行者、输出、失败处理和 evidence path。

### No Freeform Agent Behavior

vNext 必须把“禁止自我发挥”写成硬约束：

- Agent 不允许自行扩大任务范围。
- Agent 不允许自行改变 workflow。
- Agent 不允许自行新增架构层。
- Agent 不允许自行跳过 gate。
- Agent 不允许自行修改监督规则。
- Agent 不允许把临时 workaround 固化为长期设计。
- Agent 不允许在 evidence 不足时声称完成。

这些行为不能只靠 prompt 约束。它们必须通过 scope、policy、ledger reconciliation、gate checks 和 report risk flags 共同约束。

## 5. 旧 iSparto 必须继承的纪律清单

这一节不是新功能列表，而是 vNext 的继承基线。vNext 不能只是一个干净的新框架；它必须把旧 iSparto 一年多 dogfood 出来的有效纪律迁移到模型无关架构中。

### plan.md Backlog 单源约束

`docs/plan.md` 不只是恢复点，也是当前 TODO 的唯一人类可读入口。

必须继承：

- 所有 TODO、Process Observer audit findings、user-direction commitments、Wave 内 deferral 都必须进入 `docs/plan.md` Backlog。
- 写到其他临时文档、聊天记录或 session report 里但没有进入 Backlog 的 TODO，视为 workflow violation。
- `isparto end` 必须运行 `plan_md_contract_gate`，机械检查 Backlog、Wave 状态、完成记录和下一步是否一致。
- `docs/session-log.md` 记录历史，不能成为当前 TODO 源。

### Documentation Language Convention

旧框架的四层语言架构必须迁移，防止长期文档漂移。

约定：

- Tier 1：系统提示、角色契约、framework contract，默认英文，保证指令稳定和非中文协作者可读。
- Tier 2：参考文档、设计原则、实现说明，默认英文或项目约定语言。
- Tier 3：用户入口、命令帮助、模板提示，可以双语或本地化。
- Tier 4：历史归档和已完成 session 记录，冻结原始语言，不做无意义翻译。

规则：

- Tier 1 文件不能硬编码用户可见字符串。
- language gate 必须能机械扫描 Tier 1 / Tier 2 的异常 CJK、用户可见文案和约定违例。
- 语言规则是 Doc Engineer gate 的一部分，不靠模型自觉维护。

### Memory 与 CLAUDE.md 领域协议

vNext 不能把 memory、CLAUDE.md 和 policy.json 混成一个概念。

边界：

- memory 表示 “who you work with”，是用户偏好和协作背景，默认 read-only input。
- `CLAUDE.md` 或未来的项目级 agent instruction 表示 “how to work”，是项目工作协议。
- `isparto.policy.json` 表示机器可执行 policy，只承载可被代码判断的规则。

冲突处理：

- 可执行规则冲突时，framework hard invariants 和 policy 优先。
- 工作方式冲突时，项目级 instruction 优先于 memory。
- memory 不能被 Agent 当作授权来源，也不能在任务中被静默修改。
- 用户偏好可以影响汇报方式和默认选择，但不能绕过 scope、gate、halt、review。

### Wave 作为原子工作闭环

Wave 不只是并行批次，也是可恢复、可审计、可关闭的工作原子。

必须继承：

- Wave 拥有独立分支 / worktree / ownership map。
- Wave completion 由 `isparto end` 写入 `docs/session-log.md`，并与代码提交在同一 close-out 流程中完成。
- `docs/session-log.md` 的 Wave completion 必须进入 close-out commit，不能在 session 结束后单独漂移或事后补写。
- Wave close-out 必须机械验证 commit count、分支、worktree、plan Backlog、gate evidence。
- 没有完成 close-out 的 Wave 不能被标记为 completed。

### Doc Engineer Audit Checklist

`doc_sync_gate` 不能只是一个抽象 gate，必须拆成可执行清单。

第一版至少包含：

- language convention check
- policy lint
- plan.md contract check
- spec / plan / session-log link check
- Tier 1 / Tier 2 language scan
- user-visible string boundary scan
- stale TODO / orphan finding scan
- changelog / PR evidence check
- release note consistency check

每一项都必须输出结构化 gate result。Doc Engineer 可以解释失败原因，但不能替代机械检查。

### 自我指涉边界

iSparto 本仓库开发 vNext 时，项目本身就是 framework。普通项目的 framework tampering 禁止规则不能机械套死本仓库开发。

规则：

- 默认情况下，Agent 不得修改 `.isparto/**`、policy、hooks、framework 实现文件。
- 当任务明确是开发 iSparto framework 自身时，必须发放 `framework_edit_lease`。
- `framework_edit_lease` 必须记录 scope、允许路径、review gate、回滚方式和用户确认。
- 没有 lease 的 framework 修改仍然 hard halt。

这条规则也适用于用户项目本身就是 framework / library 的场景。

### Independent Reviewer 跨厂商隔离

IR 的价值不只是“另一个角色”，而是零继承上下文 + 跨 provider 审查。

默认规则：

- IR 应优先使用与 Team Lead 不同 provider 的 executor。
- 如果 Lead 使用 Claude，IR 优先 Codex 或 Kimi。
- 如果 Lead 使用 Codex，IR 优先 Claude 或 Kimi。
- 如果无法跨 provider，必须在 report 中标记为 `review_isolation_degraded`。

跨 provider 不能替代 review packet、worktree、环境变量和临时目录隔离；它是额外的偏差控制。

### 用户命令继承

vNext 第一版不能只覆盖 `start / work / end`，还必须保留旧框架日常闭环。

必须保留或重新映射：

- `init-project`：新项目初始化。
- `migrate`：存量项目迁移。
- `security-audit`：独立安全审计。
- `release`：发布闭环，禁止用户或 Agent 绕过 release workflow 直接手动 tag / push。

这些命令仍然是 workflow 级别入口，不暴露底层模型选择。

### Markdown Contract 与结构化状态

`plan.md`、product spec、tech spec、design spec 继续作为人类界面，但 framework 不能靠 LLM 自由阅读 Markdown 来判断状态。

规则：

- 关键状态必须来自 ledger、frontmatter、固定 heading contract、结构化 block 或 gate result。
- Markdown 正文可以解释上下文，但不能成为唯一可执行事实源。
- 如果 Markdown contract 解析失败，进入 `investigation_required`，不能让模型猜。
- 后续可以逐步把高风险字段迁移为 JSON / YAML sidecar，但第一版必须保留 Markdown 的人类可读体验。

## 6. 威胁模型

iSparto vNext 必须假设 Agent 会犯错，会误解指令，会扩大修改范围，会跑意外命令，也可能在流程已经坏掉时继续尝试完成任务。

第一版必须防住：

- 修改声明 scope 之外的文件。
- 修改 `.env` 等敏感本地文件。
- 未授权修改 `.isparto/**`、policy、ledger、hooks 或 framework 内部实现。
- 运行危险 shell 命令。
- commit 或 push 到保护分支。
- 产生和 session scope 不匹配的 commit。
- push secret。
- session 已经 `hard_halted` 或 `investigation_required` 后继续行动。
- 文件发生变化，但 ledger 中没有对应事件。
- 报告在证据缺失或不一致时仍然声称通过。

第一版不能完美防住：

- 完全被攻破的 shell 环境。
- 用户手动绕过 iSparto。
- 第三方 CLI 隐藏所有内部 tool call。
- OS 层面无法被 iSparto 观察到的文件系统变更。

但对这些情况，vNext 仍要尽量通过 Git 状态、文件 watcher、snapshot、最终 check 发现不一致，并在报告中明确提示。

### 控制边界

本文档引用 Reference Monitor、Complete Mediation、Fail-safe Defaults 等传统安全原则，是为了指导架构设计，不代表第一版已经具备操作系统级沙箱能力。

第一版必须诚实区分三类控制：

- **预防型控制**：动作发生前能阻止。例如 role 启动前 lease check、worktree check、保护分支 pre-push hook、session `hard_halted` / `investigation_required` 后禁止继续运行。
- **检测型控制**：动作可能已经发生，但能发现并进入 `hard_halted` 或 `investigation_required`。例如黑盒 CLI 内部写文件后，file watcher / diff reconciliation 发现 scope violation 或 ledger mismatch。
- **建议型控制**：只能提供风险判断和解释。例如 Doc Engineer、Independent Reviewer、Process Observer audit 的自然语言审查。

iSparto 只能在自己控制的 enforcement point 上接近 complete mediation。对于 Claude Code、Codex CLI、Kimi CLI 等黑盒 executor 的内部行为，第一版不能声称实时拦截一切。除非对应 executor 暴露稳定的 tool event、hook、permission API，否则内部文件操作和命令执行只能通过 worktree、日志、diff、file watcher、Git gate 做检测和补偿控制。

第一版的真实安全定位是：

```text
强审计 + 关键预防拦截 + 透明能力边界报告
```

不是：

```text
完美沙箱或完整 OS 级进程隔离
```

## 7. 系统架构

```text
用户
  |
  v
iSparto CLI
  |
  v
Supervisor Kernel
  |-- Session Manager
  |-- Role Orchestrator
  |-- Lease Manager
  |-- Worktree Manager
  |-- Policy Engine
  |-- Ledger Writer
  |-- Log Manager
  |-- Halt Manager
  |
  v
Role Execution Layer
  |-- Team Lead
  |-- Developer
  |-- Independent Reviewer
  |-- Doc Engineer
  |-- Process Observer
  |-- Dynamic Worker Instances
  |
  v
Generic CLI Executor Adapter
  |-- Claude Code CLI profile
  |-- Codex CLI profile
  |-- Kimi CLI profile
  |
  v
外部 Agent CLI

旁路监察：
  Git Gate
  File Watcher
  Secret Scanner
  Scope Checker
  Policy Enforcement Points
  Report Generator
  Human-Readable Status View
```

## 8. 核心概念

### Session

Session 是一次受监督的工作单元。

它拥有：

- 任务标题
- 自动生成的人类可读分支名
- 内部 session id
- active wave id
- scope
- denied paths
- active leases
- policy hash
- 启动时 Git 状态
- worktree path
- events ledger
- agent logs
- 当前状态

Session 状态：

- `created`
- `running`
- `warn`
- `merge_conflict_pending`
- `investigation_required`
- `hard_halted`
- `checked`
- `accepted`
- `rolled_back`
- `closed`

`merge_conflict_pending` 表示 Agent Team merge gate 遇到冲突。它不是违规状态，但也是阻塞状态：禁止 push、accept、release，只允许 report、rollback、Lead 生成冲突解决计划，或启动专门的 conflict-resolution Wave。

### Role

Role 是 iSparto 的核心抽象。模型和 CLI 工具必须挂在 Role 下面，而不是直接暴露给用户调度。

vNext 继承现有角色架构，但移除 `Teammate` 作为固定核心角色。

- **Team Lead**：用户主要交互对象，负责理解任务、计划、拆解、调度、合入和升级决策。
- **Developer**：实现和 QA 专家，接收 Team Lead 或动态 Worker 产出的结构化任务。Developer 可以有多个并行 role instance。
- **Independent Reviewer**：零继承上下文的独立审查者，负责产品-技术对齐和关键边界审查。
- **Doc Engineer**：文档一致性和上下文源审查者。
- **Process Observer**：流程监察者。Core 层是 hooks / gates / policy，无模型依赖；Audit 层可以配置模型执行事后审计。

旧架构中的 `Teammate` 存在原因，是为了让并行 Claude 会话拼接给 Codex Developer 的 prompt，再通过 MCP 并发调用 Developer。这是 Claude Code + Codex MCP 绑定时代的工程折中。

vNext 的模型无关架构不再需要把这个折中固化为核心角色。并行能力改为两种实现：

- 如果 Team Lead 绑定的 executor 支持原生派生 sub-agent，则 Team Lead 直接派生动态 Worker。
- 如果 Team Lead 绑定的 executor 不支持派生，则 Role Orchestrator 直接在独立 worktree 中启动对应 role instance。

Dynamic Worker 不是固定角色，而是执行实例。它必须继承明确的任务、scope、worktree、lease 和日志隔离。

每个 Role 可以绑定不同执行后端：

```yaml
roles:
  team_lead:
    executor: claude_cli
    model: opus-4.7

  developer:
    executor: codex_cli
    model: gpt-5.5

  independent_reviewer:
    executor: codex_cli
    model: gpt-5.5

  doc_engineer:
    executor: claude_cli
    model: opus-4.7

  process_observer_core:
    executor: hooks
    model: null

  process_observer_audit:
    executor: kimi_cli
    model: kimi-k2.6
```

上面只是示例。实际配置中，Team Lead 可以是 Claude，也可以是 Codex / GPT-5.5，也可以是 Kimi；其他角色同理。Core 只关心 role contract，不关心供应商。

Team Lead 的 executor capability 决定并行方式：

```yaml
executors:
  claude_cli:
    capabilities:
      - spawn_subagent

  codex_cli:
    capabilities:
      - cli_exec

parallelism:
  preferred_strategy: native_subagent_when_available
  fallback_strategy: orchestrator_spawned_role_instance
```

### Agent

Agent 是某个 Role 在某个 session 中的具体运行实例。

Core 只关心：

- `actor_id`
- `role`
- `executor`
- `model`
- `lease_id`
- `session_id`

Role instance 示例：

- `team_lead/main`
- `developer/implementation`
- `developer/tests`
- `worker/docs-audit`
- `independent_reviewer/wave`
- `doc_engineer/final-diff`
- `process_observer/audit`

### Wave

Wave 是 session 内的执行节拍和审计边界。

它拥有：

- `wave_id`
- title
- task groups
- ownership map
- assigned worktrees
- required gates
- current gate status
- completion evidence
- status view path

Wave 与 session 的关系：

- 一个 session 可以包含一个或多个 Wave。
- 一个 Wave 可以包含多个 task group。
- 一个 task group 可以由一个 Worker / Developer instance 执行。
- Wave boundary 触发边界审计和文档迁移。

### Lease

Lease 是 Agent 在某个 session 中行动的授权。

示例：

```json
{
  "lease_id": "lease_01",
  "session_id": "s_20260427_153000",
  "actor_id": "developer_impl_1",
  "role": "developer",
  "executor": "codex_cli",
  "model": "gpt-5.5",
  "task": "实现 Kimi CLI adapter",
  "allowed_paths": ["src/isparto/**", "tests/**", "docs/vnext/**"],
  "denied_paths": [".env", ".git/**", ".isparto/**"],
  "allowed_git_branch": "feat/kimi-cli-adapter",
  "worktree_path": "../.isparto-worktrees/isparto/feat-kimi-cli-adapter",
  "expires_at": "2026-04-27T18:30:00+08:00",
  "policy_hash": "sha256:..."
}
```

### Event

所有重要行为都必须变成事件。

事件示例：

- `session_started`
- `branch_created`
- `lease_granted`
- `agent_run_started`
- `agent_run_finished`
- `file_mutation_detected`
- `scope_violation`
- `command_blocked`
- `secret_detected`
- `git_commit_detected`
- `git_push_detected`
- `policy_check_passed`
- `policy_check_failed`
- `halt_triggered`
- `report_generated`
- `wave_planned`
- `wave_started`
- `wave_completed`
- `status_view_updated`

事件使用 append-only NDJSON：

```text
.isparto/sessions/<session-id>/events.ndjson
```

### Policy Decision

Policy decision 分五级：

- `allow`：允许继续。
- `record`：记录，但不提示用户。
- `warn`：允许继续，但报告里提示。
- `block`：阻止当前动作。
- `halt`：停止整个 session，必须用户处理。

对高风险未知状态，默认使用 `halt`。

## 9. Worktree + 分支双隔离模型

第一版默认使用 Git worktree + Git 分支作为隔离边界。

分支隔离保护 Git 历史，worktree 隔离文件系统工作目录。二者必须同时存在：

- 分支负责承载任务历史、commit、push、PR。
- Worktree 负责把 Agent 的实际文件操作放到独立目录里，避免污染用户主工作区。
- 日志隔离负责把每个 session / agent 的行为分开记录，避免事后无法追溯。

流程：

1. 用户启动一个任务。
2. iSparto 根据任务生成可读分支名。
3. iSparto 创建任务分支。
4. iSparto 为该任务创建独立 worktree。
5. Agent 只在该 worktree 内工作。
6. Agent 可以在 gate 通过后 commit 和 push 该任务分支。
7. 用户主工作区和保护分支不能被 Agent 触碰。

示例布局：

```text
repo/
  用户主工作区，不让 Agent 直接改

../.isparto-worktrees/<repo-name>/feat-kimi-cli-adapter/
  Agent 工作区，绑定 feat/kimi-cli-adapter 分支
```

Worktree 根目录应尽量放在仓库外的兄弟目录，而不是嵌套在项目仓库内部，避免嵌套 Git working tree 和项目文件扫描互相污染。

### Git Worktree 已知限制

Git worktree 是 v1 的默认隔离方式，但它不是完整沙箱。vNext 必须在设计和报告中明确这些限制。

已知限制：

- Git hooks 通常挂在 shared Git common dir 下，多个 worktree 可能共享同一套 hooks。不能为每个 session 直接覆盖 `.git/hooks/pre-commit` 或 `.git/hooks/pre-push`，否则多 session 会互相串扰。
- 同一个分支不能同时被多个 worktree checkout。Agent Team 必须使用子分支 / agent 分支，不能让多个 Worker 直接写同一分支。
- 不应在 repo 内部嵌套创建 worktree；嵌套 Git working tree 会污染文件扫描、scope 判断和 IDE 状态。
- submodule 有独立 Git 语义和工作目录，递归 hooks、scope、secret scan 都更脆弱。v1 默认不让 Agent 修改 submodule，除非 scope 明确授权并有单独 gate。
- worktree 隔离目录，不隔离进程。CLI 仍可能访问 `$HOME`、临时目录、网络或其他路径，除非 executor profile 或 OS sandbox 额外限制。
- worktree 共享 object database、refs 等 Git 元数据。framework 不能把它描述成 VM / container 级隔离。

v1 缓解策略：

- 安装一套 stable hook dispatcher，而不是每个 session 重写 hooks。hook dispatcher 根据 cwd、branch、sentinel、session state 查找当前 session，再运行对应 policy。
- `isparto doctor` 必须检查 hooks 是否仍指向 dispatcher，检测被覆盖或损坏时进入 warning 或 investigation_required。
- Worktree path 必须在 repo 外的受控目录下，并写入 `worktrees.json`。
- submodule 修改默认 block；如需开放，必须在 policy 中显式声明 submodule scope 和递归 gate。
- report 必须标注 worktree 的真实隔离边界。

分支命名规则：

```text
<type>/<task-slug>
```

示例：

```text
fix/refresh-expired-login-token
feat/kimi-cli-adapter
docs/vnext-agent-orchestra-framework
chore/add-policy-smoke-tests
```

如果分支已存在，追加短后缀：

```text
feat/kimi-cli-adapter-a7c9
```

内部 session id 仍然存在，但只用于 ledger 和状态管理，不用于公开分支名。

### Solo 模式

Solo 模式不是直接在用户主工作区里跑 Agent。

Solo 模式创建一个 session worktree：

```text
../.isparto-worktrees/<repo-name>/fix-login-token/
```

不同角色实例可以按需在这个 worktree 中顺序执行。具体使用 Claude、Codex、Kimi 还是其他模型，由 role binding 决定；所有行为都必须绑定同一个 session ledger。

UX 规则：

- 用户主仓库是 control workspace，不直接被 Agent 修改。
- `isparto start` 必须输出 session branch 和 worktree path。
- 用户想看实时变更时，应打开该 worktree 目录，而不是期待主仓库目录同步变化。
- `isparto end` 汇总 worktree diff、gate result、report、commit/push/PR 状态。
- 用户中途介入时，必须进入对应 worktree；主仓库只用于控制和最终合入。
- 如果用户在主仓库手动改动与当前 session 相关文件，session close gate 必须标记为 possible out-of-band change。

### Agent Team 模式

Agent Team 模式本来就是多执行单元并行，因此必须使用 worktree 隔离。

推荐结构：

- Team Lead 仍然负责拆解任务、定义 file ownership、选择并行策略、汇总结果。
- 如果 Team Lead executor 支持派生 sub-agent，则优先由 Team Lead 派生动态 Worker。
- 如果 Team Lead executor 不支持派生，则由 Role Orchestrator 启动独立 role instance。
- 每个动态 Worker / role instance 拥有自己的 worktree。
- 每个 worktree 绑定一个可读分支名。
- 每个 Worker / role instance 的日志独立，最终 session report 再汇总。

示例：

```text
../.isparto-worktrees/<repo-name>/feat-kimi-cli-adapter-lead/
../.isparto-worktrees/<repo-name>/feat-kimi-cli-adapter-docs/
../.isparto-worktrees/<repo-name>/feat-kimi-cli-adapter-tests/
```

如果多个 Agent 需要并行提交，不能让多个 worktree checkout 同一个分支。应使用同一个任务 slug 下的子分支或 agent 分支，再由 Lead 合入。

因此 vNext 中的 Agent Team 不是“Lead + 固定 Teammate 角色”，而是：

```text
Team Lead
  -> Dynamic Worker / Developer instance A
  -> Dynamic Worker / Developer instance B
  -> Doc Engineer / Independent Reviewer / Process Observer as needed
```

### Agent Team 合并策略

Agent Team 的关键路径不是“并行写完”，而是 Lead 如何把各 Worker 子分支安全合并回 session 分支。

分支模型：

```text
feat/kimi-cli-adapter
  feat/kimi-cli-adapter-lead
  feat/kimi-cli-adapter-docs
  feat/kimi-cli-adapter-tests
```

默认策略：

- 每个 Worker 只 push / commit 自己的子分支。
- Lead 不直接把 Worker diff 写进自己的 worktree；Lead 通过 merge gate 汇总。
- session 分支是 integration branch，只有 merge gate 通过后才能接收 Worker 子分支。
- 合并默认使用 `git merge --no-ff` 或等价的显式 merge commit，保留 Worker 边界证据。
- 小型 solo / single-worker 任务可以 fast-forward，但必须由 policy 明确允许。
- PR 可以作为远端展示和人工 review 载体，但本地 framework 不能依赖 GitHub / GitLab PR 才能完成 merge gate。

Merge gate 必须检查：

- Worker branch 是否绑定当前 Wave / task group。
- Worker diff 是否在 ownership map scope 内。
- Worker branch 是否通过 required gates。
- Worker branch 是否包含 secret、framework tampering、未登记变更。
- 合并后 integration branch 是否仍通过测试、scope、doc、security、Process Observer gate。

冲突处理：

- 自动 merge 冲突时，session 进入 `investigation_required` 或 `merge_conflict_pending`。
- 冲突不能由任意 Worker 自行解决。
- 默认由 Team Lead 生成冲突报告和解决计划；实际解决可以由 Lead 指派专门 Worker，但必须分配新的 ownership、worktree 和 gate。
- `merge_conflict_pending` 阻止 push、accept、release；允许用户 rollback、让 Lead 生成解决计划，或启动新的 conflict-resolution Wave。
- conflict-resolution Wave 必须拥有独立 branch / worktree / ownership map，并重新经过 merge gate。
- 冲突解决 commit 必须单独标记为 conflict resolution，并进入 final report。

### Independent Reviewer 隔离

Independent Reviewer 的价值不是“多一个审查角色”，而是零继承上下文和跨 provider 盲审。

vNext 必须为 IR 明确定义信息隔离等级：

1. **L1 Context Blind**
   - IR 不继承 Team Lead、Worker、Developer 的对话上下文。
   - IR 不读取 Lead 的中间推理、worker ledger、聊天历史或草稿。
   - IR 只根据明确输入形成独立判断。

2. **L2 Review Packet**
   - IR 输入必须打包成 review packet。
   - Review packet 只包含审查所需材料：

```text
.isparto/review-packets/<wave-id>/
  product-spec.md
  tech-spec.md
  design-spec.md
  plan-excerpt.md
  final.diff
  acceptance-evidence.md
```

3. **L3 Environment Narrowing**
   - IR 使用独立 review worktree 或只读 review packet 目录。
   - IR 使用独立 `TMPDIR`、日志目录和最小 env allowlist。
   - 不向 IR 进程传入 Lead session env、worker worktree path、非必要 config。
   - IR role contract 禁止跨 worktree 读取。

4. **L4 Hard Sandbox**，未来增强
   - 通过容器、macOS sandbox、executor 原生 sandbox 或更强 OS 能力限制文件系统访问。
   - 第一版不声称具备 L4。

第一版最低承诺：L1 + L2 + 部分 L3。做不到 L4 时，报告中必须称为“同机独立审查”，不能声称 OS-level blind isolation。

IR 允许读取：

- review packet
- 当前 Wave final diff
- 必要 specs excerpt

IR 禁止读取：

- Lead / Worker worktree
- Lead / Worker ledger
- executor debug logs
- 聊天历史
- 未进入 review packet 的临时草稿

## 10. 日志隔离模型

日志隔离和 worktree 隔离同等重要。

每个 session 有总 ledger，每个 agent 有独立 ledger：

```text
.isparto/sessions/<session-id>/events.ndjson
.isparto/sessions/<session-id>/agents/<actor-id>/events.ndjson
.isparto/sessions/<session-id>/agents/<actor-id>/stdout.log
.isparto/sessions/<session-id>/agents/<actor-id>/stderr.log
```

总 ledger 记录跨 Agent 的关键状态变化；agent ledger 记录该 Agent 的具体行为。最终报告必须能从总 ledger 追溯到具体 agent ledger。

## 11. Cross-Session Recovery

跨 session 恢复必须是一等能力。旧框架中 `docs/plan.md` 作为恢复点的设计不变。

三类状态源：

```text
docs/plan.md
  人类可读的当前状态源：当前 Wave、下一步、阻塞项、active worktrees、gate 摘要。

.isparto/sessions/**
  机器事实源：ledger、state、worktree mapping、policy decision、incident。

docs/session-log.md
  历史完成记录：已完成 Wave、完成证据、关键决策、遗留风险。
```

`isparto start` 不能总是无条件新建 session。

启动逻辑：

```text
isparto start
  -> detect active / dangling session
  -> reconcile plan.md + session state + git/worktree state
  -> if active session exists:
       show B-layer recovery briefing
       offer resume / close / abandon / new
  -> if no active session:
       create new session
```

必须支持：

```bash
isparto resume
```

`isparto resume` 负责：

- 读取 active session state。
- 校验 worktree 是否存在。
- 校验 branch 是否存在。
- 校验 `docs/plan.md` 当前 Wave。
- 读取最近一条 `docs/session-log.md`。
- 对账 ledger、plan、Git 状态。
- 生成 B-layer recovery briefing。

如果 plan、ledger、Git 状态不一致，不允许模型自行猜测。必须进入 recovery flow，并在 report 中标记。

`docs/plan.md` 在 vNext 中仍然是跨 session 的人类可读恢复源；但它不是唯一事实源。最终事实必须通过 ledger 和 Git 状态校验。

## 12. Human-Readable Live Status

NDJSON 不是用户界面。用户不应该在 Agent 运行期间翻 `.isparto/sessions/<id>/events.ndjson`。

vNext 需要一个实时人类可读状态界面。

推荐新增：

```text
docs/session-status.md
```

`docs/session-status.md` 是自动生成、可覆盖的实时仪表盘，由 ledger 派生，不作为长期历史源。

默认策略：

- `docs/session-status.md` 默认 gitignored，不提交到仓库。
- 它和 `docs/plan.md`、`docs/session-log.md` 同在 `docs/` 下，是为了用户容易找到，不代表同样进入 Git 历史。
- `docs/plan.md` 是当前状态和恢复点，应该可提交。
- `docs/session-log.md` 是完成历史，应该可提交。
- 如果项目强制提交 `docs/session-status.md`，必须在 policy 中显式声明，并接受每次 session 带来的 diff churn。

必须显示：

- 当前 session id / branch / worktree。
- 当前 Wave 和 task groups。
- 正在运行的 role / Worker / executor。
- 每个 worktree 的状态。
- 最近 gate 结果。
- 当前 warning / halt / incident。
- 下一步建议。
- 哪些信息是 preventive / detective / advisory。

三份文档的分工：

```text
docs/plan.md
  当前可执行状态和跨 session 恢复点。

docs/session-status.md
  当前 session 的实时仪表盘，可覆盖。

docs/session-log.md
  session / Wave 完成后的历史记录，不用于实时滚动更新。
```

用户体验原则：

- A-layer 才打断用户。
- B-layer 用于恢复、决策和合入前 briefing。
- C-layer 写入 ledger / status / report，不打扰用户。
- 用户永远不需要读 NDJSON 才知道系统在干什么。

## 13. 角色-模型绑定和 CLI Executor 设计

第一版不是让用户执行 `isparto run claude`、`isparto run codex`、`isparto run kimi`。

正确模型是：

```text
用户触发 workflow
  -> Supervisor 选择模式和角色
  -> Role Orchestrator 调度 Team Lead / Developer / IR / DE / PO / Dynamic Workers
  -> 每个 Role 根据配置选择 executor + model
  -> Generic CLI Executor Adapter 启动对应 CLI
```

执行后端配置示例：

```yaml
executors:
  claude_cli:
    type: cli
    command: claude
    health: "claude --version"

  codex_cli:
    type: cli
    command: codex
    health: "codex --version"

  kimi_cli:
    type: cli
    command: kimi
    health: "kimi --version"
```

角色绑定配置示例：

```yaml
roles:
  team_lead:
    executor: claude_cli
    model: opus-4.7
    reasoning: max

  developer_implementation:
    executor: codex_cli
    model: gpt-5.5
    reasoning: xhigh

  developer_qa:
    executor: codex_cli
    model: gpt-5.5-mini
    reasoning: high

  independent_reviewer:
    executor: codex_cli
    model: gpt-5.5
    reasoning: xhigh

  doc_engineer:
    executor: claude_cli
    model: opus-4.7
    reasoning: xhigh

  process_observer_audit:
    executor: kimi_cli
    model: kimi-k2.6
```

Generic CLI Executor Adapter 负责：

- 验证 active session 是否存在。
- 验证当前分支是否匹配 session。
- 验证当前 cwd 是否是分配给该 session / agent 的 worktree。
- 发放或检查 role lease。
- 记录命令开始事件。
- 根据 role binding 在分配的 worktree 内启动对应 CLI。
- 尽量捕获 stdout、stderr、exit code、耗时。
- 记录运行前后的 Git diff。
- 运行后触发 policy check。
- 有违规时触发 halt。

Executor Adapter 不负责决定项目工作流。它只负责把某个 Role 的一次外部 CLI 执行翻译成受监督事件。

## 14. 机器可执行监督模型

vNext 的监督不能依赖自然语言理解，必须采用传统安全工程里的 policy enforcement 模型。

同时必须避免虚假安全感：policy enforcement 只能覆盖 iSparto 实际控制的边界。黑盒 CLI 内部行为如果没有可拦截 API，就必须标记为检测型控制，而不是预防型控制。

核心原则：

```text
Prompt = 协作协议
Policy = 可执行规则
Hook / Gate = Enforcement Point
Ledger = 审计证据
Halt = 安全失败状态
```

iSparto 直接代理或发起的关键动作，必须先变成结构化请求，再由 policy engine 决策。外部 CLI executor 内部自主发起的动作，只有在该 CLI 暴露 hook / permission / event stream 时，才能进入同样的逐动作预防型路径。

因此，完整 reference monitor 是长期目标，不是 v1 对黑盒 CLI 的默认承诺。v1 必须明确承诺边界：iSparto 控制得住的边界做预防型控制，控制不住的黑盒内部行为做检测型控制和强审计。

示例：

```json
{
  "principal": "developer_impl_1",
  "role": "developer",
  "executor": "codex_cli",
  "action": "file.write",
  "resource": "src/auth/session.py",
  "session_id": "s_20260427_153000",
  "lease_id": "lease_01",
  "worktree": "../.isparto-worktrees/isparto/fix-login-token",
  "branch": "fix/login-token",
  "phase": "implementation",
  "scope": ["src/auth/**", "tests/auth/**"],
  "policy_hash": "sha256:..."
}
```

Policy engine 只能基于结构化字段判断：

```text
principal has valid lease
role allows action
resource is in scope
resource is not denied
worktree matches lease
branch matches session
session is not hard_halted or investigation_required
policy hash matches
=> allow
```

否则：

```text
=> warn / block / investigation_required / hard_halt
```

作为目标架构，这个模型对应传统系统里的：

- Reference Monitor：所有访问都必须被统一检查。
- Complete Mediation：每次访问都检查，不只在启动时检查。
- Least Privilege：每个 role / worker 只拿完成任务所需的最小权限。
- Fail-safe Defaults：未知、缺配置、证据不一致时默认拒绝。
- Policy-as-Code：规则写成机器可执行 policy，不靠模型读懂自然语言。
- Admission Control：文件写入、命令执行、commit、push、session close 都在发生前或持久化前被 gate 检查。

参考模式：

- Saltzer & Schroeder 的安全设计原则：fail-safe defaults、complete mediation、least privilege。
- NIST ABAC：根据 subject、object、action、environment 的结构化属性做授权判断。
- Open Policy Agent：policy decision 和 policy enforcement 解耦。
- Kubernetes Admission Control：对象持久化前拦截，任何 validating gate 拒绝则请求失败。
- seccomp / allowlist 思路：默认拒绝，只有明确允许的系统能力可用。

### v1 Enforcement Boundary

v1 不能声称“所有 Agent 内部动作都被在线拦截”。v1 的真实 enforcement 分成三类。

预防型控制，v1 必须做到：

- `pre_role_run`：启动 role 前校验 session、lease、scope、worktree、branch、executor binding、policy hash。
- `pre_executor_launch`：只在分配 worktree 中启动 executor，并写入 cwd、env、pid、process group。
- `pre_commit`：Git hook 阻止 `hard_halted` / `investigation_required` session、scope violation、secret、高风险 policy violation。
- `pre_push`：Git hook 阻止保护分支、非 session 分支、secret、未通过 gate 的 push。
- `framework_tampering_denylist`：对 `.isparto/**`、policy、ledger、hooks、framework 文件的未授权修改直接 block 或 hard halt。
- `protected_branch_gate`：默认保护 `main`、`master`、`release/*`、`hotfix/*`。

检测型控制，v1 必须做到：

- file watcher 记录 worktree 变化，但不假设 watcher 永不丢事件。
- before / after diff 捕获 executor 运行前后的 Git diff。
- ledger reconciliation 对比 run context、diff、gate result、Git 状态。
- session close gate 在结束前统一检查未登记变更、policy mismatch、branch mismatch、report evidence。
- 最终 report 必须标注哪些风险是 post-hoc detected，而不是 pre-write prevented。

可选 hook 型控制，只有 executor profile 证明支持时才启用：

- CLI 内部 `command.run` 逐动作审批。
- CLI 内部 `file.write` / `file.delete` 逐动作审批。
- CLI tool-call event stream 的实时 policy decision。

如果某个 executor profile 没有这些能力，iSparto 不能把 `pre_command` / `pre_file_write` 标成 preventive，只能标成 detective 或 advisory。

### Policy Enforcement Points

vNext 至少需要这些 enforcement points：

- `pre_role_run`：role 没有 lease、worktree、scope、executor binding 时不能启动。
- `pre_executor_launch`：executor 启动前绑定 cwd、worktree、branch、env、pid / process group。
- `pre_command`：仅适用于 iSparto 直接发起的命令，或支持 command hook 的 executor；危险命令、未授权命令、保护分支操作直接 block / halt。
- `pre_file_write`：仅适用于 iSparto 直接代理的文件写入，或支持 file hook 的 executor；scope 外写入、denied path、framework tampering 直接 hard halt。
- `file_reconcile`：对黑盒 CLI 的实际文件变化做检测型对账；确认违规 hard halt，证据不足进入 `investigation_required`。
- `pre_commit`：commit 前检查 scope、secret、ledger、branch、`hard_halted` / `investigation_required` state。
- `pre_push`：push 前检查保护分支、secret、gate result、session state。
- `pre_merge_or_accept`：合入前检查所有 required gates。
- `session_close`：结束前检查 ledger、diff、report、plan evidence 是否一致。

每个 enforcement point 必须在实现和报告中标注控制类型：`preventive`、`detective` 或 `advisory`。

### Policy-as-Code 形态

第一版可以先用 Python 内置 policy engine，不必一开始引入 OPA / Rego / Cedar。但设计上要保留 policy-as-code 形态。

示例：

```yaml
policies:
  - id: deny_scope_violation
    effect: hard_halt
    when:
      action: ["file.write", "file.delete"]
      resource_not_in: "${lease.allowed_paths}"

  - id: deny_framework_tampering
    effect: hard_halt
    when:
      action: ["file.write", "file.delete"]
      resource_in: [".isparto/**", "isparto.policy.json", ".git/hooks/**"]

  - id: deny_protected_branch_push
    effect: hard_halt
    when:
      action: "git.push"
      branch_in: ["main", "master", "release/**", "hotfix/**"]
```

Policy evaluation 必须输出结构化 decision：

```json
{
  "decision": "hard_halt",
  "policy_id": "deny_scope_violation",
  "reason": "resource outside lease.allowed_paths",
  "event_id": "evt_..."
}
```

### 监督边界

自然语言可以用于解释为什么某个 gate 失败，但不能用于决定是否允许动作。

不允许的设计：

```text
让 Process Observer 读聊天记录，然后判断 Agent 是否越权。
```

允许的设计：

```text
hook-capable executor 捕获 file.write -> policy engine 判断路径是否在 scope -> ledger 记录 decision -> 必要时 halt。
```

对于无法 hook 到的黑盒 executor 内部行为，允许的设计是：

```text
executor 在 worktree 内运行 -> file watcher / git diff 发现变化 -> policy engine 判断变化是否合法 -> ledger 记录 decision -> 必要时 hard halt 或 investigation_required。
```

这种路径必须在 report 中标记为 detective control，不能伪装成 pre-write prevention。

## 15. 强流程监察

强流程监察不是单独产品，而是模型无关 framework 之上的强制执行层。

必须包含：

1. Pre-run gate
   - active session 必须存在。
   - 当前分支必须匹配 session 分支。
   - 当前 cwd 必须是 session / agent 分配的 worktree。
   - session 不能处于 `hard_halted` 或 `investigation_required` 状态。
   - role 必须有有效 lease。
   - role 绑定的 executor 必须被允许。

2. File watcher
   - 记录变化路径。
   - 检测 scope violation。
   - 检测 framework tampering。
   - 尽量检测未登记变更。
   - 不能假设 watcher 事件完整；最终必须由 Git diff / reconciliation 兜底。

3. Git gate
   - 阻止保护分支 commit/push。
   - 校验当前是否在 session 分支。
   - push 前校验 scope。
   - commit/push 前校验 `hard_halted` / `investigation_required` 状态。

4. Secret scanner
   - 扫描 staged 和 changed files。
   - 高置信度 secret 直接 block 或 halt。
   - 低置信度可疑内容进入 warning。

5. Bypass detector
   - 对比 ledger events 和 Git diff。
   - 标记没有 run context 的文件变化。
   - 检测不是在已知 session 中产生的 commit。
   - 检测 policy 或 ledger 被修改。
   - 检测 Agent 是否在未分配 worktree 中产生副作用。
   - 已确认违规进入 hard halt；证据不足但风险存在进入 investigation_required。

6. Session close gate
   - 最终报告前校验 ledger、diff、branch、policy 状态是否一致。

## 16. Halt 模式

Halt 是核心安全行为，但 vNext 必须区分“已确认违规”和“检测器不确定状态”。二者都不能静默放行，但报告语义和恢复方式不同。

vNext 定义三类安全状态：

```text
ok -> warn -> investigation_required -> hard_halted
```

### Hard Halt

`hard_halted` 表示已经确认发生高风险违规。触发条件：

- 已确认写入 allowed scope 之外的文件。
- 已确认修改 denied paths。
- 未授权修改 `.isparto/**`、policy、ledger、hooks 或 framework 内部实现。
- commit 或 push 到保护分支。
- 检测到高置信度 secret。
- 检测到危险命令。
- executor 启动时当前分支和 session 分支不一致。
- executor 启动时当前 cwd 不是分配的 worktree。
- session 已经 `hard_halted` / `investigation_required` 后仍有命令、commit、push 或文件变更。
- policy hash 不匹配且 active lease 仍试图继续执行。

### Investigation Required

`investigation_required` 表示 framework 发现严重不一致，但证据不足以断言已经违规。它不是普通 warning；进入该状态后必须停止继续调度 Agent，直到用户显式处理。

触发条件：

- ledger 和 Git 状态不一致，但无法判断是 watcher 丢事件、用户手工修改，还是 executor 绕过。
- 检测到疑似 executor / role 绕过，但缺少确认性证据。
- 发现未登记文件变更，但无法确认 actor。
- Markdown contract 解析失败，导致 `plan.md`、spec 或 Backlog 状态不可判定。
- session 中途 `isparto.policy.json` 变化，active lease 的 `policy_hash` 与当前 policy 不一致。
- IR 隔离、review packet 或 worktree 映射出现不完整证据。

### Warn

`warn` 表示需要显著上报，但不应阻止低风险读操作或报告生成。

触发条件：

- 低置信度 secret 或敏感信息疑似命中。
- advisory gate 失败。
- IR 无法跨 provider，只能降级为同 provider review。
- 可选文档证据缺失，但 ledger、diff、gate 的核心证据完整。
- File watcher 报告轻微丢事件，但 Git diff / reconciliation 已确认无违规。

`hard_halted` 后效果：

- session 状态变为 `hard_halted`。
- revoke 当前 session / role lease。
- 后续 `run`、`commit`、`push`、`accept` 被阻止。
- 终止由 iSparto 启动并登记的 executor 进程组。
- 写入 HALT sentinel，供 hooks、watcher、CLI 统一识别。
- 生成 incident report。
- 保留当前 diff 和证据。
- 用户必须显式选择 `resume`、`rollback` 或手动处理。

`investigation_required` 后效果：

- session 状态变为 `investigation_required`。
- 暂停新的 role / worker 调度。
- 阻止 commit、push、accept、release。
- 终止仍在运行的 registered executor process group。
- 写入 INVESTIGATION sentinel，供 hooks、watcher、CLI 统一识别。
- 生成 incident report，并明确标注“未确认违规，但证据不一致”。
- 用户必须显式选择 `resume --ack-investigation`、`rollback`、`mark-benign` 或手动处理。

`warn` 后效果：

- 不阻止 session 继续运行。
- 必须进入 `docs/session-status.md`、ledger 和最终 report。
- 如果同类 warning 重复出现，Process Observer 可以升级为 `investigation_required`。

### Halt 执行等级

Halt 不能只是逻辑状态。vNext 定义三层 halt：

1. **Logical Halt**
   - session state 写为 `hard_halted` 或 `investigation_required`
   - lease revoke
   - 后续工作型 iSparto 命令拒绝运行；只允许 report、resume、rollback、mark-benign 等恢复命令
   - hooks 根据 HALT / INVESTIGATION sentinel 阻止 commit / push

2. **Process Halt**
   - iSparto 启动 executor 时记录 pid / process group
   - halt 时终止对应 process group
   - 如果进程无法终止，report 必须显著提示

3. **Worktree Freeze**，可选增强
   - 将 worktree 临时改成不可写，或通过平台能力冻结写入
   - 第一版不默认依赖 `chmod -R -w`，因为跨平台恢复、Git 文件权限、副作用都需要额外验证
   - 后续可作为 `isparto freeze-worktree` 或 strict mode 能力

第一版最低要求是 Logical Halt + Process Halt。`hard_halted` 和 `investigation_required` 都必须停止已登记 executor 的继续运行；只有记录状态而不停止 executor，不满足 vNext 的 halt 要求。

Incident 路径示例：

```text
.isparto/sessions/<session-id>/incident.md
```

## 17. Commit 和 Push 策略

Agent 允许 commit 和 push 自己的任务分支。

允许：

- 在 session 分支上 commit。
- push session 分支。
- 在 Agent Team 模式下，commit/push 自己被分配的 agent 子分支。
- 创建或更新 PR 分支。

阻止或 halt：

- commit 到 `main`、`master` 或配置的保护分支。
- push 到保护分支。
- hard_halted 后继续 commit。
- hard_halted 后继续 push。
- investigation_required 后继续 commit。
- investigation_required 后继续 push。
- commit 中包含 scope violation。
- push 中包含 secret。
- push 中包含未处理 policy violation。
- 从未绑定当前 session 的分支 push。
- 从未绑定当前 session 的 worktree commit/push。

这个策略保证任务分支可以快速推进，同时保护分支始终由用户控制。

## 18. 用户命令

用户命令必须是 workflow 级别，而不是模型级别。用户不应该直接关心“现在跑 Claude 还是 Codex 还是 Kimi”；用户关心的是开始工作、计划、执行、结束、回滚和健康检查。

第一版用户入口建议保持接近现有 slash command 语义：

```bash
isparto init-project
isparto migrate
isparto start "实现 Kimi CLI adapter" --scope "src/isparto/**,tests/**"
isparto resume
isparto plan
isparto work
isparto security-audit
isparto end
isparto release
isparto rollback
isparto doctor
```

这些命令的含义：

- `isparto init-project`：为新项目生成 iSparto 结构、模板、policy、role binding、hooks 和最小文档骨架。
- `isparto migrate`：把 v0.x / 旧 slash command 项目迁移到 vNext framework，生成迁移报告，不静默删除旧文件。
- `isparto start`：创建 session、生成任务分支、创建 worktree、加载角色配置、启动监督。
- `isparto resume`：从 `docs/plan.md`、session ledger、Git/worktree 状态恢复未完成 session。
- `isparto plan`：由 Team Lead / Architect 能力产出计划和模式选择，不直接暴露模型。
- `isparto work`：按 Solo 或 Agent Team 模式调度角色。Team Lead、Developer、IR、DE、PO 以及动态 Worker 的调用由 Role Orchestrator 决定。
- `isparto security-audit`：运行独立安全审计，可作为 session gate 或单独审计任务。
- `isparto end`：运行 gate、审计、报告、commit/push/PR 流程。
- `isparto release`：运行 release gate、changelog、tag、push、发布说明流程；禁止 Agent 绕过该 workflow 手动 tag / push。
- `isparto rollback`：回滚 session / worktree / branch。
- `isparto doctor`：检查 executor、role binding、hooks、worktree、git gate 是否健康。

内部或调试命令可以存在，但不作为主用户界面：

```bash
isparto role run team-lead
isparto role run developer
isparto role run independent-reviewer
isparto executor health
```

直接在任务分支上运行 `git commit` 和 `git push` 可以允许，但 Git hooks 必须执行同样的 policy。模型选择不能通过用户命令硬编码，必须来自 role binding。

## 19. 数据布局

推荐本地状态：

```text
.isparto/
  config.json
  policy.json
  roles.json
  executors.json
  HALTED
  INVESTIGATION_REQUIRED
  sessions/
    <session-id>/
      state.json
      events.ndjson
      worktrees.json
      waves.json
      policy.lock.json
      before.patch
      after.patch
      report.md
      incident.md
      agents/
        <actor-id>/
          events.ndjson
          stdout.log
          stderr.log
  review-packets/
    <wave-id>/
docs/
  plan.md
  session-status.md
  session-log.md
```

`.isparto/sessions/**` 默认是本地运行状态。

Worktree 本体默认放在仓库外的兄弟目录：

```text
../.isparto-worktrees/<repo-name>/<branch-slug>/
```

`.isparto/sessions/<session-id>/worktrees.json` 记录 session、agent、branch、worktree path 的映射。

项目级可复用 policy 后续可以放在：

```text
isparto.policy.json
```

这样可以把本地 session 历史和可提交的项目 policy 分开。

Policy 优先级：

```text
framework hard invariants
  > active session lease
  > project policy
  > local defaults
```

冲突处理：deny / halt 覆盖 allow。任何低优先级 policy 不能放宽 framework hard invariants。

Active session 启动时必须记录 `policy_hash`。session 中途 policy 变化时：

- 新 role / worker lease 必须使用新 policy hash。
- 旧 lease 默认失效，不能继续执行。
- 如果已有 executor 正在运行，session 进入 `investigation_required`，直到用户确认继续、重发 lease 或 rollback。
- report 必须记录 policy 变化前后的 hash、影响到的 lease 和恢复动作。

### 配置文件 Formal Schema

`roles.json`、`executors.json`、`policy.json`、`isparto.policy.json`、`state.json` 不能只靠示例驱动实现。v1 必须定义 formal schema，再写 loader 和 validator。

第一版实现建议：

- 使用 Pydantic model 作为 framework schema 和 validation source。
- 从 Pydantic model 生成 JSON Schema，供文档、模板和 `isparto doctor` 使用。
- 所有配置读取必须经过 schema validation；失败时不能让模型猜字段含义。
- schema version 必须写入配置文件，支持未来 migration。
- unknown field 默认 warning 或 block，由文件类型决定；policy / role contract 中的 unknown high-risk field 默认 block。

第一批 schema：

- `RoleContract`
- `ExecutorProfile`
- `PolicyDocument`
- `SessionState`
- `WaveState`
- `Lease`
- `WorktreeBinding`
- `GateResult`
- `ReportMetadata`

配置 schema 的字段细节可以进入 implementation spec，但本文档必须把“schema first”作为实现约束。

## 20. 报告要求

报告必须能让用户在三分钟内判断当前任务状态。

必须包含：

- task
- branch
- worktree
- 本次使用了哪些 role
- 每个 role 绑定了哪个 executor / model
- 每个 executor 的 capability / visibility 边界
- 每个 gate 是 preventive、detective 还是 advisory
- 改了哪些文件
- 创建了哪些 commit
- push 状态
- scope 状态
- secret scan 状态
- framework tampering 状态
- suspicious 或 unregistered changes
- policy warnings
- halt incidents
- investigation_required incidents
- hard_halted / investigation_required / warn 分级状态
- 建议：accept、manual review、rollback，或修复后 resume

如果出现任何疑似绕过，即使最终 check 通过，也必须在报告中显著显示。

## 21. Rollback 模型

第一版 rollback 以 Git + worktree 为主。

Session start 时记录：

- 起始分支
- 起始 commit
- 起始 working tree patch
- 生成的任务分支
- 生成的 worktree path
- agent 分支和 worktree 映射

Rollback 选项：

- 丢弃任务分支上的工作区变更。
- revert 任务分支上的 session commits。
- 放弃任务分支。
- 删除 session worktree。
- 删除或保留 agent worktree 作为 incident 证据。
- 切回用户原始分支。

Rollback 绝不能静默改写保护分支。

## 22. 迁移与共存

vNext 在当前仓库内重构，但不能让旧 iSparto 用户和本仓库自身开发流程断档。

### 旧框架状态

现有 Claude Code 绑定式架构进入 `legacy/reference` 状态：

- 不继续扩展新能力。
- 只接受关键修复、文档修正和迁移必要改动。
- 旧 slash command 的行为作为迁移参考，不作为 vNext 长期架构。
- vNext dogfood 达到成功标准前，旧入口不能被静默删除。

### 仓库内共存

建议物理布局：

```text
legacy/
  claude-code-bound-framework/
src/
  isparto/
docs/
  vnext/
```

如果最终实现不采用上述路径，也必须满足：

- vNext framework 代码和 legacy reference 可清晰区分。
- legacy 文档不能继续作为 active framework authority。
- `docs/plan.md`、`docs/session-log.md`、`docs/independent-review.md` 的语义必须在迁移后保持可读。

### init-project

`isparto init-project` 面向新项目，负责生成：

- `docs/plan.md`
- `docs/session-status.md`
- `docs/session-log.md`
- product / tech / design spec 模板
- `isparto.policy.json`
- role binding / executor profile 模板
- Git hooks
- `.isparto/` 本地状态目录
- `CLAUDE.md` 或通用 agent instruction 模板

初始化不能假设用户只使用 Claude Code。默认模板必须是模型无关的 role / executor 结构。

### migrate

`isparto migrate` 面向存量项目，负责：

- 检测旧版 `CLAUDE.md`、slash commands、templates、install scripts、plan.md、session-log.md。
- 生成 migration report。
- 把旧角色、命令、文档纪律映射到 vNext role contract、gate 和 policy。
- 保留旧文件或移动到 legacy/reference，不静默删除。
- 保留 `docs/plan.md` 的当前 Backlog 和恢复语义。
- 为旧项目生成最小 `isparto.policy.json` 和 role binding。
- 标记无法自动迁移的命令、模板和项目约束。

v0.8 迁移必须额外处理：

- 识别 `~/.claude/settings.json` 中旧 slash command 注册项。
- 不自动删除用户全局 Claude 配置；只生成清理建议和可执行 migration script，由用户确认后执行。
- 检查旧 `commands/*.md` 是否仍被全局设置引用，避免用户以为已迁移但仍调用旧入口。
- 兼容旧 `docs/plan.md` 格式；能自动识别 Backlog / current work / session history 的迁移到新 contract，不能识别的进入 migration report。
- 将旧 `CLAUDE.md` 的项目协议映射为 vNext agent instruction，并把可执行规则拆到 `isparto.policy.json`。
- 标记旧模板中与模型绑定强相关的内容，迁移成 role / executor binding。

迁移过程本身必须运行在独立 worktree / branch 中，并经过 Doc Engineer、Process Observer 和用户确认。

### 安装和切换

`install.sh`、`bootstrap.sh` 或未来 installer 需要支持分阶段切换：

- v0.x 项目可以继续使用旧入口。
- vNext 可以 opt-in 安装，不强制覆盖旧命令。
- 默认切换到 vNext 之前，必须通过 dogfood 成功标准。
- 切换后仍需提供 rollback 到旧入口的说明或脚本。

### Release Workflow

`isparto release` 是产品级自动化承诺，不是普通 Git 包装。

必须包含：

- release readiness gate
- changelog check
- version / tag check
- security audit check
- protected branch check
- final report
- tag / push / publish step

Agent 或用户直接手动 tag / push release，默认视为 workflow violation，除非使用显式 emergency override 并写入 report。

## 23. 实施计划

### Phase 0：Executor Capability Spike

交付：

- Claude Code CLI capability matrix
- Codex CLI capability matrix
- Kimi CLI capability matrix
- headless / batch / stream-json 可用性验证
- cwd / worktree 参数验证
- tool restriction / permission mode 验证
- stdout / stderr / exit code / stream event 捕获验证
- executor process group 记录和终止验证
- 黑盒内部行为是否可见的边界说明
- 每个 executor 的 hook / permission / event stream 能力分级
- 每个 executor 的 preventive / detective / advisory control matrix

Phase 0 是 blocker。没有完成 capability spike，不进入 Role Execution Layer 实现。

当前本机初步观察：

- Claude Code 支持 `-p/--print`、`--output-format json|stream-json`、`--input-format stream-json`、`--worktree`、`--allowedTools/--disallowedTools`、`--permission-mode`。
- Codex 支持 `codex exec` 非交互执行，并支持 `--sandbox`、`--ask-for-approval`、`--cd`。
- Kimi 支持 `--print`、`--input-format stream-json`、`--output-format stream-json`、`--work-dir`、`--prompt`。

这些只证明三者存在可编程入口，不证明 iSparto 能实时拦截其内部 tool calls。内部可见性必须作为 capability matrix 的独立字段。

### Phase 1：设计文档、项目骨架和最小安全基线

交付：

- 本设计文档
- Python package skeleton
- `isparto --help`
- config loading
- basic session state
- minimal policy engine
- HALT sentinel
- protected branch denylist
- minimal secret scanner
- minimal framework tampering check
- v1 enforcement boundary 文档化
- structured Markdown contract 草案
- Documentation Language Convention 草案
- `plan.md` Backlog 单源 contract 草案

### Phase 2：Session、Worktree 和最小 Halt

交付：

- `isparto start`
- `isparto resume`
- 人类可读分支名生成
- worktree 创建和绑定
- session state files
- scope parsing
- protected branch detection
- Logical Halt
- Process Halt for registered executor process groups
- `investigation_required` 状态和 sentinel
- session close 最小 reconciliation
- `docs/session-status.md` 自动生成
- `docs/plan.md` 恢复点对账
- policy hash lock 和 active lease invalidation

### Phase 3：Role Execution Layer 和 CLI Executor

交付：

- role binding loader
- executor profile loader
- executor capability detection
- dynamic Worker / role instance spawning
- `isparto work`
- 内部 `isparto role run <role>`
- before/after diff capture
- event ledger
- wave lifecycle events
- Wave branch / worktree / ownership map 绑定
- IR cross-provider preference 和 degraded isolation 标记
- executor health checks

### Phase 4：完整 Policy 和 Gate Pipeline

交付：

- scope check
- denied path check
- protected branch gate
- secret scan
- dangerous command baseline
- full halt state
- `hard_halted / investigation_required / warn` 分级
- incident report
- mode selection gate
- wave boundary gate
- implementation gate
- qa gate
- doc-sync gate
- Doc Engineer audit checklist 分解
- language convention gate
- plan.md contract gate
- process-observer gate
- `isparto security-audit`

### Phase 5：Git Gates

交付：

- pre-commit hook
- pre-push hook
- session branch validation
- hard_halted session block
- investigation_required session block
- push 前 scope 和 secret check

### Phase 6：Init、Migration、End、Report 和 Rollback

交付：

- `isparto init-project`
- `isparto migrate`
- `isparto end`
- `isparto rollback`
- end 内部完成 gate check、report generation、commit/push/PR 判断
- `docs/session-log.md` Wave completion 写入
- migration report
- legacy/reference 共存路径
- 三分钟可读 summary report

### Phase 7：Release Workflow

交付：

- `isparto release`
- release readiness gate
- changelog / version / tag check
- security audit precondition
- protected branch and emergency override handling
- release report

### Phase 8：Dogfood

在本仓库中真实使用 iSparto vNext 跑任务。

持续记录：

- false positives
- missed bypasses
- report 是否足够有用
- rollback 是否可靠
- 作者是否会自然地在 Agent 工作前使用它

## 24. 测试策略

安全框架没有测试计划不可接受。vNext 的测试不是实现后的补充，而是每个 phase 的出门条件。

### 测试层级

1. Policy engine tests
   - 单元测试覆盖 allow / warn / block / investigation_required / hard_halt。
   - property tests 覆盖 deny 优先、低优先级 policy 不能放宽 hard invariant、policy hash 变化使旧 lease 失效。
   - 路径规范化测试覆盖 `../`、symlink、大小写差异、绝对路径、repo 外路径、Unicode 近似字符。
   - malicious path injection 测试覆盖 `.isparto/**`、`.git/**`、`.env`、submodule、generated paths。

2. State machine tests
   - 覆盖 `created -> running -> warn -> merge_conflict_pending -> investigation_required -> hard_halted -> rolled_back / closed` 等合法转换。
   - 非法转换必须失败，例如 `hard_halted -> accepted`、`investigation_required -> push`。
   - resume / rollback / mark-benign 必须有明确前置条件和 evidence。

3. Worktree and Git tests
   - 多 session 并发创建 worktree。
   - 同分支多 worktree checkout 失败路径。
   - hook dispatcher 在不同 worktree / branch / cwd 下定位正确 session。
   - pre-commit / pre-push 在 hard_halted 和 investigation_required 下阻止提交。
   - submodule 默认 block，显式授权时运行递归 gate。
   - Agent Team 子分支 merge gate、冲突路径、冲突解决 commit。

4. Executor adapter tests
   - Claude / Codex / Kimi profile 的 command rendering、cwd、env、stdin/stdout/stderr、exit code、process group。
   - executor 退出后 before / after diff capture。
   - executor 卡死、崩溃、输出格式异常、stream-json 中断。
   - process halt 能终止已登记进程组，失败时进入 report。

5. Ledger and reconciliation tests
   - ledger event schema validation。
   - file watcher 丢事件时由 Git diff 兜底。
   - 未登记变更进入 investigation_required。
   - report 中 control type 正确标注 preventive / detective / advisory。

6. Migration tests
   - v0.8 `CLAUDE.md`、旧 slash commands、旧 `docs/plan.md`、`~/.claude/settings.json` 引用检测。
   - migration report 不静默删除旧入口。
   - 旧 plan Backlog 迁移到新 structured Markdown contract。

7. End-to-end dogfood scenarios
   - Solo happy path。
   - Agent Team 多 Worker happy path。
   - Worker scope violation。
   - secret scan hit。
   - framework tampering。
   - merge conflict。
   - policy changed mid-session。
   - interrupted session resume。
   - rollback。

### 测试技术选择

第一版 Python 实现建议：

- `pytest` 作为基础测试框架。
- `hypothesis` 做 policy 和 path normalization property tests。
- 临时 Git repo fixture 覆盖 worktree、branch、hook、merge、submodule 场景。
- fake executor binary / script 模拟 Claude、Codex、Kimi 的成功、失败、卡死和异常输出。
- Golden report tests 验证 report 不隐瞒 control boundary、warning、investigation、halt。

### Phase Gate

每个 phase 必须有对应测试证据：

- Phase 1 不能没有 policy engine 和 schema validation tests。
- Phase 2 不能没有 state machine、worktree、halt / investigation tests。
- Phase 3 不能没有 executor adapter fake tests。
- Phase 4 不能没有 gate pipeline 和 malicious path tests。
- Phase 5 不能没有真实 Git hook tests。
- Phase 6 不能没有 migration fixture。
- Phase 7 不能没有 release dry-run tests。
- Phase 8 dogfood 必须记录 missed bypasses 和 false positives。

## 25. 成功标准

第一版成功标准：

- 作者会自然用 `isparto start` 开始 Agent 工作。
- Claude Code、Codex、Kimi 都能作为 executor 绑定到角色。
- Claude Code、Codex、Kimi 的 capability matrix 已完成，并明确哪些控制是预防型、哪些只是检测型。
- v1 不声称能实时拦截黑盒 CLI 内部每个 tool call；report 能诚实展示控制边界。
- Team Lead、Developer、Independent Reviewer、Doc Engineer、Process Observer 是稳定角色；动态 Worker 是 Team Lead 或 Role Orchestrator 按需派生的执行实例。
- Wave 是 Agent Team 并行、边界审计和 plan 组织的基本单元。
- Wave 具备 branch / worktree / ownership / close-out / session-log completion 语义。
- `docs/plan.md` Backlog 是唯一当前 TODO 源。
- `docs/plan.md` 仍然是跨 session 的人类可读恢复源。
- `docs/session-status.md` 能在 Agent 运行期间展示实时状态，不要求用户阅读 NDJSON。
- Independent Reviewer 至少满足 L1 context blind + L2 review packet + partial L3 environment narrowing。
- Independent Reviewer 默认跨 provider；无法做到时 report 标记 degraded isolation。
- Documentation Language Convention 和 Doc Engineer audit checklist 已迁移。
- Memory、项目级 instruction、policy 的权限边界清晰。
- `isparto init-project`、`isparto migrate`、`isparto security-audit`、`isparto release` 存在可用路径。
- v0.x / legacy reference 有明确迁移与共存策略。
- 任务分支名人类可读。
- Solo 和 Agent Team 都默认使用独立 worktree。
- 每个 session / agent 都有独立日志。
- Agent 可以 commit 和 push 任务分支，但不能触碰保护分支。
- 已确认 scope 外写入会 hard halt。
- framework tampering 会 hard halt。
- 疑似绕过或证据不一致会进入 investigation_required，并停止继续调度。
- hard_halted 和 investigation_required 会终止 iSparto 登记的 executor process group，而不只是写状态。
- 最终报告比翻聊天记录更快理解。
- Agent 跑坏后 rollback 可用。
- Policy engine、state machine、worktree、Git hook、migration、executor adapter 都有自动化测试覆盖。
- 恶意路径注入、worktree 并发、Agent Team merge conflict、policy mid-session change 都有回归测试。

## 26. 待 review 问题

1. Python 第一版是否接受包管理和分发成本，还是需要在 dogfood 后评估 Go / Rust 单二进制迁移？
2. `plan.md`、spec、Backlog 的 structured Markdown contract 第一版采用 frontmatter、固定 heading，还是 YAML sidecar？
3. 旧 slash commands、templates、install scripts 的迁移映射是否需要全部自动化，还是第一版允许 migration report 标记人工处理项？
4. emergency override 在 release / hotfix 场景下如何授权、记录和回滚？
5. 各 role 绑定 executor 后，第一版是把 role prompt 作为 CLI 参数传入、stdin 传入，还是按 executor profile 分别实现？
6. 第一版 secret scanner 是否只用内置规则，后续再可选接 gitleaks？
7. 修改 iSparto framework 自身实现文件时，`framework_edit_lease` 的用户确认粒度是 session 级、Wave 级，还是单次 role run 级？
8. formal schema 的 source of truth 是否采用 Pydantic model，并从中生成 JSON Schema？
9. Agent Team 默认 merge 策略是否固定为 `--no-ff`，还是按 Wave 风险等级允许 fast-forward？
