# Evaluating Instructions

Evaluate behavior that matters to the user, not compliance with the old prompt's incidental wording or process.

Choose representative tasks and likely regressions. Useful cases include:

- An actionable request with routine ambiguity: completes using context.
- An assessment-only request: reports without implementing.
- A fix that requires related refactoring: completes the solution without stopping at an artificially narrow edit.
- Existing user edits or an external action: preserves user work and respects authorization.
- A small change with passing checks: finishes without redundant verification.
- A constrained creative or structured output: satisfies the requested form and meaning.

For each case, record the input and fixture, expected outcome, failure signal, and actual result. Report substantive findings with evidence and a proposed fix. Add cases when a real failure reveals a missing boundary.

Compare revisions on the same tasks with model and runtime settings held constant. Check task success and useful evidence first; compare tool work, latency, and cost when available. Change the model or settings separately if evaluating those variables.

Static validation checks file structure and links. Reading scenarios is a consistency review; it is not an executed model evaluation. State which kind of validation actually ran.
