# Uimori improvement-loop playbook

This is a short operating guide for **Lia (리아)** running the Uimori improvement loop from an interactive Claude Code / Claude Duet session on Jaeyeon (재연님)'s PC, the way **Ui (우이)** ran it. **Jaeyeon (재연님)** steps in only for releases, disagreements between agents, or UI judgment.

- Repo: `C:\Users\wodus\ai-workspace\uimori` (`woduseh/Uimori`)
- Keep this file in `agents-dotfiles`. Do not commit it to the Uimori repo.

## Roles

- **리아 (coordinator session)**: Runs the loop. Calls 니아, re-runs every gate herself, reviews diffs, commits, pushes after 니아's review, and reports to 재연님. Implements small units (one or two files) directly in this session.
- **리아 (development sessions)**: One fresh session per larger unit, started with T3 `delegate_task` (provider `claudeAgent`) so 재연님 can open and watch the thread. Fall back to `claude -p` with a log file path only if `delegate_task` is unavailable. The coordinator does not take a development session's "gates passed" on trust; she re-runs them.
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

Check 리아's and 니아's 5-hour quota with `/usage` before and after each unit. From a shell, run `claude -p "/usage"` and `agy -p "/usage" --output-format text` in PowerShell; Git Bash rewrites `/usage` into a path and sends it as an ordinary prompt. **Pause if less than about 20% of the 5-hour window remains.** Report quota percentages, never API-equivalent dollar amounts. Start a fresh coordinator session per wave: update this file and hand off at each wave's end. Development sessions are one per unit.

Revisit the split (agreed with 재연님 on 2026-11-27): if the coordinator ends up reworking a development session's result in more than half the units, implement directly; if one unit costs the coordinator more than 20% of her 5-hour window, delegate more.

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

- The timings ledger still comes from pre-Wave 1 runs (`sourceRuns` 44729063248, 44730617062, 44736850258); 6 of 349 files sit at the default weight of 1 (checked 2026-11-27).
- Server-side deletion of unseen older helper messages is not independently verified.

### Wave 1: closed (2026-11-27 KST)

재연님's decisions: move `browser-full` to Ubuntu and make PR runs impact-based; collapse `verify:*` into one `npm run verify -- <domain>`. The old aliases are now gone; use `npm run verify -- all` where older notes say `verify:browser`.

`origin/main` HEAD is `0b41f164`:

- `04490ef7` test(helper): split helper-browser into four files and keep 14 cases (27 → 14, deliberate)
- `38ca11c3` test(tooling): add feature-map and require every browser spec (also moved CODE-MAP case pointers to `tests/feature-map.json`)
- `bd55b53d` feat(tooling): add a single verify command driven by the feature map
- `862f1000` feat(ci): share check-changed selection with impact-based Vitest
- `05af2c9c` ci: move browser-full to Ubuntu and make PR runs impact-based
- `f9d87758` chore(tooling): remove verify:* aliases and select release areas from the feature map (finished the interrupted session's `release-check.mjs` work)
- `0b41f164` fix(tooling): keep release checks synthetic and pass runners only their options (니아 review follow-up)

Evidence:

- CI `Quality` success for every commit above. Ubuntu `browser-full` 3/3 passed on `05af2c9c` (manual dispatch run 45914422402). `0b41f164` push run 45919085428 succeeded; browser-full is skipped on ordinary pushes by design.
- Local on `0b41f164`: `npm run verify -- all` 333 passed (346 in Wave 0 minus the 13 helper cases dropped in `04490ef7`); `npm test` 2856 passed; `test:tooling` 188 passed; quality, check-documentation, unit-diff and check:changed passed.
- 니아 reviewed all seven commits (REQUEST_CHANGES → fixed in `0b41f164`), then re-reviewed `0b41f164`: **APPROVE**. 리아 re-ran unit-diff (37 → 39 cases), quality, check-documentation, `git diff --check`, check:changed and test:tooling on it; all passed.

니아's non-blocking notes from the re-review:

- `runOptions` in `scripts/verify.mjs` drops every option the runner does not list, so `verify -- self-host --grepp SH01` runs all of self-host instead of failing. Left for the runner-interface idea below.
- `check-documentation` now treats a leading `ns:name` word with arguments as a script name; an inline token like `build:latest --tag` would be a false positive (none today).
- `privateMaterialEnv` reads `defaults.launch` and `entry.launch` separately while `launchOf` merges them; same result today.

Cleaned up: pids 31168, 28832, 33904 were already gone; `%TEMP%\uimori-w1*` deleted (the reviews remain in 니아's conversation).

Open from 니아's review, for 재연님:

- `npm run verify -- risu` still runs the private CHARX spec whenever `UIMORI_RISU_SAMPLE_ROOT` is set, and that route skips the `UIMORI_RISU_SAMPLE_DIAGNOSTIC=1` refusal that `scripts/verify-risu-native-samples.mjs` enforces. Release checks are now protected; the direct domain route is a design choice from `bd55b53d`.
- `ci-vitest.mjs 1/1 --dist-only` exits 0 on an empty selection, and `ci-summary.mjs` does not read `vitest-dist-1`.

After Wave 1: design Phases 1–4 together with Wave 2. Starting a phase, and adding a new devDependency, needs 재연님's approval.

Design-phase sketch: (1) `packages/`, contracts, structured errors; (2) Schema v16 and dismantling `Store`; (3) `TaskRuntime`, `AgentLoop`, Helper Domain Command; (4) frontend (TanStack Query, SSE, router).

### Unapproved ideas (ask 재연님; do not implement yet)

- A light CI path for PRs that only touch root `docs/*.md`.
- Use the 1-hop import graph as the sole tooling-test selector.
- Drop the Vitest double boot by running via `runTestSpecifications`.
- Flatten `verify.mjs`'s three run kinds into one runner interface that takes parsed options instead of rewriting `process.argv`, and declare per-runner options and env guards in the feature map (니아).
- One change classifier shared by `ci-changes.mjs`, `check-changed.mjs` and `verify.mjs` (니아).
- Run feature-map domains selected by `verify -- --changed <base>` in PR CI, capped by spec count (니아; decide after the first real PR run).
- Refresh `scripts/ci-vitest-timings.json` from the first post-`05af2c9c` Linux `main` artifact.
- A `.dockerignore` ↔ `buildFingerprint()` invariant test.
- A shared `tests/fixtures/story-scale.ts`.
- Multi-run median timings plus `assertPartition`.
- Move the U6 helpers out of React files before design Phase 4.

니아's source plans and reviews are named `test-ci.md`, `design.md`, `feedback-1.md`, plus per-unit review JSON.
