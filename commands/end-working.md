收工流程：

1. 检查本次所有改动和决策：
   - 代码改动是否与 docs/ 文档一致？不一致则更新文档
   - 对话中的口头决策是否已写入对应文档？
2. 更新 docs/plan.md：
   - 标记完成的任务
   - 如果当前 Wave 的所有 Team 都完成，标记 Wave 状态为已完成
   - 列出下次待办
   - 记录遗留问题和人工介入点
3. git add -A && git commit
4. git push

执行前先让我确认 commit message。
