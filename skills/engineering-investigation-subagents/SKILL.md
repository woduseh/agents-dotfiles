---
name: engineering-investigation-subagents
description: "Provides bounded subagent playbooks for CI or test failure triage and MCP or tool-transport diagnostics, with prompt templates and an evidence-first output contract. Use when a failure can be investigated in parallel with the main task or the user asks for delegation; not for ordinary single-agent debugging that stays on the critical path."
---

# Engineering Investigation Subagents

## Delegation Rules

- Use these prompts when a failure can be investigated in parallel with the main task, when the user asks for delegation, or when the host agent's policy permits it. Keep working on the main task while the investigator runs and read its result when you need it.
- Prefer a read-only investigator for diagnosis. Use an editing agent only when it has a clear, disjoint write scope.
- Keep the main agent on the critical path. Delegate sidecar questions that can run in parallel.
- Give the subagent concrete inputs: failing command, log excerpt, changed files, tool name, repo path, or suspected surface.
- Ask for evidence and next actions, not broad architecture essays.
- If an editing agent changes files, remind it that it is not alone in the codebase and must not revert unrelated changes.
- Append the Output Contract below to whichever template you use; the templates do not repeat it.

## Prompt Playbooks

- `references/ci-failure-triage.md`: CI, build, lint, typecheck, test, or flaky failure investigation.
- `references/mcp-transport-investigator.md`: MCP tool failures such as transport closes, writes that do not land, stale host state, and diagnostics or log interpretation.

## Output Contract

Ask each subagent to return:

- Summary.
- Evidence: file paths, log lines, or commands.
- Likely root cause with confidence.
- Minimal fix or next check, with the validation command that should prove it.
- Residual risk.

Every claim should point to a tool result from the subagent's own run; anything it could not verify is marked as unverified rather than reported as done.
