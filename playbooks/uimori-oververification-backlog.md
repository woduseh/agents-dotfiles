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

From 니아's P1-2c2 review (2026-11-27, agent-decidable):

- With P1-2d1's rebase: `server/helper-runtime.ts` ~L1202/1307/1438/1443 call `modelSnapshot` without `role`, so a disabled/deleted helper or context model answers legacy text / an uncatalogued 404 instead of `MODEL_UNAVAILABLE { role }`. `HelperContextSummaryView.blockedReason` still carries the literal `'MODEL_REQUIRED:helper'` (a response field, not an error).
- With the backup-horizon unit: `comfyui.disabled` has had no writer since `cd2a804e` (before v0.18.0); remove its branches in `core/illustration.ts`, `comfyui-client.ts`, `illustration-runner.ts`, `illustrations.ts` and the `ILLUSTRATION_CONNECTION_DISABLED` code.
- Drop `validateTranslationArtifact` re-checks of server-written `job_results` (keep the `result?.text` presence and 409 order in `package-images.ts` ~L254).
- `checkedPortableIllustrationReferences`: keep one check at the untrusted file boundary (`chat-backup.ts` ~L55, `native-transfer-archive.ts` ~L269), drop the repeats (~`chat-backup.ts` L238, `native-transfer-archive.ts` L122/L360, `illustration-reference-copy.ts` L112).
- `manuscript-export.ts`: drop the other-chat ancestry check; the unused Korean `label` (~L34).
- KEEP the reservation-time `parseComfyWorkflow` re-parse: it stops a broken old workflow before a paid prompt-model storyboard call.
- P1-2e: `web/illustration-labels.ts` duplicates 22 `appErrorMessages` entries; look up `appErrorMessages` first and keep only stored/runner codes there.

From 니아's P1-2d1 review (2026-11-27, agent-decidable):

- The shell bridge (`server/helper-shell.ts` ~L730, `runner/uimori.mjs` ~L91) prints `{ code }` for an AppError and `{ error }` for a HelperToolError; pick one shape for the model.
- `readResource` (`server/resource-service.ts` ~L28-32) does not check `library_hidden` for content/prompt presets, so a deleted resource still reaches the helper as an old snapshot.
- `store.chat()`'s `'Chat not found'` reaches the helper panel on a chat-deletion race (`helper-routes.ts` ~L85, `helper-workspace.ts` ~L135/347); catalog it with the chat domain.
- `library-deletion.ts` clears main/translation/title routes on model deletion but leaves `helperModel`/`contextModel`.

From 니아's P1-2d2 review (2026-11-27, agent-decidable):

- `/api/chats/:id/sources/:sourceId/risu-action` (`server/app.ts` ~L1150) rethrows Risu timeouts raw (generic 500); share `withRisuFailureCode` from `package-presentation-routes.ts` ~L329 and reword `errors.RISU_NATIVE_TIMEOUT` from "표시 스크립트" to "Risu 스크립트".
- `web/ProviderManagement.tsx` ~L374/898/913: after a deleted connection/model save answers REVISION_CONFLICT, `readSaved` 404s; show "deleted" instead.
- Prompt combination create (`product-store.ts` ~L392) still 404s for a deleted owner preset; match the update path's REVISION_CONFLICT.
- `errors.MODEL_UNAVAILABLE` has no `agent` branch (collaboration agents fall to "Models by role").
- `request-files.ts` ~L135 upload re-hash (same as the removed request-images one; keep the `REQUEST_FILE_CHANGED` locale key for stored errors); `PACKAGE_START_REPLAY_MISSING` (`package-start.ts` ~L225) is unreachable.

From 니아's P1-2e review (2026-11-27, agent-decidable; mostly for P1-2f):

- Guard against raw descriptors: an AST check in `scripts/check-i18n.mjs` that fails when a value from `catch`/`.catch`/`message()` reaches JSX text, `title`, `aria-label`, `setCustomValidity` or `.startsWith`/`.includes`/`.match` without `translateMessage` or a translating component. If a cross-file prop chain leaks `\u001f` again, switch to an `errorMessage(caught): UiMessage` helper and ban raw `.message` in `web/`. Later, a shared Playwright fixture can assert no visible text/`title`/`aria-label`/`validationMessage` contains `\u001f`.
- Pre-existing error/notice state stored as `t(...)` (does not follow a language switch): `ShortcutSettings.tsx` ~L86-97, non-Error fallbacks in `AuthorNotesEditor.tsx` ~L148, `ContextPanel.tsx` ~L120/232/371/386, `HelperSummaryDialog.tsx` ~L15, `HelperTaskRollback.tsx` ~L251, `StoryPanel.tsx` ~L80.
- Korean outside server throws: `backup-service.ts` status error/warning (~L120/236/286/312/320), `scene-deletion.ts` ~L292 writes Korean into `context_jobs.error` (rendered raw by `ContextPanel.tsx` ~L417), ~25 Korean `throw new Error` in `core/` (`themes.ts` ~L220-317, `illustration-presets.ts` ~L80-138, `palette-files.ts`, `risu-native-assets.ts`, `theme-background.ts`).
- 니아 suggests splitting P1-2f: (1) web literals (~115) + non-throw server text; (2) `core` labels to `labelKey` (model/helper input contract) and the `sources` removal. One unit is fine if helper/models read only `.id` from those `core` objects.
- `IllustrationPresetSettings.tsx` ~L160 regex on a Korean `core` validator message (`ComfyUI 워크플로:`).

From 니아's Backup horizon review (2026-11-27, agent-decidable):

- `tests/fixtures/backup-horizon-0.18.0/snapshot.db.gz` has no rows in `provider_settings`, `illustration_references`, `illustration_jobs`, `resource_undo`, no `font_assets`, and no `chat.title.eligible`/`input.measured`/`confirmation.required` events; regenerate it from v0.18.0 with those if the test becomes the stored-format gate.
- Schema-15 open-time `init*` column/table additions in `server/database-schema.ts` ~L74-88 (unchanged since v0.18.0) and the legacy JSON native-transfer/chat backup import routes are now below the horizon too; `initSearchTrigrams` could skip its DROP/CREATE TRIGGER when already current.
- For the next horizon: record `appVersion` in `app_metadata` at open so a later floor can be a real gate.
- Kept with corrected reason: `nativeRisuSnapshotNeedsRefresh` is needed for old completed `runs.snapshot` rows and paths without `nativeRisuExecution`, not because library cards keep raw CCv2 fields.

From 니아's review of `22ab4efd`/`e15ec993` (2026-11-27, agent-decidable):

- `tests/fixtures/browser-test.ts` misses open shadow roots (`web/risu-message-surface.ts`, `web/ThemeFrame.tsx`), hidden subtrees (`innerText` skips closed `<details>`, `hidden` tabs, closed dialogs), toasts that vanish before teardown, and pages from a spec's own `browser.newContext()`. If the `UiMessage` unit is not near, use an init-script `MutationObserver` per context and match `\u001fui:`; on failed tests add an annotation instead of skipping.
- Composer menu combination/persona pickers (`web/main.tsx` ~L2812-2818, ~L2844-2851) are not locked by `hasPendingRequest`, unlike the model picker and options; a profile revision can bump during an unconfirmed request (pre-existing).
- Phase 3: one `executeOperation(op, store, rawInput)` entry so HTTP, helper tools and MCP share validation; generate JSON schemas only for helper tools whose shape matches the operation 1:1.

From the P1-3b1 dev session (2026-11-27, agent-decidable):

- `server/maintenance.ts` belongs to no feature-map domain, so `check:changed` selects no browser spec for it; adding it to `self-host` would pull the self-host runner into its checks. Decide when a maintenance browser case exists.
- Push update with `expectedRevision: 0` and no device answers 404 with code `REVISION_CONFLICT` (pre-existing); use a real `PUSH_DEVICE_NOT_FOUND` or a plain 409.
- `DeleteButton` takes a raw path, so converted DELETE routes are still called through `api()`; let it take an endpoint.
- Core types (`Bookmark`, `ReadingPosition`, `PushInfo`, `ManuscriptSearchResult`) duplicate contract schemas; re-export inferred types from `#contracts` (type-only).
- Endpoint behavior flags (`admission: 'always'`, `cache: 'revalidate'`, `effects: [...]`) could replace `ALWAYS_ADMITTED`, `REVALIDATED_ROUTES` and the URL regexes in `web/api.ts`; natural fit for P1-3b2's 304/ETag design.
- Typing `t(key: MessageKey)` produced 83 errors (template keys like `` `errors.${code}` ``); first add typed key builders (`appErrorKey(code)`) and `Record<Union, MessageKey>` maps.

From 니아's re-review of `fd074cbd..b6f4bf02` and review of P1-3c1 (2026-11-28, agent-decidable):

- Bot scope rules disagree: `store.organization.bot()` (`server/chat-organization.ts` ~L31-35) accepts any `kind` with a `package` (personas and modules get one by default, `product-store.ts` ~L300-345), while theme selection (`server/themes.ts` ~L122) requires `kind === 'bot'` and illustration presets accept packages. Settle one rule when the liveness checks are unified.
- Import findings: the server builds Korean sentences and `RisuImport.tsx`/`RisuPresetImport.tsx` regex-parse them back into catalog messages; send `{ code, level, params }` instead (P1-3b2 fix session's idea).
- `RisuContentError`/`PackageStartError` could extend `ValidationError` (one code per class + `reason` param) to close the rest of the plain-`Error` class; `RisuPromptError.code` is persisted in auxiliary job diagnostics and needs its own design.
- P1-3c1 dev: domain-model outputs are `z.looseObject` (only `revision`/`id`); moving Risu program and resource model types into `#contracts` would make them exact and drop the web casts. Prompt templates answer an English 404 for an unknown id.

- Browser flake with a known cause (리아, 2026-11-28): `/api/test/control` `fail-next` is one server-global slot used by six specs (`run-retry`, `ui-browser`, `response-actions`, `helper-workspace`, `auxiliary-recovery`, `browser`); under parallel workers another spec's request can consume it (`run-retry-browser.spec.ts` L5 got `completed` instead of `failed` once in `verify -- --changed`, then 3/3 alone). Scope the slot to a chat id (or a token returned by the control call).

- Same hazard left open by PR #39 (U2-a dev, 2026-11-28): `/api/test/control` `hold`/`release` barriers (`run`, `translation`, `illustration`) are server-global; a spec holding `run` stalls other specs' runs on that worker server and its `release` frees another spec's hold (`global-models-browser`, `response-actions-browser` hold `run`; `ui-browser`, `browser` hold `translation`; `illustration-browser` holds `illustration`). Not a small change: several specs hold before the chat exists (a token returned by `hold` would do). Take it when a barrier flake is actually seen.

- Flake (리아, 2026-11-28): `I18N07` (restarted service worker reads the persisted locale for a synthetic push, `tests/i18n-browser.spec.ts:6`) failed in Linux `browser-full (1/3)` on PRs #28 and #29 back to back ("Timeout 10000ms … waiting on the predicate", no notification), passed on rerun and alone on Windows. More PRs reach `browser-full` since #26, so it shows more often; likely service-worker restart timing under parallel workers. Look at how the spec waits for the restarted worker before posting the push.
- Flake candidate, cause unknown (Y-A dev, 2026-11-28): `LEAVE multiple prompt roles stay open without saving only the current role` missed its helper text once under `verify -- --changed` load; passed 2× alone and on a full rerun.

From 니아's PR #15 review (2026-11-28, merge-queue CI; agent-decidable):

- `runner/runner.mjs`/`runner/uimori.mjs` select no tests in `tests-pr` (`selectChecks` and Vitest `related` both return `[]`), so `helper-runner`, `helper-cli`, `helper-shell*`, `main-shell` tests don't run before merge; select them directly or treat `runner/` as a full-suite input (`scripts/change-classifier.mjs` ~L11, `scripts/check-changed.mjs` ~L80).
- Feature-map gaps: all nine `packages/contracts/src/domains/<domain>/**` folders match existing domain names but none is mapped (e.g. `bc5d01e3` changed `resource-editors/endpoints.ts` without selecting `resource-editors`); also `server/builtin-prompts/**` → prompts, `server/appearance-scope.ts` → appearance, `web/ArchivePanel.tsx`. After mapping, promote a PR with remaining `uncovered` shared files to `browser-full` (in 60 recent commits: 78% domain-only runs, 14% over the cap, 7% smoke-only).
- `browserSelection` (`scripts/ci-changes.mjs` ~L14) could skip `runner: 'self-host'` specs (core already runs them) and `requiredEnv` specs (CI has no private materials).
- `changes` and `static` run `ci-changes.mjs`/`check-documentation.mjs` before `setup-node`, on the runner's default Node; keep those scripts free of Node 26-only syntax. `static`'s `git diff --check` has no guard for a force-pushed `before`.

From PR #23 (preserve pinned prompt; dev + 니아 review, 2026-11-28; pre-existing):

- Helper `settings.read` fails with `PINNED_PROMPT_UNAVAILABLE` on a chat whose pinned main prompt was deleted (`server/helper-settings-tools.ts` ~L793 calls `chatPromptWorkspace` with the default `'library'`), so the helper cannot read `profileRevision` to unpin; return `{ id, unavailable: true }` like `choice()` does for models.
- `PUT /api/chats/:id/profile` validates `image`/`loreContext` before the revision (`server/product-store.ts` ~L650-662): fold into the chat-route contract unit (P1-3d) + stale-tab matrix.
- Chat backup restore remaps content and prompt ids through one map (`server/chat-backup.ts` ~L114-135, ~L255-278); a tampered backup can put a content id in `pinned.mainPromptPresetId` and now gets an uncatalogued 404. Split the maps.
- Idea (니아): accept only `'library'` in `ChatOptionsStore.get` and move copy/backup binding into a `chat-copy-authoring` function so `'preserve'` cannot reach a run path.

From P1-3e2b reviews (2026-11-28; Phase 3 Domain Command design inputs):

- Schema-level 400 comes before the stale-tab 409 on every contract route (e.g. `PUT /variables` with `values: {mood: 123}` on a deleted chat; stale revision + bad `definitionHash` on `POST /options/fixed`). Commands should parse target/revision first and values after.
- Helper write tools repeat read → merge → validate → write with the same order defects (`chat.guide.update`, `chat.variables.update`: 404 on a deleted chat, value errors before 409). 시아 + 니아: the service enforces `writableChat` → revision → merge/validate → write once in one transaction.
- `check-endpoint-calls.mjs` limits (ternary paths, local-scope collisions, same-file path helpers, one-segment suffix false positives, cross-file wrappers like `useApiRecord`/`DeleteButton`) → U2 replaces path matching with a shrink-only allowlist of remaining `api()` call sites (니아), contracts read by running TS.

From PR #46 (closed unmerged, 2026-11-28; 시아 dev, 니아 review):

- Native Risu card start titles are derived labels (`server/risu-native-projection.ts` ~L70 stores the Korean literals '기본 첫 메시지' / '첫 메시지 N' on every save; no editor shows or edits them). They ignore the UI language, and rows saved before `c6a8ce3d` keep '기본 시작문' / '시작문 N' until the next save. Root fix (니아's option B, 시아 agreed): generate the default label at display time (`NewStory`, `PackageStartPicker`, `SourceReader`) and keep a title in storage only when a user could have written it (Uimori-authored packages). Do not key a persisted title by greeting slot position.
- `web/NewStory.tsx` ~L620 and `web/PackageStartPicker.tsx` ~L183 render an empty or whitespace start title as a blank option.

From PR #36 (P1-3d2 transfer, 2026-11-28):

- U5 deletion candidate (accepted by 리아): drop `modelBindings` from the transfer wire — the web always sends `[]`, `inherit-main` equals no binding, only tests use `local`; removes sorting, binding cases and a nested target.
- `registerRawRoute` helper so raw routes share `parseInput` + the `no-store` hook (니아); a matrix check per target field (would have caught the missing `applyArchive` model case) — fold into U2 with PR #35's per-branch/per-`*Id` idea.
- `/risu-imports/*` (`imageHandoffIds: []`, `legacyLibraryWrites` entry) moved to Phase 3 with d1.
- Flakes seen once in full parallel runs: `server.test.ts` "Batch HTTP resume", `helper-scene-tools`, `PREVIEW01`.

From PR #35 (P1-3e3 reader, 2026-11-28):

- U2 candidate (니아): the stale-tab matrix requires a case per `discriminatedUnion` branch and per `*Id` field of every endpoint input — all three e3 review findings came from that gap.
- Selection revision / input translation have no idempotency for a lost response (a paid call); 니아 suggested a short single-flight key. Under 재연님's paid-generation rule this is welcome: design it with TaskRuntime (U7) so a retry never repeats the call.
- `StreamingResponse` still uses `api()` for `/runs/` and `/helper/tasks/` status fallbacks; `endpointRecord` accepts POST endpoints (type `Endpoint.method` too wide).
- Load flakes seen once: `codex-writing`, `risu-native-runtime` timeouts in a full run; `run-retry-browser` (the known `fail-next` slot).

From PR #34 (prep-a re-reviews, 2026-11-28; for P1-3d1/d2):

- `/presentation` also wraps `preparePresentation`, so 409 `RISU_NATIVE_SOURCE_OUTSIDE_CHAT` answers 500 (pre-existing).
- `/risu-action`: CBS/worker errors other than timeouts still answer 500; after `RISU_NATIVE_WORKER_EXIT` the next click gets `RISU_NATIVE_ACTION_FAILED`.
- `apply-archive` doesn't sort model bindings before comparing a retry (the UI sends `[]` today).
- Ideas: one core-error → catalog mapping in `core/` shared by server `asAppError` and web `toUiMessage`; Risu worker/Lua session send code and detail as separate fields with the HTTP status decided where the run is recorded; one receipt helper owning each import path's prefix, key length and command normalization.

From PR #33 (copy titles / CSV headers, 2026-11-28):

- Still Korean, web-started so the same rule could apply: copy-mode retry into a new chat (`server/run-retry.ts`) and the candidate fork title `'후보 분기'`; needs `retryRun`'s signature and digest.
- Contract `lang` enum duplicates `UI_LOCALES` (contracts can't import `core`); 니아: one shared schema.

From P1-3 prep-a reviews (2026-11-28):

- Design question (니아): Risu Lua session `failure()` and `NativeRisuRuntimeError` hard-code `statusCode: 400`; she'd remove it and decide status/logging per route. 리아 kept 400 for now because 4xx is the web's definite-refusal signal on run-admission paths next to paid generation; revisit with Phase 3's `TaskRuntime`.
- `PackageGraphError` has no catalog code (`/api/packages/resolve` → `{ error: 'Invalid request' }`).
- `server/helper-resource-editing.ts` ~L966 turns only `ValidationError`/400 `HttpError` into `validationFailure`; `RisuPromptError`/`AgentCollaborationError` patches return another shape.
- Merge `NativeTransferError`, `ChatTranscriptError`, `AgentCollaborationError` into `ValidationError` (drops `coreErrorCode`'s per-class mapping); stop writing nested `resources:*` receipts.

From PR #30 (new-item default names, 니아 review, 2026-11-28):

- Copy-title overflow (pre-existing, real): `IllustrationPresetSettings.tsx`, `LibraryPanel.tsx`, `PromptLibrary.tsx` cut the title to `slice(0, 97)`/`slice(0, 197)` for the 3-char Korean suffix, so an English " copy" (5) or Japanese (4) suffix on a near-limit title exceeds the 100-char cap and the save fails validation. Use `core/themes.ts` `copyTitle()` everywhere (small Sonnet unit, with the other copy-suffix sites from the Phase 1 plan note).
- Toggle locale invariant: `native.newToggleOption` must not contain `[=,\r\n]` and `native.newToggleItem` not `[=\r\n]` in any locale; two lines in `tests/i18n.test.ts` or `check-i18n`.
- Still Korean by design (server-named, no UI language on the server): chat copy/fork `(사본 N)`, usage CSV headers, collaboration template titles (`core/agent-collaboration.ts`), helper attachment default `'attachment'` (`web/helper-attachment-draft.ts` ~L268 — web-side, could follow the new rule).

From stored-errors A and B (2026-11-28, next-unit candidates):

- One `asAppError` that converts every `core` error class (`RisuPromptError`, `NativeTransferError`, `ChatTranscriptError`, `AgentCollaborationError`, `ValidationError`) for the HTTP handler, `shellBridgeFailure` (today `RisuPromptError` → 500 in `uimori apply`), `helperToolError`, `helper-rollback.ts` ~L570 and the prepared-import worker (B dev + 니아).
- Receipt before digest as a rule for every apply route (a stale-tab-matrix probe or a shared helper), so a lost-response retry never gets a 409 for work that was saved (B, 시아's finding).
- `resolveRunError` shared by `RetryFailure` and `RunNotices` for `runs.error` (A, 니아). Also carries: legacy unprefixed raw text in `runs.error` shown verbatim (시아), `PROMPT_*` failures from the main call after context preparation (니아), `PROMPT_CONVERSATION_REQUIRED`/`FILE_INPUT_*` outside `ContextFailureCode`.
- PR #27 nit (리아): the bare `catch` around `hooks.authorize` in `server/model-runner.ts` ~L526 and `context-tool-compaction.ts` ~L185 maps every throw (incl. an abort) to `CONNECTION_NOT_AUTHORIZED`; with 니아's idea of one `authorize` failure contract helper, catch only `PROVIDER_CONNECTION_UNAVAILABLE` and let aborts reach `CANCELLED`.
- 니아 (A review): typed domain errors instead of `CONTEXT_` prefix checks; `MODEL_REQUIRED` roles as a closed union.

From the UiMessage capstone (PR #24, dev + 니아, 2026-11-28):

- `tests/fixtures/browser-test.ts` is only `export * from '@playwright/test'` while a Biome `noRestrictedImports` rule forces 99 specs through it ("so the shared page checks run" is stale). Either drop the layer (99 import rewrites + the rule) or put a real shared page check back (no visible catalog keys, no `[object Object]`). A lint-rule change: confirm with 재연님 before merging.
- `HelperChangeCard`/`HelperTaskRollback` call `t()` without their own `useI18n()`; they follow a language switch only because a parent subscribes. Candidate static check: a component or hook calling `t()`/`formatUiMessage()` must call `useI18n()`.
- Type `t()`/`formatMessage()` keys as `MessageKey`, with a separate helper for dynamic keys.
- `web/api-errors.ts` still accepts a bare `{ error: CODE }`; with no wire back-compat it could stop.
- If readable English diagnostics are wanted in `UiError.message`, load `en` eagerly.

Decided by 재연님 (2026-11-27):

- 2 → reduce to one best-effort save without warnings; drop the IndexedDB write queue, failure banner, retry UI and the extra session keys.
- 3 → slim the Oracle release scripts to backup, integrity/compatibility probe, health check and rollback (tests only; the next release by 재연님 is the real check).
- 9 → backups are guaranteed to restore only from 0.18.0 and later (confirmed by 재연님 2026-11-27: they keep two days of backups and delete the rest). A backup whose `appVersion` is older than 0.18.0 is refused on restore with a clear code. Then remove the legacy `search_fts` dual lookup and migrator, `stored-shape-upgrades-*`, and `nativeRisuSnapshotNeedsRefresh`. DB schema stays 15 (unchanged since v0.4), so the `appVersion` check is the only gate.

Original notes:

2. Recovery for short chat inputs (main composer `sessionStorage` keys, helper input IndexedDB queue with failure banner). AGENTS.md says a short chat input needs no safeguard, but long multi-paragraph instructions are typed there too. Keep `helper-outbox:*`, `command:*` (paid generation) and authoring-editor drafts either way.
3. Oracle release scripts: multi-operator maintenance ownership, `sessionAuthority` rollback refusal, `credentialDigest` abort, `/data` symlink walk, smoke self-sandboxing. Keep DB backup/integrity/compatibility probe, health check, rollback, token masking. Release tooling is 재연님's.
9. Legacy `search_fts` dual lookup, triggers and the 1-second migrator (`server/search-schema.ts`, `manuscript-search*.ts`). Depends on how old a backup must still restore; a one-time move at open keeps old backups working.

Deliberately kept (니아): helper shell `workspacePath` / `O_NOFOLLOW` / `nlink` (the model runs arbitrary shell), backup `verifySnapshot`, access session and network policy, `stored-shape-upgrades` and `nativeRisuSnapshotNeedsRefresh` until the backup-restore horizon is decided.

From PR #48 (live resources invalidation, 2026-11-28; pre-existing or left out):

- A workspace undo answers 409 when the previous save changed the program: the write-through bumps the preset revision and the undo replays the stale one (found while writing the live-frame test).
- Deleting content or a prompt preset sends no `resources` frame, so a library list on another device keeps the item until focus. `ChatOptionSettings` and `HelperTaskRollback` still follow only `helperDataFrame`.
- Idea (니아): send the post-commit hub notification for `recordPromptWorkspaceUpdate` / `recordContentProfileEvents` from the store, next to the held invalidations, so no route has to remember `publishAll`.
- The detail panel delete button keeps the revision from when the detail opened, so after a clean live update a delete from the detail shows the conflict notice first (safe direction; same as before).

From PR #49 (helper MCP spike, 2026-11-28):

- Installed clients (Claude Code 2.1.332, Codex 0.172.0) never call `skills/list`; the four skills are served and verified with the SDK client only. Recheck client support before investing in user-written skills.
- `chat_list` / `chat_read` are inline in `HelperRuntime` and were left out of the MCP tool list; a SKILL.md-only change does not select `tests/mcp.test.ts` in `check:changed`; in-flight MCP calls are not cancelled at shutdown.
- Ideas: move `server/mcp-routes.ts` onto the Domain Command entry (`executeOperation`) as commands land; expose a free `image_read` as MCP image content (니아); library items as MCP resources (not urgent, tools already read with revisions).
