# GPT Image 2 API Reference

Use this reference only when providing API settings or code, or when making an API call where parameter validity matters. Verify the current official OpenAI image-generation documentation before relying on these values.

Last verified: 2026-06-11

## Current Defaults And Constraints

- Model: `gpt-image-2`.
- `size`, `quality`, and `background` support `auto`; `size` and `quality` default to `auto`.
- Quality values: `low`, `medium`, `high`, and `auto`.
- A custom size must have both edges as multiples of `16px`.
- The maximum edge length is `3840px`, inclusive.
- The long-edge to short-edge ratio must not exceed `3:1`.
- Total pixels must be from `655,360` through `8,294,400`, inclusive.
- Omit `input_fidelity` for `gpt-image-2`; image inputs are processed at high fidelity automatically.
- Transparent backgrounds are not currently supported by `gpt-image-2`.

## Quality Selection

- Use `auto` unless the task needs a deliberate fidelity, latency, or cost tradeoff.
- Use `low` for fast ideation and latency-sensitive previews.
- Use `medium` for most production drafts and edits.
- Use `high` when maximum fidelity matters more than latency.

Official source: https://developers.openai.com/api/docs/guides/image-generation
