# iSparto 开发计划

## 已完成

### Wave 0: 核心框架
- [x] 7 个 slash commands (start-working, end-working, plan, init-project, migrate, env-nogo, restore)
- [x] 4 个文档模板 (product-spec, tech-spec, design-spec, plan)
- [x] CLAUDE-TEMPLATE.md 项目模板
- [x] settings.json 参考配置
- [x] 角色定义 + Codex prompt 模板 (docs/roles.md)
- [x] 完整开发流程文档 (docs/workflow.md)
- [x] 核心概念文档 (docs/concepts.md)
- [x] 配置指南 (docs/configuration.md)
- [x] 用户交互手册 (docs/user-guide.md)
- [x] 问题排查 (docs/troubleshooting.md)
- [x] 设计决策记录 (docs/design-decisions.md)

### Wave 1: 安装体系
- [x] install.sh 一键安装（curl | bash）
- [x] --dry-run 预览模式
- [x] --uninstall 卸载 + 旧文件备份恢复
- [x] Codex MCP Server 全局注册
- [x] 双语 README (EN + ZH-CN)
- [x] SVG header banner + 角色架构图

### Wave 2: 快照/恢复系统
- [x] lib/snapshot.sh 快照引擎 (create/restore/list/info/prune)
- [x] /restore 命令
- [x] install.sh 集成快照（安装前自动拍快照）
- [x] migrate.md 集成快照（迁移前自动拍快照）
- [x] init-project.md 集成快照（初始化前自动拍快照）
- [x] 向后兼容旧 manifest 备份

### Wave 3: 商业化基础
- [x] 买域名 isparto.dev
- [x] Landing page (isparto-website repo)
- [x] Waitlist 邮箱收集 (Google Sheets + Apps Script)
- [x] Vercel 自动部署
- [x] 域名绑定 + SSL

### Wave 4: 自举迁移
- [x] iSparto 项目自身迁移到 iSparto 工作流 (CLAUDE.md, settings.json, product-spec, plan.md)

### Wave 5: Dogfooding 验证
- [x] 场景 1: isparto-website 项目 — /migrate 已完成
- [x] 场景 2: 萌芽勇气 (iOS app) — /migrate 已完成
- [x] 场景 3: 内部项目 A（勇芽 iOS）— /init-project 已完成（用户自行操作）
- [x] 场景 4: 内部项目 B（meic）— /init-project 已完成（用户自行操作）
- [x] Session Log 自动采集 — /end-working 自动生成 session report，/start-working 自动读取历史
- [x] 每个场景记录：Wave 数量、并行效率、Codex 拦截问题、截图（由 session-log.md 自动采集替代）

### Wave 6: 安全审计系统
- [x] security-patterns.json — 统一安全规则库（14 secret + 4 PII + 敏感文件 + gitignore 基线 + realtime_critical 子集）
- [x] security-patterns.json 全栈覆盖扩展 — 7 类 ~50+ sensitive_files pattern（构建产物/基础设施/调试/IDE/发布/备份）+ gitignore 基线同步 + inline-sourcemap/terraform-secret 2 个 secrets pattern
- [x] pre-commit-security.sh — commit 前全量扫描（从 JSON 读取 patterns，支持 .secureignore 白名单）
- [x] pre-tool-check.sh L1 扩展 — Write/Edit 实时内容安全扫描（5 个 critical patterns）
- [x] /security-audit 命令 — 里程碑全量审计（代码 + .gitignore + git 历史 + 依赖）
- [x] /end-working 集成 — commit 前安全扫描步骤
- [x] /end-working 分支守卫 — commit 前检查是否在 main，是则先创建 docs/ 分支（修复 session log 提交撞 hook 的流程缺陷）
- [x] 分支前缀规范化 — docs/ 和 release/ 正式加入 CLAUDE.md 和 Process Observer 审计 checklist
- [x] /init-project + /migrate 集成 — 安全基线初始化 / 检查
- [x] Codex QA + Developer prompt + Doc Engineer 审计清单增加安全检查
- [x] gitignore-security-baseline.md 模板
- [x] docs/security.md + process-observer.md 更新
- [x] install.sh 注册新文件
- [x] README 双语更新 + design-decisions.md 架构决策记录

## 当前阶段

### v0.6.13 — 已完成（2026-04-03）
- [x] Branch Protocol 入口防御（分支检查前置到 Step 0）
- [x] 3 条审计规则修正（Doc Engineer 时序、plan.md 同 commit、Tier 2a 区分）
- [x] 审计回流机制（User-side / Framework-side 分类 + framework-feedback 文件生成）
- [x] 用户产出去内部化（session-log 删内部指标、审计报告分层、CLAUDE-TEMPLATE.md 死链修复）

### QA 验证层级修复 — 已完成

- [x] templates/plan-template.md — acceptance script 格式升级 + Completion Criteria 三层拆分
- [x] docs/roles.md — QA prompt 加构建前置 + [code]/[build]/[runtime] 分级验证 + evidence 要求
- [x] commands/plan.md — acceptance script 指导含 [build]/[runtime] 要求
- [x] CLAUDE.md — Solo + Agent Team workflow step 3 强化
- [x] CLAUDE-TEMPLATE.md — 英文版同步
- [x] docs/workflow.md — Solo + Agent Team QA 描述强化，"Simulates" → "Runs the app and verifies"

### Independent Reviewer 角色 — 已完成
- [x] agents/independent-reviewer.md — 新建完整审查流程 + 输出格式 + CRITICAL 恢复协议
- [x] docs/roles.md — 新增 Independent Reviewer 角色定义（Teammate，非 sub-agent）
- [x] CLAUDE.md — Roles 加 IR + workflow 加 step 3.5 + Module Boundaries 更新
- [x] CLAUDE-TEMPLATE.md — 英文版同步
- [x] commands/init-project.md — Phase 0 加 Independent Review（Step 11）
- [x] commands/plan.md — Wave 条件触发（Step 4b）
- [x] docs/workflow.md — Phase 0 + Solo/Agent Team 流程加 IR 步骤
- [x] docs/design-decisions.md — 4 条决策记录

### MCP Server 重命名 — 已完成
- [x] codex-reviewer → codex-dev：14 个文件全量替换（工具调用名 + MCP 注册名）
- [x] install.sh 旧用户迁移逻辑（检测旧名 → remove → add 新名）
- [x] /start-working 项目级 hook matcher 自动迁移
- [x] design-decisions.md 标记为已解决

### CLAUDE-TEMPLATE 同步审计 — 已完成
- [x] Doc Engineer 审计清单新增 CLAUDE.md ↔ CLAUDE-TEMPLATE.md 内容一致性检查（替代 section 注入方案，复杂度更低）

### Hook 性能修复 + 清理 — 已完成
- [x] pre-tool-check.sh: .env 检测从 find 遍历改为 git ls-files 索引查询
- [x] docs/independent-review.md placeholder 创建
- [x] settings.json → settings.example.json 重命名 + 引用更新

### install.sh Python 提取 + 文档修正 — 已完成
- [x] lib/patch-settings.py：从 install.sh 提取 ~150 行内联 Python，合并为独立脚本（patch-user / clean-project）
- [x] end-working.md：修正 "can run in parallel" 误导措辞
- [x] design-decisions.md：标注 extract_json_field JSON 解析限制

### 多模型 Developer 策略 — 已完成
- [x] docs/configuration.md 模型映射表扩展（双档 Developer + Independent Reviewer + 选型理由列）
- [x] docs/configuration.md 新增 "Developer 分档模型策略" section
- [x] docs/workflow.md Tier section 追加模型选择备注
- [x] docs/design-decisions.md 追加 2 条决策（双档模型 + 保持 5.3-codex）
- [x] CLAUDE.md + CLAUDE-TEMPLATE.md Developer 角色描述更新
- [x] MCP server 模型参数验证：gpt-5.4-mini ✅ / gpt-5.3-codex-spark ❌（ChatGPT Plus 不支持）
- [x] docs/plan.md 新增 "技术生态追踪" 表格（6 项）

### gh 账号自动对齐 — 已完成
- [x] commands/start-working.md 新增 Step 6（gh 账号对齐），原 6-8 顺推为 7-9
- [x] commands/end-working.md 新增 Step 7（PR 创建前兜底），原 7 顺推为 8
- [x] docs/design-decisions.md 追加 1 条决策
- [x] 检测逻辑：git remote 提取 owner → gh api /user 比对 → 不匹配自动 switch

### /release 命令 + 发版流程制度化 — 已完成
- [x] commands/release.md — 新增发版 slash command（4 步逐步指令）
- [x] scripts/release.sh — 移除本地 tag push，改用 gh release create --target main
- [x] CLAUDE.md — 发版规则 + hotfix 后发版引导 + 自引用边界扩展（覆盖所有框架文件）
- [x] docs/design-decisions.md — 3 条决策（/release command、release.sh tag 改造、自引用边界扩展）

### i18n Cleanup — Wave 1 (2026-04-07) — Complete

Goal: Establish the four-tier language convention and ship the guardian script. No Englishization of existing files in this Wave by design — Wave 2 handles Tier 1, Wave 3 handles Tier 2.

- [x] `CLAUDE.md` — added "Documentation Language Convention" section (zero CJK literals in the section). Documents the four-tier architecture (Tier 1 System Prompt, Tier 2 Reference Docs, Tier 3 User-Facing Entry, Tier 4 Historical), the hard-coded user-facing strings rule (Principle 1), and the illustrative-example rule
- [x] `scripts/language-check.sh` — created in warning mode (manual invocation only). Scans Tier 1 (CLAUDE.md, CLAUDE-TEMPLATE.md, commands/*.md, agents/*.md, templates/*.md, hooks/**/*.{sh,json}, bootstrap.sh, install.sh, isparto.sh, scripts/*.sh, lib/*.sh) and Tier 2 (docs/*.md). Tier 2 explicit exclusions: `docs/session-log.md`, `docs/plan.md`, `docs/framework-feedback-*.md`, `docs/zh/`. CJK regex covers basic CJK + punctuation + fullwidth + Extension A. Promoted to a blocking gate inside `/end-working` Doc Engineer audit in Wave 4
- [x] `docs/plan.md` — added BLOCKING marker for the Wave 1 → Wave 2 cross-session boundary (per R1 mitigation; auto-detection wired in Wave 2 Dev B Sub-task B-bonus)

Baseline (recorded by `bash scripts/language-check.sh` after Wave 1):
- Tier 1 violations: 166 lines (target after Wave 2: 0)
- Tier 2 violations: 391 lines (target after Wave 3: 0)

Cross-session boundary required before Wave 2 (per Cross-Session Barrier Protocol — Wave 1 changed CLAUDE.md, the new section needs to ride the next session's system-reminder injection).

### i18n Cleanup — Wave 2 (2026-04-07) — Complete

Goal: Englishize all Tier 1 (System Prompt Layer) files. Target: `bash scripts/language-check.sh | grep -c '^\[Tier 1\]'` returns `0`. Tier 2 violations remain (Wave 3 scope).

Mode: Agent Team (4 parallel Devs A/B/C/D), per the approved plan at `~/.claude/plans/immutable-zooming-codd.md` (full execution plan + 5 user-mandated patches).

- [x] Dev A — `CLAUDE.md` (~120 CJK lines) and `CLAUDE-TEMPLATE.md` (14 CJK lines) translated; Wave 1 "Documentation Language Convention" section preserved byte-identical
- [x] Dev B — all 9 `commands/*.md` translated (env-nogo, restore, security-audit, migrate, init-project, release, plan, start-working, end-working). Sub-task B-bonus1: added new Step 0 "Session boundary check" to `commands/start-working.md` (BLOCKING marker auto-detection wires the cross-session boundary). `commands/end-working.md` Step 3 (Wave Boundary Review) verified for 4 equivalence properties (trigger, fixed-prompt spawn, CRITICAL → next-session path, PROCEED → briefing path)
- [x] Dev C — `agents/process-observer-audit.md` (1 CJK line) translated using Principle 1 intent-description pattern; `templates/gitignore-security-baseline.md` (13 CJK lines) translated; `agents/independent-reviewer.md` and 4 spec templates verified clean (no edits)
- [x] Dev D — `hooks/process-observer/scripts/pre-tool-check.sh` (9 CJK lines) and `hooks/process-observer/rules/workflow-rules.json` (3 CJK lines) translated; full hook smoke test executed (7 paths exercised: 3 case-block branches + direct-code-write + codex-unstructured-prompt + 2 allow paths) — all hooks still block correctly with English error messages, emoji and ANSI codes preserved in `pre-commit-security.sh`
- [x] Lead post-IR Principle 1 fixes — IR caught 3 residual violations (1 MAJOR, 2 MINOR) the mechanical CJK guardian could not detect: `commands/env-nogo.md` lines 23-24, `commands/end-working.md` lines 22-23, `agents/process-observer-audit.md` line 23. All 3 converted to Principle 1 intent-description pattern.
- [x] Independent Reviewer (Wave Boundary Review) spawned with fixed prompt; report appended to `docs/independent-review.md`. Verdict PROCEED, no CRITICAL findings.
- [x] Doc Engineer audit: PASS, 0 CRITICAL / 0 MAJOR / 1 MINOR (`docs/roles.md` line 337 stale reference to CLAUDE.md "(Chinese)" — Wave 3 cleanup scope) / 4 INFO
- [x] Process Observer audit (Sonnet): 8 PASS / 0 WARN / 0 FAIL. F1 (Independent Review at Wave boundary) PASS verified.

Verification (after Wave 2):
- Tier 1 violations: 0 (target met)
- Tier 2 violations: 392 (Wave 3 scope, unchanged) — note: an earlier draft of this plan recorded the Tier 2 baseline as 391; the actual count from `bash scripts/language-check.sh` against the post-Wave-2 main is 392. Updated here for accuracy.

Deferred items (NOT in Wave 2 scope, tracked separately):
- (All three items previously tracked here — `end-working.md` plan.md timing rule clarification, `start-working.md` Step 7 auto-add branch guard, and QA-protocol carve-out for trivial CLI scripts — were resolved in the Post-Wave 5 Follow-up Hotfixes entry at the bottom of this file on 2026-04-08.)

Cross-session boundary required before Wave 3 (per Cross-Session Barrier Protocol — Wave 2 fully Englishized CLAUDE.md, the new content must ride the next session's system-reminder injection).

### Inter-Wave Hotfix #1 — fix/mcp-rename-migration-guard (2026-04-07) — Complete

Branch: `fix/mcp-rename-migration-guard`. Mode: Solo (single-file edit to a behavioral template, self-referential boundary).

Goal: Prevent `commands/start-working.md` Step 7 from silently disabling Process Observer hook interception on stale installs by gating the legacy-matcher rename behind a presence check for the new MCP server.

- [x] `commands/start-working.md` Step 7 — added a "Migration guard (mandatory before renaming)" sub-bullet that runs `claude mcp list -s user 2>/dev/null | grep -q codex-dev` before the rename. Pass branch performs the rename and informs the user (intent-described per Principle 1, with `(in user's language)` qualifier). Fail branch (stale install — `codex-dev` MCP server is not registered) leaves the legacy matcher in place, informs the user that the migration was skipped to preserve interception, instructs them to run `~/.isparto/install.sh --upgrade` and re-run `/start-working`, then explicitly skips the next bullet (the auto-add branch) to avoid re-introducing the same silent-disable bug, and proceeds directly to Step 8.
- [x] Codex review (gpt-5.3-codex, xhigh) — verdict APPROVE WITH MINOR. Two MINOR findings: (1) "skip remaining sub-steps of Step 7" was ambiguous → tightened to explicitly name the auto-add branch and direct the Lead to Step 8; (2) auto-add branch follow-up guard → tracked in Deferred items above, not blocking this hotfix.
- [x] Tier 1 language check (`bash scripts/language-check.sh`) — Tier 1 still 0, Tier 2 still 392, no regression introduced by the diff.

Why Solo: single file, single behavioral-template change, no decomposable parallel sub-tasks. Why direct edit (not via Developer): self-referential boundary — `commands/*.md` is an iSparto framework file (Tier 1 system prompt), Lead edits directly per CLAUDE.md > Development Rules.

Scope intentionally narrow: rename branch only. Auto-add branch follow-up is a separate, smaller hotfix tracked above.

### Inter-Wave Hotfix #2 — feat/principle1-guardian-extension (2026-04-07) — Complete

Branch: `feat/principle1-guardian-extension`. Mode: Solo (single-file Python/bash extension to a script, implementation delegated to Developer per the implementation protocol; Lead reviewed).

Goal: Extend `scripts/language-check.sh` with a mechanical first-line guard for **Principle 1** (the "Hard-coded user-facing strings rule" from CLAUDE.md > "Documentation Language Convention"). Wave 2's Independent Reviewer caught 3 residual Principle 1 violations that the CJK-only guardian could not detect; this hotfix gives the guardian an orthogonal check so the most obvious violations are caught mechanically before reaching IR.

- [x] `scripts/language-check.sh` — Developer-implemented Principle 1 detector. Detection scope: `commands/*.md` + `agents/*.md` only (the layer where Lead generates user-facing output at runtime). Detector logic: a line is flagged if (1) it contains a user-output verb from `{inform, tell, ask, instruct, warn, report, notify, announce, output, display, print, echo, note, show}`, AND (2) it contains a sentence-like quoted literal (capital-start, ≥12 chars), AND (3) the line does NOT contain the `(in user's language)` qualifier, AND (4) the literal is not exempted by an `e.g.` / `for example` / etc. illustrative-example marker in the 40 chars before the opening quote, AND (5) the literal is not inside a `[...]` placeholder.
- [x] `--self-test` mode — added a CLI flag that runs synthetic fixtures without scanning real files. Test 1 (sanity negative): the CLAUDE.md line 40 illustrative example must NOT be flagged (it has both the qualifier and the `e.g.` exemption). Test 4: 5 hardcoded fixture violation strings (synthetic, not pulled from git history) must all be flagged. Both pass on the implemented detector. (Test numbers 1 and 4 are placeholders in a larger test taxonomy — Tests 2 and 3 are reserved for future phases of the guardian, not shipped with this hotfix.)
- [x] Default-mode integration — Principle 1 scan added to `main()` alongside the existing CJK Tier 1 / Tier 2 scans. Output adds `[Principle 1] <relpath>:<lineno>: <snippet>` lines and breaks the summary into three categories: `N1 Tier 1 CJK, N2 Tier 2 CJK, N3 Principle 1`. Exit codes preserved: 0 clean / 1 violations / 2 environment error (now also covers the unknown-arg path).
- [x] Top-of-file comment block updated to document the Principle 1 scope, the rationale, and the `--self-test` flag.
- [x] Acceptance verified by the Lead:
  - `bash scripts/language-check.sh --self-test` → both PASS lines, exit 0
  - `bash scripts/language-check.sh` → reports `0 Tier 1 CJK, 392 Tier 2 CJK, 0 Principle 1`, exit 1 (the 392 is the unchanged Wave 3 backlog)
  - `bash scripts/language-check.sh --bogus-arg` → exit 2
  - Manual sanity check: the detector does NOT false-positive on the trickiest real-world lines in the current `commands/` + `agents/` (line 65 of `start-working.md`'s `Announce ... e.g., "Single-module fix..."`, the standalone fixed-prompt lines in `init-project.md` / `end-working.md` / `commands/plan.md`, the bracketed placeholder in `security-audit.md:52`, and `agents/independent-reviewer.md:9`).
- [x] Codex review (gpt-5.3-codex, xhigh) — verdict APPROVE WITH MINOR. Findings (none blocking):
  - **Spec drift (MINOR):** the bracket exemption counts `[`/`]` over the entire pre-quote prefix instead of only the 40-char tail. This is strictly more conservative (catches `[...]` placeholders even when far from the literal), accepted as-is.
  - **False-positive corner case (MINOR):** a line like `Show the user how to do X — "All conflicts resolved."` (24-char literal) on a `show` line would trigger. No such line exists in the current repo; would be addressed by adding more specific verb-object disambiguation.
  - **False-negative gaps (MINOR):** unquoted literals are invisible; verbs not in the list (`say`, `state`, `explain`, `convey`, `prompt`, `respond`) are missed; multi-line verb-then-quote patterns are missed. Documented as known detector limitations — this is a Wave 1 first-line guard, not a complete IR replacement.
  - **Output format change (MINOR):** the summary line now reports three categories (was one). No downstream parsers exist (Wave 1 status, manual invocation), so accepted.

Why Solo + Developer: single file, ~150 lines of Python/bash. Implementation delegated to `mcp__codex-dev__codex` (gpt-5.3-codex, xhigh) per the Implementation Protocol — `scripts/*.sh` is a real script, not a behavioral template, so Developer is the right authoring path despite the self-referential boundary allowing direct edits. Lead assembled the structured prompt, reviewed the implementation, ran the three acceptance commands, then ran a separate Codex review pass.

Follow-up improvements (tracked, not blocking):
- Extend the verb list to cover `say`, `state`, `explain`, `convey`, `prompt`, `respond`, `reply`.
- Add detection for unquoted literals (likely requires natural-language heuristics, lower mechanical confidence).
- Tighten the bracket-exemption window if false negatives appear (currently full prefix, intentionally conservative).
- Wire `bash scripts/language-check.sh` (without `--self-test`) into the `/end-working` Doc Engineer audit step in Wave 4 as a blocking gate, per the existing Wave 4 plan.

### i18n Cleanup — Wave 3 (2026-04-07) — Complete

Goal: Englishize all Tier 2 (Reference Documentation) `docs/*.md` files. Target: `bash scripts/language-check.sh` reports `0 Tier 1 CJK, 0 Tier 2 CJK, 0 Principle 1` (whole-repo guardian clean for the first time).

Mode: Agent Team (4 parallel Devs A/B/C/D), per the approved plan at `~/.claude/plans/dreamy-strolling-duckling.md` (full execution plan + Round 1 patches 1–4 + optional rationale-chain rule + Round 2 fixes for settings.json scope, Phase 2 grep scope, and Dev D pre-spawn investigation of `independent-review.md`).

- [x] **Lead — Step 1.5 — Lead-Resolution Option A — `language-check.sh` `independent-review.md` exclusion.** The single Tier 2 violation in `docs/independent-review.md` (line 33, row 8 of the Wave 2 IR alignment table) was a CJK quote of a Tier 4 frozen plan.md section title (`"CLAUDE-TEMPLATE 同步审计 — 已完成"`). Translating it in place would mutate immutable IR audit-trail content. Resolution: added `docs/independent-review.md` to `TIER2_EXCLUDED_FILES` in `scripts/language-check.sh` (alongside `session-log.md`, `plan.md`) with a 4-line justifying comment explaining the IR audit-trail-immutability principle. One-line script change + comment, bundled into Wave 3 PR. Self-test (`bash scripts/language-check.sh --self-test`) still passes. This single non-translation script edit was the only `scripts/*.sh` change in Wave 3 and is in scope as a structural prerequisite for the 0-violation mechanical gate.
- [x] Dev A — `docs/process-observer.md` (~280 lines, 151 CJK violations). All 33 headings translated; 7 cascading dangerous-operation tables preserved with operation→rationale causal links intact; pre-defined heading renames applied (`## Real-time Interception (Hooks)` line 15 → anchor `#real-time-interception-hooks`; `## Post-Hoc Audit (Sub-agent)` line 165 → anchor `#post-hoc-audit-sub-agent`).
- [x] Dev B — `docs/configuration.md` (290 lines, 67 CJK violations) and `docs/security.md` (103 lines, 64 CJK violations). Role-Model Mapping table preserved (6 cols × 8 roles); Sensitive File Classification table preserved (3 cols × 7 categories); inbound anchor links (`#agent-model-configuration`, `#multi-device-sync-optional`) remain English-stable; JSON / bash code blocks untouched per JSON/bash rules.
- [x] Dev C — `docs/product-spec.md` (89 lines, 58 CJK violations) and `docs/design-decisions.md` (75 lines, 34 CJK violations). design-decisions.md row count preserved (71 data rows, identical to pre-edit); rationale chains preserved verbatim per Dev C SPECIAL RULE (3 spot-checked rows — row 50 self-verifying-startup, row 52 security-three-layer-defense, row 73 /release command — each retains causal connectors); milestone diagram in product-spec.md upgraded from CJK ASCII to mermaid `timeline` (Option A, dependency already present in roles.md). Bonus: Dev C also translated row 39 talk title `"AI Agent 的道与术"` → `"The Way and the Craft of AI Agents"` (semantic-preserving; `@onevcat` attribution unchanged); row 68 had a corrupt UTF-8 sequence `描��` (truncated `描述`), translated based on inferred meaning from surrounding context.
- [x] Dev D — `docs/workflow.md` (311 lines, 9 CJK violations + 2 anchor link updates), `docs/roles.md` (418 lines, 5 CJK violations + line 337 carry-over cleanup), `docs/troubleshooting.md` (34 lines, 3 CJK violations). workflow.md lines 303 + 311 anchor links updated to point at the new English anchors in process-observer.md (cross-file coordination per Pre-Defined Anchor Renames table); roles.md:337 stale `(English)/(Chinese)` parentheticals removed (Wave 2 Doc Engineer MINOR carry-over); `docs/independent-review.md` ZERO edits per Lead-Resolution Option A (verified `git diff` empty).
- [x] Phase 2 cross-check (Lead-orchestrated, sequential): 4a `language-check.sh` PASSED (0/0/0); 4b `roles.md:337` clean (0 hits); 4c cross-file anchor sweep PASSED (workflow.md → both English anchors, process-observer.md → both new English headings); 4d terminology consistency grep across Tier 1 (CLAUDE.md, CLAUDE-TEMPLATE.md, commands/, agents/) + Tier 2 (docs/) — 0 drift detected for Mode Selection Checkpoint, Independent Reviewer, Process Observer, Doc Engineer, Team Lead, Teammate, Real-time Interception, Post-Hoc Audit, self-referential boundary, Cross-Session Barrier Protocol, Wave Boundary Review.
- [x] Independent Reviewer (Wave Boundary Review) spawned with fixed prompt; report appended to `docs/independent-review.md` as `## Wave 3 Review — 2026-04-07`. Verdict PROCEED, 0 CRITICAL, 0 MAJOR, 1 MINOR (the now-resolved forward reference from `scripts/language-check.sh` to this very plan.md section).
- [x] Doc Engineer audit: PASS with 1 MINOR (pre-existing CLAUDE-TEMPLATE.md ↔ CLAUDE.md divergence on Process Observer "Core/Advisory layer" framing — out of Wave 3 scope, NOT a Wave 3 regression; tracked for a future template-resync sweep). Link integrity sample 5/5 passed (README → configuration anchors, README.zh-CN → security, workflow → roles → developer-codex anchor). Cross-file anchors verified PASS. Terminology PASS.
- [x] Process Observer audit (Sonnet): 7 PASS / 1 WARN / 0 FAIL. F1 (Independent Review at Wave boundary) PASS verified — `docs/independent-review.md` line 62 confirms `## Wave 3 Review — 2026-04-07`. The single WARN (A6 plan.md accuracy at audit time) is the expected in-progress state — Step 7 of Wave 3 execution is this very plan.md update, so the entry could not exist at audit time; resolved by writing this entry in the same commit as the Wave 3 work.

Verification (after Wave 3):
- Tier 1 violations: 0 (held from Wave 2)
- Tier 2 violations: 0 (target met — first time in project history `bash scripts/language-check.sh` reports `PASSED: Tier 1/Tier 2 are CJK-clean and Principle 1 is clean.`)
- Principle 1 violations: 0 (held from Hotfix #2)
- Files modified in Wave 3 PR: 11 (9 `docs/*.md` translation diffs + `scripts/language-check.sh` Lead-Resolution Option A 1-line exclusion + `docs/plan.md` BLOCKING-marker swap and this completion entry; `docs/independent-review.md` IR Wave 3 review append is included via the IR sub-agent run, total 11 file touches)
- `.claude/settings.json` NOT in Wave 3 PR (pre-execution Case A confirmed; the matcher migration was already merged in PR #153)

Cross-session boundary required before Wave 4 (per Cross-Session Barrier Protocol — Wave 3 fully Englishized `docs/*.md` Tier 2 reference docs which are loaded by IR at Wave Boundary Review and by Lead during planning; the current session has stale CJK versions cached in conversation context). The Wave 3→4 BLOCKING marker at the top of this file will be auto-detected by `/start-working` Step 0 in the next session.

### i18n Cleanup — Wave 4 (2026-04-07) — Complete

Goal: Promote `scripts/language-check.sh` to a blocking sub-step inside the Doc Engineer audit checklist invoked from `/end-working`. Fulfills the Wave-1 forward-looking promise at CLAUDE.md > "Documentation Language Convention" final paragraph ("integrated into the Doc Engineer audit step of `/end-working` starting from Wave 4").

Mode: Solo + Codex (3 framework files, small edits, self-referential boundary, no decomposable parallel work).

- [x] `docs/roles.md` — added item 9 (Language convention check) to Doc Engineer audit checklist after item 8 (Security compliance check). Conditional on `scripts/language-check.sh` existence (graceful no-op for projects that have not adopted iSparto's language convention). Exit code semantics: 0 ✅ pass / 1 ❌ FAIL / 2 ⚠️ env warning. Output format table extended with a row for item 9 and a `--- Language Convention Violations (item 9) ---` sub-section template for raw violation lines (only emitted on FAIL). New Key Principle added for the audit-fix-reaudit loop (Lead-fixes-not-Doc-Engineer, fresh-sub-agent re-spawn, bounded at 3 iterations) and the 6-step blocked recovery path on loop-bound exceedance.
- [x] `commands/end-working.md` — extended step 9 fallback gate with two new bullets: (a) audit-fix-reaudit loop on Doc Engineer FAIL (Lead reads failing items, edits files, re-spawns fresh Doc Engineer sub-agent, bounded at 3 iterations); (b) 6-step blocked recovery path when the loop bound is exceeded (stop loop, blocked report, plan.md entry, push WIP, report to user, exit /end-working without merging). No step renumbering.
- [x] `docs/plan.md` — Wave 3→4 BLOCKING marker consumed and replaced with Wave 4→5 marker; Wave 4 completion entry appended (this entry); deferred item "Wave 4 task — promote `language-check.sh` to a blocking gate inside `/end-working`" already removed from the Wave 3 Deferred items list.
- [x] Pre-edit baseline: ran `bash scripts/language-check.sh` at session start — reported `0 Tier 1 CJK / 0 Tier 2 CJK / 0 Principle 1` (exit 0). Wave 4 begins on a clean guardian.
- [x] Post-edit guardian re-run: ran `bash scripts/language-check.sh` after all Wave 4 edits — still reports `0 Tier 1 CJK / 0 Tier 2 CJK / 0 Principle 1` (exit 0). Wave 4 edits are pure English and introduce no new violations.
- [x] Self-test: ran `bash scripts/language-check.sh --self-test` — both Principle 1 fixtures PASS, exit 0. (Sanity check; hold from Hotfix #2.)
- [x] Doc Engineer audit (fresh sub-agent, spawned from current session): **PASS on all 9 items**. Items 1–7 PASS or N/A; item 8 (Security compliance) PASS — pure markdown, no code changes; item 9 (Language convention) PASS — guardian exit 0, 0/0/0 violations, self-test green. The new item 9 was exercised against the Wave 4 file changes themselves (meta-test succeeded: the gate that Wave 4 introduces runs cleanly against the very Wave that introduces it). See meta-verification caveat below for why this is only a partial validation.
- [x] Process Observer audit (Sonnet, fresh sub-agent): **11 PASS / 1 WARN / 0 FAIL / 2 N/A** against the 5-checklist 14-check standard. The sole WARN (F1 — Independent Review at Wave boundary) was an in-progress state captured mid-sequence: it resolved to PASS once the IR sub-agent completed and appended its report to `docs/independent-review.md`. The two N/A (D1/D2 — PR workflow) are correct pre-commit states, not deviations. Framework-side rule-correction suggestion recorded by the auditor: F1 check should gain an "IN-PROGRESS" intermediate status so mid-session audits do not conflate "pending (OK)" with "not yet done (at risk)". Noted for next `/start-working` as a framework improvement candidate.
- [x] Independent Reviewer (Wave Boundary Review, Teammate tmux mode, fixed prompt) spawned; report appended to `docs/independent-review.md` as `## Wave 4 Review — 2026-04-07`. **Verdict: PROCEED** — 0 CRITICAL, 0 MAJOR, 2 MINOR non-blocking findings. MINOR #1: the initial Wave 4→5 BLOCKING marker preamble contained the CJK phrase `master-plan-固化` (added by Edit A of plan.md). Although `docs/plan.md` is in the guardian's Tier 2 exclusion list (so the gate would not flag it), it was still a net addition of CJK content to a file the convention wants to keep clean over time — fixed in the same Wave 4 commit by replacing with "per the cross-session barrier protocol hardened in the master plan". MINOR #2: Wave 4 completion entry was still pending at IR time — resolved by writing this entry before commit. Unjustified technical work: None; every line of the 3-file diff maps directly to a Wave 4 objective.

Verification (after Wave 4):
- Tier 1 violations: 0 (held from Wave 2)
- Tier 2 violations: 0 (held from Wave 3 + MINOR #1 fixed in Wave 4)
- Principle 1 violations: 0 (held from Hotfix #2)
- Doc Engineer checklist now has 9 items (was 8); item 9 is mechanical (parallel to item 8 security scan)
- The audit-fix-reaudit loop pattern and 6-step blocked recovery path are documented in `docs/roles.md` Doc Engineer Key Principles and `commands/end-working.md` step 9
- Wave-1 forward-looking promise at CLAUDE.md > "Documentation Language Convention" is now fulfilled; the forward reference in CLAUDE.md L44 ("starting from Wave 4") remains accurate without edit

**Meta-verification caveat (important — full validation deferred to Wave 5).** The current session's Doc Engineer audit spawned a fresh sub-agent that read the post-Wave-4 `docs/roles.md` from disk and ran the new item 9 against the current repo state. This confirms item 9 *runs and reports PASS* on a clean repo — the expected happy-path for Wave 4 itself, since the Wave 4 edits introduce no language violations. **However, this is only a partial validation**:

- It does **NOT** exercise the audit-fix-reaudit loop, because the loop only triggers on a real FAIL — and the Wave 4 commit passed cleanly, so the loop was not naturally triggered.
- It does **NOT** exercise the 6-step blocked recovery path, for the same reason.
- Most importantly: the **Lead in the current session has the pre-Wave-4 Tier 1 system prompts cached in conversation context** (CLAUDE.md, `docs/roles.md`, `commands/end-working.md` — all loaded via the start-of-session system-reminder injection). Any fix-loop the Lead would orchestrate in the current session would use the stale mental model, even though the spawned sub-agents read fresh files.

**Therefore, full validation of the Wave 4 wiring (including the audit-fix-reaudit loop and the 6-step blocked recovery path) is deferred to Wave 5's first natural Doc Engineer run** in a new session — that is the first invocation where the Lead's conversation context is loaded from the post-Wave-4 disk state, and the full pattern will be exercised end-to-end against whatever Wave 5 changes happen to introduce.

Cross-session boundary required before Wave 5 (per the cross-session barrier protocol hardened in the master plan — Wave 4 modified `commands/end-working.md` and `docs/roles.md`, both Tier 1 system prompts loaded by Lead). The Wave 4→5 BLOCKING marker at the top of this file will be auto-detected by `/start-working` Step 0 in the next session.

### i18n Cleanup — Wave 5 (2026-04-07) — Completed

Goal: i18n cleanup finalization Wave. Three outcomes: (1) end-to-end verification of Wave 1-4 products against post-Wave-4 disk state via all four audit channels (`scripts/language-check.sh` + Doc Engineer + Independent Reviewer + Process Observer); (2) Chinese user onboarding entry (absorbs Master plan Task 5.1-5.6 + Wave 4 leftover Chinese entry — `README.zh-CN.md` intro + new `docs/zh/quick-start.md` + `CONTRIBUTING.md` Documentation Language Convention section); (3) historical record + carry-over framework polish (CHANGELOG entry + Human review checklist for DaDalus + two framework items previously deferred: CLAUDE-TEMPLATE.md ↔ CLAUDE.md sync sweep from Wave 3, Process Observer F1 IN-PROGRESS state from Wave 4 PO self-audit).

Master plan reference: `~/.claude/plans/distributed-twirling-harp.md` (Task 5.1-5.6 + Wave 4 Chinese-entry leftover). Wave 5 execution plan: `~/.claude/plans/sunny-petting-pizza.md`.

Mode: Solo + Lead direct edit (self-referential boundary, Wave 4 precedent — 9 markdown files across 4 modules: READMEs / Project Docs / Slash Commands + Project Template / Process Observer; no Developer/Codex calls; no architecture pre-review; no code review — zero code changes).

Task list (T1-T10):
- [x] T1 — `docs/plan.md` Wave 5 entry placeholder + removed acknowledged Wave 4→5 BLOCKING marker + removed Wave 4 deferred items #1 (CLAUDE-TEMPLATE.md sync sweep) and #2 (PO F1 IN-PROGRESS state) as both are absorbed into Wave 5 scope (commit `74723f5`)
- [x] T2 — `CLAUDE-TEMPLATE.md` sync sweep: (a) L61 Process Observer description aligned with CLAUDE.md L76 "hooks + Sonnet sub-agent" + Core/Advisory layer framing; (b) workflow steps 4-6 adds "must complete before push/merge, cannot be deferred to /end-working" qualifier; (c) consistency spot-check on Module Boundaries / Plan Mode triggers / role descriptions found 0 additional divergences (commit `9572dbe`)
- [x] T3 — `agents/process-observer-audit.md` F1 row state expansion from PASS/FAIL/N/A to PASS/IN-PROGRESS/FAIL/N/A + IN-PROGRESS determination rule ("IR planned in plan.md sequence but not yet executed at audit time") + Summary row format adjusted accordingly (commit `67ce9f1`)
- [x] T4 — `docs/zh/quick-start.md` NEW (Tier 3 Chinese quick-start, 117 lines: install → /init-project / /migrate → /start-working / /end-working → troubleshooting pointer; footer explains reference docs are English-only by design, links to CLAUDE.md > Documentation Language Convention) (commit `6212c16`)
- [x] T5 — `README.zh-CN.md` top intro pointer to `docs/zh/quick-start.md` + Tier 3 bilingual strategy note (inserted AFTER hero sentence per plan-approval IR MINOR #2 placement guidance, preserving all existing content); parallel English block also added to `README.md` (commit `1538d24` + Doc Engineer fix `1fec975`)
- [x] T6 — `CONTRIBUTING.md` new `## Documentation Language Convention` section inserted after "Things to Be Careful About" (four-tier summary + link to CLAUDE.md + language-check.sh PR blocking gate reminder) (commit `6b039f6`)
- [x] T7 — Final acceptance verification: 9 [build] commands (A1-A9: language-check.sh main/self-test, install dry-run, file/grep existence checks) all exit 0 + 4 [runtime] commands (R1 Doc Engineer sub-agent — iteration 1 FAIL on item 7 README sync → fix `1fec975` → iteration 2 PASS; R2 Process Observer sub-agent — 12 passed / 1 in-progress / 0 warnings / 0 failures with F1 IN-PROGRESS validating new state machine; R3 Independent Reviewer Teammate Wave Boundary Review — verdict PROCEED 0 CRITICAL 0 MAJOR 2 non-blocking MINOR; R4 Chinese doc manual render — 12 link targets all resolve, CLAUDE.md anchor verified at line 26)
- [x] T8 — Human review pass checklist written into three destinations byte-identically (conversation briefing + PR description + this Wave 5 entry's Human review checklist sub-section below)
- [x] T9 — `CHANGELOG.md` `[Unreleased]` section entry (4 Changed + 3 Added items spanning Wave 1-5 i18n cleanup per master plan Task 5.5 template) (commit `750dcac`)
- [x] T10 — This Wave 5 entry promoted from placeholder to final completion evidence

Verification counts:
- 10 commits on `feat/wave-5-i18n-finalization` branch (T1-T6 + T9 + Doc Engineer fix `1fec975` + IR audit trail `7a05214` + T10 `be92589`)
- 9 [build] checks PASS (A1 language-check main scan, A2 language-check self-test, A3 install --dry-run, A4 quick-start exists, A5 README.zh-CN points to quick-start, A6 CONTRIBUTING contains section header, A7 CLAUDE-TEMPLATE three sync markers, A8 PO F1 IN-PROGRESS marker, A9 CHANGELOG Unreleased entry present)
- 4 [runtime] checks PASS (R1 Doc Engineer 9/9 PASS at iteration 2; R2 Process Observer 12 passed / 1 in-progress / 0/0 — F1 IN-PROGRESS validates new T3 state machine; R3 IR Wave Boundary PROCEED 0 CRITICAL 0 MAJOR; R4 link integrity all 12 targets resolve)
- 0 CJK / 0 Tier-1 / 0 Tier-2 / 0 Principle 1 violations from `scripts/language-check.sh`
- Audit-fix-reaudit loop closed at iteration 2/3 (item 7 FAIL → 1fec975 → PASS)

Wave 5 → Wave 6 BLOCKING marker: NOT required. Wave 5 modified two Tier 1 files (`CLAUDE-TEMPLATE.md`, `agents/process-observer-audit.md`); neither is loaded into Lead's main session system-reminder cache (CLAUDE-TEMPLATE.md is read only at /init-project time; agents/process-observer-audit.md is read by spawned PO sub-agent in fresh context). All other Wave 5 changes are Tier 3 (READMEs / CONTRIBUTING / quick-start) or Tier 4 (plan.md / CHANGELOG.md), neither cached. Next session may begin without cross-session barrier.

#### Human review checklist

> ## Wave 1-5 i18n Cleanup — Human Review Checklist
>
> Wave 1-4 把 iSparto 的 Tier 1（系统提示）和 Tier 2（参考文档）从中文翻成英文。机械守卫（`scripts/language-check.sh`）已经验证 0 CJK + 0 Principle 1 violations，Independent Reviewer 在 Wave 2/3 也跑过 verdict PROCEED。但**翻译过程涉及解释而非直译的部分需要你人工 review** — IR 检查的是机械可验证的属性（行为规则没丢、recovery path 完整、Principle 1 没违反），而以下检查是 IR 做不到的语义 nuance。
>
> **本 checklist 不阻塞 Wave 5 PR merge。** 请按你自己的节奏 review，发现问题用下面的 GitHub issue 格式开 follow-up。
>
> ### Files to review
>
> | # | 文件 | 原始 CJK 行数 | 高风险 sections（涉及解释翻译） |
> |---|------|---------------|--------------------------------|
> | 1 | `CLAUDE.md` | ~120 → 0 | (a) **User Preference Interface — Three-level response model** — Level 1/2/3 的边界是行为契约的核心（哪些 user 偏好可以无条件接受、哪些只能在 workflow 边界内适应、哪些只记录不执行），翻译时容易把 Level 边界翻"软"。重点验证 territory principle wording 和 "Conflict protocol" 段落。<br/>(b) **Implementation Protocol — "Code file" 定义** — 涉及 workflow-rules.json 和 allowed_extensions 的交互，翻译时是否仍然把 .md 文件正确归类为"非代码文件"（决定 Lead 直编是否合规）。<br/>(c) **Documentation Language Convention** — Wave 1 新增段落，不是翻译；但 "Hard-coded user-facing strings rule" 和 "Illustrative-example rule" 的 wording 决定 Principle 1 守卫的覆盖范围，验证 wording 是否传达"描述 intent 而非嵌入 literal" 的意图 |
> | 2 | `CLAUDE-TEMPLATE.md` | ~14 → 0 | (a) **Process Observer 描述** — Wave 5 T2 sync sweep 把 L61 从 "hooks + Lead sub-agent" 改成 CLAUDE.md L76 同款 "hooks + Sonnet sub-agent" + Core/Advisory layer。验证生成的 project CLAUDE.md 仍能正确指挥 Process Observer 行为。<br/>(b) **Workflow steps 4-6 限定语** — Wave 5 T2 同样补了 "must complete before push/merge, cannot be deferred to /end-working" 限定语。验证语义是否传达"Doc Engineer 不能延迟到 /end-working" 这个硬约束。<br/>(c) **Module Boundaries 占位段落** — TEMPLATE 里这是空表，新项目 /init-project 时 Lead 会填，但占位文本的措辞影响 Lead 怎么填 |
> | 3 | `docs/roles.md` | ~5 → 0 | (a) **Independent Reviewer 角色定义** — "zero inherited context" / "fixed one-liner — no additional context or framing allowed" / "Report written directly to docs/independent-review.md, not filtered through Lead" 这三句是 IR 设计的核心，翻译时容易把"零继承"翻成软性建议而不是硬约束。<br/>(b) **Doc Engineer audit checklist 9 项** — Wave 4 加的 item 9 (Language convention check) 必须保留 "条件 on `scripts/language-check.sh` existence" 的语义（让用户项目 graceful skip）。<br/>(c) **Audit-fix-reaudit Key Principles** — "Lead-fixes-not-Doc-Engineer" + "fresh-sub-agent re-spawn" + "bounded at 3 iterations" + "6-step blocked recovery path" — 这是 Wave 4 引入的循环模式，每个限定词都是设计选择 |
> | 4 | `docs/workflow.md` | ~9 → 0（+ 2 anchor link 更新） | (a) **Mode Selection Checkpoint 描述** — Solo / Agent Team 切换条件，"5 files with large logic changes → Agent Team; 5 files with 1-line edits → Solo" 的判定阈值翻译时容易把示例值当成硬规则。<br/>(b) **Developer trigger 条件表** — Tier 表里 "implementation + QA" / "QA only" / "Developer review only" / "skip both" 的 4 种组合，验证决策逻辑是否清晰。<br/>(c) **Cross-doc anchor links** — L303 / L311 在 Wave 3 改成指向 process-observer.md 的英文 anchors（`#real-time-interception-hooks` / `#post-hoc-audit-sub-agent`），验证链接 resolve 正确 |
> | 5 | `docs/design-decisions.md` | ~34 → 0 | **⚠️ 最高优先级 review 文件**（per Wave 3 Dev C SPECIAL RULE: "preserve the full reasoning chain"）<br/>(a) **Rows 43-60（recent core decisions）** — Process Observer three-tier、hooks registration、three-tier security audit、Stateless Session 等 — 这些 Rationale 单元格的 "because X therefore Y" 因果链不能被翻"扁"。验证因果连接词（because / since / to avoid / otherwise）在每行 Rationale 里是否仍然存在。<br/>(b) **Row 39 talk title** — `"AI Agent 的道与术"` 翻成 `"The Way and the Craft of AI Agents"`（Wave 3 Dev C bonus 翻译，semantic-preserving 版本）。验证你是否同意这个翻译；@onevcat 署名未变。<br/>(c) **Row 68** — 原文有 corrupt UTF-8 序列 `描��`（截断的 `描述`），Wave 3 Dev C 基于上下文推断翻译，需要你确认推断是否符合原意 |
> | 6 | `docs/product-spec.md` | ~58 → 0 | (a) **v0.x / v1.x / v2.x 三阶段产品演进** — 每个阶段的 "交付标准" 是产品 vision 的核心承诺，翻译时容易把承诺翻软。验证 v0.x "一个没见过 iSparto 的 Claude Code 用户，看 README 就能装好" 这种硬标准。<br/>(b) **Milestone 图** — Wave 3 Dev C 把 CJK ASCII 图升级成 mermaid `timeline` block。验证升级后的 timeline 节点和原 ASCII 图语义一致（mermaid 渲染依赖 GitHub markdown 支持）。<br/>(c) **商业化路径含义** — 任何提到 commercialization / pro tier / paid features 的 wording 都涉及产品定位，翻译时容易把模糊表达翻精确（或反过来），影响外部读者对 iSparto 走向的理解 |
>
> ### GitHub issue 反馈格式
>
> 发现翻译问题时，请用以下格式开 issue：
>
> **Title 模板：**
> ```
> [i18n-followup] <文件路径>: <section 名>
> ```
>
> **Title 示例：**
> ```
> [i18n-followup] docs/roles.md: Independent Reviewer trigger conditions
> [i18n-followup] CLAUDE.md: User Preference Interface Level 2 wording
> [i18n-followup] docs/design-decisions.md: row 47 Process Observer rationale chain
> ```
>
> **Body 模板：**
> ```markdown
> ## Original Chinese (if you remember it)
> [原中文，可留空]
>
> ## Current English
> [当前英文版本，引用 markdown block]
>
> ## Suggested correction
> [你的修正建议]
>
> ## Why this matters
> [选一项: semantic loss / behavioral implication / wording feel / factual error]
> [简短说明为什么这个修正必要]
> ```
>
> **Maintainer 处理流程：**
> Maintainer 收到 issue 后，在 `fix/i18n-correction-MMDD` 分支处理。多个 issue 可以合并到同一分支批量修。每个 fix commit 的 message 引用对应 issue 编号。

### Post-Wave 5 Follow-up Hotfixes (2026-04-08) — Complete

Branch: `feat/post-wave5-followups`. Mode: Solo + Lead direct edit (self-referential boundary — all target files are Tier 1 behavioral templates or Tier 2 reference docs; Wave 5 precedent applies — 5 files, no code changes, no Developer/Codex calls).

Goal: Close three parked framework-side items carried over from Wave 2/3 that were explicitly scoped out of Wave 5 at /start-working user-lock. All three were non-blocking framework polish, tracked in the Wave 2 Deferred items list (now removed) and in `docs/framework-feedback-0407.md`. None of them are Wave 5 regressions.

- [x] **Hotfix #1 — `commands/start-working.md` Step 7 auto-add branch guard.** Wrapped the auto-add sub-branch with the same `claude mcp list -s user 2>/dev/null | grep -q codex-dev` migration guard as the rename branch (Wave 2 Hotfix #1 precedent). Pass branch: auto-adds matchers and informs user. Fail branch: skips auto-add entirely (no partial mid-state), informs user that the local install is stale, instructs them to run `~/.isparto/install.sh --upgrade` and re-run `/start-working`, then proceeds directly to Step 8. Closes Wave 2 Hotfix #1 Codex review MINOR follow-up.
- [x] **Hotfix #2 — `CLAUDE.md` + `CLAUDE-TEMPLATE.md` plan.md timing rule rewording.** Reworded the "Update docs/plan.md immediately after completing tasks" rule (L22 in both files) to make the Wave-completion exception explicit. New wording: "Update docs/plan.md immediately after completing each task in the same commit as the task work. Exception: Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates, because that is the step that knows the Wave is fully complete." Source: `docs/framework-feedback-0407.md` Suggestion 1, verbatim.
- [x] **Hotfix #3 — `CLAUDE.md` (L83 + L95) + `docs/workflow.md` (Solo + Agent Team QA paragraphs) Lead-direct QA carve-out.** Appended a carve-out to workflow step 3 in both Solo and Agent Team workflows (CLAUDE.md) and mirrored the rule as a sub-bullet in the two QA paragraphs in `docs/workflow.md`. Rule: when the plan.md acceptance script is ≤5 deterministic bash commands whose verdict is determined solely by exit code (e.g., `bash scripts/language-check.sh --self-test`), Lead may execute them directly and record each command + exit code in plan.md as acceptance evidence, skipping the Developer QA wrapper. Explicitly scoped: no build step, no runtime app verification, no output-parsing, not applicable to anything tagged [build]/[runtime]. Closes Wave 3 Hotfix #2 Process Observer A6 WARN.

**Acceptance script (5 Lead-direct bash commands — dogfoods Hotfix #3 carve-out):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh` | exit 0, "Tier 1/Tier 2 are CJK-clean and Principle 1 is clean" | exit 0 ✅ PASSED |
| A2 | `bash scripts/language-check.sh --self-test` | exit 0, Test 1 + Test 4 PASS | exit 0 ✅ both PASS |
| A3 | `grep -c 'claude mcp list -s user 2>/dev/null \| grep -q codex-dev' commands/start-working.md` | ≥2 | 2 ✅ (rename guard + new auto-add guard) |
| A4 | `grep -l 'Wave-completion entries and cross-session BLOCKING markers' CLAUDE.md CLAUDE-TEMPLATE.md` | both files listed | both ✅ synced |
| A5 | `grep -l '≤5 deterministic bash commands' CLAUDE.md docs/workflow.md` | both files listed | both ✅ |

All 5 commands exit 0. No build step, no runtime, no output-parsing — eligible under the new carve-out.

**Files modified:**
- `commands/start-working.md` (Hotfix #1 — Step 7 auto-add guard)
- `CLAUDE.md` (Hotfix #2 L22 rewording + Hotfix #3 L83/L95 carve-out)
- `CLAUDE-TEMPLATE.md` (Hotfix #2 L22 sync)
- `docs/workflow.md` (Hotfix #3 Solo + Agent Team QA paragraphs)
- `docs/plan.md` (Wave 2 Deferred items cleared + this entry)

**Why no Independent Reviewer:** Not a Wave boundary — this is a post-Wave-5 parked-items cleanup. Precedent: Wave 2 Inter-Wave Hotfix #1 and Hotfix #2 also did not trigger IR. Doc Engineer and Process Observer audits are sufficient for this scope.

### Framework Polish Round 2 (2026-04-08) — Complete

Branch: `feat/framework-polish-round-2`. Mode: Solo + Lead direct edit (self-referential boundary — all target files are Tier 1 behavioral templates or Tier 2 reference docs; Post-Wave 5 Follow-up Hotfixes precedent applies — 7 files, no code changes, no Developer/Codex calls).

Goal: Close ALL remaining framework-side items from the 6 `docs/framework-feedback-*.md` files, accumulated across Waves 2-5 and Session (#b). User explicitly requested a single bundled clean-up rather than another round of incremental hotfixes. 11 items collapsed into 5 logical commits.

- [x] **Commit 1 — `CLAUDE.md` self-referential boundary covers Tier 1 root-level files.** Source: framework-feedback-0408-b Rule 1. Previous L24 wording enumerated only subdirectories; root-level Tier 1 files (CLAUDE.md, CLAUDE-TEMPLATE.md, bootstrap.sh, install.sh, isparto.sh) fell outside the literal reading. Reworded to anchor on the Tier 1 definition from Documentation Language Convention and enumerate both subdirectory and root-level files explicitly. Also extended scope to cover Tier 2/3/4 framework docs (other docs/*.md, READMEs, CONTRIBUTING.md, CHANGELOG.md, VERSION). (commit `8733a97`)
- [x] **Commit 2 — Emergency hotfix + ad-hoc fix Doc Engineer exceptions.** Sources: framework-feedback-0408-b Rules 2+3, framework-feedback-0405b row 1. Added two narrow exception paths to CLAUDE.md Solo + Agent Team workflow step 4: (a) ad-hoc fix skip (no Wave, no code↔doc sync risk); (b) emergency hotfix substitute (hotfix/ branches, ≤3 Tier 1 shell + CHANGELOG files, explicit emergency window — substitute with lang-check clean run + manual inline review + session-log exception entry). Mirrored in CLAUDE-TEMPLATE.md. Added Doc Engineer reference + both exception paths to `docs/workflow.md` Hotfix Workflow section (previously omitted DE entirely). (commit `ccf04a4`)
- [x] **Commit 3 — plan.md update cadence + verification-count accuracy.** Sources: framework-feedback-0408 Rules 1+2, framework-feedback-0405b row 2. Rule 1 (verification-count accuracy): Wave 4/5 entries under-counted commits because Lead estimated at draft time; now codified to compute mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l`. Rule 2 (Option A — relax to match practice): L22 update rule relaxed to permit both per-task and per-Wave cadences, since Waves 3/4/5 all shipped bulk pattern without issue. 0405b row 2: fix session not tied to any plan.md entry requires no plan.md update. All three merged into two CLAUDE.md bullets + mirrored in CLAUDE-TEMPLATE.md + added to `templates/plan-template.md` header blockquote. (commit `8f3ae74`)
- [x] **Commit 4 — plan.md is wholly Tier 4 — forward-looking sections exempt.** Source: framework-feedback-0407c Suggestion 1, Option A. Wave 3 PO G4 check noted plan.md's Next-Steps roadmap and Tech Ecosystem Tracking table sat in a language-tier gray zone — the file is on the language-check Tier 2 exclusion list but CLAUDE.md Tier 4 only covered "historical sections in docs/plan.md". Option A resolution: plan.md wholly Tier 4, both historical and forward-looking content exempt from English-only rule, matching the guardian's actual behavior. Option B (split treatment + per-section guardian) rejected as higher complexity for zero benefit. (commit `b35b9ac`)
- [x] **Commit 5 — F1 spawn-source + PR body Mode Selection + audit source distinction.** Sources: framework-feedback-0407 Suggestion 2, framework-feedback-0405 F1+F2. (a) F1 row in `agents/process-observer-audit.md` now explicitly states that both Lead-initiated mid-session IR spawn and `/end-working` Step 3 auto-spawn satisfy F1 equally, with the same acceptance criteria. (b) Added `## Mode Selection` field to the PR body template in `commands/end-working.md` step 9 so future PR-metadata audits can verify B1 (Mode Selection Checkpoint) without replaying the session. (c) Extended the PR body template to require explicit `sub-agent run ✅ / Lead self-assessed ✅` marking for Doc Engineer and Process Observer, plus an Independent Reviewer verdict line. Self-assessed must always cite the exception reason per CLAUDE.md workflow step 4. (commit `c9bba79`)

**Acceptance verification (3 Lead-direct bash commands — under the trivial-CLI carve-out from CLAUDE.md Solo workflow step 3):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh` | exit 0, "Tier 1/Tier 2 are CJK-clean and Principle 1 is clean" | exit 0 ✅ (verified after every commit — 5 invocations) |
| A2 | `bash scripts/language-check.sh --self-test` | exit 0, Test 1 + Test 4 PASS | exit 0 ✅ both fixtures PASS |
| A3 | `git log --oneline --no-merges main..HEAD \| wc -l` | 6 commits (5 rule corrections + this plan.md entry commit) | 6 ✅ computed mechanically per Commit 3 rule |

All 3 commands exit 0. No build step, no runtime, no output-parsing — eligible under the CLAUDE.md Solo workflow step 3 trivial-CLI carve-out.

**Files modified:**
- `CLAUDE.md` (commits 1, 2, 3, 4 — self-referential boundary, workflow step 4 exceptions, plan.md rules, Tier 4 freeze)
- `CLAUDE-TEMPLATE.md` (commits 2, 3 — mirror workflow step 4 exceptions and plan.md cadence/accuracy rules)
- `docs/workflow.md` (commit 2 — Hotfix Workflow Doc Engineer references + substitute/skip paths)
- `templates/plan-template.md` (commit 3 — Wave Parallel Development Plan header blockquote)
- `agents/process-observer-audit.md` (commit 5 — F1 spawn-source clarification)
- `commands/end-working.md` (commit 5 — PR body template with Mode Selection + audit source distinction)
- `docs/plan.md` (this entry)

**Why no Independent Reviewer:** Not a Wave boundary — this is a standalone framework polish round collapsing 11 framework-feedback items from 6 accumulated feedback files. Precedent: Post-Wave 5 Follow-up Hotfixes (2026-04-08), Wave 2 Inter-Wave Hotfix #1 + #2 — none triggered IR. Doc Engineer and Process Observer audits are sufficient for this scope.

**Framework-feedback file disposition:** All 6 `docs/framework-feedback-*.md` files remain on disk as Tier 4 historical artifacts (frozen per Documentation Language Convention). Their contents are now reflected in the corresponding Tier 1/2 rule sources. No feedback file is deleted — they serve as the audit trail. Previously-closed items (0407 Suggestion 1 Wave-completion exception, 0407 Suggestion 3 Principle 1 guardian) were resolved in prior Hotfixes; the remaining 11 items are closed by this round.

### 技术生态追踪（暂不执行）

以下项目受外部生态演进驱动，iSparto 只追踪不行动，满足触发条件时再评估：

| 追踪项 | 触发条件 | 影响评估 | 预估时间 |
|--------|---------|---------|---------|
| GPT-5.3-codex 退役 | OpenAI 官方宣布退役日期（参考 5.2 Thinking 2026-06-05 退役先例） | Developer 被动升级 5.4，需验证所有 prompt template 兼容性 + 重新评估 Tier-模型映射 | 2026 Q3-Q4 |
| gpt-5.3-codex-spark 支持 | OpenAI 宣布 spark 在 ChatGPT Plus 上可用，或 API key 认证方式可绕过限制 | 引入第三档 Developer 模型（快速修复专用），从双档升级为三档 | 取决于 OpenAI |
| codex-plugin-cc 集成 | v0.8 阶段，codex-plugin-cc 稳定且 MCP/Plugin 职责边界验证完毕 | MCP 核心实现路径 + Plugin 补充审查/委派 | v0.8 |
| 跨 session 自动化 | v1.x 阶段，且 Codex Triggers + Claude Code /loop 均稳定 | 从 session 级框架扩展到 event-driven 自动化（GitHub issue → 自动修复 → 自动 PR） | v1.x |
| Process Observer 覆盖 Plugin 调用 | Claude Code 的 hook 机制支持拦截 plugin slash command（目前不支持） | 统一 MCP 和 Plugin 通道的 hooks 覆盖，简化双通道架构 | 取决于 Claude Code 演进 |
| 多 agent runtime 互操作标准 | MCP 跨 provider 标准成熟（当前各厂商各自为政） | 统一 Codex/Claude/Gemini 调用接口，简化框架层抽象 | 2026-2027 |

## 产品路线图

iSparto 的演进分三个阶段（详见 product-spec.md）：

```
v0.x  开发者工具      用户 = 开发者，手动触发流程
v1.x  自治开发团队    用户 = 技术负责人，给任务，团队自己跑
v2.x  CEO 工作台      用户 = 老板，说需求看结果，不碰过程
```

> **v1.x / v2.x planning lives elsewhere:** The v1.x autonomous-team vision and v2.x CEO-workstation vision are tracked in [`docs/roadmap.md`](roadmap.md), not in this file. `plan.md` stays focused on the current v0.x phase, active Waves, and near-term delivery gates. See `docs/roadmap.md` for long-range product capabilities.

---

### v0.x — 开发者工具（当前阶段）

**交付标准：一个没见过 iSparto 的 Claude Code 用户，看 README 就能装好、用起来、不找你问。**

| 里程碑 | 版本 | 标志 | 状态 |
|--------|------|------|------|
| 自用可靠 | v0.5 | 4 个 dogfooding 场景全部跑通 | ✅ v0.5.0 达成 |
| 架构加固 | v0.6 | Process Observer 全流量监管、角色-模型解耦、review 触发翻转 | ✅ v0.6.4 达成 |
| 外部可用 | v0.8 | 至少 1 个外部用户完整跑通，无需手把手指导 | 进行中 |
| 正式发布 | v1.0 | 稳定（连续版本无 hotfix）+ Getting Started 教程 + 基本 issue 响应机制 | — |

**v0.8 验收条件：**
- [x] 新用户入门修复（README Prerequisites、/init-project Next Steps、troubleshooting 安装问题）— PR #78
- [x] 代码关键修复（snapshot 路径编码+向后兼容、release.sh 跨平台、install.sh Python3 检查）— PR #78
- [x] 文档对齐（命令计数、术语统一、Solo Checklist）— PR #78
- [ ] 1 个外部用户冷启动验证（看 README → 安装 → /init-project → /start-working → /end-working 全流程）
- [x] 按角色独立配置模型 — v0.6.0 实现声明式角色-模型映射表（docs/configuration.md#agent-model-configuration），角色定义与模型名解耦。运行时自动切换留给 v1.x
- [x] User Preference Interface — memory/CLAUDE.md 领地分界、三级偏好模型、冲突协议、memory 写入规则、Plan Mode 自动触发
- [x] Process Observer 角色定义与文档 — 合规监督角色（实时拦截 hooks + 事后审计 sub-agent），docs/process-observer.md + 各文档集成
- [x] Process Observer hooks 实现 — PreToolUse hook shell 脚本，拦截高危操作
- [x] Process Observer 全流量监管 — Edit/Write 代码直写拦截 + Codex 结构化 prompt 强制 + 所有角色覆盖（Lead/Teammate/Doc Engineer）
- [x] Process Observer /end-working 集成 — end-working.md 中触发合规审计并输出偏差报告

**已完成：**（折叠）

<details>
<summary>v0.x 已完成项（点击展开）</summary>

- [x] README 实测效果章节（自举案例：Session Log 功能开发全流程）
- [x] 升级功能 — install.sh --upgrade + VERSION + CHANGELOG.md
- [x] CONTRIBUTING.md 贡献指南
- [x] GitHub Issues 模板优化
- [x] GitHub Issues #2 #3 标记为 Pro 付费功能
- [x] Doc Engineer 职责升级为三层
- [x] 全面文档审计（22 项修复，14 个文件）
- [x] Team Lead 角色增加"主动建议下一步"行为
- [x] install.sh --upgrade self-update
- [x] Solo + Codex 模式
- [x] Auto PR merge
- [x] GitHub Branch Protection
- [x] 减少用户审批门
- [x] Solo vs Agent Team 判断标准细化
- [x] isparto.sh exec 修复
- [x] 升级输出精简
- [x] Release 流程 — git tag + GitHub Releases + scripts/release.sh
- [x] Agent Team 模式扩展读任务
- [x] 全项目四视角 Review
- [x] 开源仓库清理
- [x] Codex 发现 bug 修复
- [x] 去伪存真精简

</details>

### Rejected Approaches

| Date | Module/Feature | What was tried | Why rejected | Notes |
|------|---------------|----------------|--------------|-------|
| 2026-03-30 | 框架全局 | 依赖层级强制（Types → Config → Service → UI） | 百万行代码库的需求；iSparto 目标用户项目通常 < 10 万行，过度工程化 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | 框架全局 | 周期性垃圾回收 | 百万行代码库 + 7 人团队的需求；solo founder 项目规模小，Wave 级 Codex review + QA 已足够 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | plan.md | Feature list 用 JSON 替代 Markdown | 无证据表明 AI 误删 plan.md 任务条目；先观察再决定 | 来源：Anthropic long-running agent harness。条件：如果实际使用中出现误删问题则重新评估 |
| 2026-03-30 | 框架全局 | 自动化 refactoring PR | 依赖 CI/CD 基础设施；solo founder 项目通常没有 | 来源：OpenAI Harness Engineering |
| 2026-03-30 | 框架全局 | Benchmark/Eval 集成 | 当前阶段不需要量化评估 harness 质量 | 来源：awesome list |
| 2026-04-01 | 框架全局 | Claude Code 10 项改进（commands frontmatter、路径作用域规则、hook if 过滤、统一 Tool(specifier) 语法、git worktree 隔离、prompt/agent hook 类型、plugin 打包、协调原语、deferred tool discovery、subagent 持久化 memory） | 独立开发者小项目不需要这些；当前 hook + tmux + CLAUDE.md 够用，没有实际痛点驱动 | 来源：anthropics/claude-code 仓库深度研究。条件：dogfooding 中遇到真实痛点时重新评估单项 |
| 2026-04-08 | 仓库结构 | P1 移动内部文件到 `.project/` 目录,与用户文档物理隔离 | 内部洁癖不是用户痛点；v0.8 外部用户验证门槛优先级更高,内部路径搬迁属于 churn。来源：Session #2 (2026-04-03) 仓库结构评估,当时挂在 plan.md 下一步,未推进 | 如果外部用户实际反馈 docs/ 布局困惑再重启 |
| 2026-04-08 | Onboarding 提醒 | plan.md 挂"本地 hook 更新提醒"长期项,督促用户运行 `install.sh --upgrade` | 僵尸提醒（来自 2026-04-03,经过 10 个版本已失效）；时效性提醒不属于 plan.md,应该进 CHANGELOG + /start-working hook 自修复 | 未来需要用户重装 hook 时用 CHANGELOG + /start-working 提示替代 |
| 2026-04-08 | 发布工具 | `scripts/macos-compat-check.sh` — 机械检查 shell 脚本里 BSD 不兼容的 sed 正则（来源：Session #b v0.7.0 BSD-sed 事故） | 单次事件的防御,缺乏模式证据；shellcheck 已免费提供很多 BSD/GNU 差异检查 | 如果再出一次同类 bug 就做；或者把 shellcheck 接进 language-check.sh pipeline |
| 2026-04-08 | 模板美观 | Framework Polish Round 2 的 Doc Engineer PASS WITH MINOR 两条模板对称性建议 | DE 自己说 non-blocking、safe to push；用户明确要求"一次搞完,不要 scope creep" | 只在具体用户反馈因为不对称造成困惑时重启；纯美学抛光永久 deferred |
