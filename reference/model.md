# Recov — Working Model (v1)

> The lean statement of the model: **one master formula, all its inputs, its output.**
> Rationale, alternatives, and the literature live in `mathematical-model.md` (Section 2
> derives this). This document is the first pass at the *actual working model* — what an
> implementation reads.

---

## The output

A real-time **efficiency ranking over every exercise** in
`free-exercise-db_exercises.json` (873 exercises), for hypertrophy. At any instant $t$,
each exercise $e$ gets a score

$$
\eta_e(t) \in [0, 1] \quad\longrightarrow\quad \text{displayed } 0\text{–}100\%
$$

answering the one question: **"how effective is this set, right now?"** The ranking is
the sorted list of `η_e(t)`. The score is **absolute** (an honest intrinsic efficiency —
a fully-fatigued day can top out well below 100%); a relative/percentile view is an
optional display transform, not a separate model.

Population-level only: no per-user fitting. All constants below are set from the
literature (or explicitly guessed), never fit per user.

---

## The master formula

$$
\eta_e(t) \;=\; \underbrace{S(t)}_{\substack{\text{shared}\\\text{systemic}}} \,\cdot \sum_{m \,\in\, e} \underbrace{a_{e,m}}_{\substack{\text{attribution}\\\text{(set credit)}}} \cdot \underbrace{\mathrm{Recovery}_m(t)}_{\substack{\text{Axis A:}\\\text{recovery gate}}} \cdot \underbrace{f'\!\big(V_{\text{eff},m}(t)\big)}_{\substack{\text{Axis B:}\\\text{marginal value}}}
$$

(then normalized to $[0,1]$). A **Hammerstein–Wiener cascade**: per-channel **leaky integrators** (linear convolution
of the timestamped set history) → **static concave nonlinearities** → **multiplicative**
combination across parallel per-muscle channels, all scaled by **one shared systemic
channel**. Every factor is bounded to $[0,1]$, so each **per-muscle channel product**
$a_{e,m}\cdot\mathrm{Recovery}_m\cdot f'$ is in $[0,1]$; the **sum over an exercise's
muscles** can exceed 1, which is what the explicit **normalize** step resolves (see the
worked example).

### The three state variables (all leaky integrators / EMAs)

Each is a running exponential sum over past sets, updated in $O(1)$ per muscle per set via

$$
x(t) \;=\; x(t_{\text{prev}})\,e^{-(t-t_{\text{prev}})/\tau} \;+\; (\text{new impulse})
$$

| State | Definition | Axis | $\tau$ (timescale) |
|---|---|---|---|
| $V_{\text{eff},m}(t)$ | effective accumulated volume for muscle $m$: $\;\sum_i a_{e_i,m}\,w_i\,e^{-(t-t_i)/\tau_{\text{slow}}}$ | B (stimulus debt) | $\tau_{\text{slow}}$ ~ days–week |
| $D_m(t)$ | recovery deficit: $\;\sum_i a_{e_i,m}\,e^{-(t-t_i)/\tau_{\text{fast}}}$ | A (recovery) | $\tau_{\text{fast}}$ ~ 1–5 d (EIMD) |
| $S(t)$ | systemic fatigue: $\;\sum_i c_{e_i}\,e^{-(t-t_i)/\tau_{\text{sys}}}$ (one global state, all muscles) | systemic | $\tau_{\text{sys}}$ ~ days (between-session) |

### The static readouts (each bounded to `[0,1]`)

| Readout | Form | Meaning |
|---|---|---|
| $f'(V_{\text{eff},m})$ | derivative of concave $f$ (log: $\Delta \propto \ln V$, PUOS≈11/session; or root $\sqrt{V}$, PUOS≈31/wk), rescaled to $[0,1]$ | marginal value of the *next* set: large when underworked, $\to 0$ at saturation/MRV |
| $\mathrm{Recovery}_m(t)$ | $e^{-D_m(t)} \in (0,1]$ | recovery gate: 1 when fully repaired, $\to 0$ right after a hard bout |
| $S(t)$ factor | $e^{-S(t)} \in (0,1]$ | global discount while systemically fatigued |

$f$ is **swappable** (log / root / exponential-growth / sigmoid) without touching the
engine — it only sets the shape of the diminishing-returns curve.

### Opt-in refinements (off by default in v1 — `λ0 = k3 = 0`)

A subtractive acute penalty for a genuine *counterproductive window* (score dips below
zero right after a bout), with optional Busso clustering (super-additive fatigue):

$$
\mathrm{value}_m(t) \;=\; f'(V_{\text{eff},m}) \;-\; \big(\lambda_0 + k_3\,C_m(t)\big)\,D_m(t)
\qquad C_m = \text{medium-}\tau_3 \text{ sensitizer EMA}
$$

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

Per-set impulse $w_i$ (the dose injected into the integrators) collapses, for
hypertrophy, to **≈ 1 fractional set** with at most a mild RIR modifier:

$$
w_i \;=\; \mathrm{rir\_mod}(RIR_i) \qquad (\approx 1;\ \text{concave, plateaus by ~1–2 RIR})
$$

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

$$
a_{e,m} \;=\;
\begin{cases}
1.0 & m \in \mathrm{primaryMuscles}(e) \\
0.5 & m \in \mathrm{secondaryMuscles}(e) \\
0.0 & \text{otherwise}
\end{cases}
$$

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

---

## Worked example

A full trace from the **raw set log** to a ranking — mirroring what the algorithm
actually receives. The input is a **flat stream of individual, timestamped sets**: there
is no "session," "exercise block," or "5 sets of bench" object — each set is its own event
with its own impulse (this is the continuous-time stance; see the note after Step 0).
Nothing is hand-fed at the muscle level; every per-muscle number is *derived* from those
sets via the attribution map. The output ranks the single **next set**, not a session.
**All constants here are illustrative placeholders** (the committed values are still TBD,
per above) — the point is to show the machinery end-to-end and that it behaves sanely, not
to assert numbers.

**Illustrative constants.** $\tau_{\text{fast}} = 3$ d (recovery), $\tau_{\text{slow}} = 7$
d (volume), $\tau_{\text{sys}} = 5$ d (systemic). Recovery gate
$\mathrm{Recovery}_m = e^{-D_m}$. Dose-response $f(V)=\sqrt{V}$ (the Pelland weekly root);
the **marginal value of the next set** is the increment of that curve,

$$
\mathrm{Marginal}_m \;=\; f(V_{\text{eff},m}+1) - f(V_{\text{eff},m}) \;=\; \sqrt{V_{\text{eff},m}+1}-\sqrt{V_{\text{eff},m}} \;\approx\; f'(V_{\text{eff},m})
$$

— bounded to $(0,1]$, max at $V_{\text{eff}}=0$ (deepest stimulus debt). Per-set impulse
$w_i = \mathrm{rir\_mod}(RIR_i)$; all sets below are working sets at RIR 1–2 so
$w_i \approx 1$. Per-set systemic cost $c_e$: compound = 0.035, isolation = 0.015 (Sousa
ordering — multi-joint costs more).

### Step 0 — the input: a stream of individual sets

This is the entire L0 input. No muscle and no "session" appears — only timestamped sets.
Each `✓` is one logged set with its own timestamp; the day grouping below is **purely
visual** (the engine just sorts the flat stream). Note the curls are genuinely *floated* —
uneven gaps, not a block (`now` = day 0, 14:00):

```
day −21   08:00 ✓  08:04 ✓  08:09 ✓  08:13 ✓                    calf raise   (isolation, RIR 2)
day −5    19:00 ✓  19:15 ✓  19:20 ✓  19:31 ✓  19:38 ✓  19:50 ✓  curl         (isolation, RIR 1–2)  ← floated
day −4    12:00 ✓  12:05 ✓  12:11 ✓  12:16 ✓  12:22 ✓           pull-up      (compound,  RIR 1–2)
day −1    17:30 ✓  17:36 ✓  17:42 ✓  17:49 ✓  17:55 ✓           bench press  (compound,  RIR 1–2)
```

20 sets total: 4 calf, 6 curl, 5 pull-up, 5 bench.

> **Why floating leaves the math unchanged here.** The slow integrators weight each set by
> $e^{-\Delta t/\tau}$ with $\tau$ in **days**, so across a bout that spans minutes the
> weight is constant to several decimals — the six curl sets at 19:00–19:50 contribute
> identically whether we treat them as floating or as one 19:25 cluster. So un-clustering
> is *representationally* honest but, on the day-scale layers alone, **numerically inert**:
> every number below is unchanged. Within-bout timing only starts to matter once a
> **minutes-scale** term exists (the acute layer — deliberately *not* added here; under
> discussion). That indifference is exactly why the day-scale backbone is safe to leave
> as-is while we still drop the "session" as an input unit.

### Step 1 — expand each exercise into per-muscle impulses

Each set in the stream deposits $w_i\,a_{e,m} \approx a_{e,m}$ into the $D$ and
$V_{\text{eff}}$ integrators of every muscle the exercise touches, using the attribution
map $a_{e,m}$ (primary = 1.0, secondary = 0.5) from the exercise DB:

| Exercise | primary ($a=1.0$) | secondary ($a=0.5$) |
|---|---|---|
| Bench Press | chest | shoulders, triceps |
| Pull-up | lats | biceps, middle back |
| Barbell Curl | biceps | forearms |
| Calf Raise | calves | — |

Collecting the stream per muscle (each bout's sets fall within minutes, so we write
$\text{count}\times a$ at the bout's age — see the Step 0 note) — and notice **biceps
accumulates from two different exercises**, which a muscle-first telling would miss:

| Muscle | impulses ($\text{count}\times a$ @ age) |
|---|---|
| chest | $5 \times 1.0$ @ 1 d |
| shoulders | $5 \times 0.5$ @ 1 d |
| triceps | $5 \times 0.5$ @ 1 d |
| lats | $5 \times 1.0$ @ 4 d |
| middle back | $5 \times 0.5$ @ 4 d |
| biceps | $6 \times 1.0$ @ 5 d **+** $5 \times 0.5$ @ 4 d |
| forearms | $6 \times 0.5$ @ 5 d |
| calves | $4 \times 1.0$ @ 21 d |

### Step 2 — per-muscle state

$D_m = \sum_i (\text{impulse})_i\,e^{-\Delta t_i/\tau_{\text{fast}}}$ and
$V_{\text{eff},m} = \sum_i (\text{impulse})_i\,e^{-\Delta t_i/\tau_{\text{slow}}}$, then the
two readouts:

| Muscle | $D_m$ | $\mathrm{Recovery}_m=e^{-D_m}$ | $V_{\text{eff},m}$ | $\mathrm{Marginal}_m$ |
|---|---|---|---|---|
| chest | 3.58 | **0.028** | 4.33 | 0.228 |
| shoulders | 1.79 | 0.167 | 2.17 | 0.308 |
| triceps | 1.79 | 0.167 | 2.17 | 0.308 |
| lats | 1.32 | 0.268 | 2.82 | 0.275 |
| middle back | 0.66 | 0.517 | 1.41 | 0.365 |
| biceps | 1.79 | 0.167 | 4.35 | 0.227 |
| forearms | 0.57 | 0.567 | 1.47 | 0.359 |
| calves | 0.004 | **0.996** | 0.20 | **0.649** |

The two axes pull apart: chest is low on **both** (fried *and* already stocked with
volume); calves are high on **both** (fully repaired *and* 21 days of decay left almost no
recent volume → near-maximal marginal value). Biceps got the most total volume (two
sources) so its marginal is the lowest of the upper-body movers.

### Step 3 — per-muscle channel value

$v_m = \mathrm{Recovery}_m \cdot \mathrm{Marginal}_m$ (Axis A × Axis B):

| Muscle | $v_m$ |
|---|---|
| chest | 0.006 |
| shoulders | 0.051 |
| triceps | 0.051 |
| lats | 0.074 |
| middle back | **0.189** |
| biceps | 0.038 |
| forearms | **0.204** |
| calves | **0.646** |

### Step 4 — systemic factor (also derived from the log)

Every set also deposits a systemic cost $c_e$, summed over the whole stream:
$S(t) = \sum_{\text{sets } i} c_{e_i}\,e^{-\Delta t_i/\tau_{\text{sys}}}$ (each bout's sets
are within minutes, so we group as $\text{count}\times c_e$ at the bout's age):

| Bout | $\text{count}\times c_e$ | $\times\,e^{-\Delta t/5}$ |
|---|---|---|
| Bench (1 d) | $5\times0.035 = 0.175$ | 0.143 |
| Pull-up (4 d) | $5\times0.035 = 0.175$ | 0.079 |
| Curl (5 d) | $6\times0.015 = 0.090$ | 0.033 |
| Calf (21 d) | $4\times0.015 = 0.060$ | 0.001 |

$S(t) = 0.256 \Rightarrow$ systemic factor $e^{-S} = 0.774$.

### Step 5 — per-exercise composite

$\;\tilde\eta_e = e^{-S}\cdot \sum_{m\in e} a_{e,m}\,v_m\;$ (same attribution map as Step 1):

| Exercise | $\sum a_{e,m}\,v_m$ | $\times\,0.774$ |
|---|---|---|
| **Standing Calf Raise** | $0.646$ | **0.500** |
| Pull-up | $0.074 + 0.5(0.038) + 0.5(0.189) = 0.187$ | 0.145 |
| Barbell Curl | $0.038 + 0.5(0.204) = 0.140$ | 0.108 |
| Bench Press | $0.006 + 0.5(0.051) + 0.5(0.051) = 0.058$ | 0.045 |

### Step 6 — normalize → ranking

The composites are bounded per-channel but the muscle-sum is not, so we normalize.
Relative (percentile) display divides by the current best:

| Rank | Exercise | $\eta_e$ |
|---|---|---|
| 1 | **Standing Calf Raise** | **100%** |
| 2 | Pull-up | 29% |
| 3 | Barbell Curl | 22% |
| 4 | Bench Press | 9% |

### Reading the result

- **The model dissolves the "what day is it?" question.** You benched yesterday; the
  naïve move is "legs or back today." The engine instead says your single most efficient
  next set *right now* is **calf raises** — recovered and three weeks underworked — and
  ranks bench **last**, because the chest is still wrecked (recovery 0.028) and even its
  synergists are tired. No "push/pull/legs" unit was ever invoked.
- **Compounds score on the muscles you'd forget — which is why we reason from exercises.**
  Pull-up and curl rank above bench largely on their *secondary* muscles: middle back
  ($v=0.19$) and forearms ($v=0.20$) are recovered and underworked, because nothing has
  hit them directly. A muscle-first telling that only logged "biceps, lats, chest…" would
  never surface that, and would mis-rank these exercises. The attribution map is doing real
  work, not bookkeeping.
- **One muscle, many exercises.** Biceps state aggregates the pull-up sets four days ago
  *and* the heavier curl sets five days ago — the integrators sum over the whole set stream
  regardless of which exercise deposited each impulse. That only falls out cleanly when the
  input is a stream of sets, not pre-bundled blocks.
- **No "session" entered anywhere.** The input is a flat stream of timestamped sets; the
  output ranks the next *set*. On the day-scale layers shown here, *when* within a bout each
  set landed is immaterial (Step 0 note) — so dropping the cluster costs us nothing now. The
  only thing that would make within-bout timing bite is a **minutes-scale acute term**,
  which we are deliberately holding for separate discussion rather than reflexively adding a
  fourth decay state.
- **Two subtleties this surfaces.** (1) Each per-muscle product is in $[0,1]$ but
  $\sum_{m\in e}$ is not — a fresh full-body exercise hitting several underworked muscles
  can exceed 1 pre-normalization; the **normalize** step is load-bearing, not cosmetic.
  (2) At a single instant $S(t)$ is one number, so it scales every exercise equally and
  **does not change the ranking** — it only sets the *absolute* ceiling (a systemically
  fried day tops out lower). Its ranking effect appears only *across* time as it decays.
