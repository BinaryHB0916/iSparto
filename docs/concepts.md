# Core Concepts

> If you're familiar with software team collaboration, the following concepts can be quickly understood by analogy.

## The Most Critical Concept: Decoupling

**The entire premise of Wave parallel execution is that tasks are fully decoupled.** This applies to both write tasks (coding, documentation) and read tasks (code review, doc audit, research/debug). If two tasks touch the same file, or if A's output is B's input, they cannot be placed in the same Wave for parallel execution.

The Team Lead's core job when breaking down tasks is not "distributing work," but **determining which tasks can run simultaneously and which must run sequentially**. The criteria are:

- **File level**: Do the two tasks modify overlapping files? If so, they cannot run in parallel.
- **Data level**: Does A produce a data structure that B consumes? Then A must finish before B can start.
- **Logic level**: Do the two features have runtime dependencies? For example, login must be completed before payment can use the user session.

**Tasks that can be decoupled go into the same Wave for parallel acceleration; tasks that cannot be decoupled are split into different Waves for sequential execution.** This is the underlying logic of "parallel within a Wave for speed, sequential across Waves for quality."

Two tools are used to achieve decoupling:
- **File ownership** — Each Developer can only modify files within their assigned scope, physically preventing conflicts
- **Interface contract** — When multiple Developers' code needs to integrate, interfaces are defined upfront, each develops against the contract, and integration happens at the end

If the Team Lead finds that tasks within a Wave cannot be fully decoupled, the correct approach is to **split them into smaller Waves**, rather than forcing parallelism at the risk of conflicts.

## Concept Quick Reference

| Concept | Explanation | Analogy |
|---------|-------------|---------|
| **Wave** | A batch of decoupled tasks. Tasks within a Wave execute in parallel, Waves execute sequentially, and users validate at Wave boundaries. | Similar to a Sprint, but lighter and more granular |
| **File ownership** | When the Team Lead breaks down tasks, they assign each Developer a specific set of files they can modify, physically isolating parallel tasks. | Similar to Git CODEOWNERS, but dynamically assigned per task |
| **Interface contract** | When multiple Developers work in parallel, the Team Lead predefines function signatures, parameter types, and return values between modules, ensuring independently developed code can integrate. | Similar to API documentation, but defined before development |
| **MCP (Model Context Protocol)** | A protocol defined by Anthropic that allows Claude Code to call external tools. iSparto uses MCP to invoke Codex for code review and QA. | Similar to a plugin system |
| **tmux teammate mode** | The built-in Agent Team execution mode in Claude Code. Multiple Developers work in parallel in their own tmux panes, coordinated by the Team Lead. iTerm2 has built-in tmux integration — no separate installation needed — Claude Code manages sessions automatically. | Similar to multiple terminal windows working simultaneously |
| **Agent Team** | An experimental feature of Claude Code that allows a primary session (Team Lead) to launch multiple sub-sessions (Developers) for parallel development. | Similar to a project manager leading multiple programmers |
| **Snapshot/Restore** | Automatic pre-change backup. Created before `/init-project`, `/migrate`, and `install.sh`. `/restore` rolls back to any snapshot. Stored in `~/.isparto/snapshots/`. | Similar to a system restore point |
| **Session Log** | Automatic development metrics collected by `/end-working` and reported by `/start-working`. Stored in `docs/session-log.md`. Tracks: tasks completed, developers spawned, Codex reviews, files changed, key decisions. | Similar to a daily standup summary |
| **Process Observer** | The compliance supervision role in the team. Composed of two parts: real-time interception (PreToolUse hooks block dangerous operations before execution) and post-session audit (sub-agent reviews workflow compliance during /end-working). Does not participate in development decisions — only monitors process compliance. | Similar to a CI/CD policy check + post-sprint retrospective |
| **Compliance Audit** | The post-session review performed by Process Observer during /end-working. Checks 5 categories (branch convention, Codex review compliance, Doc Engineer compliance, PR workflow, ownership violations) across 14 items. Outputs a deviation report with PASS/FAIL/WARNING status. | Similar to a SOX compliance audit, but for development workflow |
