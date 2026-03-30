# [Project Name] -- Development Plan

---

## Project Structure

<!-- Full file tree, keep updated as the project evolves -->

---

## Completed Phases

<!-- Compress completed Phase/Wave entries into single-line headings to reduce token usage -->
### Phase X: xxx
### Phase Y: yyy

---

## Wave Parallel Development Plan

> Waves run in parallel for speed; Waves run sequentially for quality. Users accept deliverables at Wave boundaries.
> The core of Wave splitting is decoupling: tasks within the same Wave must not have file overlaps, data dependencies, or runtime dependencies. If decoupling is not possible, move the task to the next Wave.

### Wave Overview

```
Wave 1 (status)
|-- Team A: [task name]
|-- Team B: [task name]
+-- Team C: [task name]

    -- Manual intervention: [action] --

Wave 2 (status)
+-- Team A: [task name]

    -- Manual intervention: [action] --

Wave N ...
```

---

### Wave 1 -- [Status: In Progress / Not Started / Completed]

#### Team A: [Task Name]

**Status:** [Not Started / In Progress / Completed]

**Task List:**
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

**File Ownership:**
- Developer A may create: [file list]
- Developer A may modify: [file list]
- Developer B may modify: [file list]
- Off limits: [file list]

**Interface Contracts:** (if multi-Developer collaboration)
<!-- Function signatures, parameter types, return values, shared data structures -->

**Codex Review:** [Yes/No] -- [Reason]

**Acceptance Script:**
0. setup  [precondition — environment, test data, initial state]
1. action [user operation or API call]
2. eval   [expected result — what to assert]
3. action [next operation]
4. eval   [expected result]
<!-- Extend with more action/eval pairs as needed. Each eval must be objectively verifiable. -->

**Completion Criteria:**
- Build passes
- Unit tests pass
- Codex code review passes (if triggered)
- Developer review of fixes passes
- Codex QA smoke testing passes (if triggered)
- Acceptance script eval steps all pass
- Doc Engineer documentation audit passes
- plan.md updated

---

#### Team B: [Task Name]
<!-- Same structure as above -->

---

### Wave 2 -- [Status]

**Prerequisites:** Wave 1 fully completed + [other conditions]

#### Team A: [Task Name]
<!-- Same structure as above -->

---

## Manual Intervention Points

| Timing | Action | Estimated Duration |
|--------|--------|--------------------|
| After Wave X completes | [specific action] | Xmin |
| Before Wave Y starts | [external dependency ready] | External process |

---

## Technical Decision Log

| Decision | Choice | Reason |
|----------|--------|--------|
| ... | ... | ... |

---

## Rejected Approaches

> Approaches tried and rejected during development. Prevents AI from re-attempting disproven paths.
> Lead records entries during /end-working; Lead surfaces relevant entries during /start-working.

| Date | Module/Feature | What was tried | Why rejected | Notes |
|------|---------------|---------------|-------------|-------|

---

## To-Do (Non-Code)

1. Pending: [to-do item] -- [description]
2. Done: [completed item] -- [description]
