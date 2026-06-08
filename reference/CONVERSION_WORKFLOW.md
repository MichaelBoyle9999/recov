# Reference PDF → Markdown Conversion Workflow

Working notes for converting the academic PDFs in `reference/pdfs/` into clean,
LLM-readable markdown in `reference/`. **This document will evolve.** See the
changelog at the bottom.

## Goal

One hand-reviewed markdown file per paper, same base name as the PDF, placed
directly in `reference/`. Output must be coherent and faithful enough that an LLM
(or human) can rely on it without consulting the original PDF.

## Guiding principle: transcribe, don't correct

- **Transcribe exactly as printed.** Do not normalize, simplify, re-derive, or
  "fix" equations, tables, or text into mathematically-equivalent-but-different
  forms (e.g., do not turn a printed `P = W'·Tlim⁻¹ + CP` into a `W'/Tlim`
  fraction).
- **Preserve source inconsistencies as-is.** If a figure and an appendix state the
  "same" equation with different index/notation, transcribe each where it appears.
  Do **not** reconcile them and do **not** run an equation cross-referencing /
  consistency pass.
- **Don't invent.** If something is unreadable, mark it rather than guessing.
- Publisher errata/corrigenda *are* applied (they are the authoritative corrected
  record), and noted in frontmatter `conversion_notes`. (Open question — revisit.)

## Environment constraints (this machine)

- Windows on **ARM64**. **PyMuPDF will not install** → tools built on it
  (Marker historically, Nougat, etc.) are blocked or painful.
- No assumed GPU → heavy VLM/PyTorch pipelines (olmOCR, MinerU, Nougat) are not
  practical to run locally here.
- `pdftotext` is available but it's the **minimal Git-bundled poppler build**
  (`C:\Program Files\Git\mingw64\bin`) — **no `pdftoppm`**.
- `pypdfium2` (pip, permissive BSD/Apache, ARM64 wheels) renders pages to PNG.
  This is our page-image renderer.

## Tooling

| Purpose | Tool | Notes |
|---------|------|-------|
| Prose text extraction (reading order) | `pdftotext -enc UTF-8 <pdf> <out>` | Accurate & fast for body text. `-enc UTF-8` avoids mojibake. |
| Table view (raw) | `pdftotext -layout` | Helps eyeball tables; mangles 2-column journals. |
| **Page → image (ground truth)** | `pypdfium2`, render at ~200 DPI | Enables the visual verification pass below. |

Render snippet:

```python
import pypdfium2 as pdfium
pdf = pdfium.PdfDocument(r"<path>.pdf")
pdf[i].render(scale=200/72).to_pil().save(rf"<out>_p{i+1}.png")  # i is 0-indexed
```

## Workflow: extract → render → verify

1. **Extract prose.** `pdftotext -enc UTF-8` for the body text (reading order).
   This is the backbone for paragraphs and most prose.
2. **Render pages to PNG** with `pypdfium2`.
3. **Visual verification pass.** For every page that contains an **equation,
   table, or figure**, transcribe that content **from the rendered image**
   (ground truth) — not from the text layer, which destroys 2-D layout. This is
   where multi-column tables, equation forms, sub/superscripts, in-figure
   reference attributions, and figure boundaries get captured correctly.
   - Pure-prose pages don't need the image pass — extraction is reliable there.
4. **Assemble the markdown** using the format template below.
5. **Self-review proof pass.** A second visual sweep comparing each rendered
   equation/table region against the drafted markdown, like a proofreader.
   (Note: this checks each item against the *image*, not against other copies of
   the same equation — no cross-referencing.)

> Why the image pass: `pdftotext` linearizes multi-column tables/figures into an
> unreadable vertical stream. Every transcription error found in the
> Clarke-2013 pilot (truncated equation, dropped second reference, fraction
> instead of printed form, an entire lost "Term descriptions" column) was a
> layout-destruction artifact that reading the rendered page fixes.

## Output format / template

YAML frontmatter + markdown body. Mirror
`Schoenfeld-2017_weekly-volume-hypertrophy-dose-response.md`:

```yaml
---
title: "..."
authors: "..."
year: 0000
journal: "..."
citation: "..."
doi: "..."
themes: ["..."]
source_pdf: "pdfs/<name>.pdf"
conversion: "pdftotext -enc UTF-8 + pypdfium2 page render + visual verification"
conversion_notes: "errata applied; anything flagged 'verify against PDF'; etc."
---
```

Body conventions:
- Equations as LaTeX `$$...$$`, transcribed verbatim from the rendered page.
- Figures: inline at the point they're referenced (don't reorder), introduced by an
  explicit, clearly-delimited placeholder so figure content is never mistaken for
  body prose, e.g. `> **[Figure N]** <caption>`. **Mark the figure boundary
  explicitly** — a past error was figure content flowing in unmarked.
- Tables inside figures stay tables (all columns, including reference/term-
  description columns).
- Full numbered reference lists; preserve original numbering quirks (e.g.,
  Clarke-2013's list skips #76) with a short note.
- Strip running heads, page numbers, and journal boilerplate.

## Open questions / to revisit

- Whether to **retain page PNGs in-repo** (e.g., `reference/figures/<paper>/pNN.png`)
  as retrieval artifacts linked from `[Figure N]` placeholders. Tradeoff: repo size
  vs. recoverability of figure content. (Multimodal retrieval is viable.)
- Whether a tool-assisted **first-pass draft** (see TOOLS research) is worth adding
  before the visual pass, to reduce manual transcription labor.
- Errata policy (currently: apply publisher corrigenda).

## Changelog

- 2026-06-08: Initial version. Added the render→visual-verify pass after the
  Clarke-2013 pilot review surfaced layout-destruction transcription errors.
  Dropped the proposed equation cross-referencing / consistency-reconciliation
  step per user direction ("transcribe, not correct; let papers be inconsistent").
