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
\eta_e(t) \;=\; \underbrace{e^{-\kappa\, c_e\, S(t)}}_{\substack{\text{systemic gate}\\\text{(cost-aware)}}} \,\cdot \sum_{m \,\in\, e} \underbrace{g_m}_{\substack{\text{user}\\\text{priority}}} \cdot \underbrace{a_{e,m}}_{\substack{\text{attribution}\\\text{(set credit)}}} \cdot \underbrace{\mathrm{Recovery}_m(t)}_{\substack{\text{Axis A:}\\\text{recovery gate}}} \cdot \underbrace{f'\!\big(V_{\text{eff},m}(t)\big)}_{\substack{\text{Axis B:}\\\text{marginal value}}}
$$

(then normalized to $[0,1]$). A **Hammerstein–Wiener cascade**: per-channel **leaky integrators** (linear convolution
of the timestamped set history) → **static concave nonlinearities** → **multiplicative**
combination across parallel per-muscle channels, all scaled by a **cost-aware systemic
gate**. The systemic gate is **not** a flat global dimmer: it discounts each candidate by
*its own* prospective cost $c_e$ scaled by the current systemic depletion $S(t)$, so it is
**inert when fresh** ($S\to 0 \Rightarrow$ gate $\to 1$ for all exercises) and **steers
toward low-cost work when depleted** (a costly compound is penalized more than a cheap
isolation). This is the only term that lets systemic fatigue *reorder* the ranking, not
merely lower its ceiling (Shape B; see `mathematical-model.md` §1.10 #2). $g_m \in [0,1]$
is the **user-configured priority** for muscle $m$ (default $1$ = full priority; lower it to
de-emphasize muscles the user doesn't care to grow). It is the one place user input enters
the model — and it is **configuration, not fitting**: the user states a *goal*, the dynamics
($\tau$, landmarks, dose-response) remain population-fixed and are never inferred from the
user's own logs (see *user configuration* below). Every factor is
bounded to $[0,1]$, so each **per-muscle channel product**
$g_m\cdot a_{e,m}\cdot\mathrm{Recovery}_m\cdot f'$ is in $[0,1]$; the **sum over an exercise's
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
| $D_m(t)$ | recovery deficit: $\;\sum_i a_{e_i,m}\,e^{-(t-t_i)/\tau_{\text{fast},m}}$ | A (recovery) | $\tau_{\text{fast},m}$ ~ 1–5 d (EIMD), **per muscle** |
| $S(t)$ | systemic depletion: $\;\sum_i c_{e_i}\,e^{-(t-t_i)/\tau_{\text{sys}}}$ (one global state; feeds the cost-aware gate) | systemic | $\tau_{\text{sys}}$ ~ days (between-session) |

### The static readouts (each bounded to `[0,1]`)

| Readout | Form | Meaning |
|---|---|---|
| $f'(V_{\text{eff},m})$ | derivative of concave $f$ (log: $\Delta \propto \ln V$, PUOS≈11/session; or root $\sqrt{V}$, PUOS≈31/wk), rescaled to $[0,1]$ | marginal value of the *next* set: large when underworked, $\to 0$ at saturation/MRV |
| $\mathrm{Recovery}_m(t)$ | $e^{-D_m(t)/\mathrm{cap}_m} \in (0,1]$ | recovery gate: 1 when fully repaired, $\to 0$ right after a hard bout. **Capacity-normalized**: $\mathrm{cap}_m \propto \mathrm{MRV}_m$, so a high-capacity muscle isn't crushed by the same absolute deficit as a small one |
| systemic gate | $e^{-\kappa\,c_e\,S(t)} \in (0,1]$ | **cost-aware**: inert when fresh ($S\to0$); penalizes high-$c_e$ exercises more as depletion rises → reorders toward low-cost work |

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
| systemic cost | `c_e` | derived from `mechanic`/`force`/category + `Sousa-2024` ordering | multi-joint/lower-body/eccentric cost more. **One number, two jobs:** the dose a set *deposits* into `S(t)` when logged, **and** the cost the candidate is *charged* by the systemic gate $e^{-\kappa c_e S}$ when ranked. **Cost table still owed.** |

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
| fast (recovery) time constant | `τ_fast,m` | EIMD: `Paulsen-2012`, `Howatson-2008` (~1–5 d); **per-muscle rate** | population table owed (see below) |
| recovery capacity | `cap_m` | `∝ MRV_m` (`RP-volume-landmarks_current.csv`) | normalizes the recovery gate; falls out of the RP-12 → DB-17 map |
| volume landmarks | `MV / MEV / MAV / MRV` | `RP-volume-landmarks_current.csv` | locked as scale; **needs RP-12 → DB-17 map** |
| dose-response curve `f` | `f_session` (log), `f_week` (root) | `Remmert-2024`, `Pelland-2024` | locked; shape swappable |

**Per-muscle capacity & recovery rate (`cap_m`, `τ_fast,m`).** Muscles differ in both how
much volume they can recover (`cap_m`) and how fast (`τ_fast,m`); a single global recovery
gate over-penalizes high-capacity, fatigue-resistant muscles. There is **no clean kinetic
dataset** giving per-muscle recovery time constants — so, exactly like the `c_e` cost table,
this is a **hand-set population table** triangulated from the best available proxies, not fit:

- **`cap_m` (capacity)** — set directly from **RP MRV** per muscle (already in repo; the same
  RP-12 → DB-17 map). Larger recoverable ceiling → larger `cap_m` (quads/calves high,
  hamstrings/front-delts low).
- **`τ_fast,m` (rate)** — ordered by **damage susceptibility / architecture**: longitudinal-
  fusiform and biarticular muscles recover slower (hamstrings peak ~48 h vs quads ~24 h;
  `EJAP-2023`), pennate and habitually-loaded muscles faster; fatigue-resistant Type-I
  postural muscles (calves, abs, erectors, traps — `Johnson-1973` fiber-type table) fastest,
  consistent with RP's higher tolerable frequency for them. Set from this ordering, not a
  fitted curve.

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
| systemic time constant | `τ_sys` | between-session systemic recovery | unquantified (gap); ACWR convention ~7 d acute |
| systemic coupling gain | `κ` | strength of the cost-aware systemic penalty | guess (no data); keep modest — `κ→0` recovers a pure per-muscle model |
| acute penalty weight | `λ0` | negativity knob | **0 in v1** |
| clustering gain | `k3` | super-additive fatigue knob | **0 in v1** |
| sensitizer time constant | `τ3` | clustering EMA | only if `k3 > 0` (~2 d) |

### User configuration (the *only* user-tunable input — config, not fitting)

| Parameter | Symbol | Role | Status |
|---|---|---|---|
| muscle priority | `g_m` | per-muscle goal weight $\in [0,1]$, default $1$ | user-set; default uniform |

`g_m` answers **"which muscles do I even care about, and how much?"** — a per-muscle weight
the user sets once (default all $1$ = balanced total hypertrophy, the original v1 objective).
Lowering `g_m` de-prioritizes a muscle in the ranking (set `g_neck`, `g_forearms` low and the
engine stops surfacing trivial neglected muscles just because they're underworked — the
failure mode of a pure "balanced" objective). It enters as a **pure multiplicative weight on
the channel** (master formula above), so it reranks the readout **without touching the
physiology** — `τ`, `cap_m`, landmarks, and dose-response stay population-fixed.

This is a deliberate, narrow walk-back of the "no personalization" stance, and the line is
sharp: **configuration is allowed, fitting is still banned.** The user may *declare a goal*
(`g_m`); the model never *infers* dynamics (time constants, gains, `f`) from the user's own
logs — that ill-conditioned per-subject fitting (Imbach) remains out of scope. `g_m` changes
*what we optimize for*, not *the model of how muscles respond*. (A future UI could expose
more config in the same spirit — e.g. a known injury masking an exercise — but `g_m` is the
only one committed for v1.)

---

## What "v1" commits to vs. defers

**Committed:** the LN-cascade structure; multiplicative bounded combination; `a_{e,m} ∈
{0, 0.5, 1}` from primary/secondary muscles; marginal value = concave dose-response
slope; population-fixed *dynamics* (one user-config goal weight `g_m`, see below — but no
per-user *fitting*); **capacity-normalized, per-muscle** recovery gate `exp(−D_m/cap_m)` with
per-muscle `τ_fast,m`; **cost-aware systemic gate** `exp(−κ·c_e·S)` (Shape B — reorders
toward low-cost work when depleted, inert when fresh); **per-muscle user priority** `g_m`
(default uniform); **three timescales only** (no minutes-scale acute channel — see below).

**Decided *out* (not deferred — declined by design):** a fourth, **minutes-scale acute /
intra-bout channel**. The behaviors it would add are already supplied by machinery we
commit to: (1) within-bout diminishing returns come from the **concavity of `f`** (each
set lands on a higher `V_eff`, so `f'` falls) — no fast state needed; (2) "you just
worked this muscle, move on" comes from the **slow channels accumulating per set** (`D_m`
and `V_eff,m` rise on every logged set; the worked example buries bench at 9% from this
alone). The only thing genuinely lost is **minute-resolution recovery within a bout** — a
distinction below the granularity any user acts on (actionable recovery is hours–days).
Crucially, omitting it does **not** re-introduce "days": `Δt` stays a continuous real
number, nothing buckets by calendar, floating sets remain the native input. We simply
decline to *resolve* minutes, because the value would be redundant and the state would be
unidentifiable (Imbach). This is a defended boundary, not a gap.

**Deferred / owed (calibration within this structure):** the `τ` values; the RP-12 →
DB-17 map; the per-muscle capacity/recovery-rate table (`cap_m ∝ MRV_m`, `τ_fast,m` from the
damage-susceptibility ordering — hand-set like `c_e`, no kinetic data); the per-exercise
systemic cost table `c_e` and the systemic coupling gain `κ`; the final choice of `f`; the
RIR modifier shape; EMG perturbations to `a_{e,m}`; the subtractive/clustering refinements
(`λ0`, `k3` start at 0). User priority `g_m` defaults to uniform (no calibration needed).

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

**Illustrative constants.** $\tau_{\text{fast},m} = 3$ d (recovery), $\tau_{\text{slow}} = 7$
d (volume), $\tau_{\text{sys}} = 5$ d (systemic). To keep this trace readable it runs with the
two new per-muscle knobs at their **neutral defaults** — $\mathrm{cap}_m = 1$ and user priority
$g_m = 1$ for every muscle — so the numbers below are unchanged; with real `cap_m` (∝ MRV) and a
non-uniform `g_m` the recovery gate and the channel weights would shift per muscle. Recovery gate
$\mathrm{Recovery}_m = e^{-D_m/\mathrm{cap}_m} = e^{-D_m}$ here. Dose-response $f(V)=\sqrt{V}$ (the Pelland weekly root);
the **marginal value of the next set** is the increment of that curve,

$$
\mathrm{Marginal}_m \;=\; f(V_{\text{eff},m}+1) - f(V_{\text{eff},m}) \;=\; \sqrt{V_{\text{eff},m}+1}-\sqrt{V_{\text{eff},m}} \;\approx\; f'(V_{\text{eff},m})
$$

— bounded to $(0,1]$, max at $V_{\text{eff}}=0$ (deepest stimulus debt). Per-set impulse
$w_i = \mathrm{rir\_mod}(RIR_i)$; all sets below are working sets at RIR 1–2 so
$w_i \approx 1$. Per-set systemic cost $c_e$: compound = 0.035, isolation = 0.015 (Sousa
ordering — multi-joint costs more). Systemic coupling gain $\kappa = 20$ (illustrative — the
gain that turns accumulated depletion into a per-exercise penalty).

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
> every number below is unchanged. Within-bout timing would only bite if a **minutes-scale**
> acute channel existed — and we have **decided not to add one** (see *Committed vs. deferred*).
> That decision is not a limitation but the point: the within-bout work an acute term would do
> is already done by the concavity of `f` and by the slow channels accumulating per set, so
> resolving minutes would be redundant *and* unidentifiable. The indifference shown here is
> therefore permanent by design — which is exactly what lets us drop the "session" as an input
> unit without ever needing to reinstate it as a hidden timescale.

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

### Step 4 — systemic depletion state (also derived from the log)

Every set also deposits a systemic cost $c_e$, summed over the whole stream into the single
global state $S(t) = \sum_{\text{sets } i} c_{e_i}\,e^{-\Delta t_i/\tau_{\text{sys}}}$ (each
bout's sets are within minutes, so we group as $\text{count}\times c_e$ at the bout's age):

| Bout | $\text{count}\times c_e$ | $\times\,e^{-\Delta t/5}$ |
|---|---|---|
| Bench (1 d) | $5\times0.035 = 0.175$ | 0.143 |
| Pull-up (4 d) | $5\times0.035 = 0.175$ | 0.079 |
| Curl (5 d) | $6\times0.015 = 0.090$ | 0.033 |
| Calf (21 d) | $4\times0.015 = 0.060$ | 0.001 |

$S(t) = 0.256$. Note this is the **state**, not yet a factor — under Shape B it reads out
*per exercise* in Step 5, not as one global multiplier.

### Step 5 — per-exercise composite (cost-aware systemic gate)

$\;\tilde\eta_e = e^{-\kappa\,c_e\,S}\cdot \sum_{m\in e} a_{e,m}\,v_m\;$ — each exercise is
discounted by **its own** cost $c_e$ (not a shared factor), so the compounds (pull-up,
bench) are gated harder than the isolations. With $\kappa S = 20\times0.256 = 5.12$: gate
$= e^{-5.12\,c_e}$, i.e. $e^{-0.179}=0.836$ for compounds, $e^{-0.077}=0.926$ for isolations.

| Exercise | $c_e$ | gate $e^{-\kappa c_e S}$ | $\sum a_{e,m}\,v_m$ | $\tilde\eta_e$ |
|---|---|---|---|---|
| **Standing Calf Raise** | 0.015 | 0.926 | $0.646$ | **0.598** |
| Pull-up | 0.035 | 0.836 | $0.074 + 0.5(0.038) + 0.5(0.189) = 0.187$ | 0.156 |
| Barbell Curl | 0.015 | 0.926 | $0.038 + 0.5(0.204) = 0.140$ | 0.130 |
| Bench Press | 0.035 | 0.836 | $0.006 + 0.5(0.051) + 0.5(0.051) = 0.057$ | 0.048 |

### Step 6 — normalize → ranking

The composites are bounded per-channel but the muscle-sum is not, so we normalize.
Relative (percentile) display divides by the current best:

| Rank | Exercise | $\eta_e$ |
|---|---|---|
| 1 | **Standing Calf Raise** | **100%** |
| 2 | Pull-up | 26% |
| 3 | Barbell Curl | 22% |
| 4 | Bench Press | 8% |

The cost-aware gate is what separates Shape B from a flat dimmer: it nudged the two
**compounds down** (pull-up 29→26%, bench 9→8%) relative to the isolations while leaving
the cheap calf raise on top — a small effect at this modest depletion, but it grows with
$S$ and would vanish entirely on a fresh day ($S\to0$).

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
  set landed is immaterial (Step 0 note) — so dropping the cluster costs us nothing. The only
  thing that would make within-bout timing bite is a **minutes-scale acute term**, which we
  have **deliberately declined** (see *Committed vs. deferred*): the within-bout behavior it
  would add is already delivered by `f`'s concavity (set 5 of bench lands on a higher `V_eff`,
  so scores less) and by the slow channels accumulating per set (which is *why* bench ends up
  last here). The model stays at three timescales.
- **Two subtleties this surfaces.** (1) Each per-muscle product is in $[0,1]$ but
  $\sum_{m\in e}$ is not — a fresh full-body exercise hitting several underworked muscles
  can exceed 1 pre-normalization; the **normalize** step is load-bearing, not cosmetic.
  (2) The systemic state $S(t)$ is one number, but under Shape B it reads out through the
  **per-exercise** gate $e^{-\kappa c_e S}$ — so it **does change the ranking**, penalizing
  costly compounds more than cheap isolations (here pull-up and bench slip a point or two).
  It also still lowers the *absolute* ceiling, and it vanishes when fresh ($S\to0 \Rightarrow$
  gate $\to1$ for every exercise). A flat global dimmer would have done only the ceiling part.
