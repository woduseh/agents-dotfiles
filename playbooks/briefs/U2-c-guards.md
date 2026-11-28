[T3 Code: the agent in T3 thread "mcp:78adee32-6fc1-4033-b576-e8033a8f5b3d" sent this message, not the user.]

Act as the implementation sub-agent for this task.

Hi! You're a Uimori dev session (리아, the coordinator, briefing you). Relaxed, blame-free; "I don't know" and stopping to ask are welcome. **If you see a root-cause fix or a better direction, propose it boldly — out-of-scope and bold ideas are welcome (재연님 loves them).**

Start: `git fetch origin && git reset --hard origin/main` (`ad654e6f`). Batch independent reads, searches and edits in one message. Don't use `git stash`.

## Unit U2-c: close Phase 1 with ratchets (guards only)
Phase 1 (typed route contracts) stops converting routes by hand; the remaining ~140 raw routes convert as Domain Commands in Phase 3. What closes Phase 1 is a set of checks that make the debt shrink-only. 재연님 approved; a PR that adds checks auto-merges after review. Never weaken an existing check.

**Read first:** 니아's pre-flight memo with measured counts, anchors and traps: load `mcp__t3-code__t3_thread_read` (ToolSearch `select:mcp__t3-code__t3_thread_read`) and read the last message of thread `thread:delegated-task:command%3Amcp%3A837498db-1f7e-48fd-8f24-a384d86a7143%3Adelegate-task%3Acc402dba-1def-4567-bfdd-706e201b68f1` (`limit: 1`, `maxCharsPerItem: 20000`). This unit is its items **1a, 1b and 4**. Items 2 (stale-tab matrix) and 3 (`registerRawRoute` + moving the permanent raw routes) are separate lanes — don't start them.

### Deliverables
1. **Server route guard (1a).** `registerEndpoint` marks its routes (`config.routeKind`); a new `tests/route-guard.test.ts` boots the real `createApp` with an `onRoute` callback in both `testMode: false` and `true` and requires: every `/api` route is a contract route matching `allEndpoints` 1:1, or is listed in `tests/raw-route-allowlist.json` (`permanent` with a reason each — binary, stream, SSE — and a shrink-only `debt` list); test-mode-only routes exist only under `/api/test/*`. A new raw route fails with a message that says what to do instead; a `debt` entry that no longer exists fails until the list shrinks (`UIMORI_SHRINK_ROUTES=1`). Design the registration-kind check so a third kind is a one-line addition: a parallel lane (U6-1) is adding `registerCommand` beside `registerEndpoint`.
2. **Web `api()` ratchet (1b).** Replace the path matching in `scripts/check-endpoint-calls.mjs` (landed with PR #38) with a per-file count of calls through the imported `api`/`apiBinary` bindings (alias- and namespace-aware; `web/story-ui-catalog.tsx`'s local `api()` is not one), allowlist in `scripts/legacy-api-allowlist.json` (`permanent`/`debt`, `--shrink`), plus the five direct `fetch()` sites outside `web/api.ts` pinned as `permanent`. Decide whether `<DeleteButton path=…>` and `useApiRecord(string)` are counted and say why. Keep the paired `scripts/check-endpoint-calls.test.mjs`. Pure AST, no app imports (`scripts/check-script-imports.mjs`).
3. **Biome boundary rules (4)** in place of the dropped package moves: add only the boundaries whose violation count is zero today as hard `noRestrictedImports` rules (니아's list ①–⑤; re-measure each before adding), move `PROMPT_HTTP_BODY_MAX_BYTES` to `packages/contracts/src/domains/limits.ts` so sibling-domain imports become a zero-violation hard rule, and bring `runner/**` under lint. No shrink-only lists for the non-zero internal boundaries (`server→request-validation`, `core→node:crypto`, `server→provider-fetch`): dropped as not earning their keep.

### Traps (from the memo — each has failed a first review before)
- Biome `overrides` replace rather than merge: a narrow override must repeat the root rule's `paths`/`patterns` or that file's boundary rules silently turn off. Prove each rule fires with a scratch violation (don't commit it) and list the proofs in your report. U6-1 will add its own `server/commands/**` override later; leave a shape that is easy to extend.
- Biome cannot tell `import type` or dynamic `import()` apart; leave value/lazy checks in `tests/web-runtime-boundary.test.ts`.
- Fastify `onRoute`: filter auto-generated `HEAD`; template and loop registrations (`server/risu-export.ts` ~L234) are why source scanning is not used.
- Windows/CI: allowlist keys normalized to `/`, `--shrink` output LF + two-space indent; `tests/route-guard.test.ts` names `raw-route-allowlist.json` literally so `scripts/check-changed.mjs`'s `namedTests` selects it when only the list changes; `biome.json` is a full-suite input.
- Keep `server/endpoint.ts` and `server/app.ts` edits minimal (U6-1 and others touch them).

### Evidence
For each of the three checks: it passes on the tree, and a scratch violation (a new raw route, a new `api()` call, a forbidden import) fails with the intended message — paste the messages. Update `docs/dev/CODE-MAP.md` / `docs/dev/CHECKS.md` where they describe these checks, and replace what they say about the old path matching.

### Tier 1
`npm run quality:full` (or what `check:changed` asks for when `biome.json` changes), `npm run build`, `npm run check:changed -- origin/main --all` (if `scope: full-required`, `npm test` once; read totals with `grep -E "Test Files |Tests  | FAIL |× "`), `node scripts/test-tooling.mjs`, `npx playwright test --list`.

### Self-closing review (new shared boundary)
One reviewer via T3 `delegate_task` (no worktree; call `orchestrator_capabilities` first): 니아 (`antigravity`, `gemini-4-neon`, `{ thought_level: "xhigh" }`; ask her not to edit files). Brief = `docs/dev/REVIEW-RUBRIC.md` quoted verbatim in full + its "Brief" (purpose, range, gates, user decisions: Phase 1 closes by ratchet; checks may be added but not weakened; the dropped non-zero boundary lists are the coordinator's decision; bold ideas welcome). Don't defend your change.
- APPROVE / APPROVE_AFTER_FIXES → apply, land. REQUEST_CHANGES or contested → stop and report to me.

### Land
Rebase onto `origin/main`, `npm run quality`, push, PR via `pull_request_create` (no auto-merge; 리아 enables it; link the PR to your own thread only). Return: changed files, the measured counts (contract routes, permanent raw, debt raw, `api()` calls, files), checks with results and the scratch-violation messages, open issues and ideas, PR URL + full head SHA, reviewer thread link.