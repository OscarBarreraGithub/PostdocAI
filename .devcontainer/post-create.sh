#!/usr/bin/env bash
set -euo pipefail

echo "Verifying LaTeX tools in container..."
latexmk -v | head -n 1
pdflatex --version | head -n 1
echo ""
echo "Installing Python dependencies for PPTX editing..."
pip3 install --break-system-packages -r setup/pptx/requirements.txt

echo "Verifying Python tools..."
python3 --version
python3 -c "import pptx; print('python-pptx', pptx.__version__)"
python3 -c "from PIL import Image; print('Pillow OK')"

echo ""
echo "Container setup complete."
echo "  LaTeX:  make -C setup pdf"
echo "  PPTX:   make -C setup demo-pptx"
