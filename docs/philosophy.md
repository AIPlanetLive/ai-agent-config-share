# Philosophy

这份 repo 不是一份 slash command 清单。命令是表面，背后是一套关于**人和 Agent 该如何协作**的设计立场。

如果你只想知道 "什么命令做什么、什么时候用"，请看 [README.md](../README.md) 和 [command-guide.md](command-guide.md) — 它们是入门手册，足够把你带过日常工作流。

但如果你想理解这些命令**为什么长成现在这个样子**、自己写新命令时该遵守什么心法、为什么我们在某些地方和社区主流 plan/execute skill 长得不一样，可以继续阅读本文档。

---

## 1. 人机交互协议是 Agent Harness 的核心设计点

Agent 越强，它能自主完成的工作越多。但只要它还没强到可以替你做产品决策、替你拍板架构方向，那么**你和它之间的交互协议**就是整个系统的瓶颈。

具体说，每一次 Agent 把活推回给你 / 把成果交给你 / 在中途和你对话，都在消耗你的注意力预算。这套交互怎么设计 — 不是"先把命令写出来再说"，而是要先在三个维度上做出明确取舍：

1. **Agent 什么时候停下来问你，什么时候自己往下走？**
2. **Agent 交付的成果里，哪一部分是给你审核的契约？哪一部分是它自己负责的内部细节？**
3. **Agent 用什么形式和你交互？** 看板？群消息？1-1 对话？

把市面上各类 agent harness / skill 摊开看，**它们的设计取舍基本都可以拆到这三个维度上**。本文剩下的内容就在这三个维度上展开 — 既说明这个 repo 选了什么，也说明为什么这么选。

---

### 维度一：Agent 停下来询问用户的原则是什么

这里有一个天然的 tradeoff：

- 问得太多 → 慢。每次打断你的注意力都是成本。
- 该问的时候不问 → 也慢。你后来发现 Agent 走偏了，返工的代价远高于当初问你一句。

现在的 LLM 还做不好这个判断 — 默认偏自主、偏前进、偏 "先做再说"。所以**我们不能指望 Agent 自己悟，必须通过 harness 显式给规则**。

我们的做法是**把工作流显式拆成 plan 和 execute 两个阶段**，两个阶段的判断规则**反向**配置：

| 阶段 | 默认姿态 | 我们的规则文件 |
|---|---|---|
| Plan | **遇到取舍就问**。reversal cost 高的决策、信息不足的取舍，全部摆到台面上让用户选。 | [deep-discuss-style.md](../claude/references/deep-discuss-style.md) |
| Execute | **非必要不停**。Plan 已经定好的方向，executor 自己走完；任何想 stop 的念头都要先过一道 gate。 | [plan-execution-principles.md](../claude/references/plan-execution-principles.md) |

这里有两点和社区主流 plan / execute skill 的差别值得展开讲：

**1. 我们的 plan 文档重点不是"怎么规划"，而是"取舍出现时怎么问"。**

很多 plan skill 长这样：先做需求分析、再做架构设计、再做模块拆分、再做风险评估 — 一套**流程**。我们认为流程是结果，不是手段：plan 写得好不好，不取决于你跑没跑完几步，而取决于你**有没有把所有 reversal cost 高的取舍摆到用户面前让他做选择**。所以 [deep-discuss-style.md](../claude/references/deep-discuss-style.md) 几乎不讲流程，它讲的是 "如何用 AskUserQuestion、每个选项要附 pros/cons、推荐项要标出来、不要在 inline prose 里把决定偷偷做掉"。

**2. 我们的 execute 文档重点不是"怎么执行"，而是"什么时候才允许停"。**

很多 execute skill 把重点放在 "按顺序跑、跑完报告、有错就汇报"。我们认为这种风格的最大失败模式不是 Agent 跑错，是 Agent **过早把活推回给人**。所以 [plan-execution-principles.md](../claude/references/plan-execution-principles.md) 的核心是一个 Stop Gate — 任何想中断的念头都要先过 5 道关：必要性、归因分层、替代路径、verify 拆分、交接可执行性。没过完，default-to-continue。

> 一句话总结：**我们不是在规定 Agent 怎么走，而是在规定它什么时候允许停下来**。这是 harness 的本职工作。

---

### 维度二：Agent 给人的交付契约是什么

这本质是个 API 设计问题。

- 契约太细：审核人需要懂实现细节，技能门槛和时间成本都高。
- 契约太粗：Agent 不理解你的意图，或者遗漏关键检查点，最后返工。

更难的是 — **这是个动态的契约**。LLM 越强，人的检查点会自然往上层移动。过去你需要审 plan 里的架构选型（你扮演架构师），将来你可能只审产品功能（你扮演产品经理），假设 Agent 自己给的架构 "够用"。

我们的回答是：**契约的最稳定锚点是 verify 步骤** — 也就是"什么条件下这个东西算交付完成"。

具体落在 repo 里就是一组明确的责任划分：

| 命令 | 给人的契约是什么 | 人审什么 | Agent 负责什么 |
|---|---|---|---|
| [`/custom:create-spec`](../claude/commands/custom/create-spec.md) | `spec.md` 中的 **L2 用户视角 verify** | 这套 verify 步骤能不能覆盖我作为终端用户的真实诉求 | spec 写得对、review-spec 循环跑到收敛 |
| [`/custom:create-plan`](../claude/commands/custom/create-plan.md) | `plan.md` 中的 verify 步骤 | 重点看 L3 verify 步骤能否覆盖 spec verify | plan 写得对、review-plan 循环跑到收敛、L3 设计自洽 |
| 执行阶段 | 所有 verify 步骤通过 | （通常不再介入，除非 Stop Gate 触发） | 端到端把 verify 全部跑绿 |

注意这条链路：**spec 的 verify 是上游契约，plan 的 verify 必须覆盖 spec 的 verify，execute 必须把 plan 的 verify 跑通**。每一层有自己的内部细节（spec 不讲 L3、plan 讲 L3 但用户可以只看 verify），但 verify 这一条线**贯穿三层不变** — 这就是契约。

和社区主流 plan skill 的差别：

- 多数 plan skill 把 verify 留给 implementer 自己写 unit test，**没有显式的"用户视角 verify"层**。结果就是：Agent 写的 unit test 全绿，但产品打开后用户觉得不对 — 因为 Agent 根本没拿到"用户怎么验收"的契约。


---

### 维度三：Agent 和人的交互UX是什么

传统协作里我们有三种典型形式：**看板**（发布任务、追踪进度）、**群消息**（多人观察、并发讨论）、**1-1 对话**（深入交流单一议题）。这三种在和 Agent 协作时同样适用，只是工具形态不同。

目前这个 repo 主要用 **1-1 对话** 风格 — 通过 `AskUserQuestion` 给你一组带 pros/cons 和推荐项的选项让你选，深入但同步阻塞。

后续会进一步探索基于看板和群消息的交互模式。

---

## 2. 对人的能力要求

人在产品端到端生命周期中的角色在上层移动，更多的是做选择而非设计或实现：

- 大部分时候，你的工作是**做选择题** — 在 Agent 给的几个方案中挑一个，基于它列出的 pros/cons 和推荐项。
- 少数时候，你给的是**思路** — 不是具体方案，而是"该往哪个方向找"、"该用什么思路验证"。
- 极少时候，你才需要**自己给方案** — 通常是 Agent 的能力边界外、或者一个高度专属的领域判断。

这意味着你的能力配置需要相应调整：

- ✅ **架构思路**：怎么判断参数选择？怎么找候选算法？怎么估算复杂度量级？— 你不需要会实现，但要能判断 Agent 给的方案靠不靠谱。
- ✅ **基于实验反馈的开发思路**：怎么实现 vs. 怎么测试 vs. 怎么 verify？你需要懂"如何让 Agent 给你证据"，而不是相信 Agent 的口头汇报。
- ✅ **对 LLM 能力边界的认知**：什么任务适合让 LLM 直接做？什么任务该让 LLM 当 judge（llm-as-judge）？什么任务 LLM 还不行需要 hard-code？这是新的工程素养。
- ❌ **实现细节**：哪个参数选什么值、哪个 API 怎么调、算法内部怎么写 — 这些可以越来越多的交给 Agent，越来越少能作为人的核心价值。

---

## 3. 需要 "skill编译器" 来迭代skill

写一个好 skill 需要遵守的原则不少 — 信任 LLM 的 inference-time 泛化能力、用 lens 而不是流程、不要 speculatively 加内容、加之前先做 delete-test……（完整列表见 [skill-creation-principles.md](../claude/references/skill-creation-principles.md), [skill-creation-patterns.md](../claude/references/skill-creation-patterns.md) 和 [skill-review-principles.md](../claude/references/skill-review-principles.md)

但**指望每个 skill 作者把这堆原则内化清楚再写，是不 scale 的**。原则越多，作者犯错的方式也越多。

所以我们的回答是：**把"怎么写 skill"做成 编译器 和 skill**。

- [`/custom:create-skill-from-workflow`](../claude/commands/custom/create-skill-from-workflow.md) — 把刚刚跑通的工作流编译成可复用 skill
- [`/custom:review-skill`](../claude/commands/custom/review-skill.md) — 按 skill-review-principles 审查现有 skill
- [`/custom:fix-skill-from-session`](../claude/commands/custom/fix-skill-from-session.md) — 当 skill 在 session 中行为不对时，反向定位修复

---
