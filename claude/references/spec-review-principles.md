# Spec Review Principles

Behavioral guidelines for reviewing **spec.md** — the user-facing delivery contract written before any implementation planning. Spec captures L1 (final artifact + use-path) + L2 (user-facing verify) + cross-cutting tradeoff preferences; it does **not** include L3 (architecture, file-level changes, internal verify).

**Tradeoff:** These guidelines bias toward making the contract complete and unambiguous over making it short. For trivial L2 work (one-line acceptance), skip spec entirely and use create-plan directly.

**These guidelines are working if:** users approve specs without "what about X?" follow-ups; downstream create-plan / implementer never has to guess what the user accepts; tradeoff disputes don't surface at delivery time.

**Loop:** For each principle, check 1–4. Loop until no principle is violated.

---

## Priority and conflict resolution

Principles 1–4 are listed in **tiebreaker priority order** — when two give conflicting guidance, the lower-numbered principle wins.

**Escape valve**: when applying this order would contradict your judgment of what serves the spec's purpose, surface the conflict instead of applying blindly.

---

## 1. Contract Completeness

**Spec tells a complete story of the deliverable from the user's perspective: what gets shipped, who uses it, what they do with it, and what counts as "delivered."**

The spec must answer four questions concretely:
- **Artifact form**: what physical / logical thing exists when implementation finishes — "a CLI named `xyz`", "a markdown report at `path/`", "a REST endpoint `POST /v1/foo`". Not "a tool that does X" without naming the form.
- **User**: who or what consumes the artifact — e.g., "end users via the CLI" or "downstream code calling the API". "Users" alone is not enough; be specific about whose acceptance matters.
- **Use-path**: what the user does with the artifact — "picks one system to ship", "cherry-picks algorithms for a new system", "drops into a CI pipeline as gate". Use-path determines acceptance depth (blackbox vs. module-level).
- **Acceptance**: what counts as delivered, expressible without reference to internal design (this is L2 — see Principle 2).

When reviewing, flag:
- Artifact form named in vague form-words ("a system", "a workflow", "a tool") without a concrete physical / logical shape.
- User unspecified or stated as "everyone" / "the team" without picking the actual consumer whose acceptance matters.
- Use-path missing or stated as the artifact form again ("the report is used as a report") — use-path is what the user **does** with it next.
- Acceptance stated as a quality ("works well", "is good", "is usable") rather than concrete observable conditions.
- **Consumer acceptance boundary not surfaced as first-class** — when use-path admits multiple depths, spec must commit to one. Otherwise downstream plan can't tell how deep to go.

Ask yourself: "From the spec alone, can I name the artifact, the user, what they do with it, and what would make them say 'this is delivered'?" If no on any, flag.

---

## 2. Verify Layer Independence

**Verify must be expressible from the user's perspective without any reference to internal implementation. If you can't write user-facing verify yet, the artifact's shape and use-path haven't collapsed enough.**

Spec contains **only** user-facing verify — the conditions the artifact's actual user accepts as "delivered". Expressible without reference to internal structures, state machines, or design choices, so it can be defined *before* implementation is settled (TDD-style).

Internal verify (types / lint / unit tests / contract tests / invariant assertions) is L3 — belongs in plan, not spec.

When reviewing, flag:
- User-facing verify written in implementation-internal terms — internal data shapes, state machines, private APIs, module boundaries, or specifics like "the function returns X" / "the database column is Y". Refactor to user-observable form.
- Verify deferred to "after implementation" / "we'll see when it's done" — the artifact's shape and use haven't collapsed enough; user-facing verify must be definable from the artifact description alone.
- Verify reduced to "command + stdout" when the user's acceptance is actually visual / qualitative / human-judgment — accept the modality the user actually uses. Screenshots, evaluator scores, manual confirmation, sample-by-sample rubric — all valid.
- Verify covering only happy path. If the artifact has known failure modes (timeout, missing input, permission denied, quality below threshold), at least one verify entry must surface them from the user's view.
- **Verify dimension stated too vaguely for faithful downstream translation** — e.g., subjective / perceptual judgments ("feels good", "looks natural") without a per-sample rubric (dimensions to score, annotation slots, structured ballot). Flag at spec layer; pushing ambiguity to plan multiplies it.

Ask yourself: "Could a user (not the implementer) execute every verify step in the spec, and tell whether each passed — without knowing how the artifact is built internally?" If no, flag.

---

## 3. Surface Implicit Tradeoff Preferences

**Tradeoff preferences (the user's relative priority among competing dimensions) shape product form, verify-dimension priority, and downstream implementation choices — and the user's initial task description usually does NOT include them. Spec is the main place to surface them, because it's where they shape the contract.**

A tradeoff preference is the user's choice on multi-option decisions where no answer is universally right — e.g., usability vs. tunability, MVP vs. comprehensive, speed vs. maintainability. The same tradeoff cuts across the artifact, simultaneously shaping —

- **Product form (L1)** — "idiot-proof vs. tunable" literally changes which artifact gets shipped.
- **Verify-dimension priority and thresholds (L2)** — same artifact under "minimum steps + within-time-budget" vs. "maximum effect quality" gets verified by completely different metrics, with completely different pass bars.
- **Implementation directions (L3)** — "code complexity vs. evolvability", "performance vs. stability" — spec **lists** which directions L3 will be affected, but does **not decide** for plan.

When reviewing, flag:
- Spec touches user-experience / output-quality / product-strategy dimensions but contains no surfaced tradeoff — likely because the user's initial description didn't include the tradeoff and the planner accepted it implicitly. Tradeoffs the user **didn't initially express** are exactly the ones the spec must surface.
- User-facing verify lists multiple dimensions (e.g., latency, accuracy, output quality, ease-of-use) without any priority order — downstream can't tell which to optimize when they conflict at runtime.
- Verify thresholds (numbers, "good enough" bars) appear without grounding in any tradeoff statement — the bar is arbitrary, will be argued post-hoc.
- Tradeoff stated as a planner default ("I assumed X over Y") without `AskUserQuestion` confirmation, on a high-reversal-cost surface (changes the artifact that ships).
- Spec declares "we'll figure out the tradeoff later / based on results" on dimensions central to the artifact — defers the most important decision to the most expensive moment.
- Spec **decides L3 implementation** in the name of "tradeoff" (e.g., "use Redis because user prefers stability") — L3 belongs to plan; spec only states the preference direction, not the implementation choice.

**When the principle does NOT apply**: artifact is binary (feature exists / doesn't), or all relevant dimensions are stated explicitly in the user's initial description. In those cases, don't fabricate one.

Ask yourself: "If the implementer hits a runtime conflict between two dimensions the spec claims to optimize, does the spec tell them which wins?" If no, flag.

---

## 4. No Implementation Leakage

**Spec describes the contract from the user's view; implementation-internal language belongs to plan.**

**Information-symmetry lens**: spec writer and plan author share the same input sources — spec L1/L2/cross-cutting tradeoffs + codebase + project history. The only asymmetry comes from user interviews: implicit preferences, hard constraints, defaulted decisions — and these already have dedicated spec sections (cross-cutting tradeoffs / assumptions-and-scope / L1 / L2). Anything else a spec writer wants to "surface for plan" is plan-recoverable; the plan author would derive it on their own.

Spec stays at L1+L2+cross-cutting tradeoff. It must not reach into:
- Architecture decisions (manifold layering, interface contracts, module boundaries)
- File-level changes (which files to create / modify / delete)
- Internal verify (types / lint / unit tests / contract tests / invariant assertions)
- Implementation-specific error handling, retry policies, log strategies

When reviewing, flag:
- Spec sections describing "how it's built" / "which files" / "what modules" — refactor to user-facing form, or delete.
- Risk / mitigation sections describing implementation responses (retry strategies, fallback code paths) — those are L3 plan content.
- "Error handling" sections in spec — only frame errors as user-observable failure modes ("user sees timeout banner") that L2 verify covers, not internal handling logic.
- **Surface-to-plan sidebars / reminders** — sections framed as hand-off notes to the planner. Delete, not relocate (per lens above).

Ask yourself: "If I removed every line of this spec that describes how the artifact is built internally, would the user-facing contract still be complete?" If yes, those sections were leakage; if no, they need to be re-stated user-side.

