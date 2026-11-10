---
name: explain-with-artifacts
description: "Create evidence-grounded diagrams, before/after comparisons, step-through explanations, or small interactive HTML explainers. Use for 시각적 설명, 흐름도, 변경 전후 비교, or exploring how inputs change an outcome. Not for routine code explanations, ordinary implementation or review, large tables alone, or production UI development."
---

# Explain with artifacts

The goal is to reduce the effort a reader needs to understand and judge a result. Build the lightest form that does this. A short answer with no new file is a valid outcome, even when this skill was invoked by name.

## Pick the form by the reader's question

| Reader's question | Form |
| --- | --- |
| What is the answer, condition, or exception? | Short prose or a comparison table. |
| What connects to what, and where does data go? | A small flow, sequence, or state diagram. |
| What happens over time? | Ordered stages, with step controls only when they help. |
| What changed and what stayed the same? | Before and after views of one shared scenario, with the source range. |
| What happens when I change an input? | A small interactive model that shows its assumptions and limits. |

Honor an explicit format request. Use a diagram format the host actually renders, or inline SVG or HTML when a rendered file is needed.

## Ground it

Read the real implementation, requirements, or captured results, and follow the important calls and state changes instead of inferring behavior from names. Reuse review and test evidence that still applies; an explanation is not a reason to audit or test again.

Readers make decisions from these pages, so keep four things distinguishable wherever the difference matters: observed results, descriptions backed by source, inferences, and simplified models. Label mocked, replayed, and illustrative values, and never present an illustrative number as a measured one. Give each important claim a route back to its source: a file and symbol, a revision, a requirement, or a command output. Mark what you could not inspect as unknown.

An explainer built from the code agrees with the code, including its bugs. To say the code is correct, compare it against a requirement or an independent example.

## HTML explainers

- Build one self-contained file: inline CSS, minimal JavaScript, system fonts, native elements, inline SVG. The page opens directly from disk and contacts no external service, so it uses no CDN, remote font, build step, or development server unless the task calls for one. Links to evidence are fine.
- The central explanation reads without JavaScript. Controls work from the keyboard with visible focus, state is not shown by color alone, and the layout holds on a narrow screen.
- Insert code, logs, and document text as escaped text (`textContent` for dynamic labels), and keep secrets and private data out. The page has no live write actions and no credentials.
- A page that models the system instead of running it says so on the page, along with what it simplifies or omits.
- Put the file where the user asked, or in the environment's scratch or artifact location. It stays out of the application and out of Git unless the user asks. Hand over a path or link the user can actually open.

## Check and finish

Check the central claims, arrows, and before/after values against the source. For an interactive model, exercise the inputs that separate the intended cases, and describe that as a check of the model, not of the system. With browser tools available, look at the rendered page at a normal and a narrow width and try its controls. Without them, do static checks and say that rendering and interaction were not verified.

Finish with the takeaway, the artifact location if one was made, the source references, and anything left unverified.
