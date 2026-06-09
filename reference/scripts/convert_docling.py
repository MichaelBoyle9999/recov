#!/usr/bin/env python
"""Convert a PDF to markdown with Docling, formula enrichment ON.

Usage:
    python convert_docling.py <pdf> [--out <md>]

Writes <md> (default "<pdf-dir>/docling.md"). Equations are emitted as LaTeX
(formula enrichment), NOT base64 images. Figure images are left as placeholders
so the markdown stays small and text-diffable. Run in .docling_venv.
"""
import argparse
from pathlib import Path

from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import PdfPipelineOptions
from docling.document_converter import DocumentConverter, PdfFormatOption
from docling_core.types.doc import ImageRefMode


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf", type=Path)
    ap.add_argument("--out", type=Path, default=None)
    args = ap.parse_args()
    out = args.out or args.pdf.parent / "docling.md"

    opts = PdfPipelineOptions()
    opts.do_formula_enrichment = True  # equations -> LaTeX instead of base64 images
    opts.do_table_structure = True
    opts.generate_picture_images = False

    conv = DocumentConverter(
        format_options={InputFormat.PDF: PdfFormatOption(pipeline_options=opts)}
    )
    result = conv.convert(str(args.pdf))
    md = result.document.export_to_markdown(image_mode=ImageRefMode.PLACEHOLDER)
    out.write_text(md, encoding="utf-8")
    print(f"wrote {out} ({len(md)} chars)")


if __name__ == "__main__":
    main()
