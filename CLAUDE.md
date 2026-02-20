# PocketPostdoc — Claude Code Instructions

## Environment

You are running inside a sandboxed Ubuntu 24.04 dev container.
Available tools: python3, python-pptx, Pillow, pdflatex, latexmk, ghostscript, make, git.

## Examples

This repo includes example workflows in `examples/`. Each has its own `CLAUDE.md`:

### 1. PowerPoint Editor (`examples/pptx-editor/`)
Edit `.pptx` presentations with LaTeX equation rendering.
- User files go in `work/presentations/`
- See `examples/pptx-editor/CLAUDE.md` for the full workflow and style preferences

### 2. LaTeX Double-Checker (`examples/latex-assistant/`)
Review physics/math papers for errors — only flags mistakes it is certain about.
- User files go in `work/papers/`
- Say **"run the double checker"** to analyze all `.tex` files in `work/papers/`
- See `examples/latex-assistant/CLAUDE.md` for the protocol

## LaTeX Build

- Build PDF: `make -C setup pdf`
- Watch mode: `make -C setup watch`
- Clean: `make -C setup clean`

## Git Workflow

- `work/` is gitignored by default except for `.gitkeep` scaffolds
- To version-control a file: `git add -f work/path/to/FILE && git commit -m "message"`
- Use descriptive commit messages
- Commit after each logical set of changes, not after every micro-edit

## Constraints

- You are in a container. Do not attempt to install additional system packages.
- Only modify files under the repository root.
- Do not modify files under `.devcontainer/` or `setup/` unless explicitly asked.
- Temporary files should go in `/tmp/`.
