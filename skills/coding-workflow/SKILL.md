---
name: coding-workflow
description: "Implements, debugs, refactors, reviews, and validates software: features, bug fixes, tests and builds, frontend changes, repository maintenance, and local development workflows. Use for any request to change, explain, diagnose, review, or verify code. Hand off to release-prep for version, changelog, and release-readiness work."
---

# Coding Workflow

## Design Rules

- KISS > YAGNI > DRY. Choose the simplest design that satisfies current requirements and existing contracts; accept local duplication when abstraction would obscure intent or serve only hypothetical reuse.
- Add layers, configurability, dependencies, fallbacks, or defensive handling only for a current requirement, observed failure, existing contract, or real trust boundary.
- Prefer existing project patterns, dependencies, and helpers over new ones.
- Keep changes scoped to the request; treat the worktree as shared and do not revert user changes.
- Where the task is ambiguous, implement the reading its wording and the surrounding code most directly support, state that assumption in the summary, and do not build for the other readings as well.
- When a trade-off matters, give a recommendation with the alternatives that change the outcome, then proceed.

## Debugging

- Reproduce or identify the failing path before patching when feasible.
- Prefer root-cause fixes over symptom masking.
- Add a focused regression test when it meaningfully protects the changed behavior from recurrence.
- If reproduction is blocked, name the assumption behind the fix.

## Validation and Defensive Code

- Validate at the narrowest useful level first; broaden only when risk justifies it. Report each check's actual result; a skipped or failing check is reported as such, with its output.
- Test changed behavior, regressions worth preventing, and material boundary conditions.
- Prefer a few behavior-level tests over exhaustive branch coverage or tests coupled to implementation details.
- Do not add guards, catches, retries, normalization, or impossible-state handling unless the failure can realistically occur and the code can respond meaningfully.

## Review

When asked for a review, lead with findings ordered by severity. Include file and line references. Focus on correctness, security, performance, maintainability, and test gaps that could allow material regressions. If no issues are found, say so plainly and mention residual risk.

## Frontend

- Match the existing design system and interaction patterns.
- Verify the affected interactions and relevant responsive, text-fit, empty, loading, and error states, and that rendered output is nonblank and correctly framed.
