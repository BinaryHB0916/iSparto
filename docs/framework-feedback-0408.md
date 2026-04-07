# Framework Feedback — 2026-04-08 (Wave 5 i18n Cleanup /end-working PO audit)

Two framework-side rule corrections surfaced by the Wave 5 /end-working Process Observer audit. Both are recurring gaps (not first-time findings); each has now appeared in three consecutive Waves without triggering a framework correction, so they warrant being promoted to explicit framework tasks.

---

## Rule 1 — plan.md Wave verification-count field drift

**Rule ID:** plan-md-verification-counts

**Gap:**
The `Verification counts` block of each Wave entry in `docs/plan.md` contains a line like `N commits on <branch>`. This value is filled in manually during T10 (Wave entry close-out) and has diverged from actual git history:

- Wave 4 entry recorded 4 commits; actual was 5
- Wave 5 entry recorded 8 commits; actual was 10 (caught by PO audit A7, fixed post-hoc on the session log branch)

The underlying cause is that the Lead estimates the commit count at the time of drafting T10, but the final count only stabilizes after the Doc Engineer fix loop + IR audit trail commit + T10 itself. Manual estimation at drafting time systematically undercounts.

**Expected behavior:**
T10's definition in CLAUDE.md / docs/workflow.md / templates/plan-template.md should explicitly require the Lead to compute the commit count mechanically at T10-execution time:

```bash
git log --oneline --no-merges <wave-base>..HEAD | wc -l
```

and paste the output value into the Wave entry. No other estimation shortcut.

**Session context:**
Wave 5 i18n cleanup finalization. Session 2026-04-08. PO audit A7 flagged the "8 commits" value on plan.md line 298 as inaccurate; actual was 10. The discrepancy was corrected on the docs/session-log-0408 branch in the same /end-working commit that contains this feedback file.

---

## Rule 2 — plan.md per-task incremental update vs. bulk Wave close

**Rule ID:** plan-md-incremental-update

**Gap:**
CLAUDE.md Development Rules states: *"Update docs/plan.md immediately after completing a task (in the same commit, not deferred to /end-working)."*

Observed practice in Waves 3, 4, 5 has settled on a bulk pattern: the Lead writes a placeholder Wave entry at T1 with unchecked `[ ]` task boxes, then replaces the placeholder in T10 with a final entry that has all `[x]` boxes and evidence. Individual task commits (T2, T3, T4, ...) do NOT update plan.md checkboxes as they land.

The rule as written is strict (per-task). The practice is loose (per-Wave bulk at T10). Three consecutive Waves have followed the bulk pattern without being blocked. This gap surfaces as a standing MINOR finding in every IR without triggering any correction, which is a sign that the rule either should be updated to match the practice, or the practice should be enforced.

**Expected behavior (two options — decide which):**

**Option A — relax the rule to match practice.** Update CLAUDE.md Development Rules to explicitly permit the bulk pattern: *"plan.md may be updated either per-task (in the same commit as the task) OR per-Wave in a final T10 close-out commit that lists all task completions with commit hashes. The Wave-close approach is acceptable when the Wave executes as a single atomic work session on a dedicated branch."* This would formally legitimize the observed practice.

**Option B — enforce the strict rule.** Add a Process Observer hook that intercepts task-completion commits (detected by commit message pattern like `docs(xyz): TN ...`) and verifies plan.md was updated in the same commit. This would enforce the current rule text but requires new tooling.

The CURRENT situation — strict rule + loose practice + standing IR MINOR — is the worst of both worlds.

**Session context:**
Flagged by Wave 5 Wave-Boundary IR MINOR #14 and confirmed by /end-working PO audit. Same gap was also flagged in Wave 3 IR and Wave 4 IR without framework correction. Three-Wave recurrence is the trigger to escalate this from "repeat MINOR" to "framework decision needed."

---

## Prior related framework feedback

- `docs/framework-feedback-0407.md` — end-working plan.md update timing rule (Wave 4 deferred, related to Rule 2 above)
- `docs/framework-feedback-0407c.md` — plan.md "下一步" / "技术生态追踪" forward-looking sections language convention gap

All three framework-feedback files are carry-over items; Wave 5 explicitly scoped them out per the /start-working briefing (they are framework polish, not i18n cleanup). A future Wave 6 or independent hotfix PR should consolidate and address them.
