# Configuration & Adaptation

## Global Configuration (settings.json)

```json
{
  "model": "opus",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  },
  "effortLevel": "max",
  "teammateMode": "tmux"
}
```

**Note:** `enabledPlugins` is not placed in the global configuration. Configure it per-project in the project-level `.claude/settings.json` as needed (e.g., add swift-lsp for iOS projects, other plugins for Web projects).

**Note:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is an experimental flag that still requires manual activation as of March 2026. Future Claude Code versions may make this the default behavior, at which point this environment variable can be removed.

**Warning:** `effortLevel: "max"` may be silently downgraded by the `/model` UI (under discussion in Claude Code GitHub issues). Workarounds:
- Write both settings.json + environment variable (already configured above)
- Triple-protect by launching with `claude --effort max` every time
- Avoid using the `/model` command during sessions

---

## Document Naming Conventions

```
docs/
├── product-spec.md     ← Product spec (pages, interaction flows, feature boundaries, copy)
├── tech-spec.md        ← Tech spec (architecture, data models, API contracts, state management, infrastructure, third-party integrations)
├── design-spec.md      ← Design spec (colors, typography, spacing, atmosphere elements, component styles)
├── plan.md             ← Development plan (Wave orchestration, task status, manual intervention points)
└── content/            ← Content assets (if applicable)
```

All spec documents use the uniform `-spec` suffix: product-spec, tech-spec, design-spec.

### Document Responsibility Boundaries

| File | What It Covers | One-liner |
|------|----------------|-----------|
| product-spec.md | Pages, interaction flows, feature boundaries, copy | **What the product does** |
| tech-spec.md | Architecture, data models, API contracts, state management, infrastructure, third-party integrations | **How to build it technically** |
| design-spec.md | Colors, typography, spacing, animations, atmosphere elements | **How it looks visually** |
| plan.md | Wave orchestration, task status, remaining issues, manual intervention points | **Where we are now** |

---

## Template Files

Template files used during project initialization:

| Template | Purpose |
|----------|---------|
| `CLAUDE-TEMPLATE.md` (root) | Generation template for the project CLAUDE.md |
| `templates/product-spec-template.md` | Product spec document template |
| `templates/tech-spec-template.md` | Tech spec document template (optional) |
| `templates/design-spec-template.md` | Design spec document template (optional) |
| `templates/plan-template.md` | Development plan document template |

---

## Adaptation Guide

> This project is a general-purpose template. The following explains which parts can be used as-is and which need to be modified for your project.

### Use As-Is, No Changes Needed

| Content | Description |
|---------|-------------|
| 5 custom commands | `/start-working`, `/end-working`, `/plan`, `/init-project`, `/env-nogo` are universal for all projects |
| Role definitions | Responsibilities and rules for Team Lead, Developer, Codex Reviewer, Doc Engineer |
| Trigger condition table | Trigger logic for code review + QA smoke testing |
| Branching strategy | Branch model for main / feat / fix / hotfix |
| Authorization & escalation mechanism | Team Lead's decision boundaries |
| Documentation sync rules | Documentation must follow when code changes |
| settings.json | Global configuration — copy directly |

### Must Be Modified Per Project

| Content | How to Modify |
|---------|---------------|
| Project overview in CLAUDE.md | Auto-generated during `/init-project` — fill in your product description |
| Tech stack | Fill in your project's actual languages/frameworks/platforms |
| Common commands | Replace with your build/run/test commands |
| Module boundaries | Fill in based on your project's directory structure |
| Project-level plugins | Add swift-lsp for iOS, others for Web — configure in project-level `.claude/settings.json` |

### Optional

| Content | When to Enable |
|---------|----------------|
| tech-spec.md | Create when you have backend/cloud functions/complex architecture; skip for simple front-end-only projects |
| design-spec.md | Create for projects with UI; skip for pure backend/CLI tools |
| content/ directory | Create when the project has content assets (story scripts, copy, etc.) |
| Memory boundary definitions | Reference when discussing products using the Claude.ai web interface |
| Multi-device sync | Configure when switching development between multiple computers |

---

## Memory Boundary Definitions (Optional, for Claude.ai Users)

> If you use Claude.ai (web interface) to discuss product direction and technical decisions, you can leverage Claude's Memory feature to remember long-term information across projects. Below are recommended storage boundaries — what goes in Memory vs. project documents.

### Store in Memory

| Level | Content | Change Frequency |
|-------|---------|------------------|
| Identity information | Personal background, company structure, legal entities | Almost never |
| Preference settings | Communication style, tool preferences, work habits | Occasionally |
| Brand architecture | Brand hierarchy, platform IDs, naming conventions | Rarely |
| Tech stack snapshot | Current toolchain and configuration | When tools change |
| Milestone records | Product and company key milestones | Per milestone |
| Decision principles | Decision frameworks and red lines | Rarely |
| Known failure modes | Cognitive biases and common mistakes | As new ones accumulate |

### Do Not Store in Memory

| Category | Reason |
|----------|--------|
| Wave/Team-level progress | Too granular; managed by plan.md |
| Specific code changes | Belongs in project documents |
| Temporary discussions | Exploratory conversations without conclusions |
| Sensitive credentials | Security risk |

---

## Multi-Device Sync (Optional)

If you switch development between multiple computers, you can share user-level configuration via cloud sync services + symlinks.

### Files to Sync

```
~/.claude/
├── settings.json          ← Global configuration
├── CLAUDE-TEMPLATE.md     ← New project template
├── commands/
│   ├── start-working.md
│   ├── end-working.md
│   ├── plan.md
│   ├── init-project.md
│   └── env-nogo.md
└── templates/
    ├── product-spec-template.md
    ├── tech-spec-template.md
    ├── design-spec-template.md
    └── plan-template.md
```

### No Need to Sync

Runtime data (history, cache, debug, etc. under `~/.claude/`) is independent per device and should not be synced.

### Reference Approaches

**macOS (iCloud Drive):** Place the above files in the iCloud Drive directory and use symlinks to map them back to `~/.claude/`.

**Cross-platform (Git repository):** Create a separate `claude-config` repository, clone it to each device, then symlink.

**How it works:** Claude Code reads configuration from `~/.claude/` on startup. As long as that path points to a symlink to a synced directory, multiple computers can share the same configuration.
