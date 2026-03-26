# iSparto 开发计划

## 已完成

### Wave 0: 核心框架
- [x] 6 个 slash commands (start-working, end-working, plan, init-project, migrate, env-nogo)（Wave 2 新增 /restore 后扩展为 7 个）
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

## 当前 Wave

### Wave 5: Dogfooding 验证
- [x] 场景 1: isparto-website 项目 — /migrate 已完成
- [x] 场景 2: 萌芽勇气 (iOS app) — /migrate 已完成
- [ ] 场景 3: Heddle（暂定名，generative UI 运行时）— /init-project 从零开始（用户自行操作）
- [ ] 场景 4: meic（暂定代号，虚拟声纹/声纹卡）— /init-project 从零开始（用户自行操作）
- [x] Session Log 自动采集 — /end-working 自动生成 session report，/start-working 自动读取历史
- [ ] 每个场景记录：Wave 数量、并行效率、Codex 拦截问题、截图（现在由 session-log.md 自动采集）

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

| 里程碑 | 版本 | 标志 |
|--------|------|------|
| 自用可靠 | v0.5 | 3 个 dogfooding 场景全部跑通 |
| 外部可用 | v0.8 | 至少 1 个外部用户完整跑通，无需手把手指导 |
| 正式发布 | v1.0 | 稳定（连续版本无 hotfix）+ Getting Started 教程 + 基本 issue 响应机制 |

**剩余工作：**
- [ ] 安装脚本 ASCII art banner — 黑客帝国风格的 fancy 安装头（ASCII logo + 动画效果）
- [ ] GitHub Actions CI 质量门 — PR 必须通过 CI 检查才能 merge
- [x] Process Observer 角色定义与文档 — 合规监督角色（实时拦截 hooks + 事后审计 sub-agent），docs/process-observer.md + 各文档集成
- [x] Process Observer hooks 实现 — PreToolUse hook shell 脚本，拦截高危操作
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
