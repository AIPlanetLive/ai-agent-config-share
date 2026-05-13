# Skill Creation Principles

Behavioral guidelines for reviewing and writing skills **at creation time** — covering the input the creator was given, the thinking process they followed, and the resulting skill before it ships. Complementary to `skill-review-principles.md`, which audits a finished skill in isolation; this file audits the creation pipeline (input → process → output) and assumes the review-principles will run afterward on the artifact itself.

**Tradeoff:** These guidelines bias toward smaller, more deliberately-justified skills over comprehensive scaffolds. Adding speculatively at creation time bakes regret into every future invocation and dilutes the LLM's room to extrapolate.

**These guidelines are working if:** newly created skills are smaller than the creator's first draft, every section has a named failure it prevents, and user input is reflected as derived intent rather than transcribed wording.

**Loop:** For each new or substantially-revised skill, check 1–4 against the creator's input + thinking + output. Loop until no principle is violated.

---

## 1. Distill the Intent

**Treat user suggestions as evidence about goals, not as specifications. Extract the underlying intent or principle behind each suggestion before it shapes the skill — never transcribe surface wording.**

Users speak in shorthand. Example fields, "etc.", and informal phrasing are signals about what the user values, not a complete spec. Mechanical transcription produces skills that look responsive but lock in the user's first wording before the user has had a chance to refine it — and miss any field the user didn't think to name.

When reviewing the creation:
- Flag direct copies of user's example lists into skill content (especially `(e.g. ...)` surviving verbatim).
- Flag absence of any "I derived these from goal X using criteria Y" trace in the creator's reasoning.

Ask yourself: "If the user had phrased the same intent differently, would the skill be substantially the same?" If a small rewording of the request would change the skill's structure, you transcribed instead of distilled.

---

## 2. Default to Omit

**At every "should I include this?" decision, the default is no. Add a piece of content only when it is (a) logically required by the task the skill processes, or (b) empirically validated as useful. Never to cover hypothetical scenarios.**

LLMs default to additive completion: when in doubt, write more. For a skill — which constrains every triggered session — that means baking unvalidated assumptions into every future use. Templates, `references/` files, scripts, and "just in case" sections look helpful at creation time but reduce the runtime LLM's room to adapt to the actual request.

When reviewing the creation:
- Classify each section / file / template as (a) logically required, (b) empirically validated, or (c) speculative. Flag (c) without exception.
- Common (c) tells: a `references/` file written before any failure mode demanded it; a `scripts/` that duplicates SKILL.md prose; a section labeled "edge cases" with no concrete case named; a rubric / template borrowed from a peer skill that itself hasn't been validated.

Ask yourself: "What evidence convinced me to add this?" If the answer is "it might come up" or "seems useful", the evidence is missing — omit and wait for real demand to surface.

---

## 3. Delete-Test

**After the draft is written, audit each section by deletion. For each section, ask: if I removed it, what concrete behavior would the runtime LLM get wrong? If you can't name a specific behavior change, delete the section.**

The underlying concept is subtractive validation: every section must earn its place by being load-bearing, and removal is the cleanest test of whether it is. The most common bloat in LLM-written skills is non-load-bearing prose: overview paragraphs that restate the description, value statements that don't change behavior, transitional sentences that summarize what was just said. Each individual line reads fine; the aggregate is a wall of text that costs context and dilutes the load-bearing rules.

When reviewing the creation:
- Common dead-weight patterns: opening paragraphs that restate the description; "value statement" or "why this exists" sections that don't change behavior; self-checklists whose items are obvious from the instructions above them.

Ask yourself, section by section: "What does the runtime LLM do differently because this section exists?" If the runtime would do the same right thing without it, the section is dead weight — its only effect is consuming tokens.

---

## 4. Coverage Audit

**For every piece of information in the user's input that bears on task quality, locate where it lands in the skill. If a quality-critical input has no capture site, your distillation lost signal.**

#1 (Distill), #2 (Default to Omit), and #3 (Delete-Test) all push toward less. Without a counterbalance, the skill can quietly drop load-bearing information from the user's task description. The user-provided spec is the only ground truth for what affects quality; if you can't trace a quality-relevant input forward to a capture site, you've degraded the skill below what the user already knew.

When reviewing the creation:
- For each quality-affecting item in the user's task description (constraints, success criteria, deliverable shapes, evaluation dimensions, hard requirements), identify the section / field / bullet in the skill that captures it.
- Flag items with no capture site — likely dropped during distillation or filed under a default that was actually non-default for this user.
- Flag distillation steps that classified non-default user requirements as "default-good-enough" without naming the default and confirming alignment.

Ask yourself: "If the user later asked 'where in the skill did you cover X?' for each X they mentioned, could I point to a specific location?" If the answer is "X was implicitly subsumed by Y" without specifics, you likely dropped X.
