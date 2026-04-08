# Session Log

## 2026-04-07 Session (#d) — i18n Cleanup Wave 4 (language-check.sh as Doc Engineer audit blocking gate)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | i18n Cleanup — Wave 4 (language-check.sh promoted to Doc Engineer audit item 9 blocking gate) |
| Tasks completed | Wave 4 complete (3 framework files): `docs/roles.md` (new item 9 + output table row + violation sub-section + Key Principle with audit-fix-reaudit loop + 6-step blocked recovery path), `commands/end-working.md` (step 9 extended with 2 new bullets for the loop and recovery), `docs/plan.md` (BLOCKING marker swap Wave 3→4 → Wave 4→5, Wave 4 completion entry deferred-write, deferred-items list updated). Pre-edit and post-edit guardian: 0 Tier 1 / 0 Tier 2 / 0 Principle 1 (both). Self-test: both Principle 1 fixtures PASS. Doc Engineer audit: PASS all 9 items (meta-test — item 9 validates itself against the Wave that introduces it). Process Observer audit: 11 PASS / 1 WARN (F1 in-progress, resolved by IR spawn) / 0 FAIL / 2 N/A. Independent Reviewer: PROCEED, 0 CRITICAL / 0 MAJOR / 2 MINOR (non-blocking; MINOR #1 `master-plan-固化` CJK phrase fixed in same commit, MINOR #2 deferred Wave 4 entry written before commit). |
| Key decisions | (1) Wave-1 forward-looking promise fulfilled — CLAUDE.md L44 ("starting from Wave 4") is now accurate; no edit to CLAUDE.md needed, the forward reference naturally resolves post-Wave-4. (2) Audit-fix separation pattern formalized — on Doc Engineer FAIL, the Lead (NOT the Doc Engineer) performs the fix, then spawns a **fresh** Doc Engineer sub-agent for re-audit. Rationale: prevents the agent that found a problem from also being the agent that fixes it (avoids motivated reasoning and incomplete patches). Documented in both `docs/roles.md` Key Principles and `commands/end-working.md` step 9. Loop bounded at 3 iterations. (3) 6-step blocked recovery path on loop-bound exceedance — (a) stop loop; (b) blocked-audit report; (c) write blocked-audit entry to plan.md; (d) push WIP branch (`git push -u origin <current-branch>`); (e) report to user; (f) exit /end-working without merging. Lead does NOT improvise recovery — every step is prescribed. (4) Item 9 is conditional on `scripts/language-check.sh` existence — makes the checklist universally safe (iSparto-internal projects exercise the gate, user projects without the script silently skip). The script is intentionally NOT propagated to user projects via install.sh (would require also propagating iSparto's Tier 1/Tier 2 path structure, which doesn't generalize). (5) Meta-verification is partial only in the current session — Wave 4's own Doc Engineer audit exercises item 9 against the Wave 4 files themselves, but does NOT exercise the audit-fix-reaudit loop or the 6-step blocked recovery path (those only trigger on a real FAIL, which is not expected for Wave 4). Full validation deferred to Wave 5's first natural Doc Engineer run. Most importantly, the Lead in the current session has pre-Wave-4 Tier 1 system prompts cached in conversation context — any loop the Lead would orchestrate here would use the stale mental model. Cross-session boundary before Wave 5 is mandatory. (6) Wave 3 deferred-items list was Wave-4-cleaned: the "Wave 4 task" bullet removed (replaced by this Wave 4 completion entry). New deferred items for Wave 5: CLAUDE-TEMPLATE.md ↔ CLAUDE.md sync sweep (carryover from Wave 3), Process Observer F1 check IN-PROGRESS intermediate status (new, surfaced by Wave 4 PO audit). |

### Files Changed
```
 commands/end-working.md    |   2 ++
 docs/independent-review.md |  70 ++++++++++++++++++++++++++++++++++++++++++++++
 docs/plan.md               |  50 ++++++++++++++++++++++++++++------
 docs/roles.md              |  19 +++++++++++++
 4 files changed, 133 insertions(+), 8 deletions(-)
```

### Notes
- Mode: Solo + Codex (framework self-referential boundary — 3 framework files, small edits ~5–25 lines each, no decomposable parallel sub-tasks; Lead edits directly via Edit tool, no Developer/Codex MCP needed for the edits themselves).
- All plan edit positions specified as textual anchors (not line numbers) — earlier edits in the same file do not invalidate the anchor for later edits. User-mandated Fix 1 from plan approval.
- `plan.md` Wave 4 completion entry was deferred-write (user-mandated Fix 4) — the entry was authored only after all gates (Doc Engineer, Process Observer, Independent Reviewer) completed and produced actual verdicts. No `[to be filled in]` placeholders.
- The Doc Engineer audit spawn explicitly read the post-Wave-4 `docs/roles.md` from disk (fresh sub-agent, zero inherited context) so the new item 9 definition was loaded for the audit run. The Lead's own conversation context is pre-Wave-4 (cached at session start) — this is why meta-verification is only partial and full validation is deferred to Wave 5 (see plan.md Meta-verification caveat).
- Framework improvement candidate surfaced by PO: F1 check in `agents/process-observer-audit.md` should gain an IN-PROGRESS intermediate status. Currently binary PASS/FAIL forces mid-session audits to report WARN when IR is correctly pending but not yet overdue. Noted in plan.md Wave 4 Deferred items for next session pickup.
- Cross-session boundary required before Wave 5 — Wave 4 modified `commands/end-working.md` (used by Lead each session when /end-working runs) and `docs/roles.md` (used by Doc Engineer audit, loaded when Lead spawns the sub-agent). BLOCKING marker at top of plan.md (swapped from Wave 3→4 to Wave 4→5 in this Wave's Edit A) will be auto-detected by `/start-working` Step 0 in the next session.

## 2026-04-07 Session (#b) — Inter-Wave Hotfixes

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Inter-Wave (between i18n Cleanup Wave 2 and Wave 3) |
| Tasks completed | Hotfix 1 (PR #153, `fix/mcp-rename-migration-guard`) + Hotfix 2 (PR #154, `feat/principle1-guardian-extension`) |
| Key decisions | (1) Hotfix 1 — codex-reviewer → codex-dev migration in start-working.md Step 7 must check whether the renamed MCP server is actually registered before mutating the matcher; on a stale install (codex-dev not yet registered) the rename would silently disable hook interception, which is worse than the legacy state. Guard pattern reused from install.sh: `claude mcp list -s user 2>/dev/null \| grep -q codex-dev`. The auto-add branch is also short-circuited on stale installs to avoid re-introducing the same silent-disable bug. (2) Hotfix 2 — Principle 1 detector is a mechanical first-line guard, not an exhaustive parser. Catches the most obvious cases (output verb + quoted English literal, ≥12 chars, uppercase first), exempts `e.g.` markers and `[bracket]` placeholder spans. Test 4 fixture uses 5 hardcoded synthetic violation strings (no git archaeology); Test 1 sanity-checks that the CLAUDE.md illustrative example is NOT false-positively flagged. Detection scope limited to commands/*.md and agents/*.md. |

### Files Changed
```
 CLAUDE.md                 |   2 +-
 commands/start-working.md |   5 +-
 docs/plan.md              |  49 +++++++++++++-
 scripts/language-check.sh | 162 ++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 202 insertions(+), 16 deletions(-)
```

### Notes
- Both hotfixes ran the full inline workflow: Codex review → Doc Engineer audit → Process Observer audit → push → PR → merge → branch cleanup. Each hotfix received APPROVE WITH MINOR from Codex; minors fixed in same branch before merge.
- Hotfix 1 — Doc Engineer caught a `legacy` vs `old` matcher wording inconsistency on line 56; fixed in same edit. Codex MINOR was an ambiguous "skip remaining sub-steps of Step 7" phrase; tightened to explicitly name the auto-add branch and direct Lead to Step 8.
- Hotfix 2 — Detector implementation by Codex (gpt-5.3-codex, xhigh). Verified against the current commands/+agents/ tree: 0 false positives. Edge cases verified: start-working.md:65 `Announce ... e.g., "Single-module fix..."` (e.g. exemption), security-audit.md:52 `[bracket]` (bracket exemption), standalone fixed-prompt lines in init-project.md/end-working.md/plan.md (no output verb on the line). Self-test exercises Test 1 (sanity negative — CLAUDE.md illustrative example must NOT be flagged) + Test 4 (5/5 fixture violations must be flagged); both PASS.
- Hotfix 2 — Doc Engineer caught real doc-code drift: CLAUDE.md L44 still described language-check.sh as CJK-only after the Principle 1 extension. Fixed in same branch by extending L44 to mention the two orthogonal scans and the new `--self-test` command.
- Hotfix 2 — Process Observer A6 WARN: acceptance commands were Lead-executed bash, not via Developer QA prompt as workflow step 3 prescribes. Tracked as framework-side feedback in plan.md Deferred items (proposing a carve-out for ≤5 deterministic CLI commands on trivial scripts).
- Off-by-one correction: plan.md previously recorded the Tier 2 baseline as 391; actual count is 392 (corrected with explanatory note in the Hotfix 1 section).
- Known limitations of the Principle 1 detector (documented in plan.md): unquoted literals not detected, verbs not in the list (say/state/explain/convey/…) missed, multi-line verb-then-quote not detected, bracket exemption is full-prefix (strictly more conservative than the 40-char tail used for `e.g.` markers).
- Wave 3 (Tier 2 Englishization, 392 violations) deferred to a separate new session per cross-session boundary protocol.

## 2026-04-05 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.8 外部可用（进行中） |
| Tasks completed | 多模型 Developer 策略（PR #131）、gh 账号自动对齐（PR #132）、release v0.6.16（PR #133） |
| Key decisions | Developer 双档模型（5.3-codex + 5.4-mini）代替原提案三档（spark 因 ChatGPT Plus 限制不可用）；gh 账号对齐放 start-working + end-working 双点检测 |

### Files Changed
```
 CHANGELOG.md              | 14 ++++++++++++++
 CLAUDE-TEMPLATE.md        |  2 +-
 CLAUDE.md                 |  2 +-
 VERSION                   |  2 +-
 commands/end-working.md   |  9 ++++++++-
 commands/start-working.md | 14 +++++++++++---
 docs/configuration.md     | 38 +++++++++++++++++++++++++++++---------
 docs/design-decisions.md  |  3 +++
 docs/plan.md              | 28 ++++++++++++++++++++++++++++
 docs/workflow.md          |  2 ++
 10 files changed, 98 insertions(+), 16 deletions(-)
```

### Notes
- MCP model 参数验证结果：gpt-5.4-mini 透传成功，gpt-5.3-codex-spark 被 ChatGPT Plus 认证拒绝（"not supported when using Codex with a ChatGPT account"）
- Process Observer hook 拦截了 main 上的 tag push（无法区分 tag push 和 branch push），用 `gh release create --target main` 绕过
- gh 账号问题在 PR #131 创建时首次触发，手动 `gh auth switch` 修复后立即作为第二个需求自动化

## 2026-04-03 Session (#3)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | QA 验证层级修复 + Independent Reviewer 角色 |
| Tasks completed | PR #120: QA acceptance script 三级验证标签 ([code]/[build]/[runtime])；PR #121: Independent Reviewer 角色（产品-技术对齐盲审） |
| Key decisions | 1. 三级验证：用户可见功能必须含 [build]+[runtime] 步骤；2. IR 用 Teammate(tmux) 而非 Sub-agent 确保零上下文继承；3. IR Phase 0 强制触发，Wave 边界按需；4. CRITICAL 修复后必须重新触发 IR 验证；5. Phase 0 覆盖写 / Wave 边界追加（保留审计轨迹） |

### Files Changed
```
CLAUDE-TEMPLATE.md             |  7 ++-
CLAUDE.md                      | 10 +++--
agents/independent-reviewer.md | 99 ++++++++++++++++++++++++++++++++++++++++++
commands/init-project.md       |  7 ++-
commands/plan.md               |  5 ++-
docs/design-decisions.md       |  4 ++
docs/plan.md                   | 19 ++++++++
docs/roles.md                  | 41 ++++++++++++++++-
docs/workflow.md               | 32 +++++++++++++-
templates/plan-template.md     | 29 +++++++++----
10 files changed, 233 insertions(+), 20 deletions(-)
```

### Notes
- 两个需求来源：Meic 项目 dogfooding 发现的两个系统性问题（QA 只做代码分析不做运行验证 + 审查链路全部继承 Lead 假设）
- PR #120 和 #121 各自独立完成完整工作流（实现 → 验证 → Doc Engineer → Process Observer → PR merge）
- Doc Engineer 在 #121 发现 1 个 MINOR（workflow.md Phase 0/Wave 文件处理描述不一致），当场修复

## 2026-04-03 Session (#2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.6 架构加固（延续） |
| Tasks completed | Branch Protocol 入口防御, 3 条审计规则修正, 审计回流机制, 用户产出去内部化, v0.6.13 发版 |
| Key decisions | P1 仓库结构重组推迟到下个版本; CLAUDE.md 不能移（Claude Code 硬约束）; framework-feedback 文件放 docs/ 不放项目根 |

### Files Changed
```
 CHANGELOG.md                                     | 23 +++++++++++++++++++++++
 CLAUDE-TEMPLATE.md                               | 16 ++++++++++++++--
 CLAUDE.md                                        | 18 +++++++++++++++---
 VERSION                                          |  2 +-
 agents/process-observer-audit.md                 | 21 ++++++++++++++++++---
 commands/end-working.md                          | 14 ++++++++++----
 commands/plan.md                                 |  4 +++-
 commands/start-working.md                        | 16 ++++++++++------
 docs/workflow.md                                 |  6 +++++-
 hooks/process-observer/scripts/pre-tool-check.sh | 20 ++++++++++++++++++--
 10 files changed, 117 insertions(+), 23 deletions(-)
```

### Notes
- 来源：Meic 项目 Session #13 审计（8 passed / 3 failed）暴露的框架侧缺口 + 外部用户视角产出物审视
- 4 个 PR 合并（#115 Branch Protocol, #116 用户产出去内部化, #117 CHANGELOG, #118 Release v0.6.13）
- 已安装的 hook（~/.isparto/）还是旧版本，需要 install.sh --upgrade 才能用上新的复合命令检测
- 发现并修复 CLAUDE-TEMPLATE.md L3 死链（~/.isparto/docs/ 不存在，改为 GitHub URL）

## 2026-04-01 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Bugfix (Process Observer hooks) |
| Tasks completed | Bootstrap push-to-main exception, git-rule false positive prevention, .sh allowed_extensions, v0.6.11 release |
| Developers spawned | 0 (Lead direct edit per CLAUDE.md self-referential exception) |
| Codex reviews | 2 (bootstrap fix review + false positive design review) |
| Codex catches | P1: push-on-main only checked origin/$current_branch, should check both origin/main and origin/master; applied to all git rules as helper function |
| Key decisions | User rejected all 10 Claude Code repo improvements — "不需要就够了", continue dogfooding to find real pain points |

### Files Changed
```
 hooks/process-observer/rules/workflow-rules.json |  1 +
 hooks/process-observer/scripts/pre-tool-check.sh | 46 ++++++++++++++++++++----
 CHANGELOG.md                                     | 12 ++++++
 VERSION                                          |  2 +-
 4 files changed, 55 insertions(+), 6 deletions(-)
```

### Notes
- 问题来源：在 meic-website 新项目 /init-project 后首次推 main 分支被 hook 拦截
- 修复过程中暴露第二个问题：gh pr create --body 中的 git 命令示例文本触发 git-push-main-direct 规则
- Codex 建议将 quote-stripping 做成 git-rule 家族 helper 而非单点修复，最终覆盖 5 条规则
- 深度研究了 anthropics/claude-code 仓库（plugin 系统、hook 类型、agent team 协调原语等），用户评估后认为当前项目规模不需要这些改进
- installed copy (~/.isparto/) 与 repo 同步更新

## 2026-03-24 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 2 (快照/恢复系统) + Wave 4 (自举迁移) + Wave 5 (Dogfooding 验证) |
| Tasks completed | 快照/恢复系统全部完成, 自举迁移完成, Session Log 功能, README 实测章节 |
| Developers spawned | 4 (2 for session-log feature, 2 for README benchmark) |
| Codex reviews | 2 (1 for snapshot system, 1 for session-log feature) |
| Codex catches | snapshot: 无 (uncommitted review); session-log: 2 P2 — git diff --stat 不完整 + diff 输出破坏 Markdown table |
| Key decisions | 统一快照系统设计(metadata.txt+files.txt), 向后兼容旧manifest, iSparto自举使用自己的工作流, session log自动采集替代手动记录, 升级功能列入backlog |

### Files Changed
```
 CLAUDE.md                 |  78 ++++++
 README.md                 |  47 +++-
 README.zh-CN.md           |  47 +++-
 commands/end-working.md   |  33 ++-
 commands/env-nogo.md      |  11 +-
 commands/init-project.md  |  26 ++-
 commands/migrate.md       |  19 ++-
 commands/restore.md       |  30 ++++++
 commands/start-working.md |  12 +-
 docs/plan.md              |  65 ++++++
 docs/product-spec.md      |  52 ++++++
 docs/session-log.md       |   (this file)
 docs/troubleshooting.md   |   3 +-
 docs/user-guide.md        |   3 +-
 docs/workflow.md          |   5 +-
 install.sh                | 141 +++++++++---
 lib/snapshot.sh           | 350 ++++++++++++++++++++++++++++++
 17 files changed, 900+ insertions
```

### Notes
- 本次是 iSparto 首次完整自举运行，用自己的 Agent Team 工作流开发自己的功能
- 跑了两次完整的 Agent Team 流程（session-log + README benchmark），每次都是 2 Developer 并行
- 用户提出"升级功能"缺失，已加入 backlog，下次会话优先处理
- ~/.claude/commands/end-working.md 是安装时的旧版本，还没包含 session log 步骤；下次 install.sh 更新后会同步

## 2026-03-24 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 升级系统 (--upgrade + VERSION + CHANGELOG), 文档术语修复, Doc Engineer 三层职责升级, 全面文档审计 (22 项), CONTRIBUTING.md + Issue 模板, GitHub Issues Pro 标记, Lead 主动建议行为 |
| Developers spawned | 10 (2 upgrade, 2 docs-fix, 2 docs-audit, 3 full-audit-fix, 1 contributing) |
| Codex reviews | 2 (1 for upgrade/install.sh, 1 for session-log) |
| Codex catches | upgrade: 1 P2 — head -n -1 macOS 不兼容 → 改 sed '$d'; session-log: 2 P2 (上次已修) |
| Key decisions | v0.1.0 首个版本号, Doc Engineer 三层职责(代码同步→术语一致→产品叙事), Lead 主动建议下一步写入框架, GitHub Issues 区分 Free/Pro, CONTRIBUTING.md 双语社区 |

### Files Changed
```
 CHANGELOG.md                              |  25 ++++++
 CLAUDE-TEMPLATE.md                        |   4 +-
 CLAUDE.md                                 |   4 +-
 CONTRIBUTING.md                           | 120 ++++++
 README.md                                 |  17 ++-
 README.zh-CN.md                           |  23 +++-
 VERSION                                   |   1 +
 .github/ISSUE_TEMPLATE/bug_report.md      |  45 ++--
 .github/ISSUE_TEMPLATE/custom.md          |  18 ++-
 .github/ISSUE_TEMPLATE/feature_request.md |  43 ++--
 docs/concepts.md                          |   2 +
 docs/configuration.md                     |   6 +-
 docs/design-decisions.md                  |   3 +
 docs/plan.md                              |  12 +-
 docs/product-spec.md                      |   4 +-
 docs/roles.md                             |  13 ++
 docs/session-log.md                       |  (this entry)
 docs/troubleshooting.md                   |   6 +
 docs/user-guide.md                        |   5 +-
 docs/workflow.md                          |   2 +
 install.sh                                |  59 +++-
 21 files changed, 400+ insertions
```

### Notes
- 今天两个 session 合计：38 files touched, 1300+ insertions, 12 developers spawned, 4 Codex reviews, 3 P2 catches
- 开源 backlog 全部清零
- 框架层两个重要演进：Doc Engineer 产品叙事审计 + Lead 主动建议下一步
- 下次优先：场景 3 (全新空项目 /init-project) + tmux 截图

## 2026-03-25 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | install.sh self-update 修复, Solo + Codex 模式定义, Auto PR merge 工作流, GitHub Branch Protection |
| Developers spawned | 0 (Solo + Codex 模式，Lead 全程独立完成) |
| Codex reviews | 2 (PR #4 install.sh self-update, PR #5 workflow 更新) |
| Codex catches | PR #5: 2 P2 — gh CLI 缺少 fallback + start-working 分支检查与 end-working 回 main 不兼容 |
| Key decisions | Solo + Codex 判断标准(单任务+单模块+≤3文件), Auto PR merge(审查完自动建PR合并), GitHub Branch Protection(enforce admins), 确认 dogfooding 场景 3, GitHub Actions CI 延后到场景 3 |

### Files Changed
```
 CLAUDE-TEMPLATE.md          |  28 ++++--
 CLAUDE.md                   |  33 ++++---
 README.md                   |   6 +-
 README.zh-CN.md             |   6 +-
 commands/end-working.md     |   8 ++-
 commands/start-working.md   |  14 +++-
 docs/plan.md                |   9 ++++
 docs/roles.md               |   6 +-
 docs/session-log.md         |  (this entry)
 docs/workflow.md            |  77 ++++++++++++++---
 install.sh                  |  18 ++++
 11 files changed, 170+ insertions
```

### Notes
- 首次完整走通 Solo + Codex 工作流：Lead 独立写代码 → Codex review → Doc Engineer 审计 → auto PR merge
- 首次启用 GitHub Branch Protection，main 分支正式锁定
- Codex review 两次都有效拦截了问题（gh fallback、分支生命周期兼容性）
- 产品决策：确认 dogfooding 场景 3（内部项目）
- GitHub Actions CI 延后：web 项目用 Vercel 自带 CI 足够，等场景 3 再验证独立 CI

## 2026-03-25 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 全面工作流审计, 减少用户审批门(9处改动), 并行读取规则 |
| Developers spawned | 3 (Dev A: 5 commands, Dev B: workflow+user-guide, Dev C: templates) |
| Codex reviews | 1 (PR #7 workflow 审批门优化) |
| Codex catches | PR #7: 2 P2 — env-nogo 报告格式矛盾 + /end-working merge 条件措辞不一致 |
| Key decisions | 用户交互模型统一为 briefing 模式(通知而非审批), /end-working 全自动(不确认 commit message), /start-working 自然对话(不等"start"), 并行不限于写代码(读取/审查也并行) |

### Files Changed
```
 CLAUDE-TEMPLATE.md          |   7 ++--
 CLAUDE.md                   |   6 ++-
 commands/end-working.md     |   2 +-
 commands/env-nogo.md        |   2 +-
 commands/init-project.md    |   2 +-
 commands/migrate.md         |   2 +-
 commands/start-working.md   |   2 +-
 docs/plan.md                |   1 +
 docs/session-log.md         |  (this entry)
 docs/user-guide.md          |  12 +++---
 docs/workflow.md            |   7 ++--
 11 files changed, 30+ insertions
```

### Notes
- 首次使用 Agent Team 模式做文档改动（3 Developer 并行编辑 9 个文件）
- 全面审计发现 27 个用户交互点：保留 8 个(产品决策+不可逆操作)，删除 3 个，简化 3 个
- 用户交互模型统一：Lead 输出 briefing + 建议下一步 → 用户自然回应 → 继续
- 用户反馈：并行不限于写代码，读取/审查任务也应并行——已写入框架规则

## 2026-03-25 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Solo vs Agent Team 判断标准细化（默认 Solo，两条件升级） |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 0 (纯文档标准更新，低风险) |
| Codex catches | N/A |
| Key decisions | Solo 是默认模式；Agent Team 需同时满足"可分解"+"工作量值得"；文件数 ≤3 降为参考值，核心看文件数×每文件改动量 |

### Files Changed
```
 CLAUDE-TEMPLATE.md        |   6 ++--
 CLAUDE.md                 |   6 ++--
 commands/start-working.md |   6 ++--
 docs/plan.md              |   1 +
 docs/session-log.md       |  (this entry)
 docs/workflow.md          |  19 ++++----
 6 files changed, 20+ insertions
```

### Notes
- 用户指出发布时跳过了 Doc Engineer 审计和 plan.md 更新，补做收工流程
- 判断标准从"硬门槛"（单任务+单模块+≤3文件）改为"两条件框架"（可分解×工作量值得），更符合实际判断逻辑
- 今天三个 session 合计：6 files touched this session, 累计 17 files, 0 Codex reviews this session

## 2026-03-25 Session (continued 3)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Agent Team 读写扩展, 四视角全项目 Review + 修复, Pro 内容清理, 升级 scope 文档, Codex bug 修复(trap 作用域+snapshot排序), 去伪存真精简 |
| Developers spawned | 4 (四视角并行 review: 产品/技术/新用户/代码文档) |
| Codex reviews | 2 (1 code review 全部代码改动, 1 pruning plan review) |
| Codex catches | 2 P2 — isparto.sh trap local 变量作用域 bug, snapshot.sh --latest glob 排序不可靠 |
| Key decisions | Agent Team 触发覆盖读+写任务, Pro 内容从开源仓库移除, 截图改为未来视频演示, upgrade 只更新框架不碰用户项目, 去伪存真延后 legacy backup 和 git-clone 迁移代码 |

### Files Changed
```
 CLAUDE-TEMPLATE.md        | 11 ++++++---
 CLAUDE.md                 | 11 ++++++---
 README.md                 | 16 +++++++++----
 README.zh-CN.md           | 18 ++++++++++----
 bootstrap.sh              |  5 ++--
 commands/end-working.md   |  2 +-
 commands/env-nogo.md      |  2 +-
 commands/init-project.md  | 11 ++++-----
 commands/migrate.md       |  8 +++----
 commands/plan.md          |  2 +-
 commands/restore.md       |  2 +-
 commands/start-working.md |  2 +-
 docs/concepts.md          |  2 +-
 docs/configuration.md     | 61 +-------
 docs/product-spec.md      |  8 -------
 docs/workflow.md          | 24 +++++++++------
 install.sh                | 17 +++++++------
 isparto.sh                | 16 ++++++-------
 lib/snapshot.sh           | 31 +++++++++++++------
 scripts/release.sh        |  4 ++--
 20 files changed, 114 insertions(+), 139 deletions(-)
```

### Notes
- 今天四个 session 合计：~28 files touched, 5 PRs merged (#16-#20), 4 Codex reviews, 4 P2 catches
- 首次运行四视角并行 review（产品/技术/新用户/代码文档），发现 20+ 问题并分类修复
- Codex review 再次证明价值：trap 变量作用域 bug 和 snapshot 排序 bug 都是人工不易发现的
- 确立 upgrade 边界原则："upgrade 改 agent 行为，不碰用户已有工作"
- 去伪存真延后两项高风险清理：legacy backup 系统（需 MCP 解耦）和 git-clone 迁移代码（再保留一个版本）

## 2026-03-25 Session (continued 4)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Hotfix (v0.4.0 发布后修复) |
| Tasks completed | isparto.sh exec 修复 (PR #24), 升级输出精简 (PR #25) |
| Developers spawned | 0 (Solo 模式，Lead 独立完成) |
| Codex reviews | 0 (小修复，低风险) |
| Codex catches | N/A |
| Key decisions | 升级输出区分首次安装(详细)和升级(精简), changelog 只展开 Added 其余折叠计数+链接, 依赖/文件/MCP 全通过时各一行 |

### Files Changed
```
 CHANGELOG.md |  28 +++++++++++++
 VERSION      |   2 +-
 install.sh   | 125 ++++++++++++++++++++++++++++++++++++++++-------------------
 isparto.sh   |   2 +-
 4 files changed, 115 insertions(+), 42 deletions(-)
```

### Notes
- v0.4.0 发布后用户实际安装时发现 `;;` 语法错误，根因是 isparto.sh 在升级时被覆盖后 bash 继续从旧偏移读取新文件
- 升级输出从 ~40 行压缩到 ~15 行：changelog 折叠、依赖汇总、文件计数、去掉 Next step
- 两个 hotfix PR 均已合并，准备发布 v0.4.1

## 2026-03-26 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | 命令模板语言匹配修复（7 个 commands/*.md 全部加入语言检测指令） |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 1 (QA review，通过，无问题) |
| Codex catches | None |
| Key decisions | 确认 dogfooding 场景 4（内部项目），commands 模板加入语言检测而非翻译模板本身 |

### Files Changed
```
 commands/end-working.md   | 2 ++
 commands/env-nogo.md      | 2 ++
 commands/init-project.md  | 2 ++
 commands/migrate.md       | 2 ++
 commands/plan.md          | 2 ++
 commands/restore.md       | 2 ++
 commands/start-working.md | 2 ++
 docs/plan.md              | 1 +
 docs/session-log.md       | (this entry)
 9 files changed, 15 insertions(+)
```

### Notes
- 用户在内部项目首次运行 /init-project 时发现中文输入得到英文回复，dogfooding 发现的第一个 UX bug
- 根因：commands/*.md 模板全是英文指令且无语言检测说明，而 CLAUDE-TEMPLATE.md 的语言规则要到 CLAUDE.md 生成后才生效
- 修复策略：在命令模板层加入语言检测（靠近执行时刻），而非翻译模板本身（模板是结构参考）
- templates/*.md 保持英文结构不变——生成内容的语言由 commands 指令控制

## 2026-03-26 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Process Observer 审计增加 C4 检查（plan.md 未完成项与实际状态核对），补标 plan.md 漏标的两项 |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 0 (低风险文档改动，3 个文件 6 行) |
| Codex catches | N/A |
| Key decisions | Process Observer 职责扩展：不仅观察，还要主动检查 plan.md 未完成项是否与代码实际状态一致，发现漏标时提醒 Lead |

### Files Changed
```
 commands/end-working.md  | 4 ++--
 docs/plan.md             | 4 ++--
 docs/process-observer.md | 2 ++
 docs/session-log.md      | (this entry)
 4 files changed, 6 insertions(+), 4 deletions(-)
```

### Notes
- 用户 dogfooding 中发现 plan.md 有两项（Process Observer hooks 实现 + /end-working 集成）已完成但未标记
- 根因：plan.md 更新依赖 Lead "记得"，没有系统性核对机制
- 修复：在 Process Observer 审计 Checklist C 增加 C4 检查项，/end-working 审计指令也同步补充
- 这是 Process Observer 角色的一次职责升级：从纯观察到主动兜底

## 2026-03-26 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | install.sh --upgrade 自动补全项目 hooks 注册, iSparto 自身 settings.json 补全 hooks |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 2 (第一次发现 P1: set -e 下 sys.exit(1) 导致 install.sh 退出; 第二次发现 P2: python3 缺失时静默失败) |
| Codex catches | 1 P1 — set -e + sys.exit(1) 会中断安装流程; 1 P2 — python3 缺失时静默跳过无警告 |
| Key decisions | upgrade 区分"用户内容"(不碰)和"框架基础设施"(自动补全), 用 Python 做 JSON merge 避免 jq 依赖 |

### Files Changed
```
 install.sh            | 69 ++++++++++++++++++++++++++++++++++++++
 .claude/settings.json | (local only, not tracked)
 docs/session-log.md   | (this entry)
 1 file changed, 69 insertions(+)
```

### Notes
- 根因分析：iSparto 在 v0.5.0 加了 Process Observer hooks，但自身的 .claude/settings.json 没注册——"鞋匠不穿鞋"
- 更深层原因：--upgrade 之前只更新全局文件，不碰项目级配置。但 hooks 注册属于框架基础设施，不是用户内容
- 修复策略：upgrade 时检测当前项目（有 CLAUDE.md），自动补全缺失的 hooks 注册
- Codex review 两次都抓到了关键问题：P1 会让安装流程中断，P2 会让 hooks 注册静默失败
- 用户提出"两个视角"框架：本体开发者视角 + 用户体验视角，要同时具备

## 2026-03-26 Session (continued 3)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | v0.5.1 发布（语言匹配 + C4 检查）, v0.5.2 发布（upgrade hooks 注册）, README 首屏重组（EN + ZH-CN）, 自定义角色-模型绑定加入 v1.x 路线图 |
| Developers spawned | 2 (README EN + ZH-CN 并行重组) |
| Codex reviews | 3 (语言修复 QA 1 次, install.sh code review 2 次) |
| Codex catches | 1 P1 — set-e + sys.exit(1) 中断安装; 1 P2 — python3 缺失静默失败 |
| Key decisions | upgrade 区分用户内容/框架基础设施, README 首屏重组（对比表+安装命令前置，名字故事下移）, 自定义角色绑定延后到 v1.x（当前生态绑定最强模型无需配置）, Demo GIF 延后到 dogfooding 后录制 |

### Files Changed
```
 CHANGELOG.md               | 13 ++++
 README.md                  | 136 ++++++++++++++++++++------------------
 README.zh-CN.md            | 136 ++++++++++++++++++++------------------
 VERSION                    |   4 +-
 commands/end-working.md    |   6 +-
 commands/env-nogo.md       |   2 +
 commands/init-project.md   |   2 +
 commands/migrate.md        |   2 +
 commands/plan.md           |   2 +
 commands/restore.md        |   2 +
 commands/start-working.md  |   2 +
 docs/plan.md               |   6 +-
 docs/process-observer.md   |   2 +
 docs/session-log.md        | (this entry)
 install.sh                 |  69 ++++++++++++++++++++
 14 files changed, ~380 insertions
```

### Notes
- 今天 4 个 sub-session，10 个 PR 合并（#33-#42），2 个版本发布（v0.5.1, v0.5.2）
- dogfooding 场景 4 正式启动，首次 /init-project 就发现语言匹配 bug，验证 dogfooding 价值
- Process Observer hooks 首次实战拦截：在 main 上链式执行 git checkout -b && git commit 被 commit-on-main 规则 block
- 用户提出"两个视角"框架（本体开发者 + 用户体验），推动了 upgrade hooks 注册功能
- 外部反馈（X 用户问自定义 agent）触发路线图更新，但附带了前置判断条件（生态开放度）
- README 重组采纳了外部产品建议中的 4/6 项，拒绝了 tagline 建议，延后了 GIF 录制
- 下次优先：dogfooding 场景 4 继续 + 终端录屏 GIF

## 2026-03-26 Session (continued 4)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 (Dogfooding 验证) — 续 |
| Tasks completed | Codex review 触发规则重构：从"列举要 review 的"翻转为"列举可跳过的，其余全部 review" |
| Developers spawned | 0 (Solo + Codex 模式) |
| Codex reviews | 1 (PR #44 全部改动，发现 3 个一致性问题并修复) |
| Codex catches | 3 P2/P3 — hotfix 规则未对齐 Tier 2 config 豁免, B1 判定标准未包含 config-only 跳过, workflow.md Agent Team 流程仍引用 B1-B3 而非 B1-B4 |
| Key decisions | Codex review 默认触发(Tier 1)，仅纯视觉/config(Tier 2 QA only)和纯文档/格式化(Tier 3 skip)可跳过；新增 Wave 级兜底(B4)；检查项 13→14 |

### Files Changed
```
 CLAUDE-TEMPLATE.md       |  2 +-
 CLAUDE.md                |  2 +-
 docs/concepts.md         |  2 +-
 docs/process-observer.md |  8 +++++---
 docs/roles.md            |  2 +-
 docs/session-log.md      | (this entry)
 docs/workflow.md         | 47 +++++++++++++++++++++++++++++++++++++----------
 6 files changed, 46 insertions(+), 17 deletions(-)
```

### Notes
- 触发原因：用户在另一个项目 dogfooding 时发现 Codex review 经常不触发，根因是旧规则只定义了"高风险"和"纯 UI"两端，中间地带（业务逻辑、API、数据模型等）默认被跳过
- 修复策略：翻转默认行为——从"opt-in"改为"opt-out"，只有明确列入跳过清单的才不触发
- 这是框架级改动，影响所有安装 iSparto 的项目（通过 CLAUDE-TEMPLATE.md）
- Codex review 再次证明价值：一次 review 发现 3 个交叉引用一致性问题，人工很难全部定位
- 新增 B4 Wave 级兜底检查：确保即使单次改动被分类跳过，Wave 结束时仍有至少一次批量 review

## 2026-03-30 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | 阶段性 Review（跨 Wave，v0.8 准备） |
| Tasks completed | 四视角并行 Review（57 发现）、系统决策（14 接受/18 拒绝/9 延后）、3 Wave 执行（产品方向+代码修复+文档修复）、v0.5/v0.6 里程碑标记、v0.8 验收条件定义 |
| Developers spawned | 4 (四视角 Review) + 2 (Doc Engineer + Process Observer 审计) |
| Codex reviews | 3 (Wave B 实现 6 项代码修复, snapshot 向后兼容修复, QA 全量 review) |
| Codex catches | QA review: 无 defect; Doc Engineer 发现 snapshot 编码向后兼容问题（已修复） |
| Key decisions | 删掉 ASCII banner 和 CI 质量门、v0.8 验收条件重新定义（4 项，3 项已完成）、不立即发版（等 v0.7.0 打包）、57 个 review 发现的系统性取舍（接受/拒绝/延后） |

### Files Changed
```
 CHANGELOG.md             |  2 --
 README.md                |  2 ++
 README.zh-CN.md          |  2 ++
 commands/init-project.md |  5 +++++
 docs/configuration.md    |  2 +-
 docs/plan.md             | 33 ++++++++++++++++++---------------
 docs/product-spec.md     |  4 ++--
 docs/troubleshooting.md  | 10 ++++++++++
 docs/workflow.md         |  9 +++++----
 install.sh               |  5 +++--
 isparto.sh               |  4 ++--
 lib/snapshot.sh          | 20 +++++++++++++++++++-
 scripts/release.sh       | 16 +++++++++++-----
 docs/session-log.md      | (this entry)
 14 files changed, 80 insertions(+), 34 deletions(-)
```

### Notes
- 首次对项目做系统性阶段 Review：四视角并行（新用户体验/产品完整度/代码健壮性/文档一致性），产出 57 个发现
- 系统决策模式：不逐项讨论，一次性出决策表让用户 review，高效对齐
- Doc Engineer 发现 snapshot.sh 编码变更的向后兼容问题——旧快照用 `__` 编码，新代码用 `%XX`，已加 legacy_encode_path fallback
- Process Observer 审计标记 B3（QA 缺失）为 FAIL，补跑 Codex QA review 后通过
- v0.8 前三项验收条件本次全部完成，只剩"1 个外部用户冷启动验证"
- 用户决定不立即发版，等后续工作一起打包为 v0.7.0
- 累计统计（10 sessions）：~29 Developer spawned, ~17 Codex reviews, ~18 issues caught

## 2026-03-30 Session (continued)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.6 架构加固 — 续（v0.6.5 + v0.6.6 发布） |
| Tasks completed | Process Observer Sonnet 降级, agent 定义文件安装修复, rejected approaches 追踪机制, "no direct code" 理由集中化 + 行为模板 Tier 2b, v0.6.5 发布, v0.6.6 发布 |
| Developers spawned | 0 (Solo 模式) |
| Codex reviews | 0 |
| Codex catches | N/A |
| Key decisions | Process Observer 审计从 Opus 降级 Sonnet 4.6（降低 token 消耗，关键检查已由 hooks 覆盖）, 行为模板（commands/*.md, templates/*.md）归类为 Tier 2b（Developer review only, 跳过 QA）, rejected approaches 写入 plan 模板防止 AI 重复尝试已否决路径 |

### Files Changed
```
 CHANGELOG.md                     | 25 +++++++++++++++++++++
 CLAUDE-TEMPLATE.md               | 10 ++++---
 CLAUDE.md                        | 16 ++++----
 VERSION                          |  2 +-
 agents/process-observer-audit.md | 30 ++++++++++++++++++++++++++++++
 commands/end-working.md          |  3 ++-
 commands/start-working.md        |  1 +
 docs/concepts.md                 |  1 +
 docs/configuration.md            | 11 ++++---
 docs/design-decisions.md         |  4 ++++
 docs/process-observer.md         |  2 ++
 docs/roles.md                    | 14 ++++----
 docs/workflow.md                 | 14 ++++++++++--
 install.sh                       |  3 +++
 templates/plan-template.md       | 10 +++++++++
 docs/session-log.md              | (this entry)
 15 files changed, 122 insertions(+), 24 deletions(-)
```

### Notes
- 本次 session 未走 /end-working 收工流程，session log 由下次 session 补录
- v0.6.5 修复 agent 定义文件缺失（v0.6.4 的 Sonnet 降级因缺文件静默回退 Opus）
- v0.6.6 引入两个框架级改进：rejected approaches 追踪 + 行为模板分类
- 8 个 PR 合并（#80-#87），2 个版本发布
- 累计统计（11 sessions）：~29 Developer spawned, ~17 Codex reviews, ~18 issues caught

## 2026-03-30 Session (continued 2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | v0.8 准备（Harness Engineering 研究吸收） |
| Tasks completed | session log 补录(PR #88), design-decisions CLAUDE-TEMPLATE 例外(PR #89), 自验证启动+Stateless Session 原则(PR #90), health check 命令源修复(PR #91), v0.6.7 发布(PR #92-#93) |
| Developers spawned | 0 (Solo 模式) |
| Codex reviews | 1 (Tier 2b review: start-working.md runtime health check) |
| Codex catches | 1 P2 — CLAUDE.md Build 字段是描述性文本(如 "Xcode")，直接执行会误报；限制为 Common Commands 区域 |
| Key decisions | 吸收 Harness Engineering 研究(Anthropic long-running agent harness + 12 Factor Agents)，自验证启动设为非阻塞(通知而非门禁)，排除 5 项大团队需求(依赖层级/垃圾回收/JSON 替代 Markdown/自动 refactoring/Benchmark) |

### Files Changed
```
 CHANGELOG.md               | 12 ++++++++++++
 VERSION                    |  2 +-
 commands/start-working.md  | 17 +++++++++++++----
 docs/concepts.md           |  1 +
 docs/design-decisions.md   |  4 +++-
 docs/session-log.md        | (this entry + backfill)
 6 files changed, ~36 insertions
```

### Notes
- 首次基于外部研究（OpenAI Harness Engineering + Anthropic long-running agent + 12 Factor Agents）系统性吸收改进
- Codex review 补跑流程验证：Tier 2b 行为模板改动 Lead 直接写、Codex review，本次初始遗漏 review 后补跑，Codex 抓到 P2
- 用户澄清 Solo 模式理解：确认 Lead 写行为模板 + Codex review 是 Tier 2b 正确流程
- 6 个 PR 合并（#88-#93），1 个版本发布（v0.6.7）
- 累计统计（12 sessions）：~29 Developer spawned, ~18 Codex reviews, ~19 issues caught

## 2026-03-31 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 6 (安全审计系统) + post-Wave cleanup |
| Tasks completed | Wave 6 全部 11 项（security-patterns.json、pre-commit-security.sh、pre-tool-check.sh L1 扩展、/security-audit 命令、/end-working 集成、/init-project+/migrate 集成、Codex/Developer/DocEng prompt 安全段、gitignore-security-baseline.md、docs/security.md、install.sh 注册、README+design-decisions 更新）+ dangerous-ops 敏感文件检测迁移 |
| Developers spawned | 0 (Solo 模式，4 次 Codex 实现调用 + 1 次 Codex review) |
| Codex reviews | 1 (发现 1 个 critical bug) |
| Codex catches | 1 Critical — pre-commit-security.sh regex 双重解码 bug（extract_json_string + decode_json_escapes 双重处理反斜杠，`\s` → `s`，导致所有 regex pattern 失效） |
| Key decisions | 三层安全防御架构(L1 实时/L2 pre-commit/L3 里程碑)、security-patterns.json 单一数据源、realtime_critical 子集解决 L1 性能、dangerous-ops 敏感文件检测迁移到安全系统(子串匹配误报→staged 文件扫描)、Process Observer WARNING 噪音暂不处理(观察再决定) |

### Files Changed
```
PR #96 (feat/security-audit): 23 files changed, +1140, -20
 CHANGELOG.md                                     | 26 +
 CLAUDE-TEMPLATE.md                               |  3 +
 CLAUDE.md                                        |  7 +-
 README.md                                        | 10 +-
 README.zh-CN.md                                  | 10 +-
 VERSION                                          |  2 +-
 commands/end-working.md                          |  9 +-
 commands/env-nogo.md                             |  2 +-
 commands/init-project.md                         | 12 +-
 commands/migrate.md                              |  9 +-
 commands/security-audit.md (NEW)                 | 58 +
 docs/design-decisions.md                         |  3 +
 docs/plan.md                                     | 13 +
 docs/process-observer.md                         | 27 +
 docs/product-spec.md                             |  4 +-
 docs/roles.md                                    | 35 +
 docs/security.md (NEW)                           | 89 +
 docs/user-guide.md                               |  3 +-
 hooks/.../security-patterns.json (NEW)           |154 +
 hooks/.../pre-commit-security.sh (NEW)           |571 +
 hooks/.../pre-tool-check.sh                      | 52 +
 install.sh                                       |  7 +
 templates/gitignore-security-baseline.md (NEW)   | 54 +

PR #97 (fix/dangerous-ops-dedup): 3 files changed, +3, -39
 docs/design-decisions.md                         |  3 +-
 docs/process-observer.md                         |  4 +-
 hooks/.../dangerous-operations.json              | 35 -
```

### Notes
- 本次 session 跨越了 context compaction（从上一个对话延续），Wave 6 实现在 compaction 前完成，本 session 完成了 commit/push/PR/merge + post-Wave cleanup + 发版
- Codex 发现的 critical bug（regex 双重解码）如果未修复，会导致 L2 pre-commit 扫描对所有 pattern 完全失效——这是 cross-model review 的价值体现
- 发布 2 个版本：v0.6.8（三层安全审计系统）、v0.6.9（敏感文件检测迁移）
- 4 个 PR 合并（#96-#99）
- 待验证：在实际项目（Meic/Yonya）中跑 L1 Write 拦截和 L2 .secureignore 白名单的端到端测试
- Process Observer 审计：17 PASS, 1 WARNING (C1: session log 未显式记录 Doc Engineer 执行), 0 FAIL
- Process Observer 改进建议：(1) CLAUDE.md 分支规则补充 docs/ 和 release/ 前缀；(2) session log 模板增加 Doc Engineer 执行记录行
- 累计统计（13 sessions）：~29 Developer spawned, ~19 Codex reviews, ~20 issues caught

## 2026-03-31 Session #2

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 6 (安全审计系统) — 后续扩展 |
| Tasks completed | security-patterns.json 全栈覆盖扩展（7 类 ~50+ sensitive_files pattern + 2 个 secrets pattern + gitignore 基线同步 + 文档更新） |
| Developers spawned | 0 (Solo 模式，Lead 直接编辑 rules/*.json — 自引用边界) |
| Codex reviews | 1 |
| Codex catches | P1 — bundle 目录模式（*.dSYM/*.xcarchive/\*.app）在 pre-commit scanner 中无法匹配内部路径，移除改为仅 gitignore 覆盖；P2 — gitignore 中 core.\* 会静默隐藏 core.ts 等合法源文件，从 gitignore 移除 |
| Key decisions | *.map 默认 BLOCK（source map = 完整源码泄露）、*.log 不加入 sensitive_files（误报率高，L2 内容扫描已覆盖）、构建输出目录只进 gitignore 不进 sensitive_files、L1 不扩展（构建产物是文件级非内容级）、inline source map 加入 secrets（data URI 内联补位）、*.sql/core/.vscode 从 sensitive_files 降级到 gitignore_baseline（误报风险） |

### Files Changed
```
PR #101 (fix/security-patterns-fullstack): 5 files changed, +128, -3
 docs/design-decisions.md                           |  6 +++
 docs/plan.md                                       |  3 +-
 docs/security.md                                   | 14 +++++
 hooks/.../security-patterns.json                   | 60 ++-
 templates/gitignore-security-baseline.md           | 48 +++
```

### Notes
- 动机：Claude Code source map 泄露事件暴露构建产物安全盲区，iSparto 作为通用框架需全栈覆盖
- Plan mode 讨论阶段调整了 6 个高误报 pattern 的归属（sensitive_files → gitignore_baseline only）
- Codex review 发现 2 个 pattern 有效性问题并修复；Doc Engineer 审计发现 gitignore 模板缺 .vscode 条目并补齐
- Process Observer 审计：9 PASS, 3 WARNING (均为 mid-session 预期状态), 0 FAIL
- 发布 v0.6.10
- 累计统计（14 sessions）：~29 Developer spawned, ~20 Codex reviews, ~22 issues caught

## 2026-03-31 Session #3

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 6 (安全审计系统) — 流程修复 |
| Tasks completed | /end-working 分支守卫（commit 前检查分支）+ docs/release/ 分支前缀正式化 |
| Developers spawned | 0 (Solo 模式) |
| Codex reviews | 1 |
| Codex catches | P2 — docs/session-log-MMDD 分支名不在 feat/fix/hotfix/ 允许列表中，需同步更新 CLAUDE.md 和 Process Observer checklist |
| Key decisions | /end-working step 6 加分支守卫解决 session log 提交撞 hook 的时序问题；docs/ 和 release/ 正式纳入允许的分支前缀 |

### Files Changed
```
PR #104 (fix/end-working-branch-guard): 3 files changed, +11, -5
 CLAUDE.md                  | 4 ++--
 commands/end-working.md    | 8 ++++++-
 docs/process-observer.md   | 4 ++--
```

### Notes
- 用户发现 /end-working 流程设计缺陷：session log commit 时机未考虑"主分支已 merge、当前在 main"的场景，每次先犯错再被 hook 拦截
- 根因是模板执行顺序的时序假设问题，不是模型不理解规则
- Codex review 发现修复引入了新的不一致（docs/ 分支前缀未在规则中），一并修复
- 同时解决了上个 session Process Observer 建议的 "CLAUDE.md 分支规则补充 docs/ 和 release/ 前缀"
- 累计统计（15 sessions）：~29 Developer spawned, ~21 Codex reviews, ~23 issues caught

## 2026-04-03 Session

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | 跨 Wave 修复（Codex-first 执行流程缺陷） |
| Tasks completed | Implementation Protocol 添加到 CLAUDE.md/CLAUDE-TEMPLATE.md；Hook 拦截消息改进；plan.md/workflow.md 引用补全；v0.6.12 发版 |
| Developers spawned | 0（自引用边界：框架编辑自身 .md/.sh/.json 文件） |
| Codex reviews | 0（同上，自引用例外） |
| Codex catches | None |
| Key decisions | 三层防御策略（指令预防 + Hook 拦截 + 文档引用）；不改 allowed_extensions；不新增 slash command |

### Files Changed
```
 CHANGELOG.md                                     | 13 +++++++++++++
 CLAUDE-TEMPLATE.md                               | 19 +++++++++++++++++++
 CLAUDE.md                                        | 19 +++++++++++++++++++
 VERSION                                          |  2 +-
 commands/plan.md                                 |  2 +-
 docs/workflow.md                                 |  2 ++
 hooks/process-observer/rules/workflow-rules.json |  4 ++--
 hooks/process-observer/scripts/pre-tool-check.sh |  6 +++---
 8 files changed, 60 insertions(+), 7 deletions(-)
```

### Notes
- 用户反馈 Lead (Opus) 从不主动调 Codex 先写代码，诊断发现规则→实践的转化链条断裂：文档说了"要做什么"但没说"怎么做"
- 根因：(1) plan→执行之间无桥梁 (2) CLAUDE.md 指令太软、无工具名 (3) Hook 拦截消息不可操作
- 修复：Implementation Protocol 写入 CLAUDE.md，明确 `mcp__codex-reviewer__codex` 工具名和 7 步执行序列
- 用户提出 3 个增量优化全部采纳：plan.md 触发点显式约束、Solo/Agent Team 双适用声明、Codex prompt 拦截消息引用模板
- 累计统计（16 sessions）：~29 Developer spawned, ~21 Codex reviews, ~23 issues caught

## 2026-04-05 Session (2)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | 当前阶段（ad-hoc 质量修复 + IR 链修复） |
| Tasks completed | 质量审计 Phase A（安装器加固、README 更新、快照安全修复）、IR 触发链修复、v0.6.19 发版 |
| Key decisions | IR 触发无条件化（去掉 "user-visible behavior changes" 判断门）；CRITICAL 发现不阻塞 commit，阻塞下个 Wave 启动；Phase A/B 拆分（冷启动关键 vs 反馈驱动） |

### Files Changed
```
 CLAUDE-TEMPLATE.md               |  6 +++---
 CLAUDE.md                        |  6 +++---
 CHANGELOG.md                     | 13 +++++++++++++
 README.md                        |  4 +++-
 README.zh-CN.md                  |  4 +++-
 VERSION                          |  2 +-
 agents/process-observer-audit.md |  2 ++
 bootstrap.sh                     | 17 ++++++++++++-----
 commands/end-working.md          | 23 ++++++++++++++++-------
 commands/plan.md                 |  2 +-
 docs/roles.md                    |  2 +-
 docs/workflow.md                 |  4 ++--
 install.sh                       | 56 +++++++++++++++++++++++++++++++-----------------------
 lib/snapshot.sh                  |  6 +++++-
 14 files changed, 97 insertions(+), 50 deletions(-)
```

### Notes
- 全项目质量审计（8 模块并行扫描），识别出安装器加固、快照安全、IR 触发链断裂等问题
- Phase A（冷启动关键修复）通过 PR #142、#143 完成；Phase B（反馈驱动优化）留待 v0.8 后
- IR 触发链修复（PR #144）：end-working.md 新增 Step 3 Wave Boundary Review + plan.md 无条件 IR spawn + Process Observer F1 检查 + 全文档同步
- 发版 v0.6.19（PR #146），含 PRs #142-144 的所有修复

## 2026-04-07 Session (1)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | i18n Cleanup — Wave 1（Convention + Guardian，scaffolding-only） |
| Tasks completed | 五波 i18n 清理计划评审 + 8 项 patch 应用 + plan mode 批准 + Wave 1 全部产出（文档语言公约 + 守卫脚本 + plan.md 跨会话 BLOCKING marker） |
| Key decisions | 不拆分 design-decisions.md（in-place 翻译，保留表格）；架构冲突（Addition 3 引用的 architecture.md）由 design-decisions.md 替代写入 Wave 5 人工 review checklist；Wave 4→5 跨会话边界从"建议"升级为强制（Wave 4 改了 end-working.md 必须新会话验证 gate）；引入 BLOCKING marker 机制（plan.md 顶部 marker + Wave 2 Dev B 在 start-working.md 加自动检测）作为跨会话边界的强制机制 |

### Files Changed
```
 CLAUDE.md                 |  20 +++++
 docs/plan.md              |  26 ++++++
 scripts/language-check.sh | 193 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+)
```

### Notes
- 5 Wave 计划全文存于 `~/.claude/plans/distributed-twirling-harp.md`
- 四层语言架构：Tier 1 系统 prompt 层（CLAUDE.md / commands / agents / templates / hooks / 全部 shell 脚本）、Tier 2 参考文档（docs/*.md 除历史）、Tier 3 用户入口（README + docs/zh/quick-start + CONTRIBUTING）、Tier 4 历史归档（session-log / framework-feedback / plan.md / CHANGELOG）
- 关键设计原则：Tier 1 文件不得 hard-code 任何具体语言的用户面字符串（"hard-coded user-facing strings rule"），Lead 在运行时按用户语言生成；示例本身也不得 hard-code（"illustrative-example rule"，否则 guardian 会拦截示例自身）
- Wave 1 baseline：scripts/language-check.sh 检测出 166 Tier 1 + 391 Tier 2 违规行（共 557 行），目标 Wave 2 → Tier 1 = 0，Wave 3 → Tier 2 = 0
- Wave 1 是 scaffolding only：只引入新章节和守卫脚本，不翻译任何已有文件；CLAUDE-TEMPLATE.md 同步刻意延后到 Wave 2 Dev A
- Doc Engineer 审计 PASS（9/9，1 N/A — CLAUDE-TEMPLATE.md 间隙是有意为之）；Process Observer 审计 PASS（11/11，3 N/A — Codex review/Implementation Protocol/IR 触发都是 N/A）
- 跨会话强制：Wave 1 改了 CLAUDE.md 顶部，新规则只能通过下次 session start 时的 system-reminder 注入加载，本 session 必须关闭，Wave 2 在新 session 启动
- BLOCKING marker 已写入 docs/plan.md 顶部（advisory），自动检测在 Wave 2 Dev B Sub-task B-bonus 接好（届时 /start-working 读到 marker 会硬停等待用户确认是否新 session）
- 执行时提醒（用户 confirm）：R3（IR 没触发的回归检查）写的是 PR #149，应为 PR #144（IR 断链修复 PR）；本 plan 文件批准时未改动，Wave 2 完成时 IR 若未自动 spawn 立即报告
- Wave 1 PR：#150（已 merge，fast-forward 到 main）

## 2026-04-07 Session #2

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | i18n Cleanup — Wave 2 (Tier 1 Englishization, 4-Dev Agent Team) |
| Tasks completed | All Tier 1 files Englishized (CLAUDE.md, CLAUDE-TEMPLATE.md, 9 commands/, agents/process-observer-audit.md, templates/gitignore-security-baseline.md, hooks/process-observer/scripts/pre-tool-check.sh, hooks/process-observer/rules/workflow-rules.json) + Sub-task B-bonus1 (start-working.md Step 0 BLOCKING marker auto-detection) + 3 post-IR Principle 1 fixes (env-nogo.md, end-working.md, process-observer-audit.md) + Wave 2 → Wave 3 BLOCKING marker rewrite |
| Key decisions | (1) Self-referential boundary applies — Devs use direct Edit instead of mcp__codex-dev__codex for translation work (Opus is the right model for natural-language translation; allowed_extensions covers .md/.sh/.json). (2) MCP rename bug (`codex-reviewer → codex-dev` migration in start-working.md Step 7) deferred to separate hotfix PR `fix/mcp-rename-migration-guard` — Out of Scope per "translation only" rule. (3) IR caught 3 residual Principle 1 violations (1 MAJOR + 2 MINOR) the mechanical CJK guardian could not detect — fixed in same Wave before merge. (4) Phase 2 Cross-Check pattern adopted — parallel sub-agents cannot see each other's outputs, so Lead-orchestrated grep-based scan replaces the original "Dev D second-checks Principle 1 if early" pattern. |

### Files Changed
```
 CLAUDE-TEMPLATE.md                               |  28 +--
 CLAUDE.md                                        | 242 +++++++++++------------
 agents/process-observer-audit.md                 |   4 +-
 commands/end-working.md                          |   8 +-
 commands/env-nogo.md                             |   4 +-
 commands/init-project.md                         |   4 +-
 commands/migrate.md                              |   8 +-
 commands/plan.md                                 |   2 +-
 commands/release.md                              |   2 +-
 commands/restore.md                              |   4 +-
 commands/start-working.md                        |  25 ++-
 docs/independent-review.md                       |  53 +++++
 docs/plan.md                                     |  36 +++-
 hooks/process-observer/rules/workflow-rules.json |   6 +-
 hooks/process-observer/scripts/pre-tool-check.sh |  18 +-
 templates/gitignore-security-baseline.md         |  26 +--
 16 files changed, 281 insertions(+), 189 deletions(-)
```

### Notes
- Approved Wave 2 plan at `~/.claude/plans/immutable-zooming-codd.md` (this session). User mandated 5 patches mid-plan that fixed: Sub-task B-bonus2 stripped (MCP fix is logic, not translation), Step 3 verification is presence check not diff check, Process Observer must run AFTER IR (PR #144 F1 dependency), Cross-check is Lead-orchestrated Phase 2 not sibling sub-agents (parallel limitation), Hook smoke test reads input contract first (don't assume env vars vs stdin JSON).
- Verification result: Tier 1 = 0 (target met), Tier 2 = 391 (Wave 3 scope, unchanged).
- Workload concentration: 72% of Tier 1 violations (120 of 166 lines) were in CLAUDE.md alone. Dev A was the wall-clock bottleneck; Dev B/C/D had minimal text changes but real verification work (Dev D's hook smoke test exercised 7 paths to validate string changes did not break interception).
- Hook smoke test methodology (Dev D): PATH-prepended stub `git` returning `branch --show-current = main` (rest delegated to /usr/bin/git) — exercised commit-on-main, merge-on-main, push-on-main, direct-code-write, codex-unstructured-prompt rules without modifying real git state. Test commands documented in Dev D's report for future re-use.
- Independent Reviewer: PROCEED, no CRITICAL. Caught 3 residual Principle 1 violations the mechanical guardian missed (Suggestion 3 in framework-feedback-0407.md). All 3 fixed in same Wave.
- Doc Engineer: PROCEED, 0 CRITICAL/0 MAJOR. 1 MINOR (`docs/roles.md` line 337 stale `(English)/(Chinese)` reference) deferred to Wave 3 since the file is in Tier 2 cleanup scope.
- Process Observer: 8 PASS / 0 WARN / 0 FAIL. F1 (Independent Review at Wave boundary) verified PASS by reading docs/independent-review.md.
- 3 framework-side rule corrections saved to `docs/framework-feedback-0407.md`: (1) plan.md update timing rule clarification, (2) F1 check spawn-source clarification, (3) Principle 1 guardian enforcement gap.
- Cross-session boundary required before Wave 3 — Wave 2 fully Englishized CLAUDE.md, the new content must ride the next session's system-reminder injection. BLOCKING marker rewritten at top of plan.md. start-working.md Step 0 (added in this Wave) will auto-detect on next session and gate the boundary.
- Deferred bug: `commands/start-working.md` Step 7 MCP server rename migration logic (`codex-reviewer → codex-dev`) breaks hook interception on stale installs (where the actual MCP is still under `codex-reviewer`). To be fixed in separate hotfix PR `fix/mcp-rename-migration-guard`. Documented at the top of the new BLOCKING marker section in plan.md and in the Wave 2 Deferred items list.

## 2026-04-07 Session #3

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | i18n Cleanup — Wave 3 (Tier 2 Englishization, 4-Dev Agent Team) |
| Tasks completed | All 9 `docs/*.md` Tier 2 files Englishized (process-observer, configuration, security, product-spec, design-decisions, workflow, roles, troubleshooting + zero-edit independent-review per Lead-Resolution Option A) + cross-file anchor coordination (workflow.md ↔ process-observer.md `#real-time-interception-hooks` and `#post-hoc-audit-sub-agent`) + carry-over Wave 2 MINOR cleanup (roles.md:337 stale `(English)/(Chinese)` reference) + Lead-Resolution Option A (added `docs/independent-review.md` to `scripts/language-check.sh` Tier 2 exclusion set) + Wave 3 → Wave 4 BLOCKING marker rewrite |
| Key decisions | (1) Lead-Resolution Option A — `independent-review.md:33` is row 8 of Wave 2 IR alignment table quoting a Tier 4 plan.md section title verbatim; translating in place would mutate the immutable IR audit trail. Resolved by 1-line + comment script edit treating the file as Tier-4-like exclusion (matches existing pattern for session-log.md / plan.md / framework-feedback-*.md). (2) Pre-Defined Anchor Renames table locked the new English anchor names a priori, eliminating Dev A ↔ Dev D coordination overhead. (3) product-spec.md milestone diagram converted from CJK ASCII to mermaid timeline (Option A) — render-stable across width changes, dependency already in roles.md. (4) Phase 2 Step 4d terminology grep extended to scan Tier 1 (Wave 2 canonical) AND Tier 2 (Wave 3 new) jointly; Wave 2 forms always win on drift (zero drift found). (5) Wave 3 PR pure-translation discipline enforced — `.claude/settings.json` matcher migration (from /start-working Step 7 hot-repair) excluded from Wave 3 commit, queued as separate chore PR. |

### Files Changed
```
 docs/configuration.md      | 144 +++++++++----------
 docs/design-decisions.md   |  68 ++++-----
 docs/independent-review.md |  59 ++++++++
 docs/plan.md               |  37 ++++-
 docs/process-observer.md   | 334 ++++++++++++++++++++++-----------------------
 docs/product-spec.md       | 127 ++++++++---------
 docs/roles.md              |  12 +-
 docs/security.md           | 132 +++++++++---------
 docs/troubleshooting.md    |   6 +-
 docs/workflow.md           |  18 +--
 scripts/language-check.sh  |  12 +-
 11 files changed, 524 insertions(+), 425 deletions(-)
```

### Notes
- Approved Wave 3 plan at `~/.claude/plans/dreamy-strolling-duckling.md` (this session). 4+1 Round 1 patches and 3 Round 2 fixes applied during plan iteration before approval. Final plan: 838 lines, comprehensive Pre-Execution / Mode Selection / Implementation Protocol / 4 Dev Briefs / Lead-Resolution / Canonical Terminology / Pre-Defined Anchor Renames / Phase 2 / Post-Dev Gates / PR + Cross-Session Boundary / Out of Scope / Risks / End-to-End Verification / Appendix.
- Verification result: Tier 1 = 0 (held from Wave 2), Tier 2 = 391 → 0 (target met for first time in project history), Principle 1 = 0. `bash scripts/language-check.sh` reports `0 / 0 / 0`.
- Workload distribution: Dev A 151 violations / 1 file (process-observer.md, 7 cascading dangerous-op tables, 33 headings, hardest single file), Dev B 131 / 2 files (configuration + security), Dev C 92 / 2 files (product-spec + design-decisions, hardest semantic with 71-row decision table), Dev D 18 / 4 files (workflow + roles + troubleshooting + zero-edit independent-review). 4 Devs in true parallel; total wall-clock dominated by Dev A.
- Bonus translations spotted by Devs (transparent reporting): row 39 talk title "AI Agent 的道与术" by Wang Wei @onevcat → "The Way and the Craft of AI Agents" (semantic-preserving, attribution preserved); row 68 corrupt UTF-8 `描��` → inferred `描述` → "description". No data loss.
- Independent Reviewer: PROCEED, 0 CRITICAL, 0 MAJOR, 1 MINOR (forward reference in `scripts/language-check.sh` comment to a not-yet-written plan.md section). MINOR resolved in same commit by adding sub-bullet "Lead-Resolution Option A — language-check.sh independent-review.md exclusion" to plan.md Wave 3 entry.
- Doc Engineer: PASS with 1 MINOR (pre-existing CLAUDE-TEMPLATE.md ↔ CLAUDE.md divergence, out of Wave 3 scope — not a Wave 3 regression).
- Process Observer (Wave-level audit during Wave 3 execution): 7 PASS / 1 WARN (expected in-progress plan.md state) / 0 FAIL. F1 (IR at Wave boundary) PASS verified.
- Process Observer (Session-level audit, this /end-working): 14 PASS / 0 WARN / 0 FAIL. No deviations.
- Phase 2 Lead-orchestrated cross-check: 4a language-check 0/0/0, 4b roles.md:337 cleaned, 4c anchor sweep verified (workflow.md uses new English anchors, process-observer.md has new English headings, no CJK anchors remain), 4d terminology drift zero across Tier 1 + Tier 2 scope.
- Cross-session boundary required before Wave 4 — Wave 3 fully Englishized `docs/*.md` Tier 2 files which are IR's semantic input AND Lead's planning context. BLOCKING marker rewritten at top of plan.md (auto-detected by /start-working Step 0 in next session).
- Wave 3 PR: #156 (`feat/wave-3-tier2-english`, 11 files, 524 insertions, 425 deletions, merged via `gh pr merge --merge --delete-branch`).
- Framework-side rule correction noted by PO (G4 detail): plan.md "下一步" / "技术生态追踪" sections (lines 259–274) remain in Chinese. CLAUDE.md Tier 4 exemption covers historical entries, but these are forward-looking planning items — the four-tier architecture is silent on language expectations for forward-looking sections of an otherwise-excluded file. Saved to `docs/framework-feedback-0407c.md` for next session's consideration.
- Deferred items unchanged from previous session: `.claude/settings.json` hook matcher chore PR (independent of Wave 3), `commands/start-working.md` Step 7 auto-add branch guard (independent hotfix), `language-check.sh` `/end-working` blocking-gate promotion (Wave 4 main task).

## 2026-04-08 Session — i18n Cleanup Wave 5 (finalization: Tier 3 onramp + carry-over polish + end-to-end audit)

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Wave 5 — i18n Cleanup Finalization (closes the 5-Wave i18n cleanup project) |
| Tasks completed | T1 plan.md placeholder + carry-over cleanup (74723f5); T2 CLAUDE-TEMPLATE.md ↔ CLAUDE.md sync sweep (9572dbe); T3 Process Observer F1 IN-PROGRESS state (67ce9f1); T4 docs/zh/quick-start.md NEW 117-line Chinese Tier 3 onramp (6212c16); T5 README.zh-CN.md Chinese pointer after hero (1538d24); T6 CONTRIBUTING.md Documentation Language Convention section (6b039f6); T9 CHANGELOG [Unreleased] Wave 1-5 entry (750dcac); T7-DE fix README.md parallel bilingual pointer (1fec975); T7 audits (Doc Engineer iter 2 PASS / Process Observer 12P-1IP-0W-0F / Independent Reviewer Wave Boundary PROCEED); T8 Human review checklist into 3 destinations byte-identical; T10 plan.md final evidence promotion (be92589); Wave 5 IR audit trail commit (7a05214). PR #159 merged to main via `gh pr merge --merge --delete-branch`. |
| Key decisions | (1) Wave 5 scope lock after /start-working — framework-polish hotfixes #1/#2/#3 and repo restructure deferred outside Wave 5; only i18n-adjacent carry-overs (CLAUDE-TEMPLATE sync, PO F1 IN-PROGRESS) absorbed. (2) Solo + Lead direct edit mode reaffirmed (self-referential boundary, Wave 4 precedent, zero code changes, zero Codex calls). (3) No Wave 5→6 BLOCKING marker — two Tier 1 edits don't enter Lead's system-reminder cache (CLAUDE-TEMPLATE.md read only at /init-project time; agents/process-observer-audit.md read by fresh sub-agent spawn). (4) audit-fix-reaudit loop iteration 1 FAIL on Doc Engineer item 7 (README.md missing parallel English block to match T5 addition) → Lead fix 1fec975 → fresh re-spawn iteration 2 PASS. First natural Wave 4 mechanism real-world exercise. (5) Human review checklist delivered byte-identical to 3 destinations (plan.md Wave 5 entry / PR #159 description / conversation briefing) as per plan T8. |

### Files Changed

```
CHANGELOG.md                     |  13 ++++
 CLAUDE-TEMPLATE.md               |   6 +-
 CONTRIBUTING.md                  |  29 +++++++
 README.md                        |   4 +
 README.zh-CN.md                  |   4 +
 agents/process-observer-audit.md |   6 +-
 docs/independent-review.md       | 163 +++++++++++++++++++++++++++++++++++++++
 docs/plan.md                     |  97 +++++++++++++++++++----
 docs/zh/quick-start.md           | 117 ++++++++++++++++++++++++++++
 9 files changed, 419 insertions(+), 20 deletions(-)
```

### Notes

- **Session split across a context-compaction boundary.** This is the continuation half; the first half executed plan-approval + T1 + branch rename + T2-T6 + T7-DE (with audit-fix-reaudit loop) + T7-PO. Continuation half (this session) executed T7-IR (Wave Boundary), T7-render (link integrity), T8 (Human review checklist), T10 (plan.md promotion), T11 (PR create + merge).
- **First natural Wave 4 mechanism exercise.** Wave 4 deferred partial validation of the audit-fix-reaudit loop + 6-step blocked recovery path to "Wave 5's first natural Doc Engineer run" (plan.md L267-273 from Wave 4 meta-verification caveat). Wave 5 delivered this: iteration 1 Doc Engineer FAIL on item 7 (README.md ↔ README.zh-CN.md sync rule — Wave 5 added the CONTRIBUTING sync rule and the Chinese pointer in the same Wave without adding the mirror English pointer, a self-defeating PR), Lead fixed via commit 1fec975, fresh iteration 2 Doc Engineer PASS. Loop closed within 2/3 bound. 6-step blocked-recovery path still not triggered (bound not exceeded) and remains permanently deferred per Wave 5 plan's "no manufactured failures" principle.
- **First natural Wave 5 T3 state-machine validation.** Wave 5 introduced F1 IN-PROGRESS state in T3 (67ce9f1). The same Wave's T7-PO Process Observer audit was the first real-world test: PO reported `F1 = IN-PROGRESS` mid-sequence (Wave Boundary IR queued but not yet executed at audit time) instead of the old binary PASS/FAIL shoehorn. New Summary row format `"12 passed, 1 in-progress, 0 warnings, 0 failures"` rendered correctly. Wave 5 self-validated its own T3 change.
- **Language guardian clean on post-merge main.** `bash scripts/language-check.sh` on main post-merge reports `PASSED: scripts/language-check.sh — Tier 1/Tier 2 are CJK-clean and Principle 1 is clean.` Five-Wave i18n cleanup project mechanically verified end-to-end against final disk state.
- **Wave Boundary IR already ran during Wave 5 execution (T7-IR, not in this /end-working).** Verdict PROCEED, 0 CRITICAL, 0 MAJOR, 2 non-blocking MINOR. Report appended to `docs/independent-review.md` as `## Wave 5 Review — 2026-04-08`. Not re-triggered during /end-working since the Wave was already complete-and-merged before /end-working started.
- **Human review checklist delivered to 3 destinations byte-identical.** Target audience: DaDalus (maintainer), who will review 6 i18n-high-risk files (CLAUDE.md, CLAUDE-TEMPLATE.md, docs/roles.md, docs/workflow.md, docs/design-decisions.md, docs/product-spec.md) for semantic nuance (wording-feel / behavioral implications / causal chains) that IR cannot catch mechanically. Checklist is non-blocking and lives in `docs/plan.md` Wave 5 entry "Human review checklist" sub-section for permanent record, plus PR #159 description for discoverability, plus this session briefing for in-conversation recall. Issue format `[i18n-followup] <file>: <section>` + body template documented.
- **Five-Wave i18n cleanup project formally closed.** CHANGELOG `[Unreleased]` section now carries 4 Changed + 3 Added items spanning Wave 1 (convention + guardian + `docs/plan.md` marker) → Wave 2 (Tier 1 Englishization, 166 CJK → 0) → Wave 3 (Tier 2 Englishization, 392 CJK → 0) → Wave 4 (guardian wired into Doc Engineer audit item 9 as blocking gate) → Wave 5 (Tier 3 onramp + carry-over polish). Next: user decides when to run `/release` to cut v0.7.0.
- **Deferred items explicitly outside Wave 5 (user-locked at /start-working):** (1) start-working Step 7 auto-add branch guard (Hotfix #1 carryover) → Wave 6 or independent hotfix PR. (2) end-working plan.md update timing rule clarification (framework-feedback-0407.md) → same. (3) QA-protocol carve-out for trivial CLI scripts (Hotfix #2 PO A6 WARN) → same. (4) Repo structure reorganization (internal docs → `.project/`) → Wave 6 independent project. (5) 2 IR non-blocking framework recommendations (link-integrity check for new Tier 3 files; CRITICAL-at-Wave-Boundary-IR handoff plan for T8-T10 resumption) → future framework polish.

## 2026-04-08 Session (#b) — Post-Wave 5 Follow-up Hotfixes + v0.7.0 Release + v0.7.1 Emergency BSD-sed Hotfix

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Post-Wave 5 (carry-over cleanup, not a new Wave) + v0.7.0 release + v0.7.1 emergency patch |
| Tasks completed | (1) **Post-Wave 5 Follow-up Hotfixes** (PR #161, `feat/post-wave5-followups`) — closed the 3 parked framework-side items from Wave 2/3 that were explicitly scoped out of Wave 5 at user-lock: Hotfix #1 (`commands/start-working.md` Step 7 auto-add branch guard, mirroring Wave 2 rename-branch guard), Hotfix #2 (`CLAUDE.md` + `CLAUDE-TEMPLATE.md` L22 plan.md timing rule rewording with Wave-completion exception), Hotfix #3 (`CLAUDE.md` L83/L95 + `docs/workflow.md` Solo + Agent Team QA paragraphs — Lead-direct QA carve-out for ≤5 deterministic bash commands). 5-command Lead-direct acceptance script (dogfooding Hotfix #3 carve-out): all A1-A5 exit 0. Doc Engineer audit PASS after 1 fix (4 files → 5 files typo caught by PO audit). Process Observer audit 14-check PASS. IR not triggered (not a Wave boundary). (2) **v0.7.0 release** (PR #162, `/release minor`) — first minor bump covering the full 5-Wave i18n cleanup project + the 3 post-Wave-5 follow-up hotfixes. GitHub Release + tag + assets generated via `scripts/release.sh 0.7.0`. (3) **v0.7.1 emergency hotfix** (PR #163, `hotfix/v0.7.1-bsd-sed`) — v0.7.0 `bootstrap.sh:29` + `install.sh:71` GitHub API tag parser used `sed 's/.*"\(v\?\)\([0-9][^"]*\)".*/\2/'` where `\?` is a GNU sed extension NOT supported by macOS BSD sed. On macOS the pattern silently failed to match, returning the raw `  "tag_name": "v0.7.0",` JSON line as the version string, which then tripped the semver validator with `Invalid version format`. Every `~/.isparto/install.sh --upgrade` on macOS would have hit this — v0.7.0 was effectively un-upgradeable on its target platform. Replaced with BSD-compatible `sed -E 's/.*"v?([0-9][^"]*)".*/\1/'` in both files. CHANGELOG `[Unreleased]` entry added in same commit. (4) **v0.7.1 release** (PR #164, `/release patch`) — `scripts/release.sh 0.7.1` → VERSION 0.7.0 → 0.7.1 → CHANGELOG promoted → PR → merge → GitHub Release. (5) **End-to-end upgrade verification** — `~/.isparto/install.sh --upgrade` ran against v0.7.1: 0.6.19 → 0.7.1 successful, `~/.isparto/VERSION` = 0.7.1. Idempotent re-run returned `Already up to date (v0.7.1)` cleanly. Both paths verified on the same macOS host that originally surfaced the bug. |
| Key decisions | (1) **Mode: Solo + Lead direct edit for both sub-sessions.** Post-Wave 5 hotfix session: 5 files, all framework self-referential, no Developer/Codex calls (Wave 5 precedent). v0.7.1 emergency hotfix: 3 files (`bootstrap.sh`, `install.sh`, `CHANGELOG.md`), all framework self-referential. Both sub-sessions declared Solo explicitly at mode-selection checkpoint. (2) **Dogfooded Hotfix #3 carve-out immediately in its own acceptance script.** The 5-command Lead-direct acceptance script for the very hotfix that introduced the carve-out used the carve-out to execute. The hotfix validates itself. Doc Engineer and Process Observer audits were independent sub-agents with fresh context, so the circularity risk flagged in the plan was caught mechanically (and didn't trigger — both audits passed). (3) **IR not triggered for either sub-session.** Post-Wave 5 follow-ups = not a Wave boundary (plan.md entry explicitly justifies this, precedent: Wave 2 Inter-Wave Hotfix #1 and #2 also did not trigger IR). v0.7.1 emergency hotfix = same reasoning + the bug was operationally trivial to verify end-to-end (one failing upgrade, one passing upgrade). (4) **Option A (proper hotfix release) chosen over Option B (local bypass).** When the v0.7.0 upgrade failure surfaced, the decision was between hotfix-release (fixes the bug for all macOS users, v0.7.0 stays broken in release history, +1 version cut) vs local workaround (only fixes the invoking user's install, v0.7.0 remains un-upgradeable for every other macOS user who runs `--upgrade`). Option A was the only correct answer since v0.7.0 was <1h old (clean hotfix window) and the bug had 100% reproduction rate on every macOS user. Option B was considered and explicitly rejected. (5) **v0.7.0 broken-release window.** v0.7.0 and v0.7.1 were cut within the same session with ~30 min between them. The v0.7.0 release remains in git history (tag v0.7.0 exists, GitHub Release exists) but is documented as broken-on-macOS in v0.7.1's CHANGELOG `[Unreleased]` → `[Fixed]` entry. Not yanking v0.7.0 (no mechanism + would rewrite tag history); instead the next-available version (v0.7.1) supersedes it and the upgrade path self-heals on the next `--upgrade` attempt. (6) **Pre-release gate gap surfaced.** `scripts/language-check.sh` catches language violations but there is no equivalent `scripts/macos-compat-check.sh` or macOS-sed lint that would have caught the `\?` GNU extension pre-release. BSD-GNU `sed` divergence is a well-known class of bug and could be mechanically detected (shellcheck flags some of these; a custom grep for `sed.*\\\?` over *.sh would have caught this specific case). Noted as a potential future framework improvement; not filed as a blocking item today. |

### Files Changed
```
(HEAD on main, clean. All session (b) work is already merged via PR #161, #162, #163, #164.
 Only remaining uncommitted change is this session-log.md append on the docs/session-log-0408-b
 branch created by /end-working step 7.)
```

### Notes

- **Session split across a context-compaction boundary (again).** This session (#b) started when context compacted mid-way through the upgrade verification step of the v0.7.1 flow. The first half executed plan approval → 3 hotfixes → acceptance → Doc Engineer → Process Observer → PR #161 merge → v0.7.0 release → discovery of BSD-sed bug → diagnosis. The continuation half (this writeup) executed: v0.7.1 hotfix edits → PR #163 + merge → v0.7.1 release → upgrade verify → idempotent re-run verify → /end-working.
- **Post-Wave 5 plan.md entry is the canonical record for the 3 follow-up hotfixes** — see `docs/plan.md` "Post-Wave 5 Follow-up Hotfixes (2026-04-08) — Complete" section, including the A1-A5 acceptance table, file list, IR-skip justification, and self-referential-edit mode rationale. The entry was written in the same commit as the hotfixes themselves per the freshly-reworded L22 rule that Hotfix #2 introduced (rule validates itself on first use).
- **v0.7.1 hotfix is NOT in plan.md** — by design. plan.md is not the release-notes system; CHANGELOG.md is the single source of truth for release-level facts. A plan.md cross-reference for every post-release hotfix would be noise. The BSD-sed fix is fully documented in CHANGELOG `[0.7.1] - 2026-04-08` "Fixed" section + PR #163 commit message.
- **BSD sed `\?` vs GNU `\?` primer (for future-me context).** In GNU sed basic regex mode, `\?` means "previous atom is optional" (equivalent to `?` in extended mode). In BSD sed (macOS default), `\?` is not recognized as a metachar — the backslash escapes literal `?`, which then does not appear in the input, so the pattern fails to match. The fix is either (a) switch to `-E` extended regex mode and use `?` directly, or (b) use `\{0,1\}` which is POSIX-BRE and works on both. We chose (a) because `-E` is also POSIX and the extended form is more readable. Pattern `sed -E 's/.*"v?([0-9][^"]*)".*/\1/'` is now the canonical form used in both `bootstrap.sh:29` and `install.sh:71`.
- **End-to-end verification chain**: (a) Verified new regex with 3 hand-crafted tag shapes via `echo | sed` before commit. (b) `scripts/language-check.sh` clean post-edit (no Tier 1/Tier 2 regressions). (c) PR #163 pre-commit hook clean. (d) `/release patch` ran to completion without intervention. (e) `gh release view v0.7.1` shows correct assets. (f) `~/.isparto/install.sh --upgrade` went from `Invalid version format` error (on v0.7.0 pre-fix) to clean `Upgrading 0.6.19 → 0.7.1` (post-fix), and subsequent idempotent re-run returned `Already up to date (v0.7.1)`. The verification is end-to-end not just unit because the fix runs through the real GitHub API + real BSD sed on a real macOS host + real installed `~/.isparto/install.sh` delegating to a real freshly-downloaded `bootstrap.sh`.
- **Next-session to-dos:** nothing blocking. Optional: (a) add `scripts/macos-compat-check.sh` or similar mechanical guard for BSD-sed-incompatible regex in shell files — small investment, prevents recurrence of this class of bug. (b) The 2 long-standing items remain in plan.md "下一步": P1 repo structure reorganization (`.project/` internal-docs move) and the "本地 hook 更新" reminder. (c) 5 technical-ecosystem tracking items in the "技术生态追踪" table remain passive (trigger-driven, no action today).

## 2026-04-08 Session (#c) — Framework Polish Round 2 + v0.7.2 Patch Release

| Metric | Value |
|--------|-------|
| Project | iSparto |
| Wave | Framework Polish Round 2 (standalone cleanup, not a Wave) + v0.7.2 patch release |
| Tasks completed | (1) **Framework Polish Round 2** (PR #166, `feat/framework-polish-round-2`) — closed ALL 11 remaining framework-side items accumulated across 6 `docs/framework-feedback-*.md` files (0403/0405/0406/0407/0408-a/0408-b), bundled into 5 logical commits + 1 plan.md entry commit: `8733a97` self-referential boundary covers Tier 1 root-level files; `ccf04a4` emergency hotfix + ad-hoc fix Doc Engineer exceptions (+ workflow.md hotfix DE ref added); `8f3ae74` plan.md update cadence + mechanical verification-count accuracy (+ templates/plan-template.md + CLAUDE-TEMPLATE.md mirror); `b35b9ac` plan.md reclassified as wholly Tier 4 (forward-looking sections exempt); `c9bba79` F1 Independent Reviewer dual-spawn-path + PR body template extended with `## Mode Selection` and `## Workflow audits` sub-agent-run-vs-self-assessed distinction; `c5664ef` plan.md Framework Polish Round 2 completion entry. User request (direct quote): "能把现在代办的todo一次性全部搞完吗?...我想把这个赶紧搞完,搞新的需求了。感觉这个小问题特别特别多,一直在修修来修去". Acceptance: 3 trivial-CLI commands under the Solo step 3 carve-out (`language-check.sh` exit 0, `--self-test` exit 0, `git log --oneline --no-merges main..HEAD \| wc -l` = 6 mechanical computation — dogfooded the verification-count rule introduced in commit `8f3ae74` on first use). Doc Engineer PASS WITH MINOR (2 non-blocking template-symmetry observations outside the 11-item scope, DE explicitly cleared push/merge). Process Observer 11 PASS / 0 WARN / 0 FAIL / 3 N/A (including F1 N/A — no Wave completed, B1 Mode Selection declared, C3 DE audit confirmed before merge). IR not triggered — not a Wave boundary (precedent: Post-Wave 5 hotfix series, Wave 2 Inter-Wave Hotfix #1/#2). (2) **v0.7.2 patch release** — user asked "要发小版本吗?" after PR #166 merged. Lead's recommendation: YES, because 4 of the 7 modified files (`CLAUDE-TEMPLATE.md`, `templates/plan-template.md`, `commands/end-working.md`, `agents/process-observer-audit.md`) propagate to user projects via `/init-project` and `~/.isparto/install.sh --upgrade`, and without a release those users would never see the new rules. CHANGELOG prep was required because `[Unreleased]` was empty after v0.7.1: prepped via `docs/changelog-0408-c` branch (PR #167) — 5 entries under "Changed" mapping 1:1 to the 5 rule-correction commits, Lead self-assessed as ad-hoc fix skip path (single Tier 4 file, pure CHANGELOG prep, no code↔doc sync risk). Then `bash scripts/release.sh 0.7.2` executed end-to-end without intervention: VERSION 0.7.1 → 0.7.2, CHANGELOG [Unreleased] → [0.7.2] - 2026-04-08, release/v0.7.2 branch + PR #168 + merge + `gh release create --target main` + branch cleanup. GitHub Release URL: https://github.com/BinaryHB0916/iSparto/releases/tag/v0.7.2 . Tag `v0.7.2` confirmed via `git fetch --tags && git tag -l v0.7.2`. |
| Key decisions | (1) **Mode: Solo + Lead direct edit for all sub-flows.** Framework Polish Round 2 + CHANGELOG prep both declared Solo at their Mode Selection Checkpoint, citing self-referential boundary and Post-Wave 5 Follow-up Hotfixes precedent. 7 files for Round 2 (all Tier 1 behavioral or Tier 4 plan.md), 1 file for CHANGELOG prep (Tier 4). No Developer/Codex calls in either sub-flow. `scripts/release.sh 0.7.2` is self-contained per `/release` spec — no Mode Selection applies to it. (2) **Bundle all 11 items into one PR rather than continue incremental hotfixes.** User explicitly expressed fatigue with the "修来修去" pattern ("感觉这个小问题特别特别多,一直在修修来修去"). Lead enumerated all 11 items from the 6 feedback files, deduplicated against prior hotfixes, presented 2 decision points (plan.md cadence: relax vs keep strict; forward-looking Tier 4: uniform Tier 4 vs split treatment). User confirmed "确认 A + A 搞吧" — both Option A. Resulting commit structure: 5 rule-correction commits (≤3 files each) + 1 plan.md completion entry commit. This is the OPPOSITE of the fragmented-release pattern the user was tired of: single clean bundle → single patch release → clean slate for new requirements. (3) **Dogfooded 3 rules introduced in this same session.** (a) Commit `8f3ae74` introduced the mechanical verification-count rule; the plan.md entry written in `c5664ef` immediately used `git log --oneline --no-merges main..HEAD | wc -l = 6` at write time instead of estimating — rule validates itself on first use. (b) Commit `c9bba79` introduced the new PR body template with `## Mode Selection` and `## Workflow audits` fields; PR #166 (created minutes later in the same session) immediately used the new format, as did PR #167. PR #168 is release.sh-generated boilerplate — accepted exception. (c) Commit `c9bba79` also clarified F1 IR dual-spawn-path wording; this `/end-working` session's Process Observer audit cited the new wording verbatim when reporting F1 = N/A. (4) **IR not triggered for either sub-flow.** Framework Polish Round 2 is a standalone cleanup round collapsing pre-existing feedback items, not a Wave (no Wave boundary crossed). v0.7.2 release is a patch bump with no new Wave content. Precedent chain: Wave 2 Inter-Wave Hotfix #1+#2, Post-Wave 5 Follow-up Hotfixes (Session #b, 2026-04-08), all followed the same non-trigger rationale. Explicitly documented in both the plan.md completion entry and PR #166 body. (5) **v0.7.2 as bundled patch, not semver-minor.** 5 rule corrections + CHANGELOG entries → patch bump (X.Y.Z+1) is the correct semver classification: no breaking changes, no new features, only rule clarifications and behavioral refinements. User-project impact: existing projects pulling via `install.sh --upgrade` will get the 4 user-propagating files (CLAUDE-TEMPLATE.md, templates/plan-template.md, commands/end-working.md, agents/process-observer-audit.md), which is exactly the intended delivery mechanism. (6) **Doc Engineer PASS WITH MINOR observations were NOT fixed in this round.** The 2 observations were cosmetic template-symmetry suggestions outside the 11-item scope (DE explicitly said "safe to push and merge as-is"). User fatigue + out-of-scope + DE clearance = deliberate non-fix decision, noted for future sessions. |

### Files Changed
```
 CHANGELOG.md                     | 10 ++++++++++
 CLAUDE-TEMPLATE.md               |  7 ++++---
 CLAUDE.md                        | 11 ++++++-----
 VERSION                          |  2 +-
 agents/process-observer-audit.md |  2 +-
 commands/end-working.md          | 19 ++++++++++++++++++-
 docs/plan.md                     | 35 +++++++++++++++++++++++++++++++++++
 docs/workflow.md                 |  3 +++
 templates/plan-template.md       |  4 ++++
 9 files changed, 82 insertions(+), 11 deletions(-)
```
(Computed via `git diff d9ade4e..HEAD --stat`, where `d9ade4e` is the last merge before this session. `git diff HEAD --stat` at /end-working time returns empty because everything is already merged via PR #166, #167, #168.)

### Notes

- **Session arc crossed a context-compaction boundary.** The session started with `/start-working` → Framework Polish Round 2 task breakdown → 5 rule-correction commits + 1 plan.md entry + PR #166 merge — all before compaction. After resume: verified state, created and merged PR #166, discussed v0.7.2 release decision with user, prepped CHANGELOG via PR #167, ran `scripts/release.sh 0.7.2` (→ PR #168 + tag + GitHub Release), and executed this `/end-working` flow. The compaction did not break any state — post-resume verification showed the branch was already pushed with all 6 commits intact, audits clean, ready for PR creation.
- **Three PRs merged in a single 6-minute window at the end of the session.** PR #166 (03:36:41Z), PR #167 (03:42:20Z), PR #168 (03:42:43Z). Total: 3 merges, 0 rebase conflicts, 0 retry loops. `scripts/release.sh`'s built-in `gh pr merge` retry-once-on-failure logic did not trigger — main was quiescent during the release window.
- **Precedent chain for "not a Wave, so no IR" grows longer.** Sessions that used this reasoning: Wave 2 Inter-Wave Hotfix #1 (context overflow recovery), Wave 2 Inter-Wave Hotfix #2 (Principle 1 detector), Post-Wave 5 Follow-up Hotfixes (Session #b), and now Framework Polish Round 2 (Session #c). The pattern is stable: framework-self-referential rule corrections that don't introduce new product behavior → Doc Engineer + Process Observer are sufficient, IR is overkill. No risk of rule drift detected.
- **Framework-feedback file disposition post-Round-2.** All 6 `docs/framework-feedback-*.md` files remain on disk as Tier 4 historical artifacts (frozen per Documentation Language Convention). Their contents are now reflected in the corresponding Tier 1/2 rule sources. No feedback file deleted — they serve as the audit trail. This session did NOT generate a new framework-feedback file because the Process Observer audit returned 11/0/0/0 (no new gaps detected) — the "closing round" worked as intended.
- **Dogfooding quality check.** 3 rules introduced this session were each validated by immediate first-use within the same session: (a) mechanical verification-count rule → used in plan.md entry; (b) new PR body template → used in PR #166 and #167; (c) F1 dual-spawn-path wording → cited by this end-of-session PO audit. This is the strongest form of rule validation available (immediate self-application) and it caught zero defects in the new rule wording. If any of the 3 rules had been incorrectly specified, the dogfooding would have surfaced the defect immediately rather than parking it as a new framework-feedback item for a future session to fix.
- **Next-session to-dos:** nothing blocking from this session. The 2 long-standing items remain in plan.md "下一步" (P1 repo structure reorganization `.project/` move, local hook upgrade reminder) + 5 technical-ecosystem tracking items in "技术生态追踪" (all passive, trigger-driven). The optional `scripts/macos-compat-check.sh` idea from Session (#b) also remains optional (not promoted to blocking). User stated outgoing intent: 出去吃午饭 + 搞新需求. Next session likely picks up one of the P1 items or introduces new requirements.
