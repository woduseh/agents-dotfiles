# Helper split: in-app helper and MCP harnesses (working design, 2026-11-28)

Merged from 리아 (Fable) and 니아 (gemini-4-carbon high) at 재연님's request. Not decided: 재연님 chooses after trying the MCP endpoint (v0.19.1) for some days. 니아's full answer is the last message of T3 thread "니아: 도우미 기능을 인앱과 MCP에 어떻게 나눌지".

## 재연님's intent and constraints
- The helper should hold tools as powerful and broad as possible, so it works freely and confidently, from "where is this setting?" to "why did this request fail? fix it and send it again so it succeeds".
- First impression before the trial: desktop MCP for serious large work, the in-app helper when on the phone; carrying every feature on both would be too heavy; the in-app helper's problem is cost.
- Change cards and turn rollback are not needed on the MCP side (a backup or another edit is enough).
- Facts (production snapshot, 2026-09-28..11-27): 158 helper tasks, about $29; 25% of tasks (13+ rounds) are 66% of the cost; `data.exec` (Linux data workspace, commit `50d360fd`) is the most used tool (514 calls); writes are rare.

## The frame both agree on
A harness replaces the helper's **runtime** (model loop, shell, context management, skills), not its **breadth**. Both surfaces reach the same tools; the in-app helper's own job is being **situated** (the scene on screen, the open editor's unsaved draft, a selection, one-tap confirmation).

## 니아's corrections to 리아's first version
1. Same breadth does not mean a flat `tools/list` of ~75 schemas (니아 estimates 35–45k tokens per first turn on harnesses without lazy loading, such as Codex). MCP exposes a core of 22–25 tools directly and the rest through an MCP `app_tools` + `app_call` gateway, as the in-app helper already does.
2. 리아 claimed a server-side "prepare a draft without starting" pattern exists; it does not. The composer draft is browser-only (`web/useStory.ts`), confirmations are bound to `helper_tasks` (`server/helper-confirmations.ts`), and the only server-side staged thing is `options.oneoff`.
3. Paid actions: an instruction typed to one's own harness ("fix it and resend so it succeeds") is the user's explicit request, and forcing a return to the app loses the harness's ability to retry and confirm success. Proposed rule: both surfaces follow the same `helperConfirmPaidGeneration` setting; permanent deletion always waits for a one-tap confirmation in the app. **Open for 재연님** (see below).

## What the MCP side needs for "why did it fail, fix it, resend"
1. `task.inspect(kind='run')` returns the failed request text and model summary (today it drops `runs.command.request`).
2. `task.retry` accepts an edited `request` (`server/run-retry.ts` already takes it; the tool passes empty options).
3. `McpPorts` gets action callbacks (cancel, enqueue, connection tests) without exposing keys.
4. A task-independent place for staged requests / pending confirmations that an open chat shows, and an "active reading" resource (current chat and scene from `reading_positions`).

## What gets deleted
Not breadth: the duplicated runtime. `data.exec` is a container runtime; on the desktop a small local sync script (`pull`/`apply` of the same `library/` and `chats/` tree) lets the harness's own shell replace it. Then `server/helper-shell*.ts` (~1,150 lines) and `runner/uimori.mjs` can go (`runner/runner.mjs` is shared with the writing `MainShell`; decide together). Gives up: bulk text analysis with Python from the phone. Pricing backfill becomes a button in the pricing editor; the tool stays for symmetry.

## Order (니아)
1. `task.inspect` request text, pricing backfill button, MCP `app_tools`/`app_call` gateway and control ports (plus `image_read` / `image_update_metadata`).
2. Local `pull`/`apply` sync script.
3. Phone default model cheaper (Flash/Argon or the Codex runtime); try the in-app helper with `data.exec` off.
4. Remove `helper-shell*` (and the runner container if the writing shell is unused).

## What 재연님's trial should settle
1. Failure recovery: is it more natural for the desktop harness to resend and confirm success, or to press send in the app?
2. Shell autopsy: what the 514 `data.exec` calls and the writing `MainShell` calls actually did — decides whether the runner container can go.
3. Phone feel: with a cheap default model and no `data.exec`, do bedside tasks finish comfortably within about six rounds?
4. How often in-app rollback is really used — if rarely, `helper_changes`, `helper_rollback` and the helper hooks in `server/command.ts` can go too.

## Bold idea (니아)
"Send to the workshop": when a phone task turns out to be a 15-round job, a button hands the current scene, editor pointer or failed run id to a background harness session connected over MCP, instead of the in-app loop spending dollars.

## 재연님's answers after the first MCP session (2026-11-28 evening)
- MCP works well for them from the desktop harness (connection, 20 tools with descriptions, `guide_read` used to summarize a feature).
- **Paid generation over MCP: decided — 리아's recommendation.** An outside harness may start paid generation when the user explicitly asks; MCP follows the same `helperConfirmPaidGeneration` setting as the in-app helper, with confirmation on by default for MCP; permanent deletion always waits for a one-tap confirmation in the app.
- Failure recovery (harness finishes vs. pressing send in the app): not sure yet; needs use.
- Cheap model on the phone: wants to try it first.
- In-app rollback: "hardly ever used, probably an excessive safeguard". Treat change cards + turn rollback (`helper_changes`, `helper_rollback`, the helper-only hooks in `server/command.ts`) as a deletion candidate; ask for an explicit yes before removing a visible feature.
- **In-app change cards + turn rollback: delete (재연님, explicit yes, 2026-11-28 evening, eighth coordinator thread).** Recovery is a backup or another edit.
- **Deletion over MCP (재연님, 2026-11-28 night, supersedes "permanent deletion always confirms in the app" for MCP):** a setting lets an outside harness delete without confirmation; 재연님 trusts the strong models (Fable, Opus, Carbon, Neon) and expects to turn it on. Coordinator's reading, stated back to 재연님: the setting is off by default (deletes are refused, or wait for the one-tap confirmation once that exists) and turning it on lets the eight delete operations run at once. "Edits are edits" (same night): a save through MCP replaces content as in the app; only delete operations are gated.
- They like 니아's bold ideas ("send to the workshop") together with 리아's practical checks.

## Open decision for 재연님 (answered above; kept for the reasoning)
May an MCP harness start paid generation directly (following the confirm setting), or does it only prepare and the app confirms? 리아's concern: an outside harness reads third-party cards, so injected text could ask it to call a paid tool; and the MCP token sits in config files (plain text in Antigravity's). 리아's recommendation: allow it only behind the same confirmation setting, with the setting on by default for MCP, so the user opts into direct runs knowingly.
