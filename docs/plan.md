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

### v0.7.4 — Information Layering Policy (2026-04-09) — ✅ Completed

**Wave-completion entry (2026-04-09):** T1–T5 delivered in Solo + Lead direct edit mode on branch `feat/v074-info-layering`, 13 files touched (2 new under `docs/design-principles/` + 11 modified). Acceptance script A1–A5 all passed (trivial-CLI carve-out, 5 bash commands exit-code determinate). Audit results: Doc Engineer 9/9 APPROVE, Process Observer 6/6 PASS with 0 deviations, Wave Boundary IR PROCEED with zero new findings. Principle 1 language-check surfaced 6 initial violations during A1 (4 quoted-literal cases rewritten to backticks, 2 "do-not-say" cases rephrased); re-run clean. T6 dogfood observation is post-merge and non-blocking.


Branch: `feat/v074-info-layering`. Mode: Solo + Lead direct edit (self-referential boundary — all target files are Tier 1 behavioral templates, Tier 2 reference docs, or Tier 4 historical artifacts; Framework Polish Round 2 precedent applies — 8 files, no code changes, no Developer/Codex calls).

Goal: Establish the Information Layering Policy as iSparto's runtime output rule. Core proposition: users are decision-makers, not observers. Every user-facing output must first be classified into A-layer (decision interruption, blocks user), B-layer (decision preparation, told at natural pause points), or C-layer (silent archive, never told). The Policy is enforced through command-template structural rewriting rather than pure runtime judgment — `/start-working`, `/end-working`, `/plan` output sections are rewritten to fixed B-layer briefing shapes so Lead's dynamic judgment only operates at word-choice level, not at "say or not / which facts to include" level.

Scope insight: The real delivery lives in T3 (command-template restructuring), not T1/T2 (Policy documents). The Policy documents are meta-rules serving future command additions; T3 is the structural change that ships value immediately.

Task list (T1-T5 execution + T6 post-merge dogfood + T10 close-out):

- [x] **T1 — `docs/design-principles/information-layering-policy.md` NEW (Tier 2, English).** Carries the 7-principle Policy body. Principle 3 amended from the original proposal: "IR only reviews A-layer judgments; B/C-layer judgments are Lead-autonomous" (addresses the 5-10x latency and cost objection from plan review). Principle 1 amended to list A-layer as 5 mechanically-identifiable trigger types: (a) Lead proposes a new plan requiring user confirmation; (b) Codex surfaces P0/P1 findings; (c) irreversible operation imminent (destructive git, migration, deletion); (d) IR requests script authorization (deep-IR gate); (e) Process Observer critical intercept. The 5-type enumeration closes the Lead-misclassification blind spot — Lead cannot miss an A-layer item unless it fits none of these 5 types, which is by construction the definition of "not A-layer".
- [x] **T2 — `docs/design-principles/conversation-style.md` NEW (Tier 2, English).** Carries the A-layer wording rule (standard template: "I plan to X, because Y. If you disagree, I can switch to Z. Continue?") and 3 before-after conversation samples: `/start-working`, `/plan` proposal presentation, `/end-working` final briefing. These become the reference illustrations for T3 command-template restructuring.
- [x] **T3 — Command-template structural rewrite (3 files).** `commands/start-working.md` Step 9 output directive rewritten from "Present all the above information" to an explicit B-layer briefing structure — one paragraph stating the one decision the user needs to make, one paragraph flagging items that affect that decision, and explicit preservation of the cross-session recovery surface (current Wave status, remaining issues from the last session, next active task) as protected B-layer content that C-layer silence rules must NOT touch. C-layer items silently logged not emitted are the implementation-level operational facts only: branch auto-create / rename, hook verification green, gh account auto-switch, health check green status, Process Observer arming, Doc Engineer idle state. `commands/end-working.md` final briefing similarly restructured to 3-5 sentences: what shipped today (referencing Wave completion if applicable) + what Codex caught + what's next. `commands/plan.md` proposal-presentation section augmented with the A-layer wording rule — plan proposals must present a recommendation with one alternative, never a multiple-choice menu. All three files add a `Reference: docs/design-principles/information-layering-policy.md` line at the top.
- [x] **T4 — `agents/independent-reviewer.md` role extension.** Existing "Wave Boundary Review" and "Phase 0 Review" procedures preserved verbatim. New section "A-layer Peer Review" added covering: invocation trigger (Lead classifies an output as A-layer per Policy Principle 1), independent judgment rule (IR re-reads relevant project artifacts and forms its own verdict, does not accept Lead's framing), tool permissions (read-only: read/grep/list/bash/MCP; never write), conflict-resolution rule (Lead vs IR disagreement → IR prevails, rationale documented in the Policy), regular IR vs deep IR trigger matrix (deep IR authorized to run scripts/tests/external queries only for security / architecture / irreversible-operation judgments).
- [x] **T5 — `CLAUDE.md` + `CLAUDE-TEMPLATE.md` + `CHANGELOG.md` + `docs/concepts.md` + `docs/design-decisions.md` sync.** Two deltas in each of CLAUDE.md and CLAUDE-TEMPLATE.md: (a) Documentation Index appended with `- Information Layering Policy -> docs/design-principles/information-layering-policy.md`; (b) after "Agent team memory write rules" in the User Preference Interface section, a new sub-paragraph: "Runtime output layering: see docs/design-principles/information-layering-policy.md. Lead must apply the Policy to every user-facing output before emitting it." NO migration, NO restructuring of existing sections. `docs/concepts.md` — add a new first-class concept section "Runtime Output Layering (A/B/C)" alongside Wave / Solo + Codex / Agent Team, introducing A-layer (decision interruption), B-layer (decision preparation at natural pause points), C-layer (silent archive) with a link to the Policy document. `docs/design-decisions.md` — add a new row capturing the "IR prevails on A-layer conflict" workflow decision (decision, rationale, alternatives considered, date 2026-04-09). `CHANGELOG.md` `[Unreleased]` entry: Added (Information Layering Policy + conversation-style guide + concepts.md A/B/C section + design-decisions row), Changed (/start-working, /end-working, /plan output behavior restructured per Policy), Meta (IR role extended to A-layer peer review). `VERSION` file NOT touched — version bump is handled by `/release`, not this plan.
- [ ] **T6 — Dogfood observation (post-merge, not blocking acceptance).** Next 3-5 /start-working + /end-working cycles after v0.7.4 merges. DaDalus records a qualitative note after each cycle ("quieter" / "still noisy" / "missed an important signal"). No quantitative metric — sample size is too small for statistics, and the feedback loop is DaDalus's felt experience, not a dashboard. If dogfood surfaces regressions, open `fix/v074-dogfood-*` branch for Policy or template adjustment. No fixed timeline.

**Acceptance script (5 Lead-direct bash commands — eligible under the trivial-CLI carve-out from CLAUDE.md Solo workflow step 3):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh` | exit 0, "Tier 1/Tier 2 are CJK-clean and Principle 1 is clean" | ✅ exit 0 after fixing 6 initial Principle 1 violations (switched 4 quoted-literal cases to backticks, rephrased 2 "do-not-say" cases) |
| A2 | `bash scripts/language-check.sh --self-test` | exit 0, Test 1 + Test 4 PASS | ✅ exit 0, Test 1 PASS, Test 4 PASS |
| A3 | `test -f docs/design-principles/information-layering-policy.md && test -f docs/design-principles/conversation-style.md` | exit 0 | ✅ exit 0 |
| A4 | `grep -l "information-layering-policy" commands/start-working.md commands/end-working.md commands/plan.md agents/independent-reviewer.md CLAUDE.md CLAUDE-TEMPLATE.md` | all 6 files listed | ✅ all 6 listed |
| A5 | `grep -q "v0.7.4" CHANGELOG.md && grep -q "v0.7.4" docs/plan.md` | exit 0 | ✅ exit 0 |

5 commands, all [code], all exit-code determinate, no build, no runtime, no output parsing → eligible under the trivial-CLI carve-out.

**Files to modify:**
- `docs/design-principles/information-layering-policy.md` (T1 — NEW)
- `docs/design-principles/conversation-style.md` (T2 — NEW)
- `commands/start-working.md` (T3)
- `commands/end-working.md` (T3)
- `commands/plan.md` (T3)
- `agents/independent-reviewer.md` (T4)
- `CLAUDE.md` (T5)
- `CLAUDE-TEMPLATE.md` (T5)
- `CHANGELOG.md` (T5)
- `docs/concepts.md` (T5)
- `docs/design-decisions.md` (T5)
- `docs/plan.md` (this entry + T10 close-out)

**IR Review Resolutions (from 2026-04-09 Wave-start review, verdict PROCEED with 3 actionables):**
1. **MAJOR #4 — Wave terminology conflict with product-spec Core Features.** Resolved by path (a): Wave is a state variable, not implementation noise. T3 + R4 updated to explicitly preserve Wave in user-facing briefing as protected B-layer content. The C-layer silence rule now applies only to implementation-level operational facts.
2. **MINOR #3 — Cross-session recovery surface preservation.** T3 `commands/start-working.md` Step 9 rewrite now explicitly carves out "current Wave status, remaining issues from the last session, next active task" as protected B-layer content. Verified at Wave-boundary IR by reading the rewritten Step 9 directive.
3. **MINOR #5 — IR-prevails single-voice delivery.** T4 `agents/independent-reviewer.md` A-layer Peer Review section specifies: IR delivers correction judgments through Lead (Lead re-emits the corrected A-layer output), not as a separate voice to the user. Single-voice rule prevents the user from needing to mediate Lead-vs-IR disagreement at runtime.

**Mode Selection Checkpoint.** Grouping: 8 framework files across 4 modules (design-principles/ new + commands/ + agents/ + root docs). Decomposable? T1 → T2 has weak ordering but T3 depends on T1+T2 being frozen (T3 references the Policy body). Parallelizing T1+T2 saves little and risks Policy-body divergence since T2 illustrates T1. File count × workload per file is not enough to justify coordination overhead. Decision: **Solo + Lead direct edit.**

**Why no Developer/Codex.** All target files are Tier 1 behavioral templates or Tier 2 reference docs or Tier 4 historical artifacts. Framework Polish Round 2 (2026-04-08) and Post-Wave 5 Follow-up Hotfixes (2026-04-08) precedents apply — markdown-only framework self-edits under the self-referential boundary. No architecture pre-review needed (this is an information-architecture change, not a code-architecture change). No Codex code review needed (no code). The only required audits are Independent Reviewer (pre-execution alignment review + post-execution Wave Boundary Review), Doc Engineer (9-item checklist including language-check.sh), and Process Observer (post-session audit).

**Independent Reviewer at Wave start (not only at Wave boundary).** Per /plan skill protocol, Lead spawns IR with the fixed prompt after plan approval but before task execution. IR reads this plan.md entry + relevant product-spec sections and verifies product-technical alignment. CRITICAL findings → pause and re-plan; PROCEED → start T1. A second IR invocation at Wave boundary (after T5 completes, before merge) verifies the implementation matches the plan.

**Risks:**
- **R1 — Lead runtime still dumps facts instead of applying the Policy in output.** Mitigation: T3 restructures command templates to fixed B-layer output shapes so the Policy is enforced structurally, not via Lead dynamic judgment at the "say or not" level. Dynamic judgment is narrowed to word choice.
- **R2 — A-layer trigger ambiguity causing IR to be over-triggered or under-triggered.** Mitigation: T1 Principle 1 enumerates 5 mechanically-identifiable A-layer types; IR invokes on checkbox match. Lead cannot misclassify unless the output fits none of the 5 types, which by construction defines "not A-layer".
- **R3 — CLAUDE.md small injection conflicts with existing User Preference Interface section.** Mitigation: T5 injection position is end of section (after "Agent team memory write rules") as a new sub-paragraph; no existing table, bullet, or rule is touched.
- **R4 — Collapsing Wave into silent C-layer would erase the cross-session recovery surface that product-spec.md Core Features relies on.** Resolution (IR-raised, accepted path a): Wave is a **state variable**, not **implementation noise**. The distinction is sharp — implementation noise (branch auto-create, hook verification green, gh auto-switch, health check green, Process Observer arming, Doc Engineer idle) can be silently logged because the user does not need it to make any decision; state variables (current Wave status, remaining issues from the last session, next active task) must survive into B-layer because they are exactly what the user needs to pick up a task across sessions. Mitigation: T3 explicitly carves out the cross-session recovery surface as protected B-layer content that C-layer silence rules must NOT touch. "Wave" is preserved everywhere: agents/ layer (internal concept), commands/*.md internal step descriptions (Step 0 BLOCKING marker, Step 2 Wave status read), Wave Boundary Review trigger semantics, AND user-facing briefing output. Only implementation-level operational facts are silenced.

**Post-merge polish candidate (v0.7.5 or next polish round):** Principle 5 in `docs/design-principles/information-layering-policy.md` pins structure-vs-word-choice scope but does not explicitly state the symmetric fact that dynamic layer-classification has been **totally** collapsed — Principle 1 allocates A-layer to 5 mechanical trigger types, Principle 2 allocates B-layer to 3 fixed pause points, the rest defaults to C-layer, so there is no residual surface where Lead "dynamically re-classifies" an output's layer. This is a latent reading gap: future readers (or Lead itself during a refactor) might invoke an implicit "dynamic classification" clause that does not exist. Proposed fix: append one sentence to Principle 5 — "This collapse is total: outside the three covered pause points there is no surface where Lead dynamically re-classifies; Principle 1 and Principle 2 have already allocated everything to mechanical triggers or the C-layer default." Non-blocking for v0.7.4; fold into the next framework polish round.

> ✅ **Delivered 2026-04-09** on branch `docs/principle5-total-collapse` — total-collapse paragraph appended to Principle 5 (three sentences: totality claim + scope enumeration of the three pause points, Principle 1 + Principle 2 + C-layer default exhaustion, "no fourth path where Lead decides a layer at runtime" closing clause). CHANGELOG `[Unreleased]` Changed entry added. Acceptance: `bash scripts/language-check.sh` clean (0/0/0). Mode: Solo + Lead direct edit (single-paragraph polish to a Tier 2 reference doc, framework self-referential boundary). Doc Engineer skipped per ad-hoc fix exception (no Wave entry closes, no code↔doc sync risk — the polish is a pure scope clarification inside the policy file itself and nothing else references Principle 5's specific wording).

### v0.7.5 — README Restraint Narrative (2026-04-09) — ✅ Completed

Branch: `feat/v075-readme-restraint`. Mode: Solo + Lead direct edit (Framework Polish precedent — all target files are Tier 1/2/3 framework self-edits under the self-referential boundary; zero code changes).

**Goal:** Redirect README narrative from "feature list" to "a self-restrained AI development team". v0.7.4 landed the Information Layering Policy (A/B/C, 7 principles, Principle 5 total-collapse) which made framework-internal output behavior 克制 — but this restraint does not yet surface in the reader-facing README. The two READMEs currently sit at 281 lines each and lead with role roster + tool comparison; readers learn features but miss that iSparto's core differentiation is restraint, not "more agents".

**Scope:** (1) Rewrite both READMEs under a ≤ 220-line soft budget, replacing the internal jargon (`Solo + Codex`, `Agent Team`, `Process Observer`) with user-perspective language and swapping the comparison exemplar from "single agent vs team" to "other tools dump CLAUDE.md context to the user; iSparto says only the one thing you must know". (2) Extract the self-bootstrapping case study and repository structure tree out of README into `docs/case-studies.md` and `docs/repo-structure.md` so README can stay focused on the restraint narrative. (3) Patch Policy Principle 2 with a static-by-default symmetry paragraph (pairs with Principle 5's total-collapse). (4) Add a `branch guard must precede first Edit/Write/Bash` checklist item to `agents/process-observer-audit.md` (closes PR 178's process deviation). (5) Create `docs/dogfood-log.md` with cycle #1 as the subjective evidence chain for the restraint narrative — README carries the pitch, dogfood-log carries the evidence.

**Task list (T1-T7 execution + T8 close-out):**

- [x] **T1 — README 双语重写 (`README.md` + `README.zh-CN.md`).** Target ≤ 220 lines each (current 281). New 10-section structure: Header → restraint pitch → scenario contrast (other tools dump CLAUDE.md, iSparto surfaces only the must-know line) → who it's for → install → quick start → role architecture → case-studies pointer → repo-structure pointer → origin of name + license. Forbidden vocabulary in README body: `Solo + Codex`, `Agent Team`, `Process Observer` — these are internal jargon and are pushed down into `docs/`. Chinese version MUST contain the anchor word 「克制」 at least once in pitch or heading (single voice principle — Policy terms 「A 层 / B 层 / C 层」 are NOT required in README and stay in `docs/`). **Result:** both READMEs landed at exactly 205 lines, all three forbidden words absent in both, 「克制」 appears 3 times in the Chinese version.
- [x] **T2 — `docs/case-studies.md` NEW (Tier 2, English).** Migrate the Session Log self-bootstrapping case from README lines 164-192 (8-step execution flow + metrics table: 2 parallel Developers, 1 Codex review round, 4 files, +45/-11 lines). File-head intro notes this is a growing case collection, v0.7.5 starts with Session Log, future Waves can extend. README section 8 points here with one sentence.
- [x] **T3 — `docs/repo-structure.md` NEW (Tier 2, English).** Migrate the ASCII repository tree from README lines 215-263 with per-entry annotations. File-head intro notes the repo structure evolves with Waves and this file is authoritative (not README). README section 9 points here with one sentence.
- [x] **T4 — `docs/design-principles/information-layering-policy.md` Principle 2 static-by-default patch.** Insert one paragraph after Principle 2's existing body (before Principle 3) stating that B-layer's "three pause points" are themselves static/pre-defined — not Lead runtime judgment, but fixed at command-template load time (`commands/start-working.md`, `commands/end-working.md`, `commands/plan.md`). Pairs symmetrically with Principle 5's total-collapse: A-layer entry bound by Principle 1's 5 mechanical triggers, B-layer entry bound by Principle 2's 3 pre-defined pause points, C-layer is the default, Lead has no "fourth path" to dynamically assign a layer. Duplication with Principle 5 is deliberate — Policy is meta document, skim-friendliness > DRY.
- [x] **T5 — `agents/process-observer-audit.md` checklist addition.** Add a new line to the Full Compliance Report checklist: "branch guard MUST precede the first Edit/Write/Bash modifying tool call. If the session's first modifying call occurs on main before switching to a feat/fix/hotfix branch, mark WARN." Closes PR 178's process deviation (Lead called Edit before the feat-branch checkout) at the audit layer. `docs/design-decisions.md` is NOT modified — the deviation closure lives in the PO checklist, which is sufficient. Landed as check **A3** in the audit checklist; PASS/WARN result distinction kept the rule advisory rather than failure-blocking, since PR-178-style sessions still produce mergeable work.
- [x] **T6 — Process Observer Layer 1 default-state grep (read-only, no modifications).** Grep `commands/init-project.md` and `commands/migrate.md` to confirm that Layer 1 (Write/Edit realtime content scanning) matcher is enabled by default in the `.claude/settings.json` hooks section these commands inject into new / migrated projects, no opt-in required. Secondary corroborating references: `hooks/process-observer/rules/workflow-rules.json`, `hooks/process-observer/scripts/pre-tool-check.sh`, `CLAUDE-TEMPLATE.md`, and `install.sh` (user-level Bash matcher registration around line 432, not authoritative for Write/Edit project-level injection). **Source of truth rule (corrected after IR Wave-start review):** the `commands/init-project.md` + `commands/migrate.md` project-level injection path is the single authoritative location for the Write/Edit default matcher — `install.sh` only registers the user-level Bash matcher and is NOT authoritative for Write/Edit. IR verified this by reading `install.sh` lines 420-479 (line 432 registers only `"$_hook_cmd" "Bash"` at user level; lines 424-425 and 440-441 explicitly defer Edit/Write/Codex to project-level `/init-project` and `/migrate`). If the primary injection path is ambiguous OR conflicts with the secondary references, record the conflict in this Wave entry and **do not fix** — open a separate `fix/po-layer1-default` branch (kept out of v0.7.5 scope for narrative-Wave boundary clarity).
  - **T6 grep findings (executed during this Wave):**
    - **Primary `commands/init-project.md` (lines 33-44):** unconditional registration of three matchers — `Edit`, `Write`, `mcp__codex-dev__codex` — each pointing at `bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh`. No `enabled` flag, no opt-in branch, no conditional. Layer 1 is **on by default** for every new project.
    - **Primary `commands/migrate.md` (lines 51-62):** identical unconditional registration of the same three matchers. Migration of an existing project lands in the same default-on state.
    - **Secondary `hooks/process-observer/scripts/pre-tool-check.sh`:** `grep -i 'enabled|opt.in|disabled'` returned no matches. There is no script-side toggle that can disable Layer 1 once the matcher fires.
    - **Secondary `hooks/process-observer/rules/workflow-rules.json`:** `grep "matcher"` returned no matches — this file does not register matchers; it only carries rule data consumed by the script. Not authoritative for default state.
    - **Secondary `CLAUDE-TEMPLATE.md`:** no PreToolUse / Edit / Write matcher block. The template generates project CLAUDE.md content, not `.claude/settings.json` hooks; hooks come from the two `commands/` files above.
    - **Secondary `install.sh` (lines 420-479):** comments at lines 423-425 explicitly state "Bash rules are universal and benefit all projects. Workflow hooks (Edit/Write/Codex) are registered at project level by /init-project and /migrate." Line 432 registers only `Bash` at user level. Lines 466-478 actively flag Edit/Write/Codex at user level as residue to be removed. install.sh's behavior is **consistent with** the primary-source designation, not in conflict with it.
    - **Conclusion:** No conflict found. Primary and secondary sources agree. Layer 1 (Write/Edit content scanning) is enabled by default for both new (`/init-project`) and migrated (`/migrate`) projects, requires no user opt-in, and has no programmatic disable path. T6 done; no `fix/po-layer1-default` branch needed.
- [x] **T7 — `docs/dogfood-log.md` NEW (Tier 4, Chinese).** File-head intro: this is a subjective-feeling log for each Wave or major session, no quantitative KPI, not a benchmark. Cycle #1 entry records whether the v0.7.4 Principle 5 total-collapse landing and the v0.7.5 Wave itself produced a "quieter" session — Lead dumping less context to the user, user interruptions concentrated on A-layer decisions, B-layer briefings confined to the three pause points, C-layer genuinely silent. Ends with open questions for next cycle. Purpose: the README restraint narrative (T1) carries the pitch; dogfood-log carries the subjective evidence chain. Together they form pitch + evidence closure. Cycle #1 also recorded the open questions (read-feedback on the word 「克制」, irreversible-operation Wave stress test, dogfood-log self-bloat risk, IR pre-execution catch rate) that the next cycle will close. `scripts/language-check.sh` `TIER2_EXCLUDED_FILES` updated to add `docs/dogfood-log.md` so the Chinese cycle entries do not trip the Tier 2 CJK guardian.
- [x] **T8 — Wave close-out.** Sequence: (1) tick T1-T7 checkboxes here + append commit hash list + acceptance results; (2) update `CHANGELOG.md` `[Unreleased]` with v0.7.5 entry; (3) spawn Independent Reviewer as Teammate for Wave Boundary Review (fixed prompt + "This is a Wave Boundary Review."), wait for report, CRITICAL → next-session TODO non-blocking, MAJOR/MINOR → Lead autonomous; (4) write IR Resolutions sub-section into this Wave entry (if any); (5) write the `🚨 BLOCKING: Next Wave requires NEW SESSION` marker immediately after this Wave entry (including IR Resolutions); (6) Doc Engineer audit (sub-agent, full run, zero inherited context); (7) Process Observer post-session audit (sub-agent); (8) `gh pr create` → merge → clean up feat branch. **Delivered 2026-04-09** via squash commit `3aa3b65` (PR #183, merge commit `14128b6`). Commit count: 1 non-merge (measured by `git log --oneline --no-merges 89f1e27..3aa3b65`). Post-merge re-verification on local main (2026-04-09 after the phantom-merge false alarm): A1-A5 all PASS + `language-check.sh --self-test` clean. Wave header and this checkbox left as stale bookkeeping by the PR #183 /end-working run; closed here on branch `docs/v075-closeout` immediately before `/release 0.7.5`.

**Acceptance script (5 Lead-direct bash commands — eligible under the trivial-CLI carve-out from CLAUDE.md Solo workflow step 3):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | exit 0 / exit 0 — PASS |
| A2 | `test -f docs/case-studies.md && test -f docs/repo-structure.md && test -f docs/dogfood-log.md` | exit 0 | exit 0 — PASS |
| A3 | `[ $(wc -l < README.md) -le 220 ] && [ $(wc -l < README.zh-CN.md) -le 220 ] && ! grep -q 'Solo + Codex' README.md && ! grep -q 'Agent Team' README.md && ! grep -q 'Process Observer' README.md && ! grep -q 'Solo + Codex' README.zh-CN.md && ! grep -q 'Agent Team' README.zh-CN.md && ! grep -q 'Process Observer' README.zh-CN.md` | all exit 0 | exit 0 — PASS (both READMEs at 205 lines, all 6 forbidden-word checks negative) |
| A4 | `grep -q '克制' README.zh-CN.md` | exit 0 | exit 0 — PASS (3 occurrences) |
| A5 | `grep -q 'static' docs/design-principles/information-layering-policy.md && grep -q 'branch guard' agents/process-observer-audit.md && grep -q '0.7.5' CHANGELOG.md` | all exit 0 | exit 0 — PASS (Policy Principle 2 patch / PO checklist A3 / CHANGELOG v0.7.5 entry all present) |

5 commands, all [code], all exit-code determinate, no build, no runtime, no output parsing → eligible under the trivial-CLI carve-out.

**Files to modify:**
- `README.md` (T1 — rewrite, ≤ 220 lines)
- `README.zh-CN.md` (T1 — rewrite, ≤ 220 lines)
- `docs/case-studies.md` (T2 — NEW, Tier 2 English)
- `docs/repo-structure.md` (T3 — NEW, Tier 2 English)
- `docs/dogfood-log.md` (T7 — NEW, Tier 4 Chinese)
- `docs/design-principles/information-layering-policy.md` (T4 — Principle 2 patch)
- `agents/process-observer-audit.md` (T5 — checklist addition)
- `docs/plan.md` (this entry + T8 close-out)
- `CHANGELOG.md` (T8 — `[Unreleased]` v0.7.5 entry)

**Mode Selection Checkpoint.** Grouping: 9 markdown files across 4 modules (root READMEs + docs/ + agents/ + docs/design-principles/). Decomposable? T2/T3 are the ingredients for T1's pointer sections — T1 depends on T2/T3 being frozen. T4-T7 are independent of each other and of T1-T3. File count × workload per file is modest (T1 is the largest, ~400 lines of double-language rewrite; T4/T5 are single-paragraph/single-line additions; T6 is read-only grep). Teammate coordination overhead would exceed serial cost given the T1 ← T2/T3 dependency. Decision: **Solo + Lead direct edit.**

**Why no Developer/Codex.** All target files are Tier 1 behavioral templates (`agents/process-observer-audit.md`), Tier 2 reference docs, Tier 3 user-facing entry (READMEs), or Tier 4 historical artifacts (`docs/plan.md`, `CHANGELOG.md`, `docs/dogfood-log.md`). Framework Polish / v0.7.4 precedents apply — markdown-only framework self-edits under the self-referential boundary. No architecture pre-review needed (narrative-only change, not an architecture change). No Codex code review needed (no code). Required audits: Independent Reviewer (Wave-start alignment + Wave-boundary review), Doc Engineer (full 9-item checklist), Process Observer (post-session audit).

**Independent Reviewer at Wave start.** Per /plan skill protocol, Lead spawns IR with the fixed prompt after plan approval but before T1 execution. IR reads this plan.md entry + current README.md / README.zh-CN.md / Policy / PO audit definition and verifies that the narrative pivot, the file extractions, the Principle 2 symmetry patch, and the PO checklist closure are coherent with product-spec. CRITICAL findings → pause and re-plan; PROCEED → start T1. A second IR invocation at Wave boundary (after T7, before merge) verifies the implementation matches the plan.

**Risks:**
- **R1 — README restraint narrative may fail to communicate "restraint is a value, not a gap".** Mitigation: T7 `docs/dogfood-log.md` cycle #1 records the "quieter session" subjective evidence — README carries the pitch, dogfood-log carries the evidence, the two together close the claim-evidence loop. If dogfood cycle #1 reveals the README pitch is unconvincing, v0.7.6 can adjust the wording based on that feedback.
- **R2 — BLOCKING marker is technically non-mandatory for this Wave.** The Wave touches only one Tier 1 file (`agents/process-observer-audit.md`), which is loaded at sub-agent spawn (not cached by Lead across the session), so strictly no cross-session staleness risk. User explicit decision: treat v0.7.5 as an independent Wave because README is the user-facing critical file; the cost of degrading IR Wave Boundary Review outweighs the 1-line BLOCKING marker cost.
- **R3 — Acceptance compressed to 5 rows makes A3 semantically dense (wc + 3 forbidden-word greps in one row).** Mitigation: A3 uses shell short-circuit so any sub-condition failure surfaces the specific problem immediately; A4 is already reduced to a single 1-word grep (anchor `克制`), eliminating ambiguity. If A3 shell expression becomes hard to read during execution, plan.md can record it as 4 diagnostic lines while still counting as 1 against the 5-row trivial-CLI budget.

**IR Resolutions (Wave-start + Wave-boundary, recorded after IR runs):**
- **Wave-start (CRITICAL, resolved before T1 execution).** IR found `grep -Eq 'Solo \+ Codex\|Agent Team\|Process Observer'` in the original A3 row was silently broken — under `-E` mode the backslash-escaped `\|` is a literal pipe character, not an alternation operator, so the chain would have always passed regardless of whether T1 actually removed any forbidden vocabulary. **Resolution:** A3 was rewritten to six independent `! grep -q '<word>' <file>` clauses (3 forbidden words × 2 READMEs). Each failure now diagnoses a specific missing word/file pair. Verified by direct execution (exit 0 on the corrected READMEs).
- **Wave-start (MAJOR, resolved before T1 execution).** IR identified that the original T6 source-of-truth designation inverted the actual injection topology. `install.sh` only registers the user-level `Bash` matcher (line 432); the `Edit`/`Write`/`mcp__codex-dev__codex` matchers are deferred to project-level `commands/init-project.md` and `commands/migrate.md`. **Resolution:** T6 description rewritten to designate the two `commands/` files as primary source-of-truth, with `install.sh` downgraded to secondary corroborating reference. T6 grep findings (recorded above) confirm primary and secondary sources agree — no conflict, no `fix/po-layer1-default` branch needed.
- **Wave-boundary (1 MINOR, Lead-autonomous).** IR noted additive structural drift in the final READMEs: two section pointers were preserved beyond the plan's 10-section specification — a Dogfood Log pointer (closing the pitch's claim-evidence loop with `docs/dogfood-log.md`) and the Getting Started Checklist (carried over from the prior README as a compact action summary). **Lead-autonomous resolution:** keep both. The Dogfood Log pointer is the structural complement of T7's purpose statement (pitch + evidence form a loop only if the README links to the evidence). The Getting Started Checklist is reader-actionable, fits inside the 220-line budget, and reintroduces no forbidden vocabulary. Both additions are non-jargon, reader-perspective, and consistent with the restraint narrative. Recorded here as drift-from-plan for v0.7.6 / next Wave's plan-fidelity audit, but no rework required for v0.7.5 merge. Zero CRITICAL, zero MAJOR.

🚨 BLOCKING: Next Wave requires NEW SESSION
> ✅ Session boundary acknowledged 2026-04-09 by /start-working
> ✅ Session boundary acknowledged 2026-04-10 by /start-working
> ✅ Session boundary acknowledged 2026-04-17 by /start-working

### IR Token Cost Documentation Wave (2026-04-10) — Complete

Branch: `feat/ir-token-doc-wave`. Mode: Solo (T8a via Developer/Codex for SVG coordinate work, all other tasks Lead direct edit under self-referential boundary).

**Goal:** Surface the Independent Reviewer's token cost impact across documentation and the architecture diagram. Root cause: the README architecture diagram (`assets/role-architecture.svg` / `assets/role-architecture-zh.svg`) showed only 4 nodes (USER → Lead+Doc Engineer → Teammate + Developer) while IR appears at runtime as a first-class role. Secondary gap: IR is the most token-intensive role per invocation (Opus, zero inherited context, 3 trigger modes) but this cost impact had only one sentence in the entire codebase (information-layering-policy.md Principle 3).

Principle: diagram first, then text. T8a (architecture diagram) is highest priority because it fixes the root mismatch between what users see and what actually runs.

**Task list:**

- [x] **T8a — `assets/role-architecture.svg` + `assets/role-architecture-zh.svg`: Add IR node.** Bottom row rearranged from 2-card (width=400) to 3-card (width=270): TEAMMATE left, INDEPENDENT REVIEWER center, DEVELOPER right. IR card uses dashed border (`stroke-dasharray="8,4"`) and dashed connection line from Lead — visually encodes "zero context inheritance". viewBox kept at 1100×640. ZH version follows established convention: title stays English ("INDEPENDENT REVIEWER"), subtitle Chinese ("独立队友 · 零上下文继承"), description mixed ("Phase 0 · Wave 边界 · A 层同行审查"). Via Developer (Codex) — SVG is coordinate-precise markup.
- [x] **T8b — `docs/workflow.md`: IR trigger sequence diagram.** Added mermaid `timeline` diagram as a new subsection "### Independent Reviewer — Trigger Points across the Wave Lifecycle" near the top of the file. Three timeline sections: Phase 0 (full spec review), Wave Development (A-layer Peer Review per decision-interrupt), Wave Close-out (Wave Boundary Review, scope-limited).
- [x] **T1 — `docs/configuration.md`: IR row rationale + Token Budget Awareness subsection.** Extended IR row rationale (line 57) with Opus justification and token-cost forward-pointer. Added `### Token Budget Awareness` subsection with 5-column table showing two consumption dimensions (per-invocation and cumulative per Wave). IR: Highest per-call / Medium cumulative; Developer: High per-call / Highest cumulative. Actionable guidance: frequent `/compact` → run `/end-working`. Cross-reference to Information Layering Policy Principle 3.
- [x] **T2 — `docs/design-decisions.md`: Opus cost tradeoff row.** New row after existing IR rows: "Independent Reviewer model choice | claude-opus-4-6 rather than Sonnet | IR's alignment-detection task has no structural backstop — PO Audit's checklist-verification is backstopped by Hooks core layer, so Sonnet suffices there."
- [x] **T3 — `docs/concepts.md`: IR Quick Reference row.** Inserted after "Agent Team" row. Explanation ≤35 words. Analogy: "Blind peer reviewer in academic publishing — reads the paper fresh, without the authors' cover letter."
- [x] **T4 — `docs/user-guide.md`: Token Budget Awareness section.** Two paragraphs between "What You Should Focus On" and "Your Preferences and the Agent Team": (1) when IR triggers + link to workflow.md timeline diagram; (2) context pressure mitigation + link to configuration.md#token-budget-awareness.
- [x] **T5 — `docs/workflow.md`: Token annotation at first occurrence.** Line 34 only: appended "most token-intensive role per invocation" to the Phase 0 IR description. Lines 116 and 168 (Solo/Agent Team blocks) left unchanged — T8b diagram carries the message.
- [x] **T7 — `docs/plan.md`: This Wave entry.**

**Acceptance script (9 commands — A1 under trivial-CLI carve-out, A2-A9 are grep existence checks):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | ✅ exit 0 / exit 0 |
| A2 | `grep -q 'Token Budget Awareness' docs/configuration.md` | exit 0 | ✅ exit 0 |
| A3 | `grep -q 'Independent Reviewer model choice' docs/design-decisions.md` | exit 0 | ✅ exit 0 |
| A4 | `grep -q 'Independent Reviewer' docs/concepts.md` | exit 0 | ✅ exit 0 |
| A5 | `grep -q 'token-budget-awareness' docs/user-guide.md` | exit 0 | ✅ exit 0 |
| A6 | `grep -q 'INDEPENDENT REVIEWER' assets/role-architecture.svg && grep -q 'INDEPENDENT REVIEWER' assets/role-architecture-zh.svg` | both exit 0 | ✅ exit 0 |
| A7 | `awk '/^```mermaid$/,/^```$/' docs/workflow.md \| grep -q 'timeline' && awk '/^```mermaid$/,/^```$/' docs/workflow.md \| grep -q 'Phase 0' && awk '/^```mermaid$/,/^```$/' docs/workflow.md \| grep -q 'Wave Boundary' && awk '/^```mermaid$/,/^```$/' docs/workflow.md \| grep -q 'A-layer'` | all 4 checks pass | ✅ exit 0 |
| A8 | `grep -c 'INDEPENDENT REVIEWER' assets/role-architecture.svg` = `grep -c 'INDEPENDENT REVIEWER' assets/role-architecture-zh.svg` | counts match | ✅ 3 = 3 |
| A9 | `grep -q 'TEAMMATE' assets/role-architecture.svg && grep -q 'DEVELOPER' assets/role-architecture.svg && grep -q 'INDEPENDENT REVIEWER' assets/role-architecture.svg` | exit 0 (repeat for ZH) | ✅ exit 0 (both EN and ZH) |

**Files modified (8):**
- `assets/role-architecture.svg` (T8a — IR node added, 3-column layout)
- `assets/role-architecture-zh.svg` (T8a — IR node added, 3-column layout, Chinese subtitles)
- `docs/workflow.md` (T8b + T5 — mermaid timeline diagram + first-occurrence token annotation)
- `docs/configuration.md` (T1 — IR row rationale extension + Token Budget Awareness subsection)
- `docs/design-decisions.md` (T2 — Opus cost tradeoff row)
- `docs/concepts.md` (T3 — IR Quick Reference row)
- `docs/user-guide.md` (T4 — Token Budget Awareness section)
- `docs/plan.md` (T7 — this entry)

**Mode Selection Checkpoint.** Grouping: 8 files across 4 modules (Assets, Framework Docs, Project Docs). Decomposable? T8a (SVG) is independent of T1-T5 (markdown); T1-T5 are independent of each other. Sufficient volume? T8a requires Developer for coordinate layout; T1-T5 are small targeted edits. Agent Team coordination overhead exceeds serial cost. Decision: **Solo**. T8a via Developer (Codex), all others Lead direct edit.

**Why Lead direct edit for markdown tasks:** All markdown target files are Tier 2 reference docs (`docs/*.md`). Framework self-referential boundary applies — markdown-only additions to existing documentation under the self-referential boundary. v0.7.4 and v0.7.5 precedents apply.

**Why no BLOCKING marker:** No Tier 1 system prompt files modified. All changes are Tier 2 reference docs (read by IR at spawn time from fresh context) or visual assets (never loaded into conversation context). Next session may begin without cross-session barrier.

**Why no Independent Reviewer:** Not a Wave boundary in the i18n/framework-polish sense — this is a documentation gap-fill for an already-shipped role. Scope is additive text + diagram only, no behavioral or architectural change. Doc Engineer and Process Observer audits are sufficient. Precedent: Post-Wave 5 Follow-up Hotfixes, Framework Polish Round 2.

### Wave A — Concept Decoupling (2026-04-17) — Complete

Branch: `feat/wave-a-concept-decoupling`. Mode: Solo + Lead direct edit (all 7 target files are Tier 1 system prompts, Tier 2 reference docs, or Tier 4 project docs under the self-referential boundary; no code files, no Developer/Codex calls).

Source plan: `~/.claude/plans/lovely-munching-hopper.md` (v2.4, approved 2026-04-17 after v1 → v2 → v2.1 → v2.2 → v2.3 → v2.4 review cycle). Wave A is the first of two Waves in that plan; Wave B (docs layer dedup) is scheduled for a separate session.

**Goal:** Execute Wave A — concept decoupling across `CLAUDE.md` and `agents/independent-reviewer.md`. The headline architectural move is A1 (extracting A-layer Peer Review into its own Tier 2 design-principle file); A2-A4 are supporting pointer + index work that rides on the same extraction discipline. Expected context savings: CLAUDE.md from ~208 lines to ~120 lines, cutting ~90 lines per new-session load.

**Task list:**

- [x] **A1 — Extract A-layer Peer Review (Mode 3) from `agents/independent-reviewer.md` to new `docs/design-principles/a-layer-peer-review.md`.** Original agent file dropped from 214 → 109 lines (-105), now focused on Phase 0 + Wave Boundary review modes only. New file at 124 lines, Tier 2, stands alone as a design-principle document covering invocation trigger, tool permissions (read-only + deep-IR gate), four judgment axes, verdict format, conflict-resolution, and scope. Cross-references in `CLAUDE.md §User Preference Interface`, `CLAUDE-TEMPLATE.md`, and `docs/design-decisions.md` row "Information Layering Policy — IR prevails…" updated to the new path. Commit: `e002fba`.
- [x] **A2 — Extract Collaboration Mode from `CLAUDE.md` to new `docs/collaboration-mode.md`.** New Tier 2 file with required `## Overview` and `## Lifecycle` headings (A3 depends on the `## Lifecycle` anchor). Preserves verbatim: Mode Selection Checkpoint, Plan Mode triggers, Roles, Lifecycle Solo + Codex / Agent Team, Implementation Protocol, Branch Protocol, Developer Triggers, Branching and Merge. CLAUDE.md Collaboration Mode section shrunk to 1 pointer + 1 iSparto-specific exception note. `CLAUDE-TEMPLATE.md` intentionally unchanged per plan decision D1 = B1 (user projects keep inline content for open-box usability; the sync burden vs `docs/collaboration-mode.md` remains at today's level, and the real value of B1 is iSparto's own CLAUDE.md context savings). Commit: `8e08630`.
- [x] **A3 — Shrink CLAUDE.md Development Workflow overview to a pointer.** The pre-refactor `Development Workflow (Solo + Codex)` / `(Agent Team)` overviews were a third-place repetition of lifecycle steps already defined in `commands/start-working.md` and `commands/end-working.md`. Replaced with a single pointer line: `See docs/collaboration-mode.md §Lifecycle for workflow phases; step-level execution in commands/start-working.md and commands/end-working.md`. Subsumed into the A2 commit. Commit: `8e08630`.
- [x] **A4 — Update CLAUDE.md Documentation Index and Tier 2 definition.** Located by heading, not line number (A2/A3 shifted line numbers). `## Documentation Index` gained two entries (`docs/collaboration-mode.md`, `docs/design-principles/a-layer-peer-review.md`). `## Documentation Language Convention` Tier 2 line explicitly includes `docs/design-principles/*.md` subdirectory so the `scripts/language-check.sh` maintainer does not later misclassify new files under that path. Module Boundaries promoted from `**bold**` subsection to `## Module Boundaries` (it stands alone as iSparto-specific architecture, not tied to collaboration semantics). Commit: `8e08630`.

**Acceptance script (3 Lead-direct bash commands — eligible under the trivial-CLI carve-out from the Solo lifecycle step 3):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh --self-test && bash scripts/language-check.sh` | both exit 0 | exit 0 / exit 0 — PASS |
| A2 | `./install.sh --dry-run` | exit 0, all commands + templates up to date, Codex MCP OK | exit 0 — PASS |
| A3 | `wc -l CLAUDE.md` (target ~120) + `grep -n "^## Overview\|^## Lifecycle" docs/collaboration-mode.md` (each 1 hit) | CLAUDE.md ≤ 130 + both headings present | 124 lines / Overview line 3 + Lifecycle line 43 — PASS |

3 commands, all [code], all exit-code determinate, no build, no runtime, no output parsing → eligible under the trivial-CLI carve-out.

**Mode Selection Checkpoint.** Grouping: 7 files across 3 modules (Tier 1 system prompts: `CLAUDE.md` / `CLAUDE-TEMPLATE.md` / `agents/independent-reviewer.md`; Tier 2 framework docs: `docs/collaboration-mode.md` / `docs/design-principles/a-layer-peer-review.md` / `docs/design-decisions.md`; Tier 4 project doc: `docs/plan.md`). Decomposable? A1 independent of A2/A3/A4; A2/A3/A4 mutually dependent (A3 points into A2's new `## Lifecycle`, A4 indexes both A1 and A2 outputs). File count × workload per file is modest; the Agent Team coordination overhead would exceed serial cost given the A2↔A3↔A4 dependency chain. Decision: **Solo + Lead direct edit**.

**Why Lead direct edit:** All target files are Tier 1 system prompts, Tier 2 reference docs, or Tier 4 project doc. Framework self-referential boundary applies (CLAUDE.md Development Rules). No code files, no Developer/Codex calls. Precedents: v0.7.4 Information Layering Policy Wave, v0.7.5 README restraint Wave, IR Token Cost Documentation Wave.

**Commit count verification:** 2 non-merge commits on the Wave A branch (`git log --oneline --no-merges c0c6914..HEAD | wc -l` = 2).

**Why no Independent Reviewer at Wave boundary:** Precedent chain — Framework Polish Round 2 (Session #c 2026-04-08), Post-Wave 5 Follow-up Hotfixes, IR Token Cost Documentation Wave. Wave A is a framework-self-referential refactor that preserves content verbatim (the extracted paragraphs are byte-identical to the pre-refactor originals per Doc Engineer spot checks). No new product behavior, no architecture change, no new rules. Doc Engineer audit (GREEN, 9/9 PASS) + Process Observer audit (10/12 PASS, 1 IN-PROGRESS resolved by the precedent above, 1 WARN resolved by this plan.md entry) are sufficient.

**Doc Engineer audit results (GREEN):** 9/9 PASS. Cross-references clean, pointers valid, content preserved verbatim across the three spot-checked sections (Mode Selection Checkpoint, Implementation Protocol steps, Four Judgment Axes all byte-identical except for one intentional "above" → "below" preposition flip reflecting the new relative position). Tier boundaries respected (Tier 1 agent definition remains on agents/, Tier 2 design principle lives in docs/design-principles/). CLAUDE-TEMPLATE.md regression-free (182 lines, -1 for the single reference update). Language-check clean.

**Process Observer audit results:** 10/12 PASS, 1 IN-PROGRESS (F1 — IR at Wave boundary; resolved by the Why-no-Independent-Reviewer rationale above), 1 WARN (C2 — plan.md Wave A entry missing; resolved by this entry). No Framework-side rule corrections suggested.

**BLOCKING marker rationale for next Wave:** Wave A modified two Tier 1 system prompts (`CLAUDE.md`, `CLAUDE-TEMPLATE.md`) that are cached into every new Claude Code session's context. A fresh session is required so the next Wave's Lead reads the new pointer-based Collaboration Mode section (not a stale inline block). Marker emitted below.

**Next step:** Wave B of the same plan — `docs/` layer dedup across `concepts.md` / `roles.md` / `workflow.md` / `configuration.md` / `user-guide.md` / `design-decisions.md`. Separate session, separate branch (`feat/wave-b-docs-dedup`), separate PR per plan v2.4. Pointer standard and TL;DR ≤ 30 字 hard constraints already fixed in the source plan.

🚨 BLOCKING: Next Wave requires NEW SESSION
> ✅ Session boundary acknowledged 2026-04-17 by /start-working

### Wave B — docs 层 dedup (2026-04-17) — Complete

Branch: `feat/wave-b-docs-dedup`. Mode: Solo + Lead direct edit (all target files are Tier 2 reference documentation under the self-referential boundary; no code files, no Developer/Codex calls).

Source plan: `~/.claude/plans/lovely-munching-hopper.md` (v2.4, approved 2026-04-17). Wave B is the second of two Waves in that plan; Wave A (concept decoupling) completed earlier the same day.

**Goal:** Execute Wave B — cross-file rule dedup across `docs/concepts.md` / `docs/roles.md` / `docs/workflow.md` / `docs/configuration.md` / `docs/user-guide.md` / `docs/design-decisions.md`. Every rule keeps one authoritative location; other locations replaced with standardized `TL;DR + pointer` blocks per plan v2.4's four hard constraints (TL;DR ≤ 30 字, no specific values/paths in TL;DR, anchor must resolve to actual `##`/`###` heading, markdown-link syntax `See [path](path) §anchor`).

**Task list:**

- [x] **B1 — Wave Parallelism rule consolidation.** Authority: `docs/concepts.md §Wave Parallelism` (renamed from "The Most Critical Concept: Decoupling" so the anchor is a single-concept heading; "the framework's most critical concept" framing preserved in the opening sentence). `docs/roles.md` Team Lead system prompt: first "First assess decoupling..." bullet replaced with `**Wave Parallelism**: Wave-level parallelism requires file ownership plus interface contracts. See [concepts.md](concepts.md) §Wave Parallelism for the full rule.`; the four remaining operational bullets (file-ownership assignment / interface-contract timing / shared-file sequencing / context-capacity estimate) kept verbatim because they are actions the Lead must take, not restatements of the concept. `docs/workflow.md`: new pointer block added at the top of `## Collaboration Mode Selection` (the pre-existing "Decomposable | Sufficient volume" table kept intact — it is mode-selection criteria, not a Wave Parallelism restatement). Honest note: workflow.md has no paragraph-sized Wave Parallelism restatement to replace — the plan's "相应段落 → pointer" assumption under-fits the file's actual structure, so B1's workflow.md edit is a supplementary pointer (+2 lines) rather than a replacement.
- [x] **B2 — Developer prompt template pointer consolidation.** Authority: `docs/roles.md §Developer (Codex MCP Call)` (the plan's `§Developer Prompt Templates` shorthand — actual heading kept as-is; templates live inside the Developer role's system-prompt code block, no sub-heading refactor warranted). `docs/workflow.md §Developer (Codex) Integration` pre-existing blockquote pointer converted to plan-standard format: `**Developer Prompt Templates**: Lead assembles Developer prompts with plan anchors and file ownership scope. See [roles.md](roles.md) §Developer (Codex MCP Call) for the full templates.` Scenario → timing table (Architecture pre-review / Implementation / QA) kept — it is scenario-timing mapping unique to workflow.md, not a prompt-template restatement.
- [x] **B3 — Model Assignment table pointer.** Authority: `docs/configuration.md §Agent Model Configuration` (the plan's `§Model Assignment` shorthand). `docs/roles.md §Developer (Codex MCP Call)` — four model-related bullets consolidated to three: one `**Model Assignment**: Each role uses a designated model with effort level. See [configuration.md](configuration.md) §Agent Model Configuration for the full table.` (replaces the two redundant "see config.md table" pointers), plus the two unique caveats kept inline (review-tool lacks reasoningEffort, Fast mode unavailable via MCP). `roles.md` line 32's architecture-overview pointer left unchanged — it is already a one-liner pointer, not a restatement block.
- [x] **B4 — User Preference Interface differentiated handling.** Authority (how): `CLAUDE.md §User Preference Interface` preserved unchanged. `docs/user-guide.md` "Your Preferences and the Agent Team" section — three-bullet restatement (habits respected / workflow rules win / edit CLAUDE.md to change workflow) replaced with `**User Preference Interface**: Three response levels — immediate, discuss-first, record-only. See [CLAUDE.md](../CLAUDE.md) §User Preference Interface for the full rule.` One user-friendly intro sentence kept for tier-2 reader context. `docs/design-decisions.md` row 34 — **pre-check result: skip, do not modify.** The row is a decision-record table entry (Decision column = what was decided: territory-based boundary + three-level model; Rationale column = why: memory rules may silently contradict workflow rules without explicit boundaries). It is already a decision statement (why this exists), not a CLAUDE.md how-it-works restatement — per plan v2.4's B4 pre-check rule, skip.

**Acceptance script (3 Lead-direct bash commands — eligible under the trivial-CLI carve-out from the Solo lifecycle step 3):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | exit 0 / exit 0 — PASS |
| A2 | `./install.sh --dry-run` | exit 0, all commands + templates up to date | exit 0 — PASS |
| A3 | `grep -n "See \[.*\](.*\.md) §" docs/roles.md docs/workflow.md docs/user-guide.md \| wc -l` (all B1-B4 pointers in plan format) + anchor existence greps for concepts.md §Wave Parallelism / configuration.md §Agent Model Configuration / roles.md §Developer (Codex MCP Call) / CLAUDE.md §User Preference Interface | 5 pointers + 4 anchors = 1 each | 5 pointers / each anchor count = 1 — PASS |

3 commands, all [code], all exit-code determinate, no build, no runtime, no output parsing → eligible under the trivial-CLI carve-out.

**Files modified (5):**
- `docs/concepts.md` (B1 — heading rename + opening-sentence adjustment; content preserved verbatim)
- `docs/roles.md` (B1 — Team Lead decoupling bullet → pointer; B3 — Model Assignment pointer consolidation)
- `docs/workflow.md` (B1 — Wave Parallelism supplementary pointer; B2 — Developer Prompt Templates pointer standardization)
- `docs/user-guide.md` (B4 — User Preference Interface restatement → pointer)
- `docs/plan.md` (this entry + session-boundary acknowledgement from /start-working Step 0)

**Mode Selection Checkpoint.** Grouping: 5 files across Framework Docs module only. Decomposable? B1/B2/B3/B4 independent of each other (each targets different heading/section). File count × workload per file is modest (each edit ≤ 10 lines). Teammate coordination overhead would exceed serial cost — 5 small targeted edits run faster serially than with Teammate spawn + coordination. Decision: **Solo + Lead direct edit**. Same precedent chain as Wave A.

**Why Lead direct edit:** All target files are Tier 2 reference documentation under the framework self-referential boundary (CLAUDE.md Development Rules). No code files, no Developer/Codex calls. Precedents: Wave A, IR Token Cost Documentation Wave, v0.7.5 README Restraint Wave, v0.7.4 Information Layering Policy Wave.

**Commit count verification:** 1 non-merge commit on the Wave B branch (`git log --oneline --no-merges cdbe08a..HEAD | wc -l` = 1). Base `cdbe08a` is the Wave A merge commit (PR #204).

**Why no Independent Reviewer at Wave boundary:** Same precedent chain as Wave A — framework-self-referential refactor preserving content verbatim at the authoritative sources (concepts.md / roles.md / configuration.md / CLAUDE.md §User Preference Interface all untouched in substance; only pointer locations standardized). No new product behavior, no architecture change, no new rules. Doc Engineer audit + Process Observer audit sufficient.

**Why no BLOCKING marker for next session:** Wave B modified only Tier 2 docs (`docs/concepts.md` / `docs/roles.md` / `docs/workflow.md` / `docs/user-guide.md`). Tier 2 files are not cached into Claude Code's per-session system prompt — they are loaded on-demand by `/start-working` Step 2 / `/plan` / Lead's explicit Read calls. No cross-session staleness risk. Next session may begin without session-boundary barrier.

**Honest note on actual vs expected line reduction.** Plan v2.4 expected docs/ cross-file dedup of 100-150 lines. Actual Wave B reduction: docs/roles.md -1 line (B3 bullet consolidation), docs/user-guide.md -4 lines (B4 restatement removed), docs/workflow.md +4 lines (B1 + B2 added standardized pointer blocks where pre-existing pointer was more compact), docs/concepts.md ±0 (heading rename only) — net ≈ -1 line. The plan author's estimate over-fit the assumed volume of restatement; in reality, most cross-file references were already compact pointer-style sentences, and standardization to the plan's strict markdown-link + §anchor format added roughly as many characters as pure dedup removed. Value delivered is pointer-standardization discipline (every cross-file rule reference now uses the same `**Rule**: TL;DR. See [path](path) §anchor for the full rule.` shape) and anchor traceability (`grep "See \[.*\](.*\.md) §"` now enumerates every standardized pointer mechanically), not raw line count.

**Follow-up carry-over for next /plan:** BLOCKING marker rule is currently coarse — it fires on any Tier 1 modification regardless of whether the next Wave's execution semantically depends on the specific change. A refinement candidate: only emit BLOCKING when the Tier 1 change alters behavior that the next Wave's Lead would read from the stale session-start cache. Discussed conversationally during this Wave B close-out; not planned yet. Record here as a next-/plan input; framework refinement (would modify `commands/start-working.md` and `commands/end-working.md`, both Tier 1) lands in a separate session.

**Next step:** Plan v2.4 two-Wave sprint complete. No follow-on Wave from this plan. Open carry-over items: (1) BLOCKING rule refinement — promoted to the Wave directly below (same session, 2026-04-17), (2) Wave C infrastructure hardening milestone (unchanged — still independent milestone, v0.8-launch gate per Wave A close-out), (3) v0.8 roadmap planning (deferred to its own /plan session).

### Wave — BLOCKING Marker Semantic Gate (2026-04-17) — Complete

Branch: `feat/blocking-rule-refinement`. Mode: Solo + Lead direct edit (both target files are under the framework self-referential boundary).

Source: Promoted from Wave B close-out's "Follow-up carry-over for next /plan" above. Same-session /plan (2026-04-17) approved the semantic-gate proposal; executed immediately.

**Goal:** Refine BLOCKING marker emission from mechanical "Tier 1 modified → BLOCKING" to a semantic gate. Current rule over-fires on content-extraction refactors (Wave A precedent) where stale-cache Lead still reaches correct behavior via pointer follow-through. New rule: only emit BLOCKING when the Tier 1 change is behavioral (rule/constraint/workflow-step change, new identifier, or contract/interface change); default-on-doubt stays BLOCKING; skipping requires a prose rationale.

**Task list:**

- [x] **T1 — Codify the decision gate in `commands/end-working.md`.** New sub-bullet under Step 2 ("Update docs/plan.md"): master question + three-question decision aid (behavior? identifier? contract?) + default-on-doubt = BLOCKING + skip-rationale prose requirement + Tier 2/3/4 structural-zero-risk carve-out. Existing BLOCKING marker literal unchanged (`🚨 BLOCKING: Next Wave requires NEW SESSION`) so `commands/start-working.md` Step 0's detector stays stable (contract preservation — the marker is cross-command interface).
- [x] **T2 — Record the decision in `docs/design-decisions.md`.** One new row citing Wave A → Wave B (2026-04-17) as the driver; summarizes the semantic gate, default-on-doubt, skip-rationale requirement; notes two rejected alternatives (remove BLOCKING entirely / file-whitelist).

**Acceptance script (4 Lead-direct bash commands — eligible under the trivial-CLI carve-out):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `grep -c "BLOCKING marker decision" commands/end-working.md` | ≥ 1 | 1 — PASS |
| A2 | `grep -oE 'Behavior change\?\|New identifier\?\|Contract/interface change\?' commands/end-working.md \| wc -l` | 3 | 3 — PASS |
| A3 | `grep -c "BLOCKING marker semantic gate" docs/design-decisions.md` | 1 | 1 — PASS |
| A4 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | exit 0 / exit 0 — PASS |

4 commands, all [code], all exit-code determinate → eligible under the trivial-CLI carve-out.

**Files modified (3):**
- `commands/end-working.md` (T1 — new decision sub-bullet under Step 2, ~8 lines added)
- `docs/design-decisions.md` (T2 — one new row appended)
- `docs/plan.md` (this entry + /end-working close-out updates)

**Mode Selection Checkpoint.** Grouping: 2 framework files (Tier 1 + Tier 2). Decomposable? T1 and T2 are independent but both small-volume (single sub-bullet + single row). Teammate coordination overhead exceeds serial edit cost. Decision: **Solo + Lead direct edit**. Same precedent chain as Wave A, Wave B.

**Why Lead direct edit:** Both target files are under the framework self-referential boundary (CLAUDE.md Development Rules). No code files, no Developer/Codex calls. Precedent chain: Wave A, Wave B, IR Token Cost Documentation Wave, v0.7.5 README Restraint Wave, v0.7.4 Information Layering Policy Wave.

**Commit count verification:** 1 non-merge commit on the Wave branch (`git log --oneline --no-merges 2e5f79a..HEAD | wc -l` = 1). Base `2e5f79a` is the Wave B merge commit (PR #205) — this Wave's divergence base from main.

**Why no Independent Reviewer at Wave boundary:** Same precedent chain as Wave A/B — framework-self-referential work. This Wave adds substantive decision logic rather than merely preserving content, but scope is narrow (one sub-bullet + one row), and the Doc Engineer + Process Observer /end-working audit is sufficient coverage for framework-internal logic changes this size.

**BLOCKING marker rationale for next session (meta self-application):** Under the NEW rule introduced by this Wave, the Wave itself triggers gate question (a) "behavior rule change?" = yes — adds new decision logic to `commands/end-working.md` that Lead executes at every future /end-working. Emit BLOCKING. Wave C / v0.8-plan starts in a fresh session. The rule self-applies on its own introducing Wave; expected and consistent.

**Honest note on first-application subtlety (next-/plan input):** The gate's master question references "cached Tier 1 files," but not all Tier 1 files are actually cached in the per-session system prompt. CLAUDE.md is (via the `# claudeMd` injection); `commands/*.md` and `agents/*.md` are read at invocation time (via the Skill tool for slash commands, or the Agent tool for sub-agents), so cache-staleness risk for those files is near-zero. This Wave modified `commands/end-working.md` — strictly, the master question answers "no" (no cache divergence). But the decision-aid question (a) answers "yes" (behavior change). The gate defaulted to conservative (decision-aid wins → BLOCKING). A future refinement candidate: narrow the gate trigger to files actually cached in the session system prompt (CLAUDE.md, `.claude/settings.json`) rather than all of Tier 1. Recorded here as a next-/plan input; not executed in this session to keep the Wave scope clean.

**Next step:** Same-session follow-up Wave (Gate Narrowing) promoted directly below — user pushed back on the emitted BLOCKING marker ("非得开新会话不能直接搞吗？") and Lead confirmed the marker was a predicted false-positive; narrowing landed in the same session.

🚨 BLOCKING: Next Wave requires NEW SESSION

### Wave — BLOCKING Gate Narrowing (2026-04-17) — Complete

Branch: `feat/blocking-gate-narrow`. Mode: Solo + Lead direct edit (same-session follow-up to the Semantic Gate Wave; all target files under the framework self-referential boundary).

Source: Promoted from the Semantic Gate Wave's "Honest note on first-application subtlety" above. User challenged the BLOCKING marker in-session ("非得开新会话不能直接搞吗？"); Lead confirmed the marker was a gate false-positive (predicted and recorded earlier) and executed the narrowing refinement immediately rather than deferring to a later session.

**Goal:** Narrow the gate trigger from "any Tier 1 file" to `CLAUDE.md` specifically — the only file Claude Code injects into its session-start system prompt via `# claudeMd`. Other Tier 1 files (`commands/*.md`, `agents/*.md`, `templates/*.md`, `CLAUDE-TEMPLATE.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `bootstrap/install/isparto.sh`) are read on-demand at tool-invocation time, so stale-cache risk is structurally zero for them. Semantics of the gate (master question + 3-question decision aid + default-on-doubt + skip-rationale) unchanged for genuine cache-staleness cases.

**Task list:**

- [x] **T1 — Narrow the gate trigger in `commands/end-working.md` Step 2.** Trigger clause changed from "any Tier 1 file (per Documentation Language Convention in CLAUDE.md)" to "`CLAUDE.md` (the only file Claude Code injects into its session-start system prompt — see the `# claudeMd` context block that every session receives)". Master question reworded to reference CLAUDE.md specifically. The former "Tier 2/3/4-only" carve-out expanded into an "all other files" carve-out that enumerates the invocation-read Tier 1 files and names the mechanism each is read by (Skill tool / Agent tool / /init-project / runtime hook dispatch / external shell execution).
- [x] **T2 — Record the refinement in `docs/design-decisions.md`.** New row appended (2026-04-17 refinement); the previous 2026-04-17 row marked "Superseded by the refinement below" to preserve decision history without overwriting the audit trail.

**Acceptance script (3 Lead-direct bash commands — eligible under the trivial-CLI carve-out):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `grep -c "session modified \`CLAUDE.md\`" commands/end-working.md` | 1 | 1 — PASS |
| A2 | `grep -c "gate narrowed to CLAUDE.md" docs/design-decisions.md` | 1 | 1 — PASS |
| A3 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | exit 0 / exit 0 — PASS |

3 commands, all [code], all exit-code determinate → eligible under the trivial-CLI carve-out.

**Files modified (3):**
- `commands/end-working.md` (T1 — Step 2 sub-bullet narrowed; trigger + master question + carve-out rewritten)
- `docs/design-decisions.md` (T2 — one new row appended + supersession note on previous same-day row)
- `docs/plan.md` (this entry + /end-working close-out updates)

**Mode Selection Checkpoint.** Grouping: 2 framework files (Tier 1 + Tier 2). Decomposable? T1 and T2 are independent but both tiny (~8 lines + 2 lines). Teammate coordination overhead (tmux spawn + prompt + wait + merge per Teammate) strictly exceeds serial Edit-tool cost for edits of this size. User's "Agent Team when possible" directive acknowledged; honest-assessment mode threshold not met for edits this small — Solo is faster. Decision: **Solo + Lead direct edit**. Same precedent chain as Wave A, Wave B, Semantic Gate Wave.

**Why Lead direct edit:** Both target files are under the framework self-referential boundary (CLAUDE.md Development Rules). No code files, no Developer/Codex calls. Precedent chain: Wave A, Wave B, Semantic Gate Wave (same day).

**Commit count verification:** 1 non-merge commit on the Wave branch (`git log --oneline --no-merges c60f81e..HEAD | wc -l` = 1). Base `c60f81e` is the Semantic Gate Wave merge commit (PR #206) — this Wave's divergence base from main.

**Why no Independent Reviewer at Wave boundary:** Same precedent chain as Wave A/B/Semantic Gate Wave — framework-self-referential work, narrow scope (one sub-bullet edit + one design-decisions row). Doc Engineer + Process Observer /end-working audit sufficient.

**Why no BLOCKING marker for next session (under the NEW narrowed gate this Wave just codified):** This Wave did NOT modify `CLAUDE.md` — modifications were to `commands/end-working.md` (invocation-read via Skill tool at every /end-working call) and `docs/design-decisions.md` (Tier 2, not cached). Narrowed gate's trigger not met → skip BLOCKING. Stale-cache risk is structurally zero; session continuity preserved. The gate narrowing demonstrates its own value on its own introducing Wave — the Semantic Gate Wave emitted BLOCKING unnecessarily (false-positive predicted + recorded); this Wave, under the narrowed rule, emits none (true-negative). Retrospective validation of the narrowing.

**Next step:** User elected to proceed directly with Wave C + Rule 2 in the same session via Agent Team. Entry below.

### Wave C — Infrastructure Hardening + Commit-Count Rule Refinement (2026-04-17) — Complete

Branch: `feat/wave-c-rule2-infra-hardening`. Mode: **Agent Team** (2 parallel Teammates + Lead direct for small-volume Tier 1 edits). Teammate 1 scope: `hooks/process-observer/scripts/pre-tool-check.sh` (T1 + T2). Teammate 2 scope: `install.sh` (T3). Lead scope: `CLAUDE.md` + `CLAUDE-TEMPLATE.md` (T4, Rule 2). All three work streams fired in a single parallel message; zero file-ownership overlap.

Source: (a) Wave C candidate scope enumerated in Semantic Gate Wave session-log ("one-shot Python JSON parse, canary schema drift, install.sh version extraction hardening"). (b) Rule 2 filed in `docs/framework-feedback-0417.md` (commit-count timing ambiguity, PO audit E3 fragile classification).

**Goal (Wave C):** Close three known infrastructure gaps before v0.8 external-user validation: (1) replace the documented-limitation awk JSON parser in pre-tool-check.sh with a python3 implementation that handles `\uXXXX` + nested objects; (2) add a canary schema drift check that logs a stderr warning when Claude Code's `tool_input` shape deviates from current assumptions (fail-open, not blocking); (3) harden install.sh's VERSION file reading with trim + semver validation, fail-fast on malformed content.

**Goal (Rule 2):** Update CLAUDE.md and CLAUDE-TEMPLATE.md commit-count-accuracy rule to acknowledge the pre-commit-projected / post-commit-verify cadence that `/end-working` actually uses.

**Task list:**

- [x] **T1 — pre-tool-check.sh python3 JSON parse.** `extract_json_field` function (previously awk-based, documented in `design-decisions.md` row 56 as unable to handle Unicode escapes or nesting) replaced with a python3-backed implementation. Preserves function signature `extract_json_field <input> <field> [unescape_newlines]`. Fail-open on JSON decode errors (empty string + exit 0) — matches prior behavior semantics. Teammate 1 flagged: lookup order searches `tool_input` first, falls back to top-level payload — preserves existing call sites and the bare-`{"prompt":...}` smoke-test fixture.
- [x] **T2 — pre-tool-check.sh canary schema drift check.** New python3 block inserted after `INPUT=$(cat)` and before `TOOL_NAME` extraction. Inspects `tool_input`; if it is not a plain object, or if the known fields (`command` / `file_path` / `prompt`) exist but are not strings (e.g., nested object, array, number), writes a single-line warning to stderr: `iSparto canary: tool_input schema drift detected (tool=<name>, field=<name>, type=<actual_type>) — see hooks/process-observer/scripts/pre-tool-check.sh`. Does NOT block. Silent when python3 is missing or tool_input is absent/empty. Canary only inspects the 3 currently-known fields — future tool additions will need their field names appended as they land.
- [x] **T3 — install.sh read_version_file helper.** New POSIX-compatible function (25 lines) near the top of install.sh: trims all whitespace via `tr -d '[:space:]'`, validates against `^[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.-]+)?$` (semver-ish with optional pre-release/build tail), returns trimmed string on stdout or exits 1 with a clear stderr error (`install.sh: VERSION file at <path> is missing or malformed`). Three call sites replaced: local-repo INSTALL_VERSION read is fatal on malformed (`|| exit 1`); the upgrade idempotency check and OLD_VERSION read are tolerant (`2>/dev/null || true`) to preserve CLAUDE.md's backward-compat rule for users whose installed `~/.isparto/VERSION` may be corrupted. POSIX-compliant (no bashisms, no jq, no python3 dependency at install-time).
- [x] **T4 — Rule 2: commit-count verification timing.** `CLAUDE.md` line on plan.md verification-count accuracy updated to acknowledge the pre-commit-projected / post-commit-verify cycle: "For entries authored pre-commit (standard `/end-working` cadence, where the Wave entry ships inside the same commit it documents), write the projected count and re-verify via the same command immediately after the commit lands; if mismatch, amend before push." Same clause added to `CLAUDE-TEMPLATE.md` (minus the "Applies to every Wave" framing that CLAUDE-TEMPLATE.md does not carry).

**Acceptance script (5 Lead-direct bash commands — eligible under the trivial-CLI carve-out):**

| # | Command | Expected | Actual |
|---|---------|----------|--------|
| A1 | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` | both exit 0 | exit 0 / exit 0 — PASS |
| A2 | `bash -n hooks/process-observer/scripts/pre-tool-check.sh && bash -n install.sh` | exit 0 | exit 0 — PASS |
| A3 | `./install.sh --dry-run` | exit 0, VERSION parses cleanly | exit 0 — PASS |
| A4 | `echo '{"tool_name":"Bash","tool_input":{"command":{"nested":"oops"}}}' \| bash hooks/process-observer/scripts/pre-tool-check.sh 2>&1 >/dev/null \| grep -c "canary: tool_input schema drift"` | ≥ 1 (canary fires on drift) | 1 — PASS |
| A5 | `grep -c "re-verify via the same command immediately after the commit lands" CLAUDE.md CLAUDE-TEMPLATE.md` | 1 each | 1 / 1 — PASS |

5 commands, all [code] / [runtime], all exit-code determinate → eligible under the trivial-CLI carve-out.

**Files modified (6):**
- `hooks/process-observer/scripts/pre-tool-check.sh` (T1 + T2 — awk parser replaced + canary added; 344 → 408 lines; +64 / -0 net)
- `install.sh` (T3 — read_version_file helper + 3 call sites; 512 → 542 lines; +37 / -7 net)
- `CLAUDE.md` (T4 — plan.md verification-count clause reworded; +1 / -1 line)
- `CLAUDE-TEMPLATE.md` (T4 — same clause; +1 / -1 line)
- `docs/plan.md` (this entry + /end-working close-out updates)
- `docs/design-decisions.md` (one new row for Rule 2 codification)

**Mode Selection Checkpoint.** Grouping: 4 files across 3 non-overlapping scopes (hooks/ + install.sh + CLAUDE.md pair). Decomposable? T1+T2 share a file (must be one Teammate); T3 is independent; T4 is tiny Lead-direct. File count × workload per stream justifies Teammate coordination: Teammate 1 drafted + smoke-tested ~70-line hook changes including Unicode-aware JSON parsing, and Teammate 2 drafted + smoke-tested a POSIX helper + 3 caller migrations — both streams involved non-trivial judgment (lookup order in T1, fatal-vs-tolerant caller split in T3). Decision: **Agent Team**, 2 Teammates + Lead direct on T4. Per-Teammate file ownership hard-partitioned, zero overlap.

**Why Lead direct for T4:** CLAUDE.md + CLAUDE-TEMPLATE.md are under the self-referential boundary. The Rule 2 change is a 1-line wording tweak per file; Teammate coordination overhead would exceed serial edit cost.

**Why Codex not used:** All four target files (hook script, installer, two system prompt files) are under the framework self-referential boundary (CLAUDE.md Development Rules). Teammates wrote drafts directly via Edit tool; no Codex call required. Precedent chain: Wave A, Wave B, Semantic Gate Wave, Gate Narrowing Wave.

**Commit count verification:** 1 non-merge commit projected on the Wave branch (`git log --oneline --no-merges 38d91cd..HEAD | wc -l` = 1 post-commit). Base `38d91cd` is the Gate Narrowing Wave merge commit (PR #207) — this Wave's divergence base from main. Pre-commit projected count per the Rule 2 refinement this Wave just codified; will re-verify immediately after the `/end-working` commit lands and amend if mismatch.

**Why no Independent Reviewer at Wave boundary:** Same precedent chain as Wave A/B/Semantic Gate/Gate Narrowing — framework-self-referential work. This Wave's scope includes code (hook script + installer), which is a slight extension of the precedent (prior Waves were doc-layer only). The mitigation: each Teammate ran a self-contained smoke-test suite (T1+T2: 6 smoke tests; T3: 8 smoke tests) embedded in the Agent prompt; results attached to this Wave's Teammate returns for audit trail. Doc Engineer + Process Observer /end-working audit provide the standard coverage.

**BLOCKING marker rationale for next session (under the narrowed gate codified in PR #207):** This Wave modified `CLAUDE.md` (T4 — plan.md commit-count verification timing, a behavioral rule change: adds the "re-verify immediately after the commit lands; amend before push if mismatch" workflow requirement that Lead executes at every /end-working). Narrowed gate's trigger IS met; decision aid question (a) = yes (behavior rule change). Emit BLOCKING. Next session required for Wave D / v0.8 roadmap /plan / any other work that would load CLAUDE.md fresh.

**Next step:** User decides in the next session — remaining open items are v0.8 roadmap /plan (external-user validation milestone), any follow-on framework polish, or external work (commercialization / Heddle dogfooding / etc.).

🚨 BLOCKING: Next Wave requires NEW SESSION

> ✅ Session boundary acknowledged 2026-04-17 — Rule 2 CLAUDE.md update was loaded into Lead's active context via mid-session system-reminder injection, so the stale-cache risk the marker guards against was mitigated along a non-standard path (not `/start-working` Step 0). Subsequent work proceeds in the same conversation with the updated rule visible. Wave entry below honors Rule 2 (projected commit count written pre-commit, re-verify post-commit).

### Wave — v0.7.8 Framework Polish (2026-04-17) — Complete

Branch: `feat/v0.7.8-polish`. Mode: Solo + Lead direct edit (all target files under the framework self-referential boundary).

Source: Lead ran a verification pass against an 8-point external diagnosis of the repo produced by Kimi 2.6 and classified each item by symptom-accuracy, root-cause accuracy, and prescription-fit. Two items survived verification as genuinely worth doing in this Wave (T1 + T2 below); two items surfaced partial merit and were deferred to v0.8+ roadmap (see "Out of scope" below); four items were rejected and recorded in the Rejected Approaches table.

**Goal:** (T1) stop `/start-working` Step 3 from reading the entire `docs/session-log.md` (1386 lines at Wave start and growing monotonically) when only the most recent entry is consumed by the Step 9 briefing — the rest is per-session token waste that compounds over time. (T2) introduce a mechanical guardian for the Information Layering Policy C-layer "ceremonial wrapper" rule (`scripts/policy-lint.sh`, single-detector v1), wire it into the Doc Engineer audit as item 10 parallel to the existing item 9 (`language-check.sh`). Both tasks are framework-internal polish; no user-facing product-behavior change.

**Task list:**

- [x] **T1 — `/start-working` Step 3 read-pattern fix.** Pre-implementation verification ran `grep -n -i "cumulative|total sessions|total codex" commands/start-working.md` to confirm Step 3 is the only producer of cumulative-stats collection and no downstream step consumes them; grep surfaced only the Step 3 producer bullet, closing the loop. Step 3 rewritten so that when `docs/session-log.md` exists and contains at least one `## .* Session` heading, Lead reads only the most recent session entry via `grep -n '^## .* Session' docs/session-log.md | tail -1` + `sed -n '<N>,$p'` instead of the whole file. Empty-grep case (file exists but no session heading yet — e.g., only the `# Session Log` top-level header) takes the same skip branch as "file does not exist," preventing a `sed -n ',$p'` empty-parameter stall. Cumulative-stats collection bullet (total sessions / total Codex reviews / historical issue counts) deleted — Step 9 C-layer rules already forbid emitting these, so scanning the whole log to compute them was dead work.
- [x] **T2 — `scripts/policy-lint.sh` v1 (ceremonial wrapper detector only).** New mechanical guardian mirroring `scripts/language-check.sh` structure: bash wrapper resolves repo root (git-rev-parse fallback to script-relative), Python3 heredoc does the scan, `--self-test` argument runs fixtures, exit 0 / 1 / 2 semantics. Single regex matches the 5 forbidden C-layer phrases enumerated in `commands/end-working.md` ("C-layer items — NEVER emit in the closing briefing"): `Session complete`, `Ready for next session`, `Doc Engineer audit passed`, `Process Observer audit passed`, `Security scan passed`. Scope scoped to the most recent session-log entry only (same retrieval strategy as T1 — locate last `^## .* Session` heading, scan from there to EOF). 8 self-test fixtures total: 5 positive (one per forbidden phrase) + 3 negative (`"The session was productive"` / `"Doc Engineer caught 2 issues"` / `"Security patterns updated"` — keyword subsets present but forbidden phrase absent). Hard failure on hit; warning-only detectors for bullet-stack and A-layer wording explicitly excluded from v1 to preserve signal-to-noise ratio (prevents heuristic false positives from diluting the ceremonial detector's hard-failure channel). Integration: new item 10 "Policy compliance check" added to `docs/roles.md` Doc Engineer audit checklist, parallel wording + exit-code semantics to item 9; audit-report table gets a new `Policy compliance` row and a new `--- Policy Compliance Violations (item 10) ---` section; `commands/end-working.md` line 94 (Doc Engineer re-audit trigger list) updated to include item 10 alongside items 8 and 9.

**Acceptance script (8 commands, mixed [code] + [build] + [runtime] — trivial-CLI carve-out eligible for A1/A2/A3/A6 only):**

| # | Tag | Command | Expected | Actual |
|---|-----|---------|----------|--------|
| A1 | [code] | `grep -c "read only the most recent session entry" commands/start-working.md` | ≥ 1 | 1 — PASS |
| A2 | [code] | `grep -c "Cumulative project stats" commands/start-working.md` | 0 | 0 — PASS |
| A3 | [code] | `test -x scripts/policy-lint.sh && echo PASS` | `PASS` | PASS |
| A4 | [build] | `bash scripts/policy-lint.sh --self-test` | exit 0, 8/8 fixtures pass | exit 0, 8/8 — PASS |
| A5 | [build] | `bash scripts/policy-lint.sh` in the current repo | exit 0 (or exit 1 with violations) | exit 0 — PASS (most recent session entry clean) |
| A6 | [code] | `grep -c "scripts/policy-lint.sh" docs/roles.md` | ≥ 1 | 2 — PASS (item 10 invocation line + violations section reference) |
| A7 | [runtime] | In throwaway branch, manually spawn a zero-context sub-agent, have it read `docs/roles.md` item 10 and execute the literal instruction. Confirm the linter is locatable, the exit-code table maps correctly, and the path is end-to-end clean — NOT via `/end-working` so a linter bug cannot trigger the real 3-iteration Doc Engineer re-audit loop on the session's own commits. | Sub-agent quotes item 10 verbatim + runs policy-lint.sh → exit 0 + maps to ✅ verdict | Sub-agent quoted item 10 bullets 1–2 verbatim, ran default + --self-test, both exit 0, both mapped to ✅ — PASS |
| A8 | [build] | `bash scripts/language-check.sh && bash scripts/language-check.sh --self-test` (regression — ensure T2 doesn't introduce CJK or Principle 1 violations) | both exit 0 | exit 0 / exit 0 — PASS |

**Files modified (4 + this plan.md entry):**
- `commands/start-working.md` (T1 — Step 3 rewrite; ~3 lines net)
- `scripts/policy-lint.sh` (T2 — new file, 139 lines — estimate in plan was 40-60 lines single-detector; the parallel heredoc structure + 8 fixtures + full colored output pushed it to ~140, still well under language-check.sh's 346-line comparable)
- `docs/roles.md` (T2 integration — new item 10 block, audit-report table row added, new violations section)
- `commands/end-working.md` (T2 integration — line 94 re-audit trigger list extended to include item 10)
- `docs/plan.md` (this entry)

**Mode Selection Checkpoint.** Grouping: 4 Tier 1 files + 1 Tier 4 plan.md. Decomposable? T1 and T2 touch different files, yes. Volume? T1 is ~3 lines of doc edit; T2 is one new ~140-line script + 3 doc edits across 2 files. Teammate coordination overhead (tmux spawn + prompt + wait + merge) strictly exceeds serial Edit-tool cost for edits of this aggregate size. Decision: **Solo + Lead direct edit**. Precedent chain: Wave A, Wave B, Semantic Gate Wave, Gate Narrowing Wave, Wave C T4.

**Why Lead direct edit:** All target files are under the framework self-referential boundary (CLAUDE.md Development Rules). No code files outside that boundary; no Developer/Codex calls required. T2's new script is itself a Tier 1 file (`scripts/policy-lint.sh`), covered by the self-referential exception.

**Commit count verification (Rule 2 cadence):** 2 non-merge commits on the Wave branch at `/end-working` time (projected 1, actual 2 after Doc Engineer WARN follow-up). Commit 1: primary Wave commit `83741b1` (T1 + T2 implementation, session log, framework-feedback Rules 4+5). Commit 2: Doc Engineer item 7 WARN follow-up (adds `scripts/policy-lint.sh` entry to `docs/repo-structure.md` and a new bullet in `docs/design-principles/information-layering-policy.md` §Enforcement; the two Tier 2 internal-doc integration points DE flagged as missing). Re-verification command: `git log --oneline --no-merges 3c22eba..HEAD | wc -l` — expected `= 2`. Base `3c22eba` is the Wave C + Rule 2 merge commit (PR #208) — this Wave's divergence base from main.

**Why no Independent Reviewer at Wave boundary:** Precedent chain applies — framework-self-referential polish, narrow scope, no new product-behavior surface. Doc Engineer + Process Observer `/end-working` audit is sufficient coverage. The new `policy-lint.sh` itself becomes part of the Doc Engineer audit tool-set from this Wave forward, so next Wave's audit inherits the additional guardian.

**BLOCKING marker rationale for next session (under the narrowed gate codified in PR #207):** This Wave did NOT modify `CLAUDE.md`. Target files: `commands/start-working.md`, `commands/end-working.md`, `docs/roles.md`, `scripts/policy-lint.sh` — all Skill-invoked / on-demand-read, stale-cache risk structurally zero. Narrowed-gate trigger not met → **skip BLOCKING**. Next Wave may start in the same session if desired.

**Out of scope (Kimi diagnosis disposition):**
- **Accepted into this Wave (items 1 and 6):** session-log read-pattern fix (T1) and A/B/C Policy linter v1 (T2).
- **Deferred to v0.8+ roadmap (items 3 and 8-backhalf):** two items — migrated 2026-04-17 to the Backlog section below (see DV-1 `/env-nogo` deep consistency checks and DV-2 `install.sh --rollback`).
- **Rejected (items 2, 4, 5, 7):** disposition recorded in the Rejected Approaches table below.

**Next step:** User decides in the next session — v0.8 roadmap /plan (external-user validation milestone), further framework polish, or external work (Heddle dogfooding / commercialization / etc.).

### v0.8.0 — 模型配置升级 + IR 异源化 (2026-04-18) — Merged-Not-Released

Branch: `feat/v0.8.0-model-upgrade` (主 Wave) + `docs/observation-tracker-wave0` (polish 1) + `docs/v0.8.0-merged-not-released` (polish 2,本段). Mode: Solo + Lead direct edit (all target files under the framework self-referential boundary).

**Goal.** 同步两件事：(a) iSparto 6 角色模型升级 — Lead/Teammate/Doc Engineer claude-opus-4-6 → claude-opus-4-7；Developer gpt-5.3-codex → gpt-5.4 (impl) + gpt-5.4-mini (QA, unchanged)；PO Audit 保持 Sonnet 4.6。(b) Independent Reviewer 架构迁移 — 从 Claude Code sub-agent (`Task(subagent_type=...)`) 迁移到 OpenAI Codex CLI in tmux pane (`codex exec`)，把 cross-provider training distribution independence 叠加在 zero context inheritance 之上。

**Why bundle (a) + (b) into one Wave.** 两件事都是 framework-internal config + 叙事更新，没有结构性代码改动；分两个 Wave 会产生两次 DE/PO/IR audit 开销而无收益。Section 9 回滚粒度说明保证两类 failure mode 独立 revert，不会因 Claude 4.7 退化误伤 IR 迁移成果。

**外部预验证 Gate (开工前已过):**
- [x] 验证 1: GPT-5.4 通过 mcp__codex-dev__codex 可调
- [x] 验证 2: Fast mode `service_tier = "fast"` 配置生效 (mechanical path b — `~/.codex/config.toml` 已含)
- [x] 验证 3: `codex exec` 在 tmux pane 内可读 `agents/` + 写 `docs/`

**Acceptance:**
- [x] docs/configuration.md 改动 A–E 落地
- [x] docs/collaboration-mode.md F2a + F2b 落地
- [x] docs/concepts.md F3a + F3b 落地
- [x] agents/independent-reviewer.md frontmatter 改 F4 (model: opus → runtime: codex-cli)
- [x] docs/roles.md IR 章节改 F5
- [x] commands/ + docs/workflow.md IR spawn 引用全量更新 (F6) + CLAUDE.md/CLAUDE-TEMPLATE.md 同步
- [x] docs/repo-structure.md 加 IR runtime 说明 (F7)
- [x] docs/plan.md 加观察期 tracker (本 entry 下方, F8b)
- [x] docs/design-decisions.md superseded rows 替换为 v0.8.0 决策行
- [x] CHANGELOG.md v0.8.0 entry
- [x] Doc Engineer 10 项审计全过 (含 item 9 + item 10) — PASS, 1 expected WARNING (pre-commit `[ ]` flip)
- [x] Wave Boundary IR via `codex exec` (新路径自验证) — PROCEED, MAJOR + MINOR findings resolved in-session (configuration.md token-budget table + design-decisions.md row 66 superseded marker)
- [x] Process Observer audit — 14/14 PASS
- [x] **Change G — tmux hard-dependency surfaced in pre-validation (5 files):** install.sh tmux pre-flight check, commands/migrate.md mirrored check, docs/user-guide.md Prerequisites section (new), CLAUDE.md Platform line, CHANGELOG.md Migration Notes breaking-dependency entry
- [x] PR + merge (PR #215 merged 2026-04-18, merge commit `f378219`; 2 non-merge commits `46334bc` core + `d976981` change G)
- [x] **Polish follow-up — Wave 0 observation data populated + IR MINOR resolved (separate PR on `docs/observation-tracker-wave0`):** F8b tracker first row relabeled to "Wave 0" with actual data; meta paragraph updated to document the v0.7.8 baseline-loss caveat (independent observation session conflated with main Wave repo); audit artifact persisted from `/tmp` to `docs/observation-period/wave0-de-audit.md` (`scripts/language-check.sh` `TIER2_EXCLUDED_DIRS` extended for the new directory) per Wave Boundary IR MINOR finding

**Mode Selection Checkpoint.** Grouping: initial 14 framework files (CLAUDE.md, CLAUDE-TEMPLATE.md, agents/independent-reviewer.md, commands/{end-working,init-project,plan}.md, docs/{configuration,collaboration-mode,concepts,roles,workflow,repo-structure,design-decisions,plan}.md, CHANGELOG.md) + change G adds 4 more files (install.sh, commands/migrate.md, docs/user-guide.md — CLAUDE.md and CHANGELOG.md already in scope). Total ≈ 17 framework files in commit 1 + ~5 in commit 2. Decomposable? 文件之间存在 cross-references (IR spawn 引用 + 模型映射 + tmux dependency narrative), 顺序敏感. Volume? 都是 narrative + table + small bash check, 无 Tier 1 logic 改动. Decision: **Solo + Lead direct edit**. Precedent chain: Wave A/B/C, v0.7.8 Polish.

**Why Lead direct edit:** All target files under framework self-referential boundary (CLAUDE.md Development Rules). 无 Developer/Codex calls required.

**Why Independent Reviewer at Wave boundary (despite framework-internal):** 本 Wave 改变了 IR 执行路径本身 (sub-agent → Codex CLI). Wave Boundary IR 必须真实跑一次确认新路径工作 — 这次 IR 的价值在 "验证迁移成功" 而非 "验证 alignment". 如外部验证 3 在 Wave 中失败, 本 Wave 降级为不含 IR 的 v0.8.0 (按 Backlog FR-19 三条件 carve-out 正当 skip), IR 部分推迟到 v0.8.1.

**BLOCKING marker rationale for next session (under the narrowed gate codified in PR #207):** This Wave 修改了 `CLAUDE.md` (Module Boundaries 表的 IR 行) — 触发 BLOCKING 默认值. Decision aid: (a) Behavior change? Yes — IR 调用路径变化 (Task tool → codex exec). (b) New identifier? Yes — `runtime: codex-cli` frontmatter key. (c) Contract/interface change? Yes — IR spawn one-liner shape 改变. 三项 yes → **emit BLOCKING marker**.

**Commit count verification (Rule 2 cadence):** Projected 2 non-merge commits on the Wave branch at `/end-working` time. Commit 1 (`46334bc`) ships the 17-file core upgrade. Commit 2 ships change G (5 files: install.sh, commands/migrate.md, docs/user-guide.md, CLAUDE.md, CHANGELOG.md) — surfaced after commit 1 was already pushed when the user noticed tmux was a hard dependency requiring documentation. Splitting was the cleanest path (no force-push / amend on a published commit). Re-verification command: `git log --oneline --no-merges bb5a983..HEAD | wc -l` — base `bb5a983` 是 v0.7.8 final merge commit (本 Wave divergence base from main); expected output: `2`.

**Status: MERGED-NOT-RELEASED (since 2026-04-18)**

本 Wave 的全部文件改动已 merge 到 main (PR #215 v0.8.0 核心 + change G; PR #216 Wave 0 polish), 但 v0.8.0 故意不进入 release 流程:

- VERSION 文件保持 `0.7.8` (不 bump 到 `0.8.0`)
- CHANGELOG `[0.8.0] - 2026-04-XX` 占位符不替换
- 不创建 `v0.8.0` git tag
- 不触发 GitHub Release
- `scripts/release.sh` 不运行

**Why merged-not-released:** 升级 scope 过大 (模型替换 + IR 架构迁移 + tmux hard-dep), 需要观察期内验证再发版, 降低用户被未充分验证升级波及的风险. main 分支上的代码是"事实上已就绪"的下一版本, 但 release 元数据 (tag / CHANGELOG date / VERSION bump) 等观察期通过后再统一刷新. 这是"merge ≠ release"的显式分离 — main 永远跟着最新代码走, release tag 跟着可信任度走.

**Release gate (三条件, 全部满足后才跑 `/release patch`):**

1. **5-Wave 观察期完成** — F8b tracker 第 1-5 行 (Wave 0 已填, Wave 1-4 待填) 全部记录, 且累计同字段异常 < 2 行. 如触发 ≥ 2 行同字段异常 (DocEng 过严 / Lead escalation 异常 / Teammate 字面化), 先按 docs/design-decisions.md per-role partial revert 路径处置, 处置完成后 reset 观察期重新起算 (Wave 0 数据保留作为历史参考, 但 Wave 1-4 行清空重计).
2. **新 IR 路径稳定性证据** — Wave Boundary IR 在 Wave 1/2/3 至少 3 次成功执行 (`codex exec` in tmux 无 infrastructure 故障 — Codex CLI 升级、GPT-5.4 quota 撞限、tmux pane cross-context bug 等均算 infrastructure 故障). 任何一次 infrastructure 失败需要 root cause 分析后才能继续计数; 故障前的成功次数保留, 故障 Wave 不计入但也不清空已有计数.
3. **观察期内无 emergency revert** — 5 Wave 期间未对任何角色应用 partial revert. 如发生 partial revert (例如 DocEng 回退 4.6 max), release version 必须反映实际 ship 的角色集合: 要么命名为 `v0.8.0-mixed` 显式标注混搭, 要么直接跳过 v0.8.0 tag 推迟到 v0.8.1 ship 完整 4.7 + IR 异源组合 (推荐后者, 避免 mixed 版本带来的 support 复杂度).

**Release 触发 (三条件满足后):** 在新 session 跑 `/release patch` 触发 `scripts/release.sh` (自动 bump VERSION 0.7.8 → 0.8.0、替换 CHANGELOG date 占位符为 release 当日 CST 日期、创建 `v0.8.0` git tag、推 GitHub Release). 不要绕过 `/release` 手动 tag — release.sh 包含一致性检查不容易手动复刻.

**Status 段维护规则:** Wave 1-4 完成后每次更新 F8b tracker 的同时 review 本段三条件; 全部满足时把本段标记从 `MERGED-NOT-RELEASED` 改为 `RELEASED — v0.8.0 (YYYY-MM-DD CST)` 并保留段落作为历史 (不删除); 触发 partial revert 时把本段标记改为 `MERGED-NOT-RELEASED — REVERT IN PROGRESS` 并新增子段说明 revert 范围 + 重置后的观察期起点.

🚨 BLOCKING: Next Wave requires NEW SESSION
> ✅ Session boundary acknowledged 2026-04-18 by /start-working

> Rationale (per the narrowed gate codified in PR #207): This Wave modified `CLAUDE.md` (Module Boundaries IR row). Decision aid all three "yes": (a) Behavior change — IR invocation runtime moved from Claude Code Task tool to OpenAI Codex CLI; (b) New identifier — `runtime: codex-cli` frontmatter key; (c) Contract/interface change — IR spawn one-liner shape changed (`codex exec "..."` instead of `Task(subagent_type=...)`). Marker emitted to force fresh session for Lead's `# claudeMd` cache to pick up the new IR row + the model upgrade context.

### v0.8.0 升级观察期 Tracker

升级后前 5 个 Wave 为观察期。每完成一个 Wave，在下表添加一行，mechanical 收集而非凭印象。如累计出现 ≥ 2 行同字段标记 "异常"，触发"风险与回滚"中风险 3 处置路径（轻度/中度/重度退化分级）。

**Placeholder `(待填)` 结算时机规则 (FR-27 codification):**

- **Transition 时机**: `(待填)` → 数据行 的填入动作必须在 Wave 的 `/end-working` commit 内完成, 由 Lead 在 Step 2 (更新 plan.md) 或 Step 4 (写 session report) 时填入. `/end-working` Step 5 (PO audit) 把 "tracker row 已填" 作为 E-series audit check 验证 (见 `agents/process-observer-audit.md`); commit 已 land 但 row 仍为 `(待填)` = FAIL, 属于观察期数据完整性漏采.
- **不可逆原则**: 数据行一旦填入 (任一 Wave 进入 post-commit 状态), **不得回退到 `(待填)`**. 防止 revert 池塘污染观察期统计.
- **Partial revert 路径**: 如 Wave 触发 per-role partial revert (按本文件 v0.8.0 Status 段描述的 per-role 回退路径), tracker 对应行保留, 但 `备注` 列追加 `REVERT: <reason> — Wave X 重起算` 标记, 并在 tracker 下方加 status 备注说明新的观察期起点 Wave 编号. 呼应 Release Gate 条件 3 的 mixed-version 逻辑: 保留真实历史, 只在 `备注` 层表达"本行不计入新起算窗口"的语义.
- **N/A 行**: 当 Wave 实际未产生某字段数据 (例如 Solo + Lead direct edit 模式下 Teammate 字面化字段为 N/A), 填 `N/A — <短原因>` 而非 `(待填)`. N/A 是 positive 观察结果 (确认本 Wave 不适用该字段), `(待填)` 是 negative 状态 (数据应采而未采).

| Wave 名 | DocEng 是否过严 | Lead escalation 是否异常 | Teammate 字面化是否出现 | 备注 |
|---------|----------------|--------------------------|------------------------|------|
| Wave 0 (v0.8.0 升级 itself) | 否 — context-aware, 主动做 scope clarification (audit 用户问"v0.7.8 release 状态"时主动指出 working tree 在 v0.8.0 分支), 无机械套死 | N/A — 本审计为 DE solo run, 无 Lead escalation 触发 | N/A — 无 Teammate 参与 (Solo + Lead direct edit 全程) | DE audit 输出归档: `docs/observation-period/wave0-de-audit.md` (Opus 4.7 max, 10/10 PASS — 8 实质 PASS + 2 项目类型 N/A; 原 `/tmp` 路径已迁移至 repo-tracked 路径以解决 IR MINOR finding). Scope caveat 见下方说明段 |
| Wave 1 (FR-19 IR skip carve-out codification) | 否 — DE pre-merge audit 精准捕获 plan.md 声明 / 实际状态不一致 (Wave 1 entry task list 第 9 项 + Files-modified 子弹点声称 tracker Wave 1 row 已填, 实际仍为"待填"), 以及 "(below)" vs "(above)" 方向性措辞错误; 两处均为真实 FAIL, 无 over-strictness / 无误报 | 否 — Lead 按 `docs/roles.md` Doc Engineer audit-fix separation rule 正常进入 re-audit loop, 无异常 A-layer escalation; DE FAIL 报告→Lead 直接修复→re-audit 是标准路径 | N/A — Solo + Lead direct edit, 无 Teammate 参与 | PO + DE 独立均捕获同一 plan.md 不一致 (证据: PO E2 FAIL + DE item 6 FAIL 两报告内容 byte-level 一致). Lead 在 commit 前修复. FR-19 three-condition carve-out 首次 dogfood 验证通过: PO E5 PASS (三条件 independently satisfied), F1 PASS (carve-out skip IR at Wave boundary) |
| Wave 2 (`/doctor` slash command + `doctor-check.sh`) | 否 — DE pre-merge audit 10/10 PASS (Opus 4.7 at xhigh); 未出现 over-strictness / false positive; 两 guardian scripts (language-check + policy-lint) 机械 PASS; item 6 正确识别 "10 commands 计数 (目录) vs 9 commands 计数 (user-facing excluding /release)" 双 convention 一致性 | 否 — Lead 正常按 `docs/roles.md` audit-fix separation rule 对 IR 两次 BLOCK 报告做 in-session 修复 (BLOCK-1: scripts/doctor-check.sh D2/D3 multi-line + RC masking + commands/doctor.md D4 wording + product-spec.md command count; BLOCK-2: install.sh 缺 `scripts/doctor-check.sh` → `~/.isparto/scripts/` deploy + isparto.sh 缺 uninstall cleanup + CHANGELOG 同步). 无异常 A-layer escalation, 无 feedback_no_defer_framework_polish.md 违反 (全部 in-session 修复不 defer) | **是 (首行真实数据点)** — Teammate A (Opus 4.7 xhigh) 实现 `scripts/doctor-check.sh` 时出现两个 literal-not-semantic 模式: (1) **defensive-pattern 字面化** — 对 `codex --version` / `claude --version` 加 `\|\| true` 防失败, 机械适用给所有 command 而非推理哪些确实需要 (掩盖 non-zero RC, 违反 D2/D3 "detect --version failure" 产品 intent, IR MAJOR-2 catch); (2) **raw-passthrough 字面化** — D2/D3 PASS detail 字段直接传递 `codex --version 2>&1` 的 raw 多行 stdout+stderr (e.g. "WARNING: proceeding, even though we could not update PATH: Operation not permitted (os error 1)\ncodex-cli 0.121.0"), 违反 one-line-per-check stdout 契约 (8 检查行变 9 行, IR MAJOR-1 catch). 两模式均为结构性可靠性问题, 不是单点 bug | IR 3-pass cycle 首次真实验证: BLOCK (2 MAJOR + 2 MINOR) → in-session fix → BLOCK (1 MAJOR fallback-path) → in-session fix → **PROCEED**. Release Gate 条件 2 第 1 次 real Wave Boundary IR 命中. 后续 Waves 2/3/4 必须也跑 real IR (本 Wave 是第 1 次, Wave 1 按 FR-19 carve-out 合理 skip). 本 Wave 额外暴露 2 个 framework rule gaps (→ plan.md Backlog FR-26 DE 机械 re-execute acceptance grep + FR-27 tracker placeholder 结算 timing). 审计归档: DE 10/10 PASS, PO 7 PASS + 5 IN-PROGRESS (standard pre-commit state) + 1 WARN on A6 transcription slip (fixed in this /end-working commit) |
| Wave 3 (`/start-working` Session Health Preview + FR-26 DE 机械 re-execute + FR-27 PO tracker 结算) | 否 — DE pre-merge audit 预期 10/10 PASS (Step 9 fresh sub-agent spawn, Opus 4.7); 本 Wave 验证新 FR-26 规则自洽 (audit item 3 机械 re-execute 本 Wave 的 grep/bash acceptance assertions) | 否 — Lead 正常按 Agent Team mode 并发 dispatch 3 Teammates, 每个 completion 到达按 trust-but-verify 规则独立核验 (grep 实际文件 + run --self-test + run guardians), 无异常 A-layer escalation | 否 — 3/3 Teammates 展示 semantic reasoning 非字面化: Teammate A (session-health.sh) 主动在 REAL_IR_SUBSTR 三候选 (`real run` / `Wave Boundary IR` / `real Wave Boundary IR`) 中推理选择并 document rejected alternatives, 处理 CJK `(待填)` placeholder via Unicode escapes; Teammate B (FR-26 rule) 在 Option A (sub-bullet under item 3) vs Option B (Key principles) 做理由化选择 (per-item 规则属于 item-level 而非 meta-rule); Teammate C (FR-27 check) **主动反驳** task brief 关于 `language-check.sh` backtick exemption 的错误前提 (Python probe 实证 scanner 无 code-fence 处理), 重构实现路径 (codepoint-description 代替 backtick-wrapped literal) 并推荐 FR-28 follow-up — 与 Wave 2 的 defensive-pattern / raw-passthrough 字面化形成鲜明对比 | Wave 3 triple-Teammate 首次并发 dogfood 成功, 3 个 Teammates + Lead concurrent 无 file 冲突 (file ownership group 严格隔离: Teammate A 专属 `scripts/session-health.sh` + `commands/start-working.md` Step 9 / Teammate B 专属 `docs/roles.md` 新 sub-bullet + `commands/end-working.md` Step 9 cross-ref / Teammate C 专属 `agents/process-observer-audit.md` 新 E6 row / Lead 专属 `docs/plan.md` + `CHANGELOG.md`). IR real-run 第 2 次 (Release Gate 条件 2 累计 2/3). 本 Wave 额外暴露 1 个 framework rule gap → plan.md Backlog FR-28 (language-check.sh 缺 fenced-code exemption — Teammate C implementation discovery). DE/PO audit 结果待 Step 5/9 fresh spawn 后补充 |
| Wave 4 (FR-13 gh 账户 mid-session guard + FR-24 PO audit canonical 18-row enumeration 合并执行) | 否 — DE pre-merge audit 预期 10/10 PASS (Step 9 fresh sub-agent spawn, Opus 4.7 at max); FR-26 机械 re-execute rule 在本 Wave 连续第二次 in-Wave dogfood (Wave 3 首次定义 + Wave 4 DE re-run 本 Wave 30+ grep/bash 风格 acceptance assertions). 若有 deviation 本行将 post-DE amend | 否 — Lead 按 Agent Team mode 并发 dispatch 2 Teammates (Track A: `scripts/gh-account-guard.sh` + `commands/end-working.md` Step 9 / Track B: `agents/process-observer-audit.md` canonical 18-row), 每个 completion 按 trust-but-verify 规则独立核验 (grep 实际文件 + run --self-test + run guardians), 无异常 A-layer escalation | 否 — 2/2 Teammates 均展示 semantic reasoning: **Track A positive case 语义→实证转化** — Teammate 拿到用户给的 portability 硬约束 (`"gh guard 必须在 fork+clone 后即生效, 不依赖 user-level ~/.claude/settings.json"`), 把语义前提映射成可机械验证的假设 (`.claude/settings.json` 是否 repo-tracked), 用 `git ls-files .claude/` 实测 (返回空) 排除 user-level PreToolUse hook 实现路径, 最终选择 scripts/ + commands/Step 9 expansion 双件组合; **Track B** — Teammate 对比 Wave 2 PO report (13 行) 与 Wave 3 PO report (18 行) 选定 canonical 18 行而非 FR-24 原提议的含糊"14 standard checks", 主动做 7→6 bullet→letter 收敛 (E category 吸收 "Unauthorized operations" + "plan.md accuracy"), Meta: row-count mismatch FAIL 规则置于 Rule Corrections section 避免 double-count — 两 Teammate 均主动 rationale 化架构决策, 与 Wave 2 defensive-pattern / raw-passthrough 字面化形成鲜明对比, 延续 Wave 3 全 semantic 趋势 | **Wave 4 meta-dogfood**: Track B 刚把 PO audit canonical checklist 显式化为 18 行 (A1-A3/B1-B2/C1-C2/D1-D4/E1-E6/F1), 本 `/end-working` Step 5 PO fresh spawn 直接对新 template 做"第一次"验证 (halt-on-mismatch guard: 返回 rows ≠ 18 当场 halt 查 root cause, 不让 PO 走完后才发现 codify 未生效). **IR real-run 第 3 次 → Release Gate 条件 2 累计 3/3 达成** (arc: round-1 BLOCK MAJOR → Lead in-session fix → round-2 PROCEED — 见本 Wave entry Observation data 段详情). **Positive data point — "语义判断成功"第 3 行**: Track A Teammate 的 portability-约束→git-ls-files-实测 转化, 与 Wave 3 Teammate C 主动反驳 task brief 错误前提、Wave 3 三 Teammate 全 semantic-reasoning, 合计为 "Opus 4.7 在 Teammate 角色下的 semantic reasoning 能力稳定" 累计第 3 个 positive case. 本 Wave 新增 2 个 Backlog: FR-31 (owner-extraction regex 三处重复: /start-working Step 6 + /end-working Step 8 + scripts/gh-account-guard.sh, priority low) + FR-32 (docs/roles.md "14 checks total" + docs/process-observer.md 15-row enumeration 与 canonical 18 stale, priority medium, 按用户 direction 延后至 v0.9 + plan.md 膨胀治理 session 合并处理). DE/PO audit 结果待 Step 5/9 fresh spawn 后补充 |

观察期 Wave 0 数据 (替代原计划 baseline): 原方案的"升级前 Opus 4.6 max DE 审计 baseline"在执行时因独立采集会话与主 Wave 共用 repo 串流, 实际采集到的是 Opus 4.7 max on v0.8.0 working tree 的数据 (归档于 `/tmp/de-audit-observation-wave0-47.md`, 2026-04-18 13:18 CST). 性质调整: 这是观察期 Wave 0 首行数据, 不是升级前 baseline. 后果: 观察期失去"升级前后对比"能力, 但保留"Wave 0 → Wave 1/2/3/4 内部对比"能力 — 4.7 在 iSparto structured prompt 环境下的退化趋势仍可机械观察. Wave 0 数据质量良好 (context-aware, 主动做 scope clarification, 无机械套死), 作为后续 Wave 的参照点适用. v0.7.8 baseline 缺失记入 Backlog 作为本观察期的已知 caveat, 不再补采 (补采 4.6 max 需要 downgrade Lead 模型 + 重新进入 v0.7.8 working tree 状态, 成本超过收益; 直接进入 Wave 1 收数据更高效).

以下项目受外部生态演进驱动，iSparto 只追踪不行动，满足触发条件时再评估：

| 追踪项 | 触发条件 | 影响评估 | 预估时间 |
|--------|---------|---------|---------|
| GPT-5.4 退役 / GPT-6 发布 | OpenAI 官方宣布 5.4 退役日期 OR 发布下一代 Codex 模型 | Developer 被动升级新一代，需验证所有 prompt template 兼容性 + 重新评估 Tier-模型映射；本次 v0.8.0 已主动升级 5.3-codex → 5.4 | 取决于 OpenAI |
| Fast Mode 在 Codex CLI 进一步演进 | OpenAI Codex 推出 per-call service tier override（当前是 config-level） | IR / Developer 可按场景细化 Fast Mode 触发条件，例如 IR 默认 standard 而 Developer Tier 1 默认 fast | 取决于 OpenAI |
| codex-plugin-cc 集成 | v0.8 阶段，codex-plugin-cc 稳定且 MCP/Plugin 职责边界验证完毕 | MCP 核心实现路径 + Plugin 补充审查/委派 | v0.8 |
| 跨 session 自动化 | v1.x 阶段，且 Codex Triggers + Claude Code /loop 均稳定 | 从 session 级框架扩展到 event-driven 自动化（GitHub issue → 自动修复 → 自动 PR） | v1.x |
| Process Observer 覆盖 Plugin 调用 | Claude Code 的 hook 机制支持拦截 plugin slash command（目前不支持） | 统一 MCP 和 Plugin 通道的 hooks 覆盖，简化双通道架构 | 取决于 Claude Code 演进 |
| 多 agent runtime 互操作标准 | MCP 跨 provider 标准成熟（当前各厂商各自为政） | 统一 Codex/Claude/Gemini 调用接口，简化框架层抽象 | 2026-2027 |

### Wave 1 — FR-19 IR Skip Carve-out Codification (2026-04-18) — Complete

Branch: `feat/fr-19-ir-skip-carveout`. Mode: Solo + Lead direct edit (all target files under the framework self-referential boundary).

Context: 本 Wave 是 v0.8.0 升级观察期的第 2 个 Wave (Wave 0 = v0.8.0 升级本身, Wave 1 = 本 Wave). 双目的合一: (a) 落地 Backlog FR-19 — IR skip at Wave boundary 需要显式 exit criteria, (b) 为 observation period tracker 产第 2 行数据.

**Goal:** codify 6-Wave precedent of Independent Reviewer skip-for-self-referential-polish into `commands/end-working.md` Step 3 as a three-condition carve-out (no application-code files / no new product-behavior surface / DE+PO sub-agent audits both run in same invocation). Without codification, each Wave 的 IR decision 需要 Lead re-justify from scratch, 造成跨 Wave 的 audit trail 不一致.

**Task list:**

- [x] **T1 — `commands/end-working.md` Step 3 carve-out block.** 在 "Trigger:" 行后、"If triggered:" 行前插入 skip carve-out 段落: 三条件各自独立 (缺一 revert default "run IR"), 条件 (i) 列举全部 system-prompt-layer + build/tooling-config + project-docs 路径清单, 条件 (ii) 要求无新 command/role/skill/marker/convention 命名, 条件 (iii) 要求 DE + PO 都以 sub-agent fresh-spawn 形式在本 invocation 内完成; 给出 plan.md 中 skip rationale 的 exact wording; 明示 "Default on doubt: run IR".
- [x] **T2 — `docs/workflow.md` IR blocks x2 cross-reference.** 两处 IR mermaid/prose 段落 (lines ~117-122 + ~169-174) 在 "Report written to docs/independent-review.md" 之后加 sub-bullet 指向 end-working.md Step 3 carve-out.
- [x] **T3 — `docs/collaboration-mode.md` step 3.5 lines x2.** Solo 变体 (line 51) 和 Agent Team 变体 (line 64) 的 step 3.5 各自加 carve-out 指针 (两变体 tail 文本不同, 所以分两次 edit).
- [x] **T4 — `docs/roles.md` IR trigger conditions.** Line 445 的 "Wave boundary" 条件扩写: "subject to the three-condition skip carve-out in commands/end-working.md Step 3", 列出三条件, 指明 mandatory rationale.
- [x] **T5 — `docs/design-decisions.md` new decision row.** 新增一行: Decision = 三条件 carve-out; Rationale = codify 6-Wave precedent, 消除跨 Wave audit trail 不一致; Rejected alternatives = (a) binary trigger (IR 总是跑) — 对 framework polish 是纯成本, (b) file-list whitelist — 白名单维护成本 + 新文件类型盲区. Origin = FR-19. Precedent = plan.md v0.7.5 line 884 "Why no Independent Reviewer" 表述.
- [x] **T6 — `CHANGELOG.md` [Unreleased] ### Changed** entry for FR-19 codification.
- [x] **T7 — `commands/end-working.md` Step 9 PR template line 116.** Independent Reviewer 行 bracket 内选项扩展为 `[Wave boundary PROCEED ✅ / carve-out skip — short reason / not triggered — reason]`, 让 carve-out skip 在 PR metadata 中有显式标签.

**Acceptance (5 commands, mixed [code] + [build] — trivial-CLI carve-out eligible):**

| # | Tag | Command | Expected | Actual |
|---|-----|---------|----------|--------|
| A1 | [code] | `grep -c "Skip carve-out (self-referential polish Wave)" commands/end-working.md` | 1 | 1 — PASS |
| A2 | [code] | `grep -c "Wave-boundary skip carve-out" docs/workflow.md` | 2 | 2 — PASS |
| A3 | [code] | `grep -c "three-condition skip carve-out" docs/roles.md` | ≥ 1 | 1 — PASS |
| A4 | [build] | `bash scripts/language-check.sh` | exit 0 | TBD (run in DE audit) |
| A5 | [build] | `bash scripts/policy-lint.sh` | exit 0 | TBD (run in DE audit item 10) |

**Files modified (7 + this plan.md entry):**
- `CHANGELOG.md` ([Unreleased] ### Changed)
- `commands/end-working.md` (Step 3 carve-out block + Step 9 PR template line)
- `docs/collaboration-mode.md` (step 3.5 Solo + Agent Team variants)
- `docs/design-decisions.md` (new row with rejected alternatives)
- `docs/plan.md` (this entry + tracker Wave 1 row + FR-19 Backlog removal)
- `docs/roles.md` (IR trigger condition expansion)
- `docs/workflow.md` (two IR block cross-references)

**Mode Selection Checkpoint.** Grouping: 5 Tier 1 framework files + 2 Tier 4 files (plan.md, CHANGELOG.md). Decomposable? 文件之间 cross-reference dependency 显著 — end-working.md Step 3 是 authoritative source, 其他 5 处都是 pointer, 顺序敏感. Volume? 小量 narrative + 1 new row in design-decisions table + 1 CHANGELOG 条目. Teammate coordination overhead (tmux spawn + prompt + wait + merge) strictly exceeds serial Edit cost. Decision: **Solo + Lead direct edit**. Precedent chain: v0.7.8 Polish, Wave A/B/C.

**Why Lead direct edit:** All target files under framework self-referential boundary (CLAUDE.md Development Rules). 无 Developer/Codex calls required.

**Why no Independent Reviewer at Wave boundary (dogfood of new carve-out):** 本 Wave 第一次 apply the new FR-19 carve-out, 同时也是其首次自验证. 三条件 check:
- (i) **No application-code files modified** ✓ — all 7 files 都在 Tier 1 (`commands/`, `docs/`) 或 Tier 4 (`plan.md`, `CHANGELOG.md`) 范围内, 无 app-code / hooks/ / scripts/*.sh / install.sh 等 runtime-sensitive 文件.
- (ii) **No new product-behavior surface** ✓ — carve-out codifies existing 6-Wave practice. 无新 command / role / skill / marker / convention name 引入. FR-19 只是把隐式规则显式化.
- (iii) **DE + PO sub-agent audits both run in this `/end-working` invocation** ✓ — 本次 /end-working 的 Step 5 PO audit + Step 9 pre-merge DE audit 两者都以 fresh sub-agent spawn 形式在本 invocation 内完成.

三条件全部满足 → carve-out applies → skip IR (sub-steps a–d of Step 3). **Why no IR at Wave boundary:** self-referential polish, no new product surface, DE+PO coverage sufficient — per commands/end-working.md Step 3 carve-out.

**BLOCKING marker rationale for next session (under the narrowed gate codified in PR #207):** This Wave did NOT modify `CLAUDE.md`. Target files: `commands/end-working.md`, `docs/{workflow,collaboration-mode,roles,design-decisions,plan}.md`, `CHANGELOG.md` — all Skill-invoked / on-demand-read, stale-cache risk structurally zero. Narrowed-gate trigger not met → **skip BLOCKING**. Next Wave may start in the same session if desired.

**Commit count verification (Rule 2 cadence):** Projected 1 non-merge commit on the Wave branch at `/end-working` time. Re-verification command: `git log --oneline --no-merges 567c325..HEAD | wc -l` — expected output: `1`. Base `567c325` is PR #218 merge commit (v0.8.0 session log close-out — this Wave's divergence base from main).

**Observation data entry:** see tracker Wave 1 row (above, in the v0.8.0 升级观察期 Tracker section).

**Next step:** 进入 Wave 2 继续收观察期数据. Wave 2 实际选择: 新增 `/doctor` slash command (product-surface Wave, 不在原 FR-20/FR-21 候选里) — 价值在于 Wave Boundary IR 首次以 real run 形式验证 `codex exec` in tmux pane 新路径, 同时为 observation period tracker 提供首行 Teammate 字面化真实数据点 (Teammate A on Opus 4.7).

### Wave 2 — `/doctor` Slash Command (2026-04-20) — Complete

Branch: `feat/doctor-command`. Mode: **Agent Team** (1 Teammate + Lead concurrent).

Context: 本 Wave 是 v0.8.0 升级观察期的第 3 个 Wave (Wave 0 = 升级本身, Wave 1 = FR-19 carve-out, Wave 2 = 本 Wave). 三合一目的: (a) 交付 product-surface feature (`/doctor` environment health check), (b) 为 observation tracker 产第 3 行 Teammate 字面化真实数据点, (c) 以 real Wave Boundary IR 命中 Release Gate 条件 2 的第 1 次真跑 (Wave 1 IR 按 FR-19 carve-out skip, Release Gate 要求 Waves 1/2/3 至少 3 次 real IR, 因此 Waves 2/3/4 必须都跑 IR).

**Goal:** 新增 `/doctor` 本地环境健康检查 slash command — 7 项离线检查 (tmux / Codex CLI / Claude Code / hook 文件完整性 / iSparto repo markers + BLOCKING 状态 / Codex config.toml 合理性 / VERSION ↔ git tag), 每项 PASS/WARN/FAIL + fix hint. 设计 scope: 无 `--fix` auto-remediation, 无 network probe, 无 `/start-working`/`/end-working` 耦合 — 纯只读本地诊断, 用户主动调用. 使用场景: 新机器首跑 / `install.sh --upgrade` 后 / 怀疑环境 rot (hook 不触发 / Codex MCP 超时 / tmux 命令失败).

**Task list:**

- [x] **T1 — `scripts/doctor-check.sh`** (Teammate A, Opus 4.7). Bash wrapper + python3 heredoc, D1-D7 七项检查 + `--self-test` (3 fixtures: all-pass / two-warn / one-fail) + `--help`. Stdout 格式: `[STATUS] D#: <name> — <detail>` + `(fix: ...)` 仅 WARN/FAIL, summary 行 `=== Summary: N PASS, M WARN, K FAIL / 7 total ===`. Exit codes: 0 (no FAIL) / 1 (any FAIL) / 2 (internal error). TTY-gated ANSI 颜色.
- [x] **T2 — `commands/doctor.md`** (Lead). Setup Assistant 角色, 语言检测指令, "When to use" 段 (新机器 / 升级后 / 环境 rot), "How to execute" 指向 `bash scripts/doctor-check.sh` (repo-local 优先, `$HOME/.isparto/` fallback), "What the script reports" 表 D1-D7 + exit code 语义, "Report to user" 段 (翻译 line 保留 tag/ID/fix 命令 verbatim, append verdict). "What /doctor does NOT do" scope exclusions.
- [x] **T3 — `docs/user-guide.md`** (Lead). "What You Initiate (8 Commands)" 升到 (9 Commands), 表格新增 `/doctor` 行 (位于 `/env-nogo` 和 `/restore` 之间), 新增 `## /doctor — Environment Health Check` 段落 (When to run it / line tag 含义 / 不做的事).
- [x] **T4 — `CLAUDE.md` Module Boundaries** (Lead). Slash Commands 数量 9 → 10; 新增 Doctor 行指向 `commands/doctor.md` + `scripts/doctor-check.sh`.
- [x] **T5 — `CHANGELOG.md` [Unreleased] ### Added** (Lead). `/doctor` slash command 条目, 7 项检查罗列, offline/network-free 声明.
- [x] **T6 — Wave Boundary IR (real run, not carve-out skip)** (via `codex exec` in tmux pane). 首次 real Wave Boundary IR in v0.8.0 observation period — 命中 Release Gate 条件 2 第 1 次真跑.
- [x] **T7 — DE + PO audits, pre-commit security scan, commit, PR, merge** (Lead). Standard /end-working flow.

**Acceptance (10 items):**

| # | Tag | Command | Expected | Actual |
|---|-----|---------|----------|--------|
| A1 | [code] | `ls scripts/doctor-check.sh commands/doctor.md` | 两文件存在 | 存在 — PASS |
| A2 | [code] | `test -x scripts/doctor-check.sh` | executable | PASS |
| A3 | [build] | `bash scripts/doctor-check.sh --self-test` | exit 0, 3 fixtures OK | exit 0, 3/3 OK — PASS |
| A4 | [build] | `bash scripts/doctor-check.sh` (real run, current repo) | 无 FAIL (all PASS/WARN) | 7 PASS / 0 WARN / 0 FAIL — PASS |
| A5 | [build] | `bash scripts/doctor-check.sh --help` | usage 文本 + exit 0 | PASS |
| A6 | [code] | `` grep -c "^| \`/doctor\` |" docs/user-guide.md `` | 1 | 1 — PASS (post-audit fix: pattern now backtick-escaped to match live table row) |
| A7 | [code] | `grep -c "Doctor " CLAUDE.md` (Module Boundaries row) | ≥ 1 | 1 — PASS |
| A8 | [build] | `bash scripts/language-check.sh` | exit 0 | PASS (Tier 1/2 CJK-clean + Principle 1 clean) |
| A9 | [build] | `bash scripts/policy-lint.sh` | exit 0 | PASS |
| A10 | [code] | `grep -c "/doctor" CHANGELOG.md` (Unreleased Added block) | ≥ 1 | PASS |
| A11 | [build] | `bash $HOME/.isparto/scripts/doctor-check.sh` from `/tmp` (fallback path) | 7 checks 执行, exit 0 或 1 (5 PASS + 2 WARN for non-repo cwd acceptable) | 5 PASS / 2 WARN (D5+D7) / 0 FAIL, exit 0 — PASS (post-IR-BLOCK-2 install.sh deploy verified end-to-end) |

**Files modified/added (7 + this plan.md entry):**
- `scripts/doctor-check.sh` (NEW, 883 行, Teammate A; D2/D3 multi-line sanitization + RC-capture fix applied post-IR-BLOCK-1)
- `commands/doctor.md` (NEW, Lead; D4 row scope wording fix applied post-IR-BLOCK-1)
- `docs/user-guide.md` (/doctor 表格行 + 独立段落, Lead)
- `CLAUDE.md` (Module Boundaries Slash Commands 计数 + Doctor 行, Lead)
- `CHANGELOG.md` ([Unreleased] ### Added 新增块, Lead; install.sh deployment note appended post-IR-BLOCK-2)
- `docs/product-spec.md` (Core Features slash-command 计数 8 → 9, Lead; applied post-IR-BLOCK-1)
- `install.sh` (deploy `scripts/doctor-check.sh` → `~/.isparto/scripts/doctor-check.sh` executable, Lead; applied post-IR-BLOCK-2 to satisfy `commands/doctor.md` documented fallback path)
- `isparto.sh` (`rm -rf "$ISPARTO_HOME/scripts"` added to uninstall cleanup, Lead; applied post-IR-BLOCK-2 for install.sh backward-compat rule)
- `docs/plan.md` (this entry + tracker Wave 2 row)

**Mode Selection Checkpoint.** Grouping: 1 新 bash/python script (独立文件, 无跨文件依赖) + 4 文档文件 (CLAUDE.md, user-guide.md, CHANGELOG.md, commands/doctor.md). Decomposable? Yes — `scripts/doctor-check.sh` 实现细节 (7 check 的 shell/python 逻辑) 与 `commands/doctor.md` 的 Setup Assistant 指令是正交的, 通过 stdout 契约 (line format + D1-D7 IDs + exit codes + --self-test 结构) 解耦. Volume? 单 script ~900 行 + 4 文档中等篇幅. Teammate coordination overhead (spawn + 接口契约说明 + 等待 + merge) < 并发节省. Decision: **Agent Team** — Teammate A (scripts/doctor-check.sh only) + Lead concurrent (commands/doctor.md + CLAUDE.md + user-guide.md + CHANGELOG.md). 接口契约 upfront 由 Lead 在 Teammate 启动 prompt 中明确声明 (stdout 格式, 7 check IDs 及语义, exit codes, --self-test fixtures 结构).

**Why Agent Team (not Solo):** 用户在 Wave kickoff 明确要求 "优先 Agent Team, 能并发就并发, 不要无脑 Solo". 本 Wave 是观察期 Wave 2, 首次 Teammate 字面化真实数据点 (Wave 0/1 均为 Solo + Lead direct edit, Teammate 列均为 N/A). 业务价值: 收集 Opus 4.7 on Teammate 角色的 instruction-following 数据 (字面化 vs 推理化行为), 为 v0.8.0 升级观察期 tracker 补齐 Teammate 列的首行真实数据.

**Why real Independent Reviewer at Wave boundary (not FR-19 carve-out skip):** 用户明确要求 "Wave Boundary IR 必须真实跑, 不走 FR-19 skip". 三条件 check: (i) 本 Wave 引入 application-code (`scripts/doctor-check.sh` — 可执行 script, non-trivial Python 逻辑) → 条件 (i) 失败 → carve-out 不适用; (ii) 引入 new product-behavior surface (`/doctor` 是新 slash command, 新用户命令接口) → 条件 (ii) 失败; (iii) DE+PO sub-agent audits 会跑, 条件 (iii) 满足. 任一条件失败 → revert default "run IR" → 真实调用 Codex CLI in tmux pane. Release Gate 关联: v0.8.0 release 要求 Waves 1/2/3 至少 3 次 real IR, Wave 1 按 carve-out skip (正当), 因此 Waves 2/3/4 必须都跑 real IR (本 Wave 是第 1 次真跑).

**BLOCKING marker rationale for next session:** This Wave modified `CLAUDE.md` (Module Boundaries 新增 Doctor 行, Slash Commands 计数 9 → 10). Under the narrowed gate (PR #207): decision aid (a) "Behavior change?" — 新增 product surface (Doctor module + commands/doctor.md 作为新 slash command), 虽非 behavior rule 变更, 但属于 structural 变更影响 `# claudeMd` cache 读取的模块声明内容. 答案: 是 (structural behavior surface added). 决策: **emit BLOCKING** — 下个 session 需要 fresh `# claudeMd` 读取以感知新 Doctor 模块和 10-command 计数. 实现: `/end-working` Step 2 的 BLOCKING 标记 + `/start-working` Step 0 acknowledgement 协议.

**Commit count verification (Rule 2 cadence):** Projected 1 non-merge commit on the Wave branch at `/end-working` time (all Wave 2 changes — including the two post-IR-BLOCK fix rounds: Round 1 on `scripts/doctor-check.sh` D2/D3, `commands/doctor.md` D4 wording, `docs/product-spec.md` command count; Round 2 on `install.sh` deploy + `isparto.sh` uninstall cleanup + CHANGELOG note — ship as one atomic `/end-working` commit, no intermediate commits landed). Re-verification command: `git log --oneline --no-merges 66a4aa9..HEAD | wc -l` — expected output: `1`. Base `66a4aa9` is PR #219 merge commit (Wave 1 FR-19 carve-out — this Wave's divergence base from main).

**Observation data entry:** see tracker Wave 2 row (above, in the v0.8.0 升级观察期 Tracker section) — Teammate 字面化列为 v0.8.0 观察期首行真实数据点.

**Next step:** Wave 3 继续收观察期数据, 且必须跑 real Wave Boundary IR (Release Gate 条件 2 第 2 次真跑). 候选: FR-20 + FR-21 (两者结构对称, 都是 one-line 规则补全, 可合并为 1 Wave)或其他 Backlog FR 中等优先级项.

🚨 BLOCKING: Next Wave requires NEW SESSION
> ✅ Session boundary acknowledged 2026-04-20 by /start-working

> Rationale (per the narrowed gate codified in PR #207): This Wave modified `CLAUDE.md` Module Boundaries (Slash Commands count 9 → 10 + new Doctor row). Decision aid: (a) Behavior change? — new `/doctor` product-surface introduced, structural change to the `# claudeMd` module-declaration content; (b) New identifier? — yes, "Doctor" module row + `commands/doctor.md` + `scripts/doctor-check.sh` references; (c) Contract/interface change? — 10-command inventory (up from 9) changes the surface Lead announces at session-start. Default on doubt = emit BLOCKING. Marker forces fresh session so the next Lead picks up the updated `# claudeMd` cache before planning Wave 3.

### Wave 3 — `/start-working` Session Health Preview + FR-26 DE 机械 re-execute + FR-27 PO tracker 结算 (2026-04-20) — Complete

Branch: `feat/wave-3`. Mode: Agent Team (3 Teammates concurrent + Lead concurrent).

Context: v0.8.0 升级观察期 Wave 3 (observation tracker 第 4 行). 打包三件事: (a) **主任务** — `/start-working` Step 9 B-layer briefing 增加 4th 固定结构 "Session Health Preview" 块 + 新建 `scripts/session-health.sh` 脚本 (branch / last commit / uncommitted files / BLOCKING marker / observation period 5 项 mechanical 提取, 仿 `scripts/doctor-check.sh` bash+python3 结构); (b) **Sub-task A (FR-26)** — Doc Engineer audit 机械 re-execute grep/bash 风格 acceptance assertions 规则 (`docs/roles.md` audit item 3 新增 sub-bullet + `commands/end-working.md` Step 9 cross-reference), 源自 Wave 2 A6 事件 (recorded `grep -c "^| /doctor |"` 返回 `1` 但 live re-execution 返回 `0` 因 backtick quoting 细节); (c) **Sub-task B (FR-27)** — Process Observer audit E6 check (observation-period tracker row 已填验证 with IN-PROGRESS/FAIL/PASS/N/A classification + resolution timing note).

**Tasks completed:**
- T1 `scripts/session-health.sh` (NEW, bash+python3, `--help`/`--self-test`, 3/3 fixtures PASS)
- T2 `commands/start-working.md` Step 9 扩展 (4th structure "Session Health Preview" block + C-layer carve-out paragraph)
- T3 `docs/roles.md` audit item 3 新增 FR-26 acceptance 机械 re-execution rule (whitelist: grep/wc/git log/git diff --stat/bash --self-test/bash --help; exclude: git commit/push/gh pr create/state-mutating)
- T4 `commands/end-working.md` Step 9 cross-reference FR-26
- T5 `agents/process-observer-audit.md` 新增 E6 row (tracker row 已填 check) + resolution timing note
- T6 `docs/plan.md` FR-27 placeholder 结算 timing 规则 prose (observation tracker 上方, 4 条规则: Transition 时机 / 不可逆原则 / Partial revert 路径 / N/A 行)
- T7 `docs/plan.md` Backlog FR-26/FR-27 rows 移除 (已在 Wave 3 解决)
- T8 `docs/plan.md` Backlog 新增 FR-28 (`language-check.sh` 缺 fenced-code exemption — Teammate C FR-27 实现时实证发现)
- T9 `docs/plan.md` tracker Wave 3 行填入 (FR-27 rule 首次 in-Wave dogfood)
- T10 `CHANGELOG.md` `[Unreleased]` 3 条 (Added: Session Health Preview + scripts/session-health.sh; Changed: FR-26 DE re-execute; Changed: FR-27 PO tracker check)

**Acceptance (FR-26 dogfood — mechanical re-execute rule 本 Wave 自 verify, DE Step 9 pre-merge audit 会再次机械 re-run 这些 assertion):**
- `bash scripts/session-health.sh --self-test` — 退出码 `0`, stdout 末行包含 `PASSED: session-health.sh --self-test (3/3 fixtures OK)`
- `grep -c "Session Health Preview" commands/start-working.md` — 期望 `>=3` (Step 9 preamble + block heading 说明 + C-layer carve-out 引用)
- `grep -c "Acceptance re-execution rule (FR-26)" docs/roles.md` — 期望 `1` (单一 sub-bullet placement under audit item 3)
- `grep -c "acceptance re-execution rule defined in" commands/end-working.md` — 期望 `1` (Step 9 cross-reference sentence)
- `grep -c "^| E6 |" agents/process-observer-audit.md` — 期望 `1` (E6 row 行首唯一)
- `grep -c "Note on E6 resolution timing" agents/process-observer-audit.md` — 期望 `1` (timing note 段落)
- `bash scripts/language-check.sh` — 退出码 `0` (Tier 1/Tier 2 CJK-clean + Principle 1 clean)
- `bash scripts/policy-lint.sh` — 退出码 `0` (无 ceremonial wrappers)

**Files modified/added (7 + this plan.md entry):**
- `scripts/session-health.sh` (NEW, 24 KB bash+python3, Teammate A; executable, 3/3 self-test fixtures)
- `commands/start-working.md` (Step 9 4th structure + C-layer carve-out, Teammate A)
- `docs/roles.md` (FR-26 rule sub-bullet under audit item 3, Teammate B)
- `commands/end-working.md` (Step 9 cross-reference to FR-26, Teammate B)
- `agents/process-observer-audit.md` (E6 check row + E6 resolution timing note, Teammate C)
- `docs/plan.md` (tracker FR-27 timing prose + Backlog FR-26/27 removal + FR-28 add + tracker Wave 3 row fill + this Wave entry, Lead)
- `CHANGELOG.md` (`[Unreleased]` 3 条目, Lead)

**Mode Selection Checkpoint.** Grouping: 3 个独立 Tier 1 file group 互不重叠 — Teammate A: `scripts/session-health.sh` + `commands/start-working.md` Step 9 专属; Teammate B: `docs/roles.md` audit item 3 + `commands/end-working.md` Step 9 专属; Teammate C: `agents/process-observer-audit.md` E-series 新增 row 专属; Lead concurrent: `docs/plan.md` 所有 edit + `CHANGELOG.md`. Decomposable? Yes — 三个 sub-task 产品语义正交 (product-behavior surface 新增 vs DE audit rule 新增 vs PO audit check 新增), 无 runtime 耦合; file ownership 严格不重叠 (Lead 保留 plan.md 独占, 0 冲突). Volume? 三 task 各中等 (新建 24KB script + 单段 rule + 单 row/note), 并发节省 (三 Teammate 总 wall-clock ~8 分钟, Teammate A 最长) > dispatch overhead (3 × agent spawn prompt 编写 + 结果 verify + guardian 跑). Decision: **Agent Team** — 3 Teammates concurrent + Lead concurrent. 接口契约 (file ownership group + acceptance grep + out-of-scope 声明) 由 Lead 在每个 Teammate 启动 prompt 中显式列出 (无隐式假设).

**Why Agent Team (not Solo):** 用户在 Wave kickoff 显式 "Mode: Agent Team 优先. 本 Wave 有三个独立 file group ... Mode Selection Checkpoint 认真评估, 能并发就并发, 不要无脑 Solo". 业务价值: 观察期 Wave 3 首次 triple-Teammate 并发, 为 tracker Teammate 字面化列补充 Agent Team 模式下 Opus 4.7 的 semantic-reasoning 数据点 (Wave 2 单 Teammate + Wave 3 三 Teammate 并发对比, 观察 "是否 Teammate 数量增加会放大字面化风险"; 数据结果显示 3/3 均 semantic 非字面化, 本 Wave 反向为 Teammate 字面化是偶发而非常态提供反证).

**Why real Independent Reviewer at Wave boundary (not FR-19 carve-out skip):** 用户明确 "Wave Boundary IR 必须真实跑, 不走 FR-19 skip" (Release Gate 条件 2 要求 Waves 2/3/4 累计 3 次 real IR 才解锁 v0.8.0 `/release`; Wave 1 按 FR-19 carve-out 合理 skip 不计入 3 次, Wave 2 首次 real = 1/3, 本 Wave 是第 2 次 = 2/3). 三条件 check: (i) 本 Wave 引入 application-code (`scripts/session-health.sh` — 新建 600+ 行 bash+python3 可执行) → 条件 (i) 失败 → carve-out 不适用; (ii) 引入 new product-behavior surface (`## Session Health Preview` 是 Step 9 briefing 的新 user-facing 结构 + 新 script 命令接口) → 条件 (ii) 失败; (iii) DE+PO sub-agent audits 会跑, 条件 (iii) 满足. 任一条件失败 → revert default "run IR" → 真实调用 `codex exec` in tmux pane.

**BLOCKING marker rationale for next session:** This Wave did **NOT** modify `CLAUDE.md` (files touched per `git diff HEAD --stat`: `scripts/session-health.sh` NEW + `commands/start-working.md` + `docs/roles.md` + `commands/end-working.md` + `agents/process-observer-audit.md` + `docs/plan.md` + `CHANGELOG.md` — all Tier 1 non-CLAUDE.md or Tier 4 forward-looking). Per `/end-working` Step 2 BLOCKING gate, marker decision applies **only** when `CLAUDE.md` is modified in the Wave (因为 `CLAUDE.md` 是唯一被 Claude Code 注入 session-start system prompt 的文件). 本 Wave 无 `CLAUDE.md` 变更 → skip BLOCKING marker 整个. 不属于 "skip-with-rationale" 情况 (rationale 要求附加在 `CLAUDE.md`-touching Wave 且决策三问全 "no" 的场景, 本 Wave 是 `CLAUDE.md`-untouched → 无 marker, 无 rationale 块).

**Commit count verification (Rule 2 cadence):** Projected 1 non-merge commit on the Wave branch at `/end-working` time (all Wave 3 changes — three Teammates 工作成果 + Lead concurrent plan.md/CHANGELOG edit — ship as one 原子 `/end-working` commit, 无中间 commit land). Re-verification command: `git log --oneline --no-merges 660a033..HEAD | wc -l` — expected output: `1`. Base `660a033` is PR #220 merge commit (Wave 2 /doctor — this Wave's divergence base from main).

**Observation data entry:** see tracker Wave 3 row (above, in the v0.8.0 升级观察期 Tracker section) — 3-Teammate semantic-reasoning data point (全 3/3 展示 semantic 推理非字面化, Teammate C 甚至主动反驳 task brief 错误前提并推动 FR-28 新增), IR real-run 第 2 次 (累计 2/3 达到 Release Gate 条件 2 所需), 新增 3 个 Backlog — FR-28 (`language-check.sh` fenced-code exemption gap — Teammate C implementation discovery) + FR-29 (`/end-working` Step 3 IR vs Step 4 session-log parallel-edit race — surfaced by this `/end-working` IR round-1 halt → round-2 PROCEED arc) + FR-30 (CLAUDE.md Module Boundaries first-party `scripts/*.sh` asymmetry — DE pre-merge audit MINOR).

**Next step:** Wave 4 继续收观察期数据, 必须跑 real Wave Boundary IR (Release Gate 条件 2 第 3 次真跑达到 3/3 → 条件 2 满足; 连同条件 1 5-Wave 观察期完成和条件 3 无 emergency revert, 解锁 v0.8.0 `/release patch`). 候选: Backlog FR 中等优先级项 (FR-5 `language-check` Principle 1 detector 完善 / FR-13 gh alignment mid-session guard / FR-24 PO audit checklist 显式化 — 三者均为 framework polish 但引入 application-code 或新 product surface 的概率低, 需要结合产品 / 文档任务打包以确保 carve-out 三条件中 (i) 或 (ii) 失败触发真 IR; 或选 FR-28 但该项 priority low 不优先). Wave 5 = 观察期最后一 Wave.

### Wave 4 — FR-13 gh 账户 mid-session guard + FR-24 PO audit canonical 18-row enumeration (2026-04-20) — Complete

Branch: `feat/wave-4`. Mode: Agent Team (2 Teammates concurrent + Lead concurrent).

Context: v0.8.0 升级观察期 Wave 4 (observation tracker 第 5 行 = 观察期倒数第二 Wave). 合并执行两 Backlog FR 为一个 Wave (用户明确 "不走 Wave 4 / Wave 5 拆分, Wave 4 = FR-13 + FR-24 合并执行", 保留原 5-Wave 观察期设计): (a) **Track A (FR-13 gh 账户 mid-session drift guard)** — `/start-working` Step 6 和 `/end-working` Step 8 的 gh 账户 alignment 只在 session 两端各执行一次, 用户在 session 中间手动 `gh auth switch` 或 DE re-audit loop 横跨长时间时账户可能翻转, subsequent `gh pr create` 会以错误身份发起 PR (fork attribution error 或直接失败). 新建 `scripts/gh-account-guard.sh` 脚本 (bash+python3 结构, 527 行, `--help`/`--self-test`/unknown-arg→exit 2, 3 fixtures: aligned / mismatch-auto-recovers / mismatch-unrecoverable), 在 `commands/end-working.md` Step 9 `gh pr create` 紧前调用: exit 0 silent proceed / exit 2 A-layer intercept 阻断 PR creation. Portability 硬约束 (用户在 Wave kickoff 追加): "gh guard 必须在 iSparto fork+clone 后即生效, 不依赖 user-level ~/.claude/settings.json". Teammate 用 `git ls-files .claude/` 实证排除 project-level PreToolUse hook 路径 (返回空 = `.claude/settings.json` 非 repo-tracked), 最终 scripts/ + commands/ 双件组合; (b) **Track B (FR-24 PO audit canonical checklist 显式化)** — `agents/process-observer-audit.md` 原描述"14 standard checks"但模板只显式列 A1-A3 + F1 (其余 B/C/D/E 子项需 per-invocation 从 spawn prompt 推断), 导致 audit 覆盖跨 invocation 不一致 (Wave 2 PO report 13 行 vs Wave 3 PO report 18 行). 把 canonical checklist 显式化为 18 行 (A1-A3 / B1-B2 / C1-C2 / D1-D4 / E1-E6 / F1), state-set per row 显式声明 (PASS/FAIL, PASS/WARN, PASS/IN-PROGRESS/FAIL, PASS/IN-PROGRESS/FAIL/N/A), Summary 总计增加 `X + Y + Z + W == 18` count-check 与 `Meta: row-count mismatch` FAIL-level meta-deviation 规则 (后者放 Rule Corrections section 避免 double-count), 7 scope bullets 收敛到 6 letters (E category 吸收 "Unauthorized operations" + "plan.md accuracy").

**Tasks completed:**
- T1 `scripts/gh-account-guard.sh` (NEW, Track A Teammate, bash+python3 结构 527 行, 3/3 self-test fixtures PASS, `--help`/`--self-test`/`--bogus` 行为齐全, executable)
- T2 `commands/end-working.md` Step 9 新增 gh 账户 mid-session guard bullet (Track A Teammate, +4 行, 位于 DE re-audit loop 完成与 `gh pr create` 之间, exit 0 silent / exit 2 A-layer intercept / script-absent silent-skip 三分支)
- T3 `agents/process-observer-audit.md` preamble 增加 `Canonical checklist coverage: 18 rows` + A-F scope-to-letter mapping 表 (Track B Teammate, role 描述与 scope bullets 之间新增 6 行映射表)
- T4 `agents/process-observer-audit.md` canonical 18-row explicit enumeration (Track B Teammate, 原 5 explicit rows + `| ... |` placeholder → 18 explicit rows A1-A3/B1-B2/C1-C2/D1-D4/E1-E6/F1)
- T5 `agents/process-observer-audit.md` Summary 行 `X + Y + Z + W + V == 18` count-check (含 V = N/A bucket) + Meta: row-count mismatch FAIL 规则 (Track B Teammate 初版 4-bucket + Lead round-1 IR BLOCK 后 in-session fix 加 V bucket, Summary 紧后 + Rule Corrections Framework-side 路由, 非新增 table row)
- T6 `agents/process-observer-audit.md` 7→6 scope-bullets 收敛 (Track B Teammate, E category 吸收 "Unauthorized operations" + "plan.md accuracy" 两条旧 bullet 到 E1-E6 子行)
- T7 `docs/plan.md` Wave 4 entry + tracker 第 5 行 + Backlog FR-31/FR-32 新增 (Lead, 本文件本 entry + 上方 tracker row + 下方 Framework Rule Polish 两行)
- T8 `CHANGELOG.md` `[Unreleased]` 2 条 (Added: gh-account-guard mid-session guard; Changed: PO audit canonical 18-row enumeration)

**Acceptance (FR-26 dogfood — 机械 re-execute assertions, DE Step 9 pre-merge audit 会再次机械 re-run):**
- `bash scripts/gh-account-guard.sh --self-test` — 退出码 `0`, stdout 末行包含 `PASSED: gh-account-guard.sh --self-test (3/3 fixtures OK)`
- `bash scripts/gh-account-guard.sh --help` — 退出码 `0`, stdout 含 `Usage:` 与 `Exit codes:` 两 header
- `bash scripts/gh-account-guard.sh --bogus` — 退出码 `2`, stderr 含 `unknown argument`
- `test -x scripts/gh-account-guard.sh` — 脚本 executable
- `grep -c "gh-account-guard" commands/end-working.md` — 期望 `2` (1 调用 bullet + 1 stale-install fallback 提示)
- `grep -c "Canonical checklist coverage: 18 rows" agents/process-observer-audit.md` — 期望 `1` (preamble)
- `grep -cE "^\| [A-F][0-9]+ \|" agents/process-observer-audit.md` — 期望 `18` (A1-A3/B1-B2/C1-C2/D1-D4/E1-E6/F1 canonical 18 行总计)
- `grep -c "^| A1 |" agents/process-observer-audit.md` — 期望 `1`
- `grep -c "^| E6 |" agents/process-observer-audit.md` — 期望 `1` (Wave 3 codified, 继续存在)
- `grep -c "^| F1 |" agents/process-observer-audit.md` — 期望 `1`
- `grep -c "Meta: row-count mismatch" agents/process-observer-audit.md` — 期望 `>=1` (Summary 紧后的 meta-deviation 规则)
- `grep -c "Summary total count-check (FR-24 enforcement)" agents/process-observer-audit.md` — 期望 `1`
- `grep -c "V not-applicable" agents/process-observer-audit.md` — 期望 `1` (Summary 5-bucket 格式含 N/A)
- `grep -c "X + Y + Z + W + V == 18" agents/process-observer-audit.md` — 期望 `1` (count-check 5-bucket 总等式, IR round-1 BLOCK 后 in-session fix 所得)
- `bash scripts/language-check.sh` — 退出码 `0` (Tier 1/Tier 2 CJK-clean + Principle 1 clean)
- `bash scripts/policy-lint.sh` — 退出码 `0` (无 ceremonial wrappers)

**Files modified/added (3 framework files + this plan.md entry + CHANGELOG.md):**
- `scripts/gh-account-guard.sh` (NEW, 527 行 bash+python3, Track A Teammate, executable)
- `commands/end-working.md` (Step 9 +4 行, Track A Teammate)
- `agents/process-observer-audit.md` (+49/-12 行, Track B Teammate)
- `docs/plan.md` (Wave 4 entry + tracker 第 5 行 + Backlog FR-31/FR-32, Lead)
- `CHANGELOG.md` (`[Unreleased]` 2 条, Lead)

**Mode Selection Checkpoint.** Grouping: 2 个独立 file group 互不重叠 — Track A Teammate: `scripts/gh-account-guard.sh` + `commands/end-working.md` Step 9 专属 (gh 账户 guard 产品实现); Track B Teammate: `agents/process-observer-audit.md` 专属 (PO audit template codification); Lead concurrent: `docs/plan.md` + `CHANGELOG.md`. Decomposable? Yes — 两 sub-task 产品语义完全正交 (gh 账户 session-boundary guard vs PO audit template clarity), 无 runtime 耦合, 无 import/reference 交叉; file ownership 严格不重叠 (Lead 保留 `docs/plan.md` + `CHANGELOG.md` 独占, 0 冲突). Volume? 两 task 均中等规模 (新建 527 行 bash+python3 script + 单文件 canonical enumeration ~50 行 delta), 并发节省 (两 Teammate wall-clock ~5-7 分钟) > dispatch overhead (2 × agent spawn prompt 编写 + 结果 verify + guardian 跑). Decision: **Agent Team** — 2 Teammates concurrent + Lead concurrent. 接口契约 (file ownership group + acceptance grep + Track A portability 硬约束 / Track B Wave 2/3 PO report 对比要求) 由 Lead 在每个 Teammate 启动 prompt 中显式列出, 无隐式假设.

**Why Agent Team (not Solo):** 两 track 产品语义正交 + 总 delta ~700 行代码/文档, 并发收益显著. 业务价值二: (1) 观察期 Wave 4 Teammate 字面化数据点累积 (Wave 2 单 Teammate 两种字面化 / Wave 3 triple-Teammate 全 semantic + Teammate C 主动反驳错误前提 / Wave 4 dual-Teammate 全 semantic + Track A portability 语义→实证 positive case) 为 "Opus 4.7 在 Teammate 角色下 semantic reasoning 能力稳定" 补第 3 个 positive data point; (2) 用户明确在 kickoff "Agent Team mode 两条 track 并行", 不 override.

**Why real Independent Reviewer at Wave boundary (not FR-19 carve-out skip):** 用户明确 "双触发 FR-19 (i)(ii), real IR 必跑, 凑 3/3" — Release Gate 条件 2 要求 Waves 1/2/3 累计 3 次 real IR (Wave 1 FR-19 carve-out 合理 skip 不计入, Wave 2 首次 real = 1/3, Wave 3 = 2/3, 本 Wave = 3/3 达标). 三条件 check: (i) 本 Wave 引入 application-code (`scripts/gh-account-guard.sh` 新建 527 行 bash+python3 可执行 — 同 Wave 2 `doctor-check.sh` / Wave 3 `session-health.sh` 定性) → 条件 (i) 失败 → carve-out 不适用; (ii) 引入 new product-behavior surface (新 `scripts/gh-account-guard.sh` 命令接口对外可见 + `commands/end-working.md` Step 9 新 guard bullet 引入新的 "gh pr create 前置 guard probe" 行为 Lead 必须识别) → 条件 (ii) 失败; (iii) DE+PO sub-agent audits 会跑, 条件 (iii) 满足. 任一条件失败 → revert default "run IR" → 真实调用 `codex exec` in tmux pane. Focus review 本 Wave 特别点名 (用户 directive): (a) Track B canonical 18 rows + 6 letters 收敛 + Meta-FAIL 规则的内部一致性, (b) Track A `scripts/gh-account-guard.sh` 与 `end-working.md` Step 9 guard bullet 的调用时序与 exit code 冒泡.

**BLOCKING marker rationale for next session:** This Wave did **NOT** modify `CLAUDE.md` (`git diff HEAD --stat` 触碰文件: `scripts/gh-account-guard.sh` NEW + `commands/end-working.md` + `agents/process-observer-audit.md` + `docs/plan.md` + `CHANGELOG.md` — 均为 Tier 1 非 `CLAUDE.md` 或 Tier 4 forward-looking). Per `/end-working` Step 2 BLOCKING gate, marker decision applies **only** when `CLAUDE.md` is modified in the Wave (因为 `CLAUDE.md` 是唯一被 Claude Code 注入 session-start system prompt 的文件). 本 Wave 无 `CLAUDE.md` 变更 → skip BLOCKING marker 整个. 不属于 "skip-with-rationale" 情况 (rationale 要求附加在 `CLAUDE.md`-touching Wave 场景, 本 Wave 是 `CLAUDE.md`-untouched → 无 marker, 无 rationale 块).

**Commit count verification (Rule 2 cadence):** Projected 1 non-merge commit on the Wave branch at `/end-working` time (all Wave 4 changes — 两 Teammate 工作成果 + Lead concurrent plan.md/CHANGELOG edit — ship as one 原子 `/end-working` commit, 无中间 commit land). Re-verification command: `git log --oneline --no-merges 0f2a882..HEAD | wc -l` — expected output: `1`. Base `0f2a882` is PR #221 merge commit (Wave 3 Session Health Preview — this Wave's divergence base from main).

**Observation data entry:** see tracker Wave 4 row (above, in the v0.8.0 升级观察期 Tracker section) — dual-Teammate semantic-reasoning data point (2/2 均 semantic 非字面化, Track A Teammate portability 硬约束 语义→实证 (`git ls-files .claude/` 实测) 是本观察期累计的第 3 个"语义判断成功" positive case). IR real-run 第 3 次 **arc = BLOCK (1 MAJOR, Meta-FAIL 规则与 N/A 状态不协调 — 多行 status set 含 N/A 但 Summary 等式只有 4 bucket, 会导致合法 N/A 触发 false meta-failure) → in-session fix (Lead 直接加 V=not-applicable bucket, `X+Y+Z+W+V == 18`, N/A 为一级稳定状态) → round-2 PROCEED** (累计 3/3 → **Release Gate 条件 2 满足**). 特别注意: IR round-1 的 MAJOR finding 恰好落在用户 Wave kickoff 直接点名的 focus review 区域 "Track B Meta-FAIL 规则的内部一致性" — 用户语义 focus 与 IR 独立发现一致, Lead in-session fix 不 defer (feedback_no_defer_framework_polish.md). 本 Wave 新增 2 个 Backlog: **FR-31** (owner-extraction regex 在 `/start-working` Step 6 + `/end-working` Step 8 + `scripts/gh-account-guard.sh` 三处重复, DRY gap, priority low) + **FR-32** (`docs/roles.md` "14 checks total" + `docs/process-observer.md` 15-row enumeration 与 canonical 18 stale, priority medium, 按用户 direction 延后至 v0.9 + plan.md 膨胀治理 session 合并处理, 零额外成本).

**Next step:** Wave 5 = 观察期最后一 Wave (第 6 行 tracker). Release Gate 条件 2 已在本 Wave 满足 (3/3 real IR), Wave 5 的 IR 是"加固 + 数据补强"非"门槛前置". Wave 5 结束后如三条件全满足 (5-Wave 观察期累计同字段异常 < 2 行 + 3 次 real IR + 无 emergency revert), 新 session 运行 `/release patch` 触发 v0.8.0. Wave 5 选题候选 (由用户新 session 决定): Backlog 剩余 medium-priority FR (FR-5 `language-check` Principle 1 detector / FR-18 BLOCKING atomic-write / FR-22/23 BLOCKING 非 Wave session 扩展 / FR-32 本 Wave 产出但延后项) — 均 framework polish, 需确保至少一项触发 carve-out (i) 或 (ii) 失败以跑第 4 次 real IR (数据补强, 非 gate 要求).

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

### Backlog

All deferred TODOs, framework rule-fix candidates, and open commitments live here. This is the **single source** of forward work for iSparto. Writing new backlog-type content into any other file — `docs/framework-feedback-*.md` (pattern retired 2026-04-17), memory entries, `docs/session-log.md` "next-session" prose, Wave-entry "Out of scope" paragraphs — is a workflow violation. Any new item surfaced in a session (PO audit rule gap, user-direction commitment, Wave-internal deferral) must land in one of the three tables below. Additions are per-session; no periodic audit of this list is required, but `/end-working`'s TODO-homing check guards against content landing elsewhere.

#### Framework Rule Polish

Open framework rule refinement candidates surfaced by Process Observer audits across 2026-04 sessions. Addressed rules (closed in-session by later Waves) are not listed here — see the original session-log entries for historical provenance. The 11 `docs/framework-feedback-*.md` dated files were retired 2026-04-17 (their open rules migrated to this table; their addressed rules were already closed in earlier Waves).

| # | Gap | Fix target | Priority | Origin |
|---|-----|------------|----------|--------|
| FR-1 | Mode Selection Checkpoint declaration exists only in session dialogue, not as a durable audit-trail artifact | PR body template + CLAUDE.md Mode Selection Checkpoint documentation | high | feedback-0405 F1 |
| FR-2 | PR test plan cannot distinguish whether Process Observer ran as independent sub-agent or Lead self-assessed — blocks audit verification of sub-agent independence | `commands/end-working.md` Step 4 + PR body template | high | feedback-0405 F2 |
| FR-3 | CLAUDE.md does not clarify whether Doc Engineer should trigger for ad-hoc bug-fix sessions that complete no Wave | CLAUDE.md Development Rules (Doc Engineer trigger condition) | low-to-medium | feedback-0405b |
| FR-4 | CLAUDE.md rule does not specify what to do when a fix doesn't correspond to any plan.md entry | CLAUDE.md Development Rules (plan.md update exception) | low-to-medium | feedback-0405b |
| FR-5 | `scripts/language-check.sh` detects CJK violations but Principle 1 detector misses some literal English user-facing strings in Tier 1 files (heuristic has false-negative edge cases) | `scripts/language-check.sh` — second-pass refinement for residual quoted-English cases in Report/Inform/Output contexts | medium-to-high | feedback-0407 Sug3 |
| FR-6 | CLAUDE.md four-tier language architecture does not clarify whether forward-looking sections of `docs/plan.md` should follow Tier 2 (English-only) or Tier 4 (frozen mixed-language) — partially addressed inline in 2026-04-17 Tier-4 annotation, but a direct one-liner in the convention would close the gap fully | CLAUDE.md Documentation Language Convention Tier 4 section | low | feedback-0407c |
| FR-7 | CLAUDE.md enforces strict per-task plan.md updates but practice has settled on bulk T10/Wave-close updates — decision needed to align rule with practice (relax rule, or add mechanical hook to enforce per-task) | CLAUDE.md Development Rules plan.md update cadence | medium | feedback-0408 Rule 2 |
| FR-8 | CLAUDE.md self-referential boundary clause lists framework directories but should enumerate root-level Tier 1 files explicitly (CLAUDE.md, bootstrap.sh, install.sh, isparto.sh) — partially addressed 2026-04-17; confirm language precision complete | CLAUDE.md "This project is the framework itself" clause | low | feedback-0408-b Rule 1 |
| FR-9 | No emergency/hotfix exception path documented for Doc Engineer audit — v0.7.1 BSD-sed hotfix skipped audit under an assumed (nonexistent) exception | CLAUDE.md Solo/Agent Team workflow step 4 + `docs/workflow.md` Hotfix Workflow — add emergency exception with explicit criteria (≤3 changed files, Tier 1 shell scripts + CHANGELOG, explicit user emergency context) | medium | feedback-0408-b Rule 2 |
| FR-10 | `docs/workflow.md` Hotfix Workflow section omits Doc Engineer audit requirement, making it appear optional to a first-time reader | `docs/workflow.md` Hotfix Workflow — add cross-reference to Solo/Agent Team step 4 audit requirement (and to FR-9's exception once added) | low | feedback-0408-b Rule 3 |
| FR-11 | CLAUDE.md Branch Protocol forbids commits to main but does not explicitly forbid Edit/Write tool invocations on main before branch creation | CLAUDE.md Branch Protocol — add explicit language and name the recovery path (git checkout -b before committing) | low | feedback-0409 Rule 1 |
| FR-12 | `agents/process-observer-audit.md` A-series branch checks do not explicitly audit Edit/Write tool invocations on main — relies on Lead self-report | `agents/process-observer-audit.md` A3 — add check distinguishing "commit on main" (strong violation) from "Edit/Write invoked on main before branch creation" (weak but still violation) | low | feedback-0409 Rule 2 |
| FR-13 | `gh` account alignment snapshot at `/start-working` Step 6 becomes stale if PR creation happens mid-session outside `/end-working`, allowing account drift | CLAUDE.md Solo/Agent Team workflow step 6 — add inline gh alignment guard before mid-session `gh pr create` (mirror of `/end-working` Step 8 logic) | medium | feedback-0409-b |
| FR-14 | Wave-level batch-review safety-net sentence in `docs/workflow.md` reads unconditional but Implementation Protocol exception for self-referential edits exists at clause level, creating audit confusion | `docs/workflow.md` Wave-level safety-net — add parenthetical carve-out for self-referential boundary | medium | feedback-0409-c F1 |
| FR-15 | `agents/process-observer-audit.md` A3 detection guidance assumes reflog alone verifies branch-checkout ordering, but pre-commit verification requires a two-source check (reflog + session context) | `agents/process-observer-audit.md` A3 row detection sentence — replace with two-regime version | medium-low | feedback-0409-c F2 |
| FR-16 | CLAUDE.md Branch Protocol cleanup step does not specify local-vs-remote deletion ordering; manual `git push origin --delete` from main gets intercepted by hook | CLAUDE.md Branch Protocol step 6 — add one sentence on remote deletion ordering | low | feedback-0409-d F1 |
| FR-17 | Doc Engineer ad-hoc fix exception and emergency hotfix exception do not cover automated `release/` branch commits — strict reading would require audit for every release | CLAUDE.md Solo/Agent Team workflow step 4 — add third sub-bullet for automated release exception; mirror in CLAUDE-TEMPLATE.md, `docs/workflow.md` Hotfix section, and `agents/process-observer-audit.md` C1 check | medium-low | feedback-0409-d F2 |
| FR-18 | BLOCKING sentinel and rationale lack an explicit "same edit" write-together rule — pre-commit interim state (rationale present, sentinel not yet appended) misclassified as WARN in PO audit | `commands/end-working.md` Step 2 BLOCKING decision — add atomic-write requirement | medium | feedback-0417 Rule 3 |
| FR-20 | BLOCKING marker boundary acknowledgement path undefined for the case where CLAUDE.md was modified mid-session and surfaced to Lead via system-reminder injection | `commands/start-working.md` Step 0 — add sentence documenting the non-standard acknowledgement path | low | feedback-0417 Rule 5 |
| FR-21 | `/end-working` Step 4 Notes-section authoring guidance does not require mechanical computation of aggregate Wave count via `git log` before writing prose (parallels FR-7's commit-count verification) | `commands/end-working.md` Step 4 Notes guidance — add sub-bullet requiring mechanical Wave-count verification | low | feedback-0417 Rule 6 |
| FR-22 | BLOCKING marker semantic gate in `commands/end-working.md` Step 2 is scoped to Wave-completion entries only ("Wave-completion entries only; skip for mid-Wave updates") and is silent on non-Wave sessions that modify CLAUDE.md with behavioral rule changes — such sessions can add behavior rules without emitting BLOCKING or a skip rationale | `commands/end-working.md` Step 2 BLOCKING decision preamble — remove "Wave-completion entries only" qualifier and apply the semantic gate to any session touching CLAUDE.md, with unconditional skip-rationale requirement | medium | PO audit of 2026-04-17 TODO Consolidation session — E4 WARN |
| FR-23 | `agents/process-observer-audit.md` E-series rows do not explicitly audit BLOCKING marker decisions for non-Wave CLAUDE.md-touching sessions (E1/E2 cover plan.md accuracy but not BLOCKING decision) | `agents/process-observer-audit.md` — add an E-series row covering BLOCKING gate on non-Wave CLAUDE.md-touching sessions, with the same semantic-gate logic as Wave-close case | medium | PO audit of 2026-04-17 TODO Consolidation session — E4 WARN follow-up |
| FR-24 | `agents/process-observer-audit.md` lists "14 standard checks" in role scope but the audit template only names rows A1-A2/A3/F1 explicitly — full A/B/C/D/E/F enumeration must be inferred per-invocation from the spawn prompt, causing audit coverage inconsistency across invocations | `agents/process-observer-audit.md` — add explicit numbered checklist (A1-A3, B1-B2, C1-C2, D1-D4, E1-E5, F1) so agent self-verifies completeness without relying on per-invocation prompt enumeration | medium | PO audit of 2026-04-20 Wave 2 /doctor session — framework-side rule correction #1 |
| FR-25 | `commands/end-working.md` Step 5 (PO audit spawn) runs before Step 3's IR completion is confirmed, placing F1 check in IN-PROGRESS state as the structural norm rather than exception; current F1 spec handles this but step-ordering implications are not documented | `commands/end-working.md` Step 5 — document F1 IN-PROGRESS as structural norm for PO audits spawned in this step; Lead should note F1 IN-PROGRESS in B-layer briefing's IR slot rather than flagging as deviation | low | PO audit of 2026-04-20 Wave 2 /doctor session — framework-side rule correction #2 |
| FR-28 | `scripts/language-check.sh` has no code-fence exemption — backtick-wrapped CJK literals (inline or fenced) trigger the Tier 1 CJK guardian identically to bare CJK, so a Tier 1 file that legitimately needs to reference a CJK token (e.g., the observation-period unfilled-placeholder literal in `agents/process-observer-audit.md` E6) must fall back to Unicode-codepoint descriptions, reducing human readability of the rule text | `scripts/language-check.sh` — add either a fenced-code-block state machine (triple-backtick and inline-backtick enter/exit) OR an explicit `<!-- cjk-exempt -->`-style marker the scanner honors | low | Wave 3 Teammate C FR-27 implementation discovery |
| FR-29 | `commands/end-working.md` Step 3 (Independent Reviewer spawn in tmux pane) and Step 4 (Lead authors session-log.md Wave entry) are numerically ordered but the spec does not explicitly forbid parallel execution — Lead may begin Step 4 prose while IR is mid-review, which IR detects as mid-review file mutation and halts on (codex exec is non-interactive, so IR terminates without writing verdict to `docs/independent-review.md`, requiring a round-2 re-launch after Step 4 completes) | `commands/end-working.md` Step 3 — add explicit "Step 4 must not begin until IR writes verdict to `docs/independent-review.md` and the tmux session closes" rule; OR move session-log authoring to a strictly post-IR step | medium | Wave 3 /end-working execution — IR round-1 halt on session-log parallel-edit race, round-2 PROCEED after Step 3/4 serialized |
| FR-30 | `CLAUDE.md` Module Boundaries table lists the Doctor script (`scripts/doctor-check.sh`) inline with its slash command but omits other first-party `scripts/*.sh` entries — `scripts/language-check.sh`, `scripts/policy-lint.sh`, `scripts/session-health.sh`, `scripts/release.sh` — creating an asymmetry where some guardian/tooling scripts are documented and others are not, making Module Boundaries an unreliable first-pass reference for which scripts exist at what layer | `CLAUDE.md` Module Boundaries table — add rows for Language/Policy/Session Health Preview/Release as a coherent "Scripts" band (or group them under an umbrella Framework Scripts row with sub-bullets naming each script and its purpose); also decide whether the same pattern should propagate to `CLAUDE-TEMPLATE.md` for user projects | low | Wave 3 Doc Engineer pre-merge audit MINOR — pre-existing coherence gap flagged during Session Health Preview landing |
| FR-31 | The GitHub owner-extraction sed regex `sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#'` is duplicated verbatim across three Tier 1 consumers — `commands/start-working.md` Step 6, `commands/end-working.md` Step 8, and the new `scripts/gh-account-guard.sh` shell layer — so any future edge case (SSH alias rewrites, gh CLI URL format changes, non-GitHub hosts) would need to be fixed in three places, and a silent drift between the three copies is a realistic failure mode | extract the regex to a `lib/gh-owner.sh` helper (bash-sourceable) that both the slash-command pseudocode and the guard script reference, OR explicitly document the triplication rationale inline in each occurrence so future maintainers see the deliberate choice; decide DRY-extract vs. per-consumer-owned-copy for portability | low | Wave 4 FR-13 implementation — `scripts/gh-account-guard.sh` introduced as the third regex consumer |
| FR-32 | `docs/roles.md` and `docs/process-observer.md` Process Observer sections still describe the audit as having "14 checks total" (`docs/roles.md` around line 420) and enumerate a 15-row checklist (`docs/process-observer.md`); after Wave 4's canonical 18-row codification in `agents/process-observer-audit.md`, both references are stale — a reader cross-checking role documentation against the audit template will encounter three different row counts (14 in `roles.md`, 15 in `process-observer.md`, 18 in the canonical template) | `docs/roles.md` Process Observer check-count clause + `docs/process-observer.md` checklist enumeration — both synchronise to canonical 18 rows (A1-A3/B1-B2/C1-C2/D1-D4/E1-E6/F1) with the scope-to-letter mapping mirrored from `agents/process-observer-audit.md` preamble | medium | Wave 4 FR-24 implementation — deferred to v0.9 + `docs/plan.md` 膨胀治理 session per user direction (zero-extra-cost bundle with other doc churn, not a Wave 4 in-session fix) |

#### Deferred to v0.8+

Items surfaced in earlier Waves with partial merit but deferred pending external-user feedback.

| # | Item | Notes |
|---|------|-------|
| DV-1 | `/env-nogo` deep consistency checks (CLAUDE.md Module Boundaries ↔ actual disk structure, plan.md In-Progress ↔ branch diff) | Partial merit — CLAUDE.md-half higher value than plan.md-diff-half (latter has high false-positive risk on mid-task branches). Source: v0.7.8 Polish Wave Out of scope. |
| DV-2 | `install.sh --rollback` | Existing `lib/snapshot.sh` engine covers most config-file rollback needs, so self-rollback of `install.sh` is lower-priority. Source: v0.7.8 Polish Wave Out of scope. |

#### External Direction

Items tracking iSparto's external commitments (dogfooding projects, open-source launch prep). Migrated from `memory/` on 2026-04-17.

| # | Item | Notes |
|---|------|-------|
| ED-1 | Heddle dogfooding — 3rd dogfooding scenario | Co-founded with Adam; generative UI runtime; will use `/init-project` from scratch. User-direction gate — iSparto framework side has no blocker. |
| ED-2 | meic dogfooding — 4th dogfooding scenario | User-direction gate. |
| ED-3 | Real-project benchmark + screenshots in README | Open-source launch prep: concrete project scale, Wave count, Codex impact numbers, actual tmux screenshots. Source: memory `project_opensource_todos.md`. |
| ED-4 | CONTRIBUTING.md expansion (verify state first) | Open-source launch prep carry-over from memory; `CONTRIBUTING.md` already exists per completed work — this item may be stale. Verify current state vs memory before acting. Source: memory `project_opensource_todos.md`. |

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
| 2026-04-17 | plan.md | 自动压缩规则：完成超过 7 天的 Wave 自动折叠成单行，详情移入 plan-archive.md | 前提伪造 — plan.md 和 end-working.md 里根本没有这条规则（Lead grep 验证）。现有机制是手动 `<details>` 折叠（见 plan.md v0.x 已完成项 block），工作正常；plan.md 在 v0.7.8 之前 ~935 行，远未臃肿到需要自动化压缩机制 | 来源：Kimi 2.6 外部 repo 诊断（item 2）。触发条件：plan.md 超过 ~2000 行且 `<details>` 折叠模式无法保持 Wave 历史可读性 |
| 2026-04-17 | Agent Team 模式 | Teammate 失败断点续传：plan.md 每个 task 加 checkpoint 字段 + docs/teammate-failures.md 经验库 | 当前规模过早 — iSparto 是 solo founder 框架，Agent Team 每天调用次数极低，Teammate 崩了由 Lead re-dispatch 比维护一套 checkpoint 基础设施省事得多 | 来源：Kimi 2.6 外部 repo 诊断（item 4）。触发条件：Agent Team 成为默认模式且 Teammate 崩溃频率 ≥ 1 次/天 |
| 2026-04-17 | Git 托管平台 | PR/merge 流程解耦 `gh` CLI，引入 github / gitlab / gitee / generic fallback 适配层 | 与产品定位不符 — CLAUDE.md "Platform: macOS" + install.sh 深度依赖 `gh` 是刻意选择，iSparto v0.x 目标用户是 GitHub-native solo founder，平台扩展相对 v0.8 外部用户验证 gate 属于 scope creep | 来源：Kimi 2.6 外部 repo 诊断（item 5）。触发条件：v1.x 自治团队里程碑激活且有具体 GitLab/Gitee 用户实际反馈 |
| 2026-04-17 | 框架 workflow | `/end-working` Step 5 让 PO audit 把 framework-side rule correction 写进 `docs/framework-feedback-MMDD.md` dated 文件（commands/end-working.md 67-71 行原指令） | 成了 plan.md 以外的并行 TODO 通道；0405–0417 共 12 天累计 11 个文件 21 条 open rule 绕过了用户"所有 TODO 进 plan.md"的 Single-TODO-source 意图 | 来源：2026-04-17 user-surfaced drift。永久 retired，由三条结构防御替换：CLAUDE.md Single-TODO-source Development Rule + commands/end-working.md 67-71 改写为"append 行到 plan.md Backlog" + Step 1 新增 TODO 归位 audit。PR #213 |
| 2026-04-17 | Rejected Approaches | 给表格加 Tags 列 + `isparto search-rejected <tag>` grep helper | 当前条目数过早 — 表格只有 ~10 条，现有 Module/Feature 列已起到隐式 tag 作用（`grep "框架全局"` 能达到 Tags 的同等检索精度），加结构化列的每条录入开销只在 ≥ ~30 条后才值回票价 | 来源：Kimi 2.6 外部 repo 诊断（item 7）。触发条件：表格超过 ~30 条且 Module/Feature 列精度失效 |
