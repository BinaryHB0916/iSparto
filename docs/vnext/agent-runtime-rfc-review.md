# iSparto vNext Agent Runtime RFC 评审反馈

读完 `docs/vnext/agent-runtime-rfc.md` 全文。整体判断：方向对、原则对、骨架对——角色分离、spec-driven 流向、worktree+branch+log 三层隔离、halt 模型、ledger 作为事实源、policy-as-code 的方向都把握住了。但有两类问题需要在开 Phase 1 之前修订。一类是 RFC 内部一致性 / v1 可实施性问题；另一类是当前 iSparto 一年多 dogfooding burn 出来的纪律没有 carry over 过来。下面分两部分讲。

## 一、RFC 内部一致性 / v1 可实施性问题

### 1. Section 11 的 enforcement 模型在 v1 做不到

RFC 把 vNext 描成 reference monitor 风格的运行时——每次 `file.write`、`command.run` 都生成结构化请求让 policy engine 决策 allow / halt。这个模型的前提是每个动作都过 supervisor。但执行后端是外部 CLI：Claude Code 一旦跑起来，它的 Bash tool、Edit tool 是自己内部调用的，supervisor 完全看不到，除非接每个厂商 CLI 的私有 hook 协议。而 Section 3 又明确说不做这件事。两者冲突。

把 Section 10 (Adapter) 和 Section 12 (实际监察手段) 拼起来看，v1 真正能拿到的 enforcement 只有四层：启动前 lease / scope / worktree 校验、git hooks（pre-commit / pre-push，借 git 自己 enforce）、filesystem watcher（post-hoc，best effort）、退出后 reconciliation 和 session_close gate。这四层其实够用，但 Section 11 读起来像还存在第五层"每个 agent 动作都被在线拦截"——这层在不接 CLI 私有 hook 的前提下根本不存在。

建议在 Section 3 或 Section 11 明确写出：v1 enforcement 主要是 pre-launch + git hooks + post-hoc reconciliation，in-flight 逐动作拦截不在 v1 承诺范围，仅在 CLI 暴露 hook 表面时按 profile 选配。否则 Phase 4（Policy 和 Halt）会朝着一个 v1 做不出来的目标推进。

### 2. Section 13 的 halt 触发列表过激

它把"已确认违规"和"检测器不确定状态"混在一起。前者比如保护分支 push、确认的 secret、scope 外写入 denied path，fail closed 没问题。后者比如 "ledger 和 Git 状态不一致" 和 "疑似 executor 绕过"，假阳性率会很高，因为 fsevents/inotify 在负载下会丢事件，reconciliation 必然偶发对不上。

一个用户被无关 halt 三五次之后就会自然绕过 iSparto，这是所有强监察系统的死法。Section 4 原则 5 "fail closed" 没错，但 fail closed 的对象应该是已确认的违规，不是检测器的不确定状态——后者 fail closed 等于把检测器的脆弱性转嫁给用户。

建议拆两档：hard halt（已确认违规）和 strong warn（检测器不确定，进 report 高亮 + 显式确认），不要全部走 fail closed。

### 3. Section 21 待 review 问题应该补几条

现在 5 条都是细节问题。下列几条更关键：

- v1 enforcement 的实际边界（接受 in-flight 拦截不存在、靠 git hooks + post-hoc）；
- Python vs Go/Rust 的选择理由（影响分发体验，独立开发者装 Python + pip 比单二进制麻烦）；
- plan.md / product-spec / tech-spec 都是 markdown，Python runtime 怎么解析（继续让 LLM 读，LLM 又回到信任链；切结构化，是独立设计）；
- session 中途用户改 `isparto.policy.json` 导致 `policy_hash` 不匹配的语义（halt？无效化所有 lease？继续用旧 policy？）；
- session 之上的 Wave 抽象（见 Part 二第 4 条）在 vNext 是否保留。

## 二、当前 iSparto 精要的承接缺口

下面这些是当前 iSparto 跑了一年多 dogfooding 才长出来的纪律，RFC 要么没说、要么只点到名字。它们不是 first principle 推出来的 feature，是 burn 出来的——vNext 不显式 carry over 会再 burn 一遍。

### 1. plan.md Backlog 是唯一 TODO 源

所有 TODO、Process Observer audit findings、user-direction commitments、Wave 内 deferral，全部进 plan.md Backlog，写到其他地方就是 workflow violation；专门有 `plan-md-contract-check.sh` 做机械检测，/end-working 强制执行。RFC 只把 plan.md 描述成 "current state source"，单源约束完全没说。

### 2. Documentation Language Convention（四层语言架构）

Tier 1 系统提示纯英文（保证指令稳定 + 非中文协作者可读）、Tier 2 参考文档英文、Tier 3 用户入口双语、Tier 4 历史归档冻结；加上"Tier 1 文件不能硬编码用户可见字符串"的 Principle 1，由 `language-check.sh` 守门。RFC 完全没提，这是搬过去就能减少长期 drift 的现成资产。

### 3. Memory 与 CLAUDE.md 的领域协议

memory 是 "who you work with"（read-only input），CLAUDE.md 是 "how to work"（authority）；三级响应模型（无条件尊重 / 有条件尊重 / 仅记录不执行）；冲突时执行 CLAUDE.md，不改 memory。RFC 直接把这两件事降维成 isparto.policy.json，丢掉了"项目级自然语言行为指引"和"用户偏好读取"各自的位置。

### 4. Wave 模型

Wave 是原子工作会话、独立分支、T10 close-out、Wave 完成条目由 /end-working 在同一 commit 写入 plan.md、commit count 用 `git log --no-merges | wc -l` 机械验证。RFC 只有 session 一级抽象；当前 iSparto 是 session 之上还有 Wave 的两级。

### 5. Doc Engineer audit checklist 分解

当前 /end-working 的 DE 审计是 11+ 项结构化清单（language-check、policy-lint、plan-md-contract-check、Tier 1/2 CJK 扫描、Principle 1 violation 扫描等）。RFC 只有一个 doc_sync_gate 没分解，这层是当前框架防文档腐化的主力。

### 6. 自我指涉边界（self-referential boundary）

当前 CLAUDE.md 明文写：本项目就是框架本身，Tier 1 文件 Lead 直接编辑、Codex 要求不适用。vNext 自己开发期内同样需要这条豁免，"用户项目本身就是 framework / library" 的场景也需要。RFC 没写。

### 7. 新项目启动 + 迁移整条线缺失

/init-project、CLAUDE-TEMPLATE.md、5 个 structural templates、/migrate、install.sh、bootstrap.sh、`lib/snapshot.sh`——Section 19 七个 phase 一个都没提。没有 /init-project 新用户进不来，没有 /migrate 存量用户卡在 v0.x。

同时 vNext 在同一仓库内重构、旧架构进 legacy，但没说 Phase 1-6 期间旧 slash command 系统怎么处理（冻结？只接关键修复？），已经装 v0.x 的存量用户怎么过渡，旧的 plan.md / commands/*.md 在 vNext 下还有没有语义。建议加一节"迁移与共存"。

### 8. 用户命令缺四个

Section 15 列了 6 个（start / plan / work / end / rollback / doctor），当前 iSparto 实际有 10 个：缺 /init-project、/migrate、/security-audit、/release。/release 在 CLAUDE.md 里专门写"必须用 /release，手动 git tag/push 不允许"，是产品级自动化承诺，不能默认丢。

### 9. 跨厂商隔离原则

当前 IR 用 Codex MCP server 在 tmux pane 跑，理由写明是 "cross-provider isolation on top of zero inherited context"。RFC 提了 IR 零继承上下文，但"跨厂商"这条没明说。改成 codex_cli 直接 cli_exec 之后默认仍是跨厂商，但要不要把"IR 必须跑在与 Lead 不同的供应商"作为硬约束写进 role contract，需要明确。

## 三、建议的修订动作

把这份反馈 actionable 化的话，下次改 RFC 时建议这五个动作：

**1. Section 3 / Section 11 澄清 v1 enforcement 实际边界**：pre-launch + git hooks + post-hoc reconciliation 是 v1 承诺；in-flight 逐动作拦截依赖 CLI hook profile，不是 v1 默认能力。

**2. Section 13 拆 hard halt 与 strong warn 两档**：把 reconciliation 类不确定状态从 fail closed 列表里挪走。

**3. 加一节"当前 iSparto 必须 carry-over 的纪律清单"**：列出至少 plan.md Backlog 单源、Doc Language Convention、Memory/CLAUDE.md 领域协议、Wave 模型、DE audit checklist 分解、自我指涉边界、跨厂商隔离原则、release / security-audit / init-project / migrate 用户命令——每一项标 Phase 几落地。否则 vNext 是一个干净但失忆的新框架，不是 iSparto 的下一代。

**4. 加一节"迁移与共存"**：明确旧框架冻结策略、仓库内物理布局、install.sh 切换时机、`/migrate` 怎么帮存量项目升级。

**5. 扩充 Section 21 待 review 问题**：把 v1 enforcement 边界、Python 选择理由、markdown spec 解析策略、`policy_hash` 中途变更语义、session vs Wave 双层抽象去留这几条加进去。

把这些改完，RFC 就从"一份方向对的草案"变成"一份能开工的 RFC"。架构层做得已经很完整；缺的是把当前 iSparto 跑出来的纪律明文写进新世界。
