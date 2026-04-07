# Framework Feedback — 2026-04-07 Session #3

Source: Process Observer session-level audit (Sonnet 4.6) at end of Wave 3 (i18n cleanup — Tier 2 Englishization).

Audit verdict for the session: 14 PASS / 0 WARN / 0 FAIL. The single item below is a documentation gap, not a violation of any existing rule. No action required this session.

---

## Suggestion 1 — Clarify language expectation for forward-looking sections of `docs/plan.md`

**Rule ID:** CLAUDE.md > Documentation Language Convention > Tier 4

**Gap description:**
`docs/plan.md` is in `language-check.sh`'s Tier 2 exclusion list because it contains historical Chinese sections (Tier 4) that must not be retroactively edited. However, the file also contains *forward-looking* sections — `### 下一步` (Next steps) at lines 259–273 and `### 技术生态追踪` (Tech Ecosystem Tracking) at lines 275+ — which are active planning content, not historical artifacts.

By topic, these sections read as Tier 2 (active reference content). By their containing file's exclusion status, they fall outside the language guardian's scan. The four-tier architecture in CLAUDE.md does not explicitly say which tier governs forward-looking sections of an otherwise-excluded file.

**Expected behavior (one of two clarifications, framework decides):**
- **Option A — explicit Tier 4 freeze for the entire file:** State in CLAUDE.md that `docs/plan.md` is wholly Tier 4 and forward-looking sections are exempt from the English-only rule. Implication: future Wave plans may continue to use mixed language inside plan.md.
- **Option B — split treatment:** State that historical entries inside plan.md are Tier 4 frozen, but forward-looking sections (e.g., `### 下一步`, `### 技术生态追踪`) are Tier 2 and should be in English. Implication: a future docs/ hotfix should translate the active sections, and the `language-check.sh` exclusion should become per-section rather than per-file.

**Session context:**
- Wave 3 Englishized all 9 `docs/*.md` Tier 2 files plus added `docs/independent-review.md` to the Tier 2 exclusion list (Lead-Resolution Option A) for audit-trail-immutability reasons.
- After Wave 3, PO ran the session-level audit and inspected `docs/plan.md` lines 259–274 for plan.md accuracy (G4 check). The check itself passed (no unchecked Wave 3 items in inconsistent state), but the inspector noted that the Chinese forward-looking content sits in a gray zone of the four-tier architecture.
- This is a documentation clarity issue, not a violation. No commit was blocked, no rule was broken.

**Recommendation:** Add a one-line clarification to CLAUDE.md > Documentation Language Convention > Tier 4 in a future docs/ hotfix (or fold into Wave 4 if Wave 4 touches the language guardian / CLAUDE.md). Either Option A or B is defensible — Option A is the lower-friction choice; Option B is the more consistent choice with the broader Tier 2 doctrine.

**Not part of Wave 3 PR.** Logged here for the next session to consider.
