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
        subprocess.run(
            [str(mineru), "-p", str(pdf), "-o", tmp,
             "-b", "pipeline", "-m", "auto", "-l", args.lang,
             "-f", "true", "-t", "true"],
            check=True,
        )
        produced = next(Path(tmp).rglob(f"{pdf.stem}.md"))
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
