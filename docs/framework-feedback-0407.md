# Framework Feedback — 2026-04-07 (Wave 2 Process Observer Audit)

Three framework-side rule corrections identified during Wave 2 (i18n cleanup — Tier 1 Englishization). All are non-blocking — Wave 2 was approved to merge — but each is a small, targeted improvement to iSparto's own framework rules.

## Suggestion 1 — plan.md update timing rule clarification

**Rule:** CLAUDE.md Development Rules

**Gap:** CLAUDE.md says "完成任务后立即更新 docs/plan.md（在同一个 commit 中，不推迟到 /end-working）" (Update plan.md immediately after completing a task, in the same commit, not deferred to /end-working). However, the **Wave-completion entry** is structurally written by `/end-working`, because that is the step that knows the Wave is fully complete and generates the commit. The current rule wording is ambiguous about this exception.

**Expected behavior:** Mid-Wave task entries are updated immediately in the same commit as the task work. Wave-completion entries (and the cross-session BLOCKING marker rewrite) are written by `/end-working` as part of the commit it generates.

**Suggested rewording (English):**

> Update `docs/plan.md` immediately after completing each task in the same commit as the task work. Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates — this is the documented exception.

**Session context:** Wave 2 finished translating Tier 1 files. The Wave 2 completion entry could not be written until all 4 Devs returned, IR/DE/PO audits passed, and the post-IR fixes landed — at which point `/end-working` is the natural place to write the entry. The Process Observer's G1 check noted this as borderline-PASS but raised the rule ambiguity.

## Suggestion 2 — F1 check spawn-source clarification

**Rule:** `agents/process-observer-audit.md` F1 row in Full Compliance Report

**Gap:** F1 currently asks "If Wave marked completed this session: was IR spawned? Was docs/independent-review.md updated? N/A if no Wave completed." The question does not clarify whether IR may be spawned by Lead during the session or only by `/end-working` Step 3 (Wave Boundary Review). Both are valid spawn paths, but the audit check is silent on this.

**Expected behavior:** F1 PASS as long as IR was spawned with the fixed prompt and report appended to `docs/independent-review.md`, regardless of whether the spawn happened during the session (Lead-initiated mid-session) or via `/end-working` Step 3 (automatic Wave-completion trigger).

**Suggested addition to F1 detail column:**

> IR may be spawned by Lead during the session or by `/end-working` Step 3 — both satisfy F1 provided the fixed-prompt pattern was used and the report is appended to `docs/independent-review.md`.

**Session context:** Wave 2's IR was spawned by Lead during the session (after all 4 Devs returned), not via `/end-working` Step 3, because the Wave was identified as complete before `/end-working` was invoked. Process Observer's F1 verification path had to reconcile this against the spawn-source ambiguity in the audit spec.

## Suggestion 3 — Principle 1 guardian enforcement gap

**Rule:** `scripts/language-check.sh` (Wave 1 deliverable) and the Documentation Language Convention in CLAUDE.md

**Gap:** `scripts/language-check.sh` performs a mechanical CJK-character scan to enforce the four-tier language convention. It does NOT detect literal user-facing English strings embedded in Tier 1 files, which is a separate violation under the same convention (Principle 1 — "Hard-coded user-facing strings rule"). The Independent Reviewer caught 3 such residual violations in Wave 2 that the guardian missed:

- `commands/env-nogo.md` lines 23-24: `"Environment ready..."` and `"There are no-go items..."`
- `commands/end-working.md` lines 22-23: literal English to-do entry and briefing note
- `agents/process-observer-audit.md` line 23: `"No workflow deviations detected."`

All 3 were resolved as post-IR fixes in Wave 2, but the underlying enforcement gap remains open for future files.

**Expected behavior:** Either extend `scripts/language-check.sh` with a Principle 1 heuristic (detect quoted English strings in Report/Inform/Output/briefing contexts within Tier 1 .md files), or add a Doc Engineer audit checklist item that does the same. The goal: catch English-literal user-facing strings before they reach IR.

**Suggested implementation (Wave 4 or earlier):**

1. Extend `scripts/language-check.sh` with a second pass: scan Tier 1 .md files for the regex `(Report|Inform|Output|note in.*briefing|output)\s*\(?[^)]*\)?\s*[":]\s*"[^"]+"` (rough heuristic for quoted user-facing literal strings in instruction contexts), excluding code blocks and template placeholders. Emit warnings for matches.
2. Or: add a Doc Engineer audit checklist item: "Scan Tier 1 .md files for hardcoded English user-facing strings in Report/Inform/Output/briefing contexts. Report findings before merge."
3. Promote to a blocking gate when the heuristic stabilizes (Wave 4 timeline candidate).

**Session context:** Wave 2 verification correctly hit Tier 1 = 0 on the CJK-only check, but IR caught the residual English literals on its own scan. This is exactly the third-line-of-defense pattern documented in the Wave 2 plan ("Devs → Phase 2 cross-check → IR"), but it would be cleaner to catch these at the guardian or DE layer instead of relying on IR.
