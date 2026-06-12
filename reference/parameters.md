# Recov — Parameters (commitment ledger)

> Companion to `model.md` (the working model) and `mathematical-model.md` (the derivation).
> This document is where every parameter in the master formula gets **locked in**. For each
> parameter it records (a) its **status** — open TODO or committed decision; (b) the **value
> itself, or a pointer** to where the value lives (per-exercise and per-muscle constants live
> in data files, not inline here — this doc says *which* file and how it's keyed); and, the
> point of the whole exercise, (c) **comprehensive provenance** — exactly how we derived or
> set the number, which sources, which judgment calls, and what would change it.
>
> The model structure is **frozen** (see `model.md` → *What v1 commits to*). This document does
> not relitigate structure; it only fills in the numbers that structure leaves open.

---

## The master formula (what every parameter below plugs into)

$$
\eta_e(t) \;=\; e^{-\kappa\, c_e\, S(t)} \,\cdot \sum_{m \,\in\, e} g_m \cdot a_{e,m} \cdot \mathrm{Recovery}_m(t) \cdot f'\!\big(V_{\text{eff},m}(t)\big)
$$

with the three leaky-integrator states
$V_{\text{eff},m}$ (slow, $\tau_{\text{slow}}$), $D_m$ (fast, $\tau_{\text{fast},m}$),
$S$ (systemic, $\tau_{\text{sys}}$), and readouts
$\mathrm{Recovery}_m = e^{-D_m/\mathrm{cap}_m}$, systemic gate $= e^{-\kappa c_e S}$.

Every symbol in this formula appears as a row in the index below.

---

## How to read this document

**Status legend**

| Tag | Meaning |
|---|---|
| 🔒 **COMMITTED** | Value (or rule) locked. Provenance complete. Will not move without a recorded reason. |
| 🟡 **PROVISIONAL** | A working value is in place (e.g. illustrative/borrowed) but not yet defended; usable, revisitable. |
| ⬜ **TODO** | Not yet set. Provenance section states the plan and the sources to pull from. |

> Scope: this doc covers **only parameters the model actually uses**. Knobs the model declines
> (the EMG attribution perturbation, the acute-penalty `λ0`, the clustering `k3`/`τ3`) are
> deliberate non-goals — their rationale lives in `model.md` and `mathematical-model.md` §1.8/§1.10,
> not here.

**Where the value lives**

- *Inline scalar* — a single global value; it sits in this doc.
- *Inline table* — a **per-muscle (17)** table; there are few enough muscle classes that the
  full table lives in this doc, values and all.
- *Data file* — a **per-exercise (873)** table; this doc names the file, the key column, and the
  build rule, but **not** the 873 individual numbers.

**Provenance block** — every parameter carries, at minimum:
1. **Sources** — the reference folder(s)/file(s) and any external citation the value rests on.
2. **Derivation** — the actual reasoning from source → number (or the rule that generates the table).
3. **Judgment calls** — where we chose without data, and why that choice.
4. **What would change it** — the evidence or decision that would move the value.

---

## Parameter index

Quick map of every parameter to its status and section. Symbols match the master formula.

| # | Parameter | Symbol | Group | Lives in | Status |
|---|---|---|---|---|---|
| 1 | Attribution / set credit | `a_{e,m}` | per-exercise | data file | 🔒 COMMITTED |
| 2 | Systemic cost | `c_e` | per-exercise | data file | ⬜ TODO |
| 3 | Per-set impulse / RIR modifier | `w_i`, `rir_mod` | per-set | inline | ⬜ TODO |
| 4 | Slow time constant | `τ_slow` | per-muscle (global?) | inline | ⬜ TODO |
| 5 | Fast recovery time constant | `τ_fast,m` | per-muscle | inline table | ⬜ TODO |
| 6 | Recovery capacity | `cap_m` | per-muscle | inline table | ⬜ TODO |
| 7 | Volume landmarks *(Axis-B reference scale — calibration input, not a runtime term)* | `MV/MEV/MAV/MRV` | per-muscle | inline table (← CSV) | 🟡 PROVISIONAL |
| 8 | RP-12 → DB-17 map | — | per-muscle | inline table | ⬜ TODO |
| 9 | Dose-response curve | `f`, `f'` | per-muscle (global shape) | inline | 🔒 shape / ⬜ params |
| 10 | Systemic time constant | `τ_sys` | global | inline | ⬜ TODO |
| 11 | Systemic coupling gain | `κ` | global | inline | ⬜ TODO |
| 12 | Muscle priority | `g_m` | user config | inline default | 🔒 default uniform |

---

## 1. Per-exercise parameters
*(keyed by exercise; 873 exercises in `free-exercise-db_exercises.json`)*

### 1.1 — Attribution / set credit `a_{e,m}`  🔒 COMMITTED

- **Value / location:** Rule, not a hand table. `a_{e,m} = 1.0` if `m ∈ primaryMuscles(e)`,
  `0.5` if `m ∈ secondaryMuscles(e)`, else `0`. Built directly from
  `free-exercise-db_mover-map.csv` (`direct_muscles` / `indirect_muscles` columns).
- **Provenance:**
  1. *Sources:* `free-exercise-db_mover-map.csv` (873 rows) ← `free-exercise-db_exercises.json`;
     fractional secondary weight from `Remmert-2024`, `Pelland-2024` (and the 0.5 convention
     discussed `mathematical-model.md` §1.2).
  2. *Derivation:* binary primary/secondary lists already in the DB → {1.0, 0.5, 0.0} map.
  3. *Judgment calls:* the **0.5** for secondary is the empirically-favored round number, not a
     measured multiplier; uniform across all exercises.
  4. *What would change it:* an EMG-based refinement of the weights — a declined non-goal for v1
     (see `mathematical-model.md` §1.2, Vigotsky caveat), so the map is treated as fixed here.

### 1.2 — Systemic cost `c_e`  ⬜ TODO  *(the cost table still owed)*

- **Value / location (planned):** one scalar per exercise → a new column in the mover-map (or a
  sibling `*_systemic-cost.csv`). **One number, two jobs:** the dose a set deposits into `S(t)`,
  and the cost the candidate is charged by the gate $e^{-\kappa c_e S}$.
- **Provenance (plan):**
  1. *Sources:* `Sousa-2024` (recovery/microcycle ordering — multi-joint, lower-body, eccentric
     cost more); exercise features already in the DB (`mechanic` compound/isolation, `force`,
     `category`, equipment, primary muscle region).
  2. *Derivation (to build):* hand-set population table triangulated from the Sousa ordering +
     DB features, **not fit**. Same epistemic status as `τ_fast,m` / `cap_m`: triangulated proxy.
  3. *Judgment calls (open):* the numeric scale (illustrative trace used compound 0.035 /
     isolation 0.015), and how finely to bin (binary compound/isolation vs. a graded scale by
     muscle mass / region).
  4. *What would change it:* any direct systemic-load dataset (none known); recalibration of `κ`
     (the two trade off — see row 12).

---

## 2. Per-set parameters
*(applied per logged set at integration time)*

### 2.1 — Per-set impulse `w_i` / RIR modifier `rir_mod`  ⬜ TODO

- **Value / location:** inline scalar rule. `w_i = rir_mod(RIR_i) ≈ 1` (one fractional set),
  concave, plateauing by ~1–2 RIR. Reps and load drop out to first order.
- **Provenance (plan):**
  1. *Sources:* `Baz-Valle-2021`/`-2022` (set-counting as the volume unit), `Schoenfeld-2017`
     low-vs-high-load (load interchangeable near failure), `Refalo-2023` (proximity-to-failure),
     `Jukic-2023` (velocity-loss).
  2. *Derivation (to build):* choose the `rir_mod` shape (e.g. flat = 1 for RIR ≤ ~3, or a mild
     concave taper). Default minimal-log assumption when RIR missing: RIR 1–3.
  3. *Judgment calls (open):* exact taper shape and the RIR threshold where credit starts dropping.
  4. *What would change it:* committing to richer per-set logging (reps/load) would reopen whether
     they truly drop out.

---

## 3. Per-muscle parameters
*(keyed by the 17 DB muscles; abdominals, abductors, adductors, biceps, calves, chest,
forearms, glutes, hamstrings, lats, lower back, middle back, neck, quadriceps, shoulders,
traps, triceps)*

### 3.1 — Slow time constant `τ_slow`  ⬜ TODO

- **Value / location:** inline (one global value unless evidence forces per-muscle). Governs
  `V_eff` decay — "stimulus debt" memory, days–week.
- **Provenance (plan):** dose-response / volume kinetics; the weekly dose-response window of
  `Pelland-2024` / `Schoenfeld-2017` volume studies sets the order of magnitude (~7 d in the
  illustrative trace). *Open:* defend the exact value; decide global vs. per-muscle.

### 3.2 — Fast recovery time constant `τ_fast,m`  ⬜ TODO  *(per-muscle table owed)*

- **Value / location:** inline table below (~1–5 d, EIMD scale). The `tier` column records the
  damage-susceptibility ordering the value rests on; fill `τ_fast,m` (days) once tiers are set.

  | Muscle | tier (susceptibility) | `τ_fast,m` (d) |
  |---|---|---|
  | abdominals | fast (Type-I postural) | TODO |
  | abductors | — | TODO |
  | adductors | — | TODO |
  | biceps | — | TODO |
  | calves | fast (Type-I postural) | TODO |
  | chest | — | TODO |
  | forearms | fast (habitually loaded) | TODO |
  | glutes | — | TODO |
  | hamstrings | slow (biarticular, fusiform) | TODO |
  | lats | — | TODO |
  | lower back | fast (Type-I postural) | TODO |
  | middle back | — | TODO |
  | neck | — | TODO |
  | quadriceps | medium | TODO |
  | shoulders | — | TODO |
  | traps | fast (Type-I postural) | TODO |
  | triceps | — | TODO |

- **Provenance (plan):**
  1. *Sources:* `Paulsen-2012`, `Howatson-2008` (EIMD recovery 1–5 d); ordering from `EJAP-2023`
     (hamstrings ~48 h vs quads ~24 h) and `Johnson-1973` fiber-type table (Type-I postural
     muscles recover fastest).
  2. *Derivation (to build):* hand-set population table **ordered by damage susceptibility /
     architecture** — longitudinal-fusiform & biarticular slower; pennate, habitually-loaded,
     Type-I postural (calves, abs, erectors, traps) faster. Consistent with RP's higher tolerable
     frequency for those. Not a fitted curve.
  3. *Judgment calls (open):* the actual numbers within the 1–5 d band per muscle; how many
     distinct tiers.
  4. *What would change it:* a clean per-muscle recovery-kinetics dataset (none known to exist).

### 3.3 — Recovery capacity `cap_m`  ⬜ TODO  *(triangulated: peer-reviewed muscle size, RP-validated)*

- **Value / location:** inline table below. `cap_m` scales the recovery gate `e^{-D_m/cap_m}` so
  high-capacity muscles aren't crushed by the same absolute deficit. **Re-footed (2026-06-12):** the
  cross-muscle *ordering* is **no longer `∝ RP MRV` alone**. It is now anchored on **peer-reviewed
  muscle volume** (`Riem-2025`, whole-body MRI), with **RP MRV** demoted to the **sets-based scale +
  a convergence check**, and **Ward-2009 PCSA** as a lower-limb force-capacity cross-check. This is
  the methodology that strengthens the RP numbers instead of depending on them blindly (see row 3.4).

  Columns: aggregated Riem volume (sum of constituent muscles → our DB group), mapped RP MRV, and the
  reconciled `cap_m`. The **"size source"** column flags coverage: ✓Riem = real anatomical volume,
  *borrowed* = no peer-reviewed number (neck only).

  | Muscle | size source | Riem vol, mL (agg.) | RP MRV (mapped) | `cap_m` |
  |---|---|---|---|---|
  | abdominals | ✓Riem (rectus abd. + obliques) | TODO | TODO | TODO |
  | abductors | ✓Riem (glute med/min + TFL) — *was borrowed* | TODO | — (no RP) | TODO |
  | adductors | ✓Riem (add. magnus/longus/brevis + pectineus + gracilis) — *was borrowed* | TODO | — (no RP) | TODO |
  | biceps | ✓Riem (biceps brachii) | TODO | TODO | TODO |
  | calves | ✓Riem (gastroc med/lat + soleus) | TODO | TODO | TODO |
  | chest | ✓Riem (pec major/minor) | TODO | TODO | TODO |
  | forearms | ✓Riem (~13 forearm muscles) — *was borrowed* | TODO | — (no RP) | TODO |
  | glutes | ✓Riem (glute max; med/min if not → abductors) | TODO | TODO | TODO |
  | hamstrings | ✓Riem (semiten/semimem + biceps femoris L/S) | TODO | TODO | TODO |
  | lats | ✓Riem (latissimus dorsi) | TODO | TODO | TODO |
  | lower back | ✓Riem (erector spinae + multifidus + QL) | TODO | TODO | TODO |
  | middle back | ✓Riem (rhomboid; mid-trap allocation TBD) | TODO | TODO | TODO |
  | neck | **borrowed** — Riem has no true cervical muscle | n/a | — (no RP) | TODO |
  | quadriceps | ✓Riem (rectus fem + 3 vasti) | TODO | TODO | TODO |
  | shoulders | ✓Riem (deltoid + rotator cuff) | TODO | TODO | TODO |
  | traps | ✓Riem (trapezius) | TODO | TODO | TODO |
  | triceps | ✓Riem (triceps brachii + anconeus) | TODO | TODO | TODO |

  > **Coverage win:** Riem supplies real volume for **16 of 17** DB muscles, including the three that
  > RP could not reach (**abductors, adductors, forearms** — formerly "borrowed/default"). **Neck** is
  > the lone remaining borrowed value, and the least consequential for hypertrophy (`g_neck` is
  > typically downweighted anyway).

- **Provenance (plan):**
  1. *Sources:* **`Riem-2025`** (whole-body per-muscle MRI volume, 70 muscles, Table 3 — the primary
     cross-muscle anchor); **`Ward-2009`** (lower-limb PCSA + architecture, cadaver — force-capacity
     cross-check and pennation/fiber-length input shared with `τ_fast,m`; use for **ratios, not
     absolute scale** — cadaver volumes ≈ ½ in-vivo per `Handsfield-2014`); **`Handsfield-2014`**
     (independent lower-limb volume method — convergence check); **RP MRV**
     (`RP-volume-landmarks_current.csv`) as the **sets-based scale + convergence check**, no longer
     the ordering source; recovery-by-muscle support: **`Şenışık-2021`** (architecture → differential
     EIMD across elbow flexors / knee extensors / knee flexors), `Paulsen-2012`, `Howatson-2008`.
  2. *Derivation (to build):* (a) aggregate Riem's 70 muscles into our 17 DB groups (sum constituents;
     resolve allocation calls, e.g. gluteus medius → *glutes* vs *abductors*, mid-trapezius → *traps*
     vs *middle back*); (b) set the cap_m ordering from aggregated volume (optionally blended with
     Ward PCSA where covered); (c) **validate** RP MRV against the volume ordering (row 3.4 validation
     move); (d) fix the **absolute scale** from MRV, since `cap_m` normalizes a set-based `D_m`.
     Hand-set population table, not fitted.
  3. *Judgment calls (open):* the volume→capacity proportionality; whether/how to blend volume with
     PCSA; the Riem→DB-17 aggregation/allocation calls; the **neck** borrowed value; whether a
     fiber-type axis enters (Johnson unobtained, see §F — `cap_m` is **size-only** for now).
  4. ⚠️ ***The soft spot — state it, don't hide it:*** these sources measure muscle **size**, not
     **recovery**. "Bigger muscle ⇒ more recoverable volume" is a modeling **assumption**, not a
     measurement. `Şenışık-2021` and the EIMD literature show architecture/size modulate damage
     response, but the size→capacity link itself is **not directly calibrated**. This is now the
     weakest link in `cap_m` (more than the data — the data is sturdy).
  5. *What would change it:* a direct per-muscle recovery-capacity dataset (none known to exist);
     obtaining the fiber-type leg to add a second, non-size construct; the RP-vs-volume validation
     outcome (could re-weight specific muscles or, if RP diverges badly, down-rank it further).

### 3.4 — Volume landmarks `MV / MEV / MAV / MRV` — the Axis-B reference scale  🟡 PROVISIONAL

**Not a runtime parameter.** The engine never reads MV/MEV/MAV/MRV directly — it reads `cap_m`
(3.3) and the parameterized dose-response `f` (3.6). The landmarks are the shared **calibration
source** both of those are set against (same status as the Sousa ordering for `c_e`). They get
their own row, rather than living inside one consumer's provenance, precisely because **two**
parameters depend on them; this is the single documented home for the RP scrape and its caveats.

- **Consumed by:**
  - **3.3 `cap_m`** — **no longer ∝ MRV outright.** As of 2026-06-12 the cross-muscle ordering is
    anchored on peer-reviewed muscle volume (`Riem-2025`); RP MRV now supplies only the **sets-based
    scale** and acts as a **convergence check** against that volume ordering. See the *validation
    move* below — this is the re-footing that keeps RP in the loop without depending on it blindly.
  - **3.6 dose-response `f`** — **MEV** sets the stimulus-debt threshold (`f'` high below it);
    **MAV/MRV** are the saturation/ceiling clamps (`f' → 0` near MRV), reconciled against the
    Remmert/Pelland PUOS anchors.
- **Value / location:** raw 12-group source is `RP-volume-landmarks_current.csv` (sets/muscle/week);
  provenance fully documented in `RP-volume-landmarks_SOURCES.md`. The **DB-17 mapped** values land
  inline here, in the `MRV_m` column of row 3.3 and the map of row 3.5.
- **Provenance:**
  1. *Sources:* scraped from live RP per-muscle articles 2026-06-07 (Israetel/RP). **Not
     peer-reviewed** — practitioner common-knowledge / starting point.
  2. *Derivation:* used as the **reference scale** for Axis B — see *Consumed by* above.
  3. *Judgment calls / caveats:* RP counts **direct sets**; our model uses **fractional**
     (0.5-secondary) counting — the two must be reconciled before MEV/MAV/MRV are used as ceilings
     (noted in `model.md`). This reconciliation is why status is 🟡 not 🔒.
  4. *What would change it:* re-scrape (RP revises periodically); the fractional-vs-direct
     reconciliation; the 12→17 map; the validation outcome below.
- **Validation move (the point of the re-footing — strengthens RP rather than trusting it):**
  aggregate `Riem-2025` volumes into the 12 RP groups and test whether **RP's MRV ordering tracks
  peer-reviewed muscle volume**. *Agreement* promotes RP from "practitioner folklore" to "tracks a
  measurable physiological quantity" — and we keep its sets-scale with confidence. *Disagreement* is
  itself a finding and tells us which muscles to re-weight (or to trust volume over RP). Either way
  RP stops being a single un-checked source. (Reconcile RP **direct-set** counts with our
  **fractional** counts first — same caveat as point 3.) **Status: owed** — data is in hand
  (`Riem-2025`, `RP-volume-landmarks_current.csv`); the cross-check has not yet been run.

### 3.5 — RP-12 → DB-17 map  ⬜ TODO

- **Value / location:** inline table below — each of the 17 DB muscles → its RP source group (and
  the split rule when a group feeds several muscles). `abductors/adductors/forearms/neck` have no
  RP landmark and take a borrowed/default scale (to decide).

  | DB muscle | RP group(s) | split rule |
  |---|---|---|
  | abdominals | Abs | 1:1 |
  | abductors | — | borrowed/default (TODO) |
  | adductors | — | borrowed/default (TODO) |
  | biceps | Biceps | 1:1 |
  | calves | Calves | 1:1 |
  | chest | Chest | 1:1 |
  | forearms | — | borrowed/default (TODO) |
  | glutes | Glutes | 1:1 |
  | hamstrings | Hamstrings | 1:1 |
  | lats | Back | split of "Back" (TODO) |
  | lower back | Back | split of "Back" (TODO) |
  | middle back | Back | split of "Back" (TODO) |
  | neck | — | borrowed/default (TODO) |
  | quadriceps | Quads | 1:1 |
  | shoulders | Front Delts + Rear/Side Delts | combine (TODO) |
  | traps | Traps | 1:1 |
  | triceps | Triceps | 1:1 |

- **Provenance (plan):**
  1. *Sources:* `RP-volume-landmarks_current.csv` (12 groups) vs. the 17 DB muscles.
  2. *Derivation (to build):* e.g. RP "Back" → {lats, middle back, lower back}; RP "Front Delts" +
     "Rear/Side Delts" → shoulders; Quads, Abs, Chest, Biceps, Triceps, Traps, Glutes, Hamstrings,
     Calves map ~1:1. Must also reconcile RP **direct-set** counts with our **fractional** counts.
  3. *Judgment calls (open):* how to split a group's landmark across its DB muscles;
     **borrowed/default scale** for `abductors`, `adductors`, `forearms`, `neck` (no RP landmark).
  4. *What would change it:* a finer landmark source covering the missing muscles.

### 3.6 — Dose-response curve `f` and its slope `f'`  🔒 shape committed / ⬜ params open

- **Value / location:** inline (functional form + parameters). `f'(V_eff)` is the marginal-value
  readout (Axis B); `f` is **swappable** without touching the engine.
- **Provenance:**
  1. *Sources:* `Remmert-2024` (per-session, log shape, PUOS ≈ 11/session), `Pelland-2024`
     (weekly, root shape `√V`, PUOS ≈ 31/wk); concavity defended in `mathematical-model.md` §2.2
     (Ceddia). **Saturation/threshold scale from the volume landmarks (row 3.4):** MEV anchors the
     stimulus-debt threshold, MAV/MRV the ceiling where `f' → 0`.
  2. *Derivation:* concavity is **committed** as the spine (diminishing returns); candidate forms
     log / root / exp-growth / sigmoid all preserve it. Illustrative trace used `f(V)=√V`.
  3. *Judgment calls (open):* the **final choice** among forms, and its parameters (saturation
     point relative to MRV). The *shape class* (concave) is locked; the *specific f* is not.
  4. *What would change it:* deciding session- vs. week-anchored; fit of PUOS anchors to landmarks.

---

## 4. Global parameters
*(single scalars, population-level)*

### 4.1 — Systemic time constant `τ_sys`  ⬜ TODO

- **Value / location:** inline scalar; between-session systemic recovery, ~days.
- **Provenance (plan):** acknowledged **gap** — no clean dataset. ACWR convention (~7 d acute
  window) and non-local-fatigue duration (`Zahiri-2024`, `Behm-2021`) bound the order of
  magnitude. Illustrative trace used 5 d. *Open:* defend a value.

### 4.2 — Systemic coupling gain `κ`  ⬜ TODO

- **Value / location:** inline scalar; strength of the cost-aware systemic penalty in
  $e^{-\kappa c_e S}$.
- **Provenance (plan):** **guess — no data.** Keep modest; `κ → 0` recovers a pure per-muscle
  model (gate inert). Trades off with the `c_e` scale (row 1.2) — only the product `κ·c_e`
  matters, so the two must be pinned **together**. Illustrative trace used `κ = 20` with
  `c_e ∈ {0.015, 0.035}`. *Open:* choose the operating point on the `κ·c_e` curve.

---

## 5. User configuration
*(the only user-tunable input — configuration, not fitting)*

### 5.1 — Muscle priority `g_m`  🔒 default committed (uniform)

- **Value / location:** inline default **`g_m = 1` for all 17 muscles** (balanced total
  hypertrophy). Per-muscle weight in `[0,1]`, user-set; enters as a pure multiplicative channel
  weight.
- **Provenance:**
  1. *Sources:* design decision (`model.md` → *User configuration*); not from literature, not fit.
  2. *Derivation:* a stated **goal**, not inferred dynamics. Lowering `g_m` de-prioritizes a
     muscle (e.g. `g_neck`, `g_forearms` low to stop surfacing trivial neglected muscles).
  3. *Judgment calls:* the line **configuration is allowed, fitting is banned** — `g_m` changes
     *what we optimize for*, never *how muscles respond* (`τ`, `cap`, landmarks, `f` stay fixed).
  4. *What would change it:* only user input. The **default** (uniform) needs no calibration.

---

## Cross-cutting notes

- **Coupled parameters (pin together, not in isolation):** `κ` ↔ `c_e` scale (only `κ·c_e`
  matters); `cap_m` ordering ↔ `Riem-2025` volume, `cap_m` scale ↔ MRV ↔ the 12→17 map; `f` choice ↔
  landmark saturation point.
- **Same epistemic class — "hand-set population tables, not fit":** `c_e`, `τ_fast,m`, `cap_m`.
  None has a *recovery* dataset; each is triangulated from proxies and ordered by mechanism. Treat
  their provenance with skepticism and document the ordering logic, not a false precision.
  **`cap_m` is now the best-footed of the three** — its cross-muscle ordering rests on a
  peer-reviewed whole-body volume dataset (`Riem-2025`), not practitioner numbers; its residual
  weakness is the *size→recovery inference* (an assumption), not the data (see 3.3 point 4).
- **Illustrative ≠ committed.** Every number in the `model.md` worked example (`τ` = 3/7/5 d,
  `κ = 20`, `c_e` = 0.035/0.015) is a **placeholder** to show the machinery. None is committed
  here until its row says 🔒.
