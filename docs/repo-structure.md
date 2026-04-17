# Repository Structure

This file documents the iSparto repository layout. The tree evolves Wave by Wave as new modules land or existing ones reshape — this file is the authoritative source, not the README. The README used to embed the full tree inline, but as of v0.7.5 it points here so the README can stay focused on the framework's pitch while this file carries the detail.

When a Wave adds a new top-level file or directory, or renames an existing one, update this file in the same commit as the structural change.

## Layout

```
iSparto/
├── README.md                  ← English entry point (pitch + installation + quick start)
├── README.zh-CN.md            ← Chinese-language entry point
├── CLAUDE.md                  ← Project instructions for Claude Code (Tier 1 System Prompt Layer)
├── CONTRIBUTING.md            ← Contribution guidelines
├── settings.example.json      ← Reference template for project-level .claude/settings.json
├── CLAUDE-TEMPLATE.md         ← Template for generating new project CLAUDE.md
├── LICENSE
├── .gitignore
├── VERSION                    ← Current version (semver)
├── CHANGELOG.md               ← Release notes
├── bootstrap.sh               ← Thin entry point (version resolve + checksum verify)
├── install.sh                 ← Main installer (versioned per release)
├── isparto.sh                 ← Local stub (upgrade / uninstall / version)
├── scripts/
│   ├── release.sh             ← Automated release (bump version → changelog → tag → gh release)
│   ├── language-check.sh      ← Four-tier language guardian (Tier 1 / Tier 2 CJK scan + Principle 1 heuristic)
│   └── policy-lint.sh         ← Information Layering Policy guardian (C-layer ceremonial wrapper detector, v1)
├── lib/
│   └── snapshot.sh            ← Snapshot / restore engine (factory-reset capability)
├── hooks/
│   └── process-observer/      ← Real-time interception hook scripts + rule files
├── commands/
│   ├── start-working.md       ← Start-working command
│   ├── end-working.md         ← End-working command
│   ├── plan.md                ← Planning command
│   ├── init-project.md        ← Initialize project command
│   ├── env-nogo.md            ← Environment readiness check
│   ├── migrate.md             ← Migrate existing project to iSparto
│   ├── restore.md             ← Restore project to a previous snapshot
│   ├── security-audit.md      ← Milestone-level full security audit
│   └── release.md             ← Release flow (wraps scripts/release.sh)
├── agents/
│   ├── independent-reviewer.md       ← Product-technical alignment blind reviewer
│   ├── process-observer-audit.md     ← Post-session compliance audit role
│   └── doc-engineer.md               ← Documentation audit role
├── templates/
│   ├── product-spec-template.md
│   ├── tech-spec-template.md
│   ├── design-spec-template.md
│   ├── plan-template.md
│   └── gitignore-security-baseline.md   ← Security .gitignore baseline
├── assets/
│   └── *.svg                          ← SVG assets used by the READMEs
└── docs/
    ├── product-spec.md        ← Product spec (iSparto's own, for self-bootstrapping)
    ├── plan.md                ← Development plan by Wave
    ├── roadmap.md             ← Long-range v1.x / v2.x product roadmap
    ├── session-log.md         ← Auto-generated session metrics (created by /end-working)
    ├── case-studies.md        ← End-to-end dogfooding case collection
    ├── repo-structure.md      ← This file
    ├── dogfood-log.md         ← Subjective dogfooding experience log
    ├── concepts.md            ← Core concepts (decoupling, Wave, file ownership)
    ├── security.md            ← Security audit system (three-layer defense)
    ├── user-guide.md          ← User interaction guide
    ├── roles.md               ← Role definitions + Codex prompt templates
    ├── workflow.md            ← Full development workflow + branching + Codex integration
    ├── configuration.md       ← Global configuration + adaptation + multi-device sync
    ├── troubleshooting.md     ← Common troubleshooting
    ├── process-observer.md    ← Process Observer subsystem reference
    ├── design-decisions.md    ← Design decision records
    ├── independent-review.md  ← Independent Reviewer report archive
    ├── zh/
    │   └── quick-start.md     ← Chinese quick-start (Tier 3 user-facing entry)
    └── design-principles/
        ├── information-layering-policy.md   ← A / B / C layering policy
        └── conversation-style.md            ← Conversation style guide
```

## Tier annotation (per CLAUDE.md Documentation Language Convention)

- **Tier 1 (System Prompt Layer, English-only):** `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `commands/`, `agents/`, `templates/`, `hooks/`, `bootstrap.sh`, `install.sh`, `isparto.sh`, `scripts/`, `lib/`.
- **Tier 2 (Reference Documentation, English-only):** All files under `docs/` except Tier 4 artifacts and `docs/zh/`.
- **Tier 3 (User-facing entry, bilingual):** `README.md`, `README.zh-CN.md`, `docs/zh/quick-start.md`, `CONTRIBUTING.md`.
- **Tier 4 (Historical artifacts, frozen):** `docs/session-log.md`, `docs/framework-feedback-*.md`, `docs/plan.md`, `docs/dogfood-log.md`, and historical entries in `CHANGELOG.md`.

See `CLAUDE.md > Documentation Language Convention` for the full rationale and the language-check guardian behavior.
