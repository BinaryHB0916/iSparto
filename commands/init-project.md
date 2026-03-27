You are the Team Lead. The user has run /init-project, asking you to initialize a new project.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only). All generated documentation content must also be in the user's language.

Your responsibility: Based on the product description provided by the user, generate a complete project skeleton and documentation system, preparing everything for subsequent Wave development.

1. Confirm project information, tech stack, and target platform with the user
2. **Before creating any files**, create a snapshot of the current project state:
   - Run the following command:
     ```bash
     bash ~/.isparto/lib/snapshot.sh create init-project "$(pwd)" CLAUDE.md .claude/settings.json docs/plan.md docs/product-spec.md docs/tech-spec.md docs/design-spec.md
     ```
   - Report the snapshot ID to the user: "Snapshot created: <id>. You can restore to pre-init state with `/restore <id>` at any time."
   - For a brand new project, most files will be recorded as "absent" — this is expected. The snapshot records what existed before so that `/restore` knows to remove files that were created.
   - If the snapshot script is not found at `~/.isparto/lib/snapshot.sh`, warn the user: "Snapshot script not found. Run `~/.isparto/install.sh --upgrade` to update iSparto." Then proceed without a snapshot — do not block on this.
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
     "teammateMode": "tmux",
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh"
             }
           ]
         },
         {
           "matcher": "Edit",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh"
             }
           ]
         },
         {
           "matcher": "Write",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh"
             }
           ]
         },
         {
           "matcher": "mcp__codex-reviewer__codex",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.isparto/hooks/process-observer/scripts/pre-tool-check.sh"
             }
           ]
         }
       ]
     }
   }
   ```
   If the project already has .claude/settings.json, merge these settings into it without removing existing entries.
   If the project needs platform-specific plugins (e.g., swift-lsp for iOS), add enabledPlugins here too.
7. Initialize the git repository and create the main branch
8. Invoke Codex MCP for an architecture pre-review (based on tech-spec.md, using the architecture review prompt template) and report the review results to the user
9. After the user confirms all documentation and architecture pre-review results, project initialization is complete and you may begin /start-working

Note: If anything goes wrong during initialization, the user can run `/restore <snapshot_id>` to roll back all changes.

$ARGUMENTS
