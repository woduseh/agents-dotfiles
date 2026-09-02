# Editing and Consistency

Read only the sections relevant to the requested image prompt.

## Editing Input Images

- State what to preserve: identity, geometry, pose, camera angle, layout, product labels, materials, or composition.
- State what to change: lighting, background, outfit, object placement, weather, style, or rendering quality.
- For sketch-to-render work, preserve layout, proportions, and perspective before adding materials and lighting.
- For product extraction, preserve geometry and label legibility. Prefer an opaque plain background and use separate background removal when transparency is needed.
- For style transfer, describe the target style and what must not be redesigned.

## Exact Text

Use strict instructions when text must appear in the image:

```text
Text (EXACT, verbatim, no extra characters):
"..."
Typography:
Placement:
Legibility:
```

Ask for the text once, with high contrast and clean spacing. If fidelity fails, adjust the layout or wording narrowly.

## Repeated Characters or Story Pages

- Create a character anchor first and reuse it as an input image.
- Repeat invariant traits such as face, proportions, outfit, palette, and style.
- Change only the scene action, environment, pose, or emotion required for the next image.
- State that the character must not be redesigned when continuity matters.

## Useful Patterns

- **Product mockup:** plain background, crisp silhouette, exact label preservation, subtle shadow.
- **Marketing creative:** real-world placement, exact copy, controlled typography, no extra logos or watermarks.
- **Sketch to render:** preserve perspective and layout; add plausible materials, lighting, and environment.
- **Weather or lighting variant:** keep geometry and camera unchanged; modify atmosphere, shadows, precipitation, or surface wetness.
