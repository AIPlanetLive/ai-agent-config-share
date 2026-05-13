# Plan Creation Patterns

写 plan body 时的 case-by-case **风格与结构偏好**。不同于 `plan-review-principles.md`（任何 plan 必须过的 gate），本文件的 pattern 是 **judgment-applied**：合适就用，不合适就跳过。

**如何使用本文件**：写 plan body 时 browse 找灵感 / 已验证的写法。不要拿一份写完的 plan 对每个 pattern 逐条审计 —— pattern 不是 gate，`plan-review-principles.md` 才是权威 reviewer 接口。

---

## 引用索引：多处共用的外部引用，文末汇总一次

**当外部引用（SKILL / 配置文件 / 现有代码 / 外部文档）出现在 plan 的多个 section 时，在文末给一份汇总索引表（路径 + 一句话用途），保留各 section 内的 inline 提及。** 让 implementer 不用反复翻回去问 "刚才那个路径是哪段提到的？"

Ask yourself: "implementer 读 plan 时，是否会从多个 section 查同一个引用？" 若是，索引就值得放。

---

## AIGC 人工反馈：离散优先于数字打分

**当 plan 需要用户对 AIGC 生成内容做质量反馈时，默认让用户输出离散判断（选择 / 二分 / 排序前 1-2 / 失败原因勾选）；user-facing verify 写成 "用户选 / 判通过 / 指原因"，agent 据此总结。**

考虑用数字打分的条件之一：用户明确要求 / 样本极少且每档有清晰 anchor / 评分者是训练过的评审 / 数字分仅辅助。即便 numeric 也用 2-3 档配 anchor，只对 shortlist 评分。

Ask yourself: "我让用户输出的形态，他能稳定 / 准确 / 高效地做吗？"

---

## AIGC 反馈形态库：A/B / Pass-Fail / Reason Checklist / Pairwise

**几种常见的 AIGC 反馈形态，写 verify section 时可参考；不限于此，按场景自选：**

- **A/B 或多候选选择**：适合同 prompt 下比多版本 —— "哪个更好？" / "哪个达到上线标准？"
- **Pass / Fail Gate**：适合上线验收 / 是否明显退化
- **Failure Reason Checklist**：适合 fail 后定位迭代 —— 3-6 个原因勾选 + 可选自由文本
- **Pairwise Tournament**：适合候选多 + 需偏好排序 —— 两两 A/B，agent 汇总胜出项

Ask yourself: "我设计的反馈形态匹配当前任务吗？这几个常见形态有可借鉴的角度吗？"
