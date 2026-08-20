---
name: engineering-investigation-subagents
description: Use bounded subagent playbooks for CI or test failure triage and MCP or tool-transport diagnostics. Trigger only when the user requests subagents or parallel work, or when active host policy permits delegation; do not use for ordinary single-agent debugging.
---

# Engineering Investigation Subagents

Use this skill to delegate small, bounded investigation roles without inventing a fresh prompt each time.

## Delegation Rules

- Use these prompts when the user explicitly asks for subagents, delegation, or parallel work, or when the host agent's active policy permits delegation.
- Prefer a read-only investigator for diagnosis. Use an editing agent only when it has a clear, disjoint write scope.
- Keep the main agent on the critical path. Delegate sidecar questions that can run in parallel.
- Give the subagent concrete inputs: failing command, log excerpt, changed files, tool name, repo path, or suspected surface.
- Ask for evidence and next actions, not broad architecture essays.
- If an editing agent changes files, remind it that it is not alone in the codebase and must not revert unrelated changes.

## Prompt Playbooks

- `references/ci-failure-triage.md`: use for CI, build, lint, typecheck, test, or flaky failure investigation.
- `references/mcp-transport-investigator.md`: use for MCP tool failures, transport closes, app-backed versus standalone confusion, mutating tool failures, and diagnostics/log interpretation.

## Expected Subagent Output

Ask each subagent to return:

- Finding summary.
- Evidence with file paths, log lines, or commands.
- Likely root cause and confidence.
- Minimal recommended fix or next check.
- Residual risk.
