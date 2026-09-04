---
name: prompt-engineering
description: "Designs, revises, or evaluates prompts, global agent instructions, and skills, including model migrations and instruction architecture. Use when an instruction set or its evaluation is the deliverable, not for ordinary tasks that merely use a prompt."
---

# Prompt Engineering

Deliver the requested instruction set or assessment. For edits, briefly explain the intended behavior change and any meaningful validation limits.

- Define the outcome and the constraints that matter. Let the model choose the method except where an exact procedure is required for correctness.
- Remove duplication, conflicting rules, and speculative corrections for model behavior. Distinguish explicit user preferences from instructions inherited from an earlier model; reassess the latter rather than preserving them by default.
- Preserve runtime contracts such as placeholders, tool names, template syntax, and required output fields unless changing them is in scope.
- Keep global instructions focused on durable preferences, scope, and authorization. Skills carry task-specific guidance; references hold optional technical detail. Avoid repeating the host's instructions.
- Give skills distinct, outcome-based descriptions. Split or combine them when that improves selection and use, without a fixed number of skills or sections.
- Use the target runtime's skill format and the repository's validation tools. Shared skills should not assume an unrelated project's paths or tools.

## References

Load only what the task needs:

- Model-specific GPT work: [GPT notes](references/gpt-models.md).
- Model-specific Claude work: [Claude notes](references/claude-models.md).
- Behavior evaluation or comparison: [evaluation patterns](references/evaluation-patterns.md).

Preserve the user's named model and workload roles. Verify model-specific claims against current official documentation when they determine an edit. Treat proposed improvements as hypotheses until behavior has been evaluated.
