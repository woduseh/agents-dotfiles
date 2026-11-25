---
name: writing-for-readers
description: "Write or draft text that reports work to someone else or asks them for a decision—release notes, pull-request or issue bodies, and proposals—in two layers: a brief visible decision layer and a folded evidence layer. Use when drafting or editing PR descriptions, release notes, issue reports, or written proposals. Not for guides, reference documentation, articles, fiction, or ordinary chat replies."
---

# Writing for Other Readers

Text that reports work to someone else or asks them for something—such as release notes, a pull-request or issue body, or a proposal—is read first by a person deciding quickly and later by a person or an agent looking for evidence. Write it in two layers. Guides, reference documentation, articles, and fiction keep their own structure and do not use this format.

## Visible layer (for the person deciding)

- Cover, in a few lines: what changes for them, what they need to do, and any risk or unverified item.
- Start from the shortest version that carries those points and fit it to the reader: a user needs the effect on their use and data; a pull-request reviewer needs the behavior change and what to check.
- Keep the user's own sentences when the user supplied a draft.
- Because the visible layer carries the user's judgment about what deserves the reader's time, present it as a draft for the user to choose from or edit.

## Folded layer (for evidence)

- Include the changes file by file, rejected alternatives, and the commands run with their results—complete enough for an agent to act on without this conversation.
- Fold it with what the medium offers (such as `<details><summary>` on GitHub) and label the fold as agent-written with the model name.
- When the commit range, a linked pull request, or another record already carries that evidence, link it instead of repeating it.
- Omit the folded layer when the change is small enough to explain completely in the visible layer.

## Project templates

Where a project has its own format for release notes, pull requests, or issues, keep that template. The two layers decide what goes on top and what gets folded, not the template.
