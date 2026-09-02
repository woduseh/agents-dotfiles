---
name: prompt-design
description: "Designs new prompts, system instructions, agent instructions, skills, reusable templates, output contracts, and model behavior guidelines from scratch. Use when no prompt exists yet; use prompt-revision to change an existing one and prompt-evaluation to assess without rewriting."
---

# Prompt Design

## Goal

Design prompts that are explicit, modular, non-contradictory, and easy for a model to follow. Favor clear behavioral contracts over ornate wording.

## Design Workflow

1. Define the task outcome in one sentence.
2. Identify inputs, outputs, tools, constraints, and success criteria.
3. Separate durable rules from task-specific instructions.
4. Write sections by function: role, scope, workflow, decision rules, output format, validation.
5. Remove contradictions, duplicated rules, and vague intensifiers.
6. Add examples only when they prevent predictable failure.
7. Include stop conditions and escalation/clarification rules when needed.
8. For reusable or high-risk prompts, add 2-5 evaluation seeds covering minimal input, ambiguity, expected success, and a likely failure mode.

## Frontier-Model Defaults

- Be specific about what completion means.
- State the outcome, relevant context, hard constraints, required evidence, success criteria, and output shape when they matter.
- Say which important ambiguities require clarification; otherwise let the model use reasonable defaults.
- Tell the model how much effort to spend based on task risk.
- Make tool-use rules concrete and verifiable.
- State each rule once, using the shortest wording that preserves the intended behavior and required evidence.
- Avoid stacking many near-duplicate tone rules.
- Put routing and trigger criteria in descriptions or top-level router text, not buried in bodies that may never load.
- Make output contracts testable: define required sections, allowed omissions, stop conditions, and what a good clarification looks like.
- Write triggers and rules as plain conditions. Current models over-trigger on emphatic wording (CRITICAL, MUST, ALWAYS) and on "if in doubt" defaults.
- Do not ask the model to reproduce, transcribe, or explain its reasoning in the response; on Claude this can trigger a refusal. Read thinking output through the API when visibility is needed.
- Formatting rules say when structure is appropriate rather than forbidding it.
- For prompts that run on Claude, read [Claude model notes](../prompt-revision/references/claude-models.md) for the current snippets: progress updates, autonomy and scope blocks, quoting, targeted edits, batching, and API constraints.

## Output Patterns

For a complex or reusable prompt, use the sections that earn their place and omit empty ones:

```markdown
## Purpose

## Inputs

## Instructions

## Decision Rules

## Output Format

## Validation
```

For an Agent Skill, include the required frontmatter keys `name` and `description`. Write `description` in third person as what the skill does plus when to use it, under 1,024 characters, with an exclusion only where a routing collision is likely; keep `name` to lowercase letters, digits, and hyphens under 64 characters. Keep the body under 500 lines and link references one level deep. Add provider-specific optional fields only when the target runtime needs them.

## Evaluation Handoff

When the prompt will be reused, fill the handoff block defined in [prompt-evaluation](../prompt-evaluation/SKILL.md): intended behavior, behavior contract, runtime semantics to preserve, likely failure modes, and suggested tests, including the 2-5 seed cases from the design workflow.

## Specialized Prompt Systems

When a prompt belongs to a specific runtime, app, or provider, first discover and follow that project's local instructions in the current workspace. Do not rely on hard-coded external paths.

For roleplay, preset, toggle, or template-heavy prompts, treat the prompt as a request-assembly pipeline: define what blocks exist, where runtime channels land, which variables/toggles are legal, and what model/provider assumptions the prompt depends on.
