---
name: test-audit
description: "Write, change, or review tests; audit redundant tests and test-driven code complexity. Use when choosing regression coverage or assessing test value, not for routine execution of an unchanged suite."
---

# Test Audit

Protect useful behavior with evidence worth its maintenance cost. Neither more
nor fewer tests is the goal. Test counts, coverage percentages, and deleted
lines are signals, not acceptance criteria.

## Scope

For ordinary implementation work, apply the authoring rules only to the change.
For a requested test review or cleanup, also read [the audit guide](references/audit.md).
Do not turn a small fix into a repository-wide sweep. Honor applicable project
instructions, required checks, and the user's authorized scope; this skill adds
no permissions. A review-only request remains read-only.

## Decide what needs proof

Before adding or substantially changing a test, identify:

- **Contract:** the outcome, invariant, or compatibility promise that matters.
- **Failure:** a plausible mistake this test would detect, including the relevant
  error or boundary case. Consider realistic risks, not every imaginable failure.
- **Oracle:** where the expected result comes from independently of the code
  being tested: a requirement, protocol example, reviewed fixture, or invariant.
- **Added value:** the gap in existing checks, or a substantial improvement in
  feedback speed, reproducibility, or fault isolation that justifies overlap.

Use these as decision criteria, not a mandatory essay or new planning document.
Read the relevant implementation and existing checks before claiming a gap.
Existing adequate coverage can justify adding no new test.

## Choose the boundary by the failure

Use the least expensive reliable check that would catch the identified failure.
A higher layer is not automatically stronger; it must exercise the relevant
path and assert the relevant result.

- Use integration or E2E coverage when correctness depends on components working
  together: routing, provider wiring, a user workflow, or save-and-reload behavior.
- Use focused unit, contract, or property tests for meaningful logic and edge
  cases they can cover more directly and deterministically. Do not drive every
  parser case or retry transition through a browser.
- Retain multiple layers when they detect different failures or provide material
  feedback value. Do not mirror every scenario across every layer by default.

Prefer an existing runner, fixture, or parameterized case when it fits clearly.
Do not create a generalized test framework merely to reduce a little duplication.

## Make the evidence independent

Assert outcomes rather than incidental private calls or source layout. Internal
ordering, exact bytes, or architecture rules can be valid assertions when they
are themselves a required contract, not just today's implementation.

Mock difficult dependencies, not the behavior under examination. Keep the real
owner of the claimed behavior in the exercised path. Use realistic,
provider-specific fixtures when protocols differ. A mocked external service
proves only the exercised local behavior, not live service compatibility.

Do not compute expected output with the same helper being tested, copy its
algorithm into the test, or pre-populate the final state the test claims to
produce. Independent properties and round trips are useful, but do not alone
prove compatibility with an external format.

Check that the assertion is reached and that negative cases fail for the intended
reason. Startup or no-throw smoke checks are valid when successful execution is
the actual contract; an explicit assertion count is not a quality measure.

## Regressions and testability

For a bug fix, try to establish failure before the fix and success afterward,
using the same scenario and a stable environment. Adding the test after writing
the fix is allowed; test timing is not a proxy for independence.

If the old version cannot practically reproduce the issue, state why and use the
best available evidence, such as a controlled dependency failure or captured
incident input. Do not label a test a proven reproducer without observing the
intended failure. Use a safe isolated checkout for historical comparisons when
needed; never reset or overwrite someone else's work to obtain red/green proof.

Keep or introduce small dependency seams when they make time, randomness,
transport, or scheduling controllable at a justified cost. Having only one
production implementation is not a reason to reject injection. Conversely, do
not expose internals or add production flags and wrappers just to support a
low-value assertion. Prefer the simplest boundary that stays useful afterward.

## Verify and finish

Use commands from the current repository's instructions, scripts, and CI.
Run the focused checks for the affected behavior and the required project gates.
Broaden verification for a changed boundary, a failure, or a concrete unresolved
risk, not simply because more tests are available. Run against a stable snapshot;
do not edit the tested files in a checkout while its test run is in progress.

For complex workflows, preserve the smallest useful inspectable evidence that
existing tooling can provide: asserted persisted state, generated output, a
report, or a relevant trace or screenshot. Include the command and enough
fixture/environment information to repeat the check. A screenshot can support
visual verification; it does not establish persistence or remote API correctness.
Do not build an artifact pipeline just to satisfy this paragraph. Keep secrets
and private data out of shared evidence; do not commit generated artifacts by
default.

Do not weaken assertions, silently update expectations, skip failing tests, or
relax CI gates merely to make a change pass. Explain intentional contract changes.
Distinguish product failures from environment failures and pre-existing failures.

Finish when the requested outcome and required checks are satisfied. Do not
repeat successful checks on unchanged inputs or open another audit without new
evidence, a required gate, or additional scope from the user.

Report the meaningful change or finding, checks actually run and their results,
and any unverified boundary or remaining risk. Include red/green evidence and
artifact locations when relevant. Never present a planned check as an executed
one or a mocked path as a live end-to-end result.
