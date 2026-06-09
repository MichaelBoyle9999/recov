# Reference PDF → Markdown Conversion Workflow

Working notes for converting the academic PDFs in `reference/pdfs/` into clean,
LLM-readable markdown. **This document will evolve.** See the changelog at the bottom.

## Goal

One hand-reviewed **folder** per paper — `reference/<base>/` holding `<base>.md` plus
its figure images in `reference/<base>/images/` — coherent and faithful enough that an
LLM (or human) can rely on it without consulting the original PDF.

We get there with a **multi-tool ensemble**: run several independent converters on
each PDF, keep all of their outputs side by side, then have a vision-capable LLM
**aggregate** the drafts (cross-checking against the rendered page images) into the
final document. No single tool is trusted; disagreements between tools are the signal
that tells the human/LLM reviewer exactly where to look.

## Guiding principle: transcribe, don't correct

- **Transcribe exactly as printed.** Do not normalize, simplify, re-derive, or "fix"
  equations, tables, or text into mathematically-equivalent-but-different forms (e.g.,
  do not turn a printed `P = W'·Tlim⁻¹ + CP` into a `W'/Tlim` fraction).
- **Preserve source inconsistencies as-is.** If a figure and an appendix state the
  "same" equation with different index/notation, transcribe each where it appears. Do
  **not** reconcile them and do **not** run an equation cross-referencing pass.
- **Don't invent.** If something is unreadable, mark it rather than guessing.
- Publisher errata/corrigenda *are* applied (they are the authoritative corrected
  record) and noted in frontmatter `conversion_notes`.

## Why these tools (approach diversity)

Each tool represents a genuinely different conversion approach, so their failure modes
are uncorrelated. Picking diverse approaches is the whole point — it lets the
aggregator triangulate.

| Tool | Approach | Strengths | Cost |
|------|----------|-----------|------|
| **olmOCR** (`olmOCR-2-7B`) | Specialist end-to-end VLM | Best OCR text fidelity; cleanest equations incl. figure-embedded math | **WSL2/Linux only** (no Windows vLLM wheel); ~90 s/paper on the 3090 Ti |
| **MinerU** (pipeline backend) | Modular pipeline: layout-detect → OCR → dedicated formula model | Fast; native Windows; good tables + LaTeX | minor OCR garbles |
| **Docling** (formula enrichment ON) | IBM layout-model converter | Strong table structure; different lineage = different errors | must enable formula enrichment or it dumps equations as base64 images |
| **Mathpix** (run manually by the owner) | Commercial math specialist | Best-in-class math OCR; different training data | external/paid; not scripted here |

A separate *generalist* VLM pass is intentionally **omitted**: the aggregating LLM is
itself vision-capable, so it supplies the generalist perspective on demand by reading
the page images (`pages/`) exactly where the four drafts disagree.

Dropped after the tool spike: **Marker** (lost Fig 1's table; erased a real figure/
appendix inconsistency) and **Nougat** (broken against modern `transformers`).

## Folder layout: sources/drafts vs. final output

**Working area** — each paper's source PDF + tool drafts live under `reference/pdfs/`:

```
reference/pdfs/<base>/
  <base>.pdf            # the source PDF
  pages/                # page-001.png, page-002.png, ...  (ground-truth images)
  olmocr.md             # olmOCR draft        (WSL2)
  mineru.md             # MinerU draft        + mineru_images/
  mineru_images/        # figures extracted by MinerU (the crop source for figures)
  docling.md            # Docling draft       (formula enrichment on)
  mathpix.md            # Mathpix draft       (added manually by the owner)
```

**Final deliverable** — the aggregation step writes a *folder* per paper at the top
level of `reference/` (markdown + the figure images it links):

```
reference/<base>/
  <base>.md             # the final hand-reviewed document
  images/               # figure crops linked inline by <base>.md (figure-1.jpg, ...)
```

Figure crops in `images/` are copied from the working `mineru_images/` and renamed to
meaningful names during aggregation. Only genuine figures/graphs become images;
equations and tables are transcribed as text (LaTeX / markdown), never carried as
images. (Non-paper reference data — datasets, landmark CSVs, reading lists — stays as
loose files in `reference/`; only paper conversions become folders.)

## Environment (this machine)

- **Windows 11 on AMD** with an **NVIDIA RTX 3090 Ti** (24 GB VRAM). GPU/PyTorch
  tools are practical here. (The old ARM64 / no-GPU constraints no longer apply.)
- **Windows venvs** (git-ignored, in repo root):
  - `.docling_venv` — Docling + `pypdfium2` (page rendering). Needs `transformers<5`.
  - `.mineru_venv` — MinerU (pipeline backend).
  - CUDA PyTorch must come from the cu128 wheel index (`torch==2.11.0+cu128`); ordinary
    ML pip installs pull CPU torch and must be re-pinned. Verify with
    `python -c "import torch; print(torch.cuda.is_available())"`.
- **olmOCR runs in WSL2** (Ubuntu-24.04) with GPU passthrough — vLLM has no Windows
  wheel. Venv at `~/olmocr_spike/venv` (WSL root home). Pins that matter:
  `vllm==0.11.2` (olmOCR's `gpu` extra; plain `vllm` resolves too new) and
  `flashinfer-cubin==0.5.2` to match `flashinfer-python==0.5.2`.

## Per-paper steps

Reusable scripts live in `reference/scripts/`. Run each from the repo root. Replace
`<base>` with the paper's folder name.

```powershell
$base = '<base>'
$pdf  = "reference\pdfs\$base\$base.pdf"

# 1. Render page images (ground truth for the aggregator) -> pages/
.\.docling_venv\Scripts\python.exe reference\scripts\render_pages.py $pdf

# 2. Docling draft (formula enrichment ON) -> docling.md
.\.docling_venv\Scripts\python.exe reference\scripts\convert_docling.py $pdf

# 3. MinerU draft (pipeline backend) -> mineru.md + mineru_images/
.\.mineru_venv\Scripts\python.exe reference\scripts\convert_mineru.py $pdf
```

```powershell
# 4. olmOCR draft -> olmocr.md  (runs in WSL2)
$wslpdf = "/mnt/c/Users/micha/work/recov/reference/pdfs/$base/$base.pdf"
$script = '/mnt/c/Users/micha/work/recov/reference/scripts/run_olmocr_wsl.sh'
wsl -d Ubuntu-24.04 -u root bash -lc "sed -i 's/\r`$//' '$script'; bash '$script' '$wslpdf'"
```

```text
# 5. Mathpix draft -> mathpix.md   (done manually by the owner; drop the file in the folder)
```

After steps 1–5, the paper folder holds four tool drafts + page images, ready to
aggregate.

## Aggregation step (drafts → final document)

Hand a **vision-capable LLM** all of the following for one paper:

- the four tool drafts (`olmocr.md`, `mineru.md`, `docling.md`, `mathpix.md`),
- the rendered page images (`pages/`), and
- the MinerU figure crops (`mineru_images/`).

Instruct it to produce the final **folder** `reference/<base>/` containing `<base>.md`
plus an `images/` subfolder, by reconciling the drafts under the *transcribe, don't
correct* principle:

- Where the drafts **agree**, accept the shared text.
- Where they **disagree**, treat the page image as ground truth and transcribe what is
  printed — do not pick the "nicer" or "more consistent" form, and do not reconcile
  genuine source inconsistencies.
- Preserve all table columns (including reference/term-description columns), full
  equation forms (un-truncated, printed form, not re-derived fractions), and figure
  boundaries.
- **Figures/graphs:** identify the MinerU crop in `mineru_images/` for each figure
  (use olmOCR's description + the page render to match it), copy it into
  `reference/<base>/images/` with a meaningful name (`figure-1.jpg`, …), and link it
  inline at the point the figure is referenced, with an aggregator-written caption /
  description beneath. Equations and tables are transcribed as text even when MinerU
  cropped them as images — only genuine plots/figures stay as image links.

### Aggregation prompt (working draft — being dialed in on Clarke-2013)

> **Status:** draft under iteration. The exact wording is still being validated against
> the Clarke-2013 rubric (`Clarke-2013_validation-target.md`); update this block once the
> first official conversion passes. Replace `<BASE>` with the paper's folder name.

```text
You are converting ONE academic paper into its final, canonical Markdown file by
aggregating four independent machine conversions and verifying them against ground-truth
page images. Your current working directory is the repository root.

PAPER (base name): <BASE>
Working folder: reference\pdfs\<BASE>\

INPUTS (all inside the working folder above):
- olmocr.md, mineru.md, docling.md, mathpix.md — four independent tool drafts of the
  SAME paper. None is authoritative; each has different strengths and failure modes.
- pages\page-001.png ... — full-page renders at 200 DPI. THESE ARE GROUND TRUTH. When
  drafts disagree, open the relevant page image and transcribe what is actually printed.
  (Use your file viewer tool on the .png — it can read images.)
- mineru_images\*.jpg — MinerU's cropped figure images (source for the figure images in
  your output).
- <BASE>.pdf — the source PDF (reference only).

OUTPUT (create these):
- reference\<BASE>\<BASE>.md  — the final document.
- reference\<BASE>\images\    — figure images you copy in (figure-1.jpg, figure-2.jpg, ...).

GOVERNING PRINCIPLE — TRANSCRIBE, DON'T CORRECT:
Transcribe exactly as printed. Never normalize, simplify, re-derive, or "fix" equations,
tables, or text into mathematically-equivalent-but-different forms. Never invent content.
If the paper is internally inconsistent (e.g., a figure and an appendix write the "same"
equation with different notation/indices/summation bounds), TRANSCRIBE EACH LOCATION AS
PRINTED and do NOT reconcile them to match. If something is genuinely unreadable even in
the page image, mark it `[illegible — verify against PDF]` rather than guessing.

HOW TO AGGREGATE:
1. Read all four drafts to understand structure and content.
2. Where the drafts AGREE, accept the shared text.
3. Where they DISAGREE — or wherever any equation, table, figure caption, sub/superscript,
   or in-figure reference attribution is involved — OPEN THE PAGE IMAGE (view
   pages\page-NNN.png) and transcribe verbatim from the image. The image wins over every
   draft, always.
4. Equations: render as LaTeX (`$$...$$` display, `$...$` inline). Transcribe the printed
   form exactly — un-truncated; correct multiplication vs division (do NOT turn a printed
   `A·B⁻¹ + C` into an `A/B` fraction); correct indices and summation bounds. Keep every
   equation's printed reference citation(s); if a cell stacks two citations, keep BOTH.
5. Tables — INCLUDING tables embedded inside figures: reconstruct as Markdown tables (use
   HTML <table> only if needed for row/col spans). Include EVERY column and every row,
   including any "References" and "Term descriptions"/notes columns. Verify column count
   and cell contents against the page image. Do not let a cell from one column bleed into
   another.
6. References: full numbered list. Preserve the original numbering exactly, including
   quirks (e.g., a skipped number) — add a brief HTML comment note if numbering skips.
7. Strip running heads, page numbers, footers, and journal boilerplate. Preserve reading
   order; do not reorder sections or figures.

FIGURES (image + caption):
For each figure ("Fig. 1", "Fig. 2", ...) in the paper:
a. Find its cropped image: in mineru.md, locate the `![](mineru_images/<hash>.jpg)`
   reference next to that figure's caption; that hash file is the candidate crop. VIEW the
   candidate .jpg to confirm it visually matches the figure's panels.
b. Copy that file to reference\<BASE>\images\figure-N.jpg (N = printed figure number).
c. If MinerU has no clean crop for a figure, instead copy that figure's full page render
   (pages\page-NNN.png) to images\figure-N.png and note the fallback in conversion_notes.
d. In the body, at the point the figure is first referenced/placed (do not reorder),
   insert exactly:

   ![Figure N](images/figure-N.jpg)
   > **[Figure N]** <full caption, transcribed verbatim from the page image>

   The blockquote marks the figure boundary so figure content is never mistaken for body
   prose.
e. If a figure EMBEDS a table or equations (common for definition/summary figures), ALSO
   transcribe that embedded table/equations as text (Markdown table / LaTeX) immediately
   under the caption — the image preserves the visual/plotted content; the text preserves
   the data.

FRONTMATTER (YAML at the very top of the .md):
---
title: "<full title>"
authors: "<authors as printed>"
year: <year>
journal: "<journal>"
citation: "<full citation>"
doi: "<doi if available, else omit the line>"
themes: ["<2-5 topical tags>"]
source_pdf: "pdfs/<BASE>/<BASE>.pdf"
conversion: "ensemble (olmOCR + MinerU + Docling + Mathpix) aggregated against page images"
conversion_notes: "<note any fallbacks, illegible spots, numbering quirks, or preserved inconsistencies>"
---
Verify title, authors, year, journal, and DOI against page 1 (pages\page-001.png).

SELF-VERIFY before finishing:
- Re-open the page images for every page containing an equation, table, or figure, and
  confirm your transcription matches the print.
- Confirm you did NOT reconcile any internal inconsistency.
- Confirm every figure has an image file in images\ plus an inline link + caption.
- Confirm tables include all columns with no cross-column bleed.

WHEN DONE, report back:
- The output file path and the image files you created.
- A short list of the notable disagreements between drafts and how the page image
  resolved each.
- Any spots flagged illegible or any fallbacks used.

Use whatever tools you need (file viewer for images, shell copy to rename crops, etc.).
Take the time to actually open the page images — that is the whole point of this step.
Produce the final file; do not ask for confirmation.
```

## Output format / template

YAML frontmatter + markdown body:

```yaml
---
title: "..."
authors: "..."
year: 0000
journal: "..."
citation: "..."
doi: "..."
themes: ["..."]
source_pdf: "pdfs/<base>/<base>.pdf"
conversion: "ensemble (olmOCR + MinerU + Docling + Mathpix) aggregated against page images"
conversion_notes: "errata applied; anything flagged 'verify against PDF'; tool disagreements resolved from images; etc."
---
```

Body conventions:

- Equations as LaTeX `$$...$$`, transcribed verbatim from the printed page.
- Figures: inline at the point they're referenced (don't reorder). Carry the figure's
  cropped image as an inline link to `images/figure-N.jpg`, immediately followed by an
  explicit, clearly-delimited caption/description so figure content is never mistaken
  for body prose, e.g.:

  ```markdown
  ![Figure 1](images/figure-1.jpg)
  > **[Figure 1]** <printed caption, transcribed verbatim>
  ```

  **Mark the figure boundary explicitly.**
- Tables inside figures stay tables (all columns, including reference/term-description
  columns).
- Full numbered reference lists; preserve original numbering quirks (e.g.,
  Clarke-2013's list skips #76) with a short note.
- Strip running heads, page numbers, and journal boilerplate.

## Open questions / to revisit

- Whether to commit the per-paper `pages/` PNGs and tool `mineru_images/` to the repo
  long-term (retrieval value vs. repo size), or keep them local and git-ignored.
- Whether the aggregation step should itself be scripted (batch prompt per paper) once
  the manual flow is proven on a few papers.
- Errata policy (currently: apply publisher corrigenda).

## Changelog

- 2026-06-08: Reworked into the **multi-tool ensemble** flow on the new Windows-AMD /
  RTX 3090 Ti box. Per-paper folders under `reference/pdfs/<base>/` now hold
  olmOCR + MinerU + Docling (+ manual Mathpix) drafts plus rendered page images, which
  a vision LLM aggregates into the final document. Added reusable `reference/scripts/`
  (`render_pages.py`, `convert_docling.py`, `convert_mineru.py`, `run_olmocr_wsl.sh`).
  Replaces the earlier `pdftotext` + manual visual-transcription pilot (the "before"
  picture). Retired Marker and Nougat after the tool spike.
- 2026-06-08: Initial version. Added the render→visual-verify pass after the
  Clarke-2013 pilot review surfaced layout-destruction transcription errors. Dropped
  the proposed equation cross-referencing / consistency-reconciliation step per user
  direction ("transcribe, not correct; let papers be inconsistent").
