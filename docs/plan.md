# iSparto 开发计划

## 已完成

### Wave 0: 核心框架
- [x] 7 个 slash commands (start-working, end-working, plan, init-project, migrate, env-nogo, restore)
- [x] 4 个文档模板 (product-spec, tech-spec, design-spec, plan)
- [x] CLAUDE-TEMPLATE.md 项目模板
- [x] settings.json 参考配置
- [x] 角色定义 + Codex prompt 模板 (docs/roles.md)
- [x] 完整开发流程文档 (docs/workflow.md)
- [x] 核心概念文档 (docs/concepts.md)
- [x] 配置指南 (docs/configuration.md)
- [x] 用户交互手册 (docs/user-guide.md)
- [x] 问题排查 (docs/troubleshooting.md)
- [x] 设计决策记录 (docs/design-decisions.md)

### Wave 1: 安装体系
- [x] install.sh 一键安装（curl | bash）
- [x] --dry-run 预览模式
- [x] --uninstall 卸载 + 旧文件备份恢复
- [x] Codex MCP Server 全局注册
- [x] 双语 README (EN + ZH-CN)
- [x] SVG header banner + 角色架构图

### Wave 2: 快照/恢复系统
- [x] lib/snapshot.sh 快照引擎 (create/restore/list/info/prune)
- [x] /restore 命令
- [x] install.sh 集成快照（安装前自动拍快照）
- [x] migrate.md 集成快照（迁移前自动拍快照）
- [x] init-project.md 集成快照（初始化前自动拍快照）
- [x] 向后兼容旧 manifest 备份

### Wave 3: 商业化基础
- [x] 买域名 isparto.dev
- [x] Landing page (isparto-website repo)
- [x] Waitlist 邮箱收集 (Google Sheets + Apps Script)
- [x] Vercel 自动部署
- [x] 域名绑定 + SSL

### Wave 4: 自举迁移
- [x] iSparto 项目自身迁移到 iSparto 工作流 (CLAUDE.md, settings.json, product-spec, plan.md)

### Wave 5: Dogfooding 验证
- [x] 场景 1: isparto-website 项目 — /migrate 已完成
- [x] 场景 2: 萌芽勇气 (iOS app) — /migrate 已完成
- [x] 场景 3: 内部项目 A（勇芽 iOS）— /init-project 已完成（用户自行操作）
- [x] 场景 4: 内部项目 B（meic）— /init-project 已完成（用户自行操作）
- [x] Session Log 自动采集 — /end-working 自动生成 session report，/start-working 自动读取历史
- [x] 每个场景记录：Wave 数量、并行效率、Codex 拦截问题、截图（由 session-log.md 自动采集替代）

### Wave 6: 安全审计系统
- [x] security-patterns.json — 统一安全规则库（14 secret + 4 PII + 敏感文件 + gitignore 基线 + realtime_critical 子集）
- [x] security-patterns.json 全栈覆盖扩展 — 7 类 ~50+ sensitive_files pattern（构建产物/基础设施/调试/IDE/发布/备份）+ gitignore 基线同步 + inline-sourcemap/terraform-secret 2 个 secrets pattern
- [x] pre-commit-security.sh — commit 前全量扫描（从 JSON 读取 patterns，支持 .secureignore 白名单）
- [x] pre-tool-check.sh L1 扩展 — Write/Edit 实时内容安全扫描（5 个 critical patterns）
- [x] /security-audit 命令 — 里程碑全量审计（代码 + .gitignore + git 历史 + 依赖）
- [x] /end-working 集成 — commit 前安全扫描步骤
- [x] /end-working 分支守卫 — commit 前检查是否在 main，是则先创建 docs/ 分支（修复 session log 提交撞 hook 的流程缺陷）
- [x] 分支前缀规范化 — docs/ 和 release/ 正式加入 CLAUDE.md 和 Process Observer 审计 checklist
- [x] /init-project + /migrate 集成 — 安全基线初始化 / 检查
- [x] Codex QA + Developer prompt + Doc Engineer 审计清单增加安全检查
- [x] gitignore-security-baseline.md 模板
- [x] docs/security.md + process-observer.md 更新
- [x] install.sh 注册新文件
- [x] README 双语更新 + design-decisions.md 架构决策记录

## 当前阶段

## 产品路线图

iSparto 的演进分三个阶段（详见 product-spec.md）：

```
v0.x  开发者工具      用户 = 开发者，手动触发流程
v1.x  自治开发团队    用户 = 技术负责人，给任务，团队自己跑
v2.x  CEO 工作台      用户 = 老板，说需求看结果，不碰过程
```

---

### v0.x — 开发者工具（当前阶段）

**交付标准：一个没见过 iSparto 的 Claude Code 用户，看 README 就能装好、用起来、不找你问。**

| 里程碑 | 版本 | 标志 | 状态 |
|--------|------|------|------|
| 自用可靠 | v0.5 | 4 个 dogfooding 场景全部跑通 | ✅ v0.5.0 达成 |
| 架构加固 | v0.6 | Process Observer 全流量监管、角色-模型解耦、review 触发翻转 | ✅ v0.6.4 达成 |
| 外部可用 | v0.8 | 至少 1 个外部用户完整跑通，无需手把手指导 | 进行中 |
| 正式发布 | v1.0 | 稳定（连续版本无 hotfix）+ Getting Started 教程 + 基本 issue 响应机制 | — |

**v0.8 验收条件：**
- [x] 新用户入门修复（README Prerequisites、/init-project Next Steps、troubleshooting 安装问题）— PR #78
- [x] 代码关键修复（snapshot 路径编码+向后兼容、release.sh 跨平台、install.sh Python3 检查）— PR #78
- [x] 文档对齐（命令计数、术语统一、Solo Checklist）— PR #78
- [ ] 1 个外部用户冷启动验证（看 README → 安装 → /init-project → /start-working → /end-working 全流程）
- [x] 按角色独立配置模型 — v0.6.0 实现声明式角色-模型映射表（docs/configuration.md#agent-model-configuration），角色定义与模型名解耦。运行时自动切换留给 v1.x
- [x] User Preference Interface — memory/CLAUDE.md 领地分界、三级偏好模型、冲突协议、memory 写入规则、Plan Mode 自动触发
- [x] Process Observer 角色定义与文档 — 合规监督角色（实时拦截 hooks + 事后审计 sub-agent），docs/process-observer.md + 各文档集成
- [x] Process Observer hooks 实现 — PreToolUse hook shell 脚本，拦截高危操作
- [x] Process Observer 全流量监管 — Edit/Write 代码直写拦截 + Codex 结构化 prompt 强制 + 所有角色覆盖（Lead/Teammate/Doc Engineer）
- [x] Process Observer /end-working 集成 — end-working.md 中触发合规审计并输出偏差报告

**已完成：**（折叠）

<details>
<summary>v0.x 已完成项（点击展开）</summary>

- [x] README 实测效果章节（自举案例：Session Log 功能开发全流程）
- [x] 升级功能 — install.sh --upgrade + VERSION + CHANGELOG.md
- [x] CONTRIBUTING.md 贡献指南
- [x] GitHub Issues 模板优化
- [x] GitHub Issues #2 #3 标记为 Pro 付费功能
- [x] Doc Engineer 职责升级为三层
- [x] 全面文档审计（22 项修复，14 个文件）
- [x] Team Lead 角色增加"主动建议下一步"行为
- [x] install.sh --upgrade self-update
- [x] Solo + Codex 模式
- [x] Auto PR merge
- [x] GitHub Branch Protection
- [x] 减少用户审批门
- [x] Solo vs Agent Team 判断标准细化
- [x] isparto.sh exec 修复
- [x] 升级输出精简
- [x] Release 流程 — git tag + GitHub Releases + scripts/release.sh
- [x] Agent Team 模式扩展读任务
- [x] 全项目四视角 Review
- [x] 开源仓库清理
- [x] Codex 发现 bug 修复
- [x] 去伪存真精简

</details>

### Rejected Approaches

| Date | Module/Feature | What was tried | Why rejected | Notes |
|------|---------------|----------------|--------------|-------|
| 2026-03-30 | 框架全局 | 依赖层级强制（Types → Config → Service → UI） | 百万行代码库的需求；iSparto 目标用户项目通常 < 10 万行，过度工程化 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | 框架全局 | 周期性垃圾回收 | 百万行代码库 + 7 人团队的需求；solo founder 项目规模小，Wave 级 Codex review + QA 已足够 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | plan.md | Feature list 用 JSON 替代 Markdown | 无证据表明 AI 误删 plan.md 任务条目；先观察再决定 | 来源：Anthropic long-running agent harness。条件：如果实际使用中出现误删问题则重新评估 |
| 2026-03-30 | 框架全局 | 自动化 refactoring PR | 依赖 CI/CD 基础设施；solo founder 项目通常没有 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | 框架全局 | Benchmark/Eval 集成 | 当前阶段不需要量化评估 harness 质量 | 来源：awesome list |
| 2026-04-01 | 框架全局 | Claude Code 10 项改进（commands frontmatter、路径作用域规则、hook if 过滤、统一 Tool(specifier) 语法、git worktree 隔离、prompt/agent hook 类型、plugin 打包、协调原语、deferred tool discovery、subagent 持久化 memory） | 独立开发者小项目不需要这些；当前 hook + tmux + CLAUDE.md 够用，没有实际痛点驱动 | 来源：anthropics/claude-code 仓库深度研究。条件：dogfooding 中遇到真实痛点时重新评估单项 |

---

### v1.x — 自治开发团队

**交付标准：用户给一个任务描述，团队自己跑完全流程并交付可验收的结果，用户不需要中途干预。**

**核心能力：流程自治 + 状态可见性**

- [ ] 跨 session 任务续接 — 换 session 后团队自动恢复上下文，无需用户手动对齐
- [ ] 多任务并行管理 — 同时推进多个独立任务，Lead 自动调度优先级
- [ ] 进度摘要 — 每个任务的状态、完成度、阻塞项，用人话汇报
- [ ] Demo 预览 — 自动部署 preview 环境 + 截图 + 一句话说明变化
- [ ] 风险预警 — 主动上报复杂度超预期、依赖问题、技术风险
- [ ] 失败自动重试与回滚 — 构建/测试失败时自动诊断、重试或回滚
- [x] 自定义角色-模型绑定 — v0.6.0 实现了声明式配置表（docs/configuration.md#agent-model-configuration），角色定义与模型名解耦。运行时自动切换留给 v1.x
- [ ] Agent dashboard — 任务看板，可视化团队工作状态
- [ ] Cost & token analytics — 用量统计，帮用户理解投入产出

---

### v2.x — CEO 工作台

**交付标准：一个非技术用户，用自然语言描述需求，能拿到可运行的 demo + 进度报告，全程不碰代码不碰终端。**

**核心能力：需求理解 + 自然语言交互**

- [ ] 需求拆解 — 业务语言 → 技术 task → 优先级排序，用户只确认方向
- [ ] 方案决策 — 团队提出技术方案选项，用户选择，不需要理解技术细节
- [ ] 交付验收 — 可运行 demo + 变更说明，用户体验后给反馈
- [ ] 自然语言项目管理 — "这周能上线吗？""昨天那个功能做得怎么样？"
- [ ] 多项目管理 — 同时管理多个项目的多支 AI 团队
