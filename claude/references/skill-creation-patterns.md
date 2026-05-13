# Skill Creation Patterns

Case-by-case **templates and style preferences** for writing skill bodies. Unlike `skill-creation-principles.md` (must-follow discipline for the creation pipeline), patterns here are **judgment-applied**: adopt when fit, skip when not.

**How to use this file:** browse when writing a skill body for inspiration / proven shapes. Don't audit a finished skill against every pattern — patterns are not gates.

---

## What + Lens > Playbook (default style preference)

**Default to describing the observation angle and what's being aligned on, not a step-by-step procedure. Trust the runtime LLM to derive how from a clear what. Use procedure only when ordering is a hard dependency (e.g., shell setup scripts, multi-stage flows with strict sequence).**

When you write "first do X, then Y, finally Z", you compress the model's reasoning surface into a fixed path. The same task viewed through the same lens often warrants different sequences depending on input. Lens framing preserves model judgment; procedural framing replaces it.

Ask yourself: "If the runtime LLM phrased the same goal differently, would my procedure still apply?" If a small reframing breaks the procedure, it's overfit.

---

## Alignment Facet Template: 对齐 + Lens + 常见询问方向

**For "align with user before producing artifact" sub-sections, the three-element template `**对齐**: <what to align on>` + `**lens**: <observation angle>` + `**常见询问方向**（不限于此）: <example directions>` is a proven scaffold.**

The three elements separate concerns:
- 对齐 = the *output* (what the alignment yields)
- lens = the *observation angle* (how to spot what to ask)
- 常见询问方向 = optional anchors (what tends to come up, non-exhaustive)

Ask yourself: "If a future maintainer adds a 5th alignment facet to this skill, will the template carry them through, or will they need a different shape?" If different, this template doesn't fit this skill.

---

## Surface Knobs Explicitly, Don't Bury Them in Body Prose

**For skills with discrete decision points (boolean / enum / small int with a sensible default) that change skill behavior, prefer surfacing each knob — including type and default — in a position the user can see before submitting, separate from workflow prose. Frontmatter `argument-hint` complements but does not replace this.**

Knob vs alignment content — the lens is **who consumes this info, and why it belongs where it does**. Knobs are advertised options for the user, so they need to be discoverable *before* submission. Alignment content is interview fodder for the LLM, so it lives inside sub-sections where the LLM finds it during runtime alignment.

**Doesn't apply when**: the skill has no user-facing decision points (knobs are internal-only / hardcoded), or the knob's value always comes through a positional argument with no default to surface.

Ask yourself: "Does this skill expose decision points that a user might reasonably want to change between invocations?" If yes, the pattern fits — surface them. If the only "knobs" are internal toggles a user never sees or chooses, the pattern doesn't apply.

---

## Runtime-Discovered Dimensions over Fixed Lists

**When a skill produces an artifact organized by some set of "dimensions / categories / observation angles" (e.g., issue 维度, eval rubric, alignment facets), prefer letting the runtime LLM propose those dimensions based on the specific object at hand, then align with user via `AskUserQuestion` — rather than baking a fixed list into the skill body.**

A baked-in list (e.g., "always check 内容 / UI / 操作 for user testing"; "always score on accuracy / clarity / completeness for review") collapses the model's adaptive surface — different products / docs / domains have different failure modes that the authored list doesn't reach. The usual replacement is a lens sentence pointing at the generic default the model should break + 2–3 cross-domain reverse examples teaching the *axis of variation* (not a starter list).

**Doesn't apply when**: dimensions are contractually fixed (severity enums, external schema), the domain is narrow enough that dimensions are genuinely universal, or the downstream consumer needs a stable enum to dispatch on.

Ask yourself: "If I replaced the pre-baked list with the lens + reverse examples, would a SOTA model still produce reasonable dimensions for an arbitrary new object in this skill's scope?" Yes → the list was overfitting; No → dimensions might be contractual; keep but document why.

---

## Per-Actor Facets, Cross-Actor Contracts

**For skills that span multiple actors (e.g., 主 session 对齐 → subagent 执行 → 主 session handoff), prefer facets-style sections inside each actor's scope and contract-style sections at each cross-actor handoff boundary.**

A single "## 工作流 + ### 1 / ### 2 / ### 3" structure with cross-step references ("从第 1 步提炼") collapses the LLM's flexibility *inside* an actor's scope — it stops feeling licensed to retreat, reorder, or reframe even when later evidence demands it. Flattening everything to facets goes too far the other way — the moment a downstream actor (subagent / external executor) depends on upstream output, the missing sequencing makes the handoff contract ambiguous (what input is guaranteed when the next actor runs?).

The pattern keeps both:

- **Inside one actor's scope** — facets-style with an explicit banner ("不是顺序步骤，可并行 / 迭代 / 回退"). Each facet is its own subsection and follows the alignment template (lens + 询问方向). This licenses the LLM to discover mid-alignment that the previous facet was wrong and go back.
- **At a cross-actor boundary** — a dedicated contract section (e.g., "Handoff") that enumerates what the next actor needs. Express sequentiality through content dependency — open with a causal phrase like "上游 X 充分后 spawn 下游 Y", and let the contract bullets carry the inputs in hand.
- **Role-splits section** — describe roles in coarse noun phrases ("主 session = 对齐 + 派发 + handoff"); verb-ordered phrasing here leaks sequence semantics that compete with the banner.

**Doesn't apply when**: the skill has a single actor (then full facets, e.g., `create-plan.md`), or every phase is genuinely sequential with no actor reordering freedom (install scripts, migrations), or the skill is small enough that the structure is overhead.

Ask yourself: "Does my skill have a real cross-actor handoff — i.e., does any downstream section depend on upstream output?" If not, full facets suffice.

---

## Lens-Guided Artifact Schema

**When defining the schema for an artifact a skill produces, prefer specifying it as questions the consumer must be able to answer rather than a fixed field list — keeping a small mandatory core for fields the downstream literally cannot work without.**

A lens (e.g., "every issue must let the coding agent answer: what broke? what was expected and why is it a problem? how to reproduce? what evidence?") tells the producer the information to convey and leaves the form to runtime. Different issue / observation types need different evidence shapes (screenshot vs recording vs log vs API response) — hardcoding "screenshot field" forces ill-fitting form. Strict schema is reserved for the few fields the downstream literally cannot work without.

Three layers, in order of strictness:

- **Lens questions** — "consumer must be able to answer X / Y / Z"; producer is compliant by giving information that answers each question, with form left flexible (no required field names).
- **Mandatory contract** — fields the downstream truly needs as strict schema or enum. Examples: severity enum for cross-issue aggregation, mandatory citation of expected source so the consumer can judge "is this a real problem".
- **Optional augmentation** — permissive list of "useful when applicable" fields (titles, classification tags, fix hints, user-reaction snippets, etc.), explicitly non-exhaustive.

边界判断: a field belongs in **mandatory contract** only when downstream consumption breaks if producers express it differently — severity enum needs to aggregate / sort across producers, so each producer choosing its own "high / critical / 重要" would shatter the consumer's grouping; mandatory citation is the only signal that lets the consumer judge whether the issue is real. All other fields default to **lens-guided**.

**Doesn't apply when**: the artifact must conform to an external strict schema (JSON Schema / OpenAPI / fixed enum the consumer dispatches on), or it's a single-producer / single-consumer artifact with no aggregation or judgment step downstream.

Ask yourself: "If I deleted a field from the schema but kept the lens question that motivates it, would a SOTA producer still give the consumer what they need?" Yes → the field was over-constraining form; No → it's contractual, keep it.
