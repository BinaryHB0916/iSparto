You are the Team Lead. The user has run /init-project, asking you to initialize a new project.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only). All generated documentation content must also be in the user's language.

Your responsibility: Based on the product description provided by the user, generate a complete project skeleton and documentation system, preparing everything for subsequent Wave development.

1. Confirm project information, tech stack, and target platform with the user
2. **Before creating any files**, create a snapshot of the current project state:
   - Run the following command:
     ```bash
     bash ~/.isparto/lib/snapshot.sh create init-project "$(pwd)" CLAUDE.md .claude/settings.json docs/plan.md docs/product-spec.md docs/tech-spec.md docs/design-spec.md
     ```
   - Report the snapshot ID to the user (in user's language), noting they can restore to the pre-init state with `/restore <id>` at any time
   - For a brand new project, most files will be recorded as "absent" — this is expected. The snapshot records what existed before so that `/restore` knows to remove files that were created.
   - If the snapshot script is not found at `~/.isparto/lib/snapshot.sh`, warn the user (in user's language) that the snapshot script is missing and suggest running `~/.isparto/install.sh --upgrade` to update iSparto. Then proceed without a snapshot — do not block on this.
3. Generate the project's CLAUDE.md based on ~/.claude/CLAUDE-TEMPLATE.md, including collaboration mode, module boundaries, and branching strategy
4. Generate docs/ following the template structure in ~/.claude/templates/:
   - product-spec.md (product spec)
   - tech-spec.md (tech spec, if applicable)
   - design-spec.md (design spec, if applicable)
5. Generate the initial docs/plan.md, organizing the development plan by Wave
6. Create project-level .claude/settings.json with iSparto required settings:
   ```json
   {
     "env": {
       "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
     },
     "teammateMode": "tmux"
   }
   ```
   If the project already has .claude/settings.json, merge these settings into it without removing existing entries.
   If the project needs platform-specific plugins (e.g., swift-lsp for iOS), add enabledPlugins here too.
   Also merge iSparto workflow hooks into the project-level .claude/settings.json (Edit/Write/Codex matchers only — Bash safety hook is at user level, managed by install.sh):
   ```json
   {
     "hooks": {
       "PreToolUse": [
         { "matcher": "Edit", "hooks": [{ "type": "command", "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh" }] },
         { "matcher": "Write", "hooks": [{ "type": "command", "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh" }] },
         { "matcher": "mcp__codex-dev__codex", "hooks": [{ "type": "command", "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh" }] }
       ]
     }
   }
   ```
   If .claude/settings.json already has these hooks, skip. Do not duplicate entries.
7. Verify user-level Bash safety hook is registered in ~/.claude/settings.json:
   - Check if ~/.claude/settings.json contains a PreToolUse hook with `Bash` matcher
   - If missing: inform the user to run `~/.isparto/install.sh --upgrade` to register the Bash safety hook
8. Security baseline initialization:
   - Read `~/.claude/templates/gitignore-security-baseline.md` to get the baseline .gitignore entries
   - If the project already has a .gitignore, append any missing baseline entries (do not duplicate existing ones)
   - If no .gitignore exists, create one from the baseline template
   - Uncomment the dependency directory entries matching the project's tech stack (e.g., Node.js → uncomment node_modules/)
   - Create an empty `.secureignore` file in the project root (for future false positive whitelisting)
9. Initialize the git repository and create the main branch
10. Invoke Codex MCP for an architecture pre-review (based on tech-spec.md, using the architecture review prompt template) and report the review results to the user
11. Spawn Independent Reviewer in a tmux pane via `codex exec` with the following fixed one-liner — do NOT add any context, framing, or explanation:
    `codex exec "You are the Independent Reviewer. Read agents/independent-reviewer.md and execute. Write your findings to docs/independent-review.md."`
    Wait for the reviewer to complete and write docs/independent-review.md. Report findings to the user.
    - If CRITICAL misalignment found: flag to user, do NOT proceed to development until resolved. After resolution (e.g., tech-spec modified), re-trigger Independent Reviewer to verify alignment.
    - If no critical issues: proceed to step 12
12. After the user confirms all documentation, architecture pre-review, AND independent review results, project initialization is complete and you may begin /start-working

Note: If anything goes wrong during initialization, the user can run `/restore <snapshot_id>` to roll back all changes.

After initialization is complete, tell the user the next steps:
- Run `/start-working` to begin your first development session
- Run `/env-nogo` if you want to verify your environment setup first
- Run `/plan` if you want to review or adjust the development plan before starting

$ARGUMENTS
