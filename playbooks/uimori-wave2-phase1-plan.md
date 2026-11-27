# Uimori Wave 2 — design Phase 1 plan

Shaped by 리아 (draft) and 니아 (plan) on 2026-11-27 at `d7d98b43`. 니아's full answer, with file/line evidence and per-unit allowed globs, is in the T3 delegated thread "니아: Wave 2 Phase 1 계획" under the Wave 2 coordinator thread. This file keeps the decisions and the unit order.

## Decisions

- **Vertical feature folders for `server/` and `web/` wait for Phase 2 (Store dismantling) and Phase 4 (frontend).** Both agreed. The domain taxonomy is fixed now in `packages/contracts/src/domains/<domain>/` with 10 domains (`story`, `library`, `risu`, `prompts`, `providers`, `helper`, `illustrations`, `outline`, `appearance`, `workspace`), named to match `tests/feature-map.json` domains.
- **Package resolution: root `package.json` `"imports"` (`#contracts`, `#risu-engine/browser|node`, `#providers/browser|node`) over npm workspaces** (리아 decided, 니아's recommendation). Keeps the single atomic `dist/` swap, `distHash()`, rollback and the Dockerfile; Vitest/Vite/Workers read `.ts` without a build. Cost: no per-package dependency isolation (Biome `noRestrictedImports` instead), not publishable to npm. Spike (리아, 2026-11-27, scratch project with the repo's toolchain): root `"imports": { "#contracts": "./packages/contracts/src/index.js" }` resolves in TypeScript 7.0.2 (NodeNext), Vitest 5.1.1, Vite 8.3.8, and from `dist/` once `dist/package.json` (already a copy of the root one) carries the same map, since tsc with `rootDir: "."` emits to `dist/packages/...`. The one gap: running raw `.ts` (the Worker bootstrap in `server/risu-native-worker.ts`) fails because its resolve hook rewrites only relative `.js` → `.ts`; extend it to `#*` specifiers in P1-1.
- **Fastify + Zod: in-house `defineEndpoint` / `registerEndpoint` (~60 lines), no `fastify-type-provider-zod`.** Two layers: operation schema (`input`/`output`) + HTTP binding, so Phase 3 Domain Commands and an MCP server reuse the schemas. Response `parse()` runs only in test mode.
- **Error wire: flat `{ code, params? }`.** Codes are `<DOMAIN>_<REASON>` UPPER_SNAKE, continuing `errors.<CODE>` in `web/locales/`. Colon-encoded codes move into `params`. `web/api-errors.ts` maps with `satisfies Record<AppErrorCode, ...>`. Three error kinds: UI-facing `AppErrorCode`; schema validation → one `INVALID_REQUEST`; LLM helper tool diagnostics → `HelperToolError`, outside the UI catalog. Stored failure strings get one thin display fallback; Schema 15 untouched in Phase 1. No wire backward compatibility (재연님): nothing is deployed mid-transition and no other client version talks to the server, so `AppError` sends only `{ code, params? }`; web and the runner read `code` first and fall back to `error` only while unconverted `HttpError`s remain.
- Settled in 니아's P1-2a review: fixed-text DELETE 409 reasons and `HELPER_CONVERSATION_COPY_CHANGED` become param-free codes; only codes that must name the blocking target take `{ name }`. Byte limits travel as bytes and the web formats the unit; text limits stay character counts (`{ limit }`). HTTP status stays at the throw site, not in the catalog. Helper tool results carry an `AppError`'s params to the model. A legacy `{ error }` string takes the catalog path only for codes without params (`appErrorTakesParams`), so a code with params is converted at all its throw sites in one unit. Raw-`fetch` readers (`web/archive-download.ts`, `web/RisuExportButton.tsx`) switch to `readErrorWire` when their routes convert.
- Catalog only what the UI can receive (니아's P1-2b1 review, adopted by 리아). Routine CAS 409s whose only action is "reload and retry" share `REVISION_CONFLICT`. A distinct code exists only when the recovery action differs, code branches on it, or a form needs a specific hint. Errors only the helper can hit are `HelperToolError`s. Errors no caller can reach are not catalogued at all. Before P1-2b1 these 409s showed only the generic "(409)", so the shared text is no regression.
- **`helper-routes.ts` (35 routes) is converted in Phase 1 (P1-3g2)** so `request-validation` HTTP helpers and untyped `api<T>()` reach zero (리아 decided, 니아's default).
- Zod stays on v3 API (`zod@3.25.76`); no `zod/v4` mixing.
- Shared wire types touched in P1-3 (`LiveEventFrame`, `MaintenanceStatus`) move to `packages/contracts` for Phase 4's SSE bridge.

## Traps 니아 found (must be handled in the named unit)

- P1-0: `.github/workflows/quality.yml` `changes` job sparse-checks out only `scripts/ci-changes.mjs`; add the shared classifier file.
- P1-1: hard-coded roots to extend with `packages`: `scripts/lib.mjs` fingerprint dirs (stale builds otherwise), `scripts/check-comments.mjs`, `scripts/check-i18n.mjs`, `biome.json`, `lint:architecture`, `tests/module-cycles.test.ts`, and `tests/web-runtime-boundary.test.ts` (ignores non-relative imports, so `#*` would let `node:*` leak into the browser bundle).
- P1-2: of 1,310 `HttpError`s, 376 Korean, 431 existing codes, 471 English plain (many are request-validation 400s that P1-3 removes, or helper tool diagnostics), 32 dynamic. Don't mint codes for validation messages.
- P1-4: `risu-engine` needs separate browser and node entries (web imports the CBS analyzers); `providers` extracts only pure protocol/transport/capability/pricing/tokenizer plus `codex-process` and `novelai-client`; `codex-runtime.ts` (uses `node:sqlite`), `credentials.ts`, `provider-request.ts` stay in `server/` until Phase 2/3.

## Lens for every unit (재연님, 2026-11-27)

Remove over-verification that does not fit a personal, self-hosted, same-build app: no wire or version-skew compatibility, no defenses against scenarios a one-person deployment cannot have, no checks a same-build invariant already guarantees. Each unit removes such code and tests in the area it touches; keep what protects saved text, drafts in authoring editors (lorebooks, resources, long writing), paid generation and backup restore. A short chat input gets no safeguard of its own; credentials may be re-entered when lost, but the access gate and provider keys stay closed to others. AGENTS.md Boundaries carries this. Briefs and 니아's reviews ask this question explicitly.

## Units (each reviewed on its own)

Conversion units change assertions and imports only, with no test removal. Units that delete tests (P1-0, P1-2e, P1-3h) name the replacing test and confirm with `rg` that it mounts the same component and does the same thing.

| Unit | Goal |
| --- | --- |
| P1-0 | `scripts/change-classifier.mjs` shared by ci-changes, check-changed, verify, lib.mjs; sparse-checkout sync; one table-driven test |
| P1-1 | `packages/contracts` skeleton via `#contracts`; build-runner emits `dist/package.json`; adapt biome/tsc/check-comments/check-i18n/lib/module-cycles/web-runtime-boundary |
| P1-2a | Error core (`AppError`, catalog, wire schema), dual wire in app.ts, web parses `{ code, params }` first, `HelperToolError`, runner compatibility |
| P1-2b | Core domains to codes (Store/Chat/Library/Resource/Reading/Search/StoryGuide/Backup/Transfer/Push/Images), split b1/b2 if large |
| P1-2c | Appearance/Outline/Illustrations/Translation guides; colon codes → params |
| P1-2d | Helper/Risu/Provider/Credentials; zero Korean `HttpError` repo-wide |
| P1-2e | Remove i18n Korean reverse lookup (`sources`/`formatted`/`legacyMessage`/`registerMessage`), api-errors regexes, check-i18n Korean fallback; static guards |
| P1-3a | `defineEndpoint` + in-house adapter + typed web client; pilot on 4 small route groups |
| P1-3b–g | Route groups: appearance+workspace; library/prompts/providers; risu+transfer (binary); story/reader/chat (e1/e2); product-routes + app.ts (f1/f2); illustrations + helper (g1/g2) |
| P1-3h | Retire request-validation HTTP helpers; coverage guard for uncontracted `/api/*` and raw `api<T>()` |
| P1-4a | `packages/risu-engine` (browser/node entries, `internal/` blocked) |
| P1-4b | `packages/providers` (pure parts only) |
| P1-4c | Package-level impact selection in the classifier; CODE-MAP, CHECKS, feature-map sync |
