# iSparto Product Roadmap

This document tracks the long-range product vision beyond v0.8 (the current "externally usable" milestone). Active development is tracked in [`docs/plan.md`](plan.md); this file is the vision board, intentionally decoupled from day-to-day planning.

Items on this page are NOT implementation tasks. They are product capabilities planned for a future major-version line. The cadence is slow and deliberate — each capability in v1.x depends on clearing the v0.8 externally-usable gate first, and each capability in v2.x depends on the v1.x autonomous-team foundation being in place.

For the full three-phase product narrative (v0.x developer tool → v1.x autonomous team → v2.x CEO workstation), see [`docs/product-spec.md`](product-spec.md).

---

## v1.x — Autonomous Development Team

**Delivery standard:** The user hands over a task description; the team runs the full workflow and delivers a verifiable result with no mid-process user intervention required.

**Core capabilities:** Process autonomy + state visibility

### Planned for v1.x

- **Cross-session task continuation** — After switching sessions, the team automatically restores context; no manual user alignment required.
- **Multi-task parallel management** — Advance multiple independent tasks at the same time; Lead auto-schedules priorities.
- **Progress summaries** — Per-task status, completion, and blockers reported in plain language.
- **Demo previews** — Auto-deploy a preview environment, capture screenshots, and provide a one-sentence change summary.
- **Risk alerts** — Proactively surface complexity overruns, dependency issues, and technical risks.
- **Automatic retry and rollback** — On build/test failure, auto-diagnose, then retry or roll back. Also tracked as GitHub issue #2 (Pro tier).
- **Agent dashboard** — Task board visualizing team work state. Also tracked as GitHub issue #3 (Pro tier).
- **Cost & token analytics** — Usage metrics that help users understand ROI. Also tracked as GitHub issue #3 (Pro tier).

### Partially shipped toward v1.x

- **Role-to-model binding** — Shipped in v0.6.0 as a declarative config table (see `docs/configuration.md#agent-model-configuration`) that decouples role definitions from model names. Runtime auto-switching remains on the v1.x list.

---

## v2.x — CEO Workstation

**Delivery standard:** A non-technical user describes requirements in natural language and receives a runnable demo + progress report, never touching code or the terminal throughout.

**Core capabilities:** Requirement understanding + natural-language interaction

### Planned for v2.x

- **Requirement breakdown** — Business language → technical tasks → priority ranking; the user only confirms direction.
- **Solution decisions** — The team proposes technical options; the user picks one without needing to understand technical details.
- **Delivery acceptance** — Runnable demo + change explanation; the user experiences it and provides feedback.
- **Natural-language project management** — Ask-in-conversation questions like "Can we ship this week?" or "How is yesterday's feature going?"
- **Multi-project management** — Simultaneous management of multiple AI teams across projects.
