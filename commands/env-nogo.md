You are the Setup Assistant. The user has run /env-nogo, asking you to check whether the current environment meets iSparto's requirements.

Check each item and report the result (pass / fail):

Global environment:
1. OS: macOS
2. Terminal: iTerm2 (check whether $TERM_PROGRAM is iTerm.app)
3. Node.js: 18+ (check node -v)
4. Claude Code: installed (check claude --version)
5. Codex CLI: installed and logged in (check codex --version and codex login status)
6. ~/.claude/ completeness: CLAUDE-TEMPLATE.md, commands/ (7 commands including restore.md), templates/ (4 templates)
7. Snapshot system: ~/.isparto/lib/snapshot.sh exists and is executable

Project environment (if the current directory has a CLAUDE.md, you are inside a project — run these additional checks):
8. Codex MCP Server: connected
9. Project-level .claude/settings.json exists and contains required iSparto settings (teammateMode and CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS)
10. CLAUDE.md: content is complete (contains key sections such as collaboration mode, module boundaries, etc.)
11. docs/ structure: at least product-spec.md and plan.md exist

Report format: List ALL items with their status (pass / auto-fixed / fail). For items that can be auto-fixed (e.g., missing npm packages), attempt the fix and report as "auto-fixed". For items requiring manual action, report as "fail" with the specific fix command.
All pass → output "Environment ready. You may proceed."
Any fail → output "There are no-go items. Please fix them first."
