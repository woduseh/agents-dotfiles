---
name: test-audit
description: "Write, change, or review tests; choose regression coverage; audit redundant or implementation-coupled tests. Use when deciding what a test should prove or whether a test is worth keeping, not for running an unchanged suite."
---

# Test audit

A test earns its place when it would catch a plausible mistake and costs less to maintain than that mistake would cost. Test counts, coverage percentages, and deleted lines are signals, not goals. Adding no test is a valid outcome when existing checks already cover the behavior.

During ordinary implementation work, apply this to the tests the change needs. Audit the wider suite only when the user asks for a test review or cleanup, and say which areas you did not examine.

## Decide what the test proves

Before adding or substantially changing a test, be able to name three things:

- **Contract:** the outcome, invariant, or compatibility promise that matters.
- **Failure:** a plausible mistake the test would detect.
- **Oracle:** where the expected value comes from, independent of the code under test: a requirement, a protocol example, a reviewed fixture, or an invariant.

Read the implementation and the existing checks before claiming a gap.

## Choose the level by the failure

Use the cheapest reliable check that would catch the failure. A higher level is stronger only if it exercises the relevant path and asserts the relevant result.

- Use integration or end-to-end tests when correctness depends on parts working together: routing, wiring, a user workflow, save-and-reload.
- Use unit, contract, or property tests for logic and edge cases that they reach more directly and deterministically.
- Keep two levels when they catch different failures. Mirroring every scenario at every level adds cost without adding protection.
- A passing unit suite says nothing about the installed or deployed application. If the change affects that experience, check a real flow there, or report it as unverified.

## Keep the evidence independent

- Assert outcomes. Assert internal calls, ordering, exact bytes, or source layout only when they are themselves the contract.
- Mock the dependency that is hard to control, not the behavior under test. A mocked external service proves the local behavior only, not compatibility with the live service.
- The expected value must not come from the helper under test, a copy of its algorithm, or a fixture that already contains the final state.
- Check that the assertion is reached and that a negative case fails for the intended reason.
- A small seam that makes time, randomness, transport, or scheduling controllable is worth keeping, even with one production implementation. A production flag or wrapper that exists only for a low-value assertion is not.

## Regression tests

For a bug fix, try to see the test fail without the fix and pass with it, on the same scenario. Writing the test after the fix is fine. If the failure cannot be reproduced, say why, use the best available evidence, and do not call the test a proven reproducer. Use an isolated checkout for a before-and-after comparison so the user's work is not reset.

## Removing or merging tests

A suspicious pattern is a lead, not a verdict. A slow, flaky, similar-looking, or snapshot-based test can still hold protection that nothing else has. Before deleting or merging, establish:

1. the concrete failure the test detects today;
2. why that protection is redundant or obsolete: the retained test whose path and assertion catch the same failure, or the retired requirement;
3. the focused command that validates the change.

If unique protection is uncertain, keep the test and name the uncertainty. A suite that passes after a deletion does not show that the protection survived. When equivalence is unclear and the doubt matters, inject a temporary fault in an isolated workspace and see which tests notice.

A failing test is evidence to investigate. Weakening an assertion, regenerating a snapshot, skipping a test, or relaxing a gate to get a pass hides that evidence. State an intentional contract change as one.

## Finish

Run the focused checks and the project's required gates, using the repository's own scripts and CI. When they pass, stop; repeat or widen only for a new change, a failure, or a concrete unresolved risk. Report the change or finding, the checks that ran with their results, and what remains unverified. Keep mocked paths and planned checks distinct from live, executed ones.
