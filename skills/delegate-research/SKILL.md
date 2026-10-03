---
name: delegate-research
description: Delegate substantial, bounded codebase or documentation research to appropriately sized Codex subagents and integrate verifiable evidence. Use for 조사 위임, 코드 탐색 분담, or independent evidence collection; not simple lookups or general advice about delegation.
---

# Delegate research

Reduce expensive exploration and noisy main-thread context without losing evidence. Optimize for a correct completed task, including coordination, verification, and rework. More agents or fewer parent tokens alone do not establish savings.

## Decide whether to delegate

For a concrete authorized task, use subagents when a meaningful research slice can run independently and its findings can be checked more cheaply than repeating the investigation. Reading many sources, mapping bounded code paths, and extracting explicit constraints are good candidates.

Handle short searches directly with targeted tools. Prefer direct work when the main agent already has the necessary evidence, the next question depends on each preceding answer, or evaluating the report would require reconstructing the whole investigation. Delegating nothing is a valid outcome. A question about delegation itself is not a request to launch agents.

Keep hypothesis selection, consequential interpretation, and final integration with the main agent. Ambiguous root-cause analysis and claims of completeness may require a stronger researcher; calling a task "research" does not make it easy. This workflow delegates investigation, not permission to modify code or external systems.

## Choose capability and context

- Honor explicit model choices and the current runtime's supported models and controls. Prefer a lower-cost capable model for clear extraction or bounded scans; use stronger reasoning when interpretation, indirect dependencies, or omissions dominate the risk. Avoid fixed model-to-task tiers.
- When the cost argument depends on a cheaper worker, select that model explicitly where supported. An unspecified subagent may inherit the parent's model and effort. If the runtime cannot honor the choice, reassess rather than silently claiming a cheaper run.
- Pass the question, relevant requirements, source locations, and essential constraints. Prefer a focused handoff over copying the entire conversation, while retaining the context needed to answer correctly. Follow the runtime's rules for combining history inheritance with model overrides.
- Split by independent question or source boundary, not agent count. Shared context can have cache value, and separate agents still add their own work. Do not assume either universal cache loss or free context reuse.

Do not look up prices for every investigation. Consult current official guidance when an unresolved model choice or a requested cost calculation needs it. API prices, paid credits, and included subscription usage are distinct; do not promise quota savings from token ratios.

## Give a bounded assignment

Include the question, allowed sources or paths, relevant version or revision, and the useful stopping condition. Ask workers to return findings or blockers rather than creating another layer of agents. Use the smallest output that preserves:

- **Findings and evidence:** concrete observations with file/symbol locations or source URLs and the short excerpts needed to support them; separate inference from observation.
- **Coverage and uncertainty:** what was inspected, relevant searches or checks, failures, contradictions, and what remains unknown.

For example:

> Inspect the retry behavior of this SDK version using its implementation and official documentation. Return the default, retryable conditions, and exceptions with exact references. Flag version mismatches and anything you could not establish. Stop when those items are supported or the missing evidence is identified; make no code changes.

## Integrate without repeating everything

While workers investigate, continue independent authorized work. Avoid duplicating their searches just to stay busy. Resolve a missing fact with a targeted follow-up; take over or choose a stronger worker when the task exceeds the worker's capability, instead of repeating an unsuccessful loop.

Check the primary evidence behind decision-critical claims and inspect plausible omitted paths when the conclusion depends on coverage. A report of "no matches" is evidence about a search, not proof that no other caller, behavior, or risk exists. Spot checks do not establish exhaustive coverage.

Reuse adequate evidence rather than rereading every source. Expand verification for a contradiction, an unsupported claim, or a concrete unresolved risk. Synthesize the result with its evidence and remaining uncertainty, then continue the original task within its authorized scope. Distinguish observed usage and time from estimated savings; do not build a benchmark or extra report unless the task calls for one.
