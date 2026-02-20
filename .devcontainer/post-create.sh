#!/usr/bin/env bash
set -euo pipefail

echo "Verifying LaTeX tools in container..."
latexmk -v | head -n 1
pdflatex --version | head -n 1
echo "Container setup complete. Build with: make pdf"
