#!/usr/bin/env bash
# Convert a PDF to markdown with olmOCR (runs inside WSL2 / Linux only).
#
# Usage (from WSL):   bash run_olmocr_wsl.sh /mnt/c/.../<base>/<base>.pdf
# Usage (from PowerShell):
#   wsl -d Ubuntu-24.04 -u root bash /mnt/c/Users/micha/work/recov/reference/scripts/run_olmocr_wsl.sh \
#       /mnt/c/Users/micha/work/recov/reference/pdfs/<base>/<base>.pdf
#
# Writes "<pdf-dir>/olmocr.md". olmOCR has no Windows wheel (vLLM); it must run in
# WSL2 with GPU passthrough. Env overrides: OLMOCR_VENV, OLMOCR_WS.
set -euo pipefail

PDF="${1:?usage: run_olmocr_wsl.sh <absolute-wsl-path-to-pdf>}"
VENV="${OLMOCR_VENV:-/root/olmocr_spike/venv}"
WS="${OLMOCR_WS:-/root/olmocr_spike/localworkspace}"

test -f "$PDF" || { echo "PDF MISSING: $PDF"; exit 1; }

# shellcheck disable=SC1091
source "$VENV/bin/activate"
export FLASHINFER_DISABLE_VERSION_CHECK=1

python -m olmocr.pipeline "$WS" --markdown --pdfs "$PDF"

# olmOCR writes markdown to $WS/markdown/<pdf-path-without-leading-slash>.md
rel="${PDF#/}"
rel="${rel%.pdf}.md"
src="$WS/markdown/$rel"
dst="$(dirname "$PDF")/olmocr.md"

cp "$src" "$dst"
echo "WROTE $dst"
