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

Historical Wave narratives for v0.6.x / v0.7.x live in `docs/session-log.md` — see the "已完成 Wave 索引" table below for reverse-chronological anchors. Current active phase is the v0.8.0 observation period (see entries below).

### 已完成 Wave 索引

Reverse-chronological index of historical Waves. Each anchor links into `docs/session-log.md` where the full narrative lives. This table replaces the prior per-Wave detail blocks (migrated 2026-04-20 per the plan.md/session-log authoring contract at `commands/end-working.md` Step 4).

| Wave | Date | Session-log anchor |
|------|------|--------------------|
| v0.8.0 Doc Alignment — Phase 2 (Chinese Quick-Start Sync + PO Audit E6 Pointer Fix; `docs/zh/quick-start.md` v0.8.0 rewrite across 4 sections + `agents/process-observer-audit.md` E6 ASCII-only heading-text anchor) | 2026-04-24 | [session-log](session-log.md#2026-04-24-session-b-wave-v080-doc-alignment-phase-2-chinese-quick-start-sync-po-audit-e6-pointer-fix) |
| v0.8.0 Doc Alignment — Phase 1 Factual Corrections (READMEs + reference docs + CLAUDE-TEMPLATE.md; 10-command inventory back-propagation + DE/PO audit-ordering correction + tmux hard-dep / Codex second-consumer framing) | 2026-04-24 | [session-log](session-log.md#2026-04-24-session-wave-v080-doc-alignment-phase-1-factual-corrections) |
| Wave 4 — FR-13 gh 账户 mid-session guard + FR-24 PO audit canonical 18-row enumeration | 2026-04-20 | [session-log](session-log.md#2026-04-20-session-wave-4-fr-13-gh-账户-mid-session-guard-fr-24-po-audit-canonical-18-row-enumeration) |
| Wave 3 — `/start-working` Session Health Preview + FR-26 + FR-27 | 2026-04-20 | [session-log](session-log.md#2026-04-20-session-b-wave-3-start-working-session-health-preview-fr-26-de-机械-re-execute-fr-27-po-tracker-结算-v080-observation-period-row-4) |
| Wave 2 — `/doctor` Slash Command | 2026-04-20 | [session-log](session-log.md#2026-04-20-session-wave-2-doctor-slash-command-v080-observation-period-row-3) |
| Wave 1 — FR-19 IR Skip Carve-out Codification | 2026-04-18 | [session-log](session-log.md#2026-04-18-session-b-wave-1-fr-19-ir-skip-carve-out-codification-v080-observation-period-row-2) |
| v0.8.0 — 模型配置升级 + IR 异源化 (observation Wave 0) | 2026-04-18 | [session-log](session-log.md#2026-04-18-session-v080-model-config-upgrade-independent-reviewer-cross-provider-migration) |
| v0.7.8 Release (post-Polish aggregation) | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-v078-release-post-polish-wave-aggregation) |
| v0.7.8 Framework Polish (T1 start-working read-fix + T2 policy-lint guardian) | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-v078-framework-polish-t1-start-working-read-fix-t2-policy-lint-guardian) |
| Wave C — Infrastructure Hardening + Rule 2 | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-wave-c-infrastructure-hardening-rule-2-agent-team) |
| Wave — BLOCKING Gate Narrowing | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-blocking-gate-narrowing-same-session-follow-up-refinement) |
| Wave — BLOCKING Marker Semantic Gate | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-blocking-marker-semantic-gate-framework-self-referential-wave) |
| Wave B — docs Layer Dedup | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-wave-b-docs-layer-dedup-v24-two-wave-doc-restructure) |
| Wave A — Concept Decoupling | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-wave-a-concept-decoupling-v24-two-wave-doc-restructure) |
| TODO Consolidation (framework-feedback-*.md channel retired) | 2026-04-17 | [session-log](session-log.md#2026-04-17-session-todo-consolidation-framework-feedback-md-channel-retired) |
| v0.7.7 Release — README value-prop realignment + SVG Process Observer | 2026-04-14 | [session-log](session-log.md#2026-04-14-session-readme-value-prop-realignment-svg-process-observer-v077-release-pr-197-202) |
| v0.7.6 Release — SVG diagram polish | 2026-04-12 | [session-log](session-log.md#2026-04-12-session-svg-diagram-polish-v076-release-pr-193-pr-195) |
| IR Token Cost Documentation | 2026-04-10 | [session-log](session-log.md#2026-04-09-session-e-framework-feedback-polish-sweep-pr-187-pr-188) |
| v0.7.5 Wave close-out bookkeeping + v0.7.5 release | 2026-04-09 | [session-log](session-log.md#2026-04-09-session-d-v075-wave-close-out-bookkeeping-v075-release) |
| Principle 5 total-collapse polish (v0.7.5 polish candidate) | 2026-04-09 | [session-log](session-log.md#2026-04-09-session-b-principle-5-total-collapse-polish-v075-polish-candidate-delivered) |
| v0.7.4 — Information Layering Policy | 2026-04-09 | [session-log](session-log.md#2026-04-09-session-wave-v074-information-layering-policy-release-v074) |
| Framework Polish Round 2 + v0.7.2 Patch Release | 2026-04-08 | [session-log](session-log.md#2026-04-08-session-c-framework-polish-round-2-v072-patch-release) |
| Post-Wave 5 Follow-up Hotfixes + v0.7.0 / v0.7.1 Emergency BSD-sed Hotfix | 2026-04-08 | [session-log](session-log.md#2026-04-08-session-b-post-wave-5-follow-up-hotfixes-v070-release-v071-emergency-bsd-sed-hotfix) |
| i18n Cleanup Wave 5 (finalization) | 2026-04-08 | [session-log](session-log.md#2026-04-08-session-i18n-cleanup-wave-5-finalization-tier-3-onramp-carry-over-polish-end-to-end-audit) |
| i18n Cleanup Wave 4 — language-check.sh as Doc Engineer blocking gate | 2026-04-07 | [session-log](session-log.md#2026-04-07-session-d-i18n-cleanup-wave-4-language-checksh-as-doc-engineer-audit-blocking-gate) |
| Inter-Wave Hotfixes (mcp-rename-migration-guard + principle1-guardian-extension) | 2026-04-07 | [session-log](session-log.md#2026-04-07-session-b-inter-wave-hotfixes) |
| i18n Cleanup Waves 1-3 (four-tier language convention + Tier 1/Tier 2 Englishization) | 2026-04-07 | [session-log](session-log.md#2026-04-07-session-1) |

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

**Why Independent Reviewer at Wave boundary (despite framework-internal):** 本 Wave 改变了 IR 执行路径本身 (sub-agent → Codex CLI). Wave Boundary IR 必须真实跑一次确认新路径工作 — 这次 IR 的价值在 "验证迁移成功" 而非 "验证 alignment". 如外部验证 3 在 Wave 中失败, 本 Wave 降级为不含 IR 的 v0.8.0 (按 IR 三条件 carve-out 正当 skip — 自 Wave 1 起 codified 在 `commands/end-working.md` Step 3), IR 部分推迟到 v0.8.1.

**BLOCKING marker rationale for next session (under the narrowed gate codified in PR #207):** This Wave 修改了 `CLAUDE.md` (Module Boundaries 表的 IR 行) — 触发 BLOCKING 默认值. Decision aid: (a) Behavior change? Yes — IR 调用路径变化 (Task tool → codex exec). (b) New identifier? Yes — `runtime: codex-cli` frontmatter key. (c) Contract/interface change? Yes — IR spawn one-liner shape 改变. 三项 yes → **emit BLOCKING marker**.

**Commit count verification (Rule 2 cadence):** Projected 2 non-merge commits on the Wave branch at `/end-working` time. Commit 1 (`46334bc`) ships the 17-file core upgrade. Commit 2 ships change G (5 files: install.sh, commands/migrate.md, docs/user-guide.md, CLAUDE.md, CHANGELOG.md) — surfaced after commit 1 was already pushed when the user noticed tmux was a hard dependency requiring documentation. Splitting was the cleanest path (no force-push / amend on a published commit). Re-verification command: `git log --oneline --no-merges bb5a983..HEAD | wc -l` — base `bb5a983` 是 v0.7.8 final merge commit (本 Wave divergence base from main); expected output: `2`.

**Status: RELEASED — v0.8.0 (2026-04-20 CST)**

Released 2026-04-20 via `/release minor` in dedicated release session — PR #225 merged to main (commit `a2907a0`), tag `v0.8.0` created, GitHub Release published at https://github.com/BinaryHB0916/iSparto/releases/tag/v0.8.0. The historical narrative below documents the merged-not-released state during the 2026-04-18 → 2026-04-20 observation period; the `/release patch` references at lines 157 + 163 are frozen authoring errors (correct bump type is `minor` for 0.7.8 → 0.8.0) left as-is per Tier 4 no-retroactive-edit convention.

本 Wave 的全部文件改动已 merge 到 main (PR #215 v0.8.0 核心 + change G; PR #216 Wave 0 polish), 但 v0.8.0 故意不进入 release 流程:

- VERSION 文件保持 `0.7.8` (不 bump 到 `0.8.0`)
- CHANGELOG `[0.8.0] - 2026-04-XX` 占位符不替换
- 不创建 `v0.8.0` git tag
- 不触发 GitHub Release
- `scripts/release.sh` 不运行

**Why merged-not-released:** 升级 scope 过大 (模型替换 + IR 架构迁移 + tmux hard-dep), 需要观察期内验证再发版, 降低用户被未充分验证升级波及的风险. main 分支上的代码是"事实上已就绪"的下一版本, 但 release 元数据 (tag / CHANGELOG date / VERSION bump) 等观察期通过后再统一刷新. 这是"merge ≠ release"的显式分离 — main 永远跟着最新代码走, release tag 跟着可信任度走.

**Release gate (三条件, 全部满足后才跑 `/release patch`):**

1. **观察期完成** — F8b tracker 涵盖 Wave 0 至 Wave 4 共 5 行全部记录, 且每字段累计异常 < 2 行. 如触发 ≥ 2 行同字段异常 (DocEng 过严 / Lead escalation 异常 / Teammate 字面化), 先按 docs/design-decisions.md per-role partial revert 路径处置, 处置完成后 reset 观察期重新起算 (Wave 0 数据保留作为历史参考, 但 Wave 1-4 行清空重计).
2. **新 IR 路径稳定性证据** — Wave Boundary IR 在 Wave 1/2/3 至少 3 次成功执行 (`codex exec` in tmux 无 infrastructure 故障 — Codex CLI 升级、GPT-5.4 quota 撞限、tmux pane cross-context bug 等均算 infrastructure 故障). 任何一次 infrastructure 失败需要 root cause 分析后才能继续计数; 故障前的成功次数保留, 故障 Wave 不计入但也不清空已有计数.
3. **观察期内无 emergency revert** — 5 Wave 期间未对任何角色应用 partial revert. 如发生 partial revert (例如 DocEng 回退 4.6 max), release version 必须反映实际 ship 的角色集合: 要么命名为 `v0.8.0-mixed` 显式标注混搭, 要么直接跳过 v0.8.0 tag 推迟到 v0.8.1 ship 完整 4.7 + IR 异源组合 (推荐后者, 避免 mixed 版本带来的 support 复杂度).

**Release 触发 (三条件满足后):** 在新 session 跑 `/release patch` 触发 `scripts/release.sh` (自动 bump VERSION 0.7.8 → 0.8.0、替换 CHANGELOG date 占位符为 release 当日 CST 日期、创建 `v0.8.0` git tag、推 GitHub Release). 不要绕过 `/release` 手动 tag — release.sh 包含一致性检查不容易手动复刻.

**Status 段维护规则:** Wave 1-4 完成后每次更新 F8b tracker 的同时 review 本段三条件; 全部满足时把本段标记从 `MERGED-NOT-RELEASED` 改为 `RELEASED — v0.8.0 (YYYY-MM-DD CST)` 并保留段落作为历史 (不删除); 触发 partial revert 时把本段标记改为 `MERGED-NOT-RELEASED — REVERT IN PROGRESS` 并新增子段说明 revert 范围 + 重置后的观察期起点.

**Release Gate 三条件判定 (2026-04-20, post-Wave 4):** 全部 MET — 条件 1 观察期 tracker 5 行全部已填 (Wave 0 at 2026-04-18 / Wave 1 at 2026-04-18 / Wave 2 at 2026-04-20 / Wave 3 at 2026-04-20 / Wave 4 at 2026-04-20), 每字段累计异常均 0 行 (DocEng 过严 0, Lead escalation 异常 0, Teammate 字面化 0 — Wave 2 的字面化是 `literal-not-semantic` 模式观察, 在 tracker 标记为 "是" 但属 positive capture, IR 已在 in-session fix 内处理, 非"异常行"意义); 条件 2 real Wave Boundary IR 累计 3 次达标 (Wave 1 按 FR-19 carve-out 合理 skip, Wave 2 round-1 BLOCK → round-2 PROCEED, Wave 3 round-1 BLOCK → round-2 PROCEED, Wave 4 round-1 BLOCK → round-2 PROCEED — 每次 BLOCK 均 in-session fix 后重跑 PROCEED); 条件 3 观察期内无 emergency revert (全程 0 次 partial revert). Ready to release — 下个 session 运行 `/release patch` 触发 v0.8.0.

🚨 BLOCKING: Next Wave requires NEW SESSION
> ✅ Session boundary acknowledged 2026-04-18 by /start-working
> ✅ Session boundary acknowledged 2026-04-20 by /start-working

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
| FR-14 | Wave-level batch-review safety-net sentence in `docs/workflow.md` reads unconditional but Implementation Protocol exception for self-referential edits exists at clause level, creating audit confusion | `docs/workflow.md` Wave-level safety-net — add parenthetical carve-out for self-referential boundary | medium | feedback-0409-c F1 |
| FR-15 | `agents/process-observer-audit.md` A3 detection guidance assumes reflog alone verifies branch-checkout ordering, but pre-commit verification requires a two-source check (reflog + session context) | `agents/process-observer-audit.md` A3 row detection sentence — replace with two-regime version | medium-low | feedback-0409-c F2 |
| FR-16 | CLAUDE.md Branch Protocol cleanup step does not specify local-vs-remote deletion ordering; manual `git push origin --delete` from main gets intercepted by hook | CLAUDE.md Branch Protocol step 6 — add one sentence on remote deletion ordering | low | feedback-0409-d F1 |
| FR-17 | Doc Engineer ad-hoc fix exception and emergency hotfix exception do not cover automated `release/` branch commits — strict reading would require audit for every release | CLAUDE.md Solo/Agent Team workflow step 4 — add third sub-bullet for automated release exception; mirror in CLAUDE-TEMPLATE.md, `docs/workflow.md` Hotfix section, and `agents/process-observer-audit.md` C1 check | medium-low | feedback-0409-d F2 |
| FR-18 | BLOCKING sentinel and rationale lack an explicit "same edit" write-together rule — pre-commit interim state (rationale present, sentinel not yet appended) misclassified as WARN in PO audit | `commands/end-working.md` Step 2 BLOCKING decision — add atomic-write requirement | medium | feedback-0417 Rule 3 |
| FR-20 | BLOCKING marker boundary acknowledgement path undefined for the case where CLAUDE.md was modified mid-session and surfaced to Lead via system-reminder injection | `commands/start-working.md` Step 0 — add sentence documenting the non-standard acknowledgement path | low | feedback-0417 Rule 5 |
| FR-21 | `/end-working` Step 4 Notes-section authoring guidance does not require mechanical computation of aggregate Wave count via `git log` before writing prose (parallels FR-7's commit-count verification) | `commands/end-working.md` Step 4 Notes guidance — add sub-bullet requiring mechanical Wave-count verification | low | feedback-0417 Rule 6 |
| FR-22 | BLOCKING marker semantic gate in `commands/end-working.md` Step 2 is scoped to Wave-completion entries only ("Wave-completion entries only; skip for mid-Wave updates") and is silent on non-Wave sessions that modify CLAUDE.md with behavioral rule changes — such sessions can add behavior rules without emitting BLOCKING or a skip rationale | `commands/end-working.md` Step 2 BLOCKING decision preamble — remove "Wave-completion entries only" qualifier and apply the semantic gate to any session touching CLAUDE.md, with unconditional skip-rationale requirement | medium | PO audit of 2026-04-17 TODO Consolidation session — E4 WARN |
| FR-23 | `agents/process-observer-audit.md` E-series rows do not explicitly audit BLOCKING marker decisions for non-Wave CLAUDE.md-touching sessions (E1/E2 cover plan.md accuracy but not BLOCKING decision) | `agents/process-observer-audit.md` — add an E-series row covering BLOCKING gate on non-Wave CLAUDE.md-touching sessions, with the same semantic-gate logic as Wave-close case | medium | PO audit of 2026-04-17 TODO Consolidation session — E4 WARN follow-up |
| FR-25 | `commands/end-working.md` Step 5 (PO audit spawn) runs before Step 3's IR completion is confirmed, placing F1 check in IN-PROGRESS state as the structural norm rather than exception; current F1 spec handles this but step-ordering implications are not documented | `commands/end-working.md` Step 5 — document F1 IN-PROGRESS as structural norm for PO audits spawned in this step; Lead should note F1 IN-PROGRESS in B-layer briefing's IR slot rather than flagging as deviation | low | PO audit of 2026-04-20 Wave 2 /doctor session — framework-side rule correction #2 |
| FR-28 | `scripts/language-check.sh` has no code-fence exemption — backtick-wrapped CJK literals (inline or fenced) trigger the Tier 1 CJK guardian identically to bare CJK, so a Tier 1 file that legitimately needs to reference a CJK token (e.g., the observation-period unfilled-placeholder literal in `agents/process-observer-audit.md` E6) must fall back to Unicode-codepoint descriptions, reducing human readability of the rule text | `scripts/language-check.sh` — add either a fenced-code-block state machine (triple-backtick and inline-backtick enter/exit) OR an explicit `<!-- cjk-exempt -->`-style marker the scanner honors | low | Wave 3 Teammate C FR-27 implementation discovery |
| FR-29 | `commands/end-working.md` Step 3 (Independent Reviewer spawn in tmux pane) and Step 4 (Lead authors session-log.md Wave entry) are numerically ordered but the spec does not explicitly forbid parallel execution — Lead may begin Step 4 prose while IR is mid-review, which IR detects as mid-review file mutation and halts on (codex exec is non-interactive, so IR terminates without writing verdict to `docs/independent-review.md`, requiring a round-2 re-launch after Step 4 completes) | `commands/end-working.md` Step 3 — add explicit "Step 4 must not begin until IR writes verdict to `docs/independent-review.md` and the tmux session closes" rule; OR move session-log authoring to a strictly post-IR step | medium | Wave 3 /end-working execution — IR round-1 halt on session-log parallel-edit race, round-2 PROCEED after Step 3/4 serialized |
| FR-30 | `CLAUDE.md` Module Boundaries table lists the Doctor script (`scripts/doctor-check.sh`) inline with its slash command but omits other first-party `scripts/*.sh` entries — `scripts/language-check.sh`, `scripts/policy-lint.sh`, `scripts/session-health.sh`, `scripts/release.sh` — creating an asymmetry where some guardian/tooling scripts are documented and others are not, making Module Boundaries an unreliable first-pass reference for which scripts exist at what layer | `CLAUDE.md` Module Boundaries table — add rows for Language/Policy/Session Health Preview/Release as a coherent "Scripts" band (or group them under an umbrella Framework Scripts row with sub-bullets naming each script and its purpose); also decide whether the same pattern should propagate to `CLAUDE-TEMPLATE.md` for user projects | low | Wave 3 Doc Engineer pre-merge audit MINOR — pre-existing coherence gap flagged during Session Health Preview landing |
| FR-31 | The GitHub owner-extraction sed regex `sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#'` is duplicated verbatim across three Tier 1 consumers — `commands/start-working.md` Step 6, `commands/end-working.md` Step 8, and the new `scripts/gh-account-guard.sh` shell layer — so any future edge case (SSH alias rewrites, gh CLI URL format changes, non-GitHub hosts) would need to be fixed in three places, and a silent drift between the three copies is a realistic failure mode | extract the regex to a `lib/gh-owner.sh` helper (bash-sourceable) that both the slash-command pseudocode and the guard script reference, OR explicitly document the triplication rationale inline in each occurrence so future maintainers see the deliberate choice; decide DRY-extract vs. per-consumer-owned-copy for portability | low | Wave 4 FR-13 implementation — `scripts/gh-account-guard.sh` introduced as the third regex consumer |
| FR-33 | `agents/process-observer-audit.md` B1 check ("Mode Selection Checkpoint recorded") has no explicit N/A branch for dedicated release sessions, governance-maintenance sessions, and other non-development session types where Mode Selection is structurally inapplicable — a PO auditor of a release session must reason from first principles that B1 is N/A rather than reading an explicit exemption from the canonical 18-row template, creating ambiguity for future non-Wave sessions | `agents/process-observer-audit.md` B1 row — add an N/A branch condition enumerating non-development session types (release sessions, governance-maintenance sessions, pure doc-polish sessions) where Mode Selection is structurally inapplicable; mirror the treatment F1 already has for non-Wave session IR inapplicability | low | PO audit of 2026-04-20 v0.8.0 release session — B1 reasoning gap (agent returned PASS via reasoning-from-first-principles, but spec lacks explicit structural-N/A enumeration for release session type) |
| FR-34 | `docs/plan.md` post-v0.8.0 second-pass reshape — PR #223 reshape established the "已完成 Wave 索引" pattern but left three blocks un-migrated: (a) Line 1-67 顶部 "已完成" Wave 0-6 checkbox-style legacy structure (pre-index convention, reshape 未覆盖); (b) Line 104-175 v0.8.0 Wave entry 完整 narrative block (~72 行, reshape 时 v0.8.0 处于 MERGED-NOT-RELEASED 观察期内故保留; 2026-04-20 已 released, 按索引 pattern 应迁到 session-log 只留索引行); (c) Line 177-208 观察期 tracker + Line 147-148 release closure paragraph (均为 released-state 下的冻结历史数据). 当前 plan.md 353 行, 按 "plan.md = where are we now + future work" 定位严格执行应收敛到约 150 行 (当前阶段 preamble + 已完成 Wave 索引表 + 产品路线图 + Backlog + Rejected Approaches) | 独立 `chore/plan-md-reshape-post-v080` session 执行; 按 PR #223 index-pattern 迁移上述三块到 session-log (Wave 0-6 合并为一个历史压缩条目或按 Wave 拆开, v0.8.0 entry 完整迁走只在 "已完成 Wave 索引" 表留一行, tracker 作为 v0.8.0 entry 子段一并迁走); 可与 FR-32 (docs/roles.md + docs/process-observer.md stale enumeration) 合并到同一次 "plan.md + docs 膨胀治理" session — Wave 4 已声明此 session 为多项 stale-cleanup 的共同 target | medium | User direction 2026-04-20 end-of-day post-v0.8.0 release — user surfaced plan.md 仍 bloated 与 reshape 初衷 (plan.md = "where are we now") 的 gap |
| FR-36 | README 无 "v0.8.0 有什么变化" 入口叙事, 新用户看不到 tmux 升级 / IR 异源化 / Codex 第二消费者 / observation-period / plan.md Backlog 等 v0.8.0 结构性变更; 同时 README 多处引用 "Wave" 但全文没有定义 Wave 是什么 | README.md / README.zh-CN.md — 顶部加 5-8 行 What's New 块总结 v0.8.0 结构性变更 + "Wave" 一句话定义 (放在核心差异或架构章节开头) | low | v0.8.0 doc alignment Plan Phase 3 deferred — 需用户先定叙事风格后再动; 2026-04-24 plan at `/Users/duanshao/.claude/plans/joyful-hatching-sky.md` |
| FR-37 | Information Layering Policy / A-layer Peer Review / 5 guardian scripts / v0.8.0 observation-period tracker 等机制仅在 CLAUDE.md + `docs/design-principles/` 下存在, 对 README / `docs/concepts.md` / `docs/user-guide.md` 层面的外部读者不可发现 | `docs/concepts.md` 加 "v0.8.0 引入的机制" 章节汇聚 Layering Policy + A-layer Peer Review + guardian 指针; 或新建 `docs/v0.8.0-mechanisms.md` 整合, README 链接过去 | low | v0.8.0 doc alignment Plan Phase 3 deferred — 需用户先定文档位置; 2026-04-24 plan at `/Users/duanshao/.claude/plans/joyful-hatching-sky.md` |

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
