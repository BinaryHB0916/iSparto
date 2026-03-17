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
