你是 Team Lead。用户执行了 /end-working，进入收工流程。

你的职责：确保本次所有改动和决策都落到文档和代码仓库中，不丢失任何上下文。

1. 检查本次所有改动和决策：
   - 代码改动是否与 docs/ 文档一致？不一致则你（Lead）直接更新文档，或 spawn Doc Engineer 更新
   - 对话中的口头决策是否已写入对应文档？未写入则补充
2. 更新 docs/plan.md：
   - 标记完成的任务
   - 如果当前 Wave 的所有 Team 都完成，标记 Wave 状态为已完成
   - 列出下次待办
   - 记录遗留问题和人工介入点
3. git add -A && git commit
4. git push

执行前先让用户确认 commit message。
