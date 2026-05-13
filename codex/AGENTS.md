# User-Level AGENTS.md

## Long-Task Protocol (BINDING)

当你正在实施的 plan.md 顶部有 `Long-task mode` banner 时，遵循 `~/.claude/references/long-task-protocol.md` 规定的协议（读写同目录的 state.md / journal.md、交付前必须执行所有规划的 verify 步骤）。protocol 是 source of truth；本段不重述其规则，避免 drift。

注：banner 与 state.md / journal.md 通常由 Claude Code 的 `/create-plan --long-task` 创建。本协议只规定执行端的行为——任何看到 banner 的 agent 都应遵守，不限工具。

## Plan Execution Principles (BINDING)

执行任何 plan 时遵循 `~/.claude/references/plan-execution-principles.md`。以任何理由不继续执行 plan，都算 stop。Stop 前必须先通过该文件的 stop gate。

以任何理由结束当前 plan 执行的 final response，都算 stop。状态汇报后不继续执行，也算 stop。

### Stop Gate（停止前必须逐项通过）

Stop 前必须逐项满足：

1. **必要性已证明**：已排除排队等待、应用层问题、适配层问题；不能确认时 default-to-continue（自己继续等，**同时发一条消息让用户看到当前归因状态 + 触发 stop 的条件**）。
2. **归因已分层**：已检查应用层 / 适配层 / 外部服务层 / 人工层（**人工层 ≠ Web UI；先试 browser automation / DevTools / Computer Use**）；只有观察过第三方原始响应、standalone probe、状态页、日志或工单，才能归因为外部失败。
3. **替代路径已尝试**：已尝试可用的 API / DB / CLI / DevTools / browser / local script / mock / direct probe 等 executor 能独立使用的路径。
4. **verify 已拆分**：已把 executor 能独立验证的子部分做完；剩余部分确实必须用户介入或依赖不可用能力。
5. **交接可执行**：final response 明确为什么停、阻塞哪一步、已覆盖什么、用户需要做什么；用户不需要追问或自行研究即可执行。

任一项不满足，不得 stop；应继续排查、拆分 verify，或用 commentary 发状态更新后继续执行。
