<p align="center">
  <img src="assets/header.svg" alt="iSparto" width="100%"/>
</p>

<p align="center">
  <a href="README.md">English</a>
</p>

---

**iSparto 把 Claude Code 变成一支会克制的 AI 开发团队。** Lead 组装 prompt,Developer(Codex)写代码,Teammate 并行执行,Doc Engineer 同步文档。你指挥团队,团队不把自己做事的过程倒回给你。

> **中文用户第一次使用?** 先看 [docs/zh/quick-start.md](docs/zh/quick-start.md) — 安装、首次使用、日常工作流的中文速览。
>
> iSparto 采用双语策略:用户入口(双语 README + 中文 quick-start + CONTRIBUTING)平行维护;框架指令和参考文档单一英文来源,保证 AI 指令跟随的稳定性,同时让不懂中文的开源贡献者能参与审查。详情见 [CLAUDE.md > Documentation Language Convention](CLAUDE.md#documentation-language-convention)。

### 核心差异 — 克制,不是「更多 Agent」

现有的 AI 编程工具(Cursor、Windsurf、Copilot、单会话的 Claude Code)都是**你和一个 Agent 反复沟通**。Agent 读了你的 CLAUDE.md、看了你的代码、查了你的分支状态,把这一整套脑内画面组织好之后,倾向于在动手之前先把它全部说给你听。于是你的时间花在**给它的信息分类**,而不是做决定。

iSparto 的核心动作是**停止倾倒**。团队有角色——Lead、Teammate、Developer、Doc Engineer——但卖点不是「Agent 更多了」,而是 Lead 知道**在这一刻你真正需要听见的那一句话是什么**,其余的东西写到你需要时可以 grep 的文件里去。你拿到的是决策,不是一份卷宗。

|  | 单 Agent 工具 | iSparto |
|--|---|---|
| 你看到什么 | Agent 刚读到的所有事实,用散文复述一遍 | 你现在必须知道的那一句,其余留在 `docs/` 里 |
| 什么时候打断你 | 只要 Agent「有话想说」 | 只在真正需要决策的时刻 |
| 跨会话状态 | 会丢,每次都得重新解释上下文 | `/start-working` 从 `docs/plan.md` 自动恢复 |
| 文档同步 | 手动 | 每个 Wave 自动审计 |

### 适合谁用

想用 Claude Code 成倍提升产出的 macOS 独立开发者。需要 Claude Max 和 ChatGPT 订阅。

> **平台:仅支持 macOS。** 并行执行模式依赖 iTerm2 内置的 tmux 集成。单会话模式在其他平台上可能可用,但未经测试。

| 项目 | 要求 | 说明 |
|---|---|---|
| Claude Max 订阅 | $100/月 | 运行 Claude Code 以及 Lead / Teammate / Doc Engineer 角色 |
| ChatGPT 订阅 | $20/月 | 运行 Developer 角色所用的 Codex CLI |
| Node.js | 18+ | 运行 Claude Code、Codex CLI 和 MCP Server |
| Git | 任意版本 | 版本控制 |
| 终端 | iTerm2(macOS) | 并行执行模式用 iTerm2 内置 tmux,无需单独安装 |

**总成本:$120/月**,两个顶级模型,无额外 API 费用。

---

## 安装

**前置条件:** [Claude Max](https://claude.ai)($100/月)+ [ChatGPT Plus](https://chatgpt.com)($20/月)。iSparto 以 Claude Code 为运行时,以 Codex CLI 作为 Developer 角色。

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash
```

一行搞定:从 GitHub Releases 下载经过校验的安装器、检查/安装 Claude Code 和 Codex CLI、登录 Codex、复制命令和模板到 `~/.claude/`、注册全局 MCP Server。不会修改你现有的 `~/.claude/settings.json`。安装前会自动对原始文件拍快照,随时可以回滚。

**安装前先预览:**

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash -s -- --dry-run
```

**安装指定版本:**

```bash
curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash -s -- --version=0.6.18
```

**升级:**

```bash
~/.isparto/install.sh --upgrade
```

> 升级只更新框架组件(命令模板、文档模板、快照引擎)。你的项目文件(CLAUDE.md、docs/、代码、配置)不会被修改。

**卸载:** 从备份快照还原所有被修改的文件(离线可用):

```bash
~/.isparto/install.sh --uninstall
```

遇到问题?查看[问题排查](docs/troubleshooting.md)。

<details>
<summary>备选:手动 clone</summary>

```bash
git clone https://github.com/BinaryHB0916/iSparto.git
cd iSparto && ./install.sh              # 或: ./install.sh --dry-run
```
</details>

---

## 快速开始

### 初始化新项目

```bash
mkdir my-app && cd my-app
claude --effort max
/env-nogo                              # 可选,环境检查
/init-project 我要做一个xxx            # 生成 CLAUDE.md + docs/ + 架构预审
```

创建文件前会自动拍快照。如果出现问题,运行 `/restore` 即可回滚。

### 迁移已有项目

```bash
cd existing-project/
claude --effort max
/migrate --dry-run    # 预览迁移方案,不执行(首次建议先用这个)
/migrate              # 扫描项目,出迁移方案,保留所有现有内容
```

迁移前会自动拍快照。随时运行 `/restore` 可回滚。

### 每天的工作循环

```
/start-working
    → Lead 读 plan.md,告诉你当前状态和待办
    → 你确认「开始」
        ↓
团队自己跑,你不用盯着
    → 拆任务 → 写代码 → 跨角色审查 → 文档审计
        ↓
只在真正需要决策的时刻 Lead 才回来找你
        ↓
/end-working
    → 同步文档 → 更新 plan.md → commit → push
```

### 有新需求时

```
/plan 我想加一个xxx功能
    → Lead 先审视产品方向,出一个方案
    → 你确认方案后,Lead 把方案写入 plan.md 再开始
```

---

## 角色架构

<p align="center">
  <img src="assets/role-architecture-zh.svg" alt="角色架构" width="100%"/>
</p>

- Lead / Teammate / Doc Engineer:Claude 主会话(见[模型配置](docs/configuration.md#agent-model-configuration))
- Developer:Codex 通过 MCP(见[模型配置](docs/configuration.md#agent-model-configuration))
- 实时合规监督:三层安全防御 — Write/Edit 实时内容扫描、commit 前 secret/PII 扫描、里程碑全量审计 `/security-audit`。详见 [docs/security.md](docs/security.md)。

---

## 案例集

iSparto 自举开发——框架用自己的工作流开发自己。端到端的案例集合有单独的文件:见 [docs/case-studies.md](docs/case-studies.md),从 Session Log 自举案例开始——用工作流给自己搭出了「session 指标自动采集」功能。

## Dogfood Log

每个 Wave 跑完后的主观感受记录在 [docs/dogfood-log.md](docs/dogfood-log.md)——框架是否真的「更安静」、什么时候被打扰、打扰得值不值,都写在那里。它和本页上的克制叙事是「pitch + 证据」的关系。

## 仓库结构

完整的仓库目录树和每个文件的注释在 [docs/repo-structure.md](docs/repo-structure.md)。README 不再内嵌目录树,避免每次结构调整都把 README 搅动一次。

---

## 启动清单

**一次性安装(`./install.sh` 自动完成):**

- [ ] Claude Max + ChatGPT 订阅已开通
- [ ] 终端使用 iTerm2(macOS,并行分屏依赖)
- [ ] `./install.sh` 已执行(Claude Code、Codex CLI、配置文件、MCP)
- [ ] 多设备同步已配置(如有多台电脑,见 [configuration.md](docs/configuration.md#multi-device-sync-optional))

**每个新项目(`/init-project` 自动完成):**

- [ ] `claude --effort max` 启动
- [ ] `/env-nogo` 检查通过(可选)
- [ ] `/init-project` 已生成 CLAUDE.md + docs/
- [ ] 项目级 `.claude/settings.json` 配置平台相关插件(可选)

---

## 名字的由来

希腊神话里,英雄 Cadmus 杀了一条龙,把龙牙种进泥土。一支全副武装的战士从地里破土而出——他们被称为 **Spartoi**(Σπαρτοί),意为「播种而生的人」。

这和 iSparto 的工作流是同一个故事:你把产品需求「种」进 `/init-project`,一整支团队自动组建——Lead 拆任务、Developer 写代码、同一个 Wave 内完成审查与修复、Doc Engineer 同步文档——从一颗种子长出一支完整的团队。

**i** 从 Spartoi 末尾移到了最前面。小写的 i = I = 我,一个人。

**iSparto = I + Sparto = 一人成军。**

---

## License

[MIT](LICENSE)
