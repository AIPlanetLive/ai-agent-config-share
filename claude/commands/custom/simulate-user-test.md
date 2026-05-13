---
description: 模拟真实用户试用产品（web / desktop / mobile / 任何可被 agent 访问的产品），发现影响真实使用的体验问题，输出可被 coding agent 直接吃下的 issue 清单。触发：用户说"模拟用户测试产品 / 网站 / app"、"用户视角检查 X"、"上线前走一遍 UX"、"simulate user test"、"pre-launch UX check"。
disable-model-invocation: true
---

# simulate-user-test

在真实人类用户使用之前，用 AI 模拟用户跑一遍产品，把发现的问题做成可交付给 coding agent 的 issue 清单。

## 输入

- 目标产品访问入口（必需）：URL / app 启动方式 / instance 路径等任意可被 agent 访问的形式；服务/进程需已运行
- 预期功能信息源（必需）：README / PRD / VISION / 设计文档路径，或用户当场描述

## 角色分工

- **主 session**：对齐 + 派发 subagent + 读报告 handoff
- **Subagent**：实际使用产品、记录观察、采集证据、写自己负责的 issues 文件

产出对象是 coding agent，不是给人读的体验报告——主观感受语言剔，结构化字段留。

## 主 session 内部对齐（不是顺序步骤）

**通用 lens**："为了不让 subagent 走偏，我现在缺哪些只能用户回答的信息？"

以下是要对齐的几类——**不强制顺序，可并行 / 迭代 / 回退**。任一对齐暴露上层缺失（理解错了产品类型、persona 假设崩了）就回去补。展示与提问风格遵循 `~/.claude/references/deep-discuss-style.md`。

### 理解预期

**lens**："用户的产品预期是什么？文档承诺与实际产品之间是否已存在偏离？"

读输入的功能源文档；必要时用对应工具（agent-browser / computer use / 产品原生接入）访问足以判断产品类型的少量入口建立直观。向用户简述提炼后的预期并对齐理解。

### 观察维度

每条带一句说明该维度在本产品中为何关键。

**lens**："大部分用户使用这个产品的主要方式有哪些？哪些产品独有、可能被通用 UX 评测模板覆盖不到的失败模式？"

**常见思考方向（不限于此）**：

- AIGC 产品：输出质量与失败模式可解释性
- Onboarding-heavy 产品：首次摩擦与价值传达
- 数据可视化产品：钻取路径与数据一致性

数量以"覆盖你能预期的失败模式 + subagent 能在产出 issue 时收敛到具体维度"为准。

### Persona

每条含角色 / 预期 / 主要任务，覆盖预期会有的主要用户类型。

**非显然约束**：必须包含至少一个"第一次访问者"——模型默认会偏向 power-user / maintainer 视角，需显式纠偏；首次访问者会被困住的地方，回访者通常已经习惯了看不见。

---

## Subagent 简报契约

主 session 对齐充分后 spawn general-purpose subagent 执行测试。**多 subagent 并行时主 session 给每个 subagent 分配唯一 slug**（如 persona name 或编号），避免输出文件冲突。简报必含：

- 产品访问入口 + 提炼后的预期功能摘要
- 该 subagent 负责的 persona（单 subagent 时可为完整 persona 列表，多 subagent 时为分到的子集）
- 已对齐的观察维度列表
- 产出落点：`plans/<product-slug>-user-test-<YYYY-MM-DD>/`；该 subagent 写到 `<subagent-slug>-issues.md`；证据存到该目录下的 `evidence/` 子目录
- 工具：根据产品类型选择（agent-browser / computer use / 产品原生接入），用法见对应工具文档或 ~/.claude/CLAUDE.md
- 每个 persona 按对齐后的所有维度扫一遍
- 覆盖产品支持的所有交付形态（web 的桌面+移动响应、desktop app 的所支持 OS、mobile app 的 iOS/Android 等——按产品实际范围）
- 行为约束：**像真实用户使用产品，不是跑 QA checklist**。遇到困惑 / 不顺 / 异常时记录 issue；不要预设清单挨个验证打勾。
- 附文末"反模式"段到简报

以上是下游开展测试所需的最小集——主 session 可按具体情况补充其他上下文（产品类型摘要、特殊关注点、已知 limitation 等）。

## Handoff

所有 subagent 完成后，读产出目录下所有 `<subagent-slug>-issues.md`，主 session 对每条 issue 做合理性判断，不确定的整理为 `AskUserQuestion` 让用户决策。向用户汇总保留下来的 issues，附完整文件路径。

## issue 字段契约（subagent 必须遵守）

每条 issue 要让 coding agent 能回答下列问题——给出能回答的信息即合规，形式不强求字段名一致：

- **什么坏了？** 实际观察到的现象
- **应该是什么？为什么这是问题？** 必须引用预期功能源（文档段落或对齐时的口头预期摘要）——不引用预期源 = 不知道要不要修
- **在哪里？** 产品里的位置（URL / 屏幕 / 元素 / 调用路径 等，让 coding agent 能定位）
- **怎么复现？** 从入口的最短路径
- **有什么证据？** 按需附（截图 / 录屏 / 日志 / 输入输出 / API 响应 等），选能最直接证明问题的形式，存到产出目录下的 `evidence/` 子目录
- **严重度**：Critical / High / Medium / Low
  - Critical = 阻塞核心使用
  - High = 严重影响体验或内容错误
  - Medium = 明显但有 workaround
  - Low = 抛光级

**可补充字段**（按对 coding agent 消费有用为准，非穷举）：标题、归类标签（如对齐后的观察维度）等。

**不写**：作者主观感受、未引用预期文档的功能增强建议、与预期无关的吹毛求疵。

## 反模式

- **QA checklist 模式**：跑完功能点核查表但没真用过产品 → 漏掉 UX 痛点
- **没引用预期**：标问题但不说为何是问题，coding agent 无法判断要不要修
- **漏交付形态**：只测一个平台/形态，错过产品在其他形态下的破损（web 桌面 OK 但移动炸 / desktop app macOS work 但 Windows 出 bug 等）
