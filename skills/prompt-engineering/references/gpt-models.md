# GPT Model Notes

Read this when the prompt, skill, or agent instruction runs on a current GPT model. The baseline is `gpt-5.6-sol`, the highest tier of the GPT-5.6 family. It lists what to remove, what to add for a given symptom, and the API constraints a prompt must respect.

Last verified: 2026-09-03. Sources: the OpenAI docs pages "Using GPT-5.6" (developers.openai.com/api/docs/guides/latest-model), "Prompting guidance for GPT-5.6 Sol", and "Upgrading to GPT-5.6 Sol". Appending `.md` to a docs URL returns the Markdown version. Snippets in quotation blocks are reproduced from those pages; everything else is paraphrased. Re-verify model IDs, limits, prices, and defaults against the live pages before relying on them.

## Contents

- Model family
- Remove or replace
- Add when the symptom appears
- Reasoning effort and pro mode
- API constraints for prompts that build requests
- Prompt structure and migration workflow

## Model family

- `gpt-5.6-sol` is the flagship tier; the `gpt-5.6` alias routes to it. `gpt-5.6-terra` is the mini-like tier and `gpt-5.6-luna` the nano-like tier for classification, extraction, routing, and high-volume or strict-latency work.
- Sol and Terra have roughly 1.05M context; Luna has 400K. All three have 128K maximum output. Sol and Terra requests above 272K input tokens can change pricing for the whole request. Confirm these in the live docs before writing them into a registry, picker, or prompt.
- When migrating a multi-model design, map each role to a tier (flagship to Sol, mini to Terra, nano to Luna) rather than collapsing everything into Sol. Pro is a mode on the same model (`reasoning.mode: "pro"`), not a separate slug.
- GPT-5.6 infers the intended level of work from context well, so the prompt should carry domain context, hard constraints, approval boundaries, success criteria, and which ambiguities warrant a question, not every step.
- Real-time cyber and biology misuse classifiers run on outputs. They can pause generation mid-stream or refuse, and can intervene on legitimate dual-use work such as vulnerability research or defensive testing. Applications serving end users should send a stable, privacy-preserving `safety_identifier`.

## Remove or replace

OpenAI's internal coding-agent evals scored leaner system prompts roughly 10–15% higher while using 41–66% fewer tokens. Remove one group of instructions, examples, or tools at a time and rerun the same evals.

| Found in the prompt | Why it now hurts | Replace with |
| --- | --- | --- |
| The same rule stated twice; style or process instructions that do not change behavior; examples that do not change behavior; tools unrelated to the task | Each costs context and can amplify over a long session | State once; keep only examples and style rules that encode a product requirement or fix a measured gap |
| "Be concise", "Keep it short" | GPT-5.6 is already more concise than GPT-5.5; the rule can make answers too brief | `text.verbosity` as the default, plus a statement of what a short answer must include |
| "Think step by step", "be thorough", "think harder" | Effort and pro mode handle depth; the words add nothing | A missing success criterion, dependency rule, tool-routing rule, or verification loop, then effort |
| ALWAYS, NEVER, must, only on judgment calls (when to search, ask, use a tool, keep iterating) | GPT-5-class models follow contracts closely; absolutes on judgment calls create instability | Decision rules; keep absolutes for true invariants such as safety rules and required fields |
| Repeated "ask first", "do not mutate", "wait for approval" | Blocks safe local work behind approval requests | One autonomy policy in one place (below) |
| "Always respond in the user's language" | Unwanted language switching | The intended output language and when it should change |
| Universal defaults, keyword maps, broad semantic shortcuts for implicit values | Override the context the model could have reasoned from | Decision criteria; preserve explicit user values |
| "Use Programmatic Tool Calling efficiently", or relying on tool availability to pick the route | Does not produce the right route | A task-specific route: bounded stage, eligible tools, output schema, limits, handoff |
| "Minimize tool loops" | Can outrank correctness, evidence, or required validation | The stopping condition below |
| Narrating every tool call | Noise | A preamble before the first call and sparse phase updates |
| A prompt stack rewritten wholesale during a model migration | A regression can no longer be attributed to model, effort, prompt, tools, or runtime | One surgical edit per measured failure, evals rerun after each |

## Add when the symptom appears

Add only the block that matches an observed problem.

**Implements when asked only to review, or asks permission for requested work:**

> For requests to answer, explain, review, diagnose, or plan, inspect the relevant materials and report the result. Do not implement changes unless the request also asks for them.
>
> For requests to change, build, or fix, make the requested in-scope local changes and run relevant non-destructive validation without asking first.
>
> Require confirmation for external writes, destructive actions, purchases, or a material expansion of scope.

Name the safe local actions explicitly (reading files, inspecting logs, editing in-scope code, running tests). For long-running work, also name the current layer (research, design, implementation, review, external coordination) so the model does not move between layers silently.

**Stops early, or keeps searching past the point of an answer:**

> Resolve the request in the fewest useful tool loops, but do not let loop minimization outrank correctness, required evidence, calculations, or required citations.
>
> After each result, ask whether the core request can now be answered with useful evidence. If yes, answer. If required evidence is still missing, name the missing fact and use the smallest useful fallback.

**Answers too brief after migration:** set `text.verbosity`, then say what must survive.

> Lead with the conclusion. Include the evidence needed to support it, any material caveat, and the next action. Omit secondary detail and repetition.

**Tone rules read as labels ("friendly", "empathetic"):** describe the writing choices instead.

> State the answer directly. If the user reports a problem, acknowledge the specific issue before giving the next step. Use reassurance only when it is relevant. Omit generic praise and unnecessary sign-offs.

**Edits, rewrites, or summaries add claims or a promotional tone:**

> Preserve the requested artifact, length, structure, genre, and factual claims first. Improve clarity, flow, and correctness without adding new claims, sections, or a more promotional tone unless requested.

**Skips a prerequisite lookup because the end state seems obvious:**

> Before taking an action, resolve required discovery, retrieval, and validation steps. Do not skip a prerequisite because the intended final state seems obvious.

Also state that independent reads run in parallel, dependent ones run sequentially, and that one or two meaningful fallbacks follow an empty or suspiciously narrow tool result.

**Silent during multi-step work:**

> Before tool calls for a multi-step task, send a one- or two-sentence user-visible update that states the first step. During the task, update only when a major phase begins or a finding changes the plan. Each update should state one concrete outcome and the next step.

**Unsupported claims in grounded answers:** define what needs support, what counts as enough evidence, and what to do when evidence is missing; absence of evidence is not a factual "no". For ordinary Q&A, one broad search with short discriminative keywords, and another retrieval only for a missing required fact, an explicit request for exhaustive coverage, a specific artifact that must be read, or an otherwise unsupported important claim. For research: cite only retrieved sources, attach citations to the claims they support, label inference separately, state conflicts, and narrow or report missing evidence instead of guessing. For creative drafting: do not invent names, metrics, dates, roadmap status, or product capabilities.

**Declares done without validation (coding):**

> After making changes, run the most relevant validation available:
> - targeted tests for changed behavior
> - type checks or lint checks when applicable
> - build checks for affected packages
> - a minimal smoke test when full validation is too expensive
>
> If validation cannot be run, explain why and describe the next best check.

For visual artifacts, ask it to render and inspect layout, clipping, spacing, missing content, and consistency before finalizing. For agentic migrations, add: preserve existing functionality, routes, outputs, and user-visible behavior; do not delete or disable required behavior to make the build pass.

**Frontend changes add decoration or features:** inspect and preserve existing design tokens, components, and patterns; add nothing unrequested; preserve responsive behavior and expected states; render before finalizing.

## Reasoning effort and pro mode

- `reasoning.effort` accepts `none`, `low`, `medium`, `high`, `xhigh`, and `max`. Omitted, GPT-5.6 defaults to `medium`. GPT-5.5 also defaulted to `medium`, but GPT-5.4, mini, and nano usages commonly defaulted to `none`, so an omitted setting can become slower and more expensive after a model swap. Preserve the old effective effort explicitly for the first run, then compare one level lower.
- `medium` is the balanced start, `low` for latency-sensitive work that keeps quality, `high` or `xhigh` only when evals show a gain, `max` reserved for the hardest quality-first work and never recommended globally. Before raising effort, check whether the prompt lacks a success criterion, dependency rule, tool-routing rule, or verification loop.
- Pro mode (`reasoning.mode: "pro"`, Responses API only) does more model work before one final answer, at higher latency and with those tokens billed at standard rates. Mode and effort are independent; supported pro efforts begin at `medium`. Keep the same outcome-focused prompt; do not ask the model to "use pro mode", "think harder", or generate several candidates. Compare against standard mode on the same tasks before adopting it.

## API constraints for prompts that build requests

- Use the Responses API for reasoning, tool calling, and multi-turn work. In Chat Completions, function tools work only with effective reasoning `none`; because GPT-5.6 defaults to `medium`, a Chat Completions request with tools must set `reasoning_effort: "none"` explicitly or move to Responses. Do not hide the incompatibility by dropping tools or reasoning.
- Persisted reasoning: `reasoning.context` accepts `auto`, `all_turns` (the GPT-5.6 default), and `current_turn` (the earlier default). Use `all_turns` when goals and assumptions stay stable across turns and continue with `previous_response_id`; when replaying history manually, resend every prior user input and every output item, including encrypted reasoning items under `store: false` or Zero Data Retention, and keep item types, IDs, `call_id`, `caller`, and assistant phase values unchanged. Switch to `current_turn` when earlier reasoning would anchor the model to a stale approach.
- Prompt caching: implicit caching places a managed breakpoint near the latest user or tool message with no 128-token rounding, so a stable prefix followed by a changing suffix can lose hits. Cache writes cost 1.25× uncached input; track `cached_tokens` and `cache_write_tokens`. `prompt_cache_options` (`mode: "explicit"`, `ttl`) replaces `prompt_cache_retention`; place `prompt_cache_breakpoint` at a real stable boundary only when a measured workload needs it. Keep reusable prefixes stable and compact after milestones, not every turn.
- `text.verbosity` accepts `low`, `medium`, and `high` and sets the default detail level; the prompt carries task-specific length and content requirements.
- Programmatic Tool Calling: add the `programmatic_tool_calling` tool and opt tools in with `allowed_callers: ["programmatic"]`; the host handles `program`, program-issued `function_call`, `function_call_output`, and `program_output` items and preserves `call_id` and `caller`. Use it only for bounded reduction (filtering, joining, ranking, deduplication, aggregation, repeated deterministic validation). Prefer direct calls when one call suffices, intermediate outputs are small, each result may change the next decision, an action needs approval, citations or native artifacts must survive, or semantic judgment sits between calls. Test the `program_output` item and the final message separately.
- Multi-agent (beta): header `OpenAI-Beta: responses_multi_agent=v1`, `multi_agent: { "enabled": true, "max_concurrent_subagents": N }`, and handling for `multi_agent_call`, `multi_agent_call_output`, and `agent_message` items. Cap concurrency and require a final synthesis.
- Image detail: omitted or `auto` preserves original dimensions up to 65,535 pixels per side, and the API rejects images over the 30,000-patch limit instead of resizing. Make detail explicit when cost or latency matters; keep original detail for dense, coordinate-sensitive, OCR, or visual-inspection tasks.

## Prompt structure and migration workflow

Suggested structure for a complex prompt, each section short and present only when it changes behavior:

> Role, Personality, Goal, Success criteria, Constraints, Tools, Output, Stop rules.

Personality covers tone, warmth, directness, formality, humor; collaboration style covers when the model asks, assumes, takes initiative, explains tradeoffs, and checks work. Keep both short; neither replaces goals, success criteria, tool rules, or stop conditions.

Migration order: switch the model and preserve the current effort; run representative evals before touching the prompt; remove obsolete scaffolding, repeated instructions, and irrelevant tools; add the smallest targeted instruction per measured regression; rerun evals after each change. Debug a regression from a few real traces: find the instruction or contradiction that caused it, edit surgically, rerun the same cases.

Validation matrix: old model with old prompt and settings; new model with the same prompt and preserved effort; the same with one lower effort; the smallest prompt or API fix a measured failure requires; any optional feature (pro mode, persisted reasoning, explicit caching, Programmatic Tool Calling, multi-agent) isolated from the baseline. Measure task success, output-contract validity, tool choice and loop count, latency, tokens including cache writes, and cost per successful task.
