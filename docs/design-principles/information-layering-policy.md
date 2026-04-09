# Information Layering Policy

**Status:** Active since v0.7.4 (2026-04-09)
**Scope:** Every user-facing output emitted by the Lead or any agent-team role during an iSparto session.
**Authority:** This Policy is a design principle, not a workflow rule. Workflow rules live in `CLAUDE.md`. When this Policy and a workflow rule appear to conflict, the workflow rule governs *what work happens* and this Policy governs *how that work is reported to the user*.

## Why this Policy exists

The iSparto user is a **decision-maker**, not an observer of the framework's internal operations. When the Lead dumps every fact it has gathered — branch state, hook verification, account alignment, idle agent status, plan.md counts, module boundary notes — into a single briefing, the user has to re-do the Lead's job: sort signal from noise, figure out which item needs a response, and which item is just "the machine running correctly."

That workload should never reach the user. The Lead's job is not to report what it knows. The Lead's job is to surface **decisions** the user needs to make, and **the minimum context required to make them well**. Everything else belongs in a file the user can grep when they care, not in the conversation the user reads every time.

This Policy formalizes that separation into three layers — A, B, C — and makes layer assignment a classification step the Lead must perform *before* emitting any user-facing output.

## The three layers

### A-layer — decision interruption

A-layer output **blocks the user** and demands a response. It is the only layer that is allowed to interrupt. Every A-layer item must identify the decision, name one recommended path, name the most viable alternative, and stop.

A-layer output uses the standard wording rule defined in `docs/design-principles/conversation-style.md` ("I plan to X, because Y. If you disagree, I can switch to Z. Continue?"). A-layer is not a menu — the Lead always proposes, never delegates selection.

### B-layer — decision preparation at natural pause points

B-layer output is told to the user at **natural session pause points** (the opening briefing of `/start-working`, the closing briefing of `/end-working`, the proposal step of `/plan`). It does not block. It contains only the context the user needs to resume work, form a next-step intuition, or verify that the framework is on track.

B-layer is where the **cross-session recovery surface** lives: current Wave status, remaining issues from the last session, next active task. These are **state variables**, not implementation noise — the user needs them to pick up where they left off, which is exactly the framework's value proposition at `/start-working`. The C-layer silence rules below must never touch these items.

### C-layer — silent archive

C-layer output is **never emitted to the user**. It is logged to files (`docs/session-log.md`, commit history, hook logs) that the user can grep when they care. C-layer is where the framework's internal housekeeping lives — the operational facts that prove the machine is running correctly but contribute nothing to any decision the user needs to make.

Concrete C-layer examples: branch auto-create or auto-rename from placeholder names, PreToolUse hook verification green, `gh auth switch` account alignment, runtime health check green status, Process Observer arming, Doc Engineer idle state, hook-matcher migration on stale installs.

## Seven principles

### Principle 1 — Every output must be classified before emission

Before emitting any user-facing output, the Lead must classify it into exactly one of A, B, C. Classification is mechanical, not stylistic. The Lead cannot "feel out" the layer; it must check against the 5 A-layer trigger types below.

**A-layer is triggered when and only when** one of the following 5 mechanically-identifiable conditions holds:

1. **(a) Lead proposes a new plan requiring user confirmation.** Any new `/plan` output, any mid-session pivot that materially changes the task decomposition.
2. **(b) Developer (Codex) surfaces P0 or P1 findings.** Security vulnerabilities, data loss paths, correctness bugs with user impact. P2/P3 findings are B-layer (included in the closing briefing) or C-layer (logged only).
3. **(c) Irreversible operation imminent.** Destructive git (`reset --hard`, `push --force` to non-private branches, `branch -D`), database migrations, file deletions outside of a snapshot-covered boundary.
4. **(d) Independent Reviewer requests script authorization (deep-IR gate).** IR's regular review is read-only; the deep-IR mode (running scripts, tests, or external queries) requires explicit user authorization because it crosses the read-only boundary.
5. **(e) Process Observer critical intercept.** A hook or post-session audit flags a violation the framework cannot auto-resolve.

If an output matches none of these 5 types, it is by construction **not A-layer**. This closes the Lead-misclassification blind spot: Lead cannot accidentally downgrade a critical output to B or C because the only way to become A is to match an enumerated trigger.

### Principle 2 — B-layer is emitted only at natural pause points

B-layer output is permitted only at three points in a session: the `/start-working` opening briefing, the `/end-working` closing briefing, and the `/plan` proposal-presentation step. Mid-session status updates, "I just did X" narration, and "here's what's still pending" lists are forbidden in B-layer because they create the same dump-of-facts pattern the Policy is designed to eliminate.

If the Lead needs to communicate mid-session, it must either escalate the item to A-layer (if it genuinely blocks a user decision) or log it to C-layer (if it does not).

### Principle 3 — IR only reviews A-layer judgments

The Independent Reviewer's role in runtime output review is narrow by design: **IR is invoked only when Lead has classified an output as A-layer**. B-layer and C-layer classifications are Lead-autonomous and carry no IR gate.

This principle resolves the 5-10x latency and cost objection that would otherwise make A/B/C classification unaffordable in practice. IR runs dozens of times per session would be prohibitive; IR runs only on the handful of genuine A-layer interruptions per session is cheap and preserves the "single-voice" user experience.

When IR disagrees with Lead's A-layer framing, IR prevails (see Principle 6 below).

### Principle 4 — The cross-session recovery surface is protected B-layer

Current Wave status, remaining issues from the last session, and next active task are **state variables** required for the user to resume work across sessions. They are not implementation noise. C-layer silence rules must not touch these items. Command templates (`/start-working`, `/end-working`) that restructure their B-layer briefing must explicitly carve out this surface.

This principle exists because the naive form of "silence everything except decisions" erases the very state the framework exists to preserve. The distinction is: **state variables survive; implementation facts do not**.

### Principle 5 — Word choice is Lead's dynamic judgment; structure is not

Command templates (`commands/start-working.md`, `commands/end-working.md`, `commands/plan.md`) pin the B-layer briefing **structure** to a fixed shape. Lead's runtime judgment operates only at word-choice level inside that shape.

This principle exists because dynamic judgment at the "say or not / which facts to include" level is exactly where the Lead's facts-dumping failure mode lives. Pinning structure to the template removes the failure surface; keeping word choice dynamic preserves adaptability to each session's actual content.

This collapse is total: outside the three covered pause points (`/start-working` opening, `/end-working` closing, `/plan` proposal-presentation) there is no surface where Lead dynamically re-classifies an output's layer. Principle 1 has already allocated A-layer to 5 mechanical triggers; Principle 2 has already allocated B-layer to the three pause points; the residual default is C-layer. Lead's runtime judgment survives only for word choice inside pre-pinned structure — there is no "fourth path" where Lead decides a layer at runtime.

### Principle 6 — IR prevails on A-layer conflict, delivered single-voice

When Lead and IR disagree on an A-layer output (framing, recommendation, or whether the output is A-layer at all), IR's judgment prevails. Lead then re-emits the corrected A-layer output to the user as its own voice. IR does not speak directly to the user.

This single-voice delivery rule prevents the user from having to mediate a Lead-vs-IR dispute at runtime. The user sees one voice (Lead); the correction mechanism (IR prevailing) is a backstage rule, not a user-facing interaction.

### Principle 7 — When in doubt, escalate to A or sink to C, never invent a new layer

There are only three layers. If an output feels like it "could be B-layer but isn't urgent" and the Lead is tempted to flag it as "informational," the correct move is to either elevate it to A (if a decision truly depends on it) or sink it to C (if the user can grep it later). The framework does not provide a fourth layer for "nice-to-know."

This principle exists to prevent layer drift. Every exception, every "this one time," adds a gap the facts-dumping pattern will crawl back through.

## Conflict resolution

**Workflow rule vs Policy:** workflow rules (CLAUDE.md) govern what work happens; this Policy governs how work is reported. If a workflow rule says "Lead runs Doc Engineer after Developer review" and the Policy says "do not narrate mid-session," both hold — Lead runs Doc Engineer without narrating it (the Doc Engineer pass is C-layer; any P0/P1 finding it surfaces is A-layer).

**Lead vs IR on A-layer:** IR prevails (Principle 6). Lead re-emits.

**User preference vs Policy:** the user's memory can shape A-layer word choice (language, style, brevity) per the three-level response model in CLAUDE.md, but cannot alter layer assignment. If the user asks "skip the briefing," the framework still runs the B-layer briefing step structurally but compresses it to the minimum viable shape; it does not merge B-layer into C-layer.

## Enforcement

This Policy is enforced structurally, not by runtime self-discipline. The enforcement points are:

- **Command templates** (`commands/start-working.md`, `commands/end-working.md`, `commands/plan.md`) pin the B-layer briefing shape and enumerate which facts belong in C-layer.
- **Conversation style guide** (`docs/design-principles/conversation-style.md`) defines the A-layer wording rule and provides before-after samples.
- **Agent role definitions** (`agents/independent-reviewer.md`) specify IR's A-layer peer-review trigger and the single-voice delivery rule.
- **Doc Engineer audit** (part of `/end-working`) verifies that any new command template or agent role definition carries a `Reference: docs/design-principles/information-layering-policy.md` line.

A command template that does not reference this Policy is, by definition, not in scope for Policy enforcement. This is deliberate: the Policy governs user-facing output, and user-facing output happens through command templates. If a new command template is added, it must explicitly opt in.

## Out of scope

This Policy does not govern:

- **Internal agent-to-agent messages.** Lead-to-Developer prompts, Teammate-to-Developer prompts, IR-to-Lead correction deliveries — all are internal traffic, not user-facing output.
- **File content.** The Policy governs conversation output, not the content Lead writes to `docs/*.md`, `commands/*.md`, or any committed file. Written content has its own quality bar (Tier 1/2/4 language rules, Doc Engineer audit).
- **Error messages from hooks or shell commands.** When a PreToolUse hook blocks an operation, the hook's own error message is the source of truth; Lead does not paraphrase it into A-layer wording.
- **Quantitative metrics.** The Policy is felt-experience oriented. There is no dashboard, no "A-layer count per session" KPI. Dogfood observation is qualitative (see `docs/plan.md` v0.7.4 T6).

## Revision rule

Changes to this Policy require: (1) a plan.md entry, (2) Independent Reviewer alignment review at Wave start, (3) Doc Engineer audit at Wave completion, (4) a design-decisions.md row recording the change. Minor typo or clarification fixes do not require a plan.md entry but still require the Doc Engineer audit.
