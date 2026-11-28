[T3 Code: the agent in T3 thread "mcp:78adee32-6fc1-4033-b576-e8033a8f5b3d" sent this message, not the user.]

Act as the implementation sub-agent for this task.

Hi! You're a Uimori dev session on the keystone unit of Phase 3 (리아, the coordinator, briefing you). Relaxed, blame-free; "I don't know" and stopping to ask are welcome. **Tearing up the skeleton is allowed here: if you see a root-cause fix or a better direction, propose it boldly — out-of-scope and bold ideas are welcome (재연님 loves them).**

Start: `git fetch origin && git reset --hard origin/main` (`ad654e6f`). Batch independent reads, searches and edits in one message. Don't use `git stash`.

## Why this unit
Today one mutation is spread over 6–8 places: a route with its own parsing, a helper tool that repeats read → merge → validate → write with the same order defects, receipt plumbing by hand, and reviews as the only place where order and receipt mistakes are found (three units were rejected in a row on 11-28 because a fix leaned on a server invariant nothing enforced). Phase 3 makes a mutation one definition, executed by one entry shared by HTTP, helper tools and MCP, with the invariants enforced by construction. This unit builds that core **together with its first real commands**, so the core is shaped by a caller rather than in the abstract.

## Read first
니아's design draft: load `mcp__t3-code__t3_thread_read` (ToolSearch `select:mcp__t3-code__t3_thread_read`) and read the last message of thread `thread:delegated-task:command%3Amcp%3A837498db-1f7e-48fd-8f24-a384d86a7143%3Adelegate-task%3Ac7c6a1ec-c5c3-49cc-b427-872ad61d1e43` (`limit: 1`, `maxCharsPerItem: 20000`). It has the `SplitOperation`/`defineCommand` sketch, ports, adapters and file anchors. It is a draft; the decisions below are settled, and where the code disagrees with either, tell me rather than bending the code.

## Settled design
1. **Pipeline, fixed in one executor** (`executeOperation(op, ports, rawInput, ctx)`): parse the head (target ids, expected revisions, idempotency key) → receipt fast path → optional async `prepare` outside the transaction → one transaction: receipt again → `guard(tx, ports, head)` → parse the full input → `apply` → save receipt → `afterCommit` (publish/pump/cleanup). Receipt comes before target, revision and digest, so a retry of work that was saved replays instead of answering 409. Errors are normalized in the executor, once.
2. **Order by construction:** `guard` cannot see body values (it receives the parsed head only), so "a stale or deleted target answers 409 `REVISION_CONFLICT` before any value validation" is a property of the types, not of review. Use 니아's head/body split or a smaller mechanism that gives the same guarantee.
3. **Output is type-only** (handler return type); a Zod output schema is parsed only where `outputPolicy: 'always'` marks a secret or MCP boundary.
4. **Ports without ceremony:** a command receives `Pick<AppPorts, …>`. A port is a `Pick` of an existing sub-store or a narrow module of functions taking the opaque `Tx`; don't write a new interface where an existing type can be picked, and no fake implementations (tests run on real SQLite). One file adapts `Store` into `AppPorts`. Biome keeps `server/commands/**` off the `Store` hub, `product-store`, `request-validation`, `node:sqlite`, `fastify` and `app`.
5. **Adapters stay thin.** HTTP: `registerCommand` next to `registerEndpoint` (which stays for unconverted routes) adds only route registration, input merging, `no-store`/admission/body limit, status. Helper: only what this unit's two commands need (scope injection, `withHelperChange`/task result in the same transaction via `ctx.aroundTx`, schema from `z.toJSONSchema`). No adapter repeats validation, `writableChat`/revision checks, receipts, transactions, error mapping or publish.

## The first commands (the proof)
`chat.variables.update` and `chat.guide.update`, each one command used by both the HTTP route (just converted to typed routes in PR #38, `chat-settings` domain) and the helper tool (`server/helper-chat-state-tools.ts` ~L695-809, non-atomic read → merge → write, 404 on a deleted chat, value errors before 409). The body becomes a union covering both callers (`{ values } | { set?, unset? }`, `{ config } | { changes }`). Delete the helper's duplicate implementation, its hand-written JSON schema and the duplicated `*ToolInput`. PR #38's body lists "schema 400 before 409" and the helper guide/variables order as known limitations left for Phase 3: after this unit they are gone for these two commands, and any stale-tab matrix exemption that existed for them is removed. PR #38's last fixes must survive: `unset` refuses `__proto__`/`constructor`/`prototype`, an empty patch is refused.

## Traps to settle before writing the core
- How `Store.transaction` (`server/synchronous-transaction.ts`, synchronous `BEGIN IMMEDIATE`) behaves when an existing write method that opens its own transaction is called inside one. "Every write takes `Tx`" must be a real guarantee; if existing methods ignore the token, say how you made it real for the two pilots and what remains for later commands.
- `await` inside the transaction must be impossible (니아's `SynchronousResult<T>` idea).
- `#contracts` stays type-only for the web (`tests/web-runtime-boundary.test.ts`), and `tests/endpoint.test.ts`'s strict-input checks keep passing.
- The helper change card / rollback record for these two tools must be written in the same transaction as the command, or not at all.
- A parallel lane (U2-c) is editing `biome.json` (Biome `overrides` replace rather than merge — a narrow override must repeat the root rule's paths) and adds a `config.routeKind` marker in `registerEndpoint` plus `tests/route-guard.test.ts`, which requires every `/api` route to be a contract route or allowlisted. Keep your `server/endpoint.ts` and `biome.json` edits small; if U2-c has landed when you rebase, make `registerCommand` routes count as contract routes.

## Evidence (invariants, not mirrors — `docs/dev/CHECKS.md` "Which tests to keep")
One `tests/command-core.test.ts` over the real executor and SQLite, written so later commands get the same probes for free by being listed: (1) stale or deleted target + a deliberately broken body → 409 `REVISION_CONFLICT`; (2) for a command that declares a receipt: run → change the state the guard reads → resend the same key = replayed output, same key with a different body = 409 (use a minimal receipt-bearing command if neither pilot has one, and say so); (3) HTTP and helper with the same input → same stored state and same error code; (4) a type-level check that `guard` cannot read body fields. Remove the route and helper tests these replace; report `tests/` and product line deltas (the draft expects roughly −200 for this pilot against ~+350 for the core).

**Stop and tell me** if the head/body split turns out forced for real inputs (a body value that decides the target), or if `aroundTx` and the helper change tracking tangle — 니아 named both as the evidence that would change the design.

## Tier 1
`npm run quality`, `npm run build`, `npm run check:changed -- origin/main --all` (if `scope: full-required`, `npm test` once; read totals with `grep -E "Test Files |Tests  | FAIL |× "`), `npm run verify -- --changed origin/main` (one or two domains per call on Windows), `npx playwright test --list`.

## Self-closing review (new shared boundary + helper change records)
Two reviewers in parallel via T3 `delegate_task` (no worktree; call `orchestrator_capabilities` first): 시아 (`codex`, `gpt-6.2-astra`, `{ reasoningEffort: "medium" }`; short and relaxed, demonstrated defects only) and 니아 (`antigravity`, `gemini-4-neon`, `{ thought_level: "xhigh" }`; ask her not to edit files). Brief for each = `docs/dev/REVIEW-RUBRIC.md` quoted verbatim in full + its "Brief" (purpose, range, gates, user decisions: Phase 3 order and the command core are approved; the five "Settled design" points are the coordinator's decisions; bold ideas welcome). Don't defend your change.
- Both APPROVE / APPROVE_AFTER_FIXES → apply, land. Any REQUEST_CHANGES or a contested fix → stop and report to me.

## Land
Rebase onto `origin/main`, `npm run quality`, push, PR via `pull_request_create` (no auto-merge; 리아 enables it; link the PR to your own thread only). Update `docs/dev/CODE-MAP.md` / the owning dev document with how a command is defined (what code cannot state: the pipeline order and why receipt comes first). Return: changed files, line deltas, checks with results, what the next command authors must know, open issues and ideas, PR URL + full head SHA, reviewer thread links.