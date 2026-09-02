---
name: image-prompt-design
description: "Designs or refines ready-to-use prompts and visual specifications for gpt-image-2, including editing, exact in-image text, product preservation, and repeated-character consistency. Use when the deliverable is an image prompt or spec; use the runtime's own image tool or skill to generate or edit bitmaps."
---

# Image Prompt Design

## Core Principles

- Describe only details that should materially affect the image.
- Prefer concrete composition, subject, lighting, color, material, and preservation instructions over vague quality tags or long mood lists.
- Preserve user-provided identity, geometry, layout, text, brand elements, and other invariants explicitly.
- Iterate with targeted changes instead of rewriting the whole prompt unless the visual direction changes.
- Ask a brief question only when a missing choice would materially change the result; otherwise choose sensible defaults.

## Prompt Workflow

1. Identify the image type and intended use.
2. Choose an appropriate canvas ratio and fidelity level.
3. Specify the subject, environment, composition, style or medium, lighting, color, and important constraints.
4. Quote exact in-image text and require verbatim rendering when text fidelity matters.
5. State what must remain unchanged for brand, product, identity, or reference-sensitive work.
6. Return the ready-to-use prompt and only the settings relevant to the request.

For complex requests, use a compact visual-spec structure:

```text
Goal:
Subject:
Scene and composition:
Style and medium:
Lighting and color:
Text, if any:
Constraints:
```

Do not force this structure on a simple prompt or include empty labels.

## Conditional Guidance

- For image editing, sketch-to-render work, exact text, product preservation, style transfer, or repeated-character consistency, read [references/editing-and-consistency.md](references/editing-and-consistency.md).
- Before providing API code or parameter claims, or making an API call where validity matters, verify the current official OpenAI image-generation documentation and read [references/gpt-image-2-api.md](references/gpt-image-2-api.md).
- For prompt-writing or visual-direction requests without API details, do not browse solely to revalidate parameters.

## Output

Lead with the ready-to-use prompt. Add a short settings block only when it helps the user execute it:

```markdown
## Image Prompt

(Ready-to-use prompt)

## Settings

- Model: gpt-image-2
- Size:
- Quality:
```

Omit unset or irrelevant settings.
