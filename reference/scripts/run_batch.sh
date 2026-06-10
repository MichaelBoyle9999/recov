#!/usr/bin/env bash
# One-off batch driver: bring every reference/pdfs/<base>/ folder up to the
# "ready-to-aggregate" state (pages/ + docling.md + mineru.md + olmocr.md).
# Sequential by design (each GPU tool runs as its own pass; no VRAM contention).
# Idempotent: skips a step whose output already exists. Logs every step's
# outcome and continues past failures.
#
# Run from repo root:  bash reference/scripts/run_batch.sh
set -uo pipefail

ROOT="C:/Users/micha/work/recov"
DOCPY="./.docling_venv/Scripts/python.exe"
MINPY="./.mineru_venv/Scripts/python.exe"
LOG="reference/scripts/batch.log"

# Papers already complete (the validated pilot + the smoke-tested corrigendum).
SKIP="Clarke-2013_fitness-fatigue-modeling-tutorial"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

run() {  # run <label> <base> -- <command...>
  local label="$1" base="$2"; shift 3
  local t0 rc
  t0=$SECONDS
  if "$@" >>"$LOG" 2>&1; then
    rc=0; log "OK    $label  $base  ($((SECONDS-t0))s)"
  else
    rc=$?; log "FAIL  $label  $base  (rc=$rc, $((SECONDS-t0))s)"
  fi
  return 0
}

bases=()
for d in reference/pdfs/*/; do
  b=$(basename "$d")
  [ "$b" = "$SKIP" ] && continue
  bases+=("$b")
done

log "=== batch start: ${#bases[@]} papers ==="

# Phase A: page renders (CPU, fast)
log "--- Phase A: render_pages ---"
for b in "${bases[@]}"; do
  d="reference/pdfs/$b"
  [ -d "$d/pages" ] && { log "skip  render    $b (pages/ exists)"; continue; }
  run "render  " "$b" -- "$DOCPY" reference/scripts/render_pages.py "$d/$b.pdf"
done

# Phase B: Docling
log "--- Phase B: docling ---"
for b in "${bases[@]}"; do
  d="reference/pdfs/$b"
  [ -f "$d/docling.md" ] && { log "skip  docling   $b (docling.md exists)"; continue; }
  run "docling " "$b" -- "$DOCPY" reference/scripts/convert_docling.py "$d/$b.pdf"
done

# Phase C: MinerU
log "--- Phase C: mineru ---"
for b in "${bases[@]}"; do
  d="reference/pdfs/$b"
  [ -f "$d/mineru.md" ] && { log "skip  mineru    $b (mineru.md exists)"; continue; }
  run "mineru  " "$b" -- "$MINPY" reference/scripts/convert_mineru.py "$d/$b.pdf"
done

# Phase D: olmOCR (WSL2)
log "--- Phase D: olmocr (WSL) ---"
wscript="/mnt/c/Users/micha/work/recov/reference/scripts/run_olmocr_wsl.sh"
wsl -d Ubuntu-24.04 -u root bash -lc "sed -i 's/\r\$//' '$wscript'" >>"$LOG" 2>&1
for b in "${bases[@]}"; do
  d="reference/pdfs/$b"
  [ -f "$d/olmocr.md" ] && { log "skip  olmocr    $b (olmocr.md exists)"; continue; }
  wpdf="/mnt/c/Users/micha/work/recov/reference/pdfs/$b/$b.pdf"
  run "olmocr  " "$b" -- wsl -d Ubuntu-24.04 -u root bash -lc "bash '$wscript' '$wpdf'"
done

log "=== batch complete ==="
