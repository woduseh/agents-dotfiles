---
name: prompt-evaluation
description: "Evaluates prompt quality: failure modes, rule conflicts, output contracts, tool-use boundaries, eval criteria, and before-and-after comparisons for model migrations. Use when the user wants an assessment or test plan without a rewrite; use prompt-revision when they want the prompt changed."
---

# Prompt Evaluation

## Evaluation Lens

Check the prompt for:

- Clear objective and completion criteria.
- Unambiguous role and scope.
- Consistent priority between rules.
- Concrete output format.
- Appropriate tool-use and verification rules.
- Known failure modes and recovery behavior.
- Token efficiency and unnecessary verbosity.

## Handoff Input

When prompt-design or prompt-revision hands a prompt over, expect this block and ask for missing fields before evaluating:

```markdown
Intended behavior: <one sentence>
Changed behavior contract: <what the revision changed, or "new prompt">
Runtime semantics to preserve: <variables, tools, insertion points, output shape>
Likely failure modes: 1) ... 2) ... 3) ...
Suggested tests: minimal input / ambiguous input / conflict case / output contract case
```

## Workflow

1. State the prompt's intended behavior.
2. Identify likely inputs and edge cases.
3. List failure modes by severity.
4. Recommend targeted fixes.
5. If useful, propose a small test set with expected behavior.
6. Tie each recommended fix to a specific failure mode or test case.

## Scoring Rubric

Use a lightweight rubric when helpful:

- `Clarity`: Can the model tell what to do?
- `Consistency`: Do rules conflict?
- `Completeness`: Are inputs, outputs, and stop conditions covered?
- `Robustness`: Does it handle edge cases and ambiguity?
- `Efficiency`: Does every section earn its context cost?

## Test Patterns

Use concrete test cases rather than abstract criticism when possible:

| Pattern | Test input | Expected behavior |
| --- | --- | --- |
| Minimal input | A short, underspecified request | Asks the right clarification or proceeds with stated defaults |
| Ambiguity | A request with two plausible interpretations | Does not overcommit without a decision rule |
| Conflicting instruction | Higher- and lower-priority rules disagree | Follows the intended priority order |
| Output contract | Request stresses formatting or required sections | Preserves shape, labels, and allowed omissions |
| Tool-use boundary | Task tempts unnecessary or forbidden tool use | Uses tools only under stated conditions |
| Long-context drift | Important rule appears far from the current task | Maintains durable constraints without repeating everything |
| Safety/refusal boundary | Borderline allowed and disallowed requests | Refuses only where required and preserves helpful alternatives |
| Progress visibility | A task with a long tool chain | Says what it will do, notes progress, closes with a recap that stands alone |
| Scope discipline | A task beside an unrelated bug or missing test | Reports the extra as a follow-up instead of fixing or adding it |
| Completion | A multi-step request the model has enough to finish | Finishes instead of ending on "Next I'll…" or asking permission for requested work |
| Source fidelity | Summarize a retrieved document | Rewords; any verbatim passage is marked as a quotation with its source |

For each test, state the expected behavior and the failure signal. A good eval catches the prompt doing the wrong thing, not merely producing less polished prose.

For prompts that run on Claude, take known failure modes and the matching fixes from [Claude model notes](../prompt-revision/references/claude-models.md).

For model or prompt migrations, run the same representative cases before and after the change. Compare task success, answer completeness, required evidence, total tokens, latency, and cost when those measurements are available. Treat lower resource use as an improvement only when the revised prompt still meets the quality bar.

## Output Format

For reviews, lead with findings. Then provide fixes or a revised section only if the user asked for rewriting.

Avoid long theoretical explanation unless the user requests prompt-engineering analysis.
