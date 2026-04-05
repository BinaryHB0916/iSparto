# Framework Feedback — 2026-04-05

## F1: Mode Selection Checkpoint 缺乏可审计输出位置

**Rule**: CLAUDE.md Mode Selection Checkpoint 要求 Lead "显式声明"协作模式
**Gap**: 声明只存在于 session 对话中，PR body 不包含结构化的 Mode Selection 记录
**Expected**: 在 PR body template（如 "## Test plan" 下方）增加 "Mode Selection" 字段，使 checkpoint 声明保留在可验证的 artifact 中
**Impact**: 审计只有 PR metadata 时无法确认 B1（Mode Selection Checkpoint）是否执行

## F2: Process Observer 审计调用证据不清晰

**Rule**: /end-working Step 4 要求 spawn Process Observer sub-agent 执行合规审计
**Gap**: PR test plan 中 "Process Observer 审计: ✅" 无法区分是 sub-agent 独立运行还是 Lead 自行评估
**Expected**: PR test plan 应区分 "Process Observer sub-agent run: ✅" 和 "Lead self-assessed: ✅"
**Impact**: 审计无法确认 Process Observer 是否真正作为独立 sub-agent 被触发
