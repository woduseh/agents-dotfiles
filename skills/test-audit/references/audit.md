# Focused Test Audit

Read this only for a requested review/cleanup or a specific suspected low-value
test. Use the shared criteria in `../SKILL.md`. A pattern is a lead to investigate,
not permission to delete.

## Establish the scope and baseline

For a local issue, inspect the complete candidate test, its production owner,
the exercised entry point, and the checks that supposedly replace it. Consult
history, callers, dependency contracts, or CI routing when they resolve a
specific uncertainty; do not require a full dependency archaeology for every edit.

For a repository-wide request, map the relevant test areas and CI jobs first.
Track areas examined and areas not examined so a partial review is not reported
as exhaustive. Process coherent batches; do not manufacture findings to fill
an inventory or automatically start a follow-up campaign.

Before cleanup, establish a focused baseline when feasible. An existing failure
is evidence to investigate, not a reason to delete its assertion. If execution
is unavailable, keep the limitation explicit and do not call a replacement
verified. Review-only work stops at evidence and recommendations; an authorized
cleanup continues through scoped edits and verification without a new approval
step for every routine change.

## Inspect suspicious patterns with their exceptions

| Candidate | Check before deciding |
| --- | --- |
| Expected output is copied from the implementation or computed by the tested helper | Replace the circular oracle with an independently specified outcome or property. Setup reuse alone is not circular. |
| A mock performs the transformation, persistence, or ordering being asserted | Exercise the real owner. Faking an external dependency is still legitimate. |
| A fixture already contains the claimed final state | Verify that the real path produces the state and that the assertion observes that path's store or output. |
| Several tests appear to cover the same scenario | Compare reached branches, assertions, environments, CI execution, and feedback cost. Shared names or code coverage are not proof of redundancy. |
| Exact source text, private calls, snapshots, or export lists are asserted | Retain a genuine API, architecture, generated-format, release, or byte-level contract; otherwise prefer behavior that survives internal reorganization. |
| A test only executes code or rejects an input | Successful execution can be a smoke contract. For rejection, establish that the intended guard is reached rather than an unrelated earlier failure. |
| A test is slow, flaky, or breaks during refactoring | Diagnose the cause and preserve its unique risk coverage. Slowness and flakiness alone do not prove low value. |
| A production export, flag, wrapper, or branch seems test-only | Check public consumers, dynamic registration, scripts, build entry points, and useful dependency injection before declaring it dead. Search only the mechanisms relevant to this project. |

Preserve independently useful protection for data integrity, migrations,
compatibility, security, platform behavior, and previously observed defects.
An E2E test with the relevant dependency mocked out is not a replacement for a
real dependency contract test.

## Justify a removal before editing

For each proposed deletion or merged group, capture a compact evidence note:

1. The test location and the concrete failure it currently detects.
2. Why that protection is redundant or obsolete. Name the retained test and
   explain how its path and assertion detect the failure, or identify the
   retired requirement that makes the behavior unnecessary.
3. The effect on production/test-support code, remaining consumers, and the
   focused command that will validate the change.

These notes may live in the response or working notes; do not add a permanent
audit document unless requested. If unique protection remains uncertain, retain
the test and name the uncertainty instead of replacing uncertainty with deletion.

When equivalence is unclear, use a small counterexample or temporary fault in an
isolated workspace to check sensitivity. Do this only when it resolves a
specific doubt; do not mandate mutation testing for every candidate. A suite
passing after deletion does not establish that the removed protection survives.

## Make one coherent improvement

Choose the appropriate result: keep, clarify, repair, merge, move, or delete.
Preserve distinct assertions when consolidating cases. Remove test-support and
production scaffolding only when proven unnecessary; do not preserve pointless
aliases or introduce a new abstraction to make the diff look tidy.

Do not regenerate snapshots, downgrade assertions, lower coverage thresholds,
or alter test selection to hide failures. A deliberate product-contract change
needs its own justification, not the label "test cleanup". Changes outside the
authorized scope remain findings rather than opportunistic edits.

Run the focused baseline/replacement checks, affected neighboring checks when
needed, and repository-required gates against the final diff. Review the diff
for accidental loss of behavior and run `git diff --check` in a Git checkout.
A broad audit report should state coverage of the review, meaningful changes,
retained false positives, actual verification, and remaining gaps. Counts are
optional; bug-detection value and maintainability are the result.
