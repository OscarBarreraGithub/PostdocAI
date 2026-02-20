#!/usr/bin/env python3
"""Helper functions for PowerPoint manipulation.

Intended to be imported by Claude Code when editing presentations.
"""
import os

from PIL import Image
from pptx import Presentation
from pptx.util import Inches


def open_presentation(path: str) -> Presentation:
    """Open an existing .pptx file."""
    return Presentation(path)


def save_presentation(prs: Presentation, path: str) -> None:
    """Save presentation, overwriting the original."""
    prs.save(path)


def insert_equation_image(
    slide,
    png_path: str,
    left: float = 1.0,
    top: float = 1.0,
    max_width: float = 8.0,
    max_height: float = 3.0,
):
    """Insert an equation PNG onto a slide, preserving aspect ratio.

    Args:
        slide: A python-pptx slide object.
        png_path: Path to the equation PNG image.
        left: Left position in inches.
        top: Top position in inches.
        max_width: Maximum width in inches.
        max_height: Maximum height in inches.
    """
    img = Image.open(png_path)
    img_width_px, img_height_px = img.size
    aspect = img_width_px / img_height_px

    width_in = min(max_width, max_height * aspect)
    height_in = width_in / aspect

    slide.shapes.add_picture(
        png_path,
        Inches(left),
        Inches(top),
        Inches(width_in),
        Inches(height_in),
    )


def replace_text_in_slide(slide, old_text: str, new_text: str) -> int:
    """Replace all occurrences of old_text with new_text in a slide.

    Returns the number of replacements made.
    """
    count = 0
    for shape in slide.shapes:
        if shape.has_text_frame:
            for paragraph in shape.text_frame.paragraphs:
                for run in paragraph.runs:
                    if old_text in run.text:
                        run.text = run.text.replace(old_text, new_text)
                        count += 1
    return count


def list_slide_texts(prs: Presentation) -> list[dict]:
    """Return a summary of all text content per slide.

    Returns:
        List of dicts: [{"slide": 1, "texts": ["Title", "Body..."]}, ...]
    """
    result = []
    for i, slide in enumerate(prs.slides, start=1):
        texts = []
        for shape in slide.shapes:
            if shape.has_text_frame:
                texts.append(shape.text_frame.text)
        result.append({"slide": i, "texts": texts})
    return result
