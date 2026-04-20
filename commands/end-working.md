You are the Team Lead. The user has run /end-working to wrap up the work session.

Reference: docs/design-principles/information-layering-policy.md — every user-facing output in this command must be classified A-layer (decision interruption), B-layer (the single closing briefing defined in the final step), or C-layer (silent, logged to session-log.md and commit history). Default to silence. The closing briefing follows the fixed 3-5 sentence shape defined at the bottom of this file; intermediate steps (audits, commits, PR creation) do not emit individual status lines to the user.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Ensure all changes and decisions from this session are captured in documentation and the code repository, losing no context. Run the full close-out sequence silently, then emit exactly one B-layer closing briefing plus any A-layer interrupts that Step 3/Step 5/Step 6/Step 9 authorize.

1. Review all changes and decisions from this session:
   - Are code changes consistent with docs/ documentation? If not, you (Lead) update the docs directly, or spawn a Doc Engineer to update them
   - Have verbal decisions made during the conversation been written into the corresponding docs? If not, add them
   - Were any approaches tried and rejected/rolled back during this session? If yes, append them to the "Rejected Approaches" table in docs/plan.md (date, module/feature, what was tried, why rejected, notes on alternatives or conditions for revisiting)
   - **TODO-homing check (Single TODO source rule enforcement, CLAUDE.md Development Rules).** Guard against new TODOs / deferred actions / rule-fix candidates landing anywhere other than `docs/plan.md`'s Backlog. Run two scans over this session's changes (`git diff HEAD` for modifications, `git status --porcelain` for additions):
     - **File-pattern scan:** flag any newly-added `docs/framework-feedback-*.md` file (the pattern was retired 2026-04-17 — creation of a new one is a workflow violation).
     - **Phrase-pattern scan:** grep modifications in non-plan.md files for deferred-action phrases. The English set is: `defer to`, `fold into`, `next Wave`, `open Rule`, `TODO:`, `FIXME:`. When the session conversation occurred in a non-English language, Lead extends the grep with the user-language deferred-action vocabulary the user would naturally type (derived from the live session context per the hard-coded user-facing strings rule — do not embed non-English literals in this Tier 1 spec). Exclude `docs/session-log.md` historical-reference prose (reporting on past work is not a new TODO) and `docs/plan.md` (authoritative home) from the scan scope.
     - If any hit: **A-layer (Policy trigger type e — critical intercept).** Emit one A-layer interrupt naming the specific violation (file + line + snippet); the Lead is NOT committing; the remediation is to move the flagged content into `docs/plan.md`'s `### Backlog` (under Framework Rule Polish, Deferred to v0.8+, or External Direction as appropriate) and re-run the check. Wait for user response before resuming.
     - If no hits: proceed silently (C-layer). The check's green state is the expected condition.
2. Update docs/plan.md:
   - Mark completed tasks
   - If all Teams in the current Wave are finished, mark the Wave status as completed
   - List next-session to-dos
   - Record remaining issues and manual intervention points
   - **BLOCKING marker decision (Wave-completion entries only; skip for mid-Wave updates).** When the Wave status flips to completed AND the session modified `CLAUDE.md` (the only file Claude Code injects into its session-start system prompt — see the `# claudeMd` context block that every session receives), decide whether to emit the `🚨 BLOCKING: Next Wave requires NEW SESSION` marker at the end of the Wave entry. Apply the semantic gate:
     - **Master question:** would a Lead operating on pre-change cached `CLAUDE.md` take an action materially different from a Lead on post-change `CLAUDE.md`?
     - **Decision aid — any single "yes" triggers BLOCKING:** (a) **Behavior change?** — did the change add/remove/modify a rule, constraint, or workflow step Lead executes? (b) **New identifier?** — did the change introduce a new command / role / skill / marker / convention name Lead must recognize by name? (c) **Contract/interface change?** — did the change modify a protocol Lead interacts with (hook matcher, tool-call shape, MCP server name, file-path convention, annotation format)?
     - **If all three "no" (structural-only change — e.g., content extraction to a pointer, rewording that preserves semantics, typo fix, formatting):** skip the BLOCKING marker. Append a short prose rationale in the Wave entry (a line along the lines of `Why no BLOCKING marker for next session:` followed by one sentence citing the specific structural nature — extraction with pointer preservation, verbatim translation, formatting-only, etc.). This rationale is mandatory whenever the marker is skipped on a `CLAUDE.md`-touching Wave — it is the audit evidence that the decision was made, not forgotten.
     - **Default on doubt:** emit BLOCKING. Cross-session safety outweighs session-continuity convenience.
     - **All other files (other Tier 1 files — `commands/*.md`, `agents/*.md`, `templates/*.md`, `CLAUDE-TEMPLATE.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `bootstrap.sh`, `install.sh`, `isparto.sh` — and all Tier 2/3/4 files):** no BLOCKING marker needed regardless. These files are not injected into Claude Code's session-start system prompt — the LLM reads them fresh at tool-invocation time (Skill tool reads `commands/*.md`; Agent tool reads `agents/*.md`; `/init-project` reads `templates/*.md` and `CLAUDE-TEMPLATE.md`; Claude Code runtime executes hook scripts per-event; shell scripts are external executables the user runs manually). Stale-cache risk is structurally zero. A one-line rationale in the Wave entry is still recommended for significant framework-behavior changes but not mandatory.
3. Wave Boundary Review (conditional):
   - Trigger: Step 2 marked the current Wave status as completed
   - **Skip carve-out (self-referential polish Wave).** When the Wave-completion trigger fires, the Lead MAY skip sub-steps a–d below if ALL three conditions hold — each condition is independent; missing any one reverts the Wave to the default "run IR" path:
     (i) **No application-code files modified** — every file touched in this Wave is either a Claude Code system-prompt-layer file (`CLAUDE.md`, `commands/*.md`, `agents/*.md`, `templates/*.md`, `CLAUDE-TEMPLATE.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `bootstrap.sh`, `install.sh`, `isparto.sh`), a build/tooling configuration file (`.claude/settings*.json`, `VERSION`), or project documentation (`docs/**/*.md`, `README*.md`, `CHANGELOG.md`, `CONTRIBUTING.md`). Any change to source code that implements user-facing product behavior reverts to the default "run IR" path, because that is exactly the surface where product-technical alignment gaps live.
     (ii) **No new product-behavior surface** — the Wave introduces no new command / role / skill / marker / convention name that an outside caller or the user would observe as a newly-visible identifier. Parallels the Step 2 BLOCKING decision aid's question (b). Renaming or repurposing an existing identifier counts as introducing a new surface; so does adding a new slash command, a new agent frontmatter field, or a new Process Observer rule category. Clarifying wording of an existing rule does not.
     (iii) **DE + PO audits both run as fresh sub-agent spawns in this invocation** — Doc Engineer audit (Step 9 pre-merge gate) and Process Observer audit (Step 5) both execute as fresh sub-agent spawns in this `/end-working` invocation, i.e., the Wave is NOT operating under the ad-hoc-fix or emergency-hotfix exceptions from CLAUDE.md Solo/Agent Team workflow step 4. Those exceptions skip one or both audits and would leave the Wave with no guardian coverage if IR is also skipped; condition (iii) exists to prevent that dead-zone.
     **When the carve-out applies:** skip sub-steps a–d, append a one-line skip rationale to the Wave entry in `docs/plan.md` of the form `Why no IR at Wave boundary: self-referential polish, no new product surface, DE+PO coverage sufficient — per commands/end-working.md Step 3 carve-out.`, and proceed to Step 4. The rationale is mandatory whenever the carve-out is invoked — it is the audit evidence that the skip was deliberate, not forgotten. The Step 9 PR template's `Independent Reviewer:` line records the same fact in the `carve-out skip — <short reason>` bucket.
     **Default on doubt:** run IR. Cross-provider alignment check outweighs the cost of one extra `codex exec` invocation. Parallels Step 2 BLOCKING's default-on-doubt principle — cross-Wave safety outweighs session-continuity convenience.
   - If triggered AND the carve-out does NOT apply:
     a. Spawn Independent Reviewer in a tmux pane via `codex exec` with the following fixed one-liner — do NOT add any context, framing, or explanation:
        `codex exec "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. Write your findings to docs/independent-review.md. This is a Wave Boundary Review."`
     b. Wait for the reviewer to complete and append findings to docs/independent-review.md
     c. If CRITICAL finding: **A-layer (Policy trigger type e — critical intercept).** Emit one A-layer interrupt using the standard wording rule: the Wave Boundary Review found CRITICAL issues, the Lead is NOT blocking the commit/push (code is already written and blocking would lose work), and the next session must resolve the CRITICAL findings before starting the next Wave. Add a next-session to-do entry naming the CRITICAL findings. The A-layer interrupt is emitted BEFORE the final B-layer closing briefing; the closing briefing then references the CRITICAL as the "what Codex caught" slot.
     d. If no CRITICAL findings (PROCEED): **C-layer.** Do not emit a passing-Independent-Review announcement — a passing review is the expected state and does not change any user decision. The Wave-completion fact still surfaces in the B-layer closing briefing's what-shipped-today sentence; the IR pass is implicit in the framework having reached the close-out.
   - If not triggered (mid-Wave session, Wave not completed): skip, do not mention in briefing
4. Generate a session report and append it to `docs/session-log.md`:
   - Gather all metrics from the current session context (you know all of this from coordinating the team)
   - Run `git diff HEAD --stat` to get complete file change stats (captures both staged and unstaged changes vs last commit)
   - If `docs/session-log.md` does not exist, create it with a top-level header `# Session Log`
   - Append a new entry in the following format:

     ```markdown
     ## YYYY-MM-DD Session

     | Metric | Value |
     |--------|-------|
     | Project | [project name from CLAUDE.md] |
     | Wave | [current Wave number and name] |
     | Tasks completed | [list of tasks marked done this session] |
     | Key decisions | [any product/technical decisions confirmed by user this session] |

     ### Files Changed
     ```
     [paste git diff HEAD --stat output here as a code block, not inside the table — raw diff output contains | characters that break Markdown tables]
     ```

     ### Notes
     [Any additional context worth preserving for future sessions]
     ```

   - This file will be committed together with the other changes in the next step
5. Spawn the "Process Observer Audit" agent (Sonnet model) to audit this session:
   - Audit scope: review the session against CLAUDE.md behavioral guidelines — branching conventions, Codex review triggers, Doc Engineer execution, PR workflow, unauthorized operations, plan.md accuracy
   - Input: `git log` (commits in this session), `git diff --stat` (file changes), current branch name, plan.md (check unchecked items against actual codebase state)
   - Output: the agent returns a full compliance report (for Lead's internal reference) and a user-facing summary
   - Briefing integration:
     - If all checks PASS: **C-layer.** Do not mention the audit. A passing audit is the expected state.
     - If any checks FAIL: include only the failed items with one-line recovery suggestions inside the B-layer closing briefing's "what Codex/audits caught" slot. Do not dump the full compliance table.
   - If rule correction suggestions are identified, record them in the briefing for the next /start-working session to reference (they become next-session carry-over, not this-session narration)
   - If the audit identifies any "Framework-side" rule corrections:
     a. Append a new row to the `#### Framework Rule Polish` table inside `docs/plan.md`'s `### Backlog` section. Each row: `FR-N | gap in one sentence | fix target (Tier 1 file and clause) | priority (low/medium/high) | origin (brief session context, e.g., "PO audit of 2026-MM-DD Session — <Wave name>")`. Use the next available `FR-N` identifier.
     b. Do NOT create a `docs/framework-feedback-*.md` file — that pattern was retired 2026-04-17 per CLAUDE.md's Single TODO source rule. All PO framework-level findings route through `docs/plan.md`'s Backlog; any other channel is a workflow violation.
     c. The new Backlog row(s) ship in the same commit as this session's close-out.
     d. **B-layer (closing briefing integration).** The briefing's "what Codex/audits caught" slot references the new Backlog rows by identifier (one clause, e.g., "Process Observer flagged N framework rule gaps → plan.md Backlog FR-A..FR-B"); do NOT emit a separate status line or suggest the user act on them — they will surface at the next planning moment naturally.
   - This step has no data dependency on step 1 (Doc Engineer audit), but both are triggered sequentially by the Lead within the same session.
6. Security scan (before commit):
   - Execute `bash $HOME/.isparto/hooks/process-observer/scripts/pre-commit-security.sh`
   - If output contains BLOCK → **A-layer (Policy trigger type e — critical intercept).** Stop the commit. Emit one A-layer interrupt using the standard wording rule: name the specific blocking issue, state that the Lead is NOT committing, propose the concrete remediation (e.g., add pattern to .secureignore, or rewrite the offending line). Wait for user response before resuming.
   - If output contains WARNING → **B-layer.** Include the warning list inside the closing briefing's "what Codex/audits caught" slot (one line per warning, not a table). Proceed with commit.
   - If passed → **C-layer.** Proceed to next step. Do not announce "security scan passed."
7. Branch guard before commit:
   - Run `git branch --show-current` to check the current branch
   - If on main and there are uncommitted changes (session log, docs updates, etc.):
     - Create a `docs/session-log-MMDD` branch: `git checkout -b docs/session-log-MMDD`
     - This happens when the main work was already merged via PR before /end-working ran
   - If already on a feature branch: stay on it
   Then: git add relevant files && git commit && git push
8. GitHub account alignment (before PR):
   - Run: `REPO_OWNER=$(git remote get-url origin 2>/dev/null | sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#')`
   - Run: `GH_USER=$(gh api /user --jq .login 2>/dev/null)`
   - If both are non-empty and REPO_OWNER ≠ GH_USER:
     - Run `gh auth switch --user "$REPO_OWNER"` to align
     - C-layer: auto-switch is silent. Log to the session-log entry being written in Step 4 (add a line under Notes if the switch occurred).
   - If gh is not available or switch fails: proceed — step 9 will fall back to "push branch and inform user to create PR manually" (that fallback IS an A-layer interrupt because the user must take manual action to merge the PR)
9. If all tasks on the current branch are complete (all reviews passed, docs updated):
   - If Doc Engineer audit has NOT been run for this branch's changes: spawn Doc Engineer sub-agent now (pre-merge gate)
   - The Doc Engineer applies the acceptance re-execution rule defined in `docs/roles.md` audit item 3 (FR-26) — any grep/bash-style acceptance assertion in the plan.md Wave entry is mechanically re-run against the current repo state, not trusted on the Lead's prose PASS claim.
   - If the Doc Engineer audit reports FAIL on any item (including item 8 security compliance check, item 9 language convention check, or item 10 policy compliance check): Lead reads the failing items from the report, edits the affected files directly (per the self-referential boundary for framework files, or via Developer for non-framework code), then **spawns a fresh Doc Engineer sub-agent** (zero inherited context) for a full re-audit. Loop bounded at 3 iterations. Do not proceed to `gh pr create` while the audit is in FAIL state.
   - If the third re-audit still FAILs (loop bound exceeded), execute the **6-step blocked recovery path** defined in `docs/roles.md` Doc Engineer Key Principles: (1) stop the loop; (2) generate a blocked-audit report capturing the final FAIL state; (3) write a blocked-audit entry to `docs/plan.md` under a "Blocked audits" section; (4) `git push -u origin <current-branch>` to preserve WIP; (5) report to the user (in user's language) that Doc Engineer audit hit the loop bound, the WIP branch is pushed, and manual intervention is required; (6) exit `/end-working` without creating or merging a PR. Do not leave recovery to Lead's improvisation.
   - Create PR via `gh pr create`, merge via `gh pr merge --merge`. Use the following PR body template (pass via HEREDOC to preserve formatting) — the `Mode Selection` and audit-source lines make the workflow-compliance artifacts visible in PR metadata so later audits can verify B1 (Mode Selection Checkpoint) and C3/F1 (audit execution source) without replaying the session:
     ```markdown
     ## Summary
     <1-3 bullets summarizing the change>

     ## Mode Selection
     [Solo + Codex / Agent Team] — <reason from the Mode Selection Checkpoint at workflow step 0; if Agent Team, list Teammate count and file ownership groups>

     ## Test plan
     - [ ] <acceptance step 1 from plan.md>
     - [ ] <acceptance step 2 from plan.md>

     ## Workflow audits
     - Doc Engineer audit: [sub-agent run ✅ / Lead self-assessed ✅ / skipped — reason] (see docs/workflow.md Hotfix Workflow for skip/substitute paths)
     - Process Observer audit: [sub-agent run ✅ / Lead self-assessed ✅]
     - Independent Reviewer: [Wave boundary PROCEED ✅ / carve-out skip — short reason / not triggered — reason]
     ```
     The distinction between `sub-agent run ✅` and `Lead self-assessed ✅` for Doc Engineer and Process Observer matters: the sub-agent path is the default and provides the strongest audit guarantee (fresh context, zero inherited bias); the Lead-self-assessed path is reserved for the narrow exception cases defined in CLAUDE.md Solo/Agent Team workflow step 4 (ad-hoc fix / emergency hotfix) and must always cite the exception reason.
   - Delete local branch and switch back to main: `git checkout main && git pull && git branch -d <branch>` (remote branch is auto-deleted by GitHub on merge)
   - If `gh` CLI is NOT available: push the branch and inform the user to create and merge the PR manually on GitHub
   - If tasks are NOT complete (mid-Wave), just push — PR will be created when the branch is done

**B-layer closing briefing — the single structured briefing of this command.** After Steps 1–9 complete, emit exactly one closing briefing in the fixed shape below. Do not prepend `Session complete` or append `Ready for next session` or any other ceremonial wrapper. Do not replay the day's events in narrative form.

**Fixed B-layer shape (3-5 sentences total, in order, no headings, no bullet stacks):**

1. **What shipped today** — one sentence naming the concrete outcome, referencing Wave completion if applicable (e.g., "Wave 7 / v0.7.4 Information Layering Policy is complete — T1–T5 merged to main via PR #NNN"). If mid-Wave, name the tasks that closed (e.g., "T1 and T2 of Wave 7 are done; T3 is next"). This is the cross-session recovery surface for the next /start-working — it must always be emitted.

2. **What Codex/audits caught** — one sentence OR one short bullet cluster (max 3 bullets) listing only non-empty findings: Codex P0/P1 findings, Doc Engineer audit failures (if any), Process Observer rule gaps (if any, reference the new plan.md Backlog FR-N identifiers added in Step 5), security-scan warnings (if any), TODO-homing violations (if any, named by file + short description). If ALL of these are empty, **omit this sentence entirely** — do not emit a "no findings" placeholder. Empty = C-layer.

3. **What's next** — one sentence proposing the next concrete action using the A-layer wording rule only when there IS a next decision the user needs to make; otherwise a plain pointer ("next: T3 at the next /start-working" or "Wave is complete, awaiting your direction"). If a Wave Boundary Review CRITICAL was raised in Step 3, this sentence names the CRITICAL as the blocker to the next Wave.

**Optional fourth sentence** — only when a manual-action follow-up exists (gh unavailable → manual PR creation; Doc Engineer loop-bound hit → manual intervention; stale install → run `~/.isparto/install.sh --upgrade`). This sentence is A-layer in wording (concrete action, one reason) but sits inside the B-layer briefing because the user needs it to continue outside the session.

**C-layer items — NEVER emit in the closing briefing.** These live in the session-log.md entry written in Step 4, the commit message, and the PR body template from Step 9:
- "Session complete" / "Ready for next session" / any ceremonial wrapper
- "Doc Engineer audit passed" / "Process Observer audit passed" / "Security scan passed" (passing audits are C-layer; only failures surface)
- "gh account switched to X" (auto-switch is silent; logged in Step 8)
- Token counts, model IDs, file counts, line counts, session duration — any operational metric
- Replay of the day's events ("first we did X, then we reviewed Y, then…")
- The word "briefly" — a 3-5 sentence briefing does not need to announce itself as brief

This is a briefing, not a confirmation gate — proceed without waiting for user approval. The briefing's `Continue?` question (if the next-action sentence uses the A-layer wording rule) expects a natural user response, not a formal acknowledgement.
