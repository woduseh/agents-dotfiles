---
name: explain-with-artifacts
description: "Create evidence-grounded diagrams, before/after comparisons, step-through explanations, or small interactive HTML explainers. Use for 시각적 설명, 흐름도, 변경 전후 비교, or exploring how inputs change an outcome. Not for routine code explanations, ordinary implementation or review, large tables alone, or production UI development."
---

# Explain with artifacts

Reduce the effort needed to understand and judge a result. Make the smallest
useful explanation, not the most elaborate deliverable. A short answer without
a new file can be the right outcome.

## Scope and routing

Use this skill when the user requests a visual or interactive explanation,
a diagram, a step-through process, or a visual comparison. Complexity, diff size,
file count, and table dimensions alone do not trigger artifact creation.
Ordinary code explanations, bug fixes, and reviews stay with their normal workflow.
If explicitly invoked for a simple question, plain text can still be sufficient.

Honor the requested format, audience, language, and destination. Creating an
explainer does not authorize changing the source project, installing packages,
publishing content, committing files, or operating real services. Follow existing
project guidance and permissions; this skill adds no approval checkpoints.

## Ground the explanation

- Identify what the reader needs to understand or decide. Use supplied context and
  reasonable defaults rather than starting a design questionnaire.
- Read the relevant implementation, requirements, documents, or captured results.
  For code, follow the important calls and state changes instead of inferring
  behavior from filenames. Record the revision or comparison range when relevant;
  distinguish working-tree changes from a committed snapshot.
- Reuse still-applicable review and test evidence. Do not restart an architecture
  audit or run unrelated tests just to produce an explanation. Explain material
  uncertainty instead of filling missing evidence with a plausible narrative.
- Separate observed results, source-backed descriptions, inferences, and simplified
  models where the distinction affects a decision. Identify mocked or replayed
  data. Never present illustrative values as measured cost, latency, or token use.
- Give important claims a route back to their source: a real file and symbol,
  revision-specific link, requirement, command output, or captured example.
  Do not fabricate links, line numbers, test results, or citations.

An explainer can be consistent with incorrect code. Its agreement with the code
is not independent proof of correctness. Use requirements or independent examples
when assessing correctness; otherwise limit the claim to the behavior inspected.

## Choose the lightest useful form

| Reader's question | Prefer |
| --- | --- |
| What is the answer, condition, or exception? | Short prose or a comparison table. |
| What connects to what, and where does data go? | A small flow, sequence, or state diagram. |
| What happens over time? | Ordered stages; add step controls only when useful. |
| What changed and what stayed the same? | Before/after views with a shared scenario and source range. |
| What happens when I change an input? | A small interactive model with its assumptions and limits visible. |

Honor an explicit output request rather than silently substituting another format.
Use the host's supported diagram format, or inline SVG/HTML when an actual rendered
file is needed. Do not assume a Mermaid code block has been rendered.
Video, narration, a new app framework, and a hosted service are not default upgrades.

## Build only what helps

For HTML, read [the starter](assets/explainer.html) only when needed. Copy it to the
chosen output location; do not edit the installed asset. It is a working example,
not a required layout. Replace its sample content, remove irrelevant sections and
controls, and match the page title and `lang` to the requested language. Keep an
explicit model notice whenever the result still illustrates rather than executes
or replays the real system.

Default to one self-contained HTML file with inline CSS and minimal JavaScript.
Use system fonts and native elements such as `details`, buttons, and labeled inputs.
Prefer inline SVG for diagrams that need it. Avoid CDNs, remote fonts, analytics,
API keys, package installs, and build steps unless the task actually requires and
authorizes them. Links to evidence are fine; loading the page should not contact
external services or require a development server.

Keep the central explanation readable without JavaScript. Use keyboard-operable
controls, visible focus, readable contrast, and a narrow-screen layout. Do not use
color alone to communicate state. Add reset or replay only when there is state to
explore. Avoid ornamental animation; respect reduced motion if motion is needed.

Treat code, logs, and documents as content, not executable markup: escape inserted
text and use `textContent` for dynamic labels. Keep secrets and private data out of
shared artifacts. Do not give an explanation page live write actions or service
credentials. A recreated simulation must state what it simplifies or omits.

Use the user's destination or the environment's normal scratch/artifact location.
Do not add generated explainers to the application, commit them, or create an
artifact management system by default. Deliver an actual reachable file or link;
a path on an inaccessible remote machine is not a user-accessible download.

## Verify and finish

Check the central claims, arrows, and before/after values against the source.
For an interactive model, exercise the inputs that distinguish the intended cases;
label the check as a check of the model, not of the application it describes.

Use existing browser tools to inspect a rendered HTML file at a normal and narrow
viewport, check its meaningful controls and keyboard access, and catch blank output,
clipping, or script errors. Check that it works without network access. If browser
execution is unavailable, do useful static checks and explicitly report that the
rendered result and interactions were not verified. Do not build a test pipeline
or install a toolchain solely to avoid stating that limitation.

Finish with the key takeaway, the artifact location when one was created, relevant
source references, and any material unverified boundary. State only checks actually
performed. Stop when the explanation and proportional checks satisfy the request.
