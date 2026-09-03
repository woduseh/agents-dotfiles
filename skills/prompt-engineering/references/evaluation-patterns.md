# Evaluation Patterns

Use this in Evaluate mode, and to choose the seed cases a designed or revised prompt should be tested against. Report findings by severity, each tied to a specific fix or test case. Avoid long theoretical explanation unless the user asked for prompt-engineering analysis.

## Lens

Check the prompt for a clear objective and completion criteria, an unambiguous role and scope, consistent priority between rules, a concrete output format, appropriate tool-use and verification rules, known failure modes with recovery behavior, and whether every section earns its context cost.

## Rubric

Use when a compact score helps the user compare versions.

- Clarity: can the model tell what to do?
- Consistency: do rules conflict?
- Completeness: are inputs, outputs, and stop conditions covered?
- Robustness: does it handle edge cases and ambiguity?
- Efficiency: does every section earn its context cost?

## Test Patterns

Prefer concrete test cases over abstract criticism. For each test, state the expected behavior and the failure signal. A good eval catches the prompt doing the wrong thing, not merely producing less polished prose.

| Pattern | Test input | Expected behavior |
| --- | --- | --- |
| Minimal input | A short, underspecified request | Asks the right clarification or proceeds with stated defaults |
| Ambiguity | A request with two plausible interpretations | Does not overcommit without a decision rule |
| Conflicting instruction | Higher- and lower-priority rules disagree | Follows the intended priority order |
| Output contract | Request stresses formatting or required sections | Preserves shape, labels, and allowed omissions |
| Tool-use boundary | Task tempts unnecessary or forbidden tool use | Uses tools only under stated conditions |
| Long-context drift | Important rule appears far from the current task | Maintains durable constraints without repeating everything |
| Safety or refusal boundary | Borderline allowed and disallowed requests | Refuses only where required and preserves helpful alternatives |
| Progress visibility | A task with a long tool chain | Says what it will do, notes progress, closes with a recap that stands alone |
| Scope discipline | A task beside an unrelated bug or missing test | Reports the extra as a follow-up instead of fixing or adding it |
| Completion | A multi-step request the model has enough to finish | Finishes instead of ending on "Next I'll…" or asking permission for requested work |
| Source fidelity | Summarize a retrieved document | Rewords; any verbatim passage is marked as a quotation with its source |
| Autonomy boundary | A review request beside an obvious fix | Reports without implementing; implements only when the request asks for change |

For a reusable or high-risk prompt, ship it with two to five seed cases covering minimal input, ambiguity, expected success, and its most likely failure mode.

## Before-and-After Comparison

For model or prompt migrations, run the same representative cases before and after the change. Compare task success, answer completeness, required evidence, output-contract validity, tool choice and loop count, total tokens including cache writes, latency, and cost per successful task when those measurements are available. Treat lower resource use as an improvement only when the revised prompt still meets the quality bar. Change one thing at a time (model, effort, prompt, tool set) so a regression can be attributed.
