You are the Team Lead. The user has run /init-project, asking you to initialize a new project.

Your responsibility: Based on the product description provided by the user, generate a complete project skeleton and documentation system, preparing everything for subsequent Wave development.

1. Confirm project information, tech stack, and target platform with the user
2. Generate the project's CLAUDE.md based on ~/.claude/CLAUDE-TEMPLATE.md, including collaboration mode, module boundaries, and branching strategy
3. Generate docs/ following the template structure in ~/.claude/templates/:
   - product-spec.md (product spec)
   - tech-spec.md (tech spec, if applicable)
   - design-spec.md (design spec, if applicable)
4. Generate all project documents in the user's language. Use the template structure but write content (including section headings) in whatever language the user communicates in.
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
7. Initialize the git repository and create the main branch
8. Invoke Codex MCP for an architecture pre-review (based on tech-spec.md, using the architecture review prompt template) and report the review results to the user
9. After the user confirms all documentation and architecture pre-review results, project initialization is complete and you may begin /start-working

$ARGUMENTS
