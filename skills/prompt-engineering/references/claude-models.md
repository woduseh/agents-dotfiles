# Claude Model Notes

Read this when the prompt, skill, or agent instruction runs on a current Claude model. The baseline is Claude Fable 5.1 (and Claude Mythos 5.1, which shares the model); most of it also holds for Claude Fable 5 and Claude Opus 5. It lists what to remove, what to add for a given symptom, and the API constraints a prompt must respect.

Last verified: 2026-09-03. Sources: the Anthropic docs pages "Prompting Claude Fable 5.1", "Migrating to Claude Fable 5.1 and Claude Mythos 5.1", "Prompting Claude Fable 5", and "Prompting best practices" (platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices). Snippets in quotation blocks are reproduced from those pages; everything else is paraphrased. Re-verify against the current pages before relying on version-specific claims.

## Contents

- Remove or replace
- Add when the symptom appears
- General techniques
- Effort
- API constraints for prompts that build requests

## Remove or replace

Instruction-following is strong enough that one brief instruction steers most behaviors. Instructions written for earlier models often over-steer now.

| Found in the prompt | Why it now hurts | Replace with |
| --- | --- | --- |
| Anti-formatting rules ("use bullets and bold minimally", "avoid markdown") | Current models already format less; the rule suppresses structure the content needs | A positive rule that says when structure is appropriate (see "Formatting" below) |
| "Hold all findings for the final response", "keep updates brief" | The model already narrates less during tool chains; users see it go quiet | The progress-update line below |
| "Think step by step", "show your reasoning", "explain your thinking in the response" | Reasoning is handled by adaptive thinking; asking the model to transcribe it can trigger the `reasoning_extraction` refusal | Nothing, or read `thinking` blocks through the API |
| "CRITICAL: you MUST use this tool when…", "ALWAYS", "NEVER" as emphasis | Over-triggers | Plain conditions: "Use this tool when…" |
| "If in doubt, use [tool]", "default to [tool]" | Over-triggers | "Use [tool] when it would improve your understanding of the problem" |
| Long lists of near-duplicate tone or brevity rules | Each adds context cost without adding behavior | One instruction: lead with the outcome, then supporting detail; keep output short by selecting what to include, not by compressing into fragments |
| "Break the work into small steps and stop after each", "lay out options before implementing" | Produces turns that end on "Next, I'll…" or ask permission for requested work | The autonomy and scope blocks below, plus a recommendation-not-survey rule |
| Prefilled assistant turns | Return a 400 | System-prompt instruction, structured outputs, or a tool call |
| Forced `tool_choice` (`any`, `tool`) | Returns a 400 on Claude Fable 5.1 | `tool_choice: auto` plus an instruction naming the tool and `strict: true` on the tool |
| Per-turn reminders spliced into and then removed from history, or a `system` prompt rebuilt each request | Invalidates later thinking blocks and restarts the prompt cache | Turn-scoped or mid-conversation system messages left in the history |

## Add when the symptom appears

Add only the block that matches an observed problem. Each is a system-prompt or user-message addition unless noted.

**Little or no user-facing text during long tool chains:**

> Before you start, say in a line what you're about to do; brief updates while you work help the user follow along. Close with a short recap that stands on its own — what you found, what you did, and what's next — so a reader who only sees the last message has the full picture.

**Prose runs long and dense:** define the anti-pattern rather than asking for brevity.

> Mannered prose substitutes metaphor and flourish for direct statement. Instead of "a parameter worth varying," the mannered writer produces "a dial worth turning." Instead of "this point still matters," they write "this point earns its keep." The phrases exist to display the writer, not to convey the idea, and readers can tell. That is why mannered prose irritates: it makes the reader work harder so the writer can perform. It is also imprecise. Metaphors drag in connotations the writer did not choose and cannot control. The fix is to say what you mean. When a literal phrase is available, use it.

The short form "Please remove all mannered prose." also works.

**Chat replies carry less structure than the content needs (Formatting):**

> Use lists and bullet points when asked to, or when the content is multifaceted enough that they help with clarity. If the person explicitly requests minimal formatting, always format your responses without bullet points, headers, lists, or bold emphasis, as requested. In conversational, personal, or emotional exchanges, keep to plain prose.

**Summaries reproduce source wording without marking it:** add one complete example to the system prompt: the user's request, a correct response, and a one-sentence rationale saying that each source is conveyed in the assistant's own indirect speech with at most one short marked quotation. Replace the tool-call placeholders in the example with the real tool's name so the model reads them as templated tool output.

**Turn ends before the work is done, or the model asks permission for requested work:** the opening sentence carries most of the effect; keep it as written. Add a sentence after it listing any confirmations the product still requires.

> You are operating autonomously. The user is not watching in real time and cannot answer questions mid-task, so asking 'Want me to…?' or 'Shall I…?' will block the work. For reversible actions that follow from the original request, proceed without asking. Stop only for destructive actions or genuine scope changes the user must decide. Offering follow-ups after the task is done is fine; asking permission before doing the work is not.
>
> Exception: when the user is describing a problem, asking a question, or thinking out loud rather than requesting a change, the deliverable is your assessment. Report your findings and stop. Don't apply a fix until they ask for one.
>
> Before ending your turn, check your last paragraph. If it is a plan, an analysis, a question, a list of next steps, or a promise about work you have not done ('I'll…', 'let me know when…'), do that work now with tool calls. That includes retrying after errors and gathering missing information yourself. Do not stop because the context or session is long. End your turn only when the task is complete or you are blocked on input only the user can provide.

For interactive, human-in-the-loop products use the softer form instead: pause only for a destructive or irreversible action, a real scope change, or input only the user can provide; ask and end the turn rather than ending on a promise.

**Unrequested fixes or extensions, or more committed test files than the task called for:**

> If, while working or testing, you find a pre-existing bug, a performance concern, or behavior the task doesn't mention, don't fix, optimize or extend it in this change unless the requested behavior cannot work without it; report it as a follow-up in your summary. Where the task is ambiguous, implement the reading its wording and the surrounding code most directly support, state that assumption in your summary, and don't build for the other readings as well. Verify your work however you like; scratch scripts and quick checks need not be kept. Commit tests only where the task asks for them or this repository already keeps tests for this kind of change, sized like the neighboring test files — roughly one focused test per stated behavior — and don't turn scratch checks into additional permanent test files. This is about extras only: implement every behavior the task asks for, completely.

**Whole files rewritten for small changes:**

> The number of tokens used to edit files is best minimized, all else being equal. Therefore, when it will not affect the end result, try to surgically edit a file rather than rewrite the entire thing.

**Answers from memory instead of searching (mostly at `low` effort):** raise effort for those turns, or add:

> When a query centers on a name you do not confidently recognize, or recognize from a fast-moving area like AI models and developer tools where the landscape shifts within months, the name itself is the thing to verify: search before answering, and include the name as the user wrote it in at least one query alongside any reformulations. This holds even when you have some background on it — partial background is exactly what makes an out-of-date answer sound authoritative, so familiarity is not a reason to skip the search.

**One tool call per turn in a coding or computer-use loop:** send after each round of tool results, as a turn-scoped system message (`clear_at: "next_user_message"`, beta) or in a text block after the `tool_result` blocks, and leave earlier copies in the history:

> First privately list what you need next; then request every item that doesn't depend on another's result in this one response.

**Fabricated or optimistic status reports on long runs:**

> Before reporting progress, audit each claim against a tool result from this session. Only report work you can point to evidence for; if something is not yet verified, say so explicitly. Report outcomes faithfully: if tests fail, say so with the output; if a step was skipped, say that; when something is done and verified, state it plainly without hedging.

**Over-planning on ambiguous tasks:**

> When you have enough information to act, act. Do not re-derive facts already established in the conversation, re-litigate a decision the user has already made, or narrate options you will not pursue in user-facing messages. If you are weighing a choice, give a recommendation, not an exhaustive survey. This does not apply to thinking blocks.

**Client-side compaction drops constraints or exact details:** tell the summarizer what to preserve: problems and how they were handled; options tried or set aside and why; everything asked, decided, ruled out, or established as a preference or constraint, stated exactly; where things stand; what is still open or promised; hard-to-reconstruct details (names, numbers, dates, exact wording, links) kept exactly. Keep the user's words close to verbatim; condense the assistant's own reasoning to what it concluded.

**Long deliverable at `xhigh` or `max` effort takes long or hits `max_tokens`:** run at `high` unless a measured gain justifies more. If you stay high, set `max_tokens` for thinking plus reply and append a note that reasoning and reply share one limit of about N tokens, so the model should not draft the whole deliverable in reasoning and again as the reply.

**Benign coding requests return `stop_reason: "refusal"`:** ask "Are there any bugs in this program?" rather than "Does this compile without errors?"; give context or documentation for lesser-known languages; keep base64 payloads out of tool results.

## General techniques

These hold across current Claude models and are the defaults to reach for before any model-specific block.

- Give the reason behind a rule; the model generalizes from the explanation better than from the bare rule ("the output is read aloud, so no ellipses" beats "never use ellipses").
- Say what to do instead of what not to do ("write in flowing prose paragraphs" beats "no markdown"), and match the prompt's own formatting to the output you want.
- Wrap mixed content in XML tags (`<instructions>`, `<context>`, `<input>`, `<example>`) with consistent names. Use three to five examples that are relevant and diverse, inside `<examples>`.
- For inputs over about 20k tokens, put the documents at the top inside `<document>` tags with `<source>` metadata, the query and instructions at the end, and ask for relevant quotes first when the task depends on finding them.
- One sentence of role in the system prompt is enough to focus behavior.
- Action posture is steerable in both directions. To have the model implement rather than suggest, say so ("implement changes rather than only suggesting them; infer the most useful likely action and proceed"). To keep it from acting on ambiguous requests, say that too ("default to information and recommendations; edit only when explicitly asked").
- Reversibility guidance for agents: encourage local, reversible actions (editing files, running tests) and require a check-in before destructive, hard-to-reverse, or externally visible ones (deleting, force-push, reset --hard, pushing, commenting on PRs, sending messages), and forbid destructive shortcuts such as `--no-verify` or discarding unfamiliar files.
- Over-engineering damping, when the model adds files, abstractions, defensive handling, or comments beyond the request: scope only what was asked; no docstrings or annotations on untouched code; no error handling for scenarios that cannot happen; no helpers for one-time operations; the minimum complexity for the current task.
- Subagent damping, when it delegates where a direct call would do: subagents for parallel, isolated-context, or independent workstreams; direct work for simple, sequential, single-file, or context-carrying tasks.
- Grounding for code questions: never speculate about code not opened; read a referenced file before answering.
- Self-check ("before you finish, verify your answer against …") helps on most models; on Claude Opus 5 it causes over-verification, so remove it there.
- Temporary files: the model may create scratch scripts while iterating; ask it to remove them at the end if that matters.

## Effort

Effort is the primary intelligence, latency, and cost control. Start at `high` and sweep `low`, `medium`, `xhigh`, `max` on your own evals; level names do not map to the same thinking across model generations. On Claude Fable 5.1, `medium` roughly matches Claude Fable 5 at lower cost and `low` competes with smaller models on cost per task. Gains over the prior model are largest at `xhigh` and `max`, which also add time to first response. Change effort mid-conversation with an effort-only `role: "system"` message (beta) rather than per request, to keep cache hits.

## API constraints for prompts that build requests

- Adaptive thinking is always on; `thinking: {type: "disabled"}` and `budget_tokens` return a 400. Control spend with effort.
- Keep history append-only: return each assistant turn exactly as received, thinking blocks included. Do not edit, reorder, or remove earlier turns, rebuild `system` or `tools`, or splice reminders in and out. Use mid-conversation system messages for instruction, tool, or effort changes, and turn-scoped system messages for one-turn reminders. Compact server-side, or replace the whole history with one summary plus the new user turn.
- Thinking blocks are readable only by the model that produced them or a newer one; a fallback to an older model drops them.
- Progress text between tool calls arrives as `thinking` blocks and is empty under the default `thinking.display: "omitted"`; set `"updates"` (beta) or `"summarized"` to render it.
- Handle `stop_reason: "refusal"` and `stop_details.category`; `fallbacks: "default"` (beta) re-runs a declined request on a permitted model.

