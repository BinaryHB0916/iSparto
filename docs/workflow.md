# 完整开发流程

## Phase 0：产品初始化

```
用户描述产品需求
    ↓
Claude 生成 product-spec.md + tech-spec.md + design-spec.md（在 CLAUDE.md 和 docs/ 中）
    ↓
用户审视产品方向：
  - 这真的是用户需要的吗？
  - 有没有更好的解法藏在需求背后？
  - 10 分版本长什么样？
    ↓
Codex 5.3 review 技术架构（Lead 通过 MCP 调用，xhigh + fast，基于 tech-spec.md）：
  - 架构合理性、扩展性
  - 数据流和状态管理
  - 潜在的性能瓶颈和安全问题
  - 技术选型是否匹配需求
    ↓
用户确认 → 进入 Wave 开发
```

## Phase 1-N：Wave 并行开发

```
Lead 读取 plan.md，确认当前 Wave
    ↓
Lead 拆任务：定义文件所有权 + 接口契约
    ↓
Claude Developer(s) 并行开发
  - 按文件所有权范围写代码
  - 为核心逻辑编写单元测试
  - 确保构建通过
    ↓
Codex Reviewer 审查（按触发条件表判断是否执行，见下方）
  - 审查代码逻辑、边界条件、安全问题
  - 发现问题直接修复
    ↓
Claude Developer 回看 Codex 的修复（如触发了审查）
  - 确认修复正确
  - 确认没有引入新问题
  - 确认符合项目代码风格
  - 构建验证
    ↓
Codex QA 冒烟测试（按触发条件表判断是否执行，见下方）
  - 识别本 Wave 的变更范围，只测变更涉及的功能路径
  - 已在之前 Wave 测过且未被本次改动影响的部分跳过
  - 模拟关键用户操作路径，验证功能端到端可用
  - 发现问题记录并直接修复（同代码审查流程）
    ↓
Lead spawn Doc Engineer（sub-agent）做文档审计（放在最后，确保 QA 修复后的代码也被审计）
  - 代码 vs product-spec.md 一致性
  - 代码 vs tech-spec.md 一致性
  - plan.md 任务状态更新
  - design-spec.md vs 实际样式一致性
  - CLAUDE.md 模块边界是否需要更新
    ↓
Lead 确认全部通过 → 合代码 → 更新 plan.md
```

## Codex 审查触发条件

| 场景 | 代码审查 | QA 冒烟测试 |
|------|---------|------------|
| 数据同步、支付、认证等高风险代码 | 必须 | 必须 |
| 新增 API 接口或数据模型 | 必须 | 必须 |
| 纯 UI 调整、文案修改 | 不需要 | 建议（验证显示正常） |
| Developer 自测通过但涉及多文件改动 | 建议 | 必须 |
| 小型 bug 修复（单文件、逻辑简单） | 不需要 | 不需要 |

---

## 自定义命令（commands/）

> 命令的完整内容见 `commands/` 目录下的源文件，以下是各命令的职责摘要。

| 命令 | 源文件 | 执行角色 | 职责 |
|------|--------|----------|------|
| `/start-working` | [commands/start-working.md](../commands/start-working.md) | Team Lead | 汇报当前状态（Wave 进度、遗留问题），等用户确认后启动团队 |
| `/end-working` | [commands/end-working.md](../commands/end-working.md) | Team Lead | 确保所有改动和决策落库，更新 plan.md，commit & push |
| `/plan` | [commands/plan.md](../commands/plan.md) | Team Lead | 审视产品方向，输出实现方案（含解耦分析），等用户确认后写入 plan.md |
| `/init-project` | [commands/init-project.md](../commands/init-project.md) | Team Lead | 生成项目骨架和文档体系（CLAUDE.md + docs/），Codex 架构审视，为 Wave 开发做准备 |
| `/env-nogo` | [commands/env-nogo.md](../commands/env-nogo.md) | Team Lead | 检查全局和项目环境是否满足 iSparto 运行条件 |

---

## 分支策略

```
main              ← 稳定版，发布从这里出
  └── feat/xxx    ← 新功能开发，完成后 merge 回 main
  └── fix/xxx     ← 一般 bug 修复，完成后 merge 回 main
  └── hotfix/xxx  ← 线上紧急修复，从 main 拉出，修完 merge 回 main
  └── release/x.x ← 发布准备分支（如需要）
```

**规则：**
- main 不直接开发，锁定为当前发布版本
- 每个 Wave 对应一个 feature 分支（如 `feat/wave-1-auth`）
- Wave 内部，Lead 将任务拆成解耦的子任务，每个 Developer 通过 git worktree 在独立工作目录中并行开发（由 Claude Code Agent Team 自动管理，无需手动操作），靠文件所有权杜绝冲突
- 小修小补可在 fix/ 分支上快速合回
- merge 回 main 前必须通过 Doc Engineer 审计；Codex 代码审查和 QA 冒烟测试按触发条件表执行（不是每次都触发）

**Hotfix 流程：**
- 从 main 拉 hotfix/xxx 分支
- 走完整 Lead → Developer → Codex 审查 → Developer 回看 → Codex QA → Doc Engineer 流程
- 不设简化版——Agent Team 全流程是分钟级，不存在人类团队的等人瓶颈
- 触发条件表自动适配：单文件简单修复不触发代码审查和 QA，高风险修复全量触发
- 修完 merge 回 main，如有进行中的 feat/ 分支需要同步 hotfix 改动

---

## Codex 5.3 集成

> Codex 的角色定义和三套 prompt 模板见 [roles.md → Codex Reviewer](roles.md#codex-reviewermcp-调用)。

Codex 在三个场景介入，统一配置 xhigh reasoning + fast mode：

| 场景 | 时机 | 详见 |
|------|------|------|
| A. 架构前置审视 | Phase 0，产品初始化后、开发前 | roles.md → Codex Reviewer → 架构前置审视 prompt 模板 |
| B. 代码审查 + 修复 | Phase 1-N，Developer 完成后 | roles.md → Codex Reviewer → 代码审查 prompt 模板 |
| C. QA 冒烟测试 | Phase 1-N，Developer 回看通过后 | roles.md → Codex Reviewer → QA 冒烟测试 prompt 模板 |
