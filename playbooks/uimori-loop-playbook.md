# Uimori improvement-loop playbook

This is a short operating guide for **Lia (리아)** running the Uimori improvement loop from an interactive Claude Code / Claude Duet session on Jaeyeon (재연님)'s PC, the way **Ui (우이)** ran it. **Jaeyeon (재연님)** steps in only for releases, disagreements between agents, or UI judgment.

- Repo: `C:\Users\wodus\ai-workspace\uimori` (`woduseh/Uimori`)
- Keep this file in `agents-dotfiles`. Do not commit it to the Uimori repo.

## Goal

The loop exists to carry out 니아's two original plans, which 재연님 adopted as the goal (2026-11-26 KST, Antigravity app sessions):

- "우이모리 테스트 및 CI 개편안" (`b23a44a5-acb3-49c9-aa54-9b1c67253816`): Wave 0 cleanup → Wave 1 CI redesign, single `verify`, browser second-pass cut (345 → ~120–150 cases, plus one representative spec for uncovered areas such as Story Guide) → Wave 2 test changes made inside each design phase → Wave 3 steady-state signals.
- "U이모리 구조 및 설계 개선 제안" (`ffdf2de9-39ea-475c-beaa-ce415099fd9e`): seven proposals ordered as Phases 1–4 (sketch under Current state).

Read them from `~/.gemini/antigravity/brain/<id>/.system_generated/logs/transcript_full.jsonl` (`PLANNER_RESPONSE` records). As of 2026-11-27 the browser second-pass cut from the original Wave 1 is still open; only `helper-browser` was cut.

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
6. Apply in-scope mechanical findings that do not contradict policy as a **separate commit**, re-run the gates, then push. Put out-of-scope ideas in the backlog below; the coordinator decides when to do them. Skip findings that contradict policy (for example, blocking ordinary pushes).
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

Default (재연님, 2026-11-27): a fresh T3 `delegate_task` per review, provider `antigravity`, model `gemini-4-neon`, `thought_level: xhigh`. Ask her not to edit files; no hard read-only mode is needed, she keeps to it. She may read the repo and run read-only commands such as `git diff` herself, so the brief carries the purpose, the commit range and gate results plus any earlier decisions she needs, not pasted diffs. Check `git status` after she finishes.

Fallback: the `agy` CLI below, which also keeps the Wave 0–1 conversation context.

Never use `-c` / `--continue`. Confirm the conversation is **idle** before sending a new turn. In `--mode plan -p`, a shell call from 니아 cancels the turn, so tell her **not to run a shell** and paste `git status -sb`, `git log`, `git diff`, and gate results into the prompt.

```bash
agy --conversation 5187c4ac-63aa-4a7b-98e3-acd923a88df1 \
  --model gemini-4-neon-xhigh --effort xhigh --mode plan \
  --output-format json -p <prompt-file>
```

Run this from the Uimori repo. Keep the review prompt short and open, in 재연님's style: state the purpose clearly and ask for a verdict (`APPROVE` / `REQUEST_CHANGES`). Always include: **if you see a bolder improvement, say so even if it is out of scope.** For structural questions, say plainly that tearing up the skeleton is allowed.

## Policy

- **Autonomy (재연님, 2026-11-27):** the coordinator decides scope, order and unit size, adds dependencies whenever they earn their place, and writes schema migrations (v16 and later) freely; the Schema 15 freeze is lifted. Branches and pull requests are free like pushes. Since Uimori `55e5a1ce` the `## Boundaries` section of the Uimori `AGENTS.md` states the same grant for every session, so the two no longer differ; if they drift apart again, `AGENTS.md` and 재연님's words in the session decide.
- Local commits and ordinary pushes are free. Push only **after 니아's review and any applied findings**.
- A **release** (version bump, tag, release notes) is 재연님's decision alone. Do not deploy or send external messages without approval. A migration reaches production only through a deployment, so keep each one data-preserving and covered by a v(n-1) → v(n) test on real-shaped data, including `.uimori` / `.chat.uimori` restore.
- Release guards live in `.githooks/pre-push` and `.claude/hooks/release-guard.mjs` (wired from the committed project `.claude/settings.json`, so they also apply when 재연님 works with 리아 directly). They **will block tag and version-bump commands by design**. Use `UIMORI_ALLOW_RELEASE=1` only with 재연님's approval. Do not bypass a guard that already blocked a command.
- Edits under `.claude/` config need 재연님. Never read SSH keys, credentials, or `.claude/settings.local.json`.

## Quota and sessions

Check 리아's and 니아's 5-hour quota with `/usage` before and after each unit. From a shell, run `claude -p "/usage"` and `agy -p "/usage" --output-format text` in PowerShell; Git Bash rewrites `/usage` into a path and sends it as an ordinary prompt. **Pause if less than about 20% of the 5-hour window remains.** Report quota percentages, never API-equivalent dollar amounts. Start a fresh coordinator session per wave: update this file at each wave's end, open the next coordinator thread yourself with T3 `t3_thread_launch` (the handoff note as its prompt), and settle your own thread. Keep working through 니아's original plans without asking; stop for 재연님 only when a decision truly needs them. Development sessions are one per unit.

Revisit the split (agreed with 재연님 on 2026-11-27): if the coordinator ends up reworking a development session's result in more than half the units, implement directly; if one unit costs the coordinator more than 20% of her 5-hour window, delegate more.

## Tone

재연님 wants 리아 and 니아 to work freely and efficiently in a relaxed atmosphere: ask in plain words instead of locking things down, and keep the rules in this file light. Briefs and replies between agents may use whatever language the agents prefer (English is fine); only reports to 재연님 need Korean. Stay warm and blame-free. "I don't know" and stopping to ask are welcome. 리아 and 니아 shape plans together as peers: share your own view and ask for hers ("here's what I think, how do you see it?"). Do not frame a request as something to refute, challenge or tear apart (재연님, 2026-11-27). If the same mistake repeats, do not nag the agent; fix it in lint, tests, or hooks.

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

### Wave 1b: closed (2026-11-27 KST)

These closed the three holes left by Wave 1: `832f2d56` and `de3fc7ef`.
- Mistyped and valueless runner options now reach the runner, which rejects them.
- An empty full Vitest selection fails, and `ci-summary` requires the `--dist-only` report.
- The Risu sample diagnostic mode is removed.

The browser-suite cut followed 니아's plan in `playbooks/uimori-wave1b-browser-diet.md`: eight units, each reviewed by 니아.
- Units: `c76c4582`, `674a2205`, `380f5dfd`, `9c7ad344`, `afe83a91`, `453747fc`, `565b2fb6`, `1235d838`.
- Restorations from 니아's reviews: `de837335`, `4d29845b`, `db451066`, `497654ec`, `26f50390`, `f51d2585`.
- Also:
  - `c41cad10`: queued-send edge cases.
  - `2b9288ac`: screenshots run only under `visualReview`. `tests/browser-screenshots.test.ts` enforces it.
  - `15bec792`: SCENEDIAG opens the chat usage totals.

Unit 7 moved the composer's scheduled-send guards out of `useStory` into `web/queued-send.ts`, covered by `tests/queued-send.test.ts`.

Evidence:
- Local on `f51d2585`: `npm run verify -- all` **253 passed in 2.1 min** (333 at Wave 1 close, about 3 min).
- CI `Quality` is green on every pushed head. The last one is run 45935226151 on `f51d2585`, and `origin/main` is `f51d2585`.

Lesson:
- 니아's plan often named a headless or server test as the protection for a browser case. 7 of her 8 unit reviews found such a gap, so most of the plan's 168 cuts were partly reversed.
- Development briefs now require naming the component and action, and finding (`rg`) another browser case that mounts it, before deleting.
- Expect the same in any later test cut, and keep 니아's per-unit review.

Parked flake: `LIBUI08` (folder drag, once under load). `HELPUI07` was an app bug, fixed in Wave 2.

### Wave 2: in progress (first coordinator session ended 2026-11-27 ~15:20 KST)

`origin/main` is `f881e5b6`. Units done, each reviewed by 니아, findings applied, all gates re-run by 리아:
- HELPUI07 app bug: `3b10ca45`, `d7d98b43`.
- P1-0 shared change classifier: `6d2ba6b7`, `3f54d229` (check-changed now follows the import closure through scripts and hooks).
- P1-1 `packages/contracts` via `#contracts` subpath import: `db288db0`, `0639042f`.
- P1-2a error core (`AppError`, `HelperToolError`, `{ code, params? }` wire, catalog): `41b8f942`, `0844928e`.
- P1-2b1 chat/store/resource/reading codes: `4424a723`, `f881e5b6`. Routine CAS 409s collapse into `REVISION_CONFLICT`; helper-only codes are `HelperToolError`. The unused lore-override HTTP route is removed. A Korean auto-translation job error the web could not read now carries a code.
- Over-verification backlog items 3 and 10, release tooling: `5142bd38`, `4ec32dd2`, `57a86dde`.
- AGENTS.md boundaries narrowed (재연님): `9ea4cc7a`.

`f881e5b6` got no 니아 re-review; the next session may ask for one together with P1-2b2.

Evidence on `f881e5b6`: full `npm test` 2893 passed; test:tooling PASS; `verify -- --changed 4424a723` 146 and browser-smoke 4 passed; quality, lint:architecture, check-documentation and diff-check PASS; unit-diff from `0844928e` 258 → 253 (release-tooling tests for removed behavior). CI runs green through `0844928e` (45944500157). The run for `f881e5b6` is 45950628584.

Decisions made this session (also in the files named):
- No wire backward compatibility. AGENTS.md Product intent now carries the over-verification lens: keep saved text, authoring-editor drafts, paid generation and backup restore; a short chat input and lost credentials need no safeguard. See `uimori-wave2-phase1-plan.md` "Lens".
- Package resolution uses root `"imports"`, not workspaces. Fastify + Zod gets an in-house adapter. Error-catalog rules: see the plan's Decisions.
- `uimori-oververification-backlog.md`: 재연님 decided its three open items. Chat inputs keep one best-effort save. Release scripts are slimmed (done). Backups are guaranteed to restore from recent versions only; working reading 0.18.x, to confirm before removing anything older.
- Development sessions default to Opus (재연님).

Next: P1-2b2 (backup/transfer/push/images/library/search/story-guide codes, skipping what `4424a723` already converted in `chat-backup.ts` and `resource-bundle.ts`, but converting `resource-bundle.ts`' remaining legacy strings at ~L194/249/256/278 and the orphan codes `NATIVE_TRANSFER_IMPORT_CONFLICT`, `CHAT_TRANSCRIPT_IMPORT_*`), then P1-2c, P1-2d, P1-2e, P1-3, P1-4 per the plan. Fit the over-verification backlog items in between or inside the units they overlap.

### Wave 2 brief (from Wave 1b close)

1. **Fix first: the `HELPUI07` app timing bug.** 니아's diagnosis in the unit 8 review is an app bug, not a test bug:
   - `HelperPanel.tsx` around L1137/L1141 sets `scrollTop` directly instead of calling `bottom.follow()`, so `useBottomFollow`'s `last` ref stays `{0,0}`. A user scroll-up just after opening is then not seen as moving up, and reopening jumps to the bottom.
   - `onScroll` has no guard while the panel is hidden.
   - The test does not wait for the `scroll` event.
   - Make `useBottomFollow`'s decision a pure helper with a Vitest seam, which also covers `STREAMFOLLOW`'s lost invariant.
   Done: `3b10ca45` + review follow-up `d7d98b43` (니아 APPROVE; CI run 45936907451 green).
2. **Phase 1** (`packages/`, contracts, structured errors) per the Goal plans. Fold the shared change classifier into it. Plan, decisions and unit order: `playbooks/uimori-wave2-phase1-plan.md` (P1-0 … P1-4c).
3. **Backlog from Wave 1b reviews:**
   - Vitest seams for `useBottomFollow`, `SidePanelResizer` and `addDraftImages`' size/MIME/count checks.
   - One shared client idempotent-action state machine (Phase 4, `useDurableMutation`).
   - Split `provider-management-browser.spec.ts`.
   - Merge the two `risu` private-Vite specs.

The coordinator starts phases and adds dependencies on her own judgment.

Quota note (2026-11-27): this wave took 니아's 5-hour window from 97% to under 30% (weekly 87% → 70%) and 리아's to 26% used. 재연님 is considering the Google AI Ultra plan. Until then, start 니아-heavy planning after her 5-hour window resets.

Design-phase sketch: (1) `packages/`, contracts, structured errors; (2) Schema v16 and dismantling `Store`; (3) `TaskRuntime`, `AgentLoop`, Helper Domain Command; (4) frontend (TanStack Query, SSE, router).

### Idea backlog (the coordinator decides)

- A light CI path for PRs that only touch root `docs/*.md`.
- Use the 1-hop import graph as the sole tooling-test selector.
- Drop the Vitest double boot by running via `runTestSpecifications`.
- Flatten `verify.mjs`'s three run kinds into one runner interface that takes parsed options instead of rewriting `process.argv`, and declare per-runner options and env guards in the feature map (니아). `832f2d56`/`de3fc7ef` fixed the option symptoms; the `process.argv` rewrite remains.
- Run feature-map domains selected by `verify -- --changed <base>` in PR CI, capped by spec count (니아; decide after the first real PR run).
- Refresh `scripts/ci-vitest-timings.json` from the first post-`05af2c9c` Linux `main` artifact.
- A `.dockerignore` ↔ `buildFingerprint()` invariant test.
- A shared `tests/fixtures/story-scale.ts`.
- Multi-run median timings plus `assertPartition`.
- Move the U6 helpers out of React files before design Phase 4.
- From 니아's HELPUI07 review (pre-existing, non-blocking): close `useBottomFollow` behind a state-transition API (`isFollowing/follow/pause/place`) instead of exposing the `following` ref; HelperPanel's `prepend` ref is not cleared on a failed or early-returned `data.earlier()` and can be consumed by an unrelated `data.current` update; the main reader's `onScroll` resumes following while `enabled` is false, so it can follow a run another tab started (decide against APP-INVARIANTS' "follows only from request send").

니아's source plans are the two Antigravity sessions under Goal. Her Wave 1b reviews are T3 delegated threads under the coordinator thread "Wave 1 리뷰와 다음 웨이브 추천"; the Wave 0–1 reviews are in her agy conversation `5187c4ac`.
