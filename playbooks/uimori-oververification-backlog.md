# Uimori over-verification backlog

Candidates outside the design Phase 1 path that fail AGENTS.md "Product intent" (one person, same build; protect saved text, authoring drafts, paid generation, backup restore; keep the access gate and provider keys closed). Found by 니아 at `0844928e` (2026-11-27); file:line evidence is in the T3 delegated thread "니아: over-verification candidates" under the Wave 2 coordinator thread. Verify each against the code before removing, and keep the "keep" notes.

Agent-decidable (ranked by payoff):

1. Client multi-step recovery and idempotency receipts unrelated to paid generation or authoring drafts: `web/pendingStory.ts` + `pendingProfile` locks in `web/main.tsx`; `web/helper-pending-request.ts`; `cloneWithReceipt` / `resource:clone:` receipts; `CHAT_COPY_RECEIPT_UNVERIFIED` legacy branch. Keep `resource:save:` (first save of an authoring draft). Bolder: let `POST /api/chats` take the initial package attachments and start in one transaction and delete `pendingStory.ts`. Check first that package start triggers no model call.
4. SSE endpoints with no web caller: `GET /api/chats/:id/events` (+ its keepalive branch in `server/chat-event-stream.ts`) and `GET /api/response-streams/:taskKind/:taskId/events`. Coordinate with Phase 1 route units.
5. Symlink/junction walks inside directories the server or build created itself: `ownedImportStagingRoot` (`server/import-preparation.ts`) and its six callers' duplicate `lstat` checks; `removeOwned` in `scripts/lib.mjs`. Keep the 32-hex ID regex and the active-staging sets.
6. Self-distrust on same-build IPC: parent→worker contract checks in `server/risu-lua-worker.ts` (`validLimits`, `workerData`, `host-result` whitelist) and `/exec` re-validation in `runner/runner.mjs`. Keep the guest Lua sandbox (memory, CPU hook, removed `os`/`string.dump`, guest call limits) — it guards against third-party cards. Overlaps P1-4a.
7. Triple TOCTOU inode/mtime checks in `decodeGeneratedImage` (`server/codex-runtime.ts`); keep the `relative(this.home, …)` boundary. Overlaps P1-4b.
8. Version-skew and old-browser shims: `block.text` fallback in `web/reader-blocks.ts`, `sessionStorage`→`localStorage` reading-position migration in `web/story-storage.ts`, `sweepUnregisteredStorage` in `web/storage-keys.ts`, SSE frame runtime guards in `web/response-stream-bridge.ts`. `writeRecentStorage`'s cap may stay.
10. Unconsumed release receipt verification in `scripts/release-check.mjs` and ownership double checks in `scripts/artifact-retention.mjs`.
11. Dead maintenance allowance `'/api/diagnostics/report'` in `server/maintenance.ts`; repeated `SCENE_COMMENTARY_RETIRED` guards (keep `store.retryJob` and the startup interruption).

Done: 3 and 10 in `5142bd38`, `4ec32dd2`, follow-up `57a86dde` (니아 reviewed).

More from 니아's release-tooling review (agent-decidable):

- `ownership.json` is a dead write for `output/tooling`. Its only reader is `scripts/cleanup.mjs` for `output/playwright`. Have cleanup read `summary.json` (`finishedAt`, `cleanup.livePids`) and drop `createOwnership` in `scripts/lib.mjs` and the runners' three writes.
- `deploy/oracle_gc.py` ~L166-175, ~L208-211: double image inspect and re-scanning receipts inside `deploy.lock`.
- `scripts/release-oracle.mjs` ~L350-355: re-fingerprints the whole repo after staging runner files Oracle doesn't build from.
- `deploy/oracle-update.py` ~L376: `ready-to-switch` fails on running work before `close_writes` gets to drain it. `scripts/oracle-image-probe.mjs` ~L38 re-hashes `dist/` inside the image it just built, where `buildId` already identifies it.
- The leftover `owner.startsWith('oracle:')` in `scripts/oracle-data.mjs` ~L242 does the same job as the check just removed elsewhere.

From 니아's P1-2c1 review (2026-11-27, agent-decidable):

- With the backup-horizon unit: drop `initFonts`' `sourceUrl`/`license` UPDATE (retired in v0.11.16) and its test in `tests/fonts.test.ts`.
- `GET /api/themes/:id/export` and `GET /api/palettes/:id/export` have no caller outside tests; delete them and move the tests to `themeFile`/`paletteFile` + `/api/theme-assets/:hash`.
- `web/ThemeAssetEditor.tsx` has no client size check, so assets over 64 MiB hit Fastify's bodyLimit as a generic 413.
- `THEME_STORY_UI_MISSING` can race when another tab turns `storyUi` off (`saveTheme` does not bump the preferences revision); small window, left as HelperToolError.
- Server-owned staged-file re-hashes still in `risu-import-prepared.ts` (~L74-84 manifest) and `request-images.ts` (~L48-49 `REQUEST_IMAGE_CHANGED`); unify with the P1-2d Risu unit.

Decided by 재연님 (2026-11-27):

- 2 → reduce to one best-effort save without warnings; drop the IndexedDB write queue, failure banner, retry UI and the extra session keys.
- 3 → slim the Oracle release scripts to backup, integrity/compatibility probe, health check and rollback (tests only; the next release by 재연님 is the real check).
- 9 → backups are guaranteed to restore only from 0.18.0 and later (confirmed by 재연님 2026-11-27: they keep two days of backups and delete the rest). A backup whose `appVersion` is older than 0.18.0 is refused on restore with a clear code. Then remove the legacy `search_fts` dual lookup and migrator, `stored-shape-upgrades-*`, and `nativeRisuSnapshotNeedsRefresh`. DB schema stays 15 (unchanged since v0.4), so the `appVersion` check is the only gate.

Original notes:

2. Recovery for short chat inputs (main composer `sessionStorage` keys, helper input IndexedDB queue with failure banner). AGENTS.md says a short chat input needs no safeguard, but long multi-paragraph instructions are typed there too. Keep `helper-outbox:*`, `command:*` (paid generation) and authoring-editor drafts either way.
3. Oracle release scripts: multi-operator maintenance ownership, `sessionAuthority` rollback refusal, `credentialDigest` abort, `/data` symlink walk, smoke self-sandboxing. Keep DB backup/integrity/compatibility probe, health check, rollback, token masking. Release tooling is 재연님's.
9. Legacy `search_fts` dual lookup, triggers and the 1-second migrator (`server/search-schema.ts`, `manuscript-search*.ts`). Depends on how old a backup must still restore; a one-time move at open keeps old backups working.

Deliberately kept (니아): helper shell `workspacePath` / `O_NOFOLLOW` / `nlink` (the model runs arbitrary shell), backup `verifySnapshot`, access session and network policy, `stored-shape-upgrades` and `nativeRisuSnapshotNeedsRefresh` until the backup-restore horizon is decided.
