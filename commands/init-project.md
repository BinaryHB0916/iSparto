基于 ~/.claude/CLAUDE-TEMPLATE.md 模板初始化新项目：

1. 填写项目信息、确定技术栈和目标平台
2. 整理文档到 docs/（product-spec.md、tech-spec.md、design-spec.md 等）
3. 生成初始 docs/plan.md，按 Wave 组织开发计划
4. 初始化 git 仓库，创建 main 分支
5. 在 CLAUDE.md 中包含协作模式、模块边界、分支策略
6. 调用 Codex MCP 做架构前置审视（基于 tech-spec.md，使用架构审视 prompt 模板），将结果反馈给用户确认

$ARGUMENTS
