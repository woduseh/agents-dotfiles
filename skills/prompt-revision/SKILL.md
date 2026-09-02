---
name: prompt-revision
description: "Changes, compresses, migrates, reorganizes, translates, or conflict-checks an existing prompt or instruction set, including migration to current Claude models. Use when the user supplies a prompt to improve; use prompt-evaluation for assessment only and prompt-design for a prompt that does not exist yet."
---

# Prompt Revision

Use this skill when the user provides an existing prompt or instruction set and wants it improved.

## Revision Goals

- Preserve intended behavior.
- Remove conflicts, repetition, dead rules, and overbroad instructions.
- Make trigger conditions, workflow, and output expectations explicit.
- Keep the prompt shorter unless more detail is needed for reliability.

## Workflow

1. Identify the prompt's current purpose and target model/context.
2. Map sections by function: role, scope, workflow, safety, tools, output, validation.
3. Find contradictions, vague rules, duplicated tone constraints, and hidden assumptions.
4. Decide whether to revise in place, split into skills, or create a router plus references.
5. Produce the revised prompt.
6. Include a compact change note explaining the behavioral intent of the revision.
7. Name up to 3 likely failure modes that the revised prompt should be evaluated against.

## Migration Heuristics

- Move task-specific behavior into skills or references.
- Keep routers short and trigger-focused.
- For modern frontier models, prefer outcome-focused instructions: goal, relevant context, hard constraints, required evidence, success criteria, output shape, and the ambiguities that should trigger clarification.
- Remove generic requests to think harder, reveal or transcribe reasoning, follow fixed step-by-step thought, hold findings for the final response, minimize formatting, or be broadly concise, unless they encode a measured product requirement. Replace emphatic triggers (CRITICAL, MUST, ALWAYS) with plain conditions.
- Put examples near the rule they clarify.
- Keep evaluation criteria close to the expected output.
- Avoid overfitting to one provider unless the prompt is provider-specific.
- Preserve runtime semantics before improving wording: variables, placeholders, macros, tool names, insertion points, output schemas, and priority order.

## Localization

When translating or localizing prompts:

- Preserve operational meaning over literal phrasing.
- Keep technical field names and syntax stable.
- Do not soften constraints that affect behavior.
- Preserve Korean nuance when tone, hierarchy, intimacy, or genre language matters.

## Target-Model Notes

When the prompt runs on a current Claude model, read [references/claude-models.md](references/claude-models.md) before revising. It lists what to remove, what to add for each observed symptom, and the API constraints (no prefill, no forced tool choice, append-only history) the prompt must respect.

## Specialized Prompt Systems

For roleplay, preset, lorebook, toggle, or template-heavy prompts, read [references/specialized-runtimes.md](references/specialized-runtimes.md) before changing syntax or structure.

## Evaluation Handoff

After a substantive revision, prepare a short handoff for `prompt-evaluation` when reliability matters:

```markdown
Intended behavior: ...
Changed behavior contract: ...
Runtime semantics to preserve: ...
Likely failure modes: 1) ... 2) ... 3) ...
Suggested tests: minimal input / ambiguous input / conflict case / output contract case
```

Use this especially when the revision changes routing, tool use, safety boundaries, output format, or long-context behavior.
