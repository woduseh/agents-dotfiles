---
name: pre-compact
description: "Check what a session would lose before the user compacts, ends, or hands it off: uncommitted or unpushed work, promised updates to a pull request, issue, or release, local servers and processes still running, scratch files worth keeping, and decisions not yet written down; then give a focus line for the compaction. Use when the user says they are about to compact or wrap up a session and asks whether anything is left to do. Not for a commit or push request on its own."
---

# Pre-Compact

Compaction keeps a summary and drops the rest, so whatever lives only in the conversation is lost or blurred afterward. The aim is to leave nothing in that state and to hand the user a focus line that tells the compaction what to keep.

## What to look at

Look only at what this session touched, and skip an area the session never reached.

- Working trees: uncommitted or unpushed changes in each repository and worktree the session edited, and whether each is meant to stay that way.
- Published things: a pull request, an issue, release notes, or a document the session said it would update, and drafts that were shown but not posted.
- Running things: local servers, containers, and background processes the session started, and test data or temporary configuration it left on a personal server.
- Scratch files: material in the session's scratch area the user may want later, such as evidence or benchmark results, and large temporary data that can go.
- Decisions: a decision, a rejected alternative, or a trap from the session that belongs in a commit body or in the project's owning document and is not there yet.
- Open threads: what is waiting on something else, what that is, and the next step once it is unblocked.

## Acting on what is found

Reads proceed. A commit, a push, a post, or a deletion follows the usual go-ahead rule: list each one with its exact target and act on the user's answer.

## What to hand back

Report briefly what was closed just now, what stays open, and where the state of each open item is recorded. Then give one focus line the user can pass to the compaction command, naming the branches, pull-request or issue numbers, the next step, and what is being waited on. When nothing is open, say so in one line and give the focus line.
