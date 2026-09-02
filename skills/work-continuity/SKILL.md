---
name: work-continuity
description: "Resumes work from existing progress or design notes, prepares handoffs, and keeps one compact note for work that spans sessions. Use when resuming from notes, when a handoff or progress record is requested, or when a task will clearly cross sessions; do not use merely because a task is long or uses many tool calls."
---

# Work Continuity

Use this skill to make genuinely resumable work recoverable without turning ordinary tasks into documentation work.

## When to Use It

Use a progress or design note when at least one is true:

- Work is being resumed from existing notes.
- The user requests a progress record or handoff.
- The task is likely to cross sessions and a note will prevent meaningful rediscovery.
- A blocker or scope change requires another agent or future session to continue.

Skip note creation when the task can reasonably finish in the current session without costly rediscovery. Complexity, an approved plan, or many tool calls alone is not enough.

## Note Rules

- Keep one compact note and follow an existing project convention when available.
- In Codex Desktop projectless workspaces, use `work/` for temporary notes.
- Put durable design documentation in the project only when it remains useful after the task.
- Treat prior notes as hints, not truth. Verify current files, runtime state, and user-owned changes before editing.
- Record decisions, current state, validation, blockers, and the smallest next step, not command transcripts or generic reasoning.
- Keep the user's stated constraints and preferences close to their own words, note options tried or set aside with why, and keep hard-to-reconstruct details (names, numbers, dates, exact wording, links) exact. Condense your own reasoning to what it concluded.

## Workflow

1. Read the current request, applicable local instructions, and the latest relevant progress or design note.
2. Verify the current file state and dirty worktree before trusting the note.
3. Create or update a note only if the criteria above are met.
4. Update it after meaningful changes such as an accepted decision, completed implementation slice, validation result, blocker, or scope change.
5. For a handoff, leave the next action concrete enough to execute without repeating broad discovery.

At completion, report the outcome, changed files, validation, and remaining limits. Remove or mark temporary notes obsolete only when the user requests cleanup or project convention requires it.

## Reference

When a note is warranted, read [references/progress-docs.md](references/progress-docs.md) and use only the fields that help the next session.
