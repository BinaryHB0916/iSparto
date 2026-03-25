# Design Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Remove Claude Reviewer | Codex as the sole reviewer | Same-source review has limited value; cross-source review covers blind spots more effectively |
| Codex architecture pre-review | Intervene at Phase 0 | Catching architecture issues before coding begins costs far less than rework after development |
| Codex role positioning | Hidden master | Does not participate in day-to-day development; provides oversight at key checkpoints and fixes issues along the way |
| Team Lead handles information relay | Team Lead coordinates Codex-Developer communication | The user does not participate in copy-pasting between roles; Team Lead forwards automatically |
| Doc Engineer is a sub-agent | Spawned by Team Lead | Requires Team Lead's global context; does not need an independent tmux pane |
| Developer includes unit tests | Written alongside the code | Tests are part of the code, not a separate phase |
| Platform-agnostic design | Template is not tied to any tech stack | Works for iOS / Android / macOS / Windows / Web / cross-platform |
| Project-specific plugins at project level | Not in global settings.json | swift-lsp is only useful for iOS and should not pollute other projects |
| Unified document naming | All use the -spec suffix | product-spec, tech-spec, design-spec — immediately clear |
| Added tech-spec.md | Separate tech spec document | Separates product behavior (product-spec) from technical implementation (tech-spec); template cost is zero — skip it if the project doesn't need it |
| Team Lead authorization & escalation mechanism | Team Lead decides routine matters independently; escalates when uncertain | Reduces user involvement in intermediate coordination while ensuring critical decisions are not bypassed — better to escalate too much than too little |
| Team Lead document change permissions | Team Lead can modify all documents; reports changes in summary afterward | Team Lead + Doc Engineer are document managers; prohibiting document changes creates bottlenecks. User reviews afterward; product decision changes are marked with a warning for special attention |
| Unified Codex configuration | xhigh reasoning (where MCP supports it) | `codex` tool supports reasoningEffort: xhigh; `review` tool uses server defaults (no reasoningEffort parameter). Fast mode is not exposed by the MCP server and cannot be set via MCP calls |
| Codex QA smoke testing | QA step added after code review | Fills the gap of the QA role in human teams; incremental testing strategy (only test changed paths) addresses the slowness of smoke testing |
| Prerequisites for Wave parallelism | Tasks must be fully decoupled | No file overlap + no data dependencies + no runtime dependencies required for parallelism; if decoupling is not possible, defer to the next Wave — do not risk conflicts |
| Hotfix follows the full workflow | No simplified version | The full Agent Team workflow takes minutes; there is no human-team bottleneck of waiting for people. Hotfixes are precisely when second incidents are most likely, so review should not be cut |
| Project name | iSparto | Greek mythology Spartoi (sow dragon teeth, grow an army) + moved i from the end to the front = I = one person. An army of one |
| Inspired by gstack | Only adopted the product review concept | The plan-ceo-review philosophy is good; /browse and /qa are Web-specific and not universal |
| Effort level | max | Max subscription tokens go unused otherwise; pursue the highest reasoning depth |
| Cost | $120/month | Claude Max $100 + ChatGPT $20 — two top-tier models with no additional fees |
| Memory granularity | Milestone level | Space is limited; details are managed by plan.md |
| Document layering | Concise README + detailed docs/ | Keep README under 200 lines so new users can grasp core information in 30 seconds; in-depth content is split by topic into docs/ |
| Architecture diagrams use mermaid | Replaces ASCII art | CJK character widths are imprecise in GitHub code block fonts, making ASCII borders inevitably misaligned; mermaid renders as SVG and has no such issue |
| macOS + iTerm2 only | No cross-platform terminal adaptation | Agent Team tmux mode depends on iTerm2's built-in tmux integration; focus on the core experience at this stage without spreading effort thin |
| templates/ as a separate directory | Templates extracted from README | Avoids duplicating template content in the README (originally 400+ lines); templates as standalone files can be directly referenced by /init-project |
| Snapshot/Restore system | Automatic snapshot before every destructive operation (install, migrate, init-project) | Git doesn't cover uncommitted state or global ~/.claude/ files; automatic snapshots give users a safety net without requiring any manual action |
| Session Log | /end-working auto-generates session metrics to docs/session-log.md; /start-working reads history | Dogfooding showed manual metric collection is unrealistic; auto-collection provides project health visibility across sessions without user effort |
| Version tracking and upgrade | VERSION file + CHANGELOG.md + install.sh --upgrade with "what's new" display | Users who installed via curl need a clear way to know what version they have and what changed; CHANGELOG displayed inline during upgrade reduces friction |
| Thin bootstrap installer | bootstrap.sh (thin entry) + versioned install.sh (from GitHub Releases) + local isparto.sh stub | Old git-clone approach could not self-update from old versions; release-based install enables SHA256 checksum verification, version pinning, and eliminates .git overhead. Uninstall/restore remain fully offline via the local stub |
