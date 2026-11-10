---
name: engineering-review
description: Review or design code structure - architecture, module boundaries and interfaces, refactoring plans, and maintainability or slop audits. Use for 구조 검토, 설계 리뷰, 모듈 인터페이스 설계, 리팩터링 검토, or reducing structural complexity; not routine bug fixes, style edits, or test-only reviews.
---
# Engineering review

The goal is to lower the cost of understanding, changing, and operating correct software. Judge a design against what this project actually needs (its purpose, users, scale, and compatibility commitments), not against a pattern catalog. Keeping the current design is a valid outcome.

## Look at real behavior

Trace entry points, callers, the owner of each piece of state, external effects, and consumers. Before calling code dead, check registrations, indirect calls, and supported external contracts. For a repository-wide request, sample representative paths across the main areas first, and say which areas you did not inspect.

## What counts as a finding

A finding names a location and the concrete failure or maintenance cost it causes. "Violates SRP" is not a finding. "The discount rule lives in three handlers, so a rate change needs three edits" is one.

Keep three kinds apart: demonstrated defects, maintenance risks, and hypotheses. A performance concern without a measurement is a hypothesis. Rank by impact and likelihood, and report few findings when there are few.

## Judging module shape

- **Depth.** A module earns its interface when a lot of behavior sits behind a small one. The interface is everything a caller must know: the signature, and also invariants, ordering, error modes, and required configuration.
- **Deletion test.** Imagine the module deleted. If the complexity disappears, the module only passed calls through. If the complexity reappears in every caller, the module earns its place.
- **Boundaries.** A boundary is justified by something that actually varies or must be isolated across it: a second implementation, an external system, or time, randomness, and transport that tests need to control. A production implementation plus a test stand-in counts. Similar-looking code that encodes different rules can stay separate.
- **Test surface.** Tests should cross the same interface that callers do. A need to test past the interface suggests the module has the wrong shape.
- **State.** Each fact has one authoritative representation and one owner of its writes. Types, constructors, and storage constraints prevent invalid states better than convention does.
- **Failures.** An empty default or a silent fallback disguises a failure as success. Establish that an effect is safe to repeat before adding a retry, because a timeout can leave the external outcome unknown.

## Choosing the remedy

Consider leaving the code as it is, then the simplest local repair, before a larger reorganization. Prefer the smallest cohesive fix, which is not always the fewest changed lines. Name an alternative only when its trade-off affects the choice.

When the user wants to explore interfaces, sketch two or three materially different designs, compare them on depth, on where a future change would land, and on where the boundary sits, then recommend one.

When implementation is part of the request, preserve behavior unless the task changes it. For a behavior-preserving refactor, compare outputs and side effects before and after, not only compilation. Remove the code, tests, and documentation that the change makes obsolete, and report unrelated improvements separately.

## Report

Give each finding its location, consequence, recommended remedy, and material trade-off, then say what was actually verified. Keep the report proportional to the findings: no scorecard, no fixed count, no new report file unless asked. If nothing is worth changing, say so.
