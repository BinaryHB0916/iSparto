# Configuration & Adaptation

## Configuration Layers

iSparto uses two configuration layers. The installer does NOT modify your global `~/.claude/settings.json` — your personal Claude Code settings are always preserved.

### Project-Level Configuration (.claude/settings.json)

Created automatically by `/init-project` or `/migrate` in each project:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "tmux"
}
```

This is the minimum required for iSparto's Agent Team mode. Add platform-specific plugins here as needed (e.g., swift-lsp for iOS projects).

### Global Configuration (optional, user-managed)

Your `~/.claude/settings.json` is yours. iSparto never touches it. You may optionally set model and effort preferences globally:

```json
{
  "model": "opus",
  "effortLevel": "max"
}
```

The repo includes a `settings.json` as a reference template — it is NOT installed globally.

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
├── session-log.md      ← Auto-generated session metrics (created by /end-working)
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
| session-log.md | Tasks completed, developers spawned, Codex reviews, files changed, key decisions | **Auto-generated session metrics** |

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
| 7 custom commands | `/start-working`, `/end-working`, `/plan`, `/init-project`, `/env-nogo`, `/migrate`, `/restore` are universal for all projects |
| Role definitions | Responsibilities and rules for Team Lead, Developer, Codex Reviewer, Doc Engineer, Process Observer |
| Trigger condition table | Trigger logic for code review + QA smoke testing |
| Branching strategy | Branch model for main / feat / fix / hotfix |
| Authorization & escalation mechanism | Team Lead's decision boundaries |
| Documentation sync rules | Documentation must follow when code changes |
| settings.json | Reference template — project-level config is created by `/init-project` or `/migrate` |

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

## Hooks Configuration (Process Observer)

Process Observer 的实时拦截功能通过 Claude Code PreToolUse hook 实现。

### Hook 机制

Claude Code 支持在工具调用前触发 hook 脚本。Process Observer 注册一个 PreToolUse hook，在每次 Bash 命令执行前检查是否匹配高危操作清单。

### 拦截范围

| 类别 | 示例操作 | 拦截原因 |
|------|---------|---------|
| Git 不可逆 | `git push --force`, `git reset --hard`, `git clean -f` | 覆盖历史/丢弃修改/删除文件 |
| 敏感信息泄露 | `git add .env`, `git add *.key` | 敏感文件可能被推送到公开仓库 |
| 跳过安全检查 | `--no-verify`, `--no-gpg-sign` | 绕过 pre-commit hook 或签名 |
| 破坏性文件操作 | `rm -rf /`, `rm -rf ~` | 灾难性删除 |
| iSparto 特有保护 | 修改 `~/.claude/settings.json` | 保证不修改用户全局配置 |
| 直接在 main 开发 | main 分支上 `git commit` | main 锁定，必须通过分支开发 |

### 拦截行为

匹配高危操作时，hook 返回非零退出码阻止执行，并在 stderr 输出拦截原因和建议替代方案。

### 自定义

如需调整拦截规则（例如在特定项目中允许某些操作），可在项目级 hook 配置中覆盖。完整的高危操作清单和判断原则详见 [docs/process-observer.md](process-observer.md)。

---

## Multi-Device Sync (Optional)

To share iSparto configuration across multiple computers, symlink `~/.claude/` (commands, templates, CLAUDE-TEMPLATE.md) to a synced directory (iCloud Drive, Dropbox, or a git repo). Runtime data under `~/.claude/` (history, cache) should not be synced.
