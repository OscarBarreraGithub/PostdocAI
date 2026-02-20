# PocketPostdoc — Claude Code Instructions

## Environment

You are running inside a sandboxed Ubuntu 24.04 dev container.
Available tools: python3, python-pptx, Pillow, pdflatex, latexmk, ghostscript, make, git.

## PowerPoint Editing Workflow

### Opening and Saving
1. User presentations live in `work/presentations/`.
2. Open with: `from pptx import Presentation; prs = Presentation("work/presentations/FILE.pptx")`
3. After editing, **overwrite the original**: `prs.save("work/presentations/FILE.pptx")`
4. Commit after each meaningful edit: `git add -f work/presentations/FILE.pptx && git commit -m "description"`

### Helper Scripts
- **`setup/pptx/pptx_helpers.py`** — importable functions:
  - `open_presentation(path)` / `save_presentation(prs, path)`
  - `insert_equation_image(slide, png_path, left, top, max_width, max_height)`
  - `replace_text_in_slide(slide, old_text, new_text)`
  - `list_slide_texts(prs)` — summary of all text on all slides
- **`setup/pptx/render_equation.py`** — render LaTeX to PNG:
  - CLI: `python3 setup/pptx/render_equation.py "E = mc^2" /tmp/eqn.png --dpi 300`
  - Library: `from setup.pptx.render_equation import render_equation`

### Rendering Equations in LaTeX
When the user wants an equation in a slide:
1. Render to PNG: `python3 setup/pptx/render_equation.py "LATEX_STRING" /tmp/eqn.png`
2. Remove the old text-based equation from the slide
3. Insert the PNG using `insert_equation_image()` from `setup/pptx/pptx_helpers.py`
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

## LaTeX Workflow

- Build PDF: `make -C setup pdf`
- Watch mode: `make -C setup watch`
- Clean: `make -C setup clean`

## Git Workflow

- `work/` is gitignored by default except for `.gitkeep` scaffolds
- To version-control a presentation: `git add -f work/presentations/FILE.pptx && git commit -m "message"`
- Use descriptive commit messages: "Update slide 3: replace text equation with LaTeX rendering"
- Commit after each logical set of changes, not after every micro-edit

## Constraints

- You are in a container. Do not attempt to install additional system packages.
- Only modify files under the repository root.
- Do not modify files under `.devcontainer/` or `setup/` unless explicitly asked.
- Temporary files (equation renders) should go in `/tmp/` and are cleaned up automatically.
