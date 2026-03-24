# iSparto

## Project Overview
iSparto 是一个 AI Agent Team 工作流框架，把 Claude Code 单 Agent 变成一支有分工的团队（Lead + Developer + Codex Reviewer + Doc Engineer）。目标用户是独立开发者，当前阶段：开源核心工作流已发布，dogfooding 中。

## Tech Stack
- Language: Shell (Bash), Markdown
- Framework: 无（纯配置项目，通过 Claude Code slash commands + MCP 驱动）
- Platform: macOS (iTerm2 + tmux)
- Build: 无构建步骤
- Other: Codex MCP Server (npx codex-mcp-server)

## Development Rules
- 任何代码/命令改动必须同步更新对应文档（README、docs/、命令头注释）
- 产品方向变更必须写入文档，不能只在对话里讨论
- 不确定的产品问题先问我，不要自己决定
- 完成任务后更新 docs/plan.md
- 不在 main 上直接开发；feat/ 做新功能，fix/ 修 bug，hotfix/ 紧急修复
- install.sh 改动必须保持向后兼容（旧用户能正常卸载）
- 命令模板（commands/*.md）改动需确认不破坏现有用户的 /migrate 和 /init-project 流程
- commit 后自动 push，我在 GitHub 上 review

## Collaboration Mode: Agent Team

**Roles:**
- Team Lead (main session): 拆任务、协调全流程、合代码。不写业务代码。Lead 负责 Codex 和 Developer 之间的信息中转；用户不参与中间协调。Lead 可以独立做常规决策，但不确定的事情必须上报用户。
- Claude Developer (teammate): 写代码 + 单元测试。在文件所有权范围内工作。Review Codex 的修改。
- Codex Reviewer (MCP): 代码审查 + 直接修复 + QA 冒烟测试。隐藏大师角色。始终使用 xhigh reasoning。由 Lead 调用。
- Doc Engineer (Lead sub-agent): Wave 完成后文档审计。确保代码和文档同步。

**Development Workflow:**
1. Lead 拆任务 -> 定义文件所有权 + 接口契约
2. Developer 开发 + 测试
3. Lead 调 Codex 代码审查 + 修复
4. Lead 转发改动给 Developer review
5. Lead 调 Codex QA 冒烟测试（增量，只测改动路径）
6. Lead 派 Doc Engineer 文档审计（最后一步，确保 QA 修复也被审计）
7. Lead 合代码

**Codex Review Triggers:** 高风险代码（install.sh 核心逻辑、snapshot.sh）必须触发 code review + QA；纯文档调整只需 QA；小修小补不触发。

**Branching Strategy:** main 锁定；feat/xxx 开发新功能，fix/xxx 修 bug，hotfix/xxx 紧急修复（从 main 分支，走完整流程）。

**Module Boundaries:**
| Module | Directory/Files | Description |
|--------|----------------|-------------|
| Installer | install.sh | 一键安装/卸载脚本 |
| Snapshot Engine | lib/snapshot.sh | 快照/恢复引擎 |
| Slash Commands | commands/*.md | 7 个用户命令模板 |
| Doc Templates | templates/*.md | 4 个文档模板 |
| Project Template | CLAUDE-TEMPLATE.md | 新项目 CLAUDE.md 生成模板 |
| Framework Docs | docs/ (concepts, roles, workflow, configuration, user-guide, troubleshooting, design-decisions) | 面向用户的框架文档 |
| Project Docs | docs/ (product-spec, plan) | iSparto 自身的产品规格和开发计划 |
| Assets | assets/*.svg | README 用的 SVG 图 |
| READMEs | README.md, README.zh-CN.md | 双语 README |

## Operational Guardrails
- git push 前必须确认
- 删除文件前必须确认
- 不直接 commit 到 main（但当前阶段暂时允许，后续加 PR 流程）
- install.sh 破坏性改动（改变 backup 格式、删除旧兼容逻辑）需要用户明确同意

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
