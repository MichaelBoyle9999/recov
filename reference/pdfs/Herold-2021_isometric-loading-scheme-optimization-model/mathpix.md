\title{
A mathematical model-based approach to optimize loading schemes of isometric resistance training sessions
}

\author{
Johannes L. Herold ${ }^{\mathbf{1}}$ © • Andreas Sommer ${ }^{\mathbf{1}}$
}

Accepted: 5 November 2020 / Published online: 23 December 2020
(c) The Author(s) 2020

\begin{abstract}
Individualized resistance training is necessary to optimize training results. A model-based optimization of loading schemes could provide valuable impulses for practitioners and complement the predominant manual program design by customizing the loading schemes to the trainee and the training goals. We compile a literature overview of model-based approaches used to simulate or optimize the response to single resistance training sessions or to long-term resistance training plans in terms of strength, power, muscle mass, or local muscular endurance by varying the loading scheme. To the best of our knowledge, contributions employing a predictive model to algorithmically optimize loading schemes for different training goals are nonexistent in the literature. Thus, we propose to set up optimal control problems as follows. For the underlying dynamics, we use a phenomenological model of the time course of maximum voluntary isometric contraction force. Then, we provide mathematical formulations of key performance indicators for loading schemes identified in sport science and use those as objective functionals or constraints. We then solve those optimal control problems using previously obtained parameter estimates for the elbow flexors. We discuss our choice of training goals, analyze the structure of the computed solutions, and give evidence of their real-life feasibility. The proposed optimization methodology is independent from the underlying model and can be transferred to more elaborate physiological models once suitable ones become available.
\end{abstract}

Keywords Isometric ⋅ Resistance training ⋅ Optimal control ⋅ Optimization ⋅ Ordinary differential equation model

\section*{Abbreviations}

FTI Force-time integral
KPI Key performance indicator
MVIC Maximum voluntary isometric contraction
ODE Ordinary differential equation
RT Resistance training
TUT Time-under-tension

\section*{1 Introduction}

\subsection*{1.1 Resistance training and model-based approaches}

Resistance training (RT) is a popular choice among athletes, rehabilitation patients, or the general public to improve

\footnotetext{
Johannes L. Herold
johannes.herold@iwr.uni-heidelberg.de
1 Interdisciplinary Center for Scientific Computing (IWR), Heidelberg University, Im Neuenheimer Feld 205, 69120 Heidelberg, Germany
}
physical performance. Benefits of RT include increased muscular strength and endurance, improved body composition, or enhanced functional capacity and quality of life [52]. To optimize results, individualized RT is necessary [24]. Therefore, training variables as exercise selection, frequency, volume, or intensity are adjusted to the trainee and the training goals. These adjustments are commonly performed by the trainee or a coach via trial-and-error [20].

To complement such a manual decision- making, many research areas like chemical or mechanical engineering have adopted methods from scientific computing, e.g., modeling, simulation, and optimization. For this reason, scientific computing is often considered to be the third pillar of methodology in science next to theory and experiment [38]. Nevertheless, sport science and exercise physiology are only slowly realizing the potential of model-based approaches [7]. In particular, applications covering loading schemes for resistance training are limited. We refer to the literature overview in the next section to justify this claim.

A model-based optimization of loading schemes for RT could provide valuable impulses for practitioners and complement the predominant manual program design. By
calibrating the model to the trainee, individual parameters are obtained. Then, optimized RT programs could be computed specifically for this trainee, exercise, and training goal based on a key performance indicator (KPI) accessible in the model. Furthermore, a comparison of effective loading schemes in practice and algorithmically optimized loading schemes could help to identify the driving stimuli for adaptations, e.g., the contributions of mechanical loading, metabolic stress, and muscle damage to hypertrophic adaptations [44] or the effect of different mechanical stimuli on strength and power adaptations [21]. Moreover, RT programs could be designed to induce the same level of metabolic disturbances. This would allow to increase the comparability between training approaches, e.g., between blood flow restriction training and conventional training.

\subsection*{1.2 Purpose}

In this work, we provide a literature overview of modelbased approaches used to simulate or optimize the response to single RT sessions or to long-term RT plans in terms of strength, power, muscle mass, or local muscular endurance by varying the loading scheme. To the best of our knowledge, contributions employing a predictive model to algorithmically optimize loading schemes for different training goals are nonexistent in the literature. Thus, we propose to set up optimal control problems as follows. For the underlying dynamics, we use a phenomenological model of the time course of maximum voluntary isometric contraction (MVIC) force. Then, we provide mathematical formulations of key performance indicators for loading schemes identified in sport science and use those as objective functionals or constraints. Those KPIs are the force- time integral, the time-under-tension (TUT), the accumulated fatigue defined as loss of MVIC force, and variants thereof. We then solve those optimal control problems using previously obtained parameter estimates for the elbow flexors. Last, we discuss our results, point out limitations, and give an outlook on further research.

\section*{2 Literature overview}

In the following, we provide an overview of model-based approaches used to simulate or optimize an individual's response to single RT sessions or to long-term RT plans in terms of strength, power, muscle mass, or local muscular endurance by varying the loading scheme. We begin with defining prerequisites which are necessary for a model to be used with our approach.

Remark Here, we do not include work that is restricted to the biomechanical analysis of RT exercises, the description
of muscular fatigue during RT, or general models of the training-performance relationship without a specific application to RT, as a thorough literature overview including these fields of research is beyond the scope of this work. However, we would like to mention that substantial work has been done in these fields-either close or synergetic to ours. For example, model-based approaches are stronger established in endurance sports to analyze optimum pacing strategies [8, 57], training strategies [23], or long-term adaptations [54]. Furthermore, as soon as a suitable extension of the model to dynamic movements is available, possible synergies could arise from existing works which analyze and compute optimum movements [22, 27]. For the interested reader, we refer to these exemplary works and the references therein.

\subsection*{2.1 Model prerequisites}

To enable a real-life application for practitioners, the model used should fulfill several criteria. First, the inputs of the model, which correspond to the training plan of the trainee, have to be interpretable for practitioners. As such, using quantities which reduce the dimensionality of the training input [48] is not desirable. For example, using only volume load (defined as weight × repetitions × sets) [11] to describe the loading scheme of an RT session provides no information about the intensity distribution and is therefore unsuitable. Second, the parameters of the model should be identifiable through commonly available measurement procedures, e.g., force measurements, to avoid an overly laborious model calibration. Third, due to the high number of possible training inputs, the model should be suitable for high-dimensional optimization, i.e., for derivative-based optimization [29]. Fourth, the model should allow to incorporate real-life constraints into the optimization problem, e.g., days or weeks off [43]. Last, the model should be assessed for its predictive ability. We classify a model as predictive if it has been fit to a subset of the available data and the resulting parameter estimates can be used to predict the remaining data. We emphasize this, as the terminology is sometimes used differently and models are already classified as predictive if they fit the whole dataset-a property we call descriptive. However, overparameterization or other model deficiencies might diminish the model's ability to predict unknown datasets. Benzekry et al. [10], for example, demonstrated this issue illustratively for tumor growth modeling. Furthermore, fit and prediction should be evaluated by suitable measures [46] and should not be judged based on the plots alone, as those are heavily depending on the chosen visualization.

\subsection*{2.2 Existing models}

Banister et al. [9] introduced a systems model based on the assumption that each training load induces a negative effect
(fatigue) and a positive effect (fitness) on performance. As the original paper cannot be found easily, we refer to Calvert et al. [19] for a description of the model. The ordinary differential equation (ODE) model has been adopted for various settings and several modifications have been proposed. The model is commonly known as Banister model or FitnessFatigue model and predominantly given in a time-discrete formulation. Busso et al. [16, 17] fitted variants of the Banister model to data from Olympic weightlifters. The authors used weighted weekly training volume as input and clean and jerk performance as output and correlated the model components to different hormones. However, the predictive ability of the model was not tested, i.e., the whole dataset was used for fitting the model. Model variants were furthermore used by Philippe et al. [40] to describe the response of rats to resistance training. In subsequent work, the authors used exponential growth functions for this purpose [41]. In both works, model prediction was not tested.

Mader [36, 37] developed an ODE model of the active adaptation and regulation of protein synthesis on a cellular level. The model uses intensity of the functional activity as input and gives protein mass as an indicator of functional capacity as the most important output. The model is able to describe supercompensation as well as overtraining, which is demonstrated by simulating different scenarios. An extended version of the model has been proposed by Ullmer and Mader [51]. None of the variants were experimentally validated.

Gatti et al. [26] computed training plans for shoulder rehabilitation by determining the optimal number of sets per exercise for increasing maximum isometric strength given a time constraint. Two different objective functions were examined and compared to current practice. No statements about training intensity were made.

Gacesa et al. [25] used a nonlinear dynamic system to separately fit fatigue data and muscular growth data of the triceps brachii. The predictive ability of the model was not tested.

Arandjelović [2] introduced a model of neuromuscular adaption to resistance training. In this model, the so-called capability profile of an athlete is modified depending on the execution of an exercise. The author subsequently used simulations to examine the influence of using fixed loads or accommodating loads on the training stimulus. Furthermore, the author proposed a framework to calibrate the model from video data [5, 7]. The model was found to successfully predict performance in the bench press and the squat. Resistance training can then be adjusted via trial-and-error by inspecting the simulated adaptations. Additionally, Arandjelović used the model to examine training strategies to overcome the sticking point of an arm curl [3], to examine the influence of externally supplied momentum on the hypertrophy stimulus of a shoulder lateral raise [6],
and to examine different loading mechanisms of a Smith machine [4]. Although these three studies are mainly of biomechanical nature, we mention them here, as they specifically aim at increasing force or muscle mass by a model-based examination of possible adaptations.

Wisdom et al. [53] proposed ODE models of muscle adaptation to chronic overstretch, overload, understretch, and underload and compared those models to experimental data. The predictive ability of the models was not tested. Zhou et al. [56] used similar dynamics to describe hypertrophy and atrophy of a muscle fiber given as crosssectional area with muscle activation level as input. After fitting their model to experimental data, the authors simulated muscle atrophy during a spaceflight and how different exercises could serve as countermeasures.

Torres et al. [49] extended an energy balance model to account for the hypertrophic effects of resistance training and used the model for simulation studies. Moreover, the model was fit to data from elderly participants following a resistance training routine. Resistance training input is described via a scaling variable and has no direct interpretation in terms of volume, intensity, or frequency.

Herold et al. [29] constructed and validated a model of the time course of maximum voluntary isometric contraction force. Exemplarily, the model was used to algorithmically maximize the force-time integral (FTI) of an isometric RT session. We use this model as the foundation of our work, as it is-to the best of our knowledge-the only one to be tested for its predictive ability, suitable for derivative-based optimization, and directly interpretable for practitioners in terms of RT input. However, as the model provides a phenomenological description of muscular fatigue for different loading schemes, it does not directly link the RT input to a physiological adaptation of the trainee. Additionally, there still exist research gaps concerning the exact stimuli and mechanisms of muscular adaptation. To circumvent these issues, we provide mathematical formulations of KPIs for loading schemes identified in sport science and accessible in the model. Those KPIs are the force-time integral, the time-under-tension, the accumulated fatigue defined as loss of MVIC force, and variants thereof.

\section*{3 Materials and methods}

In this section, we describe the model and the optimization problems. For readers with a focus away from mathematical modeling, simulation, and optimization, we provide a short textual summary and then invite them to directly proceed to the results section if desired.

\subsection*{3.1 Textual summary}

Previous work [29] allows us to predict how MVIC force of a muscle group decreases and recovers under isometric loading (Eq. 1). Using mathematical methods of optimal control, this enables us to compute optimized isometric RT sessions (Eq. 2) with respect to different trainings goals. These training goals are constructed from the force-time integral, time-under-tension, or fatigue (Eqs. 3-6).

\subsection*{3.2 Model}

For our numerical experiments, we use a phenomenological model of the time course of maximum voluntary isometric contraction force. We state the ordinary differential equation system and give a short explanation of the components. For a detailed description of the model, we refer to the original paper [29].

The model describes the current MVIC force capacity
$$
\begin{equation*}
h_{\mathrm{MVIC}}:[0, T] \rightarrow[0,1] \tag{1a}
\end{equation*}
$$
of a muscle (or muscle group) at joint level under an external isometric load
$$
\begin{equation*}
u_{\text {abs }}:[0, T] \rightarrow[0,1] \tag{1b}
\end{equation*}
$$
on the time horizon $[0, T]$. MVIC force capacity and external load are normalized to baseline MVIC force and are thus dimensionless. Moreover, the ranges of functions specified in this description are restricted to physiological meaningful values. The defining equations of the model are given as $\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {slow }}(t)=p_{1}\left(1-x_{\text {slow }}(t)\right)-p_{2} u_{\text {abs }}(t)$
$$
\begin{align*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{fast}}(t)= & p_{3}\left(1-u_{\mathrm{abs}}(t)\right)^{p_{4}}\left(1-x_{\mathrm{fast}}(t)\right)  \tag{1d}\\
& -p_{5} u_{\mathrm{abs}}(t)
\end{align*}
$$
$$
\begin{equation*}
h_{\mathrm{MVIC}}(t)=x_{\text {slow }}(t) x_{\text {fast }}(t), \tag{1e}
\end{equation*}
$$
where
$$
\begin{equation*}
x:[0, T] \rightarrow[0,1]^{2} \tag{1f}
\end{equation*}
$$
consists of two dimensionless state variables $x_{\text {fast }}$ and $x_{\text {slow }}$. The model furthermore contains five dimensionless parameters $p_{i} \in[0, \infty)$ for $i \in\{1, \ldots, 5\}$ describing fatigue and recovery properties. The initial conditions for the states are given by
$$
\begin{equation*}
x(0)=x_{0} \in[0,1]^{2} . \tag{1~g}
\end{equation*}
$$

For an unfatigued muscle, one chooses $x_{0}=(1,1)^{\top}$. To simulate MVIC efforts, it is favorable to substitute
$$
\begin{equation*}
u_{\mathrm{abs}}(t)=u_{\mathrm{rel}}(t) h_{\mathrm{MVIC}}(t) \tag{1h}
\end{equation*}
$$
and use
$$
\begin{equation*}
u_{\mathrm{rel}}:[0, T] \rightarrow[0,1], \tag{1i}
\end{equation*}
$$
the load relative to the current force capacity, as input.
The model was validated with a comprehensive set of data from the elbow flexors [29]. We use the corresponding parameter estimates in this work.

\subsection*{3.3 Optimal control problem}

We use a multi-stage formulation on $n_{s} \geq 2$ stages-denoted by superscripts $i \in\left\{1, \ldots, n_{s}\right\}$-to model the resistance training sessions [29]. To include metrics for the TUT, the FTI, and the accumulated fatigue, we extend the model by three states tracking these quantities $x_{\mathrm{TUT}}, x_{\mathrm{FTI}}$, and $x_{\text {fatigue }}$. The general multi-stage optimal control problem can then be formulated as
$$
\begin{equation*}
\max _{x^{i}(\cdot), u_{\mathrm{abs}}^{i}(\cdot), T^{i}} \boldsymbol{\Phi}\left(x^{n_{s}}\left(T^{n_{s}}\right)\right) \tag{2a}
\end{equation*}
$$
$$
\begin{equation*}
\text { s.t. } x^{1}(0)=(1,1,0,0,0)^{\top} \tag{2b}
\end{equation*}
$$
$$
\begin{equation*}
x^{i}(0)=x^{i-1}\left(T^{i-1}\right) \text { for } i \in\left\{2, \ldots, n_{s}\right\} \tag{2c}
\end{equation*}
$$
$$
\begin{equation*}
\sum_{i=1}^{n_{s}} T^{i}=C_{T} \tag{2d}
\end{equation*}
$$
$$
\begin{equation*}
x_{\mathrm{TUT}}^{n_{s}}\left(T^{n_{s}}\right) \leq C_{\mathrm{TUT}} \tag{2e}
\end{equation*}
$$
$$
\begin{equation*}
x_{\mathrm{FTI}}^{n_{s}}\left(T^{n_{s}}\right) \leq C_{\mathrm{FTI}} \tag{2f}
\end{equation*}
$$
and for $i \in\left\{1,3, \ldots, n_{s}-2, n_{s}\right\}$ and $t \in\left[0, T^{i}\right]:$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\text {slow }}^{i}(t)=p_{1}\left(1-x_{\text {slow }}^{i}(t)\right)-p_{2} u_{\mathrm{abs}}^{i}(t) \tag{2g}
\end{equation*}
$$
$$
\begin{align*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{fast}}^{i}(t)= & p_{3}\left(1-u_{\mathrm{abs}}^{i}(t)\right)^{p_{4}}\left(1-x_{\mathrm{fast}}^{i}(t)\right)  \tag{2h}\\
& -p_{5} u_{\mathrm{abs}}^{i}(t)
\end{align*}
$$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{FTI}}^{i}(t)=u_{\mathrm{abs}}^{i}(t) \tag{2i}
\end{equation*}
$$
$$
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{TUT}}^{i}(t)=\left\{\begin{array}{l}
0 \text { if } u_{\mathrm{abs}}^{i}(t)=0  \tag{2j}\\
1 \text { else }
\end{array}\right.
$$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {fatigue }}^{i}(t)=1-h_{\text {MVIC }}^{i}(t) \tag{2k}
\end{equation*}
$$
$$
\begin{equation*}
u_{\text {low }} \leq u_{\text {abs }}^{i}(t) \leq h_{\text {MVIC }}^{i}(t) \tag{21}
\end{equation*}
$$
and for $i \in\left\{2,4, \ldots, n_{s}-3, n_{s}-1\right\}$ and $t \in\left[0, T^{i}\right]:$
$\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {slow }}^{i}(t)=p_{1}\left(1-x_{\text {slow }}^{i}(t)\right)$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {fast }}^{i}(t)=p_{3}\left(1-x_{\text {fast }}^{i}(t)\right) \tag{2n}
\end{equation*}
$$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {FTI }}^{i}(t)=0 \tag{2o}
\end{equation*}
$$
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {TUT }}^{i}(t)=0 \tag{2p}
\end{equation*}
$$
$\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {fatigue }}^{i}(t)=0$,
with $C_{T}$ being the total time and $C_{\mathrm{TUT}}$ and $C_{\mathrm{FTI}}$ the upper bounds on the total time-under-tension and the force-time integral. During odd numbered stages contractions with $u_{\text {low }} \leq u_{\text {abs }}$ are possible. Even numbered stages are considered rest periods. The duration $T^{i}$ of each stage is being optimized. We adapt this optimal control problem to different scenarios in the following. If not mentioned otherwise, all sessions last 20 min , allow $n_{c}=25$ possible contractions and have no restrictions on FTI or TUT. This implies $C_{T}= 1200 \mathrm{~s}, n_{s}=49$ and neglecting Constraints (2e) and (2f). Table 1 gives an overview of the symbols used in the problem formulation.

To solve the problems numerically, we employ a first-discretize-then-optimize strategy. We use the optimal control software MUSCOD-II [33, 34], which originates from the work of Bock and Plitt [13] and implements a direct multiple shooting approach to transcribe the problem to finitedimensional form. We employ a piecewise constant control discretization. To integrate the ODE system, we use a Runge-Kutta-Fehlberg method and generate the sensitivities via internal numerical differentiation [12]. The necessary derivatives of the model functions are generated via finitedifference approximations. The resulting nonlinear program is solved with a tailored structure-exploiting trust-region sequential quadratic programming method with limitedmemory block-updates of the Hessian. For details, we refer to the references above.

In the following, we present how this general optimal control problem formulation (2) is adapted to different sessions (labeled Session A to K). We refer to Table 2 for a concise overview.

\begin{table}
\captionsetup{labelformat=empty}
\caption{Table 1 Overview of symbols used in the multi-stage optimal control problem (2)}
\begin{tabular}{|l|l|}
\hline Symbol & Interpretation \\
\hline $C_{T}$ & Total time \\
\hline $C_{\text {FTI }}$ & Upper bound on total FTI \\
\hline $C_{\text {TUT }}$ & Upper bound on total TUT \\
\hline $h_{\text {MVIC }}^{i}$ & MVIC force \\
\hline $i$ & Stage index \\
\hline $x_{\text {TUT }}^{i}$ & Time-under-tension \\
\hline $x_{\text {FTI }}^{i}$ & Force-time integral \\
\hline $x_{\text {fatigue }}^{i}$ & Accumulated fatigue \\
\hline $n_{s}$ & Number of stages \\
\hline $p_{j}$ & Parameters \\
\hline $\Phi$ & Objective functional \\
\hline $t$ & Time \\
\hline $T^{i}$ & Stage duration \\
\hline $u_{\text {abs }}^{i}$ & External force \\
\hline $u_{\text {low }}$ & Lower bound on $u_{\text {abs }}$ \\
\hline $x_{\text {fast }}^{i}$ & State variable \\
\hline $x_{\text {slow }}^{i}$ & State variable \\
\hline
\end{tabular}
\end{table}

\subsection*{3.4 FTI-based goals}

Resistance training volume is an important determinant of long-term adaptations [24]. For isometric contractions, where no actual physical work is performed, the force-time integral is an often used analogue of work [42]. Thus, for Session A, we maximize the FTI accumulated during an RT session without imposing restrictions on the contraction intensity, i.e., $\boldsymbol{\Phi}(x)=x_{\text {FTI }}$ and $u_{\text {low }}=0$.

To increase maximum strength, high loads are recommended by some researchers, e.g., by the [1]. Therefore, the model has previously been used to compute an exemplary optimized RT session, which maximizes the FTI and ensures that the contraction intensity is higher than a minimum threshold intensity of $80 \%$ of baseline MVIC force [29]. We adopt this example and examine how lowering or raising the minimum threshold intensity influences the solution. For Session $\mathrm{B}_{70 \%}$, we set $\boldsymbol{\Phi}(x)=x_{\text {FTI }}$ and $u_{\text {low }}=0.7$. For Session $\mathrm{B}_{90 \%}$, we set $\boldsymbol{\Phi}(x)=x_{\text {FTI }}$ and $u_{\text {low }}=0.9$.

As an alternative to the full FTI maximized in Session A, one can use the FTI accumulated above the minimum threshold intensity as an indicator of effective training volume. For Session C, we thus set $u_{\text {low }}=0$ and replace Eq. (2i) with
$\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {FTI }}^{i}(t)=u_{\text {abs }}^{i}(t)-0.8$.

A similar measure has been used by Burnley [15] when examining work capacity above critical torque.

\begin{table}
\captionsetup{labelformat=empty}
\caption{Table 2 Overview of sessions used in this work. If not mentioned otherwise, all sessions last 20 min and allow 25 possible contractions}
\begin{tabular}{|l|l|l|l|l|}
\hline Session & Explanation & Objective & Constraints & Modified equations \\
\hline \multicolumn{5}{|l|}{FTI-based} \\
\hline A & Maximize FTI & $\Phi(x)=x_{\mathrm{FTI}}$ & $u_{\text {low }}=0$ & - \\
\hline $\mathrm{B}_{70 \%}$ & Maximize FTI while ensuring a minimum threshold intensity & $\Phi(x)=x_{\text {FTI }}$ & $u_{\text {low }}=0.7$ & - \\
\hline $\mathrm{B}_{90 \%}$ & Maximize FTI while ensuring a minimum threshold intensity & $\boldsymbol{\Phi}(x)=x_{\mathrm{FTI}}$ & $u_{\text {low }}=0.9$ & - \\
\hline C & Maximize FTI accumulated above a minimum threshold intensity & $\Phi(x)=x_{\mathrm{FTI}}$ & $u_{\text {low }}=0$ & $\frac{\mathrm{d}}{\mathrm{d} t} x_{\mathrm{FTI}}^{i}(t)=u_{\mathrm{abs}}^{i}(t)-0.8$ \\
\hline D 5 & Maximize FTI while ensuring a minimum threshold intensity with 5 possible contractions & $\Phi(x)=x_{\text {FTI }}$ & $u_{\text {low }}=0.8$ & - \\
\hline $\mathrm{D}_{50}$ & Maximize FTI while ensuring a minimum threshold intensity with 50 possible contractions & $\Phi(x)=x_{\text {FTI }}$ & $u_{\text {low }}=0.8$ & - \\
\hline E & Maximize a weighted version of FTI & $\Phi(x)=x_{\mathrm{FTI}}$ & $u_{\text {low }}=0$ & $\frac{\mathrm{d}}{\mathrm{d} t} x^{i}{ }_{\text {FTI }}(t)=\left(u_{\text {abs }}^{i}(t)\right)^{2}$ \\
\hline F & Maximize a weighted version of FTI & $\Phi(x)=x_{\mathrm{FTI}}$ & $u_{\text {low }}=0.8$ & $\frac{\mathrm{d}}{\mathrm{d} t} x^{i}{ }_{\mathrm{FTI}}(t)=\left(u_{\mathrm{abs}}^{i}(t)-0.8\right)^{2}$ \\
\hline \multicolumn{5}{|l|}{Fatigue-based} \\
\hline G & Maximize fatigue & $\Phi(x)=x_{\text {fatigue }}$ & $u_{\text {low }}=0$ & - \\
\hline H & Maximize fatigue while ensuring a minimum threshold intensity & $\Phi(x)=x_{\text {fatigue }}$ & $u_{\text {low }}=0.8$ & - \\
\hline I & Minimize fatigue to reach a certain FTI & $\Phi(x)=-x_{\text {fatigue }}$ & $u_{\text {low }}=0, C_{\mathrm{FTI}}=150$ & \\
\hline \multicolumn{5}{|l|}{TUT-based} \\
\hline J & Maximize TUT while ensuring a minimum threshold intensity & $\Phi(x)=x_{\mathrm{TUT}}$ & $u_{\text {low }}=0.8$ & - \\
\hline K & Maximize a weighted version of TUT & $\Phi(x)=x_{\text {TUT }}$ & $u_{\text {low }}=0.8$ & $\frac{\mathrm{d}}{\mathrm{d} t} x_{\text {TUT }}^{i}(t)= \begin{cases}0 & \text { if } u_{\text {abs }}^{i}(t)=0 \\ t & \text { else }\end{cases}$ \\
\hline
\end{tabular}
\end{table}

For Session D, we examine the influence of the number of possible contractions on Session B and compute the solution for $n_{c} \in\{5,6, \ldots, 49,50\}$ possible contractions. This allows to investigate if more but expectedly shorter contractions allow to accumulate a higher FTI while ensuring a minimum threshold intensity of $u_{\text {low }}=0.8$ and if the additional possible contractions are actually realized in the solution.

Instead of choosing a minimum threshold intensity, we can emphasize higher loads by evaluating a weighting function on the integrand of the FTI. For demonstration purposes, we choose a quadratic weighting function for Session E. Therefore, we set $\boldsymbol{\Phi}(x)=x_{\text {FTI }}$ and replace Eq. (2i) with
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{FTI}}^{i}(t)=\left(u_{\mathrm{abs}}^{i}(t)\right)^{2} . \tag{4}
\end{equation*}
$$
$u_{\text {low }}$ is set to 0 . A similar approach has been used by Arandjelović [6] to describe the hypertrophy stimulus of a resistance training set, although he used a sigmoid function, which can be interpreted as a smoothing of the constraint $u_{\text {low }} \leq u_{\text {abs }}$ used in Session B.

A similar weighting can be applied to Session C by replacing Eq. (2i) with
$$
\begin{equation*}
\frac{\mathrm{d}}{\mathrm{~d} t} x_{\mathrm{FTI}}^{i}(t)=\left(u_{\mathrm{abs}}^{i}(t)-0.8\right)^{2} \tag{5}
\end{equation*}
$$
and setting the objective functional to $\boldsymbol{\Phi}(x)=x_{\text {FTI }}$ for Session F . In contrast to Session C , $u_{\text {low }}=0.8$ is necessary here, as otherwise $u_{\mathrm{abs}}=0$ would be the solution.

\subsection*{3.5 Fatigue-based goals}

Effects of fatigue, e.g., metabolic stress or increased motor unit recruitment, have been attributed to trigger or positively influence muscle hypertrophy [44]. We examine which loading scheme maximizes fatigue, defined as the accumulated loss of MVIC force over time. Thus, for Session G, we choose $\boldsymbol{\Phi}(x)=x_{\text {fatigue }}$ and $u_{\text {low }}=0$.

For Session H, we maximize fatigue while ensuring a minimum threshold intensity of $80 \%$ of baseline MVIC force. Therefore, we choose $\boldsymbol{\Phi}(x)=x_{\text {fatigue }}$ and $u_{\text {low }}=0.8$.

In contrast to maximizing fatigue, it might also be desired to accumulate a certain amount of work while minimizing fatigue, e.g., during the tapering period before a competition. For Session I, we exemplarily choose $\Phi(x)=-x_{\text {fatigue }}$ and $C_{\text {FTI }}=150 \mathrm{~s}$.

\subsection*{3.6 TUT-based goals}

Several authors have examined time-under-tension as a determinant of acute responses and long-term adaptations to RT (e.g., [14] or [45]). Therefore, for Session J, we
maximize TUT while ensuring a minimum threshold intensity by choosing $\boldsymbol{\Phi}(x)=x_{\text {TUT }}$ and $u_{\text {low }}=0.8$.

Session J does not take into account the duration of the contractions used to accumulate the total TUT. However, some author have reported different adaptations to short and long duration contractions with greater hypertrophy occurring after long duration contractions [45]. Thus, to weight the duration of contractions quadratically, we replace Eq. (2j) with
$$
\frac{\mathrm{d}}{\mathrm{d} t} x^{i}{ }_{\text {TUT }}(t)=\left\{\begin{array}{l}0 \text { if } u_{\text {abs }}^{i}(t)=0  \tag{6}\\ t \text { else }\end{array}\right.
$$
for Session K. All other settings are kept as in Session J.

\section*{4 Results}

In the following, we provide the results of our computations. Here, we focus on the structure of the computed solutions. For readers who skipped the methods section, we redescribe the scenarios without the mathematical details. We refer to Table 2 for a concise overview. If not mentioned otherwise, all sessions last 20 min and allow 25 possible contractions.

\subsection*{4.1 FTI-based goals}

Resistance training volume is an important determinant of long-term adaptations [24]. For isometric contractions, where no actual physical work is performed, the force-time integral is an often used analogue of work [42]. Thus, for Session A, we maximize the FTI accumulated during an RT session without imposing restrictions on the contraction intensity. Figure 1a illustrates the model response obtained by simulating Session A.

To increase maximum strength, high loads are recommended by some researchers, e.g., by the [1]. Therefore, the model has previously been used to compute an exemplary optimized RT session, which maximizes the FTI and ensures that the contraction intensity is higher than a minimum threshold intensity of $80 \%$ of baseline MVIC force [29]. We adopt this example and examine how lowering or raising the minimum threshold intensity to $70 \%$ or $90 \%$ of baseline MVIC force influences the structure of the solution. Figure 1b, c illustrates the model response obtained by simulating Sessions $\mathrm{B}_{70 \%}$ and $\mathrm{B}_{90 \%}$.

For Session C, as an alternative to the full FTI maximized in Session A, one can use the FTI accumulated above the minimum threshold intensity as an indicator of effective training volume. A similar measure has been used by Burnley [15] when examining work capacity above critical torque. Figure 1d illustrates the model response obtained by simulating Session C.

For Session D, we examine the influence of the number of possible contractions on Session B and compute the solution for $5-50$ possible contractions. This allows to investigate if more but expectedly shorter contractions allow to accumulate a higher FTI while ensuring a minimum threshold intensity of $80 \%$ of baseline MVIC force and if the additional possible contractions are actually realized in the solution. Figure 1e, f illustrates the model response obtained by simulating Sessions $\mathrm{D}_{5}$ and $\mathrm{D}_{50}$. Figure 2 depicts the objective functional value in dependency of the number of possible contractions. Figure 3 depicts the durations of contractions and rests in dependency of the number of possible contractions. For all sessions, all 25 possible contractions are realized.

Instead of choosing a minimum threshold intensity, we can emphasize higher loads by evaluating a weighting function on the integrand of the FTI. For demonstration purposes, we choose a quadratic weighting function for Session E. A similar approach has been used by Arandjelović [6] to describe the hypertrophy stimulus of a resistance training set, although he used a sigmoid function, which can be interpreted as a smoothing of the constraint used in Session B. Figure 1g illustrates the model response obtained by simulating Session E.

For Session F, a similar quadratic weighting function can be applied to Session C. Figure 1h illustrates the model response obtained by simulating Session F.

\subsection*{4.2 Fatigue-based goals}

Effects of fatigue, e.g., metabolic stress or increased motor unit recruitment, have been attributed to trigger or positively influence muscle hypertrophy [44]. For Session G, we examine which loading scheme maximizes fatigue, defined as the accumulated loss of MVIC force over time. Figure 1i illustrates the model response obtained by simulating Session G.

For Session H, we maximize fatigue while ensuring a minimum threshold intensity of $80 \%$ of baseline MVIC force. Figure 1j illustrates the model response obtained by simulating Session H.

In contrast to maximizing fatigue, it might also be desired to accumulate a certain amount of work while minimizing fatigue, e.g., during the tapering period before a competition. For Session I, we model such a scenario. Figure 1k illustrates the model response obtained by simulating Session I.

\subsection*{4.3 TUT-based goals}

Several authors have examined time-under-tension as a determinant of acute responses and long-term adaptations to RT (e.g., [14] or [45]). Therefore, for Session J, we

\begin{figure}
\includegraphics[alt={},max width=\textwidth]{https://cdn.mathpix.com/cropped/22c6fa44-25fe-45bb-80b1-a11dea24b63a-08.jpg?height=2226&width=1685&top_left_y=193&top_left_x=193}
\captionsetup{labelformat=empty}
\caption{Fig. 1 Model response obtained by simulating Sessions A to $K$. We refer to the text and Table 2 for an explanation of the individual sessions. The left column depicts the model response. The absolute force input is illustrated in the right column.}
\end{figure}

\begin{figure}
\includegraphics[alt={},max width=\textwidth]{https://cdn.mathpix.com/cropped/22c6fa44-25fe-45bb-80b1-a11dea24b63a-09.jpg?height=2235&width=1694&top_left_y=184&top_left_x=191}
\captionsetup{labelformat=empty}
\caption{Fig. 1 (continued)}
\end{figure}

\begin{figure}
\includegraphics[alt={},max width=\textwidth]{https://cdn.mathpix.com/cropped/22c6fa44-25fe-45bb-80b1-a11dea24b63a-10.jpg?height=421&width=1685&top_left_y=193&top_left_x=193}
\captionsetup{labelformat=empty}
\caption{Fig. 1 (continued)}
\end{figure}

\begin{figure}
\includegraphics[alt={},max width=\textwidth]{https://cdn.mathpix.com/cropped/22c6fa44-25fe-45bb-80b1-a11dea24b63a-10.jpg?height=482&width=821&top_left_y=757&top_left_x=182}
\captionsetup{labelformat=empty}
\caption{Fig. 2 Dependency of the objective functional value on the number of possible contractions for Sessions $\mathrm{D}_{5}$ to $\mathrm{D}_{50}$. Increasing the number of possible contractions increases the FTI of the computed solution}
\end{figure}
maximize TUT while ensuring a minimum threshold intensity of $80 \%$ of baseline MVIC force. Figure 11 illustrates the model response obtained by simulating Session J.

Session J does not take into account the duration of the contractions used to accumulate the total TUT. However, some author have reported different adaptations to short and long duration contractions with greater hypertrophy
occurring after long duration contractions [45]. Thus, we weight the durations of contractions quadratically for Session K. All other settings are kept as in Session J. Figure 1m illustrates the model response obtained by simulating Session K.

\subsection*{4.4 Durations of contractions and rests}

Table 3 contains the minimum, the maximum, and the mean durations of the contractions and rests for all sessions plotted. To a certain extent, this allows to examine the real-life feasibility of the computed sessions.

\section*{5 Discussion}

\subsection*{5.1 Choice of training goals}

In general, a model-based approach is limited by the predictive ability of the employed model and the available numerical solution methods. As mentioned, the model of Herold et al. [29] offers a phenomenological description of muscular fatigue for different loading schemes and does not directly

\begin{figure}
\includegraphics[alt={},max width=\textwidth]{https://cdn.mathpix.com/cropped/22c6fa44-25fe-45bb-80b1-a11dea24b63a-10.jpg?height=578&width=1710&top_left_y=1796&top_left_x=175}
\captionsetup{labelformat=empty}
\caption{Fig. 3 Dependency of the durations of contractions (a) and rests (b) on the number of possible contractions for Sessions $\mathrm{D}_{5}$ to $\mathrm{D}_{50}$. The horizontal dashed lines illustrate the 1 s mark. Increasing the number}
\end{figure}
of possible contractions decreases the durations of contractions and rests of the computed solution

\begin{table}
\captionsetup{labelformat=empty}
\caption{Table 3 Minimum, maximum, and mean durations of contractions $\delta_{\mathrm{c}}$ and rests $\delta_{\mathrm{r}}$ for all sessions plotted. To a certain extent, this data allows to examine the real-life feasibility of the computed sessions}
\begin{tabular}{|l|l|l|l|l|l|l|}
\hline Session & $\min \left(\delta_{\mathrm{c}}\right)$ & $\max \left(\delta_{\mathrm{c}}\right)$ & $\operatorname{mean}\left(\delta_{\mathrm{c}}\right)$ & $\min \left(\delta_{\mathrm{r}}\right)$ & $\max \left(\delta_{\mathrm{r}}\right)$ & $\operatorname{mean}\left(\delta_{\mathrm{r}}\right)$ \\
\hline A & 19.21 & 465.46 & 60.54 & 1.96 & 8.76 & 6.49 \\
\hline $\mathrm{B}_{70 \%}$ & 6.24 & 33.28 & 11.41 & 28.63 & 45.64 & 38.11 \\
\hline $\mathrm{B}_{90 \%}$ & 1.62 & 9.13 & 3.04 & 33.02 & 56.96 & 46.83 \\
\hline C & 3.71 & 6.06 & 4.11 & 28.90 & 51.81 & 45.72 \\
\hline $\mathrm{D}_{5}$ & 14.94 & 20.00 & 17.14 & 184.96 & 376.31 & 278.57 \\
\hline $\mathrm{D}_{50}$ & 1.70 & 20.00 & 3.67 & 14.38 & 25.36 & 20.75 \\
\hline E & 16.10 & 62.36 & 26.06 & 7.15 & 25.63 & 22.86 \\
\hline F & 3.08 & 6.54 & 3.52 & 39.36 & 73.22 & 59.45 \\
\hline G & 1200.00 & 1200.00 & 1200.00 & 0.00 & 0.00 & 0.00 \\
\hline H & 4.30 & 21.76 & 6.97 & 20.57 & 54.54 & 42.74 \\
\hline I & 6.51 & 12.05 & 7.25 & 30.09 & 48.14 & 42.45 \\
\hline J & 3.69 & 21.76 & 6.99 & 30.57 & 51.91 & 42.72 \\
\hline K & 5.81 & 21.76 & 12.01 & 42.10 & 126.68 & 95.97 \\
\hline
\end{tabular}
\end{table}
link the RT input to a physiological adaptation of the trainee. Thus, when choosing the training goals, we are limited by key performance indicators accessible in the model. For this reason, we use assumptions from sport science about optimal training as objectives and constraints.

The three KPIs force-time integral, time-under-tension, and loss of MVIC force can readily be used in the optimal control problem formulations. Furthermore, we employ variants of these three KPIs to demonstrate how even slight modifications can change the structure of the solution. This highlights how important it is for exercise physiologists and sport scientists to identify the correct driving stimuli for adaptations to design optimized RT programs. Suitable physiological models would allow a more thorough search, e.g., by incorporating the build up of metabolites such as hydrogen ions and inorganic phosphate or by describing the activation of different fiber types.

\subsection*{5.2 Structure of the computed RT sessions}

While the resulting differences between the solutions might seem small at first, one should keep in mind that these differences accumulate during the course of an RT plan over weeks and months.

The results of Session D favor a higher number of contractions to accumulate more force-time integral in this scenario. This is in line with the solutions of most other sessions, in which all 25 possible contractions are realized. However, this is not the case for the solutions of Sessions A, F, G, and K. The results of Session A illustrate that the inclusion of rests is not beneficial during the beginning and the end of the session for this setting. To enable high contraction intensities, the solution of Session F consists of only 20 contractions. This is due to the fact that we weight the contraction intensities proportionally more than in the solution of Session C, where all 25 contractions are realized. The
solution of Session G describes a sustained MVIC effort, which is caused by choosing the accumulated loss of MVIC force as training goal. The solution of Session K only realizes 12 contractions in order to enable longer contraction durations compared to the solution of Session J. This can be verified by comparing the mean contractions duration of Session J and K, i.e., 6.99 s and 12.01 s (see Table 3).

Except for the solutions of Sessions H, J, and K, all solutions consist exclusively of MVIC efforts. This was unexpected, as we anticipated that submaximal contractions might allow a greater accumulation of training volume due to them inducing less fatigue. It would be interesting to examine if such a behavior also occurs for dynamic constant external RT. The solution of Session H exhibits an interesting behavior as the inclusion of a minimum threshold intensity now favors submaximal contractions compared to the MVIC efforts of the solution of Session G. This is possibly caused by the longer contraction durations, which then contribute more to the accumulated fatigue. Session I exhibits the same behavior as the MVIC efforts reduce the time necessary to accumulate the desired FTI. The same holds for the solutions of Sessions J and K, where the submaximal contractions allow a greater time-under-tension. The submaximal contractions are all held until muscle failure. In case this is not desired, this could be included into the optimization problem as a constraint. If a minimum threshold intensity was chosen, the MVIC efforts are conducted until this intensity is reached (see in particular Session B). Sessions C and F differ. Here, the contractions are terminated earlier as contractions with the minimum threshold intensity do not contribute to the chosen training goal. Session E demonstrates how a focus can be set on higher contraction durations without the use of a minimum threshold intensity.

A remark from a mathematical point of view: For all sessions, constraints limit the feasible region of the optimization problems and many constraints are active in the
solutions, e.g., maximum or minimum contraction intensities are attained, which is expected in an optimal control context. All chosen constraints are solely physiologically moti-vated-no artificial constraints have been introduced. However, due to the discretization of the constraints within the multiple shooting approach, the algorithm only guarantees that the constraints are met at the shooting nodes. In case of constraint violations between the shooting grid points, the grid can be refined easily to meet the requirements.

As already noticed during the model development [29], the grouping of repetitions into sets is not supported by our results. Instead, the contractions are spread more evenly over the whole time horizon to allow a greater accumulation of training volume, i.e., force-time integral. This is a similar approach to variants of so-called cluster sets [50], which allow to increase training volume by breaking up the traditional set-repetition structure. Here, the algorithmic optimization of durations of contractions and rests provides a clear advantage over intuitive planning.

\subsection*{5.3 Real-life feasibility of the computed RT sessions}

To ensure the real-life feasibility of the computed RT sessions, several aspects have to be taken into account. First, the duration of the contractions may not be too short, as the trainees need time to develop MVIC force. Second, the duration of the submaximal contractions may not be too long, as the concept of task failure or limited work capacity is currently not implemented into the model [29]. Third, the rest periods between submaximal contractions may not be too short, as the model also does not account for a regeneration of work capacity.

Kawakami et al. [31] examined 100 intermittent MVIC efforts lasting 1 s followed by 1 s rest of the triceps surae muscles and reported no problems in executing this task. Table 3 and Fig. 3 show that our solutions do not propose durations shorter than 1 s for contractions and rests. Although a different muscle group was used in the study of Kawakami et al. [31], their data demonstrates that such short intermittent contractions might be possible in general.

Yoon et al. [55] examined endurance times for sustained isometric contractions of the elbow flexors at 90 degrees joint angle and at $80 \%$ of MVIC force. Although the experimental setup differed slightly compared to that of the experiments used for the model validation [29] (forearm horizontal versus forearm vertical to the ground), the mean endurance times of 25.0 s for men and 24.3 s for women are consistent with the maximum duration of 21.76 s of our solutions for Sessions H, J, and K (see Table 3). To the best of our knowledge, no prediction of endurance time or work capacity exists for MVIC efforts. Caffier et al. [18], for example, examined MVIC efforts of several muscle groups lasting 10 min and reported no task failure among the participants.

Thus, it remains to be validated experimentally if the solutions of Session A, E, and G, which contain sustained MVIC efforts of long durations, can be realized in practice.

Although several authors have examined the recovery of endurance times (see, for example, the work of Stull and Kearney [47] or [32]) and work capacity (see, for example, the review by Jones and Vanhatalo [30]), to the best of our knowledge, no model of their time course exists that fulfills the prerequisites postulated for use in an optimization context [29]. Furthermore, we are not aware of any experimental data that rejects the feasibility of the solutions of Sessions $\mathrm{H}, \mathrm{J}$, and K due to too short rests. If this should be the case, lower bounds on the durations of the rests could be incorporated into the optimal control problem.

\section*{6 Limitations and future research}

As no fully suitable mathematical model for the more commonly used dynamic constant external resistance (DCER) training is available, we are optimizing isometric RT sessions. Research shows that the transfer from isometric RT to dynamic performance is questionable [39]. Therefore, we discourage direct transfer of our findings to DCER or other forms of training. However, an extension of our approach to DCER training is straightforward once suitable models become available. The same holds true for extensions to other indicators of muscle fatigue (e.g., power, contraction velocity, or muscular endurance), multiple exercises, or long-term planning.

Moreover, we are using parameters obtained from the elbow flexors, as so far those are the only ones available. For this reason, a comparison between muscle groups or participants is not possible at the moment. It would be intriguing to calibrate the model to different muscle groups and participants and then examine how the resulting parameters affect the optimized RT sessions. [35], for example, after analyzing fatigue and recovery patterns of MVIC torque of the knee extensors, conclude that individualizing training might be important to optimize performance. The authors used proton magnetic resonance spectroscopy to analyze muscle fiber typology of the gastrocnemius and then classify the participants into a slow- and a fast-twitch group for which they expected different patterns. With a modelbased approach, this classification could be formulated as a parameter estimation problem for which the necessary force measurements could be obtained in one testing session [28]. Afterwards, RT sessions could be optimized individually as proposed in this work.

Since we are using local optimization methods, modified initial guesses do not necessarily lead to identical results. Vanishing stages in the employed multi-stage formulation could lead to redundant discretized controls.

Thus, the computed solutions are neither globally optimal nor unique. However, considering that globally optimal solutions cannot be efficiently computed for problems of this type, starting from an initial (e.g., empirically derived) training design, the employed method generates an improved design that is locally optimal.

Last, we acknowledge that the model is validated with data from laboratory studies. Thus, we face the same problems as the original studies: the transfer from the laboratory to real-life RT needs to be verified experimentally. To this end, we outline two potential experimental setups in the following, which could be conducted together with interested practitioners from the sports sciences.

The first experiment is designed to verify if our modelbased approach allows to achieve a better objective functional value compared to an intuitive approach. For illustrative purposes, we choose Session B, which maximizes the FTI while ensuring a minimum threshold intensity using 25 contractions within 20 min . After the trainees have familiarized themselves with the dynamometer, a testing session is conducted to individually calibrate the model to the trainees' elbow flexors and obtain reliable parameter estimates [28]. After sufficient rest, the trainees are asked to intuitively perform a session, which they think to be optimal for the given task. An optimized session is then computed for each trainee and after resting sufficiently again, the trainees are asked to perform the optimized session. This order is chosen to prevent any learning effects. Afterwards, the data of the two sessions is analyzed and the objective functional values are compared. Furthermore, the real-life feasibility of the optimized sessions can be evaluated by computing the deviations of prescribed force and actual force.

After a successful first experiment, a second one could be conducted to examine whether the chosen objective function is beneficial for our training goal. However, this can only be done in comparison to another objective functional. For illustrative purposes, we compare Sessions $\mathrm{B}_{70 \%}$ and $\mathrm{B}_{90 \%}$ with regard to increasing maximum strength. To this end, trainees with the same level of RT experience are randomly assigned to three groups-a control group, a group following optimized training protocols for Session $\mathrm{B}_{70 \%}$, and a group following optimized training protocols for Session $\mathrm{B}_{90 \%}$. At the beginning of the experiment, an MVIC force test is conducted. This test is repeated at the end of the experiment and the results are analyzed. We emphasize that in this work the sessions are optimized independently of each other. Therefore, long-term planning has to be determined by the experimenters. Nutrition and recovery should be adequate and comparable among the trainees. If desired, the model parameters and the optimized sessions could be updated at any desired point in time.

\section*{7 Conclusion}

We demonstrate that a mathematical model-based approach could provide valuable impulses for practitioners and complement the predominant manual program design of loading schemes for RT. Although, the differences in the optimized sessions might seem small, one should keep in mind that those accumulate during the course of an RT plan over weeks and months.

With our approach, training protocols-either motivated by current practice or of a more exploratory and unconventional nature-could be examined at a large scale via forward simulations of the model. The flexible formulation of different training goals in terms of adjusted objective functions allows to evaluate the performance of training sessions in silico. Thus, training recommendations can be analyzed and rated with respect to their justification and efficiency without the tremendous testing efforts in actual trials.

As our approach is independent of the underlying model, we encourage researchers to develop and validate models, which are suitable for optimization and which connect the training input of different RT types directly to training goals such as increasing strength and power, hypertrophy, or increasing local muscular endurance. This would extend the possibilities to set up the optimization problems and might furthermore help to identify the driving mechanisms for long-term adaptations. Then, we could exploit the full potential of our approach.

In addition to a large variety of application areas, e.g., biomechanical movement analysis or the design of sports equipment, our work underlines and demonstrates the potential of quantitative mathematics to analyze and improve sports activities.

Acknowledgements JLH gratefully thanks Dr. Christian Kirches of the Institute for Mathematical Optimization, Technische Universität Carolo-Wilhelmina zu Braunschweig, Braunschweig, Germany for stimulating discussions on this topic. We furthermore would like to thank the anonymous reviewers for their comments on our manuscript.

Author contributions JLH conceived the idea for this work. JLH conducted the literature research, performed the numerical experiments, and drafted the manuscript. JLH and AS discussed and edited the draft. JLH and AS revised the manuscript. JLH and AS approved the final version of the manuscript.

Funding Open Access funding enabled and organized by Projekt DEAL. JLH acknowledges support from the Heidelberg Graduate School of Mathematical and Computational Methods for the Sciences (Graduate School 220), funded by the Deutsche Forschungsgemeinschaft (DFG) within the German Excellence Initiative. JLH furthermore acknowledges funding by the German Federal Ministry of Education and Research (BMBF) in the project 'Modeling, Optimization, and Control of Networks of Heterogeneous Energy Systems with Volatile Renewable Energy Production' (MOReNet, 05M18VHA). AS acknowledges funding by the German Ministry for Education and Research
(BMBF) in the project 'Model-based Optimization of Pharmaceutical Processes' (MOPhaPro, 05M16VHA).

\section*{Compliance with ethical standards}

Conflict of interest The authors declare that they have no conflict of interest.

Preprint A preprint of this work is available on bioRxiv. URL https:// www.biorxiv.org/content/10.1101/2020.04.16.044578v1. https://doi. org/10.1101/2020.04.16.044578.

Open Access This article is licensed under a Creative Commons Attribution 4.0 International License, which permits use, sharing, adaptation, distribution and reproduction in any medium or format, as long as you give appropriate credit to the original author(s) and the source, provide a link to the Creative Commons licence, and indicate if changes were made. The images or other third party material in this article are included in the article's Creative Commons licence, unless indicated otherwise in a credit line to the material. If material is not included in the article's Creative Commons licence and your intended use is not permitted by statutory regulation or exceeds the permitted use, you will need to obtain permission directly from the copyright holder. To view a copy of this licence, visit http://creativecommons.org/licenses/by/4.0/.

\section*{References}
1. American College of Sports Medicine (2009) American College of Sports Medicine Position Stand. Progression models in resistance training for healthy adults. Med Sci Sports Exerc 41(3):687. https://doi.org/10.1249/MSS.0b013e3181915670
2. Arandjelović O (2010) A mathematical model of neuromuscular adaptation to resistance training and its application in a computer simulation of accommodating loads. Eur J Appl Physiol 110(3):523-538. https://doi.org/10.1007/s00421-010-1526-3
3. Arandjelović O (2011) Optimal effort investment for overcoming the weakest point: new insights from a computational model of neuromuscular adaptation. Eur J Appl Physiol 111(8):1715-1723. https://doi.org/10.1007/s00421-010-1814-y
4. Arandjelović $\mathrm{O}(2012)$ Common variants of the resistance mechanism in the Smith machine: analysis of mechanical loading characteristics and application to strength-oriented and hypertrophyoriented training. J Strength Cond Res 26(2):350-363. https://doi. org/10.1519/JSC.0b013e318220e6d2
5. Arandjelović O (2013a) Computer simulation based parameter selection for resistance exercise. arXiv preprint arXiv:13064724. https://arxiv.org/abs/1306.4724
6. Arandjelović $\mathrm{O}(2013)$ Does cheating pay: the role of externally supplied momentum on muscular force in resistance exercise. Eur J Appl Physiol 113(1):135-145. https://doi.org/10.1007/s00421-012-2420-y
7. Arandjelović O (2017) Computer-aided parameter selection for resistance exercise using machine vision-based capability profile estimation. Augment Hum Res 2(1):4. https://doi.org/10.1007/ s41133-017-0007-1
8. Atkinson G, Peacock O, Passfield L (2007) Variable versus constant power strategies during cycling time-trials: prediction of time savings using an up-to-date mathematical model. J Sports Sci 25(9):1001-1009. https://doi.org/10.1080/02640410600944709
9. Banister EW, Calvert TW, Savage MV, Bach TM (1975) A system model of training for athletic performance. Aust J Sports Med 7(3):57-61
10. Benzekry S, Lamont C, Beheshti A, Tracz A, Ebos JML, Hlatky L, Hahnfeldt P (2014) Classical mathematical models for description
and prediction of experimental tumor growth. PLOS Comput Biol 10(8):1-19. https://doi.org/10.1371/journal.pcbi. 1003800
11. Bird SP, Tarpenning KM, Marino FE (2005) Designing resistance training programmes to enhance muscular fitness: a review of the acute programme variables. Sports Med 35(10):841-851. https:// doi.org/10.2165/00007256-200535100-00002
12. Bock HG (1981) Numerical treatment of inverse problems in chemical reaction kinetics. In: Ebert KH, Deuflhard P, Jäger W (eds) Modelling of chemical reaction systems: proceedings of an International Workshop, Heidelberg, Fed. Rep. of Germany, September 1-5, 1980. Springer, Berlin, pp 102-125. https://doi. org/10.1007/978-3-642-68220-9_8
13. Bock HG, Plitt KJ (1984) A multiple shooting algorithm for direct solution of optimal control problems. In: Proceedings of the 9th IFAC World Congress, Pergamon Press, Oxford, pp 1603-1608. https://doi.org/10.1016/s1474-6670(17)61205-9
14. Burd NA, Andrews RJ, West DW, Little JP, Cochran AJ, Hector AJ, Cashaback JG, Gibala MJ, Potvin JR, Baker SK, Phillips SM (2012) Muscle time under tension during resistance exercise stimulates differential muscle protein sub-fractional synthetic responses in men. J Physiol 590(2):351-362. https://doi. org/10.1113/jphysiol.2011.221200
15. Burnley M (2009) Estimation of critical torque using intermittent isometric maximal voluntary contractions of the quadriceps in humans. J Appl Physiol 106(3):975-983. https://doi.org/10.1152/ japplphysiol.91474.2008
16. Busso T, Häkkinen K, Pakarinen A, Carasso C, Lacour JR, Komi PV, Kauhanen H (1990) A systems model of training responses and its relationship to hormonal responses in elite weight-lifters. Eur J Appl Physiol Occup Physiol 61(1):48-54. https://doi. org/10.1007/BF00236693
17. Busso T, Häkkinen K, Pakarinen A, Kauhanen H, Komi PV, Lacour JR (1992) Hormonal adaptations and modelled responses in elite weightlifters during 6 weeks of training. Eur J Appl Physiol Occup Physiol 64(4):381-386. https://doi.org/10.1007/BF00636228
18. Caffier G, Rehfeldt H, Kramer H, Mucke R (1992) Fatigue during sustained maximal voluntary contraction of different muscles in humans: dependence on fibre type and body posture. Eur J Appl Physiol Occup Physiol 64(3):237-243. https://doi.org/10.1007/ BF00626286
19. Calvert TW, Banister EW, Savage MV, Bach T (1976) A systems model of the effects of training on physical performance. IEEE Trans Syst Man Cybern 2:94-102. https://doi.org/10.1109/ tsmc.1976.5409179
20. Clarke DC, Skiba PF (2013) Rationale and resources for teaching the mathematical modeling of athletic training and performance. Adv Physiol Educ 37(2):134-152. https://doi.org/10.1152/advan .00078.2011
21. Crewther B, Cronin J, Keogh J (2005) Possible stimuli for strength and power adaptation. Sports Med 35(11):967-989. https://doi. org/10.2165/00007256-200535110-00004
22. Eriksson A, Nordmark A (2011) Activation dynamics in the optimization of targeted movements. Comput Struct 89(11):968-976. https://doi.org/10.1016/j.compstruc.2011.01.019
23. Eriksson A, Holmberg HC, Westerblad H (2016) A numerical model for fatigue effects in whole-body human exercise. Math Comput Model Dyn Syst 22(1):21-38. https://doi. org/10.1080/13873954.2015.1083592
24. Fleck SJ, Kraemer W (2014) Designing resistance training programs, 4E. Human Kinetics. https://books.google.com/books ?id=CczZAgAAQBAJ
25. Gacesa JP, Ivancevic T, Ivancevic N, Paljic FP, Grujic N (2010) Non-linear dynamics in muscle fatigue and strength model during maximal self-perceived elbow extensors training. J Biomech 43(12):2440-2443. https://doi.org/10.1016/j.jbiom ech.2010.04.034
26. Gatti CJ, Scibek J, Svintsitski O, Carpenter JE, Hughes RE (2008) An integer programming model for optimizing shoulder rehabilitation. Ann Biomed Eng 36(7):1242-1253. https://doi. org/10.1007/s10439-008-9491-2
27. Hatz K (2014) Efficient numerical methods for hierarchical dynamic optimization with application to cerebral palsy gait modeling. Dissertation, Heidelberg University. https://doi. org/10.11588/heidok.00016803,
28. Herold JL, Sommer A (2020) A model-based estimation of critical torques reduces the experimental effort compared to conventional testing. Eur J Appl Physiol. https://doi.org/10.1007/s00421-020-04358-w
29. Herold JL, Kirches C, Schlöder JP (2018) A phenomenological model of the time course of maximal voluntary isometric contraction force for optimization of complex loading schemes. Eur J Appl Physiol 118(12):2587-2605. https://doi.org/10.1007/s00421-018-3983-z
30. Jones AM, Vanhatalo A (2017) The 'Critical Power' concept: applications to sports performance with a focus on intermittent high-intensity exercise. Sports Med 47(1):65-78. https://doi. org/10.1007/s40279-017-0688-0
31. Kawakami Y, Amemiya K, Kanehisa H, Ikegawa S, Fukunaga T (2000) Fatigue responses of human triceps surae muscles during repetitive maximal isometric contractions. J Appl Physiol 88(6):1969-1975. https://doi.org/10.1152/jappl.2000.88.6.1969
32. Kroon GW, Naeije M (1991) Recovery of the human biceps electromyogram after heavy eccentric, concentric or isometric exercise. Eur J Appl Physiol Occup Physiol 63(6):444-448. https:// doi.org/10.1007/BF00868076
33. Leineweber DB, Bauer I, Bock HG, Schlöder JP (2003) An efficient multiple shooting based reduced SQP strategy for largescale dynamic process optimization. Part 1: theoretical aspects. Comput Chem Eng 27(2):157-166. https://doi.org/10.1016/S0098 -1354(02)00158-8
34. Leineweber DB, Schäfer A, Bock HG, Schlöder JP (2003) An efficient multiple shooting based reduced SQP strategy for largescale dynamic process optimization. Part II: software aspects and applications. Comput Chem Eng 27(2):167-174. https://doi. org/10.1016/S0098-1354(02)00195-3
35. Lievens E, Klass M, Bex T, Derave W (2020) Muscle fiber typology substantially influences time to recover from high-intensity exercise. J Appl Physiol. https://doi.org/10.1152/japplphysiol.00636.2019
36. Mader A (1988) A transcription-translation activation feedback circuit as a function of protein degradation, with the quality of protein mass adaptation related to the average functional load. J Theor Biol 134(2):135-157. https://doi.org/10.1016/S0022 -5193(88)80198-X
37. Mader A (1990) Aktive Belastungsadaptation und Regulation der Proteinsynthese auf zellulärer Ebene. Deutsche Zeitschrift für Sportmedizin 41(2):40-58. https://www.bisp-surf.de/Record/ PU1990040421614
38. Oberkampf WL, Roy CJ (2010) Verification and validation in scientific computing. Cambridge University Press, Cambridge, https://doi.org/10.1017/cbo9780511760396
39. Oranchuk DJ, Storey AG, Nelson AR, Cronin JB (2019) Isometric training and long-term adaptations: effects of muscle length, intensity, and intent: a systematic review. Scand J Med Sci Sports 29(4):484-503. https://doi.org/10.1111/sms. 13375
40. Philippe AG, Py G, Favier FB, Sanchez AM, Bonnieu A, Busso T, Candau R (2015) Modeling the responses to resistance training in an animal experiment study. BioMed Res Int. https://doi. org/10.1155/2015/914860
41. Philippe AG, Borrani F, Sanchez AM, Py G, Candau R (2019) Modelling performance and skeletal muscle adaptations with exponential growth functions during resistance training. J Sports Sci 37(3):254-261. https://doi.org/10.1080/02640414.2018.1494909
42. Rozand V, Cattagni T, Theurel J, Martin A, Lepers R (2015) Neuromuscular fatigue following isometric contractions with similar
torque time integral. Int J Sports Med 36(01):35-40. https://doi. org/10.1055/s-0034-13756149
43. Schaefer D, Asteroth A, Ludwig M (2015) Training plan evolution based on training models. In: 2015 international symposium on innovations in intelligent systems and applications (INISTA), IEEE, pp 1-8. https://doi.org/10.1109/INISTA.2015.7276739
44. Schoenfeld BJ (2010) The mechanisms of muscle hypertrophy and their application to resistance training. J Strength Cond Res 24(10):2857-2872. https://doi.org/10.1519/JSC.0b013e3181e840f 3
45. Schott J, McCully K, Rutherford OM (1995) The role of metabolites in strength training. Eur J Appl Physiol Occup Physiol 71(4):337-341. https://doi.org/10.1007/BF002404141
46. Spiess AN, Neumeyer N (2010) An evaluation of R2 as an inadequate measure for nonlinear models in pharmacological and biochemical research: a Monte Carlo approach. BMC Pharmacol 10(1):6. https://doi.org/10.1186/1471-2210-10-62
47. Stull GA, Kearney JT (1978) Recovery of muscular endurance following submaximal, isometric exercise. Med Sci Sports 10(2):109-112. https://europepmc.org/article/med/6922993
48. Toigo M, Boutellier U (2006) New fundamental resistance exercise determinants of molecular and cellular muscle adaptations. Eur J Appl Physiol 97(6):643-663. https://doi.org/10.1007/s0042 1-006-0238-14
49. Torres M, Trexler ET, Smith-Ryan AE, Reynolds A (2017) A mathematical model of the effects of resistance exercise-induced muscle hypertrophy on body composition. Eur J Appl Physiol. https://doi.org/10.1007/s00421-017-3787-6
50. Tufano JJ, Brown LE, Haff GG (2017) Theoretical and practical aspects of different cluster set structures: a systematic review. J Strength Cond Res 31(3):848-867. https://doi.org/10.1519/ JSC. 0000000000001581
51. Ullmer S, Mader A (1992) A mathematical model of regulation of protein synthesis by activation feedback: some reflections on its possibilities and limits in describing muscle mass adaptations with exercise. Integration of medical and sports sciences, vol 37. Karger Publishers, Basel, pp 288-298. https://doi. org/10.1159/000421575
52. Williams MA, Haskell WL, Ades PA, Amsterdam EA, Bittner V, Franklin BA, Gulanick M, Laing ST, Stewart KJ (2007) Resistance exercise in individuals with and without cardiovascular disease: 2007 update. Circulation 116(5):572-584. https://doi. org/10.1161/CIRCULATIONAHA.107.185214
53. Wisdom KM, Delp SL, Kuhl E (2015) Use it or lose it: multiscale skeletal muscle adaptation to mechanical stimuli. Biomech Model Mechanobiol 14(2):195-215. https://doi.org/10.1007/ s10237-014-0607-3
54. Wood RE, Hayter S, Rowbottom D, Stewart I (2005) Applying a mathematical model to training adaptation in a distance runner. Eur J Appl Physiol 94(3):310-316. https://doi.org/10.1007/s0042 1-005-1319-2
55. Yoon T, Schlinder Delap B, Griffith EE, Hunter SK (2007) Mechanisms of fatigue differ after low- and high-force fatiguing contractions in men and women. Muscle Nerve 36(4):515-524. https:// doi.org/10.1002/mus. 20844
56. Zhou X, Roos PE, Chen X (2018) Modeling of muscle atrophy and exercise induced hypertrophy. Springer International Publishing, Cham, pp 116-127. https://doi.org/10.1007/978-3-319-60591-3
57. Zignoli A, Biral F (2020) Prediction of pacing and cornering strategies during cycling individual time trials with optimal control. Sports Eng. https://doi.org/10.1007/s12283-020-00326-x

Publisher's Note Springer Nature remains neutral with regard to jurisdictional claims in published maps and institutional affiliations.