# Configuration & Adaptation

## Configuration Layers

iSparto uses two configuration layers. The installer does NOT modify your global `~/.claude/settings.json` — your personal Claude Code settings are always preserved.

### Project-Level Configuration (.claude/settings.json)

Created automatically by `/init-project` or `/migrate` in each project:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "tmux"
}
```

This is the minimum required for iSparto's Agent Team mode. Add platform-specific plugins here as needed (e.g., swift-lsp for iOS projects).

### Global Configuration (optional, user-managed)

Your `~/.claude/settings.json` is yours. iSparto never touches it. You may optionally set model and effort preferences globally:

```json
{
  "model": "opus",
  "effortLevel": "max"
}
```

The repo includes a `settings.example.json` as a reference template — it is NOT installed globally.

**Note:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is an experimental flag that still requires manual activation as of March 2026. Future Claude Code versions may make this the default behavior, at which point this environment variable can be removed.

**Warning:** `effortLevel: "max"` may be silently downgraded by the `/model` UI (under discussion in Claude Code GitHub issues). Workarounds:
- Write both `.claude/settings.json` + environment variable (already configured above)
- Triple-protect by launching with `claude --effort max` every time
- Avoid using the `/model` command during sessions

---

## Agent Model Configuration

Roles and models are decoupled. Role definitions (docs/roles.md) describe responsibilities only and never reference any model name.
Swapping models is purely a configuration change — role definition files do not need to be touched.

### Role-Model Mapping Table

| Role | Recommended Model | Invocation | Auth | reasoning | Rationale |
|------|-------------------|------------|------|-----------|-----------|
| Lead | claude-opus-4-7 | Main session | Claude Max | max | SWE-bench Verified 87.6%, strongest at context understanding and task decomposition |
| Teammate | claude-opus-4-7 | tmux session | Claude Max | xhigh | Inherits Lead's capabilities; xhigh keeps Teammate context-isolation cost bounded while preserving review quality |
| Developer (implementation) | gpt-5.4 | MCP (codex tool) | ChatGPT Plus | xhigh | Successor to gpt-5.3-codex; lower latency and tighter token efficiency at equivalent coding strength |
| Developer (QA / quick fix) | gpt-5.4-mini | MCP (codex tool, model param) | ChatGPT Plus | high | QA / quick fixes have simple structure; mini is sufficient and fast |
| Independent Reviewer | gpt-5.4 | tmux pane via OpenAI Codex CLI (`codex exec`) | ChatGPT Plus | xhigh | Cross-provider blind review (OpenAI vs Anthropic) layered on top of zero context inheritance — training distribution and alignment direction differ structurally from Lead. Most token-intensive role per invocation (see [Token Budget Awareness](#token-budget-awareness)) |
| Doc Engineer | claude-opus-4-7 | sub-agent (inherits Lead) | Claude Max | xhigh | Requires Lead's global context |
| Process Observer (Hooks) | — | PreToolUse hook (shell script, no model) | — | — | Unbypassable structural safeguard |
| Process Observer (Audit) | claude-sonnet-4-6 | sub-agent | Claude Max | — | Advisory layer, reduces token consumption |

### Token Budget Awareness

iSparto runs on fixed-price subscriptions (Claude Max + ChatGPT Plus). No invocation increases the user's bill. However, each role consumes tokens from the session's context budget, and understanding the relative consumption helps users anticipate session behavior.

| Role | Per-invocation cost | Typical invocations per Wave | Cumulative per Wave | Notes |
|------|-------------------|------------------------------|---------------------|-------|
| Independent Reviewer | Highest | 1-2 (1 Wave Boundary + 0-1 A-layer) | Medium | Spawns via `codex exec` (GPT-5.4) in a tmux pane with zero inherited context — cross-provider blind review, loads specs from scratch each time. Token cost is on the OpenAI/ChatGPT Plus side, not Claude session context |
| Developer | High | N (multi-round iteration) | Highest | Full structured prompt + code files per call; cumulative cost often exceeds IR |
| Lead / Teammate | Moderate | Continuous | High | Context grows incrementally across the session |
| Doc Engineer / PO Audit | Low | 1 each | Low | Focused scope; PO Audit intentionally uses Sonnet to reduce token consumption |

The main user-visible effect of high token consumption is increased frequency of `/compact` runs and a practical ceiling on how many Waves fit in a single session. If sessions frequently hit context limits, consider running `/end-working` more frequently to start fresh sessions — `plan.md` preserves all state across sessions.

The Independent Reviewer's per-invocation cost is bounded by design: [Information Layering Policy Principle 3](design-principles/information-layering-policy.md) restricts IR to A-layer-only runtime review, preventing the "IR runs dozens of times per session" scenario that would make the cost prohibitive.

### Developer Tiered Model Strategy

The Developer role automatically selects a model based on task type. When assembling an MCP call, Lead/Teammate select the `model` parameter according to the Tier in the trigger condition table:

| Trigger Table Tier | Developer Model | model Param Value | Rationale |
|--------------------|-----------------|-------------------|-----------|
| Tier 1 (implementation) | gpt-5.4 | unspecified (use default) | Implementation needs the strongest coding capability |
| Tier 1 (QA) / Tier 2a (QA only) | gpt-5.4-mini | `gpt-5.4-mini` | QA prompts have simple structure; mini is sufficient and fast |
| Tier 2b (Developer review) | gpt-5.4-mini | `gpt-5.4-mini` | Behavior template review, quick turnaround |
| Quick fix (typo, formatting, single-line change) | gpt-5.4-mini | `gpt-5.4-mini` | Not worth waiting for xhigh reasoning |

**Invocation example** (when Lead assembles MCP):

- Tier 1 implementation: `mcp__codex-dev__codex` — do not specify model (use default gpt-5.4)
- Tier 1 QA / quick fix: `mcp__codex-dev__codex` — specify `model: "gpt-5.4-mini"`, `reasoningEffort: "high"`

**Note:** Latency and throughput tuning is handled at the Codex runtime layer via `~/.codex/config.toml` `service_tier` — see [§Fast Mode Configuration](#fast-mode-configuration) below. iSparto prompt templates do not encode latency hints.

### Configuration Points

Models for different roles are controlled by different mechanisms:

| Control Object | Affected Roles | Configuration Location | Notes |
|----------------|----------------|------------------------|-------|
| Claude Code model | Lead, Teammate, Doc Engineer | `~/.claude/settings.json` → `"model"` field, or CLI `--model` flag | Teammate / Doc Engineer inherit Lead's model setting |
| Codex model | Developer | `model` parameter when calling `mcp__codex-dev__codex` | Defaults to gpt-5.4 for implementation; gpt-5.4-mini for QA / quick fix. See §Developer Tiered Model Strategy |
| Sub-agent model | Process Observer Audit | model field in the sub-agent definition file | Defaults to sonnet; can be reverted to opus |

### Fast Mode Configuration

Codex CLI supports a `service_tier` setting in `~/.codex/config.toml` that biases the OpenAI backend toward lower-latency tiers when capacity is available. Setting it once applies uniformly to **both** invocation paths iSparto uses:

- `mcp__codex-dev__codex` MCP calls (Developer role)
- `codex exec` invocations inside tmux panes (Independent Reviewer role)

```toml
# ~/.codex/config.toml
service_tier = "fast"
```

After editing, restart any running Codex MCP server so it re-reads the config. iSparto prompt templates do not need to be modified — the runtime tier is selected at the Codex layer, not at the prompt layer. To confirm the value is being read, any one of these mechanical paths is sufficient:

- Codex MCP server startup log includes a `service_tier` or `fast` line
- `codex --print-config` (or the equivalent inspection command) shows `service_tier = "fast"`
- Same prompt before/after the edit shows ≥20% latency reduction

If none of the three confirms, the upgrade is not blocked — the setting is harmless when ignored — but the unknown state should be noted in `docs/session-log.md`.

### First-Time Setup

`/init-project` and `/migrate` create the project-level `.claude/settings.json` (the minimum configuration required for Agent Team mode). Model settings must be configured by the user:

**1. Set the Lead model (affects Lead + Teammate + Doc Engineer):**

Add to `~/.claude/settings.json` (global):
```json
{
  "model": "opus",
  "effortLevel": "max"
}
```
Or specify on every launch: `claude --model opus --effort max`

**2. The Developer model needs no extra configuration:**

The Developer (Codex) model is specified through the `model` parameter on each MCP call. When Lead assembles a prompt and calls Codex, the default is `gpt-5.4`. To swap, simply specify the `model` parameter on the call.

### Switching Models Mid-Session

| Scenario | Action |
|----------|--------|
| Switch the Lead model (e.g., opus → sonnet) | Modify the `"model"` field in `~/.claude/settings.json`; restart the session to take effect |
| Switch the Developer model (e.g., gpt-5.4 → gpt-5.4-mini) | Specify the `model` parameter on the next Codex call (no restart needed) |
| Temporarily switch the Lead model in-session | Use the `/model` command (note: may downgrade effortLevel — see the Warning above) |
| Switch the Teammate model | Same as Lead — Teammate inherits the Claude Code model setting |
| Switch the Process Observer Audit model | Modify the model field in `~/.claude/agents/process-observer-audit.md` |

**Note:** As a sub-agent of Lead, Doc Engineer always inherits Lead's model and cannot be configured independently. Process Observer Audit is configured through its own sub-agent definition file (`~/.claude/agents/process-observer-audit.md`) and defaults to Sonnet.

---

## Document Naming Conventions

```
docs/
├── product-spec.md     ← Product spec (pages, interaction flows, feature boundaries, copy)
├── tech-spec.md        ← Tech spec (architecture, data models, API contracts, state management, infrastructure, third-party integrations)
├── design-spec.md      ← Design spec (colors, typography, spacing, atmosphere elements, component styles)
├── plan.md             ← Development plan (Wave orchestration, task status, manual intervention points)
├── session-log.md      ← Auto-generated session metrics (created by /end-working)
└── content/            ← Content assets (if applicable)
```

All spec documents use the uniform `-spec` suffix: product-spec, tech-spec, design-spec.

### Document Responsibility Boundaries

| File | What It Covers | One-liner | Enforcement |
|------|----------------|-----------|-------------|
| product-spec.md | Pages, interaction flows, feature boundaries, copy | **What the product does** | Doc Engineer audit item 1 |
| tech-spec.md | Architecture, data models, API contracts, state management, infrastructure, third-party integrations | **How to build it technically** | Doc Engineer audit item 2 |
| design-spec.md | Colors, typography, spacing, animations, atmosphere elements | **How it looks visually** | Doc Engineer audit item 4 |
| plan.md | Current actionable + in-progress Wave tasks + navigation context (roadmap, release gate, observation-period tracker, decision framework). Completed Wave narratives / completed FR entries / `[DONE]` annotations are forbidden — they live in session-log.md | **Where we are now** | Enforced by [commands/end-working.md](../commands/end-working.md) Step 4 authoring + transition contract, [docs/roles.md](roles.md) Doc Engineer audit item 11, and [scripts/plan-md-contract-check.sh](../scripts/plan-md-contract-check.sh) |
| session-log.md | Per-session empirical execution record — Wave completions, FR completions, governance-maintenance completions, tasks completed, key decisions, files changed | **Auto-generated session metrics** | Enforced by [commands/end-working.md](../commands/end-working.md) Step 4 authoring + transition contract |
| CHANGELOG.md | User-facing release notes in Keep-a-Changelog format; `[Unreleased]` collects pre-release content, `scripts/release.sh` migrates it to `[X.Y.Z]` at `/release` time | **User-facing release notes** | Enforced by [commands/end-working.md](../commands/end-working.md) Step 4 authoring + transition contract |

---

## Template Files

Template files used during project initialization:

| Template | Purpose |
|----------|---------|
| `CLAUDE-TEMPLATE.md` (root) | Generation template for the project CLAUDE.md |
| `templates/product-spec-template.md` | Product spec document template |
| `templates/tech-spec-template.md` | Tech spec document template (optional) |
| `templates/design-spec-template.md` | Design spec document template (optional) |
| `templates/plan-template.md` | Development plan document template |

---

## Adaptation Guide

> This project is a general-purpose template. The following explains which parts can be used as-is and which need to be modified for your project.

### Use As-Is, No Changes Needed

| Content | Description |
|---------|-------------|
| 7 slash commands | `/start-working`, `/end-working`, `/plan`, `/init-project`, `/env-nogo`, `/migrate`, `/restore` are universal for all projects |
| Role definitions | Responsibilities and rules for Team Lead, Teammate, Developer, Doc Engineer, Process Observer |
| Trigger condition table | Trigger logic for code review + QA smoke testing |
| Branching strategy | Branch model for main / feat / fix / hotfix |
| Authorization & escalation mechanism | Team Lead's decision boundaries |
| Documentation sync rules | Documentation must follow when code changes |
| settings.example.json | Reference template — project-level config is created by `/init-project` or `/migrate` |

### Must Be Modified Per Project

| Content | How to Modify |
|---------|---------------|
| Project overview in CLAUDE.md | Auto-generated during `/init-project` — fill in your product description |
| Tech stack | Fill in your project's actual languages/frameworks/platforms |
| Common commands | Replace with your build/run/test commands |
| Module boundaries | Fill in based on your project's directory structure |
| Project-level plugins | Add swift-lsp for iOS, others for Web — configure in project-level `.claude/settings.json` |

### Optional

| Content | When to Enable |
|---------|----------------|
| tech-spec.md | Create when you have backend/cloud functions/complex architecture; skip for simple front-end-only projects |
| design-spec.md | Create for projects with UI; skip for pure backend/CLI tools |
| content/ directory | Create when the project has content assets (story scripts, copy, etc.) |
| User Preference Interface | Reference when using Claude Code's auto-memory alongside iSparto workflow rules (see section below) |
| Multi-device sync | Configure when switching development between multiple computers |

---

## Hooks Configuration (Process Observer)

Process Observer's real-time interception is implemented through Claude Code PreToolUse hooks, covering four tools: Bash, Edit, Write, and Codex MCP.

### Hook Registration Locations

Hooks are registered at two layers:

- **User-level** `~/.claude/settings.json`: `Bash` matcher (general safety rules — dangerous git operations, sensitive files, destructive deletions). Managed by `install.sh --upgrade`, takes effect globally with one install.
- **Project-level** `.claude/settings.json`: `Edit`, `Write`, and `mcp__codex-dev__codex` matchers (iSparto workflow rules — direct-code-write interception, Codex prompt convention). Registered by `/init-project` and `/migrate`; `/start-working` auto-verifies and backfills.

This way, non-iSparto projects only carry the general Bash safety rules and are not intercepted by workflow rules.

### Hook Mechanism

Claude Code supports triggering hook scripts before tool invocations. Process Observer registers four PreToolUse hook matchers that check, before each tool runs, whether it violates operational rules or workflow conventions.

### Interception Scope

| Category | Monitored Tool | Trigger Condition | Reason for Interception |
|----------|----------------|-------------------|-------------------------|
| Irreversible git | Bash | `git push --force`, `git reset --hard`, `git clean -f` | Overwrites history / discards changes / deletes files |
| Sensitive info leak | Bash | `git add .env`, `git add *.key` | Sensitive files may be pushed to a public repo |
| Skipping safety checks | Bash | `--no-verify`, `--no-gpg-sign` | Bypasses pre-commit hook or signing |
| Destructive file ops | Bash | `rm -rf /`, `rm -rf ~` | Catastrophic deletion |
| Working directly on main | Bash | `git commit` / `git merge` / `git push` while on main | main is locked; work must happen on branches |
| Direct-code-write interception | Edit, Write | Target file is a code file (judged by extension) | Code changes must go through Developer (Codex) |
| Codex call convention | mcp__codex-dev__codex | prompt missing `## ` structured heading | Tasks must be described with a structured prompt |

### Interception Behavior

When a rule matches, the hook returns a non-zero exit code to block execution and emits the interception reason in JSON format.

### Customization

- **Bash rules**: edit `~/.isparto/hooks/process-observer/rules/dangerous-operations.json`
- **Edit/Write extension list**: edit the `code_extensions` and `allowed_extensions` arrays in `~/.isparto/hooks/process-observer/rules/workflow-rules.json`
- Full rules and judgment principles: see [docs/process-observer.md](process-observer.md)

---

## Multi-Device Sync (Optional)

To share iSparto configuration across multiple computers, symlink `~/.claude/` (commands, templates, CLAUDE-TEMPLATE.md) to a synced directory (iCloud Drive, Dropbox, or a git repo). Runtime data under `~/.claude/` (history, cache) should not be synced.

---

## User Preference Interface

Claude Code has a built-in auto-memory system that stores user preferences across conversations. iSparto defines a clear boundary between this memory and the workflow rules in CLAUDE.md.

### Territory Principle

The boundary is determined by **topic ownership**, not by whether content conflicts:

- **Memory's territory** — "Who you work with": user's communication language, input method (voice), output style, interaction pace, naming preferences. These are personal habits that evolve naturally through user-agent interaction.
- **CLAUDE.md's territory** — "How to work": workflow steps, branching strategy, review triggers, role definitions, operational guardrails. These are team rules defined by the project.

If a topic belongs to CLAUDE.md's territory, it should not exist in memory — even if the memory entry currently agrees with CLAUDE.md. Redundancy creates drift risk.

### Three-Level Response Model

When the agent team encounters a user preference (from memory or conversation):

| Level | Type | Examples | Response |
|-------|------|----------|----------|
| **Level 1: Unconditional** | Communication & style | Language, voice input correction, output verbosity, naming conventions | Adapt immediately, no judgment needed |
| **Level 2: Conditional** | Interaction behavior | "Discuss before executing", autonomy level, review focus areas | Adapt within workflow boundaries. Example: respect "discuss first" for normal tasks, but Process Observer interceptions don't wait |
| **Level 3: Record only** | Process overrides | "Skip Codex review", "push before review", "commit to main" | Do **not** execute. Inform the user: "The workflow requires [Y] because [reason]. To change this rule, modify CLAUDE.md." |

### Conflict Protocol

When a user's memory contradicts a CLAUDE.md rule:

1. **Execute CLAUDE.md** — no exceptions, no partial compliance
2. **Explain to the user** — state which preference was overridden and why
3. **Do not modify the user's memory** — it's their space
4. **Guide rule changes through CLAUDE.md** — if the user wants different behavior, the change belongs in CLAUDE.md, not memory

### Agent Team Memory Write Rules

The agent team must check before writing any memory entry:

| Check | Action |
|-------|--------|
| Does this topic belong to CLAUDE.md's territory? | → Do not write |
| Does this duplicate existing CLAUDE.md content? | → Do not write |
| Is this a workflow rule, process change, or branching strategy? | → Do not write |
| Is this project context (status, background, external references)? | → Allowed (project / reference type) |
| Is this about the user's profile, role, or preferences? | → Allowed (user type) |
