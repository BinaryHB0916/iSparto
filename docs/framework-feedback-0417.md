# Framework Feedback — 2026-04-17

Source: Process Observer post-session audit of Wave B (docs 层 dedup, v2.4 Two-Wave Doc Restructure close-out) on 2026-04-17. Audit result: 10/10 PASS (F1 Independent Reviewer correctly N/A under precedent), 0 workflow deviations. One framework-side rule correction suggestion surfaced from a conversational exchange during close-out about the Wave A → Wave B BLOCKING marker experience.

## Rule 1 — BLOCKING marker rule is over-coarse, fires on any Tier 1 modification regardless of semantic impact on next Wave

**Rule ID:** `commands/end-working.md` (marker emission step) + `commands/start-working.md` Step 0 (marker detection gate) — collectively the cross-session BLOCKING handoff mechanism, originally introduced in commit `8fa4cad` (2026-04-07, i18n Wave 2 — Tier 1 Englishization).

**Gap description:** The current rule is mechanical: if a Wave modifies any Tier 1 file (CLAUDE.md, CLAUDE-TEMPLATE.md, commands/*.md, agents/*.md, hooks/**, templates/*.md, etc.), the Wave close-out emits a `🚨 BLOCKING: Next Wave requires NEW SESSION` marker, and the next `/start-working` hard-stops until the user confirms a fresh session. The rule fires on **any** Tier 1 modification regardless of whether the modification's content would actually be read from the stale session-start system-prompt cache by the next Wave's Lead.

The rationale for the rule is correct at the mechanism level: Claude Code loads Tier 1 files into the Lead's system prompt at session start, and those files are not re-read mid-session. A Wave that changes the system-prompt content requires a fresh session so the next Wave's Lead operates on the updated content, not the stale cached copy. This is a physical constraint of Claude Code's harness (one-shot system prompt load), not an iSparto design choice.

However, the rule is applied uniformly to all Tier 1 modifications, which is over-conservative in cases where the modification does not change the **behavior** the next Wave would consult. Concrete example demonstrated this session:

- Wave A modified CLAUDE.md by extracting the Collaboration Mode section to `docs/collaboration-mode.md` and leaving a pointer.
- Wave B's execution (docs/ layer dedup across Tier 2 files) does not read the Collaboration Mode content from CLAUDE.md to perform its work — it reads concepts.md / roles.md / workflow.md / user-guide.md / design-decisions.md directly.
- Wave B's Lead could therefore have operated correctly on the pre-Wave-A stale CLAUDE.md cache (with inline Collaboration Mode) and produced the same output.
- The BLOCKING marker's session-reset was unnecessary for Wave A → Wave B specifically.

In contrast, the original 2026-04-07 i18n Wave 2 context was unambiguous: the Tier 1 Chinese→English translation changed the **language** of every Tier 1 file, and the next Wave's Lead would operate on Chinese content if the session were not reset. BLOCKING was necessary there.

**Expected behavior:** The BLOCKING marker emission step in `commands/end-working.md` should gain a semantic-impact pre-check before writing the marker. The gate should ask: "Does the Tier 1 change alter behavior that the next Wave's Lead would read from the stale session-start cache?" If yes → emit marker. If no (the change is content-extraction, content-deduplication, or additive documentation that the next Wave does not depend on) → do not emit marker; record the Tier 1 modification in plan.md without the cross-session barrier.

The `commands/start-working.md` Step 0 detection gate should remain unchanged — it still hard-stops on any detected marker, because once the marker is written it represents a real cross-session requirement.

A candidate refinement structure for the pre-check:

- Mechanical default: any modification to CLAUDE.md behavioral rules, commands/*.md step content, agents/*.md system prompts, or hooks/ scripts → emit BLOCKING (these are the high-signal cases where next-Wave Lead genuinely reads the stale content).
- Explicit opt-out for low-signal cases: pointer extraction from Tier 1 to Tier 2 (content moves but Tier 1 still has the pointer + the Tier 2 authoritative file is loaded on-demand), Documentation Index / Module Boundaries table additions, typo fixes, language-check guardian adjustments, and similar structural changes that do not alter runtime Lead behavior → skip BLOCKING with an explicit `**BLOCKING skip rationale:**` line in the Wave close-out plan.md entry naming the change type and why next-Wave Lead does not depend on it.

The opt-out list should be an enumerated whitelist maintained in `commands/end-working.md`, not a Lead-runtime judgment call, to preserve the rule's mechanical-enforcement property (per CLAUDE.md §Runtime Output Layering — the framework prefers pre-defined structural rules over runtime discretion).

**Session context:** The Wave A → Wave B close-out today surfaced this as a user observation. Sequence: user asked what the BLOCKING marker was during `/start-working`; Lead explained the cache-staleness mechanism; user asked the origin rationale; Lead pulled git history (`8fa4cad`, 2026-04-07 i18n Wave 2) to surface the origin story; user asked whether it was a context-window capacity issue; Lead clarified it was Tier 1 system-prompt caching (not token budget); user pushed that cross-Wave dependency requiring session reset indicated a task-decomposition failure; Lead honestly acknowledged the user's instinct was half-right — Waves ARE sequential by design so cross-Wave dependency is allowed (concepts.md §Wave Parallelism: "parallel within a Wave for speed, sequential across Waves for quality"), but the BLOCKING rule IS coarse and over-fires on any Tier 1 modification regardless of semantic impact on next Wave. User asked whether to refine BLOCKING first (path B) or close Wave B first (path A); Lead recommended A (clean state before framework design discussion) with explicit reasoning that BLOCKING refinement itself needs a Tier 1 edit (`commands/*.md`) and thus a new session under the current rule; user agreed.

This framework-feedback file captures the insight for a future `/plan` session that would design and implement the refinement. The refinement would itself modify `commands/start-working.md` and `commands/end-working.md` (both Tier 1), so under the current mechanical rule it would emit a BLOCKING marker on close-out — the first Wave after the refinement would need a new session. After the refinement lands, subsequent Tier 1 modifications whose semantic impact does not affect the next Wave would stop emitting BLOCKING, reducing the session-reset churn that has been accumulating across every Tier 1 touch since 2026-04-07.

**Suggested fix:** Open a `/plan` session for this refinement. Scope:

1. `commands/end-working.md` — add a BLOCKING pre-check step between the current marker-emission step and the plan.md write step. The pre-check reads the Wave's file-change list and matches each Tier 1 change against the whitelist of low-signal change types. If all Tier 1 changes are whitelisted, skip BLOCKING and require an explicit `**BLOCKING skip rationale:**` entry in the Wave plan.md entry. If any non-whitelisted Tier 1 change exists, emit BLOCKING as today.
2. `commands/start-working.md` Step 0 — unchanged. Marker presence still gates new-session confirmation.
3. `agents/process-observer-audit.md` — add a new check (e.g., C3) verifying that the Wave plan.md entry's BLOCKING handling (either `🚨 BLOCKING` marker emitted OR `**BLOCKING skip rationale:**` recorded) is consistent with the actual Tier 1 file-change set and whitelist.
4. `docs/design-decisions.md` — record the refinement decision with rationale (mechanical whitelist preferred over runtime Lead discretion, per the framework's Information Layering Policy).

Priority: low-to-medium. Not blocking any current Wave. Current over-conservative behavior is safe (session resets are cheap for the user, just an extra step); the refinement is a session-reset churn reduction, not a correctness fix. Fold into the v0.8 roadmap planning session when it runs, or a dedicated framework-polish Wave — whichever comes first.

## Rule 2 — plan.md commit count accuracy rule is timing-ambiguous for pre-commit Wave entries

**Rule ID:** `CLAUDE.md` line "plan.md verification-count accuracy" — "compute it mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` at the time the entry is written — not by estimation."

**Gap description:** For Wave close-out entries written as part of the commit they document (per the line above it: "Wave-completion entries and cross-session BLOCKING markers are written by `/end-working` as part of the commit it generates"), the entry is authored a moment **before** the commit exists. At that moment, `git log --oneline --no-merges <wave-base>..HEAD | wc -l` returns `0`, but the committed-count target is `1`. The entry records `= 1` as a projected value, which is strictly an estimate until the commit lands. This session's Wave entry demonstrated the pattern: the line "1 non-merge commit on the Wave branch (`git log --oneline --no-merges 2e5f79a..HEAD | wc -l` = 1)" was written pre-commit and the count matched only after the commit was created. Process Observer had to classify this as "PASS (projected)" — a fragile audit classification that depends on post-commit verification being done by Lead.

**Expected behavior:** The CLAUDE.md rule should explicitly acknowledge the pre-commit case. Suggested rewording: "Compute the count mechanically via `git log --oneline --no-merges <wave-base>..HEAD | wc -l` immediately after the commit that includes the Wave entry lands. For entries authored pre-commit (standard /end-working cadence), write the projected count and re-verify via the same command as part of the post-commit / pre-push sanity sweep; if mismatch, amend before push." This makes the verification a required step of /end-working, not an implicit Lead habit.

**Session context:** Surfaced by Process Observer audit of the BLOCKING Marker Semantic Gate Wave (2026-04-17, same session as this Rule 1 refinement). PO classified E3 as PASS (projected) while noting the fragility. Low-priority polish — the actual failure mode (Lead forgets to verify post-commit and commits a wrong count) has not occurred in any recorded Wave close-out. Fold into the same v0.8 roadmap planning or framework-polish Wave that would address Rule 1-style refinements if they recur.

## Rule 3 — BLOCKING literal sentinel vs rationale prose lack an explicit "same edit" write-together rule

**Rule ID:** `commands/end-working.md` Step 2 BLOCKING marker decision sub-bullet (codified by the Semantic Gate Wave and refined by the Gate Narrowing Wave, 2026-04-17) + mid-sequence PO audit expectations.

**Gap description:** The BLOCKING emission decision has two outputs: (a) a prose "BLOCKING marker rationale for next session" paragraph inside the Wave plan.md entry, and (b) the literal sentinel `🚨 BLOCKING: Next Wave requires NEW SESSION` appended after the entry as the machine-detectable boundary token matched by `commands/start-working.md` Step 0. The current rule text describes when to emit the marker and what prose to include, but does not explicitly require the sentinel and the rationale to be written in the same edit operation. PO audit on Wave C (2026-04-17) caught the real-world failure mode: the rationale was present in the Wave entry but the sentinel was not yet appended after the Next step line, and since the PO audit runs pre-commit inside `/end-working`, the audit classified this as WARN rather than IN-PROGRESS.

**Expected behavior — two acceptable fixes:**

1. **Tighten `commands/end-working.md` to require atomicity:** add one sentence to the BLOCKING marker decision sub-bullet — "When the gate fires (BLOCKING required), the literal sentinel MUST be appended to plan.md in the same edit operation as the rationale prose; do not defer." This eliminates the interim state.
2. **Or tighten `agents/process-observer-audit.md` audit criteria:** add one line to the BLOCKING-marker check — "Rationale-without-sentinel pre-commit is IN-PROGRESS, not WARN. WARN only if the Wave entry is committed without the sentinel." This documents the interim state as expected.

Either produces a clean audit signal. Option 1 is stricter (eliminates the interim state entirely); option 2 is more permissive (tolerates the interim state as valid). Recommend option 1 — it aligns with the framework's general preference for mechanical structure over runtime discretion (per CLAUDE.md §Runtime Output Layering).

**Session context:** Wave C (2026-04-17) / PO audit E3 flagged this as a WARN with a correct recovery recommendation (append the sentinel before commit). Lead applied the recovery in the same edit sequence that introduced this Rule 3. Filed here as the next-/plan candidate for the follow-up framework-polish Wave.

## Rule 4 — Independent Reviewer skip at Wave boundary lacks explicit exit criteria

**Rule ID:** `commands/end-working.md` Step 3 (Wave Boundary Review) — specifies that upon Wave completion, Independent Reviewer is spawned as a Teammate with a fixed prompt; does not enumerate conditions under which the spawn may be skipped.

**Gap description:** The project's actual practice across 6+ consecutive Waves (Wave A / Wave B / Semantic Gate / Gate Narrowing / Wave C / v0.7.8 Polish) has been to skip IR for framework-self-referential polish Waves, documenting the rationale inline in each Wave's plan.md entry under a "Why no Independent Reviewer at Wave boundary" paragraph. This established precedent has effectively modified Step 3 by custom, but the command definition has not been updated to acknowledge it. A future Lead operating without the current session's precedent context would read Step 3 as mandatory and either invoke IR unnecessarily (cost: 10-20 min + user review attention for framework-internal polish that does not need IR product-behavior coverage) or feel procedural uncertainty and freeze at the boundary.

**Expected behavior — skip carve-out parallel to the BLOCKING marker's skip-rationale mechanism.** Add a carve-out to Step 3 with three conditions that ALL must hold for skip to be acceptable:

1. All modified files are within the framework self-referential boundary (per CLAUDE.md Development Rules — Tier 1 System Prompt Layer files + `scripts/` + `hooks/` + Tier 2 `docs/`).
2. Scope is limited to doc-layer edits or internal tooling with no new product-behavior surface (no new user-facing features, no public API/interface additions, no hook rule changes that would change user-observable behavior).
3. Doc Engineer audit + Process Observer audit are confirmed complete in the same session.

When all three hold, skip is acceptable; Lead MUST document the rationale in the Wave's plan.md entry ("Why no Independent Reviewer at Wave boundary: …") citing which conditions are met. Default on doubt = spawn IR. Otherwise the current mandatory-spawn text remains in force.

**Session context:** v0.7.8 Framework Polish Wave Process Observer audit (2026-04-17) flagged the precedent-vs-spec divergence. Audit classified F1 as PASS under the spirit of the rule, given the explicit rationale in the Wave's plan.md entry; identified the gap as framework-level. Recommendation: fold into the next framework-polish Wave or the v0.8 roadmap `/plan` session.

## Rule 5 — BLOCKING marker boundary acknowledgement path undefined for mid-session CLAUDE.md updates

**Rule ID:** `commands/start-working.md` Step 0 (Session boundary check) + `commands/end-working.md` Step 2 BLOCKING marker decision.

**Gap description:** Step 0's marker-detection gate assumes the BLOCKING marker is acknowledged at the start of a new session via the Step 0 ceremony (user confirms "new session" → Lead writes a "✅ Session boundary acknowledged YYYY-MM-DD by /start-working" annotation below the marker). The gate does NOT define what happens when all four of the following occur:

1. A Wave that emits BLOCKING lands (e.g., Wave C + Rule 2, 2026-04-17).
2. The user continues in the same Claude Code session (does NOT close the window and open a new one).
3. CLAUDE.md was modified by the landed Wave, and Claude Code's system-reminder mechanism injects the updated `## Contents of ... CLAUDE.md` content into the active session context when the file changes on disk.
4. The Lead now operates with the updated rule visible in context, satisfying the marker's underlying intent (no stale-cache operation) through a mechanism the Step 0 ceremony does not account for.

The current session (v0.7.8 Polish Wave) hit exactly this scenario and handled it by writing a boundary annotation below Wave C's marker documenting the non-standard acknowledgement path. But the path is undocumented in the framework, making it ad hoc and depending on Lead judgment rather than rule.

**Expected behavior:** Add one sentence to `commands/start-working.md` Step 0 (and cross-reference from `commands/end-working.md` Step 2): "If CLAUDE.md was modified mid-session AND the updated content was surfaced to Lead via Claude Code's system-reminder injection before any subsequent Wave work began, the BLOCKING boundary is considered acknowledged for that session's continuation. Lead documents the acknowledgement path in a prose annotation immediately below the marker in plan.md (format: `> ✅ Session boundary acknowledged YYYY-MM-DD — <rule name> update surfaced via mid-session CLAUDE.md system-reminder injection`). This path applies only when the active session's context demonstrably includes the updated CLAUDE.md content; it does not extend to scenarios where the session was dormant across the Wave or where system-reminder injection did not fire."

**Session context:** v0.7.8 Framework Polish Wave Process Observer audit (2026-04-17) classified G1 as PASS under the spirit of the rule; identified the gap as framework-level. The session handled the case correctly but ad hoc; formalizing the path prevents future Lead uncertainty. Recommendation: fold into the next framework-polish Wave or v0.8 roadmap planning.

## Summary

Five framework-side rule refinement candidates surfaced across 2026-04-17's Wave sequence. Rule 1 (BLOCKING marker rule over-coarse) was surfaced during Wave B close-out and **addressed by the BLOCKING Marker Semantic Gate Wave + Gate Narrowing Wave in the same day** — now retrospective documentation of the problem and fix. Rule 2 (plan.md commit count timing ambiguity) surfaced from the Semantic Gate Wave's PO audit and was **addressed by the Wave C + Rule 2 Wave in the same day (CLAUDE.md + CLAUDE-TEMPLATE.md wording updated)** — also now retrospective. Rule 3 (BLOCKING literal sentinel vs rationale prose write-together rule) surfaced from Wave C's PO audit and is deferred to the next framework-polish Wave or v0.8 roadmap planning session. Rule 4 (IR skip at Wave boundary lacks explicit exit criteria) and Rule 5 (BLOCKING marker boundary acknowledgement path undefined for mid-session CLAUDE.md updates) surfaced from v0.7.8 Polish Wave's PO audit (both classified PASS under spirit of rule, framework-level gaps) and are deferred to the same follow-up Wave. None of the five rules — addressed or open — is blocking any current work.
