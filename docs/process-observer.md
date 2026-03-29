# Process Observer

## 概述

Process Observer 是 iSparto 团队的合规监督角色。它由两部分组成，优先级不同：

- **实时拦截（Hooks）— 核心层**：通过 Claude Code PreToolUse hook 监管所有工具调用（Bash / Edit / Write / Codex MCP），拦截违规操作。这是不可绕过的硬性保障。
- **事后审计（Sub-agent）— 建议层**：/end-working 时回顾 session 执行过程，输出合规报告和改进建议。此层依赖 Lead 主动 spawn，不保证每次执行。关键合规检查已由 Hooks 层覆盖，sub-agent 的价值是发现流程改进机会，而非作为合规的唯一防线。

Process Observer 不参与开发决策，只监督流程合规性。它与 Doc Engineer 同级，都是 Team Lead 的 sub-agent。

---

## 实时拦截（Hooks）

### 运行机制

通过 Claude Code 的 PreToolUse hook 实现。hook 是一个 shell 脚本，在每次工具调用前被触发，检查命令是否匹配高危操作清单。如果匹配，阻止执行并输出原因。

Hooks 注册在用户级 `~/.claude/settings.json` 中，所有项目共享。`install.sh --upgrade` 自动注册到用户级配置。

### 触发条件

工具调用匹配以下任一规则时触发拦截：
- **Bash**：命令匹配 dangerous-operations.json 高危操作清单
- **Edit/Write**：目标文件为代码文件（按扩展名判定）
- **Codex MCP**：prompt 缺少结构化标题（## 格式）

### 判断原则

一个操作是否"高危"，基于三个判断维度：

| 维度 | 说明 | 示例 |
|------|------|------|
| 不可逆 | 操作无法撤回，或撤回代价极高 | `git push --force`、`rm -rf` |
| 影响共享状态 | 操作改变其他人（或其他 session）依赖的状态 | 直接 push 到 main、修改全局配置 |
| 数据丢失 | 操作可能导致代码、文档或用户数据丢失 | `git reset --hard`、`git clean -f` |

满足任一维度即视为高危。

### 高危操作分类

#### 1. Git 不可逆操作

| 操作 | 拦截原因 |
|------|---------|
| `git push --force` / `git push -f`（到 main/master） | 覆盖远程保护分支历史，其他协作者的工作可能丢失 |
| `git reset --hard` | 丢弃所有未提交的本地修改 |
| `git clean -fd` / `git clean -f` | 删除未跟踪的文件，不可恢复 |
| `git checkout -- .` | 丢弃所有未暂存的修改 |
| `git branch -D main` / `git branch -d main`（保护分支） | 删除 main/master 分支 |

#### 2. 敏感信息泄露

| 操作 | 拦截原因 |
|------|---------|
| `git add` 包含 `.env`、`credentials`、`secrets`、`*.pem`、`*.key` | 敏感文件可能被提交到公开仓库 |

#### 3. 跳过安全检查

| 操作 | 拦截原因 |
|------|---------|
| `--no-verify` 标志 | 跳过 pre-commit / pre-push hook |
| `--no-gpg-sign` 标志 | 跳过 GPG 签名 |

#### 4. 破坏性文件操作

| 操作 | 拦截原因 |
|------|---------|
| `rm -rf /` 或 `rm -rf ~` | 灾难性删除（匹配根目录和 home 目录） |
| 删除项目根目录下的关键文件（CLAUDE.md、.git/） | 项目结构被破坏 |

#### 5. iSparto 特有保护

| 操作 | 拦截原因 |
|------|---------|
| 删除 `~/.isparto/backup` 目录 | 移除卸载/回滚能力 |
| 删除 `~/.isparto/snapshots` 目录 | 移除所有配置还原点 |
| 删除 `~/.isparto` 目录 | 移除全部 iSparto 数据 |
| 删除 `~/.claude` 目录 | 移除全部 Claude Code 配置 |

#### 6. 直接在 main 开发

| 操作 | 拦截原因 |
|------|---------|
| 当前分支为 main 时执行 `git commit` | main 锁定，所有开发必须在 feat/fix/hotfix 分支 |
| `git push origin main`（非 PR merge） | 绕过 PR 流程直接推送 |

#### 7. 工作流合规（Edit / Write / Codex 拦截）

##### 代码直写拦截（Edit / Write）

| 操作 | 拦截原因 |
|------|---------|
| Edit/Write 目标为代码文件（.sh, .py, .swift, .js, .ts 等） | 代码变更必须通过 Developer (Codex) 实现，不可直接编辑 |
| Edit/Write 目标为无扩展名文件（Makefile 等） | 默认视为代码文件（fail-safe） |

**判定逻辑：**
- 提取 Edit/Write 工具的 `file_path` 参数
- 根据文件扩展名判定：allowed_extensions 放行，其他拦截
- 代码文件扩展名（拦截）：.sh, .py, .swift, .js, .ts, .jsx, .tsx, .go, .rs, .java, .kt, .c, .cpp, .h, .m, .mm, .rb 等
- 允许的扩展名（放行）：.md, .json, .yaml, .yml, .toml, .txt, .svg, .png, .css, .html 等
- 未识别的扩展名默认按代码文件处理（fail-safe）

**谁会被拦：**

Hooks 运行在所有带 project settings 的 Claude Code session 中：
- **Lead**（主 session）→ 被拦
- **Teammate**（tmux session，共享 project settings）→ 被拦
- **Doc Engineer**（Lead 的 sub-agent，共享 session）→ 被拦
- **Developer (Codex MCP)**（独立进程，不走 hooks）→ **不被拦**

这是设计意图：只有 Developer (Codex) 应该写代码，其他角色都通过 Developer 间接操作。

##### Codex 调用规范（mcp__codex-reviewer__codex）

| 操作 | 拦截原因 |
|------|---------|
| 调用 Developer 时 prompt 不含 `## ` 结构化标题 | 必须使用结构化 prompt 描述任务 |

**自定义扩展名列表：**

扩展名列表定义在 `hooks/process-observer/rules/workflow-rules.json` 中，可根据项目需要调整 `code_extensions` 和 `allowed_extensions` 数组。

### 拦截行为

当检测到高危操作时：
1. **阻止执行**：返回非零退出码，Claude Code 不执行该命令
2. **输出原因**：在 stderr 输出拦截原因和建议替代方案

示例输出：
```
[Process Observer] BLOCKED: git push --force
Reason: Force push overwrites remote history and may destroy collaborators' work.
Suggestion: Use `git push` (without --force) or `git push --force-with-lease` for safer alternatives.
```

---

## 事后审计（Sub-agent）

### 运行机制

由 Team Lead 在 /end-working 流程中作为 sub-agent 派生，与 Doc Engineer 同级。审计当前 session 的执行过程，检查是否有违反工作流规范的行为。

### 触发时机

/end-working 流程中，在 Doc Engineer 文档审计之后、推分支/建 PR 之前执行。

### 审计 Checklist

#### Checklist A：分支规范

| # | 检查项 | 判定标准 | 偏差级别 |
|---|--------|---------|---------|
| A1 | 当前分支是否为 feat/、fix/ 或 hotfix/ | 分支名前缀匹配 | P1 |
| A2 | 是否有直接 commit 到 main 的记录 | git log 对比 session 开始时的 main HEAD | P1 |
| A3 | 分支命名是否遵循约定 | feat/xxx、fix/xxx、hotfix/xxx 格式 | P2 |

#### Checklist B：Codex Review 合规

| # | 检查项 | 判定标准 | 偏差级别 |
|---|--------|---------|---------|
| B1 | 代码改动是否触发 Codex code review | 默认应触发；仅 Tier 2（纯视觉、非安全配置值）和 Tier 3（纯文档/纯格式化）可跳过 code review。对照 workflow.md 触发条件表判断 | P1 |
| B2 | QA smoke testing 是否触发 | 默认应触发；仅纯文档/纯格式化改动可跳过。对照 workflow.md 触发条件表判断 | P1 |
| B3 | Codex 发现的问题是否被处理 | Codex review 输出的 catches 是否有对应的 fix commit | P1 |
| B4 | Wave 级兜底 review 是否执行 | 每个 Wave 至少包含一次批量 Codex review，不论单次改动如何分类 | P1 |

#### Checklist C：Doc Engineer 合规

| # | 检查项 | 判定标准 | 偏差级别 |
|---|--------|---------|---------|
| C1 | Doc Engineer 是否运行 | session 中有 Doc Engineer 派生记录 | P1 |
| C2 | 代码改动是否有对应文档更新 | diff 中 .md 文件变更与代码变更的对应关系 | P2 |
| C3 | plan.md 是否更新 | plan.md 在 session 中有 diff 记录 | P1 |
| C4 | plan.md 未完成项与实际状态一致 | 对照 plan.md 中标 `[ ]` 的条目，检查对应文件/功能是否已存在于代码库中。已实现但未标完成的条目视为偏差 | P1 |

#### Checklist D：PR 流程合规

| # | 检查项 | 判定标准 | 偏差级别 |
|---|--------|---------|---------|
| D1 | 是否通过 PR 合入 main | gh pr list 记录，main 的新 commit 来自 PR merge | P1 |
| D2 | 合入后是否清理了分支 | 远程分支列表中不存在已合入的 feat/fix/hotfix 分支 | P3 |

#### Checklist E：越权操作

| # | 检查项 | 判定标准 | 偏差级别 |
|---|--------|---------|---------|
| E1 | Developer 是否修改了所有权外的文件 | git log --name-only 文件列表 vs Team Lead 分配的文件所有权 | P1 |
| E2 | 不确定的产品决策是否上报了用户 | 对话上下文中是否有向用户确认的记录 | P2 |

### 偏差级别说明

| 级别 | 含义 | 处理方式 |
|------|------|---------|
| P1 | 严重偏差，违反核心工作流规范 | 必须在报告中标红，建议立即修正 |
| P2 | 一般偏差，不影响交付质量但需改进 | 在报告中标记为 WARNING，建议下次改进 |
| P3 | 轻微偏差，最佳实践建议 | 在报告中标记为 INFO，供参考 |

---

## 偏差报告模板

```markdown
### Compliance Audit

| # | Check | Status | Detail |
|---|-------|--------|--------|
| A1 | Branch is feat/fix/hotfix | PASS/FAIL | Current branch: feat/xxx |
| A2 | No direct commits to main | PASS/FAIL | ... |
| A3 | Branch naming convention | PASS/FAIL | ... |
| B1 | Codex code review triggered for code changes | PASS/FAIL/N/A | ... |
| B2 | QA smoke testing triggered | PASS/FAIL/N/A | ... |
| B3 | Codex catches resolved | PASS/FAIL/N/A | ... |
| B4 | Wave-level batch review executed | PASS/FAIL/N/A | ... |
| C1 | Doc Engineer executed | PASS/FAIL | ... |
| C2 | Code changes have doc updates | PASS/FAIL | ... |
| C3 | plan.md updated | PASS/FAIL | ... |
| C4 | plan.md unchecked items match actual state | PASS/FAIL | ... |
| D1 | Merged to main via PR | PASS/FAIL/N/A | ... |
| D2 | Branch cleaned up after merge | PASS/FAIL/N/A | ... |
| E1 | No out-of-scope file modifications | PASS/FAIL/N/A | ... |
| E2 | Uncertain decisions escalated to user | PASS/FAIL/N/A | ... |

**Summary:** X passed, Y warnings, Z failures

**Rule Corrections Suggested:**
- [Specific suggestions for fixing failures and improving warnings]
```

---

## 反馈闭环

审计发现偏差后，不直接修改文件，而是通过报告和建议驱动改进：

### 1. 根因分析
分析偏差原因，区分：
- **流程疏忽**：知道规则但忘了执行（如忘记触发 Codex review）
- **规则不明确**：规则本身有歧义或边界不清晰
- **工具限制**：当前工具/环境不支持自动执行

### 2. 修正建议
输出具体的修正建议，包括：
- 对于流程疏忽：建议在哪个步骤增加检查点
- 对于规则不明确：建议修改 CLAUDE.md 或 docs/ 中的具体措辞
- 对于工具限制：记录为已知限制，等待工具升级

### 3. 执行方式
- 审计报告和修正建议输出到 /end-working 的 session briefing 中
- **不自动修改任何文件**——修正建议仅作为建议输出
- 下次 /start-working 时，Lead 在 briefing 中提醒用户上次审计的偏差和建议，由用户决定是否采纳
