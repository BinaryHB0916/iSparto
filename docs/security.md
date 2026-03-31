# iSparto 安全审计系统

## 三层防御

### Layer 1: Real-time Write Gate（PreToolUse hook 扩展）

每次 Write/Edit 工具写入内容时实时触发。

检查内容：
- 5 个 critical 级别 secret patterns（AWS Key、Anthropic Key、Private Key、Stripe Key、GitHub Token）
- 命中 → 阻止写入，提示使用环境变量或配置引用

配置：
- 规则定义：`security-patterns.json` 的 `realtime_critical` 字段
- 执行脚本：`pre-tool-check.sh`（现有脚本的扩展）

特点：
- 在 secret 写入文件之前就拦截（比 pre-commit 更早一步）
- 仅检查 critical 子集，确保 hook 性能不受影响

### Layer 2: Pre-commit Gate

每次 `/end-working` 执行 commit 前自动触发。

检查内容：
- 全量 Secret 扫描：所有 secrets 和 pii patterns（命中 critical/high → 阻断 commit）
- 敏感文件检测：.env、.pem、.key 等文件是否被 staged（命中 → 阻断）
- PII 检测：手机号、身份证号、银行卡号（命中 → 警告，不阻断）

配置：
- 规则定义：`~/.isparto/hooks/process-observer/rules/security-patterns.json`
- 扫描脚本：`~/.isparto/hooks/process-observer/scripts/pre-commit-security.sh`
- 白名单：项目根目录 `.secureignore`

### Layer 3: Milestone Audit

通过 `/security-audit` 命令在 Phase 完成或发布前手动触发。

覆盖范围：
- 全量文件扫描（不仅 staged）
- .gitignore 完整性对照基线
- Git 历史中的泄露痕迹（使用 `git log -G` 正则扫描）
- 依赖安全漏洞

### Wave-level Review（嵌入现有流程）

每个 Wave 的 Codex 代码审查和 Doc Engineer 文档审计中自动包含安全检查：

Codex 审查覆盖：
- 硬编码凭证
- 调试日志泄露敏感数据
- 可疑依赖

Doc Engineer 审计覆盖：
- 代码中的凭证
- .gitignore 完整性
- 文档中的真实凭证/个人信息
- 第三方依赖可信度

## 与 dangerous-operations.json 的关系

两套规则互补，不重叠：

| 规则集 | 拦截层 | 拦截目标 |
|-------|--------|---------|
| dangerous-operations.json | Bash 命令 | 阻止**执行** `git add .env`、`cat .env` 等命令 |
| security-patterns.json | 文件内容 | 阻止**写入/提交**含 secret 的代码内容 |

## 误报处理

在项目根目录创建 `.secureignore`，每行格式：

```
# file_path:pattern_id:reason
# file_path:reason  (matches all patterns for this file)
test/fixtures/mock-credentials.json:test fixtures with fake data
src/constants.ts:email-hardcoded:support email is intentionally hardcoded
```

Pre-commit scanner 在扫描前读取此文件，跳过匹配的 file:pattern 组合。

## 泄露应急流程

如果发现已泄露的凭证：
1. **立即 rotate**（更换）所有泄露的密钥/token
2. 用 `git filter-repo` 或 `BFG Repo-Cleaner` 从 git 历史中清除
3. Force push 到远程仓库
4. 通知所有协作者重新 clone
5. 记录到 docs/plan.md 的技术决策记录中
