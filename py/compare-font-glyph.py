#!/usr/bin/env -S uv run --with Pillow python3
"""Compare how a Unicode glyph renders across installed Nerd Fonts.

Renders the glyph at 80pt in each installed Nerd Font Mono variant
side by side in a single image, so you can pick the best one for
font-codepoint-map in Ghostty (or any terminal).

Requires: uv, Pillow (auto-installed via uv)
"""
import argparse
import os
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compare how a glyph renders across installed Nerd Fonts.",
        epilog="""examples:
  compare-font-glyph                    # compare ❯ (default)
  compare-font-glyph "★"               # compare a star
  compare-font-glyph "❯" -o /tmp/c.png # custom output path
  compare-font-glyph $'\\ue0b0'         # powerline arrow (bash)
  compare-font-glyph $'\\U0001F600'     # emoji
  compare-font-glyph --size 120 "❯"    # larger rendering""",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "glyph", nargs="?", default="\u276F",
        help="character to compare (default: ❯ U+276F)",
    )
    parser.add_argument(
        "-o", "--output",
        default=os.path.expanduser("~/Desktop/glyph-comparison.png"),
        help="output image path (default: ~/Desktop/glyph-comparison.png)",
    )
    parser.add_argument(
        "-s", "--size", type=int, default=80,
        help="font size for rendering (default: 80)",
    )
    parser.add_argument(
        "--no-open", action="store_true",
        help="don't open the image after saving",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    fonts_dir = os.path.expanduser("~/Library/Fonts")
    if not os.path.isdir(fonts_dir):
        print(f"Font directory not found: {fonts_dir}", file=sys.stderr)
        sys.exit(1)

    font_files = sorted([
        f for f in os.listdir(fonts_dir)
        if "NerdFont" in f and "Mono" in f and "Regular" in f and f.endswith(".ttf")
    ])

    if not font_files:
        print("No Nerd Font Mono files found in ~/Library/Fonts", file=sys.stderr)
        sys.exit(1)

    row_height = args.size + 40
    label_width = 450
    glyph_width = args.size * 2
    img_width = label_width + glyph_width
    bg_color = (30, 30, 46)
    text_color = (205, 214, 244)
    glyph_color = (166, 227, 161)

    img_height = row_height * len(font_files) + 20
    img = Image.new("RGB", (img_width, img_height), bg_color)
    draw = ImageDraw.Draw(img)
    label_font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 24)

    codepoint = f"U+{ord(args.glyph):04X}" if len(args.glyph) == 1 else ""
    title = f"Glyph: {args.glyph}  {codepoint}" if codepoint else f"Glyph: {args.glyph}"
    print(f"{title}  |  {len(font_files)} fonts")

    for i, filename in enumerate(font_files):
        path = os.path.join(fonts_dir, filename)
        name = (
            filename
            .replace("NerdFontMono-Regular.ttf", " NF Mono")
            .replace("NerdFont", " NF ")
        )
        y = i * row_height + 10
        draw.text((20, y + row_height // 2 - 12), name, fill=text_color, font=label_font)
        try:
            glyph_font = ImageFont.truetype(path, args.size)
            draw.text((label_width + 20, y + 5), args.glyph, fill=glyph_color, font=glyph_font)
        except Exception as e:
            draw.text(
                (label_width + 20, y + row_height // 2 - 12),
                f"err: {e}", fill=(255, 100, 100), font=label_font,
            )

    img.save(args.output)
    print(f"Saved to {args.output}")

    if not args.no_open:
        subprocess.run(["open", args.output])


if __name__ == "__main__":
    main()
