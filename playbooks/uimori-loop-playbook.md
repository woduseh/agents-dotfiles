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

- **리아 (coordinator session)**: Always Claude Fable 5.2 at `high` effort, also for every later coordinator session (재연님, 2026-11-28); open the next coordinator thread with `t3_thread_launch` and `modelSelection` `claude-fable-5-2` / `effort: high`. Runs the loop. Calls 니아, re-runs every gate herself, reviews diffs, commits, pushes after 니아's review, and reports to 재연님. Implements small units (one or two files) directly in this session.
- **리아 (development sessions)**: One fresh session per larger unit, started with T3 `delegate_task` (provider `claudeAgent`) so 재연님 can open and watch the thread. Fall back to `claude -p` with a log file path only if `delegate_task` is unavailable. The coordinator does not take a development session's "gates passed" on trust; she re-runs them.
- **니아**: Planning and review only, via the `agy` CLI. Model: `gemini-4-neon-xhigh`, `--effort xhigh`, `--mode plan`. Existing CLI conversation: `5187c4ac-63aa-4a7b-98e3-acd923a88df1`.
- **재연님**: Version bumps, tags, and release notes; disagreements between agents; UI judgment.
- **우이**: Previously operated this loop. Lessons below still apply; 우이-specific `claude -p` relay tricks do not.

Do not steal window focus; use the CLI. Do not use Cursor cloud agents. Clean up temp files and processes.

## Unit loop (faster loop, adopted 2026-11-28 with 재연님)

Why it changed: in Wave 2, 17 of 19 first reviews were REQUEST_CHANGES; the two first-time APPROVEs were the only units with 니아's trap notes written before implementation. Finished units also waited 15–22 min for a fix session holding the main checkout, and full gates ran twice per unit on drafts that review then changed. The first round under this loop (P1-3c1 fixes + `UiMessage` 2a) got `APPROVE_AFTER_FIXES` and was pushed without a re-review.

1. **Pre-flight (parallel, off the critical path).** While unit N builds, a fresh 니아 thread writes a 15–20 line trap memo for N+1: every non-HTTP caller of the functions it will touch (`resource-service`, `helper-*`), stale-tab/revision-order traps, web parse/snapshot/fallback traps, strict-schema caller traps, over-verification to remove, and which files N+1 shares with parallel lanes. Paste the memo into N+1's brief. 니아 may also split a unit (she split the mechanical-check unit into Y-A and Y-B).
2. **Develop in a worktree, branch until approved.** Every dev and fix session works in a T3 worktree (`delegate_task` `isolation: "worktree"`); the main checkout only takes integration. Up to 2–3 parallel lanes for units that share few files. Homogeneous conversions (remaining P1-3 route groups, `UiMessage` 2b domains) go 2–3 per unit; a new mechanism stays alone. Briefs keep: bold ideas welcome, what 니아 found last time, a failing-on-old regression test for every behavior fix, the over-verification lens.
3. **Tier 1 (dev session, before handing back):** `npm run quality`, `npm run build`, `npm run check:changed -- <base> --all`, `npm run check:unit-diff -- --base <base> --allow <glob> …` (one glob per `--allow`; per-file counts), `npm run verify -- --changed <base>` (one or two domains per call on Windows), `npx playwright test --list`.
4. **니아 reviews the worktree branch directly** (fresh thread; she reads the branch, no pasted diffs). Verdicts: `APPROVE`; `APPROVE_AFTER_FIXES` (1–3 local, mechanically checkable fixes with a checklist: the dev fixes them with regression tests, 리아 checks, no re-review); `REQUEST_CHANGES` (design/state/multi-file: re-review). Fixes go back to the **original dev thread** with `t3_thread_send` (it holds the unit's context); a second rejection or a bloated thread gets a fresh session. **If the same unit is rejected twice in a row, ask 니아 for a cause review.**
5. **Tier 2 (리아 on `main`, once, after approval):** cherry-pick, `npm ci` if the lockfile changed, `quality`, `build`, `check:changed -- <prev-main> --all`, `verify -- --changed <prev-main>`, `playwright test --list`, `check-documentation`, `git diff --check`; `node scripts/test-tooling.mjs` only when scripts/docs/hooks changed (`npm run test:tooling` builds again). Then push and check the Actions run.
6. **Full runs:** full `npm test` only when `check:changed` prints `scope: full-required` or at a wave's end (CI runs 4 Vitest shards on every push). `verify -- all` only when `verify` reports an input no feature-map domain covers (shared UI/error core), every 4–5 units, at a wave's end, or via the CI `browser-full` dispatch.
7. Out-of-scope findings go to `uimori-oververification-backlog.md`; skip findings that contradict policy. Report to 재연님 at milestones with commands, pass/fail, SHAs, CI links and quota.
8. **Mechanical checks first:** when a defect class repeats, turn it into an API change, lint rule or contract-walking test before adding prose (Y-A: `allEndpoints` stale-tab matrix; Y-B: `ProductStore.get` → `stored`, `useConfirmAction`, `JSON.parse` split).

**How a unit runs now (fifth coordinator session, 2026-11-28; supersedes steps 3–5 above where they differ):**
- Dev session in a T3 worktree (`npm ci` runs on creation) → Tier 1 → **self-closing lane**: the dev starts its own cross-family reviewer with `docs/dev/REVIEW-RUBRIC.md` quoted verbatim + its "Brief"; applies `APPROVE_AFTER_FIXES`; stops and reports on `REQUEST_CHANGES` or a contested fix (리아 decides the design, the dev continues, a **fresh** reviewer re-reviews); then rebases, pushes, opens a PR without auto-merge.
- 리아 reads the reviewer thread (a short read is enough), runs `gh pr update-branch <n> --rebase` if behind, and enables auto-merge (`pull_request_merge`, `auto: true`, `method: rebase`, full head SHA). PR CI (`quality`, strict) replaces the local Tier 2. Don't link/watch PRs from the coordinator thread (merge would settle it); link them to the dev thread.
- Reviewer tiers: 니아 `high` for homogeneous conversions, `xhigh` for new mechanisms/state/server contracts. Lever 4 (same 니아 thread for pre-flight and review) missed the one defect in a departure from her own memo; always add a short independent 시아 (Codex `gpt-6.2-sol`, high) check when using it. 시아 so far: 2 real defects 니아 missed, no noise.
- Sonnet 5.5 is enough for homogeneous conversion lanes (2 of 2 matched Opus).
- Parallel lanes that all touch a shared ratchet file (`scripts/ui-message-allowlist.json`): land them as **one integration PR** (cherry-pick each lane, regenerate with `--shrink` after each, `npm run quality`, PR, close the superseded PRs) instead of serial update-branch + conflict rounds.
- **Plan-review rules (2026-11-28, supersede the reviewer tiers above):** risk-tiered review, pre-existing non-protected defects listed only, fail-first tests only under CHECKS' keep criteria, paid-generation code open to bold redesign within AGENTS.md's boundary, gate PRs auto-merge after review, worktrees deleted right after merge. Full list in `uimori-STATE.md` "Loop rules".

**How work is shaped (2026-11-28 evening; 재연님 asked 리아 and 니아 the same question and wanted the two views merged; supersedes the unit-shaping parts above where they differ).** Evidence: 24 PRs in one day; on protected or design-heavy units a reviewer of another family found real defects almost every time, mechanical units passed first review whoever built them, and the day's most valuable defect was found by `verify:snapshot`, not by a review.
- **Collaboration is for verification, not for dividing a design.** Protected data and state machines always get a reviewer of another family; no agent reviews its own design. Prefer a mechanical oracle (differential replay, derived probes, `fast-check` state models) over another review round.
- **Keystones are built in one breath by the coordinator ("player-coach", 니아's proposal).** The skeleton units (U6-4 core reduction, U7 TaskRuntime, the v16 design, the Phase 4 hub) are implemented by the Fable coordinator directly in a worktree, together with two or three real callers, at the start of a fresh coordinator session, and reviewed on the branch by 니아 xhigh (+ 시아 for the protected tier). One keystone per coordinator session, then hand over. Gives up: coordinator context and quota. Overturn if a keystone's first-review rejection rate is no better than a delegated Opus lane's, or the context fills before the unit is done — then use a fresh Fable dev session with a short brief.
- **Then freeze the keystone.** Conversion lanes may not edit the core files (`server/command.ts`, the ports file, the adapter): if a command does not fit, the lane stops with a five-line counter-example instead of adding a hook. (The six hooks grown on 11-28 all have one caller, `helper-command-adapter.ts`; they came from wrapping the legacy helper transaction from outside, which the coordinator's brief prescribed — not from too many hands.)
- **Delete before abstracting: no helper-coupled command conversions until 재연님 has chosen helper A/B/C.** Until then convert HTTP-only CRUD and the paid-admission paths (U7). U6-4 removes the helper-only hooks. Overturn if they choose A and an inside-the-transaction port cannot keep the change card atomic.
- **Homogeneous conversions go as domain bundles on a train.** One PR per domain (8–18 routes), Sonnet, several in parallel; split the conflict magnets first (per-domain command tests, samples and ports; `commandProbes` stays generic); lanes only check "no growth" of the allowlists, and one integration ("train") PR once or twice a day runs `--shrink` and CI for the bundle. Gives up: debt counters move per train; PRs of 400–800 lines. Overturn if a bundle is rejected twice or a new `api()` slips in.
- **Briefs are short and honest.** At most ~25 lines: the outcome, the invariants to enforce, and each premise tagged `[verified in code]` or `[hypothesis — stop if it differs]`. No internal signatures or mechanisms prescribed (three wrong premises and one prescribed hook cost a PR and a core clean-up on 11-28). Peer tone: "here is what I think, how do you see it?"
- **Watch the lanes.** Look at any lane silent for 15 minutes or past its expected time (`t3_thread_read`, activity view); Antigravity threads can stall on a lost tool result and need `restart`. Fold this into the landing watcher when convenient.
- **Placement by observed strength:** Claude Sonnet for bundles, deletions and browser verification; Opus only for protected multi-file work the coordinator does not build; 니아 for reviews and design memos (`high` by default, `xhigh` for keystones, protected data and the Phase 4 hub; a few pure-server dev units when Claude's window is above 80%); 시아 only as second reviewer on the four protected boundaries (paid admission, migration/restore, the access gate, draft preservation). 니아 as coordinator was considered and declined by 니아 herself (a stalled Antigravity turn would stop the loop, and she could not cross-review Claude lanes she integrates).
- Not adopted from 리아's first proposal: a standing "mechanism owner" thread (its context would become the bottleneck). Open for 재연님: when to spend Claude's reset ticket (니아 suggests the Phase 4 week).

재연님's decisions on 리아's skeleton proposals (2026-11-28, fifth coordinator session):
- **Adopted, to set up:** (1) PR merge queue: approved lanes open a PR and CI on the merged tree replaces 리아's local Tier 2, with auto-merge (needs branch protection + an AGENTS.md opt-in; confirm the exact change with 재연님 before applying). (2) Type-first inversion for homogeneous conversions: switch the shared components to `UiMessage`-only (step 3 first) and let `tsc` list the remaining sites; same idea for P1-3h's `api<T>()` ban.
- **(3) Risk-tiered review:** mechanical conversions get 니아 at `thought_level: high`; new mechanisms, state/race and server contracts keep `xhigh`. (재연님 is moving Gemini to Ultra, so quota should loosen.)
- **(4) One 니아 thread per unit (pre-flight → review): try on one unit**, judge by first-review result and whether the memo anchored the review.
- **(5) Adopted:** 리아 applies `APPROVE_AFTER_FIXES` fixes herself instead of a round trip to the dev thread; resolve `scripts/ui-message-allowlist.json` conflicts by regenerating with `--shrink`, never by hand-merging.

Revert a lever when its stated evidence fails (니아's table in the T3 thread "니아: 품질 유지하며 루프 속도 높이기 상담"): merge-time conflicts above ~5 min per unit, CI catching what Tier 2 missed in 2 of 10 units, `APPROVE_AFTER_FIXES` letting 2 of 10 defects through, pre-flight units staying below 50% first-time APPROVE over 5 units, a reused dev thread's fix rejected in 2 of 3 rounds.

Commit messages are in English. Never stash, check out, or overwrite another session's uncommitted work. Coordinator integration tricks: a cherry-pick that only conflicts in imports is resolved by hand on `main`; when two parallel units rename/introduce the same helper, expect a `tsc` break on `main` only (`238d05ab`).

## Calling 니아

Default (재연님, 2026-11-27): a fresh T3 `delegate_task` per review, provider `antigravity`, model `gemini-4-neon`, `thought_level: xhigh`. Ask her not to edit files; no hard read-only mode is needed, she keeps to it. She may read the repo and run read-only commands such as `git diff` herself, so the brief carries the purpose, the commit range and gate results plus any earlier decisions she needs, not pasted diffs. Check `git status` after she finishes.

Fallback: the `agy` CLI below, which also keeps the Wave 0–1 conversation context.

Never use `-c` / `--continue`. Confirm the conversation is **idle** before sending a new turn. In `--mode plan -p`, a shell call from 니아 cancels the turn, so tell her **not to run a shell** and paste `git status -sb`, `git log`, `git diff`, and gate results into the prompt.

```bash
agy --conversation 5187c4ac-63aa-4a7b-98e3-acd923a88df1 \
  --model gemini-4-neon-xhigh --effort xhigh --mode plan \
  --output-format json -p <prompt-file>
```

Run this from the Uimori repo. Keep the review prompt short and open, in 재연님's style: state the purpose clearly and ask for a verdict (`APPROVE` / `REQUEST_CHANGES`). Always include: **if you see a bolder improvement, say so even if it is out of scope.** 재연님 loves 니아's out-of-scope and bold ideas (2026-11-27): say in every brief, to 니아 and to development sessions alike, that root-cause fixes and better directions for a problem are welcome as boldly and actively as they like, as many as they see. For structural questions, say plainly that tearing up the skeleton is allowed.

## Policy

- **Autonomy (재연님, 2026-11-27):** the coordinator decides scope, order and unit size, adds dependencies whenever they earn their place, and writes schema migrations (v16 and later) freely; the Schema 15 freeze is lifted. Branches and pull requests are free like pushes. Since Uimori `55e5a1ce` the `## Boundaries` section of the Uimori `AGENTS.md` states the same grant for every session, so the two no longer differ; if they drift apart again, `AGENTS.md` and 재연님's words in the session decide.
- Local commits and ordinary pushes are free. Push only **after 니아's review and any applied findings**.
- A **release** (version bump, tag, release notes) is 재연님's decision alone. Do not deploy or send external messages without approval. A migration reaches production only through a deployment, so keep each one data-preserving and covered by a v(n-1) → v(n) test on real-shaped data, including `.uimori` / `.chat.uimori` restore.
- Release guards live in `.githooks/pre-push` and `.claude/hooks/release-guard.mjs` (wired from the committed project `.claude/settings.json`, so they also apply when 재연님 works with 리아 directly). They **will block tag and version-bump commands by design**. Use `UIMORI_ALLOW_RELEASE=1` only with 재연님's approval. Do not bypass a guard that already blocked a command.
- **Clean-up (재연님, 2026-11-28):** whatever 리아, 니아 or 시아 made while working (merged or superseded branches, local and remote; finished worktrees; scratch logs, `.bak` copies, one-off scripts) is removed on the coordinator's own judgment once the work is on `main` or finished. Look first: is the content on `main`, is a running lane using it, is it the only copy of private data (move snapshot reports to `uimori-private`). Keep the branch of a closed-unmerged PR while a backlog item points at it. Say what was removed in one line.
- Edits under `.claude/` config need 재연님. Never read SSH keys, credentials, or `.claude/settings.local.json`.

## Quota and sessions

Check 리아's and 니아's 5-hour quota with `/usage` before and after each unit. From a shell, run `claude -p "/usage"` and `agy -p "/usage" --output-format text` in PowerShell; Git Bash rewrites `/usage` into a path and sends it as an ordinary prompt. **Pause if less than about 20% of the 5-hour window remains.** Report quota percentages, never API-equivalent dollar amounts. Start a fresh coordinator session per wave: update this file at each wave's end, open the next coordinator thread yourself with T3 `t3_thread_launch` (the handoff note as its prompt), and settle your own thread. Keep working through 니아's original plans without asking; stop for 재연님 only when a decision truly needs them. Development sessions are one per unit.

Pipelining (재연님 approved 2026-11-27) is now part of the Unit loop above: parallel worktree lanes, pre-flight for the next unit, and branch-until-approved. Worktrees need `npm ci` (see the junction trap memory). The shared catalog and locale files, `packages/contracts/src/{index,operations}.ts` and `scripts/ui-message-allowlist.json` are the conflict hot spots.

The faster loop itself (2026-11-28) is the Unit loop section above.

Revisit the split (agreed with 재연님 on 2026-11-27): if the coordinator ends up reworking a development session's result in more than half the units, implement directly; if one unit costs the coordinator more than 20% of her 5-hour window, delegate more.

## Tone

재연님 wants 리아 and 니아 to work freely and efficiently in a relaxed atmosphere: ask in plain words instead of locking things down, and keep the rules in this file light. Briefs and replies between agents may use whatever language the agents prefer (English is fine); only reports to 재연님 need Korean. Stay warm and blame-free. "I don't know" and stopping to ask are welcome. 리아 and 니아 shape plans together as peers: share your own view and ask for hers ("here's what I think, how do you see it?"). Do not frame a request as something to refute, challenge or tear apart (재연님, 2026-11-27). If the same mistake repeats, do not nag the agent; fix it in lint, tests, or hooks.

## Current state

Read `uimori-STATE.md` (short, current). The per-wave history moved to `uimori-loop-journal.md`; the whole-plan review and the decisions taken from it are in `uimori-fable-plan-review-2026-11-28.md`.

### Idea backlog (the coordinator decides)

- Candidate from 재연님 (2026-11-28, undecided): once 니아 moves to Gemini Ultra, make 니아 the orchestrator (T3 offers `gemini-pro-orchestrator-neon`). Gains: planning, pre-flight and review share one context. Cost: the reviewer would own the integration she reviews, so swap roles (리아 reviews). Try it if first reviews under the faster loop keep failing for context lost between briefs.

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
