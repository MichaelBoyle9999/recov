#!/usr/bin/env bash
set -u
script='/mnt/c/Users/micha/work/recov/reference/scripts/run_olmocr_wsl.sh'
sed -i 's/\r$//' "$script"
bases=(
  'Burd-2010_resistance-exercise-volume-myofibrillar-protein-synthesis'
  'Ceddia-2025_tapering-periodisation-optimisation'
  'Damas-2016_myofibrillar-protein-synthesis-damage-hypertrophy'
  'Herold-2021_isometric-loading-scheme-optimization-model'
  'Imbach-2022_fitness-fatigue-models-machine-learning'
  'Jukic-2023_velocity-loss-thresholds-meta-analysis'
  'Kontro-2025_three-dimensional-impulse-response-model'
  'Pareja-Blanco-2019_recovery-timecourse-loading-velocity-loss'
  'Refalo-2023_proximity-to-failure-hypertrophy-meta-analysis'
  'Refalo-2023_proximity-to-failure-neuromuscular-fatigue'
  'Sousa-2024_recovery-resistance-training-microcycle-construction'
  'Zajac-2015_central-peripheral-fatigue-resistance-exercise-review'
)
for base in "${bases[@]}"; do
  wslpdf="/mnt/c/Users/micha/work/recov/reference/pdfs/$base/$base.pdf"
  echo "=== [$base] olmocr ==="
  bash "$script" "$wslpdf"
  echo "=== [$base] olmocr DONE ==="
done
echo "ALL_OLMOCR_COMPLETE"
