# Skill Review Principles

Behavioral guidelines for reviewing skills — covering triggering, structure, instruction style, and scope. Applies equally to new skills pre-merge and existing skills under periodic audit.

**Tradeoff:** These guidelines bias toward skills with sharper triggers, leaner bodies, and narrower scope. For trivial wrappers or shims over a single command, use judgment.

**These guidelines are working if:** skills trigger when they should and stay silent when they shouldn't; SKILL.md bodies stay readable; authors explain why, not just how; scope matches the stated purpose without accumulated cruft; every section is actionable by the actor chain.

**Loop:** For each skill (or each section, for large skills), check 1–8 in order. Loop until no principle is violated.

---

## 1. Description = Trigger

**The description is the only skill text always in context. Judge it as a trigger, not a summary: it must state WHAT the skill does AND WHEN to invoke it, both concretely.**

Claude decides whether to consult a skill from its description alone — nothing else loads until the skill triggers. A description that reads like a clean summary but lacks concrete trigger cues is broken, even if everything it says is true.

When reviewing:
- Restate the description as "this triggers when…". If you can't finish that sentence concretely, the WHEN is missing.
- Imagine near-miss queries (shared keywords, different intent). Flag if the description would over-trigger on them.
- Imagine realistic user phrasings that should trigger. Flag if the description would miss them.
- Flag descriptions that only restate the name or re-assert genericity ("Skill for X. Use when X comes up").
- Flag description content that doesn't help decide whether to trigger — tool choices ("use AskUserQuestion"), style references ("per deep-discuss-style.md"), workflow steps. Behavioral instructions belong in body. Description = trigger only.

The test: you can write a one-sentence "triggers when the user [concrete context] and does [concrete thing]" without opening the body.

---

## 2. Demand Contracts for External Interfaces

**When a skill depends on or produces for something outside itself — a wrapped program's output, another reference doc's required field, or a downstream consumer's expected artifact — surface review can only check form, not substance until the relevant external contract is in hand. Locate it before entering principles 3–7.**

Three illustrative shapes:

- **Wrapped-program contracts**: a skill drives a CLI / API / library and acts on its output. A skill that bundles "重跑 / 手动修复 / 仍然保存" into one ask looks fine on surface — but if the contract distinguishes "informational already-self-fixed" from "actionable needs-human", the misalignment is visible.
- **Reference-doc dependencies**: a skill / reference doc requires another doc to produce or contain field X (e.g., a long-task protocol assumes "plan must have a verify section"). If the upstream doesn't bind X, the dependency is silent — works when the author happens to satisfy it, fails when they don't.
- **Downstream consumer / output contracts**: a skill PRODUCES an artifact (handoff markdown, summary, report, plan) for a downstream consumer. Rules whose effect serves a framework different from the skill's stated core goal are locally coherent but globally misaligned (e.g., audit-checklist drift in a skill whose actual contract is equivalence-substitution).

A useful contract has two layers, applicable to any shape: (a) **meaning per item** — what does each field / required artifact actually represent; and (b) **intended consumer behavior** — what does the consumer (upstream-of-skill or downstream-of-skill) expect or use. Wrapped programs typically need both layers checked; ref-doc dependencies often need only binding existence.

When reviewing:
- Locate the relevant external contract (program README / docstring / schema for upstream; stated core goal / consumer-facing purpose for downstream output). If absent, stop the audit — the rest is built on guesses.
- For each program output the SKILL.md consumes, hold contract and SKILL.md side by side: does the skill's interpretation match the contract's stated meaning? Does the skill's response match the contract's stated consumer
 behavior?
- For skills that PRODUCE an artifact, name the artifact's consumer-facing goal. For each prescriptive rule (especially rules about absence / empty-case handling), project the rule's effect from the consumer's perspective: does it serve the stated goal, or only make sense under a different framework? Mis-framed rules read as locally reasonable but globally drift the artifact away from its actual contract.
- When fixing a gap, prefer strengthening the upstream contract over adding defensive logic to this skill — defensive accumulation across many dependents drifts more than fixing the source once.

Ask yourself: "Reading this skill's body and the relevant external contract together — upstream input or downstream consumer — can I tell whether the interaction or production is appropriate? If I can only see what the skill does (form) but not whether it's right (substance), the contract is what's missing."

---

## 3. Why Over How

**State the rule. Explain the reasoning. Trust the model to extrapolate. Walls of MUST/NEVER and rigid templates are a yellow flag.**

LLMs with good theory-of-mind extrapolate from principles to novel situations. Procedures and edge-case lists overfit to the scenarios the author imagined, then mislead the model on scenarios the author didn't. HOW-detail is reserved for places the model demonstrably fails at the WHAT level — not added speculatively.

When reviewing:
- Flag stacks of all-caps MUST / NEVER / ALWAYS without the "why" behind them.
- Flag rigid step-by-step templates in sections where judgment is needed — templates strip judgment.
- Flag speculative HOW-scaffolds added "just in case" — edge-case lists, lookup tables. Each item must trace to an observed failure, not to "the model might also need this."
- Flag enumerated trigger / scenario / criterion lists that give concrete bullets but never state the underlying lens (the shared judgment criterion the bullets exemplify). The model can extrapolate to listed cases but not to neighbors. Constructive recommendation: extract the lens, then keep the minimum anchors needed to span the lens's distinct cases.
- Flag procedural detail (exact command, exact file path) where a principle would generalize further.
- Flag NEVER-class absolutism about the skill's own structure or evolution. Skills are artifacts that evolve; those statements freeze unverified assumptions and cannot survive their own first audit.

Positive form: one sentence stating the rule, one sentence explaining why it matters, then stop. If a rule is inescapably about HOW, lead with the WHY so the model can still extrapolate.

The trust-the-model test (section scope): write any prescriptive section's WHAT-framing in 1–2 sentences. If a SOTA model handed only that framing would produce the right output, the section's body is teaching what the model already knows. Each individual item can pass scrutiny (every rule has a WHY, every example has a purpose) while the section as a whole adds nothing the model wouldn't already do — item-by-item review misses this. Same test catches author-facing content (provenance, repetition reasons, historical context): if removing it doesn't change executor behavior, it's serving the author, not the runtime.

---

## 4. Simplicity First

**Minimum skill that solves the goal. Nothing speculative.**

- Flag features beyond what the skill's stated purpose requires.
- Flag abstractions, configurability, or flexibility that was not asked for.
- Flag skills that bundle multiple unrelated domains — split them, or argue explicitly why they co-habit.
- Flag named phases that don't clearly improve the outcome — skip or inline them.
- If the skill is 500 lines and could be 150, push back.

Ask yourself: "Would a senior engineer say this skill is overcomplicated?" If yes, push back.

---

## 5. Progressive Disclosure

**SKILL.md stays lean. Depth goes into references/ and scripts/, with clear pointers to when they load.**

Three layers load in order: description (always), SKILL.md body (on trigger, ideally <500 lines), bundled files (on demand). Content at the wrong layer either bloats every triggered session or never gets read at all.

When reviewing:
- Flag SKILL.md over 500 lines without hierarchical sections and "go here next" navigation cues.
- Flag content in SKILL.md that only matters for one rare branch — it belongs in references/.
- Flag reference files with no "read this when…" pointer from SKILL.md. Unreferenced files are dead weight.
- Flag content in SKILL.md that's skill-agnostic (would apply equally to any skill) — it belongs in broader-scope files (CLAUDE.md / skill registry / shared references), not embedded in this skill. Exception: skill-agnostic content can stay if it's both (a) prone to being overlooked without explicit instruction at runtime AND (b) materially affects this skill's execution quality.
- Flag duplication — paraphrased summaries, same-constraint repetition across description / overview / tail-end guard sections. Apply the **substitution-path test** before consolidating: piece A is safely consolidatable into B only when every (consumer, scenario) of A has a reasonable path to B. Self-question: "Who reads this, in what scenario, and where do they go if it's gone?" Default tilts: for **normative content** (rules / contracts / definitions), source of truth belongs at the detail end, with always-loaded surface as a pointer; for **executor-aid cues** (param tables, output shape examples), keep both if removing forces an extra hop at execution time. Pick one location only when no (consumer, scenario) breaks.
- Flag mixed-role lists in the body — items playing different functional roles (e.g. references read vs review objects processed) bundled into one bulleted list. Split into role-named sub-sections so the reader doesn't classify each bullet before acting.

The test: from SKILL.md alone, a reader can decide whether they need to open each reference file, without opening it.

---

## 6. Definition Precedes Reference

**Within a single linearly-read doc: define terms before using them. When deduplicating, delete the later re-definition, not the earlier definition.**

A term used before defined forces the reader to jump forward or push through with unresolved meaning. Compression that targets an overview / framing section orphans later references.

The test: read front-to-back — did you ever need to jump forward to resolve a term?

---

## 7. Trigger Mode: Auto vs Manual

**Auto-invocable skills need low false-positive cost. Manual skills need to be discoverable without reminders.**

An auto-invocable skill fires whenever Claude judges its description relevant; every triggered session pays its context cost and risks misfire. A manual (slash-command) skill only fires on explicit invocation, so it costs nothing until used — but the user must remember it exists.

When reviewing:
- Flag auto-invocable skills whose misfire is expensive or confusing — ones that would kick off background work, modify files, or derail the conversation if triggered wrongly.
- Flag manual skills whose triggers are cleanly recognizable from context and whose users would benefit from not having to remember a command.
- Flag skills that declare themselves auto-invocable but whose description is too vague to reliably win against adjacent alternatives.
- Flag manual-only skills/commands whose frontmatter lacks `disable-model-invocation: true`.

The test: for auto — "what's the worst thing that happens if this fires unprompted?" For manual — "would a typical user know to invoke this at the right moment?"

---

## 8. Confirm High-Cost Decisions

**For each decision the skill's runtime makes implicitly, ask: "if the model picks wrong, how expensive is the redo?" If high — regenerated artifacts, re-run subprocess, modified files, or significant user re-work — the skill must explicitly instruct the runtime to use `AskUserQuestion` at that point. Trust-the-LLM is no substitute for confirming user intent at high-reversal-cost branches.**

The runtime model has good judgment for low-stakes choices, but some decisions are genuinely under-specified at runtime: ambiguous user inputs with multiple plausible interpretations, branches with diverging downstream consequences, upstream picks that propagate into all later artifacts. Self-deciding at those points produces fast wrong answers; a single AskUserQuestion turn is far cheaper than rework. The inverse failure exists too — skills that ask about decisions the model could trivially make alone interrupt unnecessarily.

When reviewing:
- Walk the skill's runtime path. At each implicit decision (the skill's body lets the model pick one of several options without an explicit ask), classify reversal cost: low (recoverable in seconds, e.g. "regenerate") vs high (forces re-running expensive ops or rewriting outputs).
- Flag high-cost decisions that aren't gated by `AskUserQuestion` in the skill body — especially upstream ambiguities (which input? which interpretation of user request?) that propagate downstream.
- Flag the inverse: skills asking about decisions the model could derive from context alone.

Ask yourself: "What's the worst case if the model picks this without asking — recoverable in one turn, or forces the user to redo significant work?" If the latter, the skill must explicitly require an ask.
