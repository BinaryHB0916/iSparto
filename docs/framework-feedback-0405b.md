# Framework Feedback — 2026-04-05 Session 2

Process Observer 审计发现的框架改进建议。

| Rule | Gap | Expected Behavior | Session Context |
|------|-----|-------------------|-----------------|
| Doc Engineer 触发条件 | CLAUDE.md 和 workflow.md 写"每个 Wave 结束后"触发 Doc Engineer，但未明确 ad-hoc 修复 session（无 Wave 完成）是否需要触发 | 添加说明："Doc Engineer 不适用于无 Wave 完成的 ad-hoc 修复 session（除非该 session 有代码与文档同步风险）" | PRs #142-144 均为 bug fix，无 Wave 完成，Doc Engineer 未触发（合理但需要显式规则支持） |
| plan.md 更新规则 | CLAUDE.md 写"完成任务后立即更新 plan.md"，但未说明修复不对应任何 plan.md 条目时如何处理 | 添加说明："如果修复不对应 plan.md 中任何条目，则无需修改 plan.md" | PRs #142-143 为质量修复，不对应任何 plan 条目，正确地未修改 plan.md，但审计需要推理判断 |
