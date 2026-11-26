---
name: writing-for-readers
description: "Write or draft text that reports work to someone else or asks them for a decision—release notes, pull-request or issue bodies, and proposals—in two layers: a brief visible decision layer and a folded evidence layer. Use when drafting or editing PR descriptions, release notes, issue reports, or written proposals. Not for guides, reference documentation, articles, fiction, or ordinary chat replies."
---

# Writing for Readers

Someone deciding whether to approve, upgrade, or act needs the verdict in seconds; a reviewer or future agent auditing the work needs complete evidence. Separate the two layers. Guides, reference docs, articles, and fiction keep their own structure and do not use this format.

## Visible layer (for the decision-maker)

- Cover in a few lines: what changes for the reader, what action (if any) they need to take, and any material risk or unverified boundary. Never hide a caveat or risk inside the fold.
- Fit the framing to the audience: users care about impact on their workflow and data; PR reviewers care about behavior changes and what deserves direct inspection.
- Preserve the user's wording when they supplied a draft.
- Because the visible layer represents 재연님's judgment about what deserves the reader's time, present it as a draft to choose from or edit.

## Folded layer (for evidence)

- Include file-by-file changes, rejected alternatives with reasons, and commands run with their results—complete enough for another agent to act on without this conversation.
- Fold it using the medium's native control (such as `<details><summary>` on GitHub) and label the fold as agent-written with the model name.
- Link to an existing commit range, linked PR, or record instead of repeating evidence it already carries.
- Omit the fold when the change is small enough to state completely in the visible layer.

## Project templates

Keep any template the repository already defines for release notes, pull requests, or issues; the two layers govern what stays on top and what folds, not the template itself.
