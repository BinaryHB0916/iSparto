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

## Community

- **Languages:** English and Chinese are both welcome
- **Conduct:** Be respectful and constructive in all interactions
- **Questions:** Open a GitHub Issue or Discussion -- there are no bad questions

---

## License

By contributing to iSparto, you agree that your contributions will be licensed under the [MIT License](LICENSE).
