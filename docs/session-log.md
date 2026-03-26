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
| Key decisions | Solo + Codex 判断标准(单任务+单模块+≤3文件), Auto PR merge(审查完自动建PR合并), GitHub Branch Protection(enforce admins), Heddle 作为场景 3, GitHub Actions CI 延后到 Heddle |

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
- 产品决策：Heddle（暂定名，generative UI 运行时）确认为 dogfooding 场景 3
- GitHub Actions CI 延后：web 项目用 Vercel 自带 CI 足够，等 Heddle 再验证独立 CI

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
| Key decisions | meic（虚拟声纹/声纹卡）确认为 dogfooding 场景 4，commands 模板加入语言检测而非翻译模板本身 |

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
- 用户在 meic 项目首次运行 /init-project 时发现中文输入得到英文回复，dogfooding 发现的第一个 UX bug
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
| Key decisions | upgrade 区分用户内容/框架基础设施, README 首屏重组（对比表+安装命令前置，名字故事下移）, 自定义角色绑定延后到 v1.x（当前生态绑定最强模型无需配置）, Demo GIF 延后到 meic dogfooding 后录制 |

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
- meic dogfooding 场景 4 正式启动，首次 /init-project 就发现语言匹配 bug，验证 dogfooding 价值
- Process Observer hooks 首次实战拦截：在 main 上链式执行 git checkout -b && git commit 被 commit-on-main 规则 block
- 用户提出"两个视角"框架（本体开发者 + 用户体验），推动了 upgrade hooks 注册功能
- 外部反馈（X 用户问自定义 agent）触发路线图更新，但附带了前置判断条件（生态开放度）
- README 重组采纳了外部产品建议中的 4/6 项，拒绝了 tagline 建议，延后了 GIF 录制
- 下次优先：meic 项目 dogfooding 继续 + 终端录屏 GIF
