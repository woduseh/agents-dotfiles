---
name: coding-workflow
description: "Implements, debugs, refactors, reviews, and validates software: features, bug fixes, tests and builds, frontend changes, repository maintenance, and local development workflows. Use for any request to change, explain, diagnose, review, or verify code. Hand off to release-prep for version, changelog, and release-readiness work."
---

# Coding Workflow

Use this skill when the user wants code changed, explained, debugged, reviewed, or validated.

## Operating Principles

- Inspect the relevant code before changing it.
- Prefer existing project patterns, dependencies, helpers, and style.
- Apply engineering principles in this order: KISS > YAGNI > DRY.
- Choose the simplest design that satisfies current requirements and existing contracts; accept local duplication when abstraction would obscure intent or serve only hypothetical reuse.
- Add layers, configurability, dependencies, fallbacks, or defensive handling only for a current requirement, observed failure, existing contract, or real trust boundary.
- Keep changes scoped to the request and avoid unrelated cleanup.
- Treat the worktree as shared. Do not revert user changes.
- Validate at the narrowest useful level first; broaden only when risk justifies it.
- Where the task is ambiguous, implement the reading its wording and the surrounding code most directly support, state that assumption in the summary, and do not build for the other readings as well.

## Workflow

1. Determine the mode: implementation, debugging, review, architecture, validation, or explanation.
2. Read the minimum files needed to understand the behavior.
3. For non-trivial work, say in a line what you will do; when a trade-off matters, give a recommendation with the alternatives that change the outcome, then proceed.
4. Edit with focused patches.
5. Run relevant checks when available and report their actual result; a skipped or failing check is reported as such, with its output.

## Debugging

- Reproduce or identify the failing path before patching when feasible.
- Prefer root-cause fixes over symptom masking.
- Add a focused regression test when it meaningfully protects the changed behavior from recurrence.
- If reproduction is blocked, name the assumption behind the fix.

## Validation and Defensive Code

- Test changed behavior, regressions worth preventing, and material boundary conditions.
- Prefer a few behavior-level tests over exhaustive branch coverage or tests coupled to implementation details.
- Do not add guards, catches, retries, normalization, or impossible-state handling unless the failure can realistically occur and the code can respond meaningfully.

## Review

When asked for a review, lead with findings ordered by severity. Include file and line references. Focus on correctness, security, performance, maintainability, and test gaps that could allow material regressions. If no issues are found, say so plainly and mention residual risk.

## Frontend

- Match the existing design system and interaction patterns.
- Verify the affected interactions and relevant responsive, text-fit, empty, loading, and error states.
- For visual or 3D work, verify that the rendered result is nonblank and correctly framed.
