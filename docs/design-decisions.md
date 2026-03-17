# 设计决策记录

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
| 文档分层 | README 精简 + docs/ 详细文档 | README 控制在 200 行内，新用户 30 秒看完核心信息；深度内容按主题拆到 docs/ |
| 架构图用 mermaid | 替代 ASCII art | GitHub 代码块字体中 CJK 字符宽度不精确，ASCII 边框必然错位；mermaid 渲染为 SVG 无此问题 |
| 仅支持 macOS + iTerm2 | 不做跨平台终端适配 | Agent Team tmux 模式依赖 iTerm2 内置 tmux 集成；当前阶段聚焦核心体验，不分散精力 |
| templates/ 独立目录 | 模板从 README 中抽出 | 避免 README 中重复模板内容（原 400+ 行），模板作为独立文件可被 /init-project 直接引用 |
