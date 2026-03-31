# Session Log

## 2026-03-24 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 2 (快照/恢复系统) + Wave 4 (自举迁移) + Wave 5 (Dogfooding 验证) |
| Tasks completed | 快照/恢复系统全部完成, 自举迁移完成, Session Log 功能, README 实测章节 |
| Developers spawned | 4 (2 for session-log feature, 2 for README benchmark) |
| Codex reviews | 2 (1 for snapshot system, 1 for session-log feature) |
| Codex catches | snapshot: 无 (uncommitted review); session-log: 2 P2 — git diff --stat 不完整 + diff 输出破坏 Markdown table |
| Key decisions | 统一快照系统设计(metadata.txt+files.txt), 向后兼容旧manifest, iSparto自举使用自己的工作流, session log自动采集替代手动记录, 升级功能列入backlog |

### Files Changed
```
 CLAUDE.md                 |  78 ++++++
 README.md                 |  47 +++-
 README.zh-CN.md           |  47 +++-
 commands/end-working.md   |  33 ++-
 commands/env-nogo.md      |  11 +-
 commands/init-project.md  |  26 ++-
 commands/migrate.md       |  19 ++-
 commands/restore.md       |  30 ++++++
 commands/start-working.md |  12 +-
 docs/plan.md              |  65 ++++++
 docs/product-spec.md      |  52 ++++++
 docs/session-log.md       |   (this file)
 docs/troubleshooting.md   |   3 +-
 docs/user-guide.md        |   3 +-
 docs/workflow.md          |   5 +-
 install.sh                | 141 +++++++++---
 lib/snapshot.sh           | 350 ++++++++++++++++++++++++++++++
 17 files changed, 900+ insertions
```

### Notes
- 本次是 iSparto 首次完整自举运行，用自己的 Agent Team 工作流开发自己的功能
- 跑了两次完整的 Agent Team 流程（session-log + README benchmark），每次都是 2 Developer 并行
- 用户提出"升级功能"缺失，已加入 backlog，下次会话优先处理
- ~/.claude/commands/end-working.md 是安装时的旧版本，还没包含 session log 步骤；下次 install.sh 更新后会同步

## 2026-03-24 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 升级系统 (--upgrade + VERSION + CHANGELOG), 文档术语修复, Doc Engineer 三层职责升级, 全面文档审计 (22 项), CONTRIBUTING.md + Issue 模板, GitHub Issues Pro 标记, Lead 主动建议行为 |
| Developers spawned | 10 (2 upgrade, 2 docs-fix, 2 docs-audit, 3 full-audit-fix, 1 contributing) |
| Codex reviews | 2 (1 for upgrade/install.sh, 1 for session-log) |
| Codex catches | upgrade: 1 P2 — head -n -1 macOS 不兼容 → 改 sed '$d'; session-log: 2 P2 (上次已修) |
| Key decisions | v0.1.0 首个版本号, Doc Engineer 三层职责(代码同步→术语一致→产品叙事), Lead 主动建议下一步写入框架, GitHub Issues 区分 Free/Pro, CONTRIBUTING.md 双语社区 |

### Files Changed
```
 CHANGELOG.md                              |  25 ++++++
 CLAUDE-TEMPLATE.md                        |   4 +-
 CLAUDE.md                                 |   4 +-
 CONTRIBUTING.md                           | 120 ++++++
 README.md                                 |  17 ++-
 README.zh-CN.md                           |  23 +++-
 VERSION                                   |   1 +
 .github/ISSUE_TEMPLATE/bug_report.md      |  45 ++--
 .github/ISSUE_TEMPLATE/custom.md          |  18 ++-
 .github/ISSUE_TEMPLATE/feature_request.md |  43 ++--
 docs/concepts.md                          |   2 +
 docs/configuration.md                     |   6 +-
 docs/design-decisions.md                  |   3 +
 docs/plan.md                              |  12 +-
 docs/product-spec.md                      |   4 +-
 docs/roles.md                             |  13 ++
 docs/session-log.md                       |  (this entry)
 docs/troubleshooting.md                   |   6 +
 docs/user-guide.md                        |   5 +-
 docs/workflow.md                          |   2 +
 install.sh                                |  59 +++-
 21 files changed, 400+ insertions
```

### Notes
- 今天两个 session 合计：38 files touched, 1300+ insertions, 12 developers spawned, 4 Codex reviews, 3 P2 catches
- 开源 backlog 全部清零
- 框架层两个重要演进：Doc Engineer 产品叙事审计 + Lead 主动建议下一步
- 下次优先：场景 3 (全新空项目 /init-project) + tmux 截图

## 2026-03-25 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | install.sh self-update 修复, Solo + Codex 模式定义, Auto PR merge 工作流, GitHub Branch Protection |
| Developers spawned | 0 (Solo + Codex 模式，Lead 全程独立完成) |
| Codex reviews | 2 (PR #4 install.sh self-update, PR #5 workflow 更新) |
| Codex catches | PR #5: 2 P2 — gh CLI 缺少 fallback + start-working 分支检查与 end-working 回 main 不兼容 |
| Key decisions | Solo + Codex 判断标准(单任务+单模块+≤3文件), Auto PR merge(审查完自动建PR合并), GitHub Branch Protection(enforce admins), 确认 dogfooding 场景 3, GitHub Actions CI 延后到场景 3 |

### Files Changed
```
 CLAUDE-TEMPLATE.md          |  28 ++++--
 CLAUDE.md                   |  33 ++++---
 README.md                   |   6 +-
 README.zh-CN.md             |   6 +-
 commands/end-working.md     |   8 ++-
 commands/start-working.md   |  14 +++-
 docs/plan.md                |   9 ++++
 docs/roles.md               |   6 +-
 docs/session-log.md         |  (this entry)
 docs/workflow.md            |  77 ++++++++++++++---
 install.sh                  |  18 ++++
 11 files changed, 170+ insertions
```

### Notes
- 首次完整走通 Solo + Codex 工作流：Lead 独立写代码 → Codex review → Doc Engineer 审计 → auto PR merge
- 首次启用 GitHub Branch Protection，main 分支正式锁定
- Codex review 两次都有效拦截了问题（gh fallback、分支生命周期兼容性）
- 产品决策：确认 dogfooding 场景 3（内部项目）
- GitHub Actions CI 延后：web 项目用 Vercel 自带 CI 足够，等场景 3 再验证独立 CI

## 2026-03-25 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 全面工作流审计, 减少用户审批门(9处改动), 并行读取规则 |
| Developers spawned | 3 (Dev A: 5 commands, Dev B: workflow+user-guide, Dev C: templates) |
| Codex reviews | 1 (PR #7 workflow 审批门优化) |
| Codex catches | PR #7: 2 P2 — env-nogo 报告格式矛盾 + /end-working merge 条件措辞不一致 |
| Key decisions | 用户交互模型统一为 briefing 模式(通知而非审批), /end-working 全自动(不确认 commit message), /start-working 自然对话(不等"start"), 并行不限于写代码(读取/审查也并行) |

### Files Changed
```
 CLAUDE-TEMPLATE.md          |   7 ++--
 CLAUDE.md                   |   6 ++-
 commands/end-working.md     |   2 +-
 commands/env-nogo.md        |   2 +-
 commands/init-project.md    |   2 +-
 commands/migrate.md         |   2 +-
 commands/start-working.md   |   2 +-
 docs/plan.md                |   1 +
 docs/session-log.md         |  (this entry)
 docs/user-guide.md          |  12 +++---
 docs/workflow.md            |   7 ++--
 11 files changed, 30+ insertions
```

### Notes
- 首次使用 Agent Team 模式做文档改动（3 Developer 并行编辑 9 个文件）
- 全面审计发现 27 个用户交互点：保留 8 个(产品决策+不可逆操作)，删除 3 个，简化 3 个
- 用户交互模型统一：Lead 输出 briefing + 建议下一步 → 用户自然回应 → 继续
- 用户反馈：并行不限于写代码，读取/审查任务也应并行——已写入框架规则

## 2026-03-25 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Solo vs Agent Team 判断标准细化（默认 Solo，两条件升级） |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 0 (纯文档标准更新，低风险) |
| Codex catches | N/A |
| Key decisions | Solo 是默认模式；Agent Team 需同时满足"可分解"+"工作量值得"；文件数 ≤3 降为参考值，核心看文件数×每文件改动量 |

### Files Changed
```
 CLAUDE-TEMPLATE.md        |   6 ++--
 CLAUDE.md                 |   6 ++--
 commands/start-working.md |   6 ++--
 docs/plan.md              |   1 +
 docs/session-log.md       |  (this entry)
 docs/workflow.md          |  19 ++++----
 6 files changed, 20+ insertions
```

### Notes
- 用户指出发布时跳过了 Doc Engineer 审计和 plan.md 更新，补做收工流程
- 判断标准从"硬门槛"（单任务+单模块+≤3文件）改为"两条件框架"（可分解×工作量值得），更符合实际判断逻辑
- 今天三个 session 合计：6 files touched this session, 累计 17 files, 0 Codex reviews this session

## 2026-03-25 Session (continued 3)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Agent Team 读写扩展, 四视角全项目 Review + 修复, Pro 内容清理, 升级 scope 文档, Codex bug 修复(trap 作用域+snapshot排序), 去伪存真精简 |
| Developers spawned | 4 (四视角并行 review: 产品/技术/新用户/代码文档) |
| Codex reviews | 2 (1 code review 全部代码改动, 1 pruning plan review) |
| Codex catches | 2 P2 — isparto.sh trap local 变量作用域 bug, snapshot.sh --latest glob 排序不可靠 |
| Key decisions | Agent Team 触发覆盖读+写任务, Pro 内容从开源仓库移除, 截图改为未来视频演示, upgrade 只更新框架不碰用户项目, 去伪存真延后 legacy backup 和 git-clone 迁移代码 |

### Files Changed
```
 CLAUDE-TEMPLATE.md        | 11 ++++++---
 CLAUDE.md                 | 11 ++++++---
 README.md                 | 16 +++++++++----
 README.zh-CN.md           | 18 ++++++++++----
 bootstrap.sh              |  5 ++--
 commands/end-working.md   |  2 +-
 commands/env-nogo.md      |  2 +-
 commands/init-project.md  | 11 ++++-----
 commands/migrate.md       |  8 +++----
 commands/plan.md          |  2 +-
 commands/restore.md       |  2 +-
 commands/start-working.md |  2 +-
 docs/concepts.md          |  2 +-
 docs/configuration.md     | 61 +-------
 docs/product-spec.md      |  8 -------
 docs/workflow.md          | 24 +++++++++------
 install.sh                | 17 +++++++------
 isparto.sh                | 16 ++++++-------
 lib/snapshot.sh           | 31 +++++++++++++------
 scripts/release.sh        |  4 ++--
 20 files changed, 114 insertions(+), 139 deletions(-)
```

### Notes
- 今天四个 session 合计：~28 files touched, 5 PRs merged (#16-#20), 4 Codex reviews, 4 P2 catches
- 首次运行四视角并行 review（产品/技术/新用户/代码文档），发现 20+ 问题并分类修复
- Codex review 再次证明价值：trap 变量作用域 bug 和 snapshot 排序 bug 都是人工不易发现的
- 确立 upgrade 边界原则："upgrade 改 agent 行为，不碰用户已有工作"
- 去伪存真延后两项高风险清理：legacy backup 系统（需 MCP 解耦）和 git-clone 迁移代码（再保留一个版本）

## 2026-03-25 Session (continued 4)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Hotfix (v0.4.0 发布后修复) |
| Tasks completed | isparto.sh exec 修复 (PR #24), 升级输出精简 (PR #25) |
| Developers spawned | 0 (Solo 模式，Lead 独立完成) |
| Codex reviews | 0 (小修复，低风险) |
| Codex catches | N/A |
| Key decisions | 升级输出区分首次安装(详细)和升级(精简), changelog 只展开 Added 其余折叠计数+链接, 依赖/文件/MCP 全通过时各一行 |

### Files Changed
```
 CHANGELOG.md |  28 +++++++++++++
 VERSION      |   2 +-
 install.sh   | 125 ++++++++++++++++++++++++++++++++++++++++-------------------
 isparto.sh   |   2 +-
 4 files changed, 115 insertions(+), 42 deletions(-)
```

### Notes
- v0.4.0 发布后用户实际安装时发现 `;;` 语法错误，根因是 isparto.sh 在升级时被覆盖后 bash 继续从旧偏移读取新文件
- 升级输出从 ~40 行压缩到 ~15 行：changelog 折叠、依赖汇总、文件计数、去掉 Next step
- 两个 hotfix PR 均已合并，准备发布 v0.4.1

## 2026-03-26 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 命令模板语言匹配修复（7 个 commands/*.md 全部加入语言检测指令） |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 1 (QA review，通过，无问题) |
| Codex catches | None |
| Key decisions | 确认 dogfooding 场景 4（内部项目），commands 模板加入语言检测而非翻译模板本身 |

### Files Changed
```
 commands/end-working.md   | 2 ++
 commands/env-nogo.md      | 2 ++
 commands/init-project.md  | 2 ++
 commands/migrate.md       | 2 ++
 commands/plan.md          | 2 ++
 commands/restore.md       | 2 ++
 commands/start-working.md | 2 ++
 docs/plan.md              | 1 +
 docs/session-log.md       | (this entry)
 9 files changed, 15 insertions(+)
```

### Notes
- 用户在内部项目首次运行 /init-project 时发现中文输入得到英文回复，dogfooding 发现的第一个 UX bug
- 根因：commands/*.md 模板全是英文指令且无语言检测说明，而 CLAUDE-TEMPLATE.md 的语言规则要到 CLAUDE.md 生成后才生效
- 修复策略：在命令模板层加入语言检测（靠近执行时刻），而非翻译模板本身（模板是结构参考）
- templates/*.md 保持英文结构不变——生成内容的语言由 commands 指令控制

## 2026-03-26 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Process Observer 审计增加 C4 检查（plan.md 未完成项与实际状态核对），补标 plan.md 漏标的两项 |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 0 (低风险文档改动，3 个文件 6 行) |
| Codex catches | N/A |
| Key decisions | Process Observer 职责扩展：不仅观察，还要主动检查 plan.md 未完成项是否与代码实际状态一致，发现漏标时提醒 Lead |

### Files Changed
```
 commands/end-working.md  | 4 ++--
 docs/plan.md             | 4 ++--
 docs/process-observer.md | 2 ++
 docs/session-log.md      | (this entry)
 4 files changed, 6 insertions(+), 4 deletions(-)
```

### Notes
- 用户 dogfooding 中发现 plan.md 有两项（Process Observer hooks 实现 + /end-working 集成）已完成但未标记
- 根因：plan.md 更新依赖 Lead "记得"，没有系统性核对机制
- 修复：在 Process Observer 审计 Checklist C 增加 C4 检查项，/end-working 审计指令也同步补充
- 这是 Process Observer 角色的一次职责升级：从纯观察到主动兜底

## 2026-03-26 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | install.sh --upgrade 自动补全项目 hooks 注册, iSparto 自身 settings.json 补全 hooks |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 2 (第一次发现 P1: set -e 下 sys.exit(1) 导致 install.sh 退出; 第二次发现 P2: python3 缺失时静默失败) |
| Codex catches | 1 P1 — set -e + sys.exit(1) 会中断安装流程; 1 P2 — python3 缺失时静默跳过无警告 |
| Key decisions | upgrade 区分"用户内容"(不碰)和"框架基础设施"(自动补全), 用 Python 做 JSON merge 避免 jq 依赖 |

### Files Changed
```
 install.sh            | 69 ++++++++++++++++++++++++++++++++++++++
 .claude/settings.json | (local only, not tracked)
 docs/session-log.md   | (this entry)
 1 file changed, 69 insertions(+)
```

### Notes
- 根因分析：iSparto 在 v0.5.0 加了 Process Observer hooks，但自身的 .claude/settings.json 没注册——"鞋匠不穿鞋"
- 更深层原因：--upgrade 之前只更新全局文件，不碰项目级配置。但 hooks 注册属于框架基础设施，不是用户内容
- 修复策略：upgrade 时检测当前项目（有 CLAUDE.md），自动补全缺失的 hooks 注册
- Codex review 两次都抓到了关键问题：P1 会让安装流程中断，P2 会让 hooks 注册静默失败
- 用户提出"两个视角"框架：本体开发者视角 + 用户体验视角，要同时具备

## 2026-03-26 Session (continued 3)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | v0.5.1 发布（语言匹配 + C4 检查）, v0.5.2 发布（upgrade hooks 注册）, README 首屏重组（EN + ZH-CN）, 自定义角色-模型绑定加入 v1.x 路线图 |
| Developers spawned | 2 (README EN + ZH-CN 并行重组) |
| Codex reviews | 3 (语言修复 QA 1 次, install.sh code review 2 次) |
| Codex catches | 1 P1 — set-e + sys.exit(1) 中断安装; 1 P2 — python3 缺失静默失败 |
| Key decisions | upgrade 区分用户内容/框架基础设施, README 首屏重组（对比表+安装命令前置，名字故事下移）, 自定义角色绑定延后到 v1.x（当前生态绑定最强模型无需配置）, Demo GIF 延后到 dogfooding 后录制 |

### Files Changed
```
 CHANGELOG.md               | 13 ++++
 README.md                  | 136 ++++++++++++++++++++------------------
 README.zh-CN.md            | 136 ++++++++++++++++++++------------------
 VERSION                    |   4 +-
 commands/end-working.md    |   6 +-
 commands/env-nogo.md       |   2 +
 commands/init-project.md   |   2 +
 commands/migrate.md        |   2 +
 commands/plan.md           |   2 +
 commands/restore.md        |   2 +
 commands/start-working.md  |   2 +
 docs/plan.md               |   6 +-
 docs/process-observer.md   |   2 +
 docs/session-log.md        | (this entry)
 install.sh                 |  69 ++++++++++++++++++++
 14 files changed, ~380 insertions
```

### Notes
- 今天 4 个 sub-session，10 个 PR 合并（#33-#42），2 个版本发布（v0.5.1, v0.5.2）
- dogfooding 场景 4 正式启动，首次 /init-project 就发现语言匹配 bug，验证 dogfooding 价值
- Process Observer hooks 首次实战拦截：在 main 上链式执行 git checkout -b && git commit 被 commit-on-main 规则 block
- 用户提出"两个视角"框架（本体开发者 + 用户体验），推动了 upgrade hooks 注册功能
- 外部反馈（X 用户问自定义 agent）触发路线图更新，但附带了前置判断条件（生态开放度）
- README 重组采纳了外部产品建议中的 4/6 项，拒绝了 tagline 建议，延后了 GIF 录制
- 下次优先：dogfooding 场景 4 继续 + 终端录屏 GIF

## 2026-03-26 Session (continued 4)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Codex review 触发规则重构：从"列举要 review 的"翻转为"列举可跳过的，其余全部 review" |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 1 (PR #44 全部改动，发现 3 个一致性问题并修复) |
| Codex catches | 3 P2/P3 — hotfix 规则未对齐 Tier 2 config 豁免, B1 判定标准未包含 config-only 跳过, workflow.md Agent Team 流程仍引用 B1-B3 而非 B1-B4 |
| Key decisions | Codex review 默认触发(Tier 1)，仅纯视觉/config(Tier 2 QA only)和纯文档/格式化(Tier 3 skip)可跳过；新增 Wave 级兜底(B4)；检查项 13→14 |

### Files Changed
```
 CLAUDE-TEMPLATE.md       |  2 +-
 CLAUDE.md                |  2 +-
 docs/concepts.md         |  2 +-
 docs/process-observer.md |  8 +++++---
 docs/roles.md            |  2 +-
 docs/session-log.md      | (this entry)
 docs/workflow.md         | 47 +++++++++++++++++++++++++++++++++++++----------
 6 files changed, 46 insertions(+), 17 deletions(-)
```

### Notes
- 触发原因：用户在另一个项目 dogfooding 时发现 Codex review 经常不触发，根因是旧规则只定义了"高风险"和"纯 UI"两端，中间地带（业务逻辑、API、数据模型等）默认被跳过
- 修复策略：翻转默认行为——从"opt-in"改为"opt-out"，只有明确列入跳过清单的才不触发
- 这是框架级改动，影响所有安装 iSparto 的项目（通过 CLAUDE-TEMPLATE.md）
- Codex review 再次证明价值：一次 review 发现 3 个交叉引用一致性问题，人工很难全部定位
- 新增 B4 Wave 级兜底检查：确保即使单次改动被分类跳过，Wave 结束时仍有至少一次批量 review

## 2026-03-30 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | 阶段性 Review（跨 Wave，v0.8 准备） |
| Tasks completed | 四视角并行 Review（57 发现）、系统决策（14 接受/18 拒绝/9 延后）、3 Wave 执行（产品方向+代码修复+文档修复）、v0.5/v0.6 里程碑标记、v0.8 验收条件定义 |
| Developers spawned | 4 (四视角 Review) + 2 (Doc Engineer + Process Observer 审计) |
| Codex reviews | 3 (Wave B 实现 6 项代码修复, snapshot 向后兼容修复, QA 全量 review) |
| Codex catches | QA review: 无 defect; Doc Engineer 发现 snapshot 编码向后兼容问题（已修复） |
| Key decisions | 删掉 ASCII banner 和 CI 质量门、v0.8 验收条件重新定义（4 项，3 项已完成）、不立即发版（等 v0.7.0 打包）、57 个 review 发现的系统性取舍（接受/拒绝/延后） |

### Files Changed
```
 CHANGELOG.md             |  2 --
 README.md                |  2 ++
 README.zh-CN.md          |  2 ++
 commands/init-project.md |  5 +++++
 docs/configuration.md    |  2 +-
 docs/plan.md             | 33 ++++++++++++++++++---------------
 docs/product-spec.md     |  4 ++--
 docs/troubleshooting.md  | 10 ++++++++++
 docs/workflow.md         |  9 +++++----
 install.sh               |  5 +++--
 isparto.sh               |  4 ++--
 lib/snapshot.sh          | 20 +++++++++++++++++++-
 scripts/release.sh       | 16 +++++++++++-----
 docs/session-log.md      | (this entry)
 14 files changed, 80 insertions(+), 34 deletions(-)
```

### Notes
- 首次对项目做系统性阶段 Review：四视角并行（新用户体验/产品完整度/代码健壮性/文档一致性），产出 57 个发现
- 系统决策模式：不逐项讨论，一次性出决策表让用户 review，高效对齐
- Doc Engineer 发现 snapshot.sh 编码变更的向后兼容问题——旧快照用 `__` 编码，新代码用 `%XX`，已加 legacy_encode_path fallback
- Process Observer 审计标记 B3（QA 缺失）为 FAIL，补跑 Codex QA review 后通过
- v0.8 前三项验收条件本次全部完成，只剩"1 个外部用户冷启动验证"
- 用户决定不立即发版，等后续工作一起打包为 v0.7.0
- 累计统计（10 sessions）：~29 Developer spawned, ~17 Codex reviews, ~18 issues caught

## 2026-03-30 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.6 架构加固 — 续（v0.6.5 + v0.6.6 发布） |
| Tasks completed | Process Observer Sonnet 降级, agent 定义文件安装修复, rejected approaches 追踪机制, "no direct code" 理由集中化 + 行为模板 Tier 2b, v0.6.5 发布, v0.6.6 发布 |
| Developers spawned | 0 (Solo 模式) |
| Codex reviews | 0 |
| Codex catches | N/A |
| Key decisions | Process Observer 审计从 Opus 降级 Sonnet 4.6（降低 token 消耗，关键检查已由 hooks 覆盖）, 行为模板（commands/*.md, templates/*.md）归类为 Tier 2b（Developer review only, 跳过 QA）, rejected approaches 写入 plan 模板防止 AI 重复尝试已否决路径 |

### Files Changed
```
 CHANGELOG.md                     | 25 +++++++++++++++++++++
 CLAUDE-TEMPLATE.md               | 10 ++++---
 CLAUDE.md                        | 16 ++++----
 VERSION                          |  2 +-
 agents/process-observer-audit.md | 30 ++++++++++++++++++++++++++++++
 commands/end-working.md          |  3 ++-
 commands/start-working.md        |  1 +
 docs/concepts.md                 |  1 +
 docs/configuration.md            | 11 ++++---
 docs/design-decisions.md         |  4 ++++
 docs/process-observer.md         |  2 ++
 docs/roles.md                    | 14 ++++----
 docs/workflow.md                 | 14 ++++++++++--
 install.sh                       |  3 +++
 templates/plan-template.md       | 10 +++++++++
 docs/session-log.md              | (this entry)
 15 files changed, 122 insertions(+), 24 deletions(-)
```

### Notes
- 本次 session 未走 /end-working 收工流程，session log 由下次 session 补录
- v0.6.5 修复 agent 定义文件缺失（v0.6.4 的 Sonnet 降级因缺文件静默回退 Opus）
- v0.6.6 引入两个框架级改进：rejected approaches 追踪 + 行为模板分类
- 8 个 PR 合并（#80-#87），2 个版本发布
- 累计统计（11 sessions）：~29 Developer spawned, ~17 Codex reviews, ~18 issues caught

## 2026-03-30 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.8 准备（Harness Engineering 研究吸收） |
| Tasks completed | session log 补录(PR #88), design-decisions CLAUDE-TEMPLATE 例外(PR #89), 自验证启动+Stateless Session 原则(PR #90), health check 命令源修复(PR #91), v0.6.7 发布(PR #92-#93) |
| Developers spawned | 0 (Solo 模式) |
| Codex reviews | 1 (Tier 2b review: start-working.md runtime health check) |
| Codex catches | 1 P2 — CLAUDE.md Build 字段是描述性文本(如 "Xcode")，直接执行会误报；限制为 Common Commands 区域 |
| Key decisions | 吸收 Harness Engineering 研究(Anthropic long-running agent harness + 12 Factor Agents)，自验证启动设为非阻塞(通知而非门禁)，排除 5 项大团队需求(依赖层级/垃圾回收/JSON 替代 Markdown/自动 refactoring/Benchmark) |

### Files Changed
```
 CHANGELOG.md               | 12 ++++++++++++
 VERSION                    |  2 +-
 commands/start-working.md  | 17 +++++++++++++----
 docs/concepts.md           |  1 +
 docs/design-decisions.md   |  4 +++-
 docs/session-log.md        | (this entry + backfill)
 6 files changed, ~36 insertions
```

### Notes
- 首次基于外部研究（OpenAI Harness Engineering + Anthropic long-running agent + 12 Factor Agents）系统性吸收改进
- Codex review 补跑流程验证：Tier 2b 行为模板改动 Lead 直接写、Codex review，本次初始遗漏 review 后补跑，Codex 抓到 P2
- 用户澄清 Solo 模式理解：确认 Lead 写行为模板 + Codex review 是 Tier 2b 正确流程
- 6 个 PR 合并（#88-#93），1 个版本发布（v0.6.7）
- 累计统计（12 sessions）：~29 Developer spawned, ~18 Codex reviews, ~19 issues caught

## 2026-03-31 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 6 (安全审计系统) + post-Wave cleanup |
| Tasks completed | Wave 6 全部 11 项（security-patterns.json、pre-commit-security.sh、pre-tool-check.sh L1 扩展、/security-audit 命令、/end-working 集成、/init-project+/migrate 集成、Codex/Developer/DocEng prompt 安全段、gitignore-security-baseline.md、docs/security.md、install.sh 注册、README+design-decisions 更新）+ dangerous-ops 敏感文件检测迁移 |
| Developers spawned | 0 (Solo 模式，4 次 Codex 实现调用 + 1 次 Codex review) |
| Codex reviews | 1 (发现 1 个 critical bug) |
| Codex catches | 1 Critical — pre-commit-security.sh regex 双重解码 bug（extract_json_string + decode_json_escapes 双重处理反斜杠，`\s` → `s`，导致所有 regex pattern 失效） |
| Key decisions | 三层安全防御架构(L1 实时/L2 pre-commit/L3 里程碑)、security-patterns.json 单一数据源、realtime_critical 子集解决 L1 性能、dangerous-ops 敏感文件检测迁移到安全系统(子串匹配误报→staged 文件扫描)、Process Observer WARNING 噪音暂不处理(观察再决定) |

### Files Changed
```
PR #96 (feat/security-audit): 23 files changed, +1140, -20
 CHANGELOG.md                                     | 26 +
 CLAUDE-TEMPLATE.md                               |  3 +
 CLAUDE.md                                        |  7 +-
 README.md                                        | 10 +-
 README.zh-CN.md                                  | 10 +-
 VERSION                                          |  2 +-
 commands/end-working.md                          |  9 +-
 commands/env-nogo.md                             |  2 +-
 commands/init-project.md                         | 12 +-
 commands/migrate.md                              |  9 +-
 commands/security-audit.md (NEW)                 | 58 +
 docs/design-decisions.md                         |  3 +
 docs/plan.md                                     | 13 +
 docs/process-observer.md                         | 27 +
 docs/product-spec.md                             |  4 +-
 docs/roles.md                                    | 35 +
 docs/security.md (NEW)                           | 89 +
 docs/user-guide.md                               |  3 +-
 hooks/.../security-patterns.json (NEW)           |154 +
 hooks/.../pre-commit-security.sh (NEW)           |571 +
 hooks/.../pre-tool-check.sh                      | 52 +
 install.sh                                       |  7 +
 templates/gitignore-security-baseline.md (NEW)   | 54 +

PR #97 (fix/dangerous-ops-dedup): 3 files changed, +3, -39
 docs/design-decisions.md                         |  3 +-
 docs/process-observer.md                         |  4 +-
 hooks/.../dangerous-operations.json              | 35 -
```

### Notes
- 本次 session 跨越了 context compaction（从上一个对话延续），Wave 6 实现在 compaction 前完成，本 session 完成了 commit/push/PR/merge + post-Wave cleanup + 发版
- Codex 发现的 critical bug（regex 双重解码）如果未修复，会导致 L2 pre-commit 扫描对所有 pattern 完全失效——这是 cross-model review 的价值体现
- 发布 2 个版本：v0.6.8（三层安全审计系统）、v0.6.9（敏感文件检测迁移）
- 4 个 PR 合并（#96-#99）
- 待验证：在实际项目（Meic/Yonya）中跑 L1 Write 拦截和 L2 .secureignore 白名单的端到端测试
- Process Observer 审计：17 PASS, 1 WARNING (C1: session log 未显式记录 Doc Engineer 执行), 0 FAIL
- Process Observer 改进建议：(1) CLAUDE.md 分支规则补充 docs/ 和 release/ 前缀；(2) session log 模板增加 Doc Engineer 执行记录行
- 累计统计（13 sessions）：~29 Developer spawned, ~19 Codex reviews, ~20 issues caught

## 2026-03-31 Session #2

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 6 (安全审计系统) — 后续扩展 |
| Tasks completed | security-patterns.json 全栈覆盖扩展（7 类 ~50+ sensitive_files pattern + 2 个 secrets pattern + gitignore 基线同步 + 文档更新） |
| Developers spawned | 0 (Solo 模式，Lead 直接编辑 rules/*.json — 自引用边界) |
| Codex reviews | 1 |
| Codex catches | P1 — bundle 目录模式（*.dSYM/*.xcarchive/\*.app）在 pre-commit scanner 中无法匹配内部路径，移除改为仅 gitignore 覆盖；P2 — gitignore 中 core.\* 会静默隐藏 core.ts 等合法源文件，从 gitignore 移除 |
| Key decisions | *.map 默认 BLOCK（source map = 完整源码泄露）、*.log 不加入 sensitive_files（误报率高，L2 内容扫描已覆盖）、构建输出目录只进 gitignore 不进 sensitive_files、L1 不扩展（构建产物是文件级非内容级）、inline source map 加入 secrets（data URI 内联补位）、*.sql/core/.vscode 从 sensitive_files 降级到 gitignore_baseline（误报风险） |

### Files Changed
```
PR #101 (fix/security-patterns-fullstack): 5 files changed, +128, -3
 docs/design-decisions.md                           |  6 +++
 docs/plan.md                                       |  3 +-
 docs/security.md                                   | 14 +++++
 hooks/.../security-patterns.json                   | 60 ++-
 templates/gitignore-security-baseline.md           | 48 +++
```

### Notes
- 动机：Claude Code source map 泄露事件暴露构建产物安全盲区，iSparto 作为通用框架需全栈覆盖
- Plan mode 讨论阶段调整了 6 个高误报 pattern 的归属（sensitive_files → gitignore_baseline only）
- Codex review 发现 2 个 pattern 有效性问题并修复；Doc Engineer 审计发现 gitignore 模板缺 .vscode 条目并补齐
- Process Observer 审计：9 PASS, 3 WARNING (均为 mid-session 预期状态), 0 FAIL
- 发布 v0.6.10
- 累计统计（14 sessions）：~29 Developer spawned, ~20 Codex reviews, ~22 issues caught
