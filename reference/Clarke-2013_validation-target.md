# Clarke-2013 conversion — validation target (the "before/after" diff)

This file records the **ground-truth corrections** a human reviewer found in the
first-pass conversion of `Clarke-2013_fitness-fatigue-modeling-tutorial.md`.

Purpose: when we re-convert Clarke-2013 with an improved workflow (or evaluate a
tool's first-pass draft such as Docling/Marker), we diff the new output against
this list. A workflow "passes" if it catches these without reintroducing them.

These errors all share one root cause: `pdftotext` linearizes multi-column
figure/table layouts into an unreadable vertical jumble, and the equations were
then reconstructed from that mangled text plus domain knowledge instead of from
the actual printed page. The fix is a **visual verification pass** (render the
page, transcribe from the image verbatim).

Governing principle (see `CONVERSION_WORKFLOW.md`): **transcribe exactly as
printed — do not normalize, simplify, or correct, and preserve source
inconsistencies as-is.**

---

## Figure 1 (Clarke-2013, journal p.4) — a 3-column table that was mishandled

The figure is a table with **three columns**: `Equation | References | Term descriptions`.
The first-pass conversion collapsed it. Specific errors:

1. **Equation 1 was truncated and contaminated.**
   - Printed: `W_lim = W' + CP · T_lim`
   - First pass wrote: `W_lim = W' + CP · T_lim = P · T_lim` — the trailing
     `= P · T_lim` was actually a cell from the **Term descriptions** column that
     got appended onto the equation.

2. **A second reference was dropped.**
   - Equation 1 is cited to **BOTH** Monod & Scherrer (1965) **AND** Moritani et
     al. (1981) (two citations stacked in the same References cell).
   - First pass kept only Monod & Scherrer.

3. **An equation was turned into a fraction it isn't.**
   - Printed: `P = W' · T_lim + CP`  (note: `W'` multiplied by `T_lim`)
   - First pass wrote: `P = W'/T_lim + CP` — invented a fraction.

4. **The entire "Term descriptions" column was lost.**
   - e.g. the descriptor for row 1 reads roughly:
     `W_lim = Total work performed during the trial; W_lim = P · T_lim`.
   - None of this column survived the first pass.

## Figure 6A (Clarke-2013, journal p.8) — internal inconsistency to PRESERVE

- Figure 6A **literally prints**: `Σ_{s=0}^{t-1} e^{-(t-s)/τ} w(s)` (uses `s=0`, `w(s)`).
- Appendix A of the **same paper** prints the same model with `Σ_{i=1}^{t-1} … w(i)`
  (uses `i=1`, `w(i)`).
- The paper is **internally inconsistent**. Per the governing principle, transcribe
  **each location as printed** — do NOT reconcile them to match each other.
- (The first pass's Fig 6A text matched the figure; the reviewer's `i=1` note came
  from Appendix A. Both are "correct" to their own location.)

## Confirmed-good (no change needed)

- **Table 4B** was transcribed accurately in the first pass — use as a positive control.

---

## How to use this file

After producing a new Clarke draft:
1. Render journal p.4 (Fig 1) and p.8 (Fig 6) to PNG (e.g. `pypdfium2`) and view them.
2. Check each of the items above against the new draft.
3. A good workflow/tool draft should reproduce Fig 1's three columns, both
   references on Eq 1, the un-truncated Eq 1, the non-fraction `P = W'·T_lim + CP`,
   and leave the Fig 6A / Appendix A inconsistency intact.

PDF page mapping: in the original first-pass spike, **Fig 1 was rendered from PDF
page 4 and Fig 6 from PDF page 8** of `Clarke-2013_fitness-fatigue-modeling-tutorial.pdf`.
Confirm the exact pages when re-rendering (the journal's printed page numbers are
offset from the PDF page index).
