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
Codex Reviewer 审查（Lead 通过 MCP 调用，xhigh + fast）
  - 审查代码逻辑、边界条件、安全问题
  - 发现问题直接修复
    ↓
Claude Developer 回看 Codex 的修复
  - 确认修复正确
  - 确认没有引入新问题
  - 确认符合项目代码风格
  - 构建验证
    ↓
Codex QA 冒烟测试（Lead 通过 MCP 调用，xhigh + fast，增量）
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

### 1. start-working.md

```
开工流程：

1. 读取 docs/plan.md，确认：
   - 当前处于哪个 Wave
   - 本 Wave 有哪些 Team，各自状态（待开始 / 进行中 / 已完成）
   - 上次收工后的遗留问题
2. 快速检查：代码当前状态与 docs/ 文档是否一致，有无漂移
3. 确认当前分支（应在 feat/ 或 fix/ 或 hotfix/ 分支上，不在 main 上开发）
4. 判断接下来的工作模式：
   - 如果当前 Wave 有可并行的 Team → 建议启动 Agent Team
   - 如果是单任务或需要人工决策 → 走普通开发模式
5. 输出以上信息，等我确认后再开始，不要写任何代码
```

### 2. end-working.md

```
收工流程：

1. 检查本次所有改动和决策：
   - 代码改动是否与 docs/ 文档一致？不一致则更新文档
   - 对话中的口头决策是否已写入对应文档？
2. 更新 docs/plan.md：
   - 标记完成的任务
   - 如果当前 Wave 的所有 Team 都完成，标记 Wave 状态为已完成
   - 列出下次待办
   - 记录遗留问题和人工介入点
3. git add -A && git commit
4. git push

执行前先让我确认 commit message。
```

### 3. plan.md

```
针对我接下来描述的需求：

1. 先审视产品方向：
   - 这真的是用户需要的吗？
   - 有没有更好的解法藏在需求背后？
   - 10 分版本长什么样？
2. 读取相关的 docs/ 文档获取上下文
3. 输出实现方案：
   - 要改哪些文件、怎么改、有什么风险
   - 解耦分析：哪些任务之间没有文件重叠和数据依赖，可以并行？哪些必须顺序执行？
   - 如果可以并行，列出文件所有权划分（确保不重叠）
   - 如果并行任务之间有数据交互，定义接口契约
   - 是否需要 Codex 前置架构审视
   - 是否涉及高风险代码需要 Codex 审查
4. 等我确认方案后，先把方案追加到 docs/plan.md，再开始写代码
```

### 4. init-project.md

```
基于 ~/.claude/CLAUDE-TEMPLATE.md 模板初始化新项目：

1. 填写项目信息、确定技术栈和目标平台
2. 整理文档到 docs/（product-spec.md、tech-spec.md、design-spec.md 等）
3. 生成初始 docs/plan.md，按 Wave 组织开发计划
4. 初始化 git 仓库，创建 main 分支
5. 在 CLAUDE.md 中包含协作模式、模块边界、分支策略
6. 调用 Codex MCP 做架构前置审视（基于 tech-spec.md），将结果反馈给用户确认
```

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
- Wave 内部，Lead 将任务拆成解耦的子任务，每个 Developer 通过 git worktree 在独立工作目录中并行开发，靠文件所有权杜绝冲突
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
