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
- [ ] 场景 3: 全新空项目 — /init-project 从零开始
- [x] Session Log 自动采集 — /end-working 自动生成 session report，/start-working 自动读取历史
- [ ] 每个场景记录：Wave 数量、并行效率、Codex 拦截问题、截图（现在由 session-log.md 自动采集）

## 待办 (Backlog)

### 开源优化
- [x] README 实测效果章节（自举案例：Session Log 功能开发全流程）
- [x] 升级功能 — install.sh --upgrade + VERSION + CHANGELOG.md（版本追踪、changelog 展示）
- [x] CONTRIBUTING.md 贡献指南
- [x] GitHub Issues 模板优化（bug report / feature request / question 适配 CLI 项目）

### Pro 版规划
- [ ] Agent dashboard 原型设计
- [ ] Auto-retry & rollback 技术方案
- [ ] Cost & token analytics 数据采集方案
