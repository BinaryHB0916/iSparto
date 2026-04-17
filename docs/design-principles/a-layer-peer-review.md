# A-layer Peer Review

## Overview

A-layer Peer Review is the structural guard against A-layer inflation. When Lead proposes an A-layer output — a decision interruption that blocks the user and demands a response — an Independent Reviewer verifies the output's classification, framing, correctness, and single-voice integrity before it reaches the user.

This document defines the principle side: judgment axes, verdict format, conflict-resolution rule, and scope. The invocation-side role definition lives in `agents/independent-reviewer.md` (Phase 0 and Wave Boundary review modes). A-layer Peer Review was added in v0.7.4 as part of the Information Layering Policy.

Peer Review is intentionally scoped to A-layer outputs only. B-layer briefings (fixed pause points at `/start-working` open, `/end-working` close, `/plan` proposal) and C-layer silent operations (hook auto-repair, auto-switches, green status) are Lead-autonomous and never reach the reviewer.

## Why This Exists

The Information Layering Policy (`docs/design-principles/information-layering-policy.md`) classifies user-facing outputs into three layers: A (decision interruption), B (decision preparation at fixed pause points), C (silent archive). If Lead could unilaterally classify any output as A-layer, the facts-dumping failure mode would return through A-layer inflation — everything becomes urgent, every message blocks the user. Peer Review is the mechanism that prevents that drift: a second eye verifies that Lead's proposed A-layer output actually matches the 5 trigger types in Policy Principle 1, and rewrites or rejects when it does not.

## Invocation Trigger

Lead spawns the reviewer with the fixed prompt:

> You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. This is an A-layer Peer Review. The proposed A-layer output is attached verbatim below.

Lead MUST include the exact verbatim text of the proposed A-layer output. If the verbatim output is missing, the reviewer refuses the review and requests a re-spawn with the exact text attached.

## Tool Permissions (Read-Only by Default)

During A-layer Peer Review the reviewer has the following tools:

- Read, Grep, Glob, ListMcpResourceTool — read project artifacts
- Bash (read-only subset: `git log`, `git diff`, `git status`, `git branch`, file listing)
- MCP read tools (e.g., `mcp__codex-dev__listSessions`, `mcp__codex-dev__ping`)

The reviewer MAY NOT use: Edit, Write, NotebookEdit, Bash destructive commands, or any tool that mutates project state. If the reviewer believes the A-layer output is correct AND needs something written somewhere, it reports that need to Lead — the reviewer does not write.

### Deep-IR Gate (Policy Trigger Type d)

For a narrow category of A-layer judgments — security findings, architecture decisions, irreversible-operation judgments — read-only review is insufficient because the verdict depends on actually running scripts, tests, or external queries. The reviewer may request deep-IR authorization from Lead, which crosses the read-only boundary.

Deep-IR request procedure:

1. State why read-only is insufficient (one sentence).
2. Name the exact scripts/tests/queries needed.
3. Wait for Lead to escalate the deep-IR request to the user as an A-layer interrupt (Policy trigger type d).
4. Only after the user authorizes, run the scripts/tests/queries and continue.

Do not run anything beyond the read-only subset without explicit authorization passed through Lead.

## Independent-Judgment Rule

When the reviewer receives the A-layer Peer Review spawn, it does NOT accept Lead's framing as true. It re-reads the relevant project artifacts (plan.md current Wave, product-spec.md affected sections, actual code state, independent-review.md prior findings, information-layering-policy.md for classification rules) and forms its own verdict. Lead's proposed A-layer output is evidence of Lead's reasoning, not a conclusion the reviewer ratifies.

## Four Judgment Axes

Review the proposed A-layer output along four axes, in order:

1. **Classification** — is this output actually A-layer, or is Lead mis-classifying a B/C-layer item as A-layer? Check against the 5 trigger types in Policy Principle 1. If none of the 5 match, the output is NOT A-layer and Lead should downgrade it.

2. **Framing** — does the proposed output follow the A-layer wording rule from `docs/design-principles/conversation-style.md`? Specifically: (a) one proposed action with a one-clause reason, (b) one alternative named concretely (or explicit "no viable alternative"), (c) terminal "Continue?" question, (d) no menu-delegation, (e) no hedges, (f) no narration of the classification decision itself.

3. **Correctness** — is the proposed recommendation actually right? This is where the reviewer does its own analysis against primary sources. Check: does the reason hold up? Is the alternative really the best alternative? Are there risks Lead has omitted? Is the action actually the minimum-viable move, or is it bundled with unnecessary scope?

4. **Single-voice integrity** — does the proposed output mix "Lead voice" and "reviewer voice" in a way that would confuse the user? The user should see one voice (Lead's); the reviewer's corrections must be deliverable as Lead-voice edits, not as a parallel commentary.

## Verdict Format

Write the A-layer Peer Review to `docs/independent-review.md` under a new dated section. Format:

```
---

## A-layer Peer Review — [date] [HH:MM]

**Context:** [one sentence naming what session Lead is in and which of the 5 trigger types Lead assigned]

**Proposed A-layer output (verbatim from Lead):**
> [quoted text, exactly as Lead proposed it]

**My verdict:**
1. Classification: [CORRECT / INCORRECT — if incorrect, name the correct layer]
2. Framing: [CORRECT / INCORRECT — if incorrect, name the specific wording-rule violation]
3. Correctness: [CORRECT / INCORRECT — if incorrect, explain the substantive error]
4. Single-voice integrity: [CORRECT / INCORRECT]

**Recommendation:** [APPROVE / APPROVE-WITH-EDIT / REJECT]

**If APPROVE-WITH-EDIT:** [the exact corrected text Lead should emit, in Lead-voice, ready to copy-paste]

**If REJECT:** [one-sentence explanation and the recommended action — typically either "downgrade to B-layer" or "rewrite from scratch using the Policy Principle 1 trigger type NAME"]
```

## Conflict-Resolution Rule — Reviewer Prevails

When the reviewer and Lead disagree on any of the four judgment axes, **the reviewer prevails**. Lead does not debate the verdict. Lead re-emits the A-layer output using the reviewer's corrected version (for APPROVE-WITH-EDIT) or withdraws the A-layer output entirely (for REJECT).

This rule exists because the Policy exists: if Lead could override the reviewer on A-layer classification, the facts-dumping failure mode would return via A-layer inflation ("everything is urgent"). The reviewer is the structural guard against that drift.

## Single-Voice Delivery Rule

The reviewer does NOT speak directly to the user. The verdict is written to `docs/independent-review.md` and delivered to Lead; Lead then re-emits the corrected A-layer output to the user as its own voice. The user sees one voice throughout — the correction mechanism (reviewer prevailing) is a backstage rule, not a user-facing interaction.

If the reviewer believes the user urgently needs to see the verdict directly (e.g., Lead is attempting to merge a destructive operation that the reviewer has rejected but Lead is ignoring), the correct recovery is to write an APPROVE-WITH-EDIT verdict whose "corrected text" is a Lead-voice A-layer interrupt explaining the situation. The reviewer remains behind the scenes; Lead is the single voice.

## Regular vs Deep-IR Trigger Matrix

| Scenario | Regular Peer Review (read-only) | Deep-IR (authorized script/test execution) |
|----------|----------------------------------|--------------------------------------------|
| Plan proposal (trigger type a) | ✅ default | only if plan depends on empirical benchmarks |
| Codex P0/P1 finding (trigger type b) | ✅ default | only if finding severity depends on runtime state |
| Irreversible git/file operation (trigger type c) | ✅ default | only if reversibility depends on runtime state not visible to `git status` |
| Reviewer deep-IR self-request (trigger type d) | N/A — this IS the deep-IR gate | ✅ the deep-IR request itself is A-layer |
| Process Observer critical intercept (trigger type e) | ✅ default | only when the intercept is security/architecture |

Default to regular Peer Review. Deep-IR is the narrow exception and requires the authorization protocol above.

## Out of Scope

- B-layer briefings (`/start-working` open, `/end-working` close, `/plan` proposal) — these are Lead-autonomous and the reviewer is not invoked.
- C-layer silent operations (hook auto-repair, auto-switches, green status) — these never surface to the user at all.
- Internal agent-to-agent messages (Lead → Developer prompts, Teammate → Developer prompts) — these are not user-facing output.
- File content Lead writes to `docs/*.md` or `commands/*.md` during the Implementation Protocol — Doc Engineer handles that audit, not Peer Review.

## See Also

- `agents/independent-reviewer.md` — Independent Reviewer role definition and the Phase 0 / Wave Boundary review procedures.
- `docs/design-principles/information-layering-policy.md` — the 5 A-layer trigger types and the layer classification rules.
- `docs/design-principles/conversation-style.md` — the A-layer wording rule referenced in Judgment Axis 2.
