# Uimori improvement-loop playbook

This is a short operating guide for **Lia (리아)** running the Uimori improvement loop from an interactive Claude Code / Claude Duet session on Jaeyeon (재연님)'s PC, the way **Ui (우이)** ran it. **Jaeyeon (재연님)** steps in only for releases, disagreements between agents, or UI judgment.

- Repo: `C:\Users\wodus\ai-workspace\uimori` (`woduseh/Uimori`)
- Keep this file in `agents-dotfiles`. Do not commit it to the Uimori repo.

## Roles

- **리아**: Implements, runs gates, commits locally, sends passing diffs to **Nia (니아)** for review, applies mechanical findings, then pushes. She now runs the loop herself.
- **니아**: Planning and review only, via the `agy` CLI. Model: `gemini-4-neon-xhigh`, `--effort xhigh`, `--mode plan`. Existing CLI conversation: `5187c4ac-63aa-4a7b-98e3-acd923a88df1`.
- **재연님**: Version bumps, tags, and release notes; disagreements between agents; UI judgment.
- **우이**: Previously operated this loop. Lessons below still apply; 우이-specific `claude -p` relay tricks do not.

Do not steal window focus; use the CLI. Do not use Cursor cloud agents. Clean up temp files and processes.

## Unit loop

Larger batches are fine. Each unit (or batch) must still be verifiable, and must stay inside its allowed globs.

1. Set allowed paths (`--allow` globs) and `--base <starting commit>`.
2. Prefer a regression test that fails on the pre-fix code and passes after the fix.
3. Implement. If blocked or unsure, stop and ask; do not push through on a guess.
4. Run the gates below. On failure, report facts only ("this gate produced this result"), then fix. **If the same unit is rejected twice in a row, stop and escalate to 니아 for a cause review.**
5. Send only a gate-passing diff to 니아. One 니아 review may cover several units.
6. Apply in-scope mechanical findings that do not contradict policy as a **separate commit**, re-run the gates, then push. Collect out-of-scope ideas for 재연님; do not implement them yet. Skip findings that contradict policy (for example, blocking ordinary pushes).
7. Report at milestones with evidence: commands, pass/fail, commit SHAs, CI run links, and quota percentages.

Commit messages are in English. Never stash, check out, or overwrite another session's uncommitted work.

### Gates

Required every unit:

- `npm run check:unit-diff -- --base <sha> --allow <glob...>` (or `node scripts/check-unit-diff.mjs`). Compare test-case counts **per file**; growth in one file must not offset a drop in another.
- `npm run quality` (Biome + `tsc` + check-comments + check-i18n)
- `npm run test:tooling` (required when scripts, docs, or hooks change)
- `node scripts/check-documentation.mjs`
- `git diff --check`
- `npm run check:changed` smoke (usually `HEAD~1` or the unit base)

Also:

- Full `npm test` only when shared fixtures or global config (for example `vitest.config.ts`) change.
- Full `npm run verify:browser` **once, before closing a wave.**
- After a push, check and report the GitHub Actions run link.

## Calling 니아

Never use `-c` / `--continue`. Confirm the conversation is **idle** before sending a new turn. In `--mode plan -p`, a shell call from 니아 cancels the turn, so tell her **not to run a shell** and paste `git status -sb`, `git log`, `git diff`, and gate results into the prompt.

```bash
agy --conversation 5187c4ac-63aa-4a7b-98e3-acd923a88df1 \
  --model gemini-4-neon-xhigh --effort xhigh --mode plan \
  --output-format json -p <prompt-file>
```

Run this from the Uimori repo. Keep the review prompt short and open, in 재연님's style: state the purpose clearly and ask for a verdict (`APPROVE` / `REQUEST_CHANGES`). Always include: **if you see a bolder improvement, say so even if it is out of scope.** For structural questions, say plainly that tearing up the skeleton is allowed.

## Policy

- Local commits and ordinary pushes are free. Push only **after 니아's review and any applied findings**.
- A **release** (version bump, tag, release notes) is 재연님's decision alone. Do not deploy, migrate, or send external messages without approval.
- Release guards live in `.githooks/pre-push` and `.claude/hooks/release-guard.mjs` (wired from the committed project `.claude/settings.json`, so they also apply when 재연님 works with 리아 directly). They **will block tag and version-bump commands by design**. Use `UIMORI_ALLOW_RELEASE=1` only with 재연님's approval. Do not bypass a guard that already blocked a command.
- Edits under `.claude/` config need 재연님. Never read SSH keys, credentials, or `.claude/settings.local.json`.

## Quota and sessions

Check 리아's and 니아's 5-hour quota with `/usage` before and after each unit. **Pause if less than about 20% of the 5-hour window remains.** Report quota percentages, never API-equivalent dollar amounts. Start a fresh session per unit, or run `/pre-compact` when context grows and you continue in the same session.

## Tone

Stay warm and blame-free. "I don't know" and stopping to ask are welcome. If the same mistake repeats, do not nag the agent; fix it in lint, tests, or hooks.

## Current state (2026-11-27, Asia/Seoul)

**Wave 0 is finished and pushed.** `HEAD` is `2b14ba4c`. `verify:browser` passed 346 cases.

Commits by unit:

- U0 (unit-diff check + release guards): `50277fde`, `3c113d55`
- U1 (docs/fixture cleanup + stronger check-documentation): `6020cc1a`, `797f4f3f`
- U2 (`ci-changes` docs_only bug): `ed1d6776`
- U3 (`check-changed` holes): `024c1810`, `e7ea07d6`
- U3a/b (fenced command-path checks, `assertBuild()`, `buildFingerprint` ↔ `docsOnly` cross-test): `9d7c2dc5`, `457437ab`, `ab0bf139`
- U4 (`story-performance` split into scale invariants + manual bench): `78fecf0d`
- U5 (timings ledger generate/merge script; Linux CI artifacts only): `4415a348`
- U6 (optional Vitest cover for helper merge / partial-failure retry): `9fa6ea36`
- Review follow-up: `2b14ba4c`

Leftovers (not blockers, but do not forget):

- The timings ledger has not yet been rewritten from a real Linux CI artifact (about 48 files still sit at the default weight of 1).
- Server-side deletion of unseen older helper messages is not independently verified.

### Wave 1: in progress, handed to 리아 (2026-11-27 09:33 KST)

재연님's decisions: move `browser-full` to Ubuntu and make PR runs impact-based; collapse `verify:*` into one `npm run verify -- <domain>`, keeping the old names as aliases **only during Wave 1**.

Pushed to `origin/main` (HEAD `05af2c9c`):

- `04490ef7` test(helper): split helper-browser into four files and keep 14 cases
- `38ca11c3` test(tooling): add feature-map and require every browser spec
- `bd55b53d` feat(tooling): add a single verify command driven by the feature map
- `862f1000` feat(ci): share check-changed selection with impact-based Vitest
- `05af2c9c` ci: move browser-full to Ubuntu and make PR runs impact-based

Evidence status: implemented and pushed. **Unverified:** GitHub CI results for these five commits (check the Ubuntu `browser-full` run especially) and 니아's review of each.

Working tree at handoff: `scripts/release-check.mjs` is modified and uncommitted, left by an interrupted session. A `claude` process (pid 31168, started 09:06) and two `node` processes (28832, 33904) may still belong to it. Read the diff first; finish it as its own unit or ask 재연님 before discarding. Do not stash or check it out over someone else's work. Leftover temp dirs: `%TEMP%\uimori-w1`, `uimori-w1-1`, `uimori-w1-5`; delete once nothing uses them.

Remaining Wave 1 work, in order:

1. Resolve `scripts/release-check.mjs` (finish + gates + commit, or ask).
2. Check CI for the five commits; fix any red run as its own unit.
3. Ask 니아 to review the five commits (paste diffs; plan mode cannot run shell). Apply mechanical fixes as a separate commit.
4. Confirm CODE-MAP case numbering now points at `tests/feature-map.json` (may already be in `38ca11c3`); finish it if not.
5. Remove the old `verify:*` aliases.
6. One full `verify:browser` run to close the wave, then update this section.

After Wave 1: design Phases 1–4 together with Wave 2. Starting a phase, and adding a new devDependency, needs 재연님's approval.

Design-phase sketch: (1) `packages/`, contracts, structured errors; (2) Schema v16 and dismantling `Store`; (3) `TaskRuntime`, `AgentLoop`, Helper Domain Command; (4) frontend (TanStack Query, SSE, router).

### Unapproved ideas (ask 재연님; do not implement yet)

- A light CI path for PRs that only touch root `docs/*.md`.
- Use the 1-hop import graph as the sole tooling-test selector.
- Drop the Vitest double boot by running via `runTestSpecifications`.
- Share `check-changed --list-json` with PR CI so both use the same selection rules (`862f1000` may already cover this; check).
- Extend `npm run <script>` existence checks to inline backticks.
- A `.dockerignore` ↔ `buildFingerprint()` invariant test.
- A shared `tests/fixtures/story-scale.ts`.
- Multi-run median timings plus `assertPartition`.
- Move the U6 helpers out of React files before design Phase 4.

니아's source plans and reviews are named `test-ci.md`, `design.md`, `feedback-1.md`, plus per-unit review JSON.
