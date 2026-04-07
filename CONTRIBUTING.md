# Contributing to iSparto

Welcome! iSparto is a community-driven project, and we appreciate contributions of all kinds -- bug reports, documentation improvements, new templates, and code changes.

iSparto uses its own Agent Team workflow for development (self-bootstrapping), so contributing here also means shaping the tool you use.

> **Language note:** English and Chinese are both welcome in issues, discussions, and PRs.

---

## Reporting Issues

Use [GitHub Issues](https://github.com/BinaryHB0916/iSparto/issues) to report bugs or request features.

### Bug reports

Please include:

- **iSparto version:** `cat ~/.isparto/VERSION`
- **OS:** macOS version (and Linux distro, if applicable)
- **Claude Code version:** `claude --version`
- **What happened:** Steps to reproduce the problem
- **What was expected:** The behavior you expected instead

### Feature requests

- Describe the **problem** you are trying to solve
- Propose a **solution** (if you have one)
- Note any **alternatives** you considered

---

## Contributing Code and Docs

1. **Fork** the repo and clone your fork
2. **Create a branch** from `main`:
   - Features: `feat/short-description`
   - Fixes: `fix/short-description`
3. **Make your changes**
4. **Test your changes:**
   - For `install.sh` changes: run `./install.sh --dry-run` to verify
   - For command templates (`commands/*.md`): manually test in a Claude Code session
   - For doc changes: review rendering on GitHub
5. **Commit** with a clear message (see [Commit messages](#commit-messages) below)
6. **Open a PR** against `main`

PRs will be reviewed by maintainers. We aim to respond within a few days.

---

## Good First Issues

If you are looking for a place to start, these areas are especially welcoming to new contributors:

- **Documentation** -- fix typos, clarify wording, add translations
- **Troubleshooting** -- add new entries to `docs/troubleshooting.md` from real usage
- **Command templates** -- improve `commands/*.md` based on real-world feedback
- **Document templates** -- add new templates to `templates/`
- **Platform support** -- improve `install.sh` for Linux or other platforms

---

## Things to Be Careful About

Some files have a wide blast radius. Extra care is needed when changing:

| File / Area | Why it matters |
|---|---|
| `install.sh` | Must maintain backward compatibility -- existing users rely on `--uninstall` to revert cleanly |
| `commands/*.md` | These are the command templates for all users; changes should be well-tested before merging |
| `CLAUDE-TEMPLATE.md` | Propagates to every new project created with `/init-project` |
| `README.md` / `README.zh-CN.md` | Keep both English and Chinese versions in sync |

---

## Documentation Language Convention

iSparto maintains a four-tier language architecture — contributors must understand which tier a file belongs to before editing:

| Tier | What | Language | Examples |
|---|---|---|---|
| Tier 1 | System Prompt Layer (AI instructions) | English only | `CLAUDE.md`, `CLAUDE-TEMPLATE.md`, `commands/*.md`, `agents/*.md`, `templates/*.md`, `hooks/**`, `scripts/*.sh`, `lib/*.sh`, `install.sh`, `bootstrap.sh` |
| Tier 2 | Reference Documentation | English only | All `docs/*.md` files (except Tier 4 historical artifacts and the `docs/zh/` directory) |
| Tier 3 | User-Facing Entry | Bilingual | `README.md`, `README.zh-CN.md`, `docs/zh/quick-start.md`, `CONTRIBUTING.md` |
| Tier 4 | Historical Artifacts | Frozen (not retroactively edited) | `docs/session-log.md`, `docs/framework-feedback-*.md`, historical entries in `docs/plan.md` and `CHANGELOG.md` |

**Key rules:**

- **Tier 1 must not embed literal user-facing strings in any specific language.** Describe the intent in English and let the Lead generate the actual string in the user's language at runtime. See CLAUDE.md > Documentation Language Convention for the exact "wrong vs right" pattern.
- **No Chinese mirror of `docs/`.** Single source of truth in English. The only Chinese file under `docs/` is `docs/zh/quick-start.md`; do not add more Chinese mirrors, and do not translate existing `docs/*.md` files into Chinese.
- **`README.md` ↔ `README.zh-CN.md` must stay in sync.** Any content change to one requires a parallel change to the other (already listed in the blast-radius table above).
- **New entries in `docs/plan.md` and `CHANGELOG.md` are written in English**, even though historical entries from before the Wave 1 convention may contain CJK.

**Mechanical guardian (`scripts/language-check.sh`):** PRs are blocked if the language guardian finds CJK characters in Tier 1 or Tier 2 files, or Principle 1 violations in `commands/*.md` / `agents/*.md`. The guardian runs inside the Doc Engineer audit step of `/end-working` starting from Wave 4, which means any branch that introduces a violation cannot merge until it is fixed. Before opening a PR, run the guardian locally:

```bash
bash scripts/language-check.sh            # main scan (exit 0 = clean)
bash scripts/language-check.sh --self-test  # verify Principle 1 detector is working
```

Full authoritative definition: [CLAUDE.md > Documentation Language Convention](CLAUDE.md#documentation-language-convention).

---

## Style Guide

### Shell scripts

Follow the existing `install.sh` conventions:

- Color variables (`RED`, `GREEN`, `YELLOW`, `BLUE`, `NC`) for output
- `printf` for formatted output
- Consistent 4-space indentation
- `set -e` at the top

### Markdown

- Follow the structure and tone of existing docs
- Use headers, bullet points, and tables -- avoid walls of text
- Keep lines readable (no strict line-length limit, but break naturally)

### Commit messages

- Use imperative mood: "Add session log reading" not "Added session log reading"
- Describe the **why**, not just the what
- Keep the subject line under 72 characters

Examples:
```
Add Linux support to install.sh

Fix git diff command to include staged files in end-working

Clarify snapshot restore steps in troubleshooting docs
```

---

## Releasing (Maintainers)

To cut a new release:

```bash
./scripts/release.sh 0.3.0
```

The script handles everything automatically:
1. Validates preconditions (on main, clean tree, tag doesn't exist)
2. Updates `VERSION` and stamps `CHANGELOG.md` with the release date
3. Commits, tags `v0.3.0`, pushes to origin
4. Generates `checksums.sha256` for `install.sh`
5. Creates a GitHub Release with `install.sh` + `checksums.sha256` as assets

**Before releasing:** make sure `CHANGELOG.md` has entries under `[Unreleased]` describing what changed.

---

## Community

- **Languages:** English and Chinese are both welcome
- **Conduct:** Be respectful and constructive in all interactions
- **Questions:** Open a GitHub Issue or Discussion -- there are no bad questions

---

## License

By contributing to iSparto, you agree that your contributions will be licensed under the [MIT License](LICENSE).
