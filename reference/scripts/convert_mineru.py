#!/usr/bin/env python
"""Convert a PDF to markdown with MinerU (pipeline backend).

Usage:
    python convert_mineru.py <pdf> [--out <md>]

Runs `mineru -b pipeline` into a temp dir, then surfaces a single
"<pdf-dir>/mineru.md" with its extracted figures in "<pdf-dir>/mineru_images/"
(image links rewritten accordingly). Run via the .mineru_venv interpreter so the
`mineru` console script is on PATH:

    .\\.mineru_venv\\Scripts\\python.exe reference\\scripts\\convert_mineru.py <pdf>
"""
import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf", type=Path)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--lang", default="en")
    args = ap.parse_args()

    pdf = args.pdf.resolve()
    out_md = (args.out or pdf.parent / "mineru.md").resolve()
    img_dir = out_md.parent / "mineru_images"

    mineru = Path(sys.executable).parent / "mineru.exe"
    mineru = mineru if mineru.exists() else Path("mineru")

    with tempfile.TemporaryDirectory() as tmp:
        # MinerU bakes the input file stem into a deep internal temp path
        # (mineru-api-client-*/output/<uuid>/<stem>/auto/<stem>_content_list_v2.json).
        # With long paper folder names that path exceeds Windows MAX_PATH (260) and the
        # output stage dies with FileNotFoundError. Run on a short-stem copy to keep the
        # internal path short; outputs are surfaced to out_md regardless of stem.
        stem = "p"
        work_pdf = Path(tmp) / f"{stem}.pdf"
        shutil.copyfile(pdf, work_pdf)
        subprocess.run(
            [str(mineru), "-p", str(work_pdf), "-o", tmp,
             "-b", "pipeline", "-m", "auto", "-l", args.lang,
             "-f", "true", "-t", "true"],
            check=True,
        )
        produced = next(Path(tmp).rglob(f"{stem}.md"))
        md = produced.read_text(encoding="utf-8")

        src_imgs = produced.parent / "images"
        if src_imgs.is_dir():
            if img_dir.exists():
                shutil.rmtree(img_dir)
            shutil.copytree(src_imgs, img_dir)
            md = md.replace("images/", "mineru_images/")

        out_md.write_text(md, encoding="utf-8")
    print(f"wrote {out_md} ({len(md)} chars)")


if __name__ == "__main__":
    main()
