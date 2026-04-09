## Framework feedback — 2026-04-09 Session #c (v0.7.5 README restraint-narrative Wave PO audit)

### F1 — Wave-level batch-review safety-net does not carve out self-referential-boundary-only Waves

**Observed session:** `feat/v075-readme-restraint` (v0.7.5 README restraint-narrative Wave, 2026-04-09)

**Symptom:** PO audit had to manually reconcile two clauses that point in opposite directions:
1. `docs/workflow.md` Wave-level safety-net sentence — "Each Wave must include at least one batch Developer review before completion, regardless of how individual changes are categorized."
2. `CLAUDE.md` Implementation Protocol L121 — "Exception: see the self-referential boundary in Development Rules (iSparto framework editing its own framework files)."

The v0.7.5 Wave touched only Tier 1 markdown templates, Tier 2 reference docs, Tier 3 README, Tier 4 historical artifacts, plus a 5-line data-only patch to `scripts/language-check.sh`'s `TIER2_EXCLUDED_FILES` Python set. No Tier 1 logic changes. No code. By the self-referential boundary exception, Lead correctly performed all edits directly without invoking Developer. But the Wave-level safety-net sentence reads as unconditional ("regardless of how individual changes are categorized"), and a reader without prior Wave precedent (Framework Polish Round 2, v0.7.4 Wave, Post-Wave-5 Hotfixes) could legitimately flag the entire Wave for missing the required batch review.

**Root cause:** The Implementation Protocol exception was added with a clause-level scope ("the Implementation Protocol does not require Developer for self-referential edits") but the Wave-level safety-net sentence was written before that exception existed and was never updated to match. The two rules were composed by reader inference rather than by an explicit cross-reference.

**Recovery this session:** PO audit applied the Implementation Protocol exception as the controlling clause and noted the resolution in B3's PASS detail. No rework was needed because the precedent set by Framework Polish Round 2 / v0.7.4 / Post-Wave-5 Hotfixes had already established the convention. But the rule reading required PO-level workflow knowledge — a fresh reader doing the same audit cold could plausibly mark this PASS as WARN or FAIL.

**Proposed fix:** Add a parenthetical carve-out to the Wave-level safety-net sentence in `docs/workflow.md` matching the wording style of CLAUDE.md L121:

> Each Wave must include at least one batch Developer review before completion, regardless of how individual changes are categorized **(except when the entire Wave change set falls within the self-referential boundary defined in CLAUDE.md Development Rules — markdown-only / data-only / no Tier 1 logic changes — in which case Developer is exempted per the Implementation Protocol exception at CLAUDE.md L121).**

This is a single-sentence amendment to one location in `docs/workflow.md`. No structural change. No new rule. Just makes the existing convention explicit so PO audits do not need workflow lore to apply the exception correctly.

**Priority:** Medium. Triggers every time a self-referential-only Wave runs through PO audit. Does not block any current workflow because precedent has resolved it for the regulars, but creates audit friction for any new contributor running PO cold.

**Affected files if accepted:**
- `docs/workflow.md` Wave-level safety-net section — single sentence amendment
- (Optional) `agents/process-observer-audit.md` B3 check description — add a one-line note that the Wave-level safety net respects the self-referential boundary carve-out, mirroring the workflow.md amendment

**Session log evidence:** This file. The PO audit's B3 PASS detail explicitly cites "subordinate to the Implementation Protocol's self-referential boundary exception" as the controlling clause, demonstrating that the resolution required external interpretation rather than rule reading.

### F2 — A3 (branch guard precedence) check guidance assumes git-only verification is possible

**Observed session:** Same Wave as F1 above.

**Symptom:** The A3 check (added in this Wave per T5) instructs PO to "inspect `git reflog` + session Edit/Write timestamps vs the `git checkout -b` timestamp." This guidance reads as if PO can verify A3 from git state alone. But:

1. `git reflog` records branch operations (checkouts, commits, resets, merges) — it does not record individual Edit/Write tool calls.
2. When a Wave's work is entirely uncommitted at PO audit time (as in v0.7.5: PO audit ran at T8.7, before any commit on the feature branch), PO can verify the checkout timestamp but cannot independently verify from git state alone that no Edit/Write call preceded the checkout on `main`.
3. The session context — what tool calls actually occurred and in what order — is the only authoritative evidence source for that ordering, and the session context is not a git artifact.

**Root cause:** The A3 check was written assuming the PR-178 failure mode (Lead edits files on main, then later switches to a feat branch) leaves git-visible evidence (a commit on main, or a stash, or a reflog HEAD movement). It does. But the **success** state — Lead correctly switches to feat first, then edits — does NOT leave git-visible evidence of the *ordering* until the first commit on the feat branch lands. PO running at T8.7 (pre-commit) is structurally unable to verify the success state from git alone.

**Recovery this session:** PO audit treated A3 as PASS based on the combination of (a) reflog showing the checkout transition with no prior modifying operations on main, and (b) session context confirming all working-tree modifications happened post-checkout. PO had to add a paragraph explaining this two-source verification because the A3 description does not authorize it.

**Proposed fix:** Amend the A3 detection guidance in `agents/process-observer-audit.md` to spell out the two evidence regimes:

> Detection: When the Wave's work is **already committed** at audit time, inspect `git reflog` + commit history — any commit on main between session start and the checkout to a feat/fix branch is a FAIL (downgraded to WARN per the rule). When the Wave's work is **still uncommitted** at audit time (PO audit running pre-commit, e.g., during `/end-working` step T8.7), use a two-source verification: (1) `git reflog` confirms the checkout transition from main with no prior reset/HEAD movement that could mask earlier work, AND (2) the session context / plan.md entry confirms the ordering. PASS with context-corroboration is acceptable in this regime; the rule's intent (catch the PR-178 failure mode) is preserved without requiring git-impossible evidence.

**Priority:** Medium-low. The check itself is correct in spirit; only the detection guidance needs the two-regime split. Without this fix, future PO audits running cold may incorrectly mark uncommitted-at-audit-time Waves as INDETERMINATE or fail to apply A3 at all.

**Affected files if accepted:**
- `agents/process-observer-audit.md` A3 row — replace the single Detection sentence with the two-regime version above
- (Optional) `docs/process-observer.md` A3 check reference — mirror the change for documentation consistency

**Session log evidence:** PO audit's A3 PASS detail in this session cites "no earlier timestamps for Edit/Write calls on main appear in reflog" as the verification. That is technically circular — reflog cannot record Edit/Write timestamps in the first place. The PASS verdict is correct, but the stated method is not the actual method. The actual method is the two-source verification, which the current A3 guidance does not authorize.

---

**Note on placement:** Today already has `docs/framework-feedback-0409-b.md` from the earlier `docs/principle5-total-collapse` session. This file is `-c` for the v0.7.5 README restraint-narrative session (Session #c on 2026-04-09).
