# Framework Feedback — 2026-04-08 Session (#b)

Process Observer audit of Session (#b) (Post-Wave 5 Follow-ups + v0.7.0 release + v0.7.1 emergency BSD-sed hotfix) surfaced 3 framework-side rule correction candidates. This file is the handoff artifact for the next /start-working session to pick up; these are candidates for a future framework-polish Wave, not blocking.

## 1. Self-referential boundary text does not enumerate root-level files

**Rule ID:** CLAUDE.md Development Rules — self-referential boundary clause
**Current text (CLAUDE.md L24):**
> This project is the framework itself; all framework files (commands/, templates/, scripts/, hooks/, agents/, docs/) fall within the self-referential boundary — Lead edits directly, and Process Observer interceptions can be approved

**Gap:** The parenthesized list enumerates directories only: `commands/, templates/, scripts/, hooks/, agents/, docs/`. Root-level framework files are NOT in the list: `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `bootstrap.sh`, `install.sh`, `isparto.sh`, `CHANGELOG.md`, `VERSION`. A literal reading would exclude them from the self-referential exception, even though they are clearly framework-internal Tier 1 files (listed in the Tier 1 — System Prompt Layer definition, the Module Boundaries table, and design-decisions.md entry #75). This text-precision gap has been silently resolved by Lead judgment call in every session so far, but an explicit correction would close the ambiguity.

**Expected behavior:** The self-referential boundary should cover all Tier 1 framework files regardless of whether they live in a subdirectory or at the repo root.

**Suggested fix:** Reword as:
> This project is the framework itself; all Tier 1 — System Prompt Layer files (as defined in Documentation Language Convention) fall within the self-referential boundary — Lead edits directly, and Process Observer interceptions can be approved. This includes both subdirectory files (`commands/`, `templates/`, `scripts/`, `hooks/`, `agents/`, `docs/`) and root-level files (`CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `bootstrap.sh`, `install.sh`, `isparto.sh`).

Equivalent alternatives: anchor to the Module Boundaries table instead of re-listing; or state "all files listed in Tier 1 — System Prompt Layer of the Documentation Language Convention section".

**Session context:** Surfaced in Session (#b) when PR #163 (v0.7.1 BSD-sed emergency hotfix) needed to edit `bootstrap.sh` + `install.sh` via Lead direct edit. The literal reading of L24 would not permit this; the intended reading clearly does. PO audit B2 check judged the Lead's call as correct but noted the text gap.

## 2. No emergency/hotfix exception path for Doc Engineer audit

**Rule ID:** CLAUDE.md Solo Workflow step 4 + Agent Team Workflow step 4
**Current text (both workflows):**
> Lead runs Doc Engineer audit (as sub-agent) — must complete before step 6 push/merge, cannot be deferred to /end-working

**Gap:** The rule is absolute — Doc Engineer must complete before every push/merge. There is no exception path for emergency hotfixes, where a 2-line shell script fix + CHANGELOG entry is functionally lower risk than almost any Doc Engineer checklist item could flag. In Session (#b), PR #163 (v0.7.1 BSD-sed hotfix) skipped the formal Doc Engineer sub-audit under "small, urgent, pre-release window" reasoning — PO audit flagged this as C3 FAIL because no emergency exception exists to appeal to.

**Expected behavior:** A documented, narrowly-scoped exception path that permits Lead to substitute Doc Engineer with a minimal manual review for true emergency hotfixes, while preserving the full requirement for non-emergency work.

**Suggested fix:** Add a new bullet under Solo Workflow step 4 + Agent Team Workflow step 4:
> **Emergency hotfix exception (hotfix/ branches only):** When a hotfix/ branch contains ≤3 changed files, all limited to Tier 1 shell scripts (`*.sh`) and/or `CHANGELOG.md`, AND the user context is explicitly an emergency release window (e.g., a broken release freshly published and actively blocking users), Lead may substitute Doc Engineer with: (a) `bash scripts/language-check.sh` clean run, (b) manual review of each changed file inline in the session, (c) an explicit session-log entry naming the exception. The standard Doc Engineer audit is still required for any hotfix/ branch that does not meet all three conditions.

Mirror the same clause in `docs/workflow.md` Hotfix Workflow section.

**Session context:** Surfaced in Session (#b) PR #163. The fix was unambiguously correct (well-understood BSD/GNU sed divergence, manually verified via `echo | sed` against 3 tag shapes, then end-to-end verified via `~/.isparto/install.sh --upgrade` on the target macOS host). The end-to-end verification was substantively more rigorous than any Doc Engineer item would have been. But the formal compliance step was skipped, and the rule gap should not be left unaddressed.

## 3. Hotfix workflow description in docs/workflow.md does not reference Doc Engineer

**Rule ID:** `docs/workflow.md` "Hotfix Workflow" section (lines ~275-279)
**Current text:**
> **Hotfix Workflow:**
> - Branch hotfix/xxx from main
> - The mode selection table applies: simple single-file hotfixes use Solo + Codex; complex hotfixes use Agent Team
> - The trigger condition table auto-adapts: Tier 2 changes (pure visual, non-security config tweaks) need QA only; Tier 3 changes (pure doc/formatting) skip both; all other code fixes trigger code review + QA per default
> - After fixing, merge back to main via PR; if there are in-progress feat/ branches, sync the hotfix changes

**Gap:** The section describes branch creation, mode selection, trigger table adaptation, and the merge-back step, but omits the Doc Engineer audit entirely. A reader following this section alone (without cross-referencing the Solo/Agent Team Workflow step 4) would conclude that Doc Engineer is optional for hotfixes. This is not the intent — the Solo/Agent Team step 4 requirement applies to all branch types, hotfix included.

**Expected behavior:** The Hotfix Workflow section should explicitly state that the Doc Engineer audit requirement from the Solo/Agent Team workflow still applies to hotfix branches.

**Suggested fix:** Add a bullet:
> - The Solo/Agent Team workflow step 4 Doc Engineer audit requirement still applies to hotfix branches (see [emergency exception path](#emergency-hotfix-exception) if added per Rule Correction 2)

**Session context:** Surfaced in Session (#b) when the C3 FAIL was investigated. The Solo Workflow step 4 rule is clear; the Hotfix Workflow section's omission made it easier to silently skip the audit by referring only to the Hotfix section.

## Next steps

- These 3 corrections are candidates for a future framework-polish Wave. They are not blocking — Session (#b) proceeded to merge despite the C3 FAIL because the PO audit itself noted no retroactive action was required and the changes are already released in v0.7.1.
- Recommended bundling: all 3 corrections are small (1-5 lines each) and share the theme "make implicit rules explicit". They could be closed in a single Solo + Lead direct edit session, similar to the Post-Wave 5 Follow-up Hotfixes pattern.
- Alternatively, these could roll into the next Wave's opening Deferred items list for pickup at the Wave's /end-working.
