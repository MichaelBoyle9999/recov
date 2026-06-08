# Free Exercise DB — exercise→muscle mover mapping (vendored)

Public-domain dataset of **873 exercises**, each annotated with the muscles it works,
its mechanic (compound/isolation), force vector, equipment, and category. Vendored here as the
free, structured replacement for the print anatomy/technique textbooks (NSCA Essentials, Delavier,
Zatsiorsky) for **Theme 2 — which exercises are direct/indirect for which muscles**. Also serves as
the master **exercise list** for later aggregation.

## Source & license
- **Repository:** https://github.com/yuhonas/free-exercise-db
- **File pulled:** `dist/exercises.json` (combined array), from `raw.githubusercontent.com/.../main`
- **Pulled:** 2026-06-07
- **License:** **The Unlicense** — released into the **public domain** (`LICENSE.md` mirrored as
  `_freeexdb_LICENSE.md` is removed after vendoring; see repo for the full text). No attribution
  required, but provenance is recorded here for honesty.
- **Lineage:** restructured from Ollie Jennings' `wrkout/exercises.json`.

## Files vendored
| File | What it is |
|---|---|
| `free-exercise-db_exercises.json` | Full dataset, all 873 records, all fields (incl. `instructions`, `images`). Pretty-printed, key-sorted. |
| `free-exercise-db_mover-map.csv` | Derived flat table for aggregation: one row per exercise. |
| `free-exercise-db_build.py` | Script that regenerates the two files above from the upstream JSON. |

## `mover-map.csv` columns
`name, category, mechanic, force, level, equipment, direct_muscles, indirect_muscles`

- **`direct_muscles`** = the dataset's `primaryMuscles` → treat as a **full (1.0) set** for that muscle.
- **`indirect_muscles`** = the dataset's `secondaryMuscles` → treat as a **fractional (0.5) set**.
  This is exactly the direct/indirect split the fractional-volume literature (Pelland/Remmert) uses.
- Multi-valued cells join muscles with `; `.

## Muscle vocabulary (17 groups, `primaryMuscles`/`secondaryMuscles`)
abdominals, abductors, adductors, biceps, calves, chest, forearms, glutes, hamstrings, lats,
lower back, middle back, neck, quadriceps, shoulders, traps, triceps

## Categories (7)
cardio, olympic weightlifting, plyometrics, powerlifting, strength, stretching, strongman

## Mechanic
compound = 489, isolation = 297, unspecified (null) = 87.

## Caveats
- This is **community-curated**, not peer-reviewed: the direct/indirect labels are editorial
  (anatomical reasoning), **not** EMG-derived. For the big compounds, cross-check against the EMG
  %MVC papers in Bucket A (Lehman 2004, Rodríguez-Ridao 2020, Martín-Fuentes 2020, Clark 2012,
  Saeterbakken 2013), which give quantitative activation rather than a binary primary/secondary flag.
- `mechanic`, `force`, and `equipment` are `null` for some records (the upstream data is incomplete
  on those fields).
- Muscle granularity is coarse (e.g. a single `shoulders`, not ant/med/post delt; `quadriceps` not
  split by head). Fine for set-counting bookkeeping; not for regional-hypertrophy questions.

## Reproduce
```
curl -L https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json -o _exercises_raw.json
python free-exercise-db_build.py   # regenerates the .json copy + mover-map.csv
```
