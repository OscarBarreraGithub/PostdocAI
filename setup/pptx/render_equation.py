#!/usr/bin/env python3
"""Render a LaTeX equation to a PNG image.

Usage:
    python3 render_equation.py "E = mc^2" output.png [--dpi 300]

Pipeline:
    1. Substitutes equation into setup/pptx/equation_template.tex
    2. Runs pdflatex to produce a tightly-cropped PDF (standalone class)
    3. Runs ghostscript to convert PDF -> transparent PNG at specified DPI
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_PATH = os.path.join(SCRIPT_DIR, "equation_template.tex")


def render_equation(latex_str: str, output_png: str, dpi: int = 300) -> str:
    """Render a LaTeX equation string to a PNG file.

    Args:
        latex_str: LaTeX math content (without $ delimiters).
        output_png: Path to write the output PNG.
        dpi: Resolution for the output image.

    Returns:
        The output_png path on success.
    """
    with open(TEMPLATE_PATH) as f:
        template = f.read()

    tex_content = template.replace("EQUATION_PLACEHOLDER", latex_str)

    tmpdir = tempfile.mkdtemp(prefix="eqn_")
    try:
        tex_path = os.path.join(tmpdir, "equation.tex")
        with open(tex_path, "w") as f:
            f.write(tex_content)

        # pdflatex -> PDF
        result = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode",
             "-output-directory", tmpdir, tex_path],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            print(result.stdout, file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            raise RuntimeError("pdflatex failed — check the LaTeX string")

        pdf_path = os.path.join(tmpdir, "equation.pdf")

        # ghostscript -> transparent PNG
        output_png = os.path.abspath(output_png)
        result = subprocess.run(
            ["gs", "-dNOPAUSE", "-dBATCH", "-sDEVICE=pngalpha",
             f"-r{dpi}", f"-sOutputFile={output_png}", pdf_path],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            print(result.stdout, file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            raise RuntimeError("ghostscript conversion failed")

        return output_png
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render LaTeX equation to PNG")
    parser.add_argument("equation", help="LaTeX equation string (no $ delimiters)")
    parser.add_argument("output", help="Output PNG path")
    parser.add_argument("--dpi", type=int, default=300, help="Image resolution (default: 300)")
    args = parser.parse_args()

    path = render_equation(args.equation, args.output, args.dpi)
    print(f"Rendered: {path}")
