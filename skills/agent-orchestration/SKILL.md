---
name: agent-orchestration
description: "Designs how agents, skills, tools, and prompts coordinate: AGENTS.md or CLAUDE.md routers, skill taxonomies and descriptions, sub-agent delegation rules, tool routing, context-loading strategy, and multi-step work plans. Use when the question is how instructions should be split, triggered, or handed off; use prompt-design for one prompt's content and prompt-revision to change an existing one."
---

# Agent Orchestration

## Core Principles

- Keep routers short and limited to broad routing rules.
- Put task-specific procedure in skills and conditional detail in references.
- Make descriptions concise and discriminating because they control implicit activation.
- Prefer fewer, stronger skills until distinct outcomes or workflows justify a split.
- Make handoffs explicit when one skill prepares material for another.
- Use programmatic or batched tool orchestration only for bounded, predictable processing with a defined result shape. Keep semantic judgment, approvals, and final validation in direct model-controlled steps.

## Design Workflow

1. Identify the user intents and task types the system must handle.
2. Decide which instructions are global, skill-specific, or reference-only.
3. Give each skill a precise trigger and add exclusions only for likely routing collisions.
4. Define the primary skill and any genuine cross-domain handoff.
5. Add validation, approval, and stopping rules only where the task risk requires them.

## Sub-Agent Rules

Delegate when parallelism improves quality, speed, or coverage: independent codebase exploration, large reviews, architecture comparison, isolated implementation slices, or verification in a fresh context. Keep small, local, sequential, or tightly coupled work in the main agent.

When delegating, give concrete inputs (paths, commands, log excerpts, the exact question), ask for evidence-backed findings rather than essays, keep the lead agent working while sub-agents run, and intervene when one drifts or lacks context. Prefer one long-lived sub-agent for a series of related subtasks over a fresh one per subtask.

## Writing for Current Models

- Current frontier models follow brief instructions reliably and over-trigger on emphatic ones. Write triggers as plain conditions ("Use this skill when…"), not "CRITICAL: you MUST…", and drop "if in doubt, use X" defaults.
- Prefer outcome, constraints, required evidence, and success criteria over step-by-step procedure. Reserve exact steps for fragile operations where one wrong move is costly.
- Instructions written for earlier models are often too prescriptive now. When migrating a router or skill, remove rules the model already follows by default, then re-test.
- Where the runtime shows text between tool calls, ask for a one-line note before long tool chains and a standalone recap at the end; ask for independent tool calls to be issued together in one turn.
- For lesson or memory files: one lesson per file with a one-line summary; record corrections and confirmed approaches with why; skip what the repo or chat already records; update rather than duplicate; delete what turns out wrong.

## Split or Integrate

Create a separate skill when at least two are true:

- The success criteria differ.
- The workflow differs.
- The output format differs.
- The trigger is distinct and the task repeats often.
- Keeping the material together creates routing ambiguity.

Keep material together when it is a method, checklist, failure mode, genre, tone, or formatting variant inside the same task. Use a reference instead of another skill when optional detail shares the same trigger and success criteria.

Good handoff wording says: use this skill for X; hand off to Y only when Z becomes the main problem.

## Surface Placement

- **Router:** selects the primary skill and rare combination rules.
- **Task skill:** contains guidance that changes the result for that task.
- **Reference:** holds mode-specific procedures, schemas, checks, or substantial examples loaded only when needed.

Keep shared skills portable: do not embed one project's paths, tool names, or assumptions in a skill that installs globally.
