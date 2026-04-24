# Process Observer

## Overview

Process Observer is the compliance oversight role of the iSparto team. It consists of two parts with different priorities:

- **Real-time Interception (Hooks) — Core layer**: Monitors all tool calls (Bash / Edit / Write / Codex MCP) via Claude Code PreToolUse hook and intercepts non-compliant operations. This is an unbypassable hard guarantee.
- **Content Security Scan (Hooks extension) — Core layer**: When the Edit/Write tools write content, scans for critical-level secret patterns in real time (API keys, private keys, etc.). This is an extension of the PreToolUse hook and shares the same script as operation interception.
- **Post-Hoc Audit (Sub-agent) — Advisory layer**: At /end-working time, reviews the session execution process and outputs a compliance report and improvement suggestions. This layer depends on the Lead actively spawning it and is not guaranteed to run every time. Critical compliance checks are already covered by the Hooks layer; the value of the sub-agent is to discover process improvement opportunities, not to serve as the sole line of defense for compliance.

Process Observer does not participate in development decisions; it only monitors process compliance. It is on the same level as Doc Engineer; both are sub-agents of the Team Lead.

---

## Real-time Interception (Hooks)

### Mechanism

Implemented via Claude Code's PreToolUse hook. The hook is a shell script that is triggered before every tool call and checks whether the command matches the dangerous-operations list. If it matches, execution is blocked and a reason is printed.

Hooks are registered at two levels: user-level `~/.claude/settings.json` holds Bash safety rules (managed by `install.sh`); project-level `.claude/settings.json` holds Edit/Write/Codex workflow rules (registered by `/init-project`, validated by `/start-working`).

### Trigger Conditions

Interception is triggered when a tool call matches any of the following rules:
- **Bash**: command matches the dangerous-operations.json dangerous-operation list
- **Edit/Write**: target file is a code file (determined by extension)
- **Codex MCP**: prompt lacks a structured heading (`## ` format)

### Judgment Principles

Whether an operation is "high-risk" is judged on three dimensions:

| Dimension | Description | Example |
|-----------|-------------|---------|
| Irreversible | Operation cannot be undone, or undoing it is prohibitively costly | `git push --force`, `rm -rf` |
| Affects shared state | Operation changes state that other people (or other sessions) depend on | Pushing directly to main, modifying global configuration |
| Data loss | Operation may cause loss of code, documentation, or user data | `git reset --hard`, `git clean -f` |

Meeting any one dimension qualifies as high-risk.

### Dangerous Operation Categories

#### 1. Irreversible Git Operations

| Operation | Reason for Interception |
|-----------|------------------------|
| `git push --force` / `git push -f` (to main/master) | Overwrites remote protected-branch history; other collaborators' work may be lost |
| `git reset --hard` | Discards all uncommitted local changes |
| `git clean -fd` / `git clean -f` | Deletes untracked files, unrecoverable |
| `git checkout -- .` | Discards all unstaged changes |
| `git branch -D main` / `git branch -d main` (protected branch) | Deletes the main/master branch |

#### 2. Sensitive Information Leakage

> **Migrated:** Sensitive file detection (`git add .env`, `git add *.pem`, etc.) has been removed from dangerous-operations.json and is now handled uniformly by the three-layer security system (security-patterns.json) — L1 real-time content scan, L2 pre-commit staged-file scan, L3 full audit. The new system scans actual file content rather than command strings, providing higher precision with no false positives. See [docs/security.md](security.md) for details.

#### 3. Skipping Safety Checks

| Operation | Reason for Interception |
|-----------|------------------------|
| `--no-verify` flag | Skips pre-commit / pre-push hook |
| `--no-gpg-sign` flag | Skips GPG signing |

#### 4. Destructive File Operations

| Operation | Reason for Interception |
|-----------|------------------------|
| `rm -rf /` or `rm -rf ~` | Catastrophic deletion (matches root directory and home directory) |
| Deleting key files in the project root (CLAUDE.md, .git/) | Destroys project structure |

#### 5. iSparto-Specific Protections

| Operation | Reason for Interception |
|-----------|------------------------|
| Deleting the `~/.isparto/backup` directory | Removes uninstall/rollback capability |
| Deleting the `~/.isparto/snapshots` directory | Removes all configuration restore points |
| Deleting the `~/.isparto` directory | Removes all iSparto data |
| Deleting the `~/.claude` directory | Removes all Claude Code configuration |

#### 6. Developing Directly on main

| Operation | Reason for Interception |
|-----------|------------------------|
| Running `git commit` while on the main branch | main is locked; all development must happen on feat/fix/hotfix branches |
| `git push origin main` (non-PR merge) | Bypasses the PR flow with a direct push |

#### 7. Workflow Compliance (Edit / Write / Codex Interception)

##### Direct Code Write Interception (Edit / Write)

| Operation | Reason for Interception |
|-----------|------------------------|
| Edit/Write target is a code file (.sh, .py, .swift, .js, .ts, etc.) | Code changes must be implemented through Developer (Codex); direct editing is not allowed |
| Edit/Write target has no extension (Makefile, etc.) | Treated as a code file by default (fail-safe) |

**Decision logic:**
- Extract the `file_path` parameter from the Edit/Write tool
- Decide based on file extension: allowed_extensions are passed through; others are intercepted
- Code-file extensions (intercepted): .sh, .py, .swift, .js, .ts, .jsx, .tsx, .go, .rs, .java, .kt, .c, .cpp, .h, .m, .mm, .rb, etc.
- Allowed extensions (passed through): .md, .json, .yaml, .yml, .toml, .txt, .svg, .png, .css, .html, etc.
- Unrecognized extensions default to being treated as code files (fail-safe)

**Who gets intercepted:**

Hooks run in every Claude Code session that has project settings:
- **Lead** (main session) → intercepted
- **Teammate** (tmux session, shares project settings) → intercepted
- **Doc Engineer** (Lead's sub-agent, shares the session) → intercepted
- **Developer (Codex MCP)** (independent process, does not go through hooks) → **not intercepted**

This is the intended design: only Developer (Codex) should write code; all other roles operate indirectly through Developer.

##### Codex Invocation Convention (mcp__codex-dev__codex)

| Operation | Reason for Interception |
|-----------|------------------------|
| Calling Developer with a prompt that lacks a `## ` structured heading | A structured prompt must be used to describe the task |

**Custom extension list:**

The extension list is defined in `hooks/process-observer/rules/workflow-rules.json` and the `code_extensions` and `allowed_extensions` arrays can be adjusted to suit project needs.

#### 8. Content Security Scan (Write / Edit Real-time Interception)

| Operation | Reason for Interception |
|-----------|------------------------|
| Write/Edit content contains an AWS Access Key (AKIA...) | Risk of leaking a hard-coded secret |
| Write/Edit content contains an Anthropic API Key (sk-ant-...) | Risk of leaking a hard-coded secret |
| Write/Edit content contains a Private Key Header (-----BEGIN...PRIVATE KEY-----) | Leak of private-key file contents |
| Write/Edit content contains a Stripe Key (sk_test_/sk_live_...) | Risk of leaking payment credentials |
| Write/Edit content contains a GitHub Token (ghp_/gho_...) | Leak of repository access credentials |

**Decision logic:**
- After the Edit/Write extension check passes, but before passing through, extract the content being written
- Write tool: scan the `content` field
- Edit tool: scan the `new_string` field
- Only the `realtime_critical` subset is checked (5 critical-level patterns); no full scan is performed — the hook is on the hot path and performance comes first
- A complete scan is covered by pre-commit-security.sh (before commit) and /security-audit (milestone)
- Pattern definitions: the `realtime_critical` field of `hooks/process-observer/rules/security-patterns.json`

**Relationship with Layers 2/3:**

| Layer | Timing | Scope | Performance Requirement |
|-------|--------|-------|------------------------|
| PreToolUse content scan | Every Write/Edit | critical patterns only | High (hot path) |
| pre-commit-security.sh | Every commit | All patterns | Medium |
| /security-audit | Manually triggered | Full + history + dependencies | Low |

### Interception Behavior

When a dangerous operation is detected:
1. **Block execution**: Return a non-zero exit code; Claude Code does not execute the command
2. **Print the reason**: Print the interception reason and suggested alternative on stderr

Example output:
```
[Process Observer] BLOCKED: git push --force
Reason: Force push overwrites remote history and may destroy collaborators' work.
Suggestion: Use `git push` (without --force) or `git push --force-with-lease` for safer alternatives.
```

---

## Post-Hoc Audit (Sub-agent)

### Mechanism

Spawned by the Team Lead as a sub-agent during the /end-working flow, on the same level as Doc Engineer. It audits the execution of the current session and checks for behavior that violates workflow rules.

The post-hoc audit uses the Sonnet 4.6 model (defined via `~/.claude/agents/process-observer-audit.md`) rather than the Lead's Opus model. This is a deliberate downgrade — auditing is a structured checklist comparison, Sonnet is more than capable, and critical compliance checks have already been moved to the Hooks layer.

### Trigger Timing

In the /end-working flow, executed at **Step 5 (before the security scan, commit, and the Doc Engineer Step 9 pre-merge gate before PR creation/merge)**. (PO = Step 5 in commands/end-working.md; DE = Step 9 pre-merge gate.)

### Audit Checklist

**Canonical coverage: 19 checks across 6 categories (A-F).** The enumeration below mirrors the authoritative table in `agents/process-observer-audit.md` (A1-A3 / B1-B2 / C1-C2 / D1-D4 / E1-E7 / F1). That file is the source of truth; this section is a reader-facing reference — when the two drift, `agents/process-observer-audit.md` wins.

#### Checklist A: Branch Rules

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| A1 | Whether the current branch is feat/, fix/, hotfix/, docs/, or release/ | Branch name prefix matches one of the approved five | P1 |
| A2 | Whether there are any direct commits to main | git log compared with the main HEAD at session start; PR-merge commits on main are PASS | P1 |
| A3 | Whether the branch guard precedes the first modifying tool call | Branch switched off main before first Edit/Write/Bash modifying call; WARN (not FAIL) if ordering broke but work still merged cleanly | P2 |

#### Checklist B: Codex Review and Doc Engineer Spawn Compliance

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| B1 | Whether code changes triggered Codex code review | Per-change iteration against the trigger-condition table in workflow.md; only Tier 2 (purely visual, non-security config values) and Tier 3 (pure documentation / pure formatting) may skip | P1 |
| B2 | Whether Doc Engineer sub-agent was spawned when required | /end-working Step 9 pre-merge gate either spawned a fresh DE sub-agent or recorded an explicit Lead-self-assessed exception citing the ad-hoc-fix / emergency-hotfix clause | P1 |

#### Checklist C: Doc Engineer Execution Compliance

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| C1 | Whether Doc Engineer executed at least once in the session | A Doc Engineer spawn record exists in the session — either the /end-working Step 9 gate or an earlier Lead-initiated mid-session spawn | P1 |
| C2 | Whether code changes have corresponding documentation updates | Correspondence between code-layer diffs and docs/ , README*, command/agent/template header comments, or CHANGELOG entries in the same session | P2 |

#### Checklist D: PR Flow Compliance

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| D1 | Whether merged into main via PR | gh pr list record; new commits on main come from `gh pr merge --merge` (not `--squash` or `--rebase`, and not direct push) | P1 |
| D2 | Whether the branch was cleaned up after merging | The merged feat/fix/hotfix/docs/release branch does not appear in the remote branch list | P3 |
| D3 | Whether the PR body template was populated per /end-working Step 9 | PR body contains Summary, Mode Selection, Test plan, and Workflow audits sections with the standard audit-annotation vocabulary | P1 |
| D4 | Whether gh account alignment was executed when repo owner differs from authenticated user | When `REPO_OWNER` ≠ `GH_USER`, a `gh auth switch --user $REPO_OWNER` invocation occurred before `gh pr create` | P1 |

#### Checklist E: Out-of-Scope Operations and plan.md Integrity

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| E1 | Whether Developer / Teammate modified files outside its ownership | git log --name-only file list vs the file ownership assigned by Team Lead in the spawn prompt | P1 |
| E2 | Whether uncertain product decisions were escalated to the user | Product-direction signals (new command / role / file-format / UX copy) appeared as an A-layer interrupt with an explicit question, not as a unilateral Lead decision | P2 |
| E3 | Whether plan.md unchecked items match the actual codebase state | For items marked `[ ]` in plan.md, re-execute each acceptance assertion (grep / wc / self-test) and cross-check — items fully implemented but not flipped to `[x]` are FAIL; partial presence is WARN | P1 |
| E4 | Whether BLOCKING-marker decision was applied to CLAUDE.md-touching sessions | Per /end-working Step 2 (FR-22 expansion), any session that modifies CLAUDE.md must either emit the BLOCKING marker requiring a new session for the next Wave OR append a one-sentence skip rationale | P1 |
| E5 | Whether verification counts on Wave-completion entries are mechanically accurate | Per CLAUDE.md "plan.md verification-count accuracy" rule, any Wave-completion entry citing a commit count must match `git log --oneline --no-merges <wave-base>..HEAD \| wc -l` | P1 |
| E6 | Whether the observation-period tracker row is filled for a completed Wave | When /end-working is marking a Wave complete within the v0.8.0 observation window (Waves 0-4), the tracker row's four observation columns must contain non-placeholder, non-dash content (unfilled-placeholder or `-` is FAIL post-commit, IN-PROGRESS mid-flow) | P1 |
| E7 | Whether plan.md contract shape is respected for maintenance / Wave PRs | Per /end-working Step 4 "plan.md, session-log.md and CHANGELOG authoring + transition contract" (parts A authoring + B transition + C enforcement), diffs must not add `[DONE in Wave N]` annotations, full Wave retrospective blocks outside the completed-Wave index, or retained completed-FR lines; if `scripts/plan-md-contract-check.sh` is present, exit 1 is an automatic FAIL | P1 |

#### Checklist F: Independent Reviewer Execution

| # | Check | Criterion | Deviation Level |
|---|-------|-----------|----------------|
| F1 | Whether Independent Review ran at the Wave boundary | If a Wave was marked completed this session, IR was spawned (either Lead-initiated mid-session or /end-working Step 3 auto-spawn) and the report was appended to `docs/independent-review.md`; IN-PROGRESS if scheduled but not yet executed at audit time | P1 |

### Deviation Level Definitions

| Level | Meaning | Handling |
|-------|---------|----------|
| P1 | Severe deviation, violates core workflow rules | Must be flagged red in the report; immediate correction is recommended |
| P2 | General deviation, does not affect delivery quality but needs improvement | Marked as WARNING in the report; improvement recommended next time |
| P3 | Minor deviation, best-practice suggestion | Marked as INFO in the report, for reference |

---

## Deviation Report Template

```markdown
### Compliance Audit

| # | Check | Status | Detail |
|---|-------|--------|--------|
| A1 | Branch is feat/fix/hotfix/docs/release | PASS/FAIL | Current branch: feat/xxx |
| A2 | No direct commits to main | PASS/FAIL | ... |
| A3 | Branch guard precedes first modifying tool call | PASS/WARN | ... |
| B1 | Codex code review triggered for code changes | PASS/FAIL/N/A | ... |
| B2 | Doc Engineer sub-agent spawned when required | PASS/IN-PROGRESS/FAIL/N/A | ... |
| C1 | Doc Engineer executed at least once in the session | PASS/IN-PROGRESS/FAIL | ... |
| C2 | Code changes have doc updates | PASS/FAIL/N/A | ... |
| D1 | Merged to main via PR | PASS/IN-PROGRESS/FAIL/N/A | ... |
| D2 | Branch cleaned up after merge | PASS/IN-PROGRESS/FAIL/N/A | ... |
| D3 | PR body template populated per end-working Step 9 | PASS/IN-PROGRESS/FAIL/N/A | ... |
| D4 | gh account alignment when owner ≠ authenticated user | PASS/FAIL/N/A | ... |
| E1 | No out-of-scope file modifications | PASS/FAIL/N/A | ... |
| E2 | Uncertain decisions escalated to user | PASS/WARN/N/A | ... |
| E3 | plan.md unchecked items match codebase state | PASS/WARN/FAIL | ... |
| E4 | BLOCKING marker decision applied to CLAUDE.md-touching sessions | PASS/WARN/FAIL/N/A | ... |
| E5 | Verification-count accuracy for Wave-completion entries | PASS/FAIL/N/A | ... |
| E6 | Observation-period tracker row filled for completed Wave | PASS/IN-PROGRESS/FAIL/N/A | ... |
| E7 | plan.md contract shape respected for maintenance / Wave PRs | PASS/FAIL/N/A | ... |
| F1 | Independent Review at Wave boundary | PASS/IN-PROGRESS/FAIL/N/A | ... |

**Summary:** X passed, Y in-progress, Z warnings, W failures, V not-applicable (Total: X+Y+Z+W+V = 19)

**Rule Corrections Suggested:**
- [Specific suggestions for fixing failures and improving warnings]
```

---

## Feedback Loop

After the audit finds a deviation, no files are modified directly; improvement is driven through reports and suggestions:

### 1. Root-Cause Analysis
Analyze the cause of the deviation, distinguishing among:
- **Process slip**: knew the rule but forgot to apply it (e.g. forgot to trigger Codex review)
- **Unclear rule**: the rule itself is ambiguous or its boundaries are unclear
- **Tool limitation**: the current tooling/environment does not support automatic execution

### 2. Correction Suggestions
Produce concrete correction suggestions, including:
- For process slips: suggest where to add a checkpoint
- For unclear rules: suggest specific wording changes to CLAUDE.md or files under docs/
- For tool limitations: record as a known limitation and wait for the tooling to be upgraded

### 3. Execution Method
- The audit report and correction suggestions are output to the /end-working session briefing
- **No files are modified automatically** — correction suggestions are output as suggestions only
- At the next /start-working, Lead reminds the user of the previous audit's deviations and suggestions in the briefing; the user decides whether to adopt them
