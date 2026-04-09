# Conversation Style Guide

**Status:** Active since v0.7.4 (2026-04-09)
**Scope:** The concrete wording rules and before-after samples for A-layer and B-layer output. This guide is the operational companion to `docs/design-principles/information-layering-policy.md` — the Policy defines the what and why; this guide defines the how.

## Reading order

Read the [Information Layering Policy](./information-layering-policy.md) first. This guide assumes you already understand the three layers (A/B/C), the 5 A-layer trigger types, and the single-voice delivery rule. If you are modifying a command template or an agent role definition and do not know whether an output is A-layer or B-layer, stop and re-read Policy Principle 1.

## A-layer wording rule

A-layer output is a **proposal**, not a menu. The Lead always proposes one path, names the most viable alternative, and stops. The user responds yes/no/switch; the Lead does not delegate the choice.

**Standard template:**

> I plan to **X**, because **Y**. If you disagree, I can switch to **Z**. Continue?

- **X** — the concrete action the Lead is about to take. One verb, one object. Not a category ("do some refactoring") but a specific move ("rename `legacy_auth.sh` to `auth_v1.sh` and update the 3 call sites in `install.sh`").
- **Y** — the reason, in one clause. Why this specific action, not a general rationale for the whole task. If you cannot state Y in one clause, the action is probably wrong or the scope is too wide.
- **Z** — the most viable alternative, named concretely. Not "we could do something else." If there is no viable alternative, say so: "No viable alternative — this is the only path I see. Continue?"
- **Continue?** — the terminal question. One word. The user's response is binary plus an optional third branch (switch to Z).

**Do not:**

- Offer three or more options ("Option A: X, Option B: Y, Option C: Z — which do you prefer?"). This is menu-delegation, not proposal.
- Stack justification paragraphs before the proposal. The proposal comes first; the justification is one clause inside it.
- Ask open questions ("what would you like to do next?"). The Lead's job is to have a recommendation.
- Pad with "I was thinking..." or "Maybe we could..." hedges. The proposal is a commitment, not a musing.
- Narrate the classification decision ("I'm flagging this as A-layer because..."). The user does not need to see the Policy machinery; they need to see the decision.

## B-layer structural rule

B-layer output is emitted only at the three natural pause points (`/start-working` open, `/end-working` close, `/plan` proposal presentation). Inside those pause points, the structure is pinned by the command template, not chosen at runtime.

**`/start-working` opening briefing — fixed B-layer shape:**

1. One sentence naming the current Wave status and the one next decision the user needs to make (this is the cross-session recovery surface — protected B-layer, Policy Principle 4).
2. One sentence (or one short paragraph) flagging any items from the last session that affect that decision: remaining issues, rejected approaches relevant to the current Wave, runtime health failures.
3. One sentence naming the Lead's proposed next action (which becomes an A-layer item if and only if it triggers one of the 5 A-layer conditions).

**`/end-working` closing briefing — fixed B-layer shape (3-5 sentences total):**

1. What shipped today, referencing Wave completion if applicable.
2. What Codex (Developer) caught, if anything. Only mention if non-zero findings; if zero, do not emit a "no findings" line (that is C-layer).
3. What's next — one-line pointer to the next active task or the fact that the Wave is complete and awaiting user direction.

**`/plan` proposal presentation — fixed B-layer shape:**

1. The recommended plan, stated as a proposal (use the A-layer wording rule even though the overall plan step is B-layer — the embedded proposal is A-layer).
2. One alternative, named concretely.
3. Key risks, bulleted if more than one.
4. Acceptance script summary, not the full script (the full script goes into plan.md, which is C-layer storage the user can grep).

**Do not:**

- Dump parallel "branch status / hook status / gh status / plan.md status" bullets. These are C-layer facts; include them in B-layer only when one of them changes the user's next decision.
- Re-state what the user just said. The briefing is forward-facing, not an echo chamber.
- Add a "summary of what I'm about to do" section before the proposal. The proposal is the summary.
- Include metrics the framework cannot act on (token counts, model IDs, session duration). These are C-layer; they live in session-log.md for future grep.

## Before-after samples

Each sample shows the old facts-dumping pattern alongside the Policy-compliant version. The "after" column is what the rewritten command templates in v0.7.4 should produce.

### Sample 1 — `/start-working` opening briefing

**Before (facts-dump pattern):**

> Branch `feat/v074-info-layering` is active. The PreToolUse hooks are verified green (Edit, Write, and mcp__codex-dev__codex matchers all point to the upgraded pre-tool-check.sh). The gh account was auto-switched to BinaryHB0916 to match the repository owner. Runtime health check: no build command in CLAUDE.md Common Commands, so skipped. Process Observer is armed. Doc Engineer is idle. Plan.md was read; Wave 7 (v0.7.4 Information Layering Policy) is in progress with T1 completed and T2 next. Last session completed v0.7.3 release. The user's memory contains 8 entries, all currently applicable. Ready to proceed with T2 when you're ready.

> This dumps 10+ facts across 4 unrelated domains. The user has to sort what matters. Most of it is "the machine is running correctly" noise.

**After (Policy-compliant, ~3 sentences):**

> Wave 7 (v0.7.4 Information Layering Policy) is mid-flight — T1 (information-layering-policy.md) is done, T2 (conversation-style.md) is next.
> No blockers from the last session; the v0.7.3 release closed cleanly.
> I plan to start T2 now by writing the conversation-style guide with the A-layer wording rule and 3 before-after samples. Continue?

> The cross-session recovery surface (Wave status, next task) is preserved. The hooks/gh/health/Process Observer facts are silenced — they live in session-log.md and will surface only if they break.

### Sample 2 — `/plan` proposal presentation

**Before (menu-delegation pattern):**

> Here are three possible approaches for v0.7.4:
>
> Option A: Pure runtime judgment — teach Lead to classify every output at runtime via a Policy document. Pros: flexible. Cons: relies on Lead not dumping facts under time pressure.
>
> Option B: Structural command-template rewrite — pin the briefing shapes in `commands/*.md` so Lead's runtime judgment only operates at word-choice level. Pros: enforced by template, not by discipline. Cons: requires rewriting 3 command files.
>
> Option C: Hybrid — do a Policy doc AND rewrite one command file as a proof of concept, leave the other two for later. Pros: lower risk. Cons: partial delivery.
>
> Which would you like to go with?

> This is menu-delegation. The Lead has done the analysis but is refusing to commit to a recommendation.

**After (Policy-compliant, proposal + alternative):**

> I plan to **rewrite all 3 command templates (start-working, end-working, plan) to fixed B-layer shapes**, backed by a new Policy doc in `docs/design-principles/`. This works because it enforces the Policy structurally — Lead's runtime judgment narrows to word choice, which is where Lead is reliable; structural decisions ("say or not / which facts to include") move to the template where they cannot drift.
>
> If you disagree, the viable alternative is a **Policy-only delivery** (write the doc, skip the template rewrites, rely on Lead discipline). It ships faster but the facts-dumping pattern will crawl back through the gap within a few sessions — we already have evidence of that from the `/start-working` briefing earlier today.
>
> Key risks: (1) template rewrites break the cross-session recovery surface if "Wave" gets over-silenced — mitigated by explicit B-layer carve-out; (2) A-layer trigger ambiguity — mitigated by 5 mechanical types in Principle 1. Full acceptance script (5 CLI commands, trivial-CLI carve-out) in the plan.md entry.
>
> Continue with the structural rewrite path?

### Sample 3 — `/end-working` closing briefing

**Before (narrative dump pattern):**

> Today we started the v0.7.4 work. First, I ran /start-working and completed all the setup tasks (branch guard, hook verification, gh switch, health check, Process Observer auto-repair). Then we reviewed your v2 simplification proposal together — I raised 5 concerns and you decided on all 5. After that, we entered /plan, and I produced a plan with T1-T6 tasks and a 5-command acceptance script. You approved the plan with 4 responses. I spawned the Independent Reviewer, got back a PROCEED verdict with 3 actionable items (MAJOR #4 Wave terminology, MINOR #3 cross-session surface, MINOR #5 single-voice). You resolved all 3. I updated plan.md with the resolutions, then created docs/design-principles/ and wrote both the Policy doc (T1) and the conversation-style guide (T2). That's where we are now. Commits so far: the plan.md edits are uncommitted. Next steps would be T3 (command template rewrites), T4 (IR role extension), T5 (CLAUDE.md + CLAUDE-TEMPLATE.md + CHANGELOG + concepts.md + design-decisions.md sync).

> This is a play-by-play narrative. The user sat through all of it; they do not need it replayed.

**After (Policy-compliant, 3-5 sentences):**

> Wave 7 is about half done — T1 (Information Layering Policy) and T2 (conversation-style guide) are written; T3-T5 and the close-out remain.
> Codex was not invoked this session (self-referential Lead-direct edits only, per the precedent from Framework Polish Round 2), so no Codex findings to report.
> I plan to push this branch now as a checkpoint and resume with T3 (command template rewrites) in the next session. Continue?

> This restricts B-layer to: what shipped, what Codex caught (or a single line that it was not invoked under a named precedent), what's next. No replay of the day's events.

## Anti-patterns to watch

These are the recurring facts-dumping patterns the Policy is designed to prevent. When rewriting command templates or reviewing Lead output, scan for these and excise them:

- **"Everything is green" reports.** If the only thing to say is that the machine is running correctly, do not say it. Green status is C-layer. If something is not green, that is A-layer or B-layer depending on whether it blocks a decision.
- **Retrospective narration.** "First I did X, then I did Y, then I did Z." The user saw it happen. Narration is C-layer by default; include only the outcomes that change the next decision.
- **Parallel-domain bullet stacks.** "Branch: X. Hooks: Y. gh: Z. Plan: W. Memory: V." These are C-layer facts arranged to look like B-layer content. Collapse to one sentence or silence entirely.
- **"Here are the options" menus.** See Principle 1 of the Policy. A-layer is proposal, not menu.
- **Metrics the user cannot act on.** Token counts, model IDs, session duration, file counts, line counts. C-layer, always.
- **Hedged proposals.** "I was thinking maybe we could..." — commit to the proposal or do not emit it. Hedges signal that the Lead has not done the analysis the proposal step requires.

## Relationship to user memory

The user's memory (see CLAUDE.md "User Preference Interface") can shape **word choice** within A-layer and B-layer output (target language, brevity default, no-summary preference, format-prose preference). It cannot shape **layer assignment** — memory cannot downgrade a Policy-defined A-layer item to B or C. If a memory entry asks for "skip the briefing," the framework still runs the B-layer briefing step structurally but compresses it to one sentence; it does not merge B into C.

See `feedback_response_brevity.md` and `feedback_format_prose.md` in the user's memory directory for the current brevity and prose-format defaults applied to this user's sessions. These shape word choice; they do not override the Policy.
