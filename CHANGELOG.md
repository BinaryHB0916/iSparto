# Changelog

All notable changes to iSparto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Process Observer full workflow monitoring — expands from Bash-only (20 rules) to all tool calls: Edit/Write code file interception (blocks direct code editing by all roles except Developer), Codex MPC structured prompt enforcement (must contain ## heading), new workflow-rules.json with configurable extension lists
- install.sh and project templates (init-project, migrate) register 4 hook matchers: Bash, Edit, Write, mcp__codex-reviewer__codex

### Fixed

- install.sh --upgrade now skips redundant tarball download when already on the target version

## [0.6.0] - 2026-03-27

### Changed

- Role swap: Lead/Teammate no longer write code directly — they assemble structured prompts for Developer (Codex) and review output. Codex moves from Reviewer to primary implementer
- 5-role architecture: Lead, Teammate, Developer, Doc Engineer, Process Observer (QA merged into Developer as a prompt mode, replacing the former 4-role model)
- New Agent Model Configuration table in docs/configuration.md — single source of truth for role-model binding; all hardcoded model names removed from role definitions, workflows, READMEs, and SVG diagrams
- Terminology migration across 12 files, 6 modules: "Codex Reviewer" → "Developer", "Claude Developer" → "Teammate", model names replaced with configuration table references
- Implementation prompt template added to roles.md (replaces code review prompt for the new Developer role)
- Developer Trigger Conditions table (renamed from Codex Review Trigger Conditions) with updated terminology

## [0.5.4] - 2026-03-27

### Added

- User Preference Interface: territory-based boundary between Claude Code auto-memory and CLAUDE.md workflow rules, three-level preference response model (unconditional / conditional / record-only), conflict protocol, and agent team memory write rules
- Plan Mode auto-trigger: Lead autonomously enters plan mode for cross-module, core design, user-facing, or hard-to-reverse changes
- CLAUDE-TEMPLATE.md now includes User Preference Interface section (new projects inherit the rules via /init-project)
- docs/configuration.md: detailed User Preference Interface reference documentation
- docs/concepts.md: User Preference Interface added to Concept Quick Reference
- docs/user-guide.md: "Your Preferences and the Agent Team" section
- docs/design-decisions.md: recorded User Preference Interface and Plan Mode decisions

## [0.5.3] - 2026-03-26

### Changed

- Codex review trigger rules overhauled: default is now "trigger code review + QA" for all code changes (Tier 1); only pure visual/config changes (Tier 2, QA only) and pure doc/formatting (Tier 3, skip both) are exempt
- New Wave-level safety net: each Wave must include at least one batch Codex review regardless of individual change categorization
- Process Observer compliance checklist expanded: 13 → 14 items (added B4 Wave-level batch review check)

## [0.5.2] - 2026-03-26

### Added

- `install.sh --upgrade` now auto-patches project-level `.claude/settings.json` to register Process Observer hooks if missing (covers projects init'd before v0.5.0)
- Graceful fallback: warns if python3 is unavailable or settings.json is invalid, suggests `/migrate` as alternative

## [0.5.1] - 2026-03-26

### Added

- Process Observer C4 check: cross-references plan.md unchecked items against actual codebase state, catches implemented features that were not marked done

### Fixed

- All 7 command templates now detect user's language and respond accordingly (Chinese or English); previously always responded in English regardless of user input

## [0.5.0] - 2026-03-26

### Added

- Process Observer role: real-time interception via PreToolUse hooks (20 rules, 6 categories) + post-session compliance audit (13 check items, 5 checklists)
- dangerous-operations.json: configurable high-risk operation ruleset (git destructive, sensitive info leak, hook bypass, filesystem destructive, iSparto-specific, direct-on-main)
- hooks/process-observer/scripts/pre-tool-check.sh: shell-based hook script, no jq dependency, POSIX ERE patterns
- /end-working now includes Process Observer audit step with deviation report + rule correction suggestions
- /init-project and /migrate auto-register Process Observer hooks in project settings.json
- install.sh installs hooks to ~/.isparto/hooks/ and isparto.sh --uninstall cleans them up
- Three-phase product roadmap: v0.x (developer tool) → v1.x (autonomous dev team) → v2.x (CEO workbench)
- Three-layer capability model in product-spec.md (process autonomy → status visibility → requirement understanding)
- docs/process-observer.md: complete role documentation with audit checklists, deviation report template, and feedback loop mechanism

## [0.4.1] - 2026-03-25

### Fixed

- isparto.sh: use `exec` in do_upgrade() to prevent `;;` syntax error after self-overwrite during upgrade
- Upgrade output: compressed from ~40 lines to ~15 (changelog folded to Added + counts, deps/files/MCP collapsed, removed Next Step for upgrades)

## [0.4.0] - 2026-03-25

### Added

- Agent Team mode now triggers for read tasks (code review, doc audit, research) in addition to write tasks
- Platform check: install.sh warns on non-macOS systems

### Changed

- Collaboration Mode selection criteria refined: "decomposable + worth the overhead" applies to both read and write
- Extracted language instruction from 7 command templates into CLAUDE.md/CLAUDE-TEMPLATE.md (single source of truth)
- Simplified configuration.md: removed Memory Boundary section, shortened Multi-Device Sync to 3 lines
- release.sh uses PR flow instead of direct push to main

### Fixed

- isparto.sh: trap local variable scope bug (local var not accessible in EXIT trap after function returns)
- snapshot.sh: --latest flag now compares timestamps instead of relying on glob order
- Shell scripts: fixed trap quoting across bootstrap.sh, install.sh, isparto.sh, scripts/release.sh
- README: fixed notification count, Solo mode description, directory tree completeness, zh-CN self-reference link
- workflow.md: fixed release branch format, added Setup Assistant footnote

### Removed

- Pro version section from product-spec.md (open-source repo only contains free features)
- Screenshot placeholder notes from READMEs (will use video demos)
- Dead code: unused color variables, unreachable VERSION fallback branch, stale checksums.sha256 reference

## [0.3.0] - 2026-03-25

### Added

- Automated release script (scripts/release.sh): bump version, update changelog, tag, push, create GitHub Release with assets

### Fixed

- Upgrade from git-clone install no longer copies files to themselves

## [0.2.0] - 2026-03-25

### Changed

- Installer architecture: replaced git-clone approach with thin bootstrap + GitHub Releases
- bootstrap.sh: new thin entry point with SHA256 checksum verification and version pinning
- isparto.sh: new local stub for offline uninstall/restore and network upgrade
- install.sh: downloads release tarball instead of cloning git repo
- Automatic migration from old git-clone installs to release-based installs

### Fixed

- Upgrade from old versions no longer requires pressing Y for each file
- Self-update mechanism works reliably across all versions

## [0.1.0] - 2026-03-24

### Added

- Core workflow with 7 slash commands (/start-working, /end-working, /plan, /init-project, /migrate, /env-nogo, /restore)
- 4 document templates (product-spec, tech-spec, design-spec, plan)
- CLAUDE-TEMPLATE.md for bootstrapping new projects
- Install system (install.sh) with dry-run, uninstall, upgrade, and MCP registration support
- Bilingual README (English and Chinese)
- SVG assets for header banner and role architecture diagram
- Snapshot/restore system (lib/snapshot.sh) for saving and restoring project state
- /restore slash command integrated into install, migrate, and init-project flows
- Session log feature for tracking development sessions
- Self-bootstrap: iSparto migrated to its own workflow
- Real-world usage section in README with dogfooding results
- Upgrade system for updating iSparto in existing projects
