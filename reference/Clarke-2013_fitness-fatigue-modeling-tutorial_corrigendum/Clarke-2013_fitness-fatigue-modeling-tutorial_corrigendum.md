---
title: "Corrigendum: Rationale and resources for teaching the mathematical modeling of athletic training and performance"
authors: "David C. Clarke, Philip F. Skiba"
year: 2013
journal: "Advances in Physiology Education"
citation: "Clarke DC, Skiba PF. Rationale and resources for teaching the mathematical modeling of athletic training and performance. Adv Physiol Educ 37: 134–152, 2013; doi:10.1152/advan.00078.2011. (Corrigendum: Adv Physiol Educ 37: 270–271, 2013.)"
doi: "10.1152/advan.zu1-2780-corr-2013.2013"
themes: ["athletic training", "mathematical modeling", "fitness-fatigue model", "critical power", "corrigendum"]
source_pdf: "pdfs/Clarke-2013_fitness-fatigue-modeling-tutorial_corrigendum/Clarke-2013_fitness-fatigue-modeling-tutorial_corrigendum.pdf"
conversion: "ensemble (olmOCR + MinerU + Docling + Mathpix) aggregated against page images"
conversion_notes: "Standalone corrigendum (2 pages); transcribes only its own corrections, not the original article. Corrected Fig. 5 and corrected Fig. 10 (panels A and B) are reproduced from the corrigendum's own figure crops; Fig. 10 panel B comprises three stacked plots carried as separate crops (figure-10-b-1/2/3). Page-1 k2 summation upper bound is 's' (verified against page image; olmOCR's draft 'r' was wrong). No numbering quirks. No illegible spots."
---

# Corrigendum

Clarke DC, Skiba PF. Rationale and resources for teaching the mathematical modeling of athletic training and performance. *Adv Physiol Educ* 37: 134–152, 2013; doi:10.1152/advan.00078.2011.

In the *CP model* section, *Equation derivation and assumptions*, *lines 5–7*, the sentence should read as follows: "The model features two parameters, CP and $W'$, which are related according to the following equation…"

The labels in Fig. 5 are shown corrected below.

![Figure 5](images/figure-5.jpg)
> **[Fig. 5]** (Corrected.) Power (W) versus Duration (s). The grey curve is labeled $CP_2(t)$ and the black curve is labeled $CP_3(t)$; the dotted horizontal asymptote is labeled $P_{max}$. The upper-left annotations read $t \rightarrow 0$ and $P \rightarrow \infty$. Two horizontal dashed lines are labeled $CP_2 = 254\ \mathrm{W}$ and $CP_3 = 213\ \mathrm{W}$.

In *Conceptual benefits and practical applications*, paragraph 4, lines 7–8, the authors should read as Jimenez and Skiba. The author listed in Ref. 52 should be Jimenez.

In Fig. 10*B* the equation for $k_2(s)$ should include $w(j)$, as follows:

$$
k_2(s) = k_3 \sum_{j=1}^{s} w(j) e^{-(s-j)/\tau_3}
$$

---

**A**

$$
p(t) = p(0) + k_1 \sum_{s=0}^{t-1} e^{-(t-s)/\tau_1} \omega_p(s) - k_2 \sum_{s=0}^{t-1} e^{-(t-s)/\tau_2} \omega_n(s)
$$

Hill equation:

$$
\omega(s) = \kappa_{p/n} \frac{w(s)^{\gamma}}{\delta^{\gamma} + w(s)^{\gamma}}
$$

![Figure 10 panel A](images/figure-10-a.jpg)
> **[Fig. 10A]** (Corrected.) Adaptive stimulus as a function of training load. Adaptive stimulus (arbitrary units) versus training load (arbitrary units). Legend: solid line "Linear," dashed line "Saturable." The solid (linear) curve is labeled $w(s)$ and the dashed (saturable) curve is labeled $\omega(s)$.

**B**

$$
p(t) = p(0) + k_1 \sum_{s=0}^{t-1} e^{-(t-s)/\tau_1} w(s) - k_2(s) \sum_{s=0}^{t-1} e^{-(t-s)/\tau_2} w(s)
$$

$$
k_2(s) = k_3 \sum_{j=1}^{s} w(j) e^{-(s-j)/\tau_3}
$$

![Figure 10 panel B plot 1](images/figure-10-b-1.jpg)
![Figure 10 panel B plot 2](images/figure-10-b-2.jpg)
![Figure 10 panel B plot 3](images/figure-10-b-3.jpg)
> **[Fig. 10B]** (Corrected.) Three stacked plots sharing a Day axis: (top) TRIMPs (arbitrary units) versus Day; (middle) $k_2(t)$ versus Day; (bottom) Model outputs (arbitrary units) versus Day.
