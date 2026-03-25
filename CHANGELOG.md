# Changelog

All notable changes to iSparto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
