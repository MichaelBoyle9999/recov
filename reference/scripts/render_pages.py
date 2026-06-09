#!/usr/bin/env python
"""Render every page of a PDF to PNG (ground-truth images for the aggregator).

Usage:
    python render_pages.py <pdf> [--out <dir>] [--dpi 200]

Writes <dir>/page-001.png, page-002.png, ...  Defaults <dir> to "<pdf-dir>/pages".
Runs in the .docling_venv (pypdfium2 is installed there) or any venv with pypdfium2.
"""
import argparse
from pathlib import Path

import pypdfium2 as pdfium


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf", type=Path)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--dpi", type=int, default=200)
    args = ap.parse_args()

    out = args.out or args.pdf.parent / "pages"
    out.mkdir(parents=True, exist_ok=True)

    doc = pdfium.PdfDocument(str(args.pdf))
    n = len(doc)
    for i in range(n):
        img = doc[i].render(scale=args.dpi / 72).to_pil()
        img.save(out / f"page-{i + 1:03d}.png")
    print(f"rendered {n} pages -> {out}")


if __name__ == "__main__":
    main()
