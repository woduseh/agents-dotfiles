---
name: pre-compact
description: "Check what a session would lose before the user compacts, ends, or hands it off: uncommitted or unpushed work, promised updates to a pull request, issue, or release, local servers and processes still running, scratch files worth keeping, repeated corrections worth turning into a check, and decisions not yet written down; then give a compaction focus line or standalone handoff block. Use when the user says they are about to compact, end, or hand off a session and asks whether anything is left to do. Not for a commit or push request on its own."
---

# Pre-Compact

Compaction keeps a summary and drops line-level detail, so anything living only in the conversation gets lost or blurred. Audit what this session touched, close what is safe, and hand back a crisp continuity record.

## Audit only what this session touched

Skip areas the session never reached.

- **Working trees:** uncommitted or unpushed changes in each touched repository or worktree, and whether each is meant to stay uncommitted.
- **Promised updates and drafts:** pull requests, issues, release notes, or documents the session said it would update, plus drafts shown in chat but not posted.
- **Running processes and temp state:** local servers, containers, background tasks, or temporary config/test data left running or on disk.
- **Scratch files:** evidence or benchmark outputs worth keeping versus large temporary data that can be deleted.
- **Unrecorded decisions:** decisions, rejected alternatives, or traps from the session that belong in a commit body or owning document and are not written down yet.
- **Repeated corrections:** any mistake 재연님 had to correct more than once, and whether a type, lint rule, test, or hook could prevent it next time (offer the check; prose rules or memory are only the fallback for judgment calls).
- **Open threads:** what is blocked or waiting on something else, and the exact next step once unblocked.

Inspect directly. List any write, deletion, commit, push, or external follow-up with its exact target for approval rather than executing it silently.

## Hand back

Report briefly what was verified or closed, what remains open, and where each open item's state lives. Then provide one of:

- **For compaction:** one tight focus line to pass to the compaction command, naming active branches, PR/issue numbers, the immediate next step, and what is being waited on.
- **For a phase handoff or session fork:** a short standalone handoff block (or file, if requested) with the goal, verified decisions, exact file paths, and immediate next step so a fresh session starts without compaction loss.

If nothing is open, say so in one line and give the focus line.
