# Recov — Working Model (v1)

> The lean statement of the model: **one master formula, all its inputs, its output.**
> Rationale, alternatives, and the literature live in `mathematical-model.md` (Section 2
> derives this). This document is the first pass at the *actual working model* — what an
> implementation reads.

---

## The output

A real-time **efficiency ranking over every exercise** in
`free-exercise-db_exercises.json` (873 exercises), for hypertrophy. At any instant `t`,
each exercise `e` gets a score

```
η_e(t) ∈ [0, 1]   →   displayed 0–100%
```

answering the one question: **"how effective is this set, right now?"** The ranking is
the sorted list of `η_e(t)`. The score is **absolute** (an honest intrinsic efficiency —
a fully-fatigued day can top out well below 100%); a relative/percentile view is an
optional display transform, not a separate model.

Population-level only: no per-user fitting. All constants below are set from the
literature (or explicitly guessed), never fit per user.

---

## The master formula

```
            ┌─────────────── shared systemic channel
            │        ┌────── sum over the muscles this exercise trains
            │        │     ┌──────── attribution: how much of a set counts for muscle m
            │        │     │      ┌──────── recovery gate (Axis A): is m repaired enough?
            │        │     │      │              ┌──────── marginal value (Axis B): is m underworked?
  η_e(t) = S(t) ·  Σ    a_{e,m} · Recovery_m(t) · f'(V_eff,m(t))           (then normalize to [0,1])
                 m ∈ e
```

A **Hammerstein–Wiener cascade**: per-channel **leaky integrators** (linear convolution
of the timestamped set history) → **static concave nonlinearities** → **multiplicative**
combination across parallel per-muscle channels, all scaled by **one shared systemic
channel**. Every factor is bounded to `[0,1]`, so the product is in `[0,1]` with no
clamping.

### The three state variables (all leaky integrators / EMAs)

Each is a running exponential sum over past sets, updated in O(1) per muscle per set via
`x(t) = x(t_prev)·e^{−(t − t_prev)/τ} + (new impulse)`:

| State | Definition | Axis | τ (timescale) |
|---|---|---|---|
| `V_eff,m(t)` | effective accumulated volume for muscle `m` = `Σ_i a_{e_i,m}·w_i·e^{−(t−t_i)/τ_slow}` | B (stimulus debt) | `τ_slow` ~ days–week |
| `D_m(t)` | recovery deficit = `Σ_i a_{e_i,m}·e^{−(t−t_i)/τ_fast}` | A (recovery) | `τ_fast` ~ 1–5 d (EIMD) |
| `S(t)` | systemic fatigue = `Σ_i c_{e_i}·e^{−(t−t_i)/τ_sys}` (one global state, all muscles) | systemic | `τ_sys` ~ days (between-session) |

### The static readouts (each bounded to `[0,1]`)

| Readout | Form | Meaning |
|---|---|---|
| `f'(V_eff,m)` | derivative of concave `f` (log: `Δ ∝ ln V`, PUOS≈11/session; or root `√V`, PUOS≈31/wk), rescaled to `[0,1]` | marginal value of the *next* set: large when underworked, →0 at saturation/MRV |
| `Recovery_m(t)` | `exp(−D_m(t))` ∈ (0,1] | recovery gate: 1 when fully repaired, →0 right after a hard bout |
| `S(t)` factor | `exp(−S(t))` ∈ (0,1] | global discount while systemically fatigued |

`f` is **swappable** (log / root / exponential-growth / sigmoid) without touching the
engine — it only sets the shape of the diminishing-returns curve.

### Opt-in refinements (off by default in v1 — `λ0 = k3 = 0`)

A subtractive acute penalty for a genuine *counterproductive window* (score dips below
zero right after a bout), with optional Busso clustering (super-additive fatigue):

```
value_m(t) = f'(V_eff,m) − (λ0 + k3·C_m(t))·D_m(t)      C_m = medium-τ3 sensitizer EMA
```

Used only when a sub-zero "do not train yet" signal is wanted (e.g. forward projection).
For pure ranking, the bounded multiplicative form above suffices.

---

## The inputs

### L0 — the set history (the only time-varying input)

A stream of logged sets. Per set `i`:

| Field | Symbol | Required? | If missing (minimal-log fallback) |
|---|---|---|---|
| exercise | `e_i` | **yes** | — |
| timestamp | `t_i` | **yes** | — |
| reps | `r_i` | no | assume working-set prior (8–12) |
| load | `L_i` | no | hypertrophy-load prior; load is interchangeable near failure |
| reps-in-reserve / RPE | `RIR_i` | no | assume fixed RIR (1–3) |

Per-set impulse `w_i` (the dose injected into the integrators) collapses, for
hypertrophy, to **≈ 1 fractional set** with at most a mild RIR modifier:

```
w_i = rir_mod(RIR_i)          (≈ 1; concave, plateaus by ~1–2 RIR)
```

Reps and load drop out of the stimulus to first order — which is exactly what makes the
minimal `(exercise, timestamp, RPE)` log viable.

### Per-exercise parameters (static, from the exercise DB — 873 exercises)

These come from `free-exercise-db_mover-map.csv` and do **not** change over time.

| Parameter | Symbol | Source | Notes |
|---|---|---|---|
| **primary (direct) muscles** | → `a_{e,m} = 1.0` | `direct_muscles` column (`primaryMuscles`) | the muscles a set fully counts for |
| **secondary (indirect) muscles** | → `a_{e,m} = 0.5` | `indirect_muscles` column (`secondaryMuscles`) | fractional credit (the empirically-favored 0.5; Remmert/Pelland) |
| all other muscles | `a_{e,m} = 0` | — | not trained |
| systemic cost | `c_e` | derived from `mechanic`/`force`/category + `Sousa-2024` ordering | feeds `S(t)`; multi-joint/lower-body/eccentric cost more. **Cost table still owed.** |

So the **attribution map `a_{e,m}`** — the only place exercise identity enters the
dynamics — is built directly from the primary/secondary muscle lists we already have:

```
a_{e,m} = 1.0  if m ∈ primaryMuscles(e)
        = 0.5  if m ∈ secondaryMuscles(e)
        = 0.0  otherwise
```

EMG-based refinement of these weights is **deferred** (Vigotsky caveat: EMG amplitude is
ordinal, not a literal multiplier). v1 ships the binary {0, 0.5, 1} map.

### Per-muscle parameters (static, population-level — 17 muscles)

State is tracked per muscle over the **17 DB muscles**: `abdominals, abductors,
adductors, biceps, calves, chest, forearms, glutes, hamstrings, lats, lower back,
middle back, neck, quadriceps, shoulders, traps, triceps`.

| Parameter | Symbol | Source | Status |
|---|---|---|---|
| slow time constant | `τ_slow` | dose-response / volume kinetics | needs setting |
| fast (recovery) time constant | `τ_fast` | EIMD: `Paulsen-2012`, `Howatson-2008` (~1–5 d) | needs fitting |
| volume landmarks | `MV / MEV / MAV / MRV` | `RP-volume-landmarks_current.csv` | locked as scale; **needs RP-12 → DB-17 map** |
| dose-response curve `f` | `f_session` (log), `f_week` (root) | `Remmert-2024`, `Pelland-2024` | locked; shape swappable |

**RP-12 → DB-17 map (owed).** RP's landmarks are for **12 groups**; we track **17
muscles**. The mapping is one-to-many and must be built (and RP's *direct-set* counts
reconciled with our *fractional* counting before MEV/MAV/MRV are used as ceilings):

```
RP "Back"            → lats, middle back, lower back
RP "Front Delts" +
RP "Rear/Side Delts" → shoulders
RP "Quads"           → quadriceps
RP "Abs"             → abdominals
… (Chest, Biceps, Triceps, Traps, Glutes, Hamstrings, Calves map ~1:1)
```

RP has no landmark for `abductors`, `adductors`, `forearms`, `neck` — these need a
borrowed/default scale.

### Global parameters (population-level)

| Parameter | Symbol | Role | Status |
|---|---|---|---|
| systemic time constant | `τ_sys` | between-session systemic recovery | unquantified (gap) |
| acute penalty weight | `λ0` | negativity knob | **0 in v1** |
| clustering gain | `k3` | super-additive fatigue knob | **0 in v1** |
| sensitizer time constant | `τ3` | clustering EMA | only if `k3 > 0` (~2 d) |

---

## What "v1" commits to vs. defers

**Committed:** the LN-cascade structure; multiplicative bounded combination; `a_{e,m} ∈
{0, 0.5, 1}` from primary/secondary muscles; marginal value = concave dose-response
slope; population-fixed parameters; recovery gate = `exp(−D_m)`.

**Deferred / owed (calibration within this structure):** the `τ` values; the RP-12 →
DB-17 map; the per-exercise systemic cost table `c_e`; the final choice of `f`; the RIR
modifier shape; EMG perturbations to `a_{e,m}`; the acute (sub-session) and clustering
refinements (`λ0`, `k3` start at 0).
