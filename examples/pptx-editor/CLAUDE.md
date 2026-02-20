# PPTX Editor — Claude Code Instructions

## Workflow

1. User presentations live in `work/presentations/`.
2. Open with: `from pptx import Presentation; prs = Presentation("work/presentations/FILE.pptx")`
3. After editing, **overwrite the original**: `prs.save("work/presentations/FILE.pptx")`
4. Commit after each meaningful edit: `git add -f work/presentations/FILE.pptx && git commit -m "description"`

## Helper Scripts

All helpers are in `examples/pptx-editor/`.

- **`pptx_helpers.py`** — importable functions:
  - `open_presentation(path)` / `save_presentation(prs, path)`
  - `insert_equation_image(slide, png_path, left, top, max_width, max_height)`
  - `replace_text_in_slide(slide, old_text, new_text)`
  - `list_slide_texts(prs)` — summary of all text on all slides
- **`render_equation.py`** — render LaTeX to PNG:
  - CLI: `python3 examples/pptx-editor/render_equation.py "E = mc^2" /tmp/eqn.png --dpi 300`
  - Library: `from examples.pptx_editor.render_equation import render_equation`

## Rendering Equations in LaTeX

When the user wants an equation in a slide:
1. Render to PNG: `python3 examples/pptx-editor/render_equation.py "LATEX_STRING" /tmp/eqn.png`
2. Remove the old text-based equation from the slide
3. Insert the PNG using `insert_equation_image()` from `pptx_helpers.py`
4. Position it where the text was

The LaTeX string uses standard math notation (amsmath, amssymb available).
`\displaystyle` is already in the template — no need to add it.

## Style Preferences

### Equations
- All mathematical equations MUST be rendered as LaTeX images, never left as plain text
- Use 300 DPI for equation images
- Equations should have transparent backgrounds
- Center equations horizontally on the slide

### Text
- Use clear, readable fonts (Calibri or Arial preferred)
- Title slides: 36–44pt titles
- Body text: 18–24pt
- Bullet points should be concise (one line each when possible)

### Layout
- Prefer clean, minimal layouts
- One key idea per slide
- Maximum 6 bullet points per slide
