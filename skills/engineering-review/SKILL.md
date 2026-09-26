---
name: engineering-review
description: Review architecture, module boundaries, refactoring plans, or maintainability and slop audits. Use for 구조 검토, 설계 리뷰, 리팩터링 검토, or reducing structural complexity; not routine bug fixes, style edits, or test-only reviews.
---
# Engineering review

Reduce the cost of understanding, changing, and operating correct software. Review actual behavior and dependencies, not conformity to a pattern catalog. Keeping the current design is a valid outcome.

## Scope and context

Honor the user's authorized scope and applicable project instructions. A review-only request remains read-only; carry requested implementation through verification. This skill adds no permissions or approval checkpoints.

Establish the project's purpose, users, operating scale, and compatibility commitments before judging its design. Weigh abstractions and infrastructure against those actual needs, not an assumed deployment model. Preserve behavior unless the task authorizes changing it.

## Find the relevant evidence

- Identify the target: a change, module, feature, or repository-wide audit. Establish the current revision and relevant working-tree changes.
- Use the repository's guidance, code map, or feature contracts when available to find entry points and owners. If they are absent, trace the code and tests directly; do not require a particular document layout or create one just for the review.
- Follow callers through policy/calculation, state ownership, external effects, and consumers. Before declaring code dead, check registrations, indirect calls, imports, and supported external contracts.
- Expand along observed dependencies and plausible failure paths. For a repository-wide request, inspect representative paths across the major areas before narrowing deeper work. Report uninspected areas rather than implying exhaustive coverage.

## Select the lenses that matter

Use relevant rows, not a mandatory all-items checklist. Name concrete failure or maintenance costs rather than simply declaring a SOLID violation.

| Lens | Questions and decision criteria |
| --- | --- |
| Ownership, cohesion, and locality | Which rules change together, and who owns their state? Keep related rules near each other; separate independently changing concerns. Look for scattered policy, hidden global dependencies, and cycles that obstruct local reasoning. Many callers alone do not make a stable shared utility a problem. |
| Information hiding and abstraction | What implementation decision does a boundary hide? Prefer a direct function or module when sufficient. Retain an adapter, strategy, interface, or shared owner when it isolates a real variation or important boundary. One implementation can justify a boundary; repeated syntax alone does not justify merging different rules. |
| Data and invariants | What must remain true before and after a change? Identify the authoritative representation and prevent contradictory states with suitable types, constructors, and storage constraints. Distinguish persisted facts from derived views; review migration and atomicity when stored data changes. A status enum alone does not enforce valid transitions or required results. |
| Effects, state, and concurrency | Keep calculations separable from I/O where useful. Identify allowed transitions and the owner of each write. Examine cancellation, late responses, duplicate submissions, ordering, and partial completion. Establish safety for duplicate effects before adding retries; a timeout can leave the external outcome unknown. |
| Errors and observability | Distinguish expected absence, rejected input, operational failure, and unknown outcome. Preserve actionable diagnostics without exposing secrets or unnecessary user data. Do not disguise failures as success with empty defaults or silent fallbacks; avoid duplicate logging at every layer. |
| Performance and resource cost | Identify the relevant workload and cost: algorithmic growth, I/O round trips, serialization, external service calls, allocations, or UI updates. Measure the suspected bottleneck or label the claim as a hypothesis. Add caching, batching, parallelism, or queues only with justified benefit and clear invalidation, ordering, or capacity semantics. |
| Verification and maintenance | Which observable behavior distinguishes a correct change from a plausible mistake? Reuse checks at the affected boundary. Prefer outcomes and invariants over incidental implementation shape. Before removing tests, identify obsolete behavior or redundant coverage and check what protection remains. |

## Choose the smallest coherent improvement

- Explain the problem with a file/symbol reference and a concrete consequence. Separate demonstrated defects, maintenance risks, and unmeasured hypotheses. Prioritize by impact and likelihood; do not manufacture findings to fill a quota.
- Consider leaving the code as-is and the simplest local repair before proposing a larger abstraction or reorganization. Discuss alternatives when their tradeoffs materially affect the choice. Prefer the smallest cohesive fix, not the fewest changed lines.
- Keep shared business knowledge under one owner, but allow similar-looking code to remain separate when it represents different rules. Avoid forwarding layers, factories, event buses, frameworks, and compatibility scaffolding that add no current value. Do not prescribe a folder topology or pattern by default.
- Check what a proposed deletion protects. Remove redundant internal validation when its invariant is established and preserved; retain necessary checks at untrusted input, persistence, and external-effect boundaries. Do not delete recovery or compatibility behavior merely because a search or one test did not exercise it.
- Clean up code, tests, and owning documentation made obsolete by the agreed change; report independent improvements separately. Do not silently modify vendored snapshots or add a second source of truth for project contracts or verification commands.

## Verify and finish

Use the current repository's instructions, scripts, and CI to select checks for affected behavior and plausible failures. Honor required gates and reuse still-applicable evidence; expand or repeat verification only for subsequent changes, failures, or unresolved risks.

For a behavior-preserving refactor, compare meaningful outputs and side effects, not only type-check success. For a performance claim, compare equivalent workloads and correctness before and after. Distinguish synthetic or mocked results from live-service or production evidence, and report blocked or unverified checks honestly.

Report meaningful findings or completed changes with locations, consequences, the selected remedy, material tradeoffs, and actual verification. Keep the report proportional: no mandatory scorecard, diagram, finding count, or new report file. If no worthwhile change is supported, say so and finish.
