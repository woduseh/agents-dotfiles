---
name: project-docs
description: "Write, extend, deduplicate, or correct project documentation, such as a README section, a design or contract document, or a tool reference, so that it holds what the code cannot state and points to the code for the rest. Use when adding a documentation section for a feature, removing duplicated documentation, or reconciling a document with the code. Not for release notes, pull-request or issue bodies, or proposals (writing-for-readers), diagrams or explainers (explain-with-artifacts), or code comments."
---

# Project Docs

A document that repeats the code has no reader that fails when it goes stale. In one project, two documents whose links and source paths were all valid still carried more than ten statements that had drifted from the code they restated. So a project document holds what the code cannot state and points to the code for the rest.

This applies to the user's own projects. A repository someone else owns keeps its own documentation conventions.

## What a document holds

- The reason for a rule that is not obvious.
- What a feature deliberately does not do.
- Which path owns a behavior, so that no second one gets built.
- The boundary between two features.
- Guides for readers who do not read the code.

## What stays in the code

A document does not restate what the code already tells its reader: a type, a schema, a tool or API description, or a test. Name the file that defines a contract and the test that enforces it instead of copying them.

## Removing duplication

Before removing a statement as duplicated, find the place that carries it, and keep the statement when nothing does. Without that check, the guess that the code probably says it removes content that only the document held.

## When a document and the code disagree

The document is wrong about current behavior, so correct it to the code. When the document states the intent and the code falls short of it, report a defect instead of rewriting the intent.

## Project structure

Which file holds what in a given project belongs to that project's own instructions. This skill decides what a document says, not where it lives.
