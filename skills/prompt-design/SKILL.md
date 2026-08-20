---
name: prompt-design
description: "Use for designing new prompts, system instructions, agent instructions, reusable prompt templates, role/task specs, output contracts, and model behavior guidelines from scratch."
---

# Prompt Design

Use this skill when creating a prompt or instruction set whose goal is reliable model behavior.

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

For an Agent Skill, include the required frontmatter keys `name` and `description`. Put trigger information in `description`, and add provider-specific optional fields only when the target runtime needs them.

## Evaluation Handoff

When the prompt will be reused, include a compact evaluation note:

- Intended behavior in one sentence.
- Success criteria that can be observed in output.
- 2-5 seed cases covering normal use, minimal input, ambiguity, and a likely failure.
- Any runtime semantics that must be preserved, such as variables, tools, insertion points, or output shape.

## Specialized Prompt Systems

When a prompt belongs to a specific runtime, app, or provider, first discover and follow that project's local instructions in the current workspace. Do not rely on hard-coded external paths.

For roleplay, preset, toggle, or template-heavy prompts, treat the prompt as a request-assembly pipeline: define what blocks exist, where runtime channels land, which variables/toggles are legal, and what model/provider assumptions the prompt depends on.
