# Dogfood Log

这份文档记录 iSparto 自举开发过程中每个 Wave(或每个大 session)的**主观感受**。

它不是 benchmark,不追求量化 KPI,也不和任何外部工具做对比。它记录的是 Lead/Teammate/Developer 跑一整轮工作流下来,用户实际感觉到的「session 是否更安静」「什么时候被打扰」「打扰得值不值」「哪里还在倾倒 context」。这些东西不能用数字证明,只能用使用者一次次写下的主观印象沉淀出来——因此这份文档是 Tier 4 historical artifact,只加条目,不回头改。

README 负责 pitch——「一支会克制的 AI 开发团队」。这份文档负责 pitch 的证据链。两者合起来才是一个完整的主张:一边说我们是什么,一边把「我们跑一次真实工作是什么感觉」摊开给读者看。v0.7.6 之后,每个叙事 Wave 或每个重要 session 都可以在这里补一条 cycle 记录。

---

## Cycle #1 — v0.7.4 Principle 5 total-collapse 落地 → v0.7.5 README 克制叙事 Wave

**时间跨度**:2026-04-09 v0.7.4 发布当天的 Session #b(Principle 5 total-collapse polish)到 2026-04-09 晚的 v0.7.5 README 克制叙事 Wave。两件事紧挨着发生,因此 cycle #1 把它们当成一个完整的「克制落地到真实开发体感」观察点。

### v0.7.4 Principle 5 total-collapse 给 session 带来的第一手变化

v0.7.4 之前,Information Layering Policy 已经有 A/B/C 三层和 7 条原则,但 Lead 在运行时仍然要做「这条信息算 A 层还是 B 层」的动态判断,这个判断空间就是 facts-dumping 老毛病的残留接口。Principle 5 total-collapse 把这件事堵死:A 层入口被 Principle 1 的 5 条机械触发静态绑定,B 层入口被 Principle 2 的三个 pause point 静态绑定,C 层是默认兜底,Lead 没有运行时动态决定「层次」的第四条路,只在「同一个 pause point 的既定结构里,具体用什么词」这一层还有判断权。

落地那一刻的 session 体感:**Lead 在 `/start-working` 和 `/end-working` 以外的时间几乎不主动说话了**。Mid-session 进度汇报、「我刚做完 X」的叙述、「下面还剩 Y」的清单——这三件事 v0.7.4 之前经常出现,v0.7.4 之后几乎绝迹。原因不是 Lead 在「忍着不说」,而是 Policy 从入口侧就没给 mid-session 输出留任何合法的 layer:它既不匹配 A 层的 5 条机械触发,也不在 B 层的三个 pause point 上,于是自动落入 C 层的沉默。

### v0.7.5 Wave 本身的 session 体感

本 Wave 是第一个在「Policy 完全 total-collapse」状态下跑完的叙事 Wave。观察到的几件事:

**一、用户被打断的次数只有两次,且两次都是真的必须打断。** 一次是 `/plan` 第 3 步提出 proposal 要求用户批复——这是 Policy trigger type (a),机械触发,Lead 没有选择空间。一次是 IR Wave-start 审出的 CRITICAL A3 grep bug + MAJOR T6 source-of-truth 反向,需要用户在是否重跑 IR cycle 上拍板——这是 Policy trigger type (e) 的延伸,同样是机械触发。除此之外,Lead 在整个 plan 编写、branch guard、文件读取、IR spawn、10 次 plan 修订这些环节上全程沉默,用户只在最终要做决定的两个节点被叫到。

**二、B 层汇报确实只在三个 pause point 出现。** `/plan` 第 3 步的 proposal 是一次 B 层(结构是 B,其中请求确认的那一句是 A 层);`/start-working` 的开场汇报是一次 B 层;`/end-working` 的收场汇报还没跑到。整个过程没有出现「我要顺便告诉你一下 X」这种第四路 B 层。

**三、C 层的沉默是真的沉默,不是 Lead「假装」沉默。** Branch guard 自动切 feat/v075-readme-restraint、PreToolUse hook 逐次放行、Process Observer 后台 arm、`gh auth` 对齐检查、每次 Edit/Write 落地——这些全都是 C 层,用户从头到尾没看到一个字。需要时可以 grep `docs/session-log.md` 或 git log,但 session 进行中用户的眼睛不会被这些操作性事实占用。

**四、代价也看到了,不装。** Lead 在 Wave 内部沉默的副作用是:当用户没主动说话的一段时间里,用户并不知道 Lead 在做什么,只能信任它。这种信任在 v0.7.4 之前是 optional 的(因为 Lead 还会主动汇报进度),v0.7.4 之后变成 mandatory 的(Lead 不再主动汇报)。这一 cycle 这种信任是成立的——因为整个 Wave 在 main 上跑不动,必须切 feat 分支,所有变更都在分支上,回滚成本是「git checkout main」。但如果将来某个 Wave 涉及不可回滚的操作(release、数据迁移),这种「Lead 默默做事」的信任就会变紧。Policy 当前通过 trigger type (c) 的「不可逆操作」把这种情况强制升级到 A 层,这是正确的,但 cycle #1 还没遇到真的不可逆操作,所以这条保险没被实测。

**五、README 克制叙事和 Policy 落地是两码事。** Policy 让框架内部克制,Wave 内部跑完几乎无声。但如果读者从 GitHub 点进 README,看到的还是 281 行的功能罗列 + 工具对比 + 角色清单,读者无从知道这个框架的核心差异是克制——这就是 v0.7.5 Wave 本身要解决的 gap。Policy 改变的是框架行为,README 改变的是读者认知,两件事都要做,只做一件就是半成品。

### 下一个 cycle 留给自己的开放问题

- v0.7.5 README 发出去之后,收到的反馈里,「克制」这个词读者接住了吗?还是被当成「功能少」?
- Principle 5 total-collapse 在一个**不可逆操作的 Wave**(比如下一次 release 或大型重构)里是否还成立?Lead 默默做事的信任阈值在那里会不会撑不住,需要临时把某件事从 C 层升级到 A 层?
- dogfood-log 本身会不会变成另一种 facts-dumping?如果每个 cycle 都写 200 行,读者同样会淹死。下一个 cycle 把目标篇幅控制在 60-100 行试试。
- IR Wave-start 的 CRITICAL + MAJOR 连抓两条,是偶然还是 plan 阶段 Lead 自审的系统性漏洞?下一个 Wave 的 IR 结果会回答这个问题。
