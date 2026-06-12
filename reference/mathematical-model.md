# Recov — Mathematical Model

> **In one paragraph.** Conventional training reasons in discrete containers — "splits,"
> "sessions," "push/pull/legs days," "sets per week." Recov throws those out and models
> training as a **continuous-time process**: a stream of sets landing at timestamps, each
> depositing stimulus and fatigue into per-muscle state variables that decay by *published
> kinetics*. At any instant it answers one question — **what is the most effective next set,
> right now?** — by ranking every exercise 0–100%. The engine is a **fitness-fatigue /
> impulse-response dynamical system** (Banister → Busso lineage) specialized to **hypertrophy**
> and resolved to **17 muscles**: "effectiveness" weighs each muscle's accumulated **stimulus
> debt** against its current **fatigue**, across two handed-off timescales (damage *days* →
> adaptation *weeks*) plus a shared systemic channel. *(A third, minutes-scale acute timescale
> was considered and declined — §1.10 #1; the within-bout behavior it would add is already
> carried by dose-response concavity and per-set accumulation.)* Constants are **taken from the empirical literature where
> it exists and explicitly guessed where it doesn't** — the rigor lives in the *structure* and in
> keeping every assumption visible, not in pretending to data we lack. It is a **population-level**
> recommender: no per-user fitting (individual override is a future UI concern). The payoff is a
> system that can say "do this set now" without ever invoking the concept of a "leg day."
>
> **Operationally:** input = a history of `(set, timestamp[, reps, load, RIR])`; output = a
> real-time 0–100% efficiency ranking over every exercise in `free-exercise-db_exercises.json`,
> for hypertrophy.
>
> **Status.** Living design doc, intentionally staged. Section 1 maps the *parameter space* and
> the open forks **without** committing to a single objective function; later sections narrow.
> The unresolved decisions are consolidated in **§1.11** — start there on return.

---

## Scope & decisions locked so far

These were decided up front; they constrain everything below.

| Decision | Choice | Consequence for the model |
|---|---|---|
| Adaptation target | **Hypertrophy** (not strength) | Use the *fractional*-set volume scheme; use the hypertrophy dose-response forms, not the strength ones. |
| Output | Rank **all** exercises, **0–100% efficiency, real time** | The objective must be evaluable instantaneously from current state, for every exercise, and be normalizable to [0,1]. |
| Time resolution | **Continuous, day-scale kernels** — explicitly *replaces* the "session" / "PPL day" unit | `Δt` is a continuous real; nothing buckets by calendar. "Right now" can mean mid-workout, but within-bout *minutes* are deliberately **not** resolved — concavity + per-set accumulation already cover the within-bout behavior (acute layer declined, §1.10 #1). |
| Per-exercise differentiation | **None** — direct/indirect (fractional) sets only | No exercise-specific *stimulus* (length/ROM/profile): precision exceeds user-input fidelity and is likely more individual than population. Exercise-specific *fatigue* (systemic) is wanted — see §1.10. |
| Input log fidelity | **Full set detail** target (exercise, timestamp, reps, load, RIR/RPE); possible minimal fallback (exercise, timestamp, RPE) | Every per-set quantity below must *degrade gracefully* when reps/load/RIR are missing. |
| Muscle granularity | **Exercise-DB native (17 muscles)** | State is tracked per-muscle over these 17. RP landmarks (12 groups) are mapped *onto* these 17, not vice versa. |
| "Efficiency" objective | **Not yet pinned down** — compound metric | Section 1 keeps recovery and stimulus-debt as *separate axes* (see §1.0). Section ≥2 will commit. |
| Personalization | **None in v1** — population-level recommendation only | All time constants and gains are *set from the population literature, never fit per user.* Sidesteps ill-conditioned per-subject fitting (see §1.8). User-judgment override is a future UI concern, out of scope here. |

The 17 muscle units (from `free-exercise-db_mover-map.csv`):
`abdominals, abductors, adductors, biceps, calves, chest, forearms, glutes,
hamstrings, lats, lower back, middle back, neck, quadriceps, shoulders, traps,
triceps`.

---

# Section 1 — Taxonomy of parameters

## 1.0 The central design tension (read this first)

The naïve objective is **"rank by how recovered the involved muscles are."** It is
wrong on its own, and the reason it's wrong defines the whole parameter space:

> *If you haven't trained calves in 3 weeks, they are as "recovered" as biceps you
> trained a week ago — yet calves should rank higher, because they are
> **underworked** relative to their weekly target.*

So there are **two distinct state axes** per muscle, with different time constants
and different reference points:

- **Axis A — Recovery readiness** (fast, days). "Has the tissue repaired enough that
  a new stimulus will be productive rather than just additive damage?" Reference
  point: full recovery (= 0 residual fatigue). Driven by **fatigue/damage**
  dynamics (§1.3, §1.4).
- **Axis B — Stimulus debt / dose opportunity** (slow, ~week). "Is this muscle below
  the weekly volume that drives growth — i.e., is there *unclaimed* stimulus to
  give?" Reference point: the **weekly volume landmarks** MEV→MAV→MRV (§1.5).
  Driven by **accumulated recent volume** vs. target.

A muscle 3 weeks rested scores high on **both** axes (fully recovered **and** deep
in stimulus debt) → high efficiency. A muscle trained yesterday to MRV scores low on
both. A muscle trained lightly 4 days ago is recovered (A high) but may already be
near its weekly target (B low). The model must hold A and B separately and only
**combine them in the objective layer (§1.6)** — they are not the same quantity and
must not be collapsed prematurely.

The **fitness-fatigue (impulse-response) model** is attractive precisely because its
two state variables map onto these two axes (slow "fitness" ↔ accumulated stimulus,
fast "fatigue" ↔ recovery deficit). See §1.3 and the collapse map (§1.7).

---

## 1.1 Layered structure of the parameter space

Parameters fall into six layers. Data flows top to bottom; the objective reads the
bottom state.

```
 L0  INPUT          per-set log primitives          (exercise, t, reps, load, RIR)
        │
 L1  ATTRIBUTION    exercise → per-muscle shares     a_{e,m}   (mover map + EMG)
        │
 L2  PER-SET DOSE   one set → stimulus & fatdamage   s_set, d_set  (effective volume)
        │
 L3  DYNAMICS       convolve history over time       G_m(t), H_m(t)  (FF / recovery)
        │
 L4  DOSE-RESPONSE  accumulated volume → adaptation   f(V)  (log / root, landmarks)
        │
 L5  OBJECTIVE      state → 0–100% per exercise       η_e(t)   (the readout)
```

The remaining subsections enumerate the parameters of each layer: **symbol,
meaning, source, timescale/units, and how it can be simplified or collapsed.**

---

## 1.2 Layer L0–L1 — Input primitives & muscle attribution

### L0 — per-set log primitives
For each logged set *i*: exercise `e_i`, timestamp `t_i`, and (when available)
reps `r_i`, load `L_i` (relative to e.g. 1RM or bodyweight), and proximity to
failure `RIR_i` (reps in reserve) or `RPE_i`.

| Symbol | Meaning | If missing (minimal-log fallback) |
|---|---|---|
| `e_i`, `t_i` | which exercise, when | always present |
| `r_i`, `L_i` | reps, load | assume a "working set" prior (e.g. 8–12 reps at hypertrophy load); collapses L2 to a constant per set |
| `RIR_i` / `RPE_i` | failure proximity | assume fixed RIR (e.g. 1–3); removes the effective-rep modulation in L2 |

### L1 — attribution coefficients `a_{e,m}`
The fraction of a set of exercise `e` that "counts" toward muscle `m`.

| Symbol | Meaning | Source | Notes / collapse |
|---|---|---|---|
| `a_{e,m}` | per-muscle credit of exercise `e` for muscle `m`, `m ∈ 17` | `free-exercise-db_mover-map.csv` (direct/indirect) + EMG cluster | **Baseline (fractional scheme):** direct muscle → 1.0, indirect → 0.5, else 0. This is the empirically-favored weighting (see L4). |
| EMG refinement | replace the flat 0.5/1.0 with relative activation | `*_emg-*` papers (Lehman, Rodriguez-Ridao, Martin-Fuentes, Clark, Saeterbakken) | **Caveat (Vigotsky-2018): EMG amplitude is ordinal, not a literal multiplier.** Cross-exercise, cross-muscle, cross-study sEMG amplitudes cannot be read as proportional hypertrophy contribution (normalization, cross-talk, MU pool differences). Use EMG only to *re-rank/perturb* the {1.0, 0.5} priors within an exercise, never as ground-truth gains. |

**Collapse:** the simplest defensible `a_{e,m}` is the **binary fractional map**
(direct=1, indirect=0.5). EMG is a *second-order correction* that we may not need for
a first model. `a_{e,m}` is the only place exercise identity enters the dynamics —
everything downstream is per-muscle.

---

## 1.3 Layer L3 — Dynamic state (the fitness-fatigue backbone)

Source: `Clarke-2013` (Banister impulse-response / IR model), `Busso-2003` (variable
dose-response extension). This is the engine that turns a *history* into a
*current state*. The IR model, **per muscle**:

```
p_m(t) = p_m(0) + k1 · G_m(t) − k2 · H_m(t)

G_m(t) = Σ_i a_{e_i,m} · w_i · e^{−(t − t_i)/τ1}      (fitness / accumulated stimulus, SLOW)
H_m(t) = Σ_i a_{e_i,m} · w_i · e^{−(t − t_i)/τ2}      (fatigue / recovery deficit,  FAST)
```

with `w_i` the per-set training impulse (= L2 dose), and the recursion form
`g(t)=g(t−Δ)e^{−Δ/τ1}+w`, `h(t)=h(t−Δ)e^{−Δ/τ2}+w` for cheap real-time updates.

| Symbol | Meaning | Typical value (source) | Role / axis |
|---|---|---|---|
| `τ1` | fitness (slow) time constant | ~27–45 d (Clarke Fig.6 uses τ1=27) | **Axis B** carrier — slow accumulation/decay of trained stimulus |
| `τ2` | fatigue (fast) time constant | ~10–15 d global (Clarke); **for local hypertrophy, must be retuned to per-muscle recovery, ~1–5 d, see §1.4** | **Axis A** carrier — recovery deficit |
| `k1` | fitness gain | model-fit, AU | weights Axis B |
| `k2` | fatigue gain | model-fit, AU (`k2>k1` so fatigue dominates early) | weights Axis A |
| `p_m(0)` | baseline capacity | per-muscle | offset; may drop out under normalization |
| `w_i` | training impulse of set *i* | = L2 `s_set`/`d_set` | the "dose" injected |

**Two crucial adaptations of the textbook IR model for our problem:**

1. **It must be per-muscle and stimulus-localized**, not a single global "performance"
   scalar. `G_m, H_m` are indexed by muscle and fed by `a_{e_i,m}`.
2. **The classic τ2 (~15 d) is for global endurance performance, not local muscle
   recovery.** For hypertrophy training, the relevant fatigue is local damage/repair,
   which resolves in **~1–5 days** (§1.4). So τ2 is re-anchored to the EIMD literature,
   and the fitness/fatigue *gains and time constants likely depend on the dose itself*
   (Busso-2003: `k2` is not constant — large doses produce disproportionate,
   longer-lasting fatigue → captures "junk volume"/overreaching).

**Variable dose-response (Busso-2003) — the nonlinearity that matters.**
`k2 → k2(t)` accumulates with recent training magnitude, so the marginal fatigue cost
of a set rises when you're already buried. This is what makes a set *unproductive*
past MRV even though the linear model would still credit it. Whether we need the full
Busso machinery or can approximate it with a saturating L4 + a per-muscle MRV cap
(§1.5) is an open simplification question.

**Mapping to the two axes:**
- Axis A (recovery readiness) `≈ 1 − k2·H_m(t)/(normalizer)` — high when fast fatigue
  has decayed.
- Axis B (stimulus debt) is **not** simply `G_m`. `G_m` is *accumulated stimulus*; debt
  is *target − recent accumulation*. The cleanest formulation routes Axis B through
  the **weekly-volume landmarks** (§1.5), using a short rolling window rather than the
  τ1 exponential. We keep both candidate encodings of Axis B open (slow-FF-state vs.
  rolling-volume-vs-landmark) — see §1.7 collapse map.

---

## 1.4 Layer L3 — Recovery / muscle-damage kinetics (sets τ2 and the productivity gate)

Sources: `Damas-2015` (MPS), `Paulsen-2012`, `Howatson-2008` (EIMD).

These papers don't give one clean ODE; they give the **shape and timescale** of the
fast (fatigue/recovery) component and a key gating idea.

| Phenomenon | Parameter it informs | Value / shape | Source |
|---|---|---|---|
| Myofibrillar **MPS elevation window** after a session | the productive "stimulus is still being converted" window | elevated ~**24–48 h** (trained state); longer but partly damage-directed in untrained | Damas-2015 |
| **Training-status modulation** (repeated-bout) | makes `k1,k2,τ2` *non-stationary* — damage shrinks, MPS becomes growth-directed as a muscle becomes trained | qualitative; argues against fixed constants for a beginner | Damas-2015, Howatson-2008 |
| **EIMD magnitude** scales with eccentric load & **novelty** | per-set damage `d_set` modifier; novel/eccentric-biased exercises cost more | force deficit, soreness, CK rise | Howatson-2008, Paulsen-2012 |
| **Recovery time course** of force/soreness | τ2 anchor | hours → **>1 week** depending on damage magnitude; typical trained session ~**1–5 d** | Paulsen-2012, Howatson-2008 |

**Key modeling idea — a productivity gate, not just additive fatigue.** Damas implies
the *first* exposures spend MPS on repair (low net growth), and that very high
per-session damage doesn't buy proportional growth. This supports treating Axis A as a
**gate/efficiency multiplier on stimulus**, not merely a subtractive fatigue term: a
set landing on an unrecovered muscle yields *less* hypertrophy per unit volume. That is
a structurally different combination of A and B than the IR model's simple subtraction,
and is one of the main objective-design choices for Section 2.

---

## 1.5 Layer L4 — Volume landmarks & dose-response transfer (Axis B reference points)

This layer turns *accumulated fractional volume per muscle per week* into *expected
hypertrophy*, and supplies the reference points that define stimulus debt.

### Volume landmarks (the reference scale for Axis B)
Source: `RP-volume-landmarks_current.csv` (practitioner data, **not peer-reviewed** —
flagged). Per muscle, weekly **direct-set** counts:

| Landmark | Meaning | Role in model |
|---|---|---|
| **MV** | maintenance volume | floor below which a muscle detrains |
| **MEV** | minimum *effective* volume | below this → in "stimulus debt" (Axis B high) |
| **MAV** | maximum *adaptive* volume | the productive sweet spot; growth per set peaks then diminishes |
| **MRV** | maximum *recoverable* volume | weekly ceiling; sets beyond ≈ junk/negative (ties to Busso k2 blow-up) |

These are RP's **12 groups**; they must be mapped onto our **17 DB muscles** (one-to-
many, e.g. RP "Back" → lats + middle back + lower back; RP "Rear/Side Delts" + "Front
Delts" → shoulders). That mapping table is a deliverable for §2. RP counts are
*direct sets*; reconcile with our fractional `a_{e,m}` before comparing.

### Dose-response functional forms (volume → hypertrophy)
Sources: `Remmert-2024` (per-session), `Pelland-2024` (weekly),
`Schoenfeld-2017_weekly-volume`, `Baz-Valle-2021/2022`, `Currier-2023`. Caveats from
`Buckner-2023`, `Nuckols-2022` (diminishing returns / doubts).

| Dose variable | Best-fit form | Saturation point (PUOS) | Source |
|---|---|---|---|
| **Per-session** fractional sets → hypertrophy | **linear-log** (logarithmic; `Δ ∝ ln(V)`), slope β≈0.39%/log-unit | ≈ **11 fractional sets / session** | Remmert-2024 |
| **Weekly** fractional sets → hypertrophy | **root** (≈√V) | ≈ **31 fractional sets / week** | Pelland-2024 |
| Indirect-set contribution | **fractional ≈ 0.5** (direct=1) is the best-supported weighting for hypertrophy | — | Remmert-2024, Pelland-2024 (Mannarino: biceps +11% vs rows +5% ≈ 2:1) |

**Both forms are concave (diminishing returns).** Concavity is the mathematical
embodiment of "underworked muscles are worth more per set": the marginal value of the
*next* set is the **derivative** of the dose-response, evaluated at the muscle's
current accumulated volume. That derivative *is* a clean, unified definition of Axis B:

```
marginal_value_m  =  f'(V_m^{week})     with f concave (root / log)
```

so a muscle near 0 weekly sets has a large `f'` (steep, underworked) and one near MRV
has `f' ≈ 0` (saturated). This is the single most important collapse in the document:
**the "stimulus debt" axis and the "diminishing-returns dose-response" are the same
object — the marginal value is the slope of the dose-response curve.**

| Symbol | Meaning | Source |
|---|---|---|
| `f_session(V)`, `f_week(V)` | dose-response (log / root) | Remmert, Pelland |
| `V_m^{session}`, `V_m^{week}` | accumulated fractional sets for muscle `m` in rolling session/week window | derived from L0–L2 |
| `f'(V)` | **marginal value of next set** = Axis B | derivative of above |
| PUOS, MAV/MRV | saturation / ceiling clamps | Remmert/Pelland, RP |

---

## 1.6 Layer L2 — Per-set dose magnitude (the impulse `w_i`)

Sits between L1 and L3: converts one logged set into the impulse injected into the
dynamics. This is where reps/load/RIR matter, and where the log-fidelity fallback
bites.

| Symbol | Meaning | Driver | Fallback if log is minimal |
|---|---|---|---|
| `s_set` (stimulus impulse) | growth-relevant dose of one set | mostly **= 1 fractional set** (volume is counted in *sets*, per Baz-Valle-2021), modulated by proximity to failure | = 1 (a set is a set) |
| effective-reps / RIR modifier | sets far from failure give less stimulus | `RIR_i`; stimulatory reps ≈ last ~5 before failure | assume fixed RIR prior |
| load/rep modifier | hypertrophy is load-robust across ~30–80% 1RM if near failure | `L_i, r_i` (`Schoenfeld-2017_low-vs-high-load`) | none needed — load matters little for hypertrophy volume if taken near failure |
| `d_set` (damage impulse) | fatigue/EIMD cost of one set | eccentric bias, novelty, range; **load ≈ neutral at matched volume** (`Winchester-2022`) | = `s_set` (cost ∝ stimulus) as crudest collapse — defensible for the slow layer |

**Important simplification supported by the literature:** for *hypertrophy*, the
primary volume currency is the **(fractional) set**, not volume-load
(`Baz-Valle-2021`), and load is interchangeable across a wide range if sets are taken
near failure (`Schoenfeld-2017_low-vs-high-load`). So **`s_set ≈ a_{e,m}` with only a
mild RIR modifier** is a strongly defensible first model — reps and load can be
collapsed out, which is exactly what makes the *minimal* (exercise+timestamp+RPE) log
viable. RIR/RPE is the one per-set detail worth keeping.

---

## 1.7 Collapse map — how the parameters reduce into each other

The point of this taxonomy is to expose redundancy. Candidate collapses, strongest
first:

1. **Marginal value ≡ dose-response slope.** Axis B ("stimulus debt / underwork") does
   **not** need a separate parameter set — it is `f'(V_m^{week})`, the derivative of the
   concave Pelland/Remmert curve at the muscle's current weekly volume. MEV/MAV/MRV are
   just labeled points on that same curve. *(§1.5)*

2. **Per-set dose collapses to the fractional attribution.** `w_i = s_set ≈ a_{e_i,m}`
   (set-counting + fractional scheme), with at most a single RIR multiplier. Reps and
   load drop out for hypertrophy. → L0, L1, L2 fold into one number per (set, muscle).
   *(§1.2, §1.6)*

3. **Fitness-fatigue's two states ≈ the two axes** — *partially*. The fast state
   `H_m(t)` (with τ2 re-anchored to EIMD, ~1–5 d) is a good encoding of **Axis A
   (recovery)**. The slow state `G_m(t)` is *accumulated stimulus*, which is related to
   but **not identical** to Axis B; Axis B is better read off the dose-response slope
   (#1). So we likely keep `H_m` from the IR model for recovery and get Axis B from L4,
   rather than running the full two-component IR convolution. This is the biggest open
   structural choice. *(§1.3, §1.5)*

4. **Damage ≈ stimulus, to first order.** `d_set ≈ s_set` unless we add eccentric/novelty
   modifiers from Howatson/Paulsen. Lets Axis A be driven by the same impulse as Axis B.
   *Empirically reinforced for the slow layer (2026-06 review):* `Winchester-2022` found
   **structural damage (myoglobin) load-insensitive at matched volume** (85% ≈ 67% 1RM,
   between-condition p≈1.0), i.e. EIMD tracks *volume*, not load. The load/rep fatigue effect of
   `Pareja-Blanco-2019` (lighter+more-reps → more fatigue) **dissociates** from structural damage
   and belongs to a **fast acute neuromuscular layer**, not the days-scale `d_set`. So keep
   `d_set ≈ volume` on the slow layer; the load/rep fatigue term *would* have lived in the acute
   kernel — which we have **declined** (§1.10 #1) — so it is **dropped**, not relocated. This is
   consistent: it is a minutes-scale effect, below the resolution we model, and its within-bout
   consequence is already covered by per-set accumulation.
   *(§1.4, §1.6)*

5. **EMG folds away.** Drop EMG entirely in v1; `a_{e,m} ∈ {0, 0.5, 1}`. Re-introduce
   only as bounded perturbations later, honoring Vigotsky. *(§1.2)*

6. **Subtractive vs. gated combination is NOT a collapse — it's the fork.** The IR model
   combines fitness and fatigue by *subtraction* (`k1 G − k2 H`). Damas-2015 motivates a
   *multiplicative gate* (recovery scales how much of the available stimulus debt you can
   actually convert). These give different rankings and §2 must choose. *(§1.4, §1.6)*

**Minimal viable parameter set** implied by the collapses above (one realization, to be
debated in §2):

```
per muscle m, at time t:
  V_m^{week}(t)   = Σ_{i: t−7d < t_i ≤ t}  a_{e_i,m} · rir_mod(RIR_i)      # rolling fractional weekly volume
  H_m(t)          = Σ_i a_{e_i,m} · e^{−(t − t_i)/τ2}                       # recovery deficit, τ2 ~ 2–4 d
  Recovery_m(t)   = exp(−H_m(t))               ∈ (0,1]                      # Axis A
  Marginal_m(t)   = f'(V_m^{week})  clamped by MEV..MRV                     # Axis B (dose-response slope)

per exercise e:
  η_e(t) = combine_m∈e ( a_{e,m},  Recovery_m,  Marginal_m )   → normalize to 0–100%
```

The **`combine` operator and the Recovery×Marginal interaction (subtract? multiply?
gate?)** are exactly what Section 2 will resolve, along with the τ2 value, the RP→17
muscle map, and whether Busso's non-stationary `k2` is needed.

---

## 1.8 Beyond linear convolution: negativity and clustering

The base model of §1.7 is a **linear convolution** per muscle —
`V_eff_m(t) = Σ_i a_{e_i,m}·κ(t − t_i)`, `marginal_m(t) = f'(V_eff_m(t))`. Two
properties of that form bound what it can express, and they are exactly the two
features under discussion:

- **Monotone** (`κ ≥ 0`, `f' > 0`): the score is always ≥ 0 and can never transiently
  dip below zero → no "counterproductive" regime.
- **Superposition** (each set's effect is independent of every other): no interaction
  between sets → "10 sets at once" = "10 sets spread out" at equal lag → no clustering.

Both limits are escaped by the same move — leaving the linear-convolution world — and
**Busso-2003 supplies both canonical mechanisms.** Both are added as **off-by-default
knobs**: v1 may ship with both at zero (pure stimulus-debt ranking), and they only ever
*refine* the ranking.

### Negativity — a transient counterproductive window
A single monotone-decaying state **cannot** change sign; a dip-then-recover requires
**two time constants** whose difference crosses zero. Busso writes the single-bout
*influence kernel* as the difference of two exponentials (his Eq. 10):

```
E(Δ) = k1·e^{−Δ/τ1} − k2·e^{−Δ/τ2}        (Δ = t − t_i, lag since the set)
```

biphasic for `τ1 > τ2`, `k2 > k1`: negative at short lag, single zero-crossing at

```
t_n = [τ1·τ2 / (τ1 − τ2)] · ln(k2/k1)      (Eq. 7)
```

then positive. `t_n` is the soonest a muscle's last bout becomes net-positive to
retrain — a *derived* "don't recommend yet" gate. In our framing, keep the concave
benefit and add **one fast subtractive state**:

```
value_m(t) = f'(V_eff_m(t)) − λ0·D_m(t),     D_m(t) = Σ_i a_{e_i,m}·e^{−(t − t_i)/τ_fast}
```

`D_m` is one extra scalar EMA per muscle; `τ_fast ≈` EIMD recovery (~1–3 d). `λ0 = 0`
→ pure "meh" ranking; `λ0 > 0` → score dips negative right after a bout and climbs back
to `f'(V_eff)` as `D` decays. (Benefit stays a separate term rather than folding into
one biphasic kernel, because `f'` is nonlinear in volume; Busso's clean single-kernel
form assumes *linear* benefit.)

### Clustering — super-additive fatigue (the literature math)
Breaking superposition requires nonlinearity in the history. Busso's mechanism: make
the fatigue **gain itself a state variable** tracking recent load (Eq. 4–5):

```
p̂_n = p* + k1·Σ_i w^i e^{−(n−i)/τ1} − Σ_i k2^i·w^i e^{−(n−i)/τ2}      (4)
k2^i = k3·Σ_{j≤i} w^j e^{−(i−j)/τ3}                                    (5)
```

Substituting (5) into (4) makes the fatigue term **bilinear** in history:

```
fatigue ∝ k3·Σ_i Σ_j w^i·w^j·e^{−(i−j)/τ3}·e^{−(n−i)/τ2}
```

The cross-terms `w^i·w^j` are large when sessions `i, j` fall within `τ3` of each
other — **that double sum *is* the clustering.** Busso fit `τ3 ≈ 2 d` (vs `τ2 ≈ 17`,
`τ1 ≈ 30`); `τ3` is the "sensitization" timescale: how long one session amplifies the
fatigue cost of the next. In our framing, let the penalty gain ride a **third EMA**:

```
C_m(t) = Σ_i a_{e_i,m}·e^{−(t − t_i)/τ3}        ("recent-load sensitizer", medium τ3)
```

### Unified nested form
```
value_m(t) = f'(V_eff_m(t)) − (λ0 + k3·C_m(t))·D_m(t)
```

Three scalar EMAs per muscle (`V_eff` slow, `C` medium-`τ3`, `D` fast-`τ_fast`). The
product `C_m·D_m` is the minimal nonlinearity that makes "10 sets at once ≠ spread
out." The two knobs nest cleanly and **degrade back to the §1.7 single-variable model**:

| `λ0` | `k3` | Model |
|---|---|---|
| 0 | 0 | pure stimulus debt (one effective state, **no combine operator**) |
| >0 | 0 | constant-gain negativity, no clustering |
| 0 | >0 | Busso clustering (super-additive fatigue) |
| >0 | >0 | full |

This resolves the "subtract vs. gate" fork flagged in §1.7 #6: the *benefit* is read
off the dose-response slope (stimulus debt), and fatigue enters as a **subtractive,
clustering-amplified penalty** — not a multiplicative gate on the benefit. (A gate
remains a viable alternative for §2 if the Damas "convert-vs-add-damage" reading is
preferred; the two differ when both terms are mid-range.)

### v1 stance — population-level, no personalization
Every constant here (`τ_slow, τ_fast, τ3, λ0, k3`, and the `f` forms) is **set from the
population literature, never fit per user.** This is a deliberate scope choice and a
mathematical convenience: per-subject fitness-fatigue fits are famously ill-conditioned
(Busso et al. report improved fit but unstable parameters), and we avoid that entirely.
Sources: `τ_fast, τ3` from EIMD/MPS kinetics (Howatson, Paulsen, Damas); `f_session` =
log/PUOS≈11 and `f_week` = root/PUOS≈31 from Remmert/Pelland; landmarks from RP. **For
ranking alone, `λ0 = 0` is defensible** (low marginal value already de-prioritizes a
just-trained muscle); negativity and clustering are opt-in refinements.

### Empirical fingerprint of clustering in our own sources
If sets were purely additive, weekly and per-session dose-response would be the *same*
curve up to a frequency rescaling. They are not: Pelland (weekly) best-fits a **root**,
Remmert (per-session) a **log**, and Remmert finds a per-session saturation (~11)
distinct from the weekly one (~31). That divergence — plus Schoenfeld-2019's frequency
benefit at equated volume — is the empirical signature of a per-session nonlinearity,
i.e. clustering. `τ3` is the parameter that reconciles the two dose-response papers.

### Alternatives to Busso's bilinear gain (largely equivalent)
- **(b) dose-dependent recovery rate:** `dD/dt = −D/τ(D) + input` with `τ(D)` increasing
  in `D` — recovery capacity gets overwhelmed. More physiological, but no closed form and
  no support in the current reference set.
- **(c) per-session pre-aggregation:** bundle a session's sets into a session dose and
  apply a convex damage `g(session_dose)` before injection.

Both are reparameterizations of the *same* nonlinearity (history-dependent fatigue) and
coincide with (a) in the regimes we care about; **(a) is preferred as the
literature-backed, cheapest form.**

---

## 1.9 Parameter master list (quick reference)

| Param | Layer | Axis | Source | Status |
|---|---|---|---|---|
| `a_{e,m}` direct=1/indirect=0.5 | L1 | both | mover-map + Remmert/Pelland | baseline locked |
| EMG perturbation to `a_{e,m}` | L1 | both | EMG cluster (ordinal only) | deferred (Vigotsky caveat) |
| `s_set` (≈1 set), RIR modifier | L2 | B | Baz-Valle, Schoenfeld load study | baseline locked |
| `d_set` (damage), eccentric/novelty mod; **load-neutral at matched volume** | L2 | A | Howatson, Paulsen, Winchester-2022 | optional modifier; `d_set ≈ volume` on slow layer |
| `τ1` fitness time const (~27–45 d) | L3 | B | Clarke | maybe unused (see collapse #3) |
| `τ2` fatigue time const (**~1–5 d**, retuned) | L3 | A | Clarke + Paulsen/Howatson | needs fitting |
| `k1, k2` gains; `k2(t)` non-stationary | L3 | A/B | Clarke, Busso | open (Busso optional) |
| MPS window ~24–48 h; training-status drift | L3 | A | Damas | informs gate idea |
| MV/MEV/MAV/MRV per muscle | L4 | B | RP (non-peer-reviewed) | locked as scale; needs 12→17 map |
| `f_session` = log, PUOS≈11; `f_week` = root, PUOS≈31 | L4 | B | Remmert, Pelland | locked |
| `f'(V)` marginal value | L4 | B | derivative of above | core of Axis B |
| `D_m`, `τ_fast` (fast damage EMA) | L3 | A | Busso Eq.10; Paulsen/Howatson | enables negativity (`λ0>0`) |
| `λ0` (acute penalty weight) | L5 | A | Busso/design | **0 in v1** (ranking ok); knob |
| `C_m`, `τ3` (sensitizer EMA) | L3 | A | Busso Eq.5 (`τ3≈2 d`) | enables clustering (`k3>0`) |
| `k3` (clustering gain) | L5 | A | Busso Eq.5 | **0 in v1**; knob |
| `combine` operator + A×B interaction | L5 | — | §1.8 (subtractive penalty) vs gate | partly resolved; gate still open for §2 |

---

## 1.10 Known gaps & integration backlog

Tracked so they aren't lost. One is **in scope and needs building** (systemic `S`); the rest are
**deliberately deferred or declined** (recorded so the decision is explicit, not silent).

### Decided out — the minutes-scale acute layer (DECLINED by design, 2026-06)
1. **Sub-session / acute fatigue layer — DECLINED, not deferred.** Earlier drafts had this
   in scope: dissolving the "session" as a unit seemed to *require* an acute (minutes-scale)
   fatigue kernel on top of the days-scale `D_m` — a third faster timescale (`τ_acute` ~ minutes,
   the W′-recharge layer from the CP model, Clarke-2013 `W'` half-time ~3.5 min, plus set-to-set
   decrement data: `Pareja-Blanco-2019`, `Jukic-2023`, `Refalo-2023_neuromuscular-fatigue`).
   *On review we are dropping it entirely.* The decision turns on what such a channel would
   actually add to the **ranking**, item by item:
   - **Within-bout diminishing returns** ("set 5 is worth less than set 1") are already supplied
     by the **concavity of `f`** — each set lands on a higher `V_eff`, so `f'(V_eff)` falls. No
     fast-decaying state is needed for "the more you've done, the less the next is worth."
   - **"You just hammered this muscle, move on"** is already supplied by the **slow channels
     accumulating per set**: every logged set raises `D_m` (recovery gate shrinks) and `V_eff,m`
     (marginal value shrinks). In the §model.md worked example this alone drives bench to last
     (9%) after five sets — the within-bout "stop flogging this" behavior is emergent, not added.
   - **The only thing genuinely lost** is *minute-resolution recovery within a bout* (a muscle
     worked 20 min ago vs 2 min ago) — a distinction below the granularity any user acts on;
     actionable recovery is hours–days, which `τ_fast` already resolves.

   And critically, omitting it does **not** re-introduce "days": `Δt` stays a continuous real,
   nothing buckets by calendar, floating sets stay the native input — we simply decline to
   *resolve* minutes. That keeps the state count minimal (Imbach: a fourth `τ_acute` component
   is exactly the poorly-identifiable kind we'd be fitting from priors, not data). So the
   double-count and timescale-separation worries (§1.11 #8) don't get *managed* — they're
   **removed**. The `Zahiri-2024` cross-muscle timing (τ≈1–3 min, gone by 5) and the
   same-muscle decrement data still stand as evidence; they just no longer motivate a state,
   because the ranking already behaves correctly without one.

### In scope — to be modeled (v1 or fast-follow)
2. **Global / systemic per-exercise fatigue (WANTED — data is the bottleneck).** There is a
   **session-level productivity cap that spans muscles** (a hard leg session degrades an
   unrelated push). The model is currently 17 *independent* per-muscle channels; this adds a
   single shared "systemic fatigue" state `S(t)` that every set feeds (weighted by the
   exercise's systemic cost) and that discounts *all* exercises' scores while elevated.
   Sources now in repo: `Zając-2015` (central vs peripheral fatigue), `Sousa-2024` (grades
   exercises by recovery cost: multi-joint / lower-body / eccentric cost more).
   *Reframed (2026-06 review) — split `S` into two timescales, because the non-local-fatigue
   evidence (`Behm-2021` meta, `Zahiri-2024`) reshapes it:*
   - **Acute cross-muscle `S` ≈ negligible, and is NOT a force effect.** Crossover to a non-exercised
     muscle is *trivial* for strength (+0.11) and power (−0.01); it is only moderate for
     **endurance / reps-to-failure** (−0.54), which *is* the currency we care about (a working set is
     a reps-to-failure task). But it is (a) **not moderated by fatigue severity, homologous/heterologous,
     or upper/lower body** — so it can't be a clean exercise-cost-scaled term — (b) attributed to
     **perceived effort**, not a force deficit, and (c) gone within ~5 min (`Zahiri-2024`). ⇒ model it,
     if at all, as a **small, flat discount on *achievable volume*** (sets land at target RIR sooner),
     **not** as a stimulus-quality multiplier or a max-force penalty, and **not** as a cross-channel
     force coupling.
   - **Between-session `S` is the real #9 — now committed to Shape B.** "Hard leg day degrades tomorrow's
     push" is a *recovery-resource* competition over days (`Sousa-2024`), a different mechanism from
     acute crossover — the NLMF papers mostly *rule out* acute crossover as its cause. Here the
     exercise-specific cost ordering (squat ≫ leg curl) *does* apply. **Committed form (2026-06):** one
     global state `S(t) = Σ c_e e^{−Δt/τ_sys}` reading out as a **cost-aware multiplicative gate**
     `exp(−κ·c_e·S)` on each candidate's score — *not* a flat `e^{−S}` dimmer. The distinction is the
     whole point: a flat global factor scales every exercise equally and so **cannot reorder a
     single-instant ranking** (it only lowers the ceiling); the cost-aware gate penalizes a candidate by
     *its own* `c_e`, so when systemically depleted the model **steers toward low-cost work** (the
     "big compound(s) + accessories" structure practitioners already use). The same `c_e` does double
     duty — the dose a set deposits into `S` *and* the cost it is charged at ranking. Inert when fresh
     (`S→0`); `κ→0` recovers a pure per-muscle model.
   **Structural precedent (not hypertrophy-specific):** the training-load-monitoring lineage —
   session-RPE (`Foster`), Banister `TRIMP`, and the **acute:chronic workload ratio** — is exactly this
   shape: an exponentially-weighted accumulator of per-session systemic cost used to gate subsequent
   work, with an ~7 d acute window. It validates the *form* and offers a `τ_sys` convention; it does
   **not** supply a hypertrophy-tuned `c_e` or `κ`.
   **Gap (constants only):** the per-exercise `c_e` cost table, `κ`, and `τ_sys`. No clean kinetics
   exist; set from the `Sousa-2024` ordering + a hand-chosen modest `κ`, revisit if the absolute-ceiling
   behavior across days looks wrong. The *shape* is no longer open.
3. **RIR modifier shape for L2 (refine).** The per-set stimulus modifier is concave and
   plateaus by ~1–2 RIR (`Refalo-2023` meta, small effect ES≈0.15–0.21) — replace the
   placeholder "mild RIR multiplier" with this published shape.
4. **RP-12 → DB-17 muscle map.** Still owed (one-to-many; e.g. RP "Back" → lats + middle back
   + lower back). Needed to use MEV/MAV/MRV as ceilings at our muscle resolution.

### Deferred / declined (explicit non-goals)
- **Per-exercise *stimulus* differentiation** (muscle length, ROM, resistance profile,
  lengthened partials, "effective/stimulating reps"): **declined for v1.** Precision exceeds
  typical user-input fidelity; differences are likely more individual than population. Model
  stays on direct/indirect (fractional) sets. *(Distinct from per-exercise systemic **fatigue**,
  which is in scope above.)*
- **Bottom-up mechanobiological ODEs** (IGF1-AKT-mTOR signaling → growth tensor): out of scope
  — needs molecular parameters; our model is top-down/empirical.
- **Early-training damage regime** (Damas-2016: week-1 MyoPS is damage-directed, not growth):
  declared **out of scope** under the population/trained-user assumption — stated, not inherited.
- **Physique-goal weighting** of the objective: out of scope; the readout implicitly maximizes
  balanced total hypertrophy. (Future UI-side user override, per project scope.)

### Backbone risk to revisit before §2 commits
- **FF identifiability / alternative forms.** `Imbach-2022` documents that two-component FF
  models are poorly identifiable and borderline unfalsifiable when fit per subject — this
  *supports* our population-level, literature-set-parameter stance, but also flags that the IR
  backbone is contested. Alternatives to audit: an **exponential-growth** adaptation form
  (reported to fit hypertrophy better than IR in some RT data) and the **3-D / multi-channel
  IR** of `Kontro-2025`; `Herold-2021`'s **sigmoid** stimulus is an alternative to our log/root.

## 1.11 Open design questions (the nagging list) — resolve in §2

The genuinely *unresolved forks* we keep circling — distinct from §1.10 (which is build-work
and declined scope). These are decisions, each changes the rankings. Roughly ordered by how
load-bearing they are. Cross-refs point to where each is developed.

1. **What *is* "efficiency"? (the objective/readout).** Still a compound metric, not pinned.
   How do the two axes (stimulus debt, fatigue) plus systemic fatigue collapse into a single
   0–100 number? This is the central §2 task. *(→ §1.0, §1.6)*

2. **Subtract vs. gate.** Does fatigue enter as a **subtractive penalty** (`benefit − penalty`,
   Banister/Busso) or as a **multiplicative gate** on stimulus conversion (`recovery × benefit`,
   motivated by Damas: an unrecovered muscle *converts less* of the available stimulus)? They
   agree at the extremes and **diverge when both terms are mid-range.** §1.8 tentatively picks
   subtractive; the gate is still live. *(→ §1.4, §1.8 #6)*

3. **0–100% normalization: relative or absolute?** Is 100% the **best exercise available right
   now** (percentile/relative — there is always a winner, even on a fried day) or a **fixed
   absolute scale** (so a fully-fatigued day might top out at 40%)? This changes the meaning of
   the number and the UX. Not yet decided. *(→ §1.6 readout)*

4. **Axis B encoding.** Read stimulus debt off the **dose-response slope** `f'(V_eff)` (preferred,
   §1.5) or off the **FF slow state** `G_m`? Collapse #3 leans to the slope but it's not closed.
   *(→ §1.5, §1.7 #1, #3)*

5. **Negativity knob `λ0`: on in v1?** A counterproductive window needs two timescales (§1.8). For
   *ranking*, low-value may suffice and `λ0 = 0` is defensible; for *forward projection* it matters
   more. *(→ §1.8)*

6. **Clustering knob `k3`: needed, or approximated away?** Is Busso's bilinear `C·D` term required,
   or does a saturating `f` + a hard **MRV cap** reproduce "junk volume" well enough? *(→ §1.3, §1.8)*

7. **FF backbone choice (and risk).** Stick with two-component IR, or switch to an **exponential-
   growth** adaptation form (reportedly fits RT hypertrophy better), **Herold's sigmoid** stimulus,
   or **Kontro's multi-channel 3-D IR**? `Imbach-2022` warns IR is poorly identifiable — mitigated
   by our population-level stance, but the structural choice is open. *(→ §1.10 backbone risk)*

8. **Acute layer `τ_acute` + timescale separation.** **CLOSED (2026-06): no acute channel.** The
   layer is declined by design — within-bout diminishing returns are carried by the concavity of `f`,
   and "you just worked this muscle" by per-set accumulation in the slow channels, so a minutes-scale
   state would be redundant *and* unidentifiable (Imbach). Omitting it does not re-introduce "days":
   `Δt` stays continuous; we just decline to *resolve* minutes. The timescale-separation and
   double-count worries are thereby removed rather than managed. Full rationale in §1.10 #1. *(→ §1.10 #1)*

9. **Systemic fatigue `S(t)`: functional form + per-exercise cost.** **RESOLVED (2026-06): Shape B —
   a cost-aware multiplicative gate on score.** The split from the earlier review still holds: (i) the
   **acute cross-muscle** term is ≈0 for force/power and at most a small, flat perceived-effort effect
   (`Behm-2021`; gone in ~5 min) — **dropped** with the acute layer (#8); and (ii) the **between-session
   recovery-resource** term (the real cap; `Sousa-2024`) is the surviving `S`. Its form is now committed:
   a single global state `S(t) = Σ c_e e^{−Δt/τ_sys}` reading out through the **per-exercise** gate
   `exp(−κ·c_e·S)`. This closes both sub-forks: it acts on **score** (the "volume" reading belonged to
   the dropped acute piece), and the form is a **multiplicative discount** — but a *cost-aware* one, so
   it **reorders** toward low-cost work when depleted rather than dimming flatly (a flat `e^{−S}` cannot
   move a single-instant ranking; `exp(−κ c_e S)` can). Inert when fresh (`S→0 ⇒` gate `→1`); `κ→0`
   recovers the pure per-muscle model. Still open: the `c_e` cost table, `κ`, `τ_sys` (constants only —
   no data; ACWR convention ~7 d). *(→ §1.10 #2)*

10. **Effort/RIR modifier shape.** Adopt the `Refalo-2023` concave-plateau (small effect, flattens
    by ~1–2 RIR) for L2 — but how steep, and how does it interact with `d_set`? *(→ §1.6, §1.10 #3)*

11. **Minimal-log degradation.** Exactly what does "a set" deposit when only `(exercise, timestamp,
    RPE)` is logged? Confirm the fallback priors keep rankings sane. *(→ §1.6, scope table)*

12. **RP-12 → DB-17 mechanics.** The mapping table itself, *and* reconciling RP's **direct-set**
    landmarks with our **fractional** counting before using MEV/MAV/MRV as ceilings. *(→ §1.5)*

---

# Section 2 — The backbone (committed)

> **In one paragraph.** Section 1 left the *objective* open and kept circling three
> forks: fitness-fatigue state vs. dose-response slope (§1.11 #4), subtract vs. gate
> (#2), and which adaptation form is "the" backbone (#7). All three dissolve once the
> backbone is **named correctly**. It is not "the fitness-fatigue model." It is a
> **Hammerstein–Wiener / linear-nonlinear (LN) cascade**: per-muscle **leaky
> integrators** (linear convolution of the set history) feeding **static concave
> nonlinearities**, combined **multiplicatively** across parallel channels, with one
> shared systemic channel. Banister, Busso, Remmert/Pelland, exponential-growth and
> sigmoid forms are all *instances* of this cascade — they differ only in the static
> nonlinearity and the number of integrators, never in the engine. This section commits
> to that structure and to the master formula it implies. The working statement lives in
> `model.md`; this section is the *why*.

## 2.1 The backbone is an LN cascade, not "the FF model"

Every candidate spine in Section 1 starts from the **identical** operation: convolve the
per-muscle impulse train `Σ_i a_{e_i,m}·w_i·δ(t − t_i)` with a decaying exponential —
i.e. a **leaky integrator / EMA** with cheap real-time recursion (§1.3). What differs is
only what happens *after* that convolution:

| Apparent "backbone" | = same leaky integrator(s), then… |
|---|---|
| Banister IR (`Clarke-2013`) | **two** integrators, differenced, identity output |
| Busso variable-gain (`Busso-2003`) | one gain promoted to a **third** integrator → bilinear fatigue (§1.8) |
| Dose-response slope (`Remmert-2024`, `Pelland-2024`) | **one** integrator through a concave `f`, then differentiated |
| Exponential-growth (`Philippe-2019`, *missing*) | one integrator through a different concave `f` |
| Sigmoid stimulus (`Herold-2021`) | one integrator through a sigmoid `f` |

So the invariant object is **linear leaky-integrator dynamics → static output
nonlinearity**, with parallel channels. That cascade *is* the backbone. "FF state vs.
dose-response slope" (§1.11 #4) is therefore a **false fork**: `G_m` and `f'(V_eff)` read
the *same* convolved state through *different* output functions. We read it through the
**concave dose-response slope**, because that is the lens our hypertrophy data actually
constrains (Remmert/Pelland); the identity lens (`G_m`) is one the data is silent on.

## 2.2 Why concavity is the spine, not an off-by-default knob (Ceddia)

§1.8 filed concavity/negativity as opt-in refinements. `Ceddia-2025` shows the concave
benefit is **load-bearing**. Optimizing a *linear* Banister model degenerates to
**bang-bang** — "train maximally or not at all"; graded, realistic behavior
(periodization, tapering, diminishing returns) only appears once a **saturating concave
benefit** is in the model. For a *ranking* engine the same fact bites differently: a
linear marginal value never falls, so it can **never de-prioritize a just-hammered
muscle** — superposition (§1.8) makes each set history-independent. The concave `f` is
the entire mechanism by which `f'` decays as volume accumulates, i.e. by which
"underworked calves outrank fresh-but-saturated biceps" (§1.0). **Collapse #1 ("marginal
value ≡ dose-response slope") is therefore promoted from *strongest available
simplification* to *the definition of the backbone*.** (Ceddia also supplies a clean
bound worth keeping — fatigue cannot exceed current performance, "you cannot lose more
than you have" — which motivates the bounded `[0,1]` factors of §2.4.)

## 2.3 The missing paper (Philippe-2019) is no longer load-bearing

§D3 flagged the paywalled exponential-growth paper as "the single most load-bearing
missing paper." Under §2.1 it is **not** load-bearing for the architecture: exponential-
growth, IR, log and root all differ *only in the shape of the static nonlinearity `f`* —
a swappable last stage over the identical integrator engine. Which `f` fits RT
hypertrophy best is a later curve-fit that changes **no** state plumbing, recursion, or
readout. `Imbach-2022` corroborates empirically: across forty years the FF variants
"remain close in predictive performance while heterogeneous in complexity" — the
*structure* is stable, the exact `f` is in the noise. **We go forward without Philippe;
`f` is a tunable, evidence-swappable component.**

## 2.4 Combine multiplicatively (gate), not subtractively — and normalization falls out

§1.8/§1.11 #2 tentatively picked subtractive. **Section 2 commits to a multiplicative
gate** as the primary, always-on combination, for three reasons:

1. **Normalization for free (resolves #3).** Each channel readout is bounded to `[0,1]`;
   a product of `[0,1]` factors is automatically in `[0,1]`. An *absolute* efficiency
   falls out with no clamping — "a fried day genuinely tops out at 40%" becomes a
   property of the math, and relative/percentile is then a pure **display** transform.
   #3 (absolute vs relative) stops being a modeling decision. *(Under the Shape-B systemic
   gate the ceiling drop is **exercise-specific** — a fried day tops out low for costly
   compounds but a cheap isolation can still read high, which is the intended behavior, not
   a violation of the bound.)*
2. **It is the Damas reading.** A multiplicative recovery gate *is* "an unrecovered
   muscle converts less of the available stimulus" (§1.4) — productivity, not a
   bookkeeping debit. Subtraction is the endurance/TRIMP framing Banister inherited;
   multiplication is the MPS framing our hypertrophy sources describe.
3. **Subtraction's one edge barely bites in ranking.** Its only unique gift is genuine
   *negativity* (a transient counterproductive window), but a just-trained muscle already
   scores near-zero under the product (low gate × low marginal); negativity almost never
   moves the argmax. So the subtractive acute penalty (`λ0`, `k3`, §1.8) is **kept as the
   opt-in layer it already was** — used only where a sub-zero "do not train yet" signal is
   wanted for forward projection — *over* the multiplicative spine.

## 2.5 Shape and size of the state vector (Kontro, Imbach)

- **Kontro-2025** is the structural precedent: its thesis is that collapsing
  heterogeneous adaptation channels into one scalar is the Banister model's original sin,
  fixed by **parallel independent IR channels** with their own `k`/`τ`. Our 17 muscles
  are Kontro's energy systems. Lesson imported: **keep channels independent through the
  dynamics, combine only at the readout** (our L5), and never pre-collapse muscles into a
  single state. Kontro also licenses one **shared** channel across the independents — the
  right home for systemic fatigue `S(t)` (§1.10 #2): a single global leaky integrator
  entering as one more `[0,1]` multiplicative factor — but a **cost-aware** one,
  `exp(−κ c_e S)`, so it reorders toward low-cost work rather than dimming flatly (Shape B).
- **Imbach-2022** sets the discipline: two-component FF is poorly identifiable and adding
  components reliably fails to improve prediction. This bounds the state count: **≤3 leaky
  integrators per muscle** (slow `V_eff`, fast recovery `D`, optional medium sensitizer
  `C`) **+ 1 global** (systemic `S`). A minutes-scale acute integrator was considered and
**declined** (§1.10 #1) on exactly this principle — it is the unidentifiable kind of state
Imbach warns against, and its behavior is already carried by concavity + per-set
accumulation. Every integrator beyond that is a parameter
  we cannot identify and that Imbach predicts won't pay for itself. Our **population-fixed,
  no-per-user-fit** stance is not merely scope — Imbach makes it the only defensible one.

## 2.6 The master formula (committed)

$$
\eta_e(t) \;=\; \underbrace{e^{-\kappa\, c_e\, S(t)}}_{\substack{\text{cost-aware}\\\text{systemic gate}}} \cdot \sum_{m \,\in\, e} \underbrace{a_{e,m}}_{\text{attribution}} \cdot \underbrace{\mathrm{Recovery}_m(t)}_{\text{Axis A: recovery}} \cdot \underbrace{f'\!\big(V_{\text{eff},m}(t)\big)}_{\text{Axis B: marginal value}}
\qquad\longrightarrow\ \text{normalize}
$$

with $S$, $\mathrm{Recovery}_m$, $V_{\text{eff},m}$ each a population-parameterized leaky integrator (EMA)
over the set history, `f` the concave dose-response (log/root now; swappable — §2.3), and
every factor bounded to `[0,1]` so the product is an honest absolute efficiency (§2.4). The
systemic factor is **cost-aware** (Shape B, §1.10 #2): it discounts each candidate by its own
prospective cost $c_e$ scaled by depletion $S$, so it is inert when fresh ($S\to0$) and steers
toward low-cost work when depleted — the one term that lets systemic fatigue *reorder*, not
just lower the ceiling. This is a Hammerstein–Wiener cascade: **linear leaky-integrator dynamics, static concave
nonlinearities, multiplicative combination, parallel per-muscle channels + one shared
systemic channel.** It is *exactly* the §1.7 minimal set, with three forks closed by
naming the structure.

| Open question (§1.11) | Resolution |
|---|---|
| #7 FF backbone choice / Philippe risk | Non-issue. Backbone is the LN cascade; `f` is a swappable output stage. |
| #4 Axis-B encoding | Dose-response slope `f'(V_eff)` — same convolution as `G_m`, read through the data-constrained lens. |
| #2 subtract vs gate | Multiplicative gate as spine (bounded, Damas-consistent); subtractive penalty opt-in for acute negativity only. |
| #3 normalization | Absolute falls out of the bounded product; relative is display. |
| #8 acute layer | Declined — no minutes-scale channel; concavity + per-set accumulation carry within-bout behavior (§1.10 #1). |
| #9 systemic form | Shape B: one global state, cost-aware gate `exp(−κ c_e S)` on score — reorders toward low-cost work, inert when fresh (§1.10 #2). |

**Still open after §2** (calibration *within* the structure, not a search *for* it): the
`τ` values (incl. `τ_sys`), the RP-12 → DB-17 map, the systemic per-exercise cost table
`c_e` and gain `κ`, and the final choice of `f`. The working statement — formula, every
input, every parameter, the output — is `model.md`.

---

### Source ledger for Section 2
- LN-cascade framing dissolving the FF-vs-slope fork: synthesis over `Clarke-2013`,
  `Busso-2003`, `Remmert-2024`, `Pelland-2024`.
- Concavity is load-bearing (linear → bang-bang): `Ceddia-2025`.
- Adaptation form `f` is swappable / not architecture-critical: `Imbach-2022`,
  `Philippe-2019` (still missing — §D3), `Herold-2021`.
- Parallel independent channels + one shared channel: `Kontro-2025`.
- Minimal identifiable state count, population-fixed parameters: `Imbach-2022`.
- Multiplicative gate = MPS/productivity reading: `Damas-2015`, `Damas-2016`.
- Cost-aware systemic gate (Shape B) — per-exercise recovery cost ordering: `Sousa-2024`; central/systemic
  fatigue basis: `Zając-2015`; structural precedent (EWMA-of-load → gate, ~7 d window) from the
  training-load-monitoring lineage (session-RPE / Banister TRIMP / acute:chronic workload ratio) —
  *form only, no hypertrophy-specific constants; we decline to ingest this class of paper (see reading list)*.

---

### Source ledger for Section 1
- Fitness-fatigue / IR & CP models, impulse form, recursion: `Clarke-2013_fitness-fatigue-modeling-tutorial`
- Non-stationary fatigue (variable dose-response): `Busso-2003`
- Per-session dose-response (log, PUOS≈11 fractional), strength=direct: `Remmert-2024`
- Weekly dose-response (root, PUOS≈31 fractional), fractional≈0.5: `Pelland-2024`
- Set-counting as the volume currency: `Baz-Valle-2021`, `Baz-Valle-2022`
- Load interchangeability for hypertrophy: `Schoenfeld-2017_low-vs-high-load`
- Weekly volume dose-response corroboration: `Schoenfeld-2017_weekly-volume`, `Ralston-2017` (strength), `Currier-2023`
- Diminishing-returns skepticism / bounds: `Buckner-2023`, `Nuckols-2022`
- MPS time course & training-status modulation: `Damas-2015`
- EIMD magnitude, recovery time course, repeated-bout: `Howatson-2008`, `Paulsen-2012`
- EIMD load-insensitivity at matched volume (`d_set ≈ volume`): `Winchester-2022`
- Frequency: `Schoenfeld-2019`
- Attribution priors: `free-exercise-db_mover-map.csv`; EMG refinements: `Lehman-2004`, `Rodriguez-Ridao-2020`, `Martin-Fuentes-2020`, `Clark-2012`, `Saeterbakken-2013`; **interpretation caveat:** `Vigotsky-2018`
- Volume landmarks: `RP-volume-landmarks_current.csv` (*practitioner data, not peer-reviewed*)
- Negativity & clustering (variable dose-response): `Busso-2003` (Eq. 4–5, 7, 10)
- FF identifiability / alternative backbones: `Imbach-2022`, `Kontro-2025`, `Herold-2021`, `Ceddia-2025`
- Per-set RIR/proximity-to-failure modifier: `Refalo-2023_proximity-to-failure-hypertrophy-meta-analysis`
- Productivity gate / training-status non-stationarity (primary): `Damas-2016`; per-session MyoPS ceiling: `Burd-2010`
- Global/systemic fatigue (cross-muscle cap): `Zając-2015`, `Sousa-2024`; non-local-fatigue magnitude (acute crossover ≈0 for force, modest for endurance/volume): `Behm-2021`
- Sub-session / acute fatigue kinetics: `Pareja-Blanco-2019`, `Jukic-2023`, `Refalo-2023_neuromuscular-fatigue`; cross-muscle acute duration (τ≈1–3 min, gone by 5): `Zahiri-2024`
