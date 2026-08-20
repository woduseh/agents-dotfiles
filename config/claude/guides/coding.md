# Coding Guide

Extends the global instructions. Applies to implementation, refactoring,
debugging, review, and architecture work.

## Working Style
- Break large work into small units and do them one at a time, rather than
  dumping a whole implementation at once.
- Deliver code-first. Keep prose to what the user needs to follow the change.
- Before sizable or trade-off-laden changes, lay out the approach and the
  options' pros and cons first, then implement.
- Use sub-agents when independent investigation or parallel slices genuinely
  improve speed or coverage; skip them for small, coupled work.

## Boundaries
- Treat questions, reviews, diagnoses, and "make a plan" as read-only unless
  the user also asks to change something. "Implement", "apply", "fix",
  "finish", or an approved plan is permission to make in-scope edits and
  validate them.
- Ask before destructive actions, git commits/pushes/PRs, releases or
  publishing, deployments, production dependencies or migrations, and broad
  scope expansion.
- Don't run full E2E verification unless requested; recommend it clearly when
  it would materially reduce risk.

## Code Quality
- Inspect the relevant code before changing it. Follow project conventions
  over personal preference.
- Keep changes scoped to the request; avoid unrelated cleanup. Treat the
  worktree as shared — don't revert the user's changes.
- Write simple, clean code that another agent or person can maintain easily.
  Favor clarity over cleverness; avoid premature abstraction.
- Let the code explain itself. Keep comments minimal — only where intent
  genuinely isn't clear from the code.
- Prefer structured parsers or framework APIs over ad hoc text manipulation.

## Debugging
- Reproduce or identify the failing path before patching when feasible.
  Prefer root-cause fixes over symptom masking.
- If reproduction is blocked, name the assumption behind the fix.

## Review
- After finishing, review the uncommitted changes (staged and unstaged) once,
  checking for weaknesses, bugs, and consistency issues before considering it
  done.
- When asked to review code, lead with findings ordered by severity, with
  file and line references. If nothing is wrong, say so plainly and note any
  residual risk.

## Documentation & Continuity
- Don't document every change. Write or update a design doc only for
  structural changes or new modules, where a doc actually saves future agents
  from reading all the code. Skip docs entirely for small, local fixes.
- If a design doc or progress note already exists, read it before digging
  into the code.
- When resuming interrupted work, check the current file state first, then
  separate done, partial, and remaining work before continuing from the
  smallest safe next step.

## Final Response
- Report the result, key files changed, validation performed, and remaining
  limitations. Add caveats only when useful.
