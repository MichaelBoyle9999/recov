$ErrorActionPreference = 'Continue'
$bases = @(
  'Burd-2010_resistance-exercise-volume-myofibrillar-protein-synthesis',
  'Ceddia-2025_tapering-periodisation-optimisation',
  'Damas-2016_myofibrillar-protein-synthesis-damage-hypertrophy',
  'Herold-2021_isometric-loading-scheme-optimization-model',
  'Imbach-2022_fitness-fatigue-models-machine-learning',
  'Jukic-2023_velocity-loss-thresholds-meta-analysis',
  'Kontro-2025_three-dimensional-impulse-response-model',
  'Pareja-Blanco-2019_recovery-timecourse-loading-velocity-loss',
  'Refalo-2023_proximity-to-failure-hypertrophy-meta-analysis',
  'Refalo-2023_proximity-to-failure-neuromuscular-fatigue',
  'Sousa-2024_recovery-resistance-training-microcycle-construction',
  'Zajac-2015_central-peripheral-fatigue-resistance-exercise-review'
)
foreach ($base in $bases) {
  $pdf = "reference\pdfs\$base\$base.pdf"
  Write-Host "=== [$base] render_pages ==="
  & .\.docling_venv\Scripts\python.exe reference\scripts\render_pages.py $pdf
  Write-Host "=== [$base] convert_docling ==="
  & .\.docling_venv\Scripts\python.exe reference\scripts\convert_docling.py $pdf
  Write-Host "=== [$base] convert_mineru ==="
  & .\.mineru_venv\Scripts\python.exe reference\scripts\convert_mineru.py $pdf
  Write-Host "=== [$base] DONE win steps ==="
}
Write-Host "ALL_WIN_STEPS_COMPLETE"
