---
name: release-prep
description: "Prepares software releases and readiness reviews: version bump, changelog, docs, CI and test selection, risk list, and final checklist. Use for release prep, 1.0.0 readiness, release-tied changelog or docs updates, version planning, or pre-release validation; ordinary code changes need no skill."
---

# Release Prep

## Workflow

1. Establish the release target: intended version, release type, repo/package surface, and whether the user wants only a readiness review or actual edits.
2. Load local project rules before deciding versioning or CI. Prefer repo guidance such as `AGENTS.md`, release docs, package manifests, changelog, README, CI workflows, and contributor docs.
3. Inspect the current state: worktree status, package versions, changelog top entry, README badges or install commands, CI scripts, and recent relevant changes.
4. Decide the version and docs contract. For source or tooling changes, keep package manifests, lockfiles, changelog, and user-visible docs in sync. Do not tag, publish, or push unless explicitly asked.
5. Validate narrowly first, then broaden based on risk. Typical checks include lint, typecheck, unit tests, build, packaging dry runs, MCP/eval tests, or frontend/browser checks when those areas changed.
6. Produce a release readiness summary with blockers, remaining risks, commands run, files touched, and the exact next release action if one remains.

## Defaults

- Treat changelog and docs as release artifacts, not afterthoughts.
- Prefer the existing project versioning rules over generic semver guesses.
- Keep release notes concise and user-facing.
- Separate "ready to merge" from "ready to publish" when packaging, signing, store upload, or tags are still pending.
- If checks fail, switch to triage: identify the first meaningful failure, map it to likely cause, and propose the smallest fix. Report the failing output itself; never mark a check as passed without its result.

## Output Contract

End with:

- Target version or release label.
- Files changed or inspected.
- Validation performed.
- Blockers and residual risks.
- Next action, only if useful.
