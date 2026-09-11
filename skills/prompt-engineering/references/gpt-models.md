# GPT Model Notes

Baseline: GPT-6 Astra. Verified 2026-09-12 against [OpenAI's Astra prompting guidance](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#prompting-best-practices) and the [skill and instruction audit article](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). Preserve the user's named model and runtime settings.

## Documented tendencies

Astra can ask questions that interrupt otherwise actionable work, respond strongly to conflicting skill instructions, produce detailed or repetitive formatting, delegate less than desired, and overextend coding verification. The official guide recommends making autonomy, instruction priority, writing style, delegation, and verification expectations explicit where these behaviors matter.

## Applying this here

Start with the requested outcome and the host's existing instructions. Add guidance for a relevant gap or demonstrated failure; do not paste every possible correction into the prompt. Earlier model workarounds are candidates for removal, not permanent user preferences.

Keep discovery text concise and specific to the deliverable. Route to references by workflow; avoid mandatory repository tours or fixed procedures where the model can choose the method. Retain completion criteria and real authorization boundaries.

Use representative tasks to check whether removing a rule preserves completion, correctness, authorization boundaries, and useful reporting. Restore the smallest rule that addresses a reproduced failure. Shorter instructions alone do not establish better behavior.

Retrieve current official documentation for model-specific API or runtime changes. Pricing, effort levels, caching, and tool protocols do not belong in a global behavior prompt.
