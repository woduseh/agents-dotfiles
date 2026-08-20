---
name: agent-orchestration
description: "Use for designing agent workflows, AGENTS.md routers, Skill taxonomies, sub-agent usage rules, tool routing, multi-step work plans, and context-loading strategies."
---

# Agent Orchestration

Use this skill when the work is about how agents, skills, tools, prompts, or workflows should coordinate.

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

Use sub-agents only when parallelism improves quality, speed, or coverage. Good uses include independent codebase exploration, large reviews, architecture comparison, or isolated implementation slices. Avoid sub-agents for small, local, sequential, or highly coupled work.

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

For project-specific orchestration, inspect local instructions, skills, schemas, and documentation. Do not embed absolute paths or assumptions from another project.
