---
name: prompt-engineering
description: "Designs, revises, evaluates, and migrates prompts and instruction sets: system and agent prompts, AGENTS.md or CLAUDE.md routers, Agent Skills and their descriptions, output contracts, reusable templates, and how instructions split across router, skill, and reference, including migration to current Claude and GPT models. Use when the deliverable is a prompt, skill, or instruction set, or an assessment or test plan for one; not for ordinary writing or coding that merely uses a prompt."
---

# Prompt Engineering

## Modes

Pick the mode from the request. The rules below apply to all three.

- Design: no prompt exists yet. Deliver the prompt.
- Revise: a prompt exists and the user wants it changed, compressed, reorganized, translated, or migrated. Deliver the revised prompt plus a compact change note that states the behavioral intent and up to three failure modes to evaluate against.
- Evaluate: the user wants an assessment or test plan without a rewrite. Deliver findings by severity, each tied to a fix or a test case, and rewrite only if asked. Use [references/evaluation-patterns.md](references/evaluation-patterns.md).

## Rules

- Define completion: outcome, relevant context, hard constraints, required evidence, success criteria, stop conditions, and output shape. Prefer these over step-by-step procedure. Reserve exact steps for fragile operations where one wrong move is costly.
- State each rule once in the shortest wording that preserves behavior. Remove contradictions, near-duplicate tone or brevity rules, and steps the model already performs by default. Instructions written for earlier models are usually too prescriptive now.
- Write triggers and rules as plain conditions ("Use this tool when…"). Current models over-trigger on emphatic wording (CRITICAL, MUST, ALWAYS) and on "if in doubt" defaults. Keep absolutes for true invariants such as safety rules and required fields.
- Say which ambiguities should trigger a question; otherwise let the model use stated defaults. Give one autonomy policy in one place: what to do for answer, explain, review, and plan requests; what to do for change, build, and fix requests; what needs confirmation.
- Formatting rules say when structure is appropriate rather than forbidding it. Do not ask the model to transcribe or explain its reasoning in the response.
- Add examples only where they prevent a predictable failure, placed near the rule they clarify. Make tool-use rules concrete and verifiable.
- Preserve runtime semantics before improving wording: variables, placeholders, macros, tool names, insertion points, block order, conditional syntax, output schemas, and priority order. Verify unfamiliar template or decorator syntax against the project's documentation or user-provided material before touching it.
- When translating or localizing, preserve operational meaning over literal phrasing, keep field names and syntax stable, do not soften constraints that affect behavior, and preserve Korean nuance where tone, hierarchy, intimacy, or genre language matters.
- Keep shared skills portable: no single project's paths, tool names, or assumptions in a skill that installs globally.

## Target Model

Read the matching reference before designing or revising for a specific model, and take known failure modes from it when evaluating.

- Current Claude models, with Claude Fable 5.1 as the baseline: [references/claude-models.md](references/claude-models.md)
- Current GPT models, with gpt-5.6-sol as the baseline: [references/gpt-models.md](references/gpt-models.md)

When a model name carries several tiers, design against the highest tier and note where a lower tier changes a constraint. Re-verify version-specific claims against the live documentation named in each file when its date is old or the claim decides the design.

## Instruction Architecture

- Router (AGENTS.md, CLAUDE.md, system prompt): short, holding only global defaults and broad routing. Task skill: guidance that changes the result for that task. Reference: mode-specific procedure, schemas, or substantial examples loaded only when needed, linked one level deep from the skill.
- Put trigger criteria in descriptions or router text, not in bodies that may never load. A description is third person, says what the skill does plus when to use it, and carries an exclusion only where a routing collision is likely.
- Split into a separate skill only when at least two hold: success criteria differ, workflow differs, output format differs, the trigger is distinct and frequent, or keeping the material together creates routing ambiguity. Methods, checklists, genres, tones, and formatting variants of one task stay together. Optional detail with the same trigger becomes a reference.
- Handoff wording: "use this skill for X; hand off to Y only when Z becomes the main problem."
- Agent Skill frontmatter: `name` is at most 64 characters of lowercase letters, digits, and hyphens and does not contain "anthropic" or "claude"; `description` is non-empty, under 1,024 characters, and free of XML tags. Keep the body under 500 lines. Add provider-specific optional fields only when the target runtime needs them.
- Memory or lesson files: one lesson per file with a one-line summary; record corrections and confirmed approaches with the reason; skip what the repo or chat already records; update rather than duplicate; delete what turns out wrong.

## Output

For a complex or reusable prompt, use the sections that earn their place and omit empty ones: Purpose, Inputs, Instructions, Decision Rules, Output Format, Validation. Lead with the deliverable. Keep prompt-engineering commentary to the change note or the findings unless the user asked for analysis.
