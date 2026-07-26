#!/usr/bin/env python3
"""Render a 1920x1080 text slide with Cyrillic support (Pillow)."""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def find_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNS.ttf",
    ]
    for path in candidates:
        p = Path(path)
        if p.is_file():
            try:
                return ImageFont.truetype(str(p), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def gradient_bg(w: int, h: int) -> Image.Image:
    img = Image.new("RGB", (w, h), (11, 18, 32))
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(11 + (26 - 11) * t)
        g = int(18 + (58 - 18) * t)
        b = int(32 + (102 - 32) * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return img


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, max_width: int) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        if not paragraph.strip():
            lines.append("")
            continue
        words = paragraph.split(" ")
        current = ""
        for word in words:
            trial = word if not current else f"{current} {word}"
            if draw.textlength(trial, font=font) <= max_width:
                current = trial
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines


def render(title: str, body: str, out: Path, w: int = 1920, h: int = 1080) -> None:
    img = gradient_bg(w, h)
    draw = ImageDraw.Draw(img, "RGBA")
    margin = 80
    draw.rounded_rectangle(
        (margin, margin, w - margin, h - margin),
        radius=28,
        fill=(255, 255, 255, 16),
        outline=(255, 255, 255, 40),
        width=2,
    )

    title_font = find_font(64)
    body_font = find_font(44)
    x0, y0 = 120, 130
    max_w = w - 240

    draw.text((x0, y0), title, font=title_font, fill=(238, 244, 255, 255))
    y = y0 + 100
    for line in wrap_lines(draw, body, body_font, max_w):
        draw.text((x0, y), line, font=body_font, fill=(200, 214, 234, 255))
        y += 58

    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out, "PNG")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--title", required=True)
    p.add_argument("--body", required=True)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()
    # Allow \n escapes from shell
    body = args.body.replace("\\n", "\n")
    render(args.title, body, args.out)


if __name__ == "__main__":
    main()
