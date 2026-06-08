# Spike: Docling vs Marker on Clarke-2013, for the AMD / RTX 3090Ti box.
# Goal: produce two first-pass markdown drafts to diff against the known Clarke corrections.
# Run from the repo root (where reference/ lives). Requires Python 3.10-3.12 + NVIDIA driver.

$ErrorActionPreference = "Stop"
$pdf = "reference\pdfs\Clarke-2013_fitness-fatigue-modeling-tutorial.pdf"
$out = "spike_out"
New-Item -ItemType Directory -Force -Path $out | Out-Null

# --- isolated venv so we don't pollute anything ---
python -m venv .spike_venv
.\.spike_venv\Scripts\Activate.ps1
python -m pip install --upgrade pip

# --- CUDA PyTorch FIRST (so downstream tools don't pull the CPU build) ---
# cu124 wheels suit a 3090Ti; adjust if your CUDA differs.
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124

# --- Tool 1: Docling (IBM) ---
pip install docling
docling $pdf --to md --output $out\docling
# (Docling enables formula + table structure models by default.)

# --- Tool 2: Marker (DataLab) ---
pip install marker-pdf
# --force_ocr off by default; --output_format markdown; use the LLM-off baseline first.
marker_single $pdf --output_dir $out\marker --output_format markdown

Write-Host "`nDONE. Drafts in:" -ForegroundColor Green
Write-Host "  $out\docling   (Docling)"
Write-Host "  $out\marker    (Marker)"
Write-Host "`nVerify GPU was used:" -ForegroundColor Yellow
python -c "import torch; print('CUDA available:', torch.cuda.is_available(), '|', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU only')"
