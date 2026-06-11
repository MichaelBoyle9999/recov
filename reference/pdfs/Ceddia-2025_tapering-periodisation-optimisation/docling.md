## Mathematical Modelling and Optimisation of Athletic Performance: Tapering and Periodisation

David Ceddia ∗ , Howard Bondell, Peter Taylor

School of Mathematics and Statistics The University of Melbourne

## Abstract

We conduct a mathematical optimisation of the training load to maximise performance for two seminal athletic performance models: the Banister et al. 1975 Fitness-Fatigue Impulse Response Model [3] and the Busso 2003 Variable Dose-Response Model [10]. We discuss discrepancies in the general trends of the optimised training loads compared to common training practices recommended in the sports science literature, such as tapering and periodisation. We then propose a set of interpretable nonlinear modifications in the magnitude and time response to training in the fitness-fatigue model such that the optimised training load demonstrates these trends.

## 1 Introduction

Physical activity offers numerous health benefits, including links to improved strength, balance, flexibility, cognitive function, mood, and immunity, as well as reduced risks of certain cancers, osteoporosis, coronary heart disease, stroke, type-2 diabetes, Alzheimer's disease and dementia [37, 38, 39]. Moderation is key, however, as excessive exercise can lead to overtraining, injury and mental health issues [37, 28]. Accurately quantifying the effects of training can be used equally to optimise elite athlete training to maximise performance and by lay individuals to maximise training efficiency, whilst, in both cases, also reducing the risk of overtraining.

Beyond individual interests, quantifying training effects has benefits for society as a whole by acting as a preventive healthcare measure and eliminating the associated costs. Moreover, having an individualised model of training also aligns with the contemporary shift toward individualised medicine and personalised healthcare [22], where these models may be incorporated into existing technologies such as activity- and fitness-tracking wearable devices or mobile phone applications and applied to an individual's data or optimised to an individual's constraints.

The current overarching theory behind the process of adaptation is the General Adaptation Syndrome (GAS) model [41, 17]. The model is qualitative rather than quantitative. It illustrates that, in response to a stressor, an individual will go through phases of initial fatigue, recovery and finally, performance improvement or adaptation. If the stimulus is maintained for too long, however, then a period of performance decline or overtraining will occur.

Within the body of sports science literature, there exists many documented experimental studies and written descriptions of an individual's capacity to adapt to a training stimulus. Key phenomena described in these accounts include the performance benefits of a warm-up [21], Post Activation Performance Enhancement (PAPE) [49, 6] and active recovery [7]. Research also concentrates on characterising repetitions and sets in the case of resistance training [16, 48], contrasts intervals and steady-state training in the case of endurance training [18, 31], and looks at the interference effect of concurrent resistance and endurance training [50]. Additional topics include training to a sub-maximal effort and periodisation [20, 8], tapering [35, 36, 9, 29]

∗ Corresponding author e-mail: d.ceddia@unimelb.edu.au

and injury prevention or predicting injury risk [5, 23]. Although this selection of literature reveals substantial insights, our understanding necessarily remains incomplete without an encompassing quantitative model that includes these principles.

The first widely acknowledged quantitative model of athletic performance in the academic literature is the Banister et al. Fitness-Fatigue Impulse Response Model (FFM) [3, 15, 33, 11]. Since 1975, this, and variants, have been applied to: swimming [3, 34, 24, 43], running [33], weight lifting [14], cycling [12, 13], hammer throwing [11], triathlons [4, 32], gymnastics [40] and judo [1]. Despite describing a relationship between training stimulus and change in performance, these models have yet to reach the point of being a practical predictive tool.

Some recent research has moved away from mechanistically motivated models and instead use statistical tools to capture correlations between raw athlete-training data and performance outcomes. These inferencebased investigations used methods such as multivariate-linear regression with a mixed-effect [2], Elastic Net (a combination of Ridge and LASSO penalisation), Principal Component Regression (PCR); Random Forest models [26], latent variable dose-response modelling [47] or machine learning [27]. We argue, however, that it is fruitful to retain mechanistically motivated models and consider modifications to improve its effectiveness as a practical predictive tool.

We will show that the current FFMs lack the necessary nonlinear components that ensure when we optimise the training load under these models, we see behaviour that is consistent with common elite athlete training, such as periodisation and tapering. There can be one of two reasons for this discrepancy:

1. the models do not incorporate all the relevant effects,
2. the commonly understood training behaviour is not optimal.

In this paper, we consider modifications to these models that produce periodisation and tapering in the training load that maximises performance.

In Section 2, we introduce the Banister et al. Fitness-Fatigue Impulse Response Model and the Busso Variable Dose-Response Model, which employ the concept of a training load. In Section 3, we numerically optimise the Banister and Busso models, explore their prediction for the optimum training load which maximises performance and discuss shortcomings. In Section 4, we systematically introduce interpretable nonlinear modifications to the model to elicit trends in the optimised training load that is consistent with common elite athlete training practices, such as tapering and periodisation. In Section 5, we present our conclusions.

## 2 Existing Athletic Performance Models and Training Load Framework

## Banister et al.'s Fitness-Fatigue Impulse Response Model

The FFM proposed by Banister et al. in 1975 [3, 15] and subsequently refined in [33, 11] expresses the performance P in terms of a continuous time, one dimensional training variable w via the equation

$$P ( t ) = P _ { 0 } + \int _ { 0 } ^ { t } w ( t ^ { \prime } ) g ( t - t ^ { \prime } ) d t ^ { \prime } ,$$

$$g ( t ) = k _ { 1 } \exp \left ( - \frac { t } { \tau _ { 1 } } \right ) - k _ { 2 } \exp \left ( - \frac { t } { \tau _ { 2 } } \right )$$

is known as the transfer function, P 0 is a baseline performance, k 1 is the magnitude of fitness gains from a unit of training, k 2 is the magnitude of fatigue incurred by a unit of training, and τ 1 and τ 2 are time constants that control the decay of the fitness and fatigue response, respectively. An important simplifying step is to notice that the training time frame is relatively small compared to the resting time frame, which allows a continuous time training session to be summarised by a discrete one-dimensional training impulse w that quantifies its impact. For an illustrative comparison of the training to resting time frames, see Fig. 1. In

where this, we see a single training session viewed on a timescale of its duration, the same training session viewed on the timescale of a day, and the same training session, repeated Tuesday, Thursday and Saturday, viewed on the timescale of a week. As such, the integral over continuous time in (1) is mostly zero and the non-zero contributions can be captured as a discrete sum of one-dimensional training impulses.

In Banister et al.'s original work [3, 15], the authors studied the change in performance of a swimmer and quantified the training impulse using a 3-tier weighting system based on intensity for each 100m swum. Warm-up intensity was awarded 1 arbitrary training unit (ATU) per 100m swum, low intensity was awarded 2 ATUs per 100m swum and high intensity was awarded 3 ATUs per 100m swum. A training impulse for each session was then calculated by summing up the weights for each 100m swum. Additionally, weight training was taken into account via the estimation that 500 lightweight pulls was considered equivalent to 1000m of high-intensity swimming or 30 ATUs. An assortment of subsequent definitions have since come along, some such being: the heart rate (HR) system w = D (∆HR Ratio), where D is the training duration and (∆HR Ratio) = (HR av -HR rest ) / (HR max -HR rest ) [33]; or to apply weightings of 1,2,3,4,5 in a five-HRzones, linear system [19]; or weights of 1,2,3,5,8 in a five-lactate-zones, approximately exponential system [34]; or weights of 1,2,3 in a three-HR-zones, linear system (1 &lt; aerobic threshold, 2 between thresholds, 3 &gt; anaerobic threshold) [30]. The particular training impulse formula chosen will be context-dependent, and a discussion of which is most appropriate is outside of the scope of this paper. We simply note that training is often summarised by a single number. Our interest lies in exploring the mathematical ramifications of this. Note, with respect to terminology, we will refer to a single peak as a 'training impulse', and use 'training load' to refer to a sequence or collection of training impulses.

Figure 1: Illustration of the training impulse approximation. (a) Training velocity as a function of time. (b) Same, but viewed on the timescale of a day. (c) Same, but repeated on Tuesday, Thursday and Saturday, viewed on the timescale of a week.

<!-- image -->

The discrete version of (1) is

$$P ( n ) = P _ { 0 } + \sum _ { i = 1 } ^ { n - 1 } w ( i ) \left [ k _ { 1 } \exp \left ( - \frac { ( n - i ) } { \tau _ { 1 } } \right ) - k _ { 2 } \exp \left ( - \frac { ( n - i ) } { \tau _ { 2 } } \right ) \right ]$$

where P ( n ) is the predicted performance on day n ∈ Z + , w ( i ) is the training impulse for a given day and i sums over all prior contributions to the day of interest. Physiologically speaking, τ 1 and τ 2 control the time frames associated with detraining and recovery. Mathematically speaking, they govern the temporal delay in the correlation between a training load and a change in performance, while k 1 and k 2 are representative of the magnitude of the correlation between a training load and a change in performance. Henceforth, we will refer to (2) as the Banister model, the cumulative positive impulse response, F ( n ) = ∑ n -1 i =1 k 1 w ( i ) exp ( -( n -i ) /τ 1 ), as the fitness and the cumulative negative impulse response, f ( n ) = ∑ n -1 i =1 k 2 w ( i ) exp ( -( n -i ) /τ 2 ), as the fatigue. Additionally, we emphasise that w ( i ) is a training impulse and the exponential decay is the impulse response.

It is worth emphasising that not all physiological phenomena take place on time scales appropriate to be accurately captured by a daily training impulse, for example, a warm-up. Moreover, with the definition of training impulse, there now exists an ambiguity in the discernment of intensity and duration, which complicates the reverse process of going from an optimised training load, to an actual training program.

Nonetheless, the construction of a daily training impulse does capture phenomena that persist from one training session to the next, and it can aid in the prediction of things such as periodisation and tapering strategies.

Given the model in (2), one can calculate two timepoints of interest. The first is the time

$$t _ { r } = \left ( \frac { \tau _ { 1 } \tau _ { 2 } } { \tau _ { 1 } - \tau _ { 2 } } \right ) \ln \left ( \frac { k _ { 2 } } { k _ { 1 } } \right )$$

until the impulse response reaches a break-even point, after which a positive return is made. This is found by taking the positive, fitness impulse and the negative, fatigue impulse and solving for the time at which the two are equal. For the case that k 1 &gt; k 2 , the break-even point solution will be non-positive (i.e. the immediate benefit outweighs the cost and no time delay is required to realise the training benefit). In the case that k 1 &lt; k 2 , the break-even point will be some positive time in the future. The second time of interest,

$$t _ { p } = \left ( \frac { \tau _ { 1 } \tau _ { 2 } } { \tau _ { 1 } - \tau _ { 2 } } \right ) \ln \left ( \frac { k _ { 2 } \tau _ { 1 } } { k _ { 1 } \tau _ { 2 } } \right )$$

is the time it takes the impulse response to reach a peak. This is found by taking the time derivative of the combined fitness-fatigue impulse response and solving for the time t p where it is equal to zero.

Applying the Banister model to time-series training load and performance data involves estimating the model parameters. Typically, this is done by fitting the model to minimise the Residual Sum of Squares (RSS) between predicted and actual performance measurements for a given set of training load data [12, 13]. To give an idea as to how this model performs in an applied context, consider the findings of [24] which applied the Banister model to nine swimmers and found that the change in performance was related to the training load distribution for all participants. A mean value of 0.79 for the coefficient of determination, r 2 , was obtained for the nine swimmers, with a standard deviation of 0.13 and a range of [0.61, 0.97].

## Busso's Variable Dose-Response Model

The Banister model is linear in training load, which implies that all training is equally effective at generating a fitness gain, regardless of the training history that preceded it. A significant development on the Banister model is Busso's Variable Dose-Response model [10] which introduces a nonlinear fatigue response. This model captures the idea that fatigue is compounding as subsequent challenging training days are sustained. The model takes the form

$$P ( n ) = P _ { 0 } + \sum _ { i = 1 } ^ { n - 1 } w ( i ) \left [ k _ { 1 } \exp \left ( - \frac { ( n - i ) } { \tau _ { 1 } } \right ) - k _ { 2 } ( i ) \exp \left ( - \frac { ( n - i ) } { \tau _ { 2 } } \right ) \right ] ,$$

where

$$k _ { 2 } ( i ) = \sum _ { j = 1 } ^ { i - 1 } w ( j ) k _ { 3 } \exp \left ( - \frac { ( i - j ) } { \tau _ { 3 } } \right ) ,$$

denotes the variable magnitude of fatigue incurred by a unit of training on day i ; k 3 and τ 3 are the magnitude and time constants that control the variable fatigue-magnitude response. In other words, the fatigue generated at the current time due to a training impulse is governed by a memory of recent training impulses, the amount and duration of which are determined by k 3 and τ 3 . In a contemporary study comparing several statistical tools applied to training data and performance outcomes, this model was used as the benchmark athletic performance model from which to gauge the various modelling approaches' effectiveness [26]. Henceforth, we will refer to (5) as the Busso model.

## 3 Optimisation of the Banister and Busso Models

We underscore the importance and practicality of the simplifying assumption introduced by Banister et al. in [3, 15], that both training load and performance are expressed as a function of discrete days where training is summarised by a one-dimensional variable w .

Consider the training load leading up to day n , a prioritised performance time point in the future, denoted by w = ( w (1) , . . . , w ( n -1)). Using either the Banister model defined in (2) or Busso model defined in (5), we can obtain a prediction for an athlete's performance on day n . A natural question for sports scientists to ask is, 'What training load should an athlete adopt to maximise their performance on day n ?' Mathematically speaking, this translates to solving the optimisation problem

$$\max _ { w } \ P ( n ) .$$

We note that neither the Banister nor Busso model have bounds on the daily training impulse w ( i ), which means that there is no upper bound on the level of performance P ( n ) that can be achieved on day n . For the optimisation in (6) to be a well-posed, bounded optimisation problem, we require a constraint on the maximum possible training impulse per day. We propose that w ( i ) should be subject to the constraints

$$0 \leq k _ { 2 } ( i ) w ( i ) \leq P ( i ) \ \text { for all } i \in \{ 1 , 2 , \dots , n - 1 \} .$$

This ensures that we cannot do negative training, nor can the fatigue incurred from training exceed the predicted performance of that day. Put another way, given that fatigue is measured in performance loss, we cannot lose more performance than we have.

We note that the constraints in (7) impose quite a severe upper bound on the maximum training impulse. Whilst this upper limit is consistent with the model's interpretation, it is unlikely that this is the point that one should realistically train to. Instead, we suspect the upper limit is often characterised by a compromise between wanting more training whilst not wanting to acquire an injury. Without wanting to introduce additional assumptions regarding this trade-off, however, we will use the upper bound that is mathematically consistent with the model's interpretation for this work.

Observing that the Banister model and the constraints are linear in the training load w , to solve the optimisation problem above we used linear programming - specifically, we used MATLAB's inbuilt function 'linprog'. On the other hand, the Busso model is nonlinear in w , and so we treated the optimisation problem above as a constrained, nonlinear optimisation problem. Here, we solved all nonlinear optimisation problems using MATLAB's inbuilt 'fmincon'. This is a gradient-based algorithm that finds a local optimum. By using a variety of starting values, an estimate of the global optimum can be obtained by selecting the maximum from the resulting set of local optima. We can also assess our confidence in our estimate of the global optimum by examining characteristics of the set of local optima; for example, a consistent outcome, or a tightly clustered outcome, suggests that the maximum is robust to initial conditions and may be close to the true global optimum.

## The Banister Model

In order to solve the optimisation problem in (6), subject to the constraints in (7), we used the parameter values from [12]. This study followed eight participants' training and performance on a cycloergometer over fourteen weeks and fit the Banister model to this experimental data. Using the mean values of the model parameters in Table 3 of [12], we calculated the training load that leads to the greatest improvement in performance in 28 days, Fig. 2.

In the experiment, the participants experienced an average improvement of 33.3 PU (Performance Units) from 104.8 PU to 138.1 PU over fourteen weeks under their prescribed training program. The optimisation predicts, however, that if they used the program depicted in Fig. 2, in only four weeks, an improvement of 6020.2 PU from 104.8 PU to 6125 PU should have been possible.

In Fig. 2, optimisation of the training load to maximise performance under the Banister model yielded the result, that the best possible training program is to train every day to the maximum allowable amount (that is, until the fatigue incurred k 2 w ( i ) matched the predicted performance P ( i )) until the time t r given in (3), and then cease all training. Indeed, based on numerous simulations, we conjecture that the training load

$$w ^ { * } ( i ) = \begin{cases} \frac { P ( i ) } { k _ { 2 } } = \frac { 1 } { k _ { 2 } } \left [ P _ { 0 } + \sum _ { \ell = 1 } ^ { i - 1 } w ^ { * } ( \ell ) \left ( k _ { 1 } \exp \left ( - \frac { ( i - \ell ) } { \tau _ { 1 } } \right ) - k _ { 2 } \exp \left ( - \frac { ( i - \ell ) } { \tau _ { 2 } } \right ) \right ) \right ] , & \text { for all } n - i > t _ { r } \\ 0 & \text { for all } n - i \leq t _ { r } \end{cases}$$

is the solution of the optimisation problem in (6), subject to the constraints in (7), in all cases where 0 &lt; k 1 &lt; k 2 and 0 &lt; τ 2 &lt; τ 1 , see Appendix A for more on this conjecture. From this, it is interesting to note that in some instances of parameters, both the training load and performance will approach a finite maximum value and in other instances, they will be unbounded. We can obtain an expression for the asymptotic daily training impulse by setting all the w ( i )'s in (8) equal to the asymptotic value w ∞ and solve

$$w _ { \infty } & = \frac { 1 } { k _ { 2 } } \left [ P _ { 0 } + \sum _ { \ell = 1 } ^ { \infty } w _ { \infty } \left ( k _ { 1 } \exp \left ( - \frac { \ell } { \tau _ { 1 } } \right ) - k _ { 2 } \exp \left ( - \frac { \ell } { \tau _ { 2 } } \right ) \right ) \right ] , \\ \Rightarrow & w _ { \infty } = \frac { P _ { 0 } } { k _ { 2 } - k _ { 1 } ( \exp \left ( 1 / \tau _ { 1 } \right ) - 1 ) ^ { - 1 } + k _ { 2 } ( \exp \left ( 1 / \tau _ { 2 } \right ) - 1 ) ^ { - 1 } } ,$$

where we have used the infinite geometric series result ∑ ∞ ℓ =1 exp( -ℓ/τ ) = 1 exp (1 /τ ) -1 . This leads to the condition

$$k _ { 2 } \left ( 1 + \frac { 1 } { \exp { ( 1 / \tau _ { 2 } ) } - 1 } \right ) - \frac { k _ { 1 } } { \exp { ( 1 / \tau _ { 1 } ) } - 1 } > 0$$

for when the denominator of equation (9) is positive and we expect the optimised training load to approach a finite value. If this condition is violated, then we expect the optimised training load and performance to grow in an unbounded fashion. Furthermore, if human performance is considered a bounded quantity, then this condition should be considered a constraint on parameter estimation for the Banister model for which we expect realistic results.

It is worth noting that if we are in the situation O ( n ) ≫ O ( τ 1 ), early training will not contribute significantly to the final result if the parameters are such that the optimised training load approaches a finite limit. If we are in the unbounded case, however, earlier training will not persist to the final date but it will facilitate greater training in the in-between time and will indirectly lead to an increased final result.

Having observed that for certain sets of parameters, our conjectured optimum training load for the Banister model approaches a finite limit, this then raises the question, 'If I want to reach x %of my maximum performance improvement ( P max -P 0 ), how many days before the end date should I begin training in earnest?' To answer this question, we need to solve the problem

$$\min _ { n } \ P ( n ) \geq x ( P _ { \max } - P _ { 0 } )$$

for n where the training is given by w ∗ defined in (8). The problem in (11) does not have an analytical, closed-form solution for n , but it can be numerically solved for different choices of parameters - see Appendix B for such a numerical investigation.

In conclusion, optimisation of the Banister model seems to recommend that we either train maximally, or not at all. To induce more complex behaviour in the optimised training load that is more consistent with elite athlete training behaviour noted in the sports science literature, such as periodisation and nuanced tapering strategies, alterations to the model are necessary.

## The Busso Model

When we seek to optimise the Busso model with only the constraints in (7) we encounter an optimisation loophole. That is, since the fatigue magnitude, k 2 ( i ) in (5), varies depending on the recent history of training, we can make this arbitrarily small by simply waiting long enough from the last training impulse. Then, since the fatigue magnitude can be made arbitrarily small, we can theoretically have an arbitrarily large training impulse with arbitrarily large performance improvements.

Anumber of measures could be employed to remove this feature: (i) an arbitrary window for the maximum number of consecutive rest days, (ii) an arbitrary upper bound placed on the training impulse or (iii) an additional constant offset to the fatigue magnitude, to name a few. We will use the second constraint, an arbitrary upper bound placed on the training impulse, as we believe this to be the simplest fix possible.

Two optimal training programs, which differ in the arbitrary training impulse upper bound, are observable in Fig. 3 with parameters taken from Table 2 of [10]. Firstly, we can see that the solutions are dependent on the arbitrary upper-bound, with Fig. 3a-3b having an upper bound of w ( i ) ≤ 10 P 0 and Fig. 3c-3d having an upper bound of w ( i ) ≤ 50 P 0 . Present in both is the ramping up and decaying away of the fatigue cost k 2 ( i ), which creates variations in on-off days. This is due to the optimisation algorithm suggesting that once the fatigue magnitude k 2 ( i ) exceeds the fitness magnitude k 1 = 0 . 031, then we should not train.

Figure 2: Optimised training load to maximise performance on day 28 using the Banister model with parameters: P 0 = 104 . 8 , k 1 = 0 . 048 , k 2 = 0 . 117 , τ 1 = 38 , τ 2 = 1 . 9, taken from Table 3, mean values of 8 subjects, from [12]. For these parameters, t r = 1 . 78 days and t p = 7 . 77 days.

<!-- image -->

In the case that k 2 ( i ) &lt; k 1 , then we see an immediate return on maximal training, which does not correspond to our intuition of typical fatigue and improvement following maximal training. For example, if a well-rested person were to run a marathon, then we would not expect to see a significant performance boost the day after. Instead, we would expect to see a substantial fatigue cost which creates a delay in observing any fitness gains that may have occurred. Seemingly, whilst the Busso model has increased explanatory power over the Banister model [10], it lacks practicality as an optimisation and predictive tool.

## 4 Proposed Modifications to the Banister Model

Given that the Banister model, which is linear, predicted that 'more is better' when determining the optimal training load that maximises performance, and that the nonlinearity introduced in the Busso model led to a more interesting yet similarly impractical result, we propose a systematic exploration of nonlinear modifications to the Banister model. Specifically, we investigate nonlinearities in the immediate magnitude response to training, Subsection 4.1, in the time-decay of this response, Subsection 4.2 and the combination of the two, Subsection 4.3. Our goal is to identify nonlinearities that produce optimised training load trends that more realistically align with elite athlete behaviour - such as periodisation and tapering.

## 4.1 Magnitude Modifications

Consider the idea that not all training is equally beneficial. It could be that as a training session goes on, there are diminishing returns with increasing training impulse. Or more broadly speaking, it could be that as fatigue is accumulated, whether that be from previous days or earlier in the same session, there are diminishing returns with increasing training impulse.

To capture this idea, we can consider a number of magnitude modifications to the current linear form. Firstly, we will leave fatigue as being linear and make modifications to the fitness magnitude only. Secondly, for the sake of simplicity, we will consider the perspective of training effectiveness or density. That is, as it currently stands, the magnitude of the training benefit is linear in w ( i ), which means that each bit of training has equal effectiveness or the training density is constant. Here, we will consider the training densities:

## 1. Exponential decay

$$A _ { F } ( w ( i ) ) = \int _ { 0 } ^ { w ( i ) } k _ { 1 } \exp \left ( - \frac { u } { k _ { 3 } } \right ) d u = k _ { 1 } k _ { 3 } \left ( 1 - \exp \left ( - \frac { w ( i ) } { k _ { 3 } } \right ) \right ) ,$$

?

Figure 3: (a) Optimised training load to maximise performance on day 28 using the Busso model, with parameters taken from Table 2 of [10]: P 0 = 100 , k 1 = 0 . 031 , k 3 = 0 . 000 035 , τ 1 = 30 . 8 , τ 2 = 16 . 8 , τ 3 = 2 . 3 and with an arbitrary upper-bound of w ( i ) ≤ 10 P 0 . (b) The variation in fatigue cost k 2 ( i ) as a function of time, for (a). (c) Same as (a) but with an arbitrary upper bound of w ( i ) ≤ 50 P 0 . (d) Same as (b) but relevant to (c).

<!-- image -->

## 2. Power decay

## 3. Logistic decay

$$A _ { F } ( w ( i ) ) = \int _ { 0 } ^ { w ( i ) } k _ { 1 } + \frac { k _ { 4 } } { 1 + \exp \left ( k _ { 3 } ( u - k _ { 5 } ) \right ) } d u = k _ { 1 } w ( i ) + \frac { k _ { 4 } } { k _ { 3 } } \ln \left ( \frac { 1 + \exp \left ( k _ { 3 } k _ { 5 } \right ) } { 1 + \exp \left ( k _ { 3 } [ k _ { 5 } - w ( i ) ] \right ) } \right ) , \quad ( 1 4 )$$

where k 3 &gt; 0 is a parameter that adjusts the decay of training effectiveness, and k 4 &gt; 0 and k 5 &gt; 0 occur in the logistic case, which controls the increase for relatively small training impulses and the offset location, respectively.

One area that has been previously explored is that of training benefit saturation [25, 45]. Examining the above, and ignoring the physical upper limit of training k 2 w ( i ) ≤ P ( i ) for the time being, we can see that the training benefit has an inherent finite upper limit in some cases and an infinite upper limit in others. That is, for an exponential decay in training effectiveness, the most we could ever hope to achieve is k 1 k 3 . For a power decay in training effectiveness, we have three regimes: in the first, 0 &lt; k 3 &lt; 1, an infinite return is, in theory, possible (albeit at an infinite fatigue cost); in the regime k 3 = 1, the integral returns a logarithm

$$A _ { F } ( w ( i ) ) = \int _ { 0 } ^ { w ( i ) } \frac { k _ { 1 } } { ( 1 + u ) } d u = k _ { 1 } \ln \left ( 1 + w ( i ) \right ) ,$$

and again, an infinite return is, in theory possible; the third and final regime of the power decay is k 3 &gt; 1 in which case the integral converges in the limit of large w ( i ) to k 1 / ( k 3 -1). In the logistic case, the upper

$$A _ { F } ( w ( i ) ) = \int _ { 0 } ^ { w ( i ) } \frac { k _ { 1 } } { ( 1 + u ) ^ { k _ { 3 } } } d u = \frac { k _ { 1 } } { k _ { 3 } - 1 } \left ( 1 - \frac { 1 } { ( 1 + w ( i ) ) ^ { k _ { 3 } - 1 } } \right ) ,$$

limit of training benefit is again infinite. This is to say that the idea of training saturation is captured by (or, indeed, is a subset of) the idea of diminishing returns.

Perhaps of greater importance than the upper limit of training benefit, is the behaviour of the combined fitness-fatigue training impulse. In the Banister model, there was a single time to return, t r , and a single time to the peak of a training impulse, t p , defined in (3) and (4), respectively. With our modification to the magnitude representation, however, these points are now curves. For each w ( i ), there will now be a unique t r and t p , and for each t p , there will be a corresponding peak value of the impulse.

For an analytical example, in the exponential decay of training effectiveness case, we can calculate the time to return as

$$t _ { r } = \frac { \tau _ { 1 } \tau _ { 2 } } { \tau _ { 1 } - \tau _ { 2 } } \ln \left ( \frac { k _ { 2 } w ( i ) } { k _ { 1 } k _ { 3 } \left ( 1 - \exp \left ( - w ( i ) / k _ { 3 } \right ) \right ) } \right ) .$$

Similarly, the time to a peak in training effect will be

$$t _ { p } = \frac { \tau _ { 1 } \tau _ { 2 } } { \tau _ { 1 } - \tau _ { 2 } } \ln \left ( \frac { k _ { 2 } \tau _ { 1 } w ( i ) } { k _ { 1 } k _ { 3 } \tau _ { 2 } \left ( 1 - \exp \left ( - w ( i ) / k _ { 3 } \right ) \right ) } \right ) .$$

Having a variable time to return on training benefits should allow for more complex tapering dynamics to arise naturally from the model. Previously, we saw that optimisation of the training load to maximise performance from the Banister model, Fig. 2, produced the tapering strategy to rest from t r days before the end day. In practice, however, we do not typically see this type of tapering behaviour utilised by elite athletes. In previous studies of tapering in FFMs [34, 4, 42, 43, 44], authors provided a set of realistic tapering strategies and compared the Banister model's prediction for performance outcomes. Some strategies proposed by authors included: a step-down in consistent training, a linear decrease in training and an exponential decrease in training with different decay rates, as well as the concept of an 'over-training' block preceding the taper block. With modifications in the magnitude representation, however, we no longer have to supply the model with a set of realistic options. Instead, as we will see, the model naturally gives rise to these options depending on the form of the magnitude modification.

It is possible to analytically calculate the expression for optimum training load taper for each case of magnitude modification. If we assume that the training load is below the upper training constraint in (7), such as during the taper, then the days are independent - which is to say that it is synonymous to optimise each day as it is to optimise the days in series.

In the Banister model, optimising a single day simply led to the conclusion that more was better. That, if we are j days from our desired maximum performance date, the return on training is

$$w ( j ) \left [ k _ { 1 } \exp \left ( - \frac { j } { \tau _ { 1 } } \right ) - k _ { 2 } \exp \left ( - \frac { j } { \tau _ { 2 } } \right ) \right ]$$

and so long as j &gt; t r , the greater w ( j ), the greater the return. Put another way, there is no turnaround point at which over-training occurs and more training yields less results. In the modified magnitude case, however, we now see a turnaround point and can solve for the optimum amount of training. In the exponential decay of training effectiveness case, we see that

$$0 & = \frac { d } { d w } \left ( k _ { 1 } k _ { 3 } \left ( 1 - \exp \left ( - \frac { w } { k _ { 3 } } \right ) \right ) \exp \left ( - \frac { j } { \tau _ { 1 } } \right ) - k _ { 2 } w \exp \left ( - \frac { j } { \tau _ { 2 } } \right ) \right ) \\ & \Rightarrow w ( j ) = k _ { 3 } \ln \left ( \frac { k _ { 1 } } { k _ { 2 } } \right ) + j k _ { 3 } \left ( \frac { \tau _ { 1 } - \tau _ { 2 } } { \tau _ { 1 } \tau _ { 2 } } \right ) .$$

This tells us that as j counts down to our desired maximum performance date, we should linearly decrease our training load to obtain an optimum result. The extent of this taper is determined by the intersection of the taper and maximum training constraint, k 2 w ( i ) ≤ P ( i ). In summary, this indicates that an exponential decay in training effectiveness naturally gives rise to a linear taper towards the desired maximum performance date.

Performing the same calculation for a power decay in training effectiveness, we find that the optimal training impulse as we approach the desired maximum performance date is given by

$$0 & = \frac { d } { d w } \left ( \frac { k _ { 1 } } { k _ { 3 } - 1 } \left ( 1 - \frac { 1 } { ( 1 + w ) ^ { k _ { 3 } - 1 } } \right ) \exp { - \frac { j } { \tau _ { 1 } } - k _ { 2 } w \exp { - \frac { t } { \tau _ { 2 } } } } \right ) \\ \Rightarrow w ( j ) & = \left ( \frac { k _ { 1 } } { k _ { 2 } } \right ) ^ { \frac { k _ { 3 } } { k _ { 3 } } } \exp { \frac { j } { k _ { 3 } } \left ( \frac { \tau _ { 1 } - \tau _ { 2 } } { \tau _ { 1 } \tau _ { 2 } } \right ) - 1 } .$$

This tells us that as j counts down to the desired maximum performance date, we should exponentially taper our training load. Finally, we can perform the same calculation for a logistic decay in training effectiveness, for which we obtain

$$0 & = \frac { d } { d w } \left ( [ k _ { 1 } w + \frac { k _ { 4 } } { k _ { 3 } } \ln \left ( \frac { 1 + \exp \left ( k _ { 3 } k _ { 5 } \right ) } { 1 + \exp \left ( k _ { 3 } ( k _ { 5 } - w ) \right ) } \right ) ] \exp \left ( - \frac { j } { \tau _ { 1 } } \right ) - k _ { 2 } w \exp \left ( - \frac { j } { \tau _ { 2 } } \right ) \right ) \\ & \Rightarrow w ( j ) = k _ { 5 } + \frac { 1 } { k _ { 3 } } \ln \left ( \frac { k _ { 4 } } { k _ { 2 } \exp \left ( - j \left ( \frac { \tau _ { 1 } - \tau _ { 2 } } { \tau _ { 1 } \tau _ { 2 } } \right ) \right ) - k _ { 1 } } - 1 \right ) .$$

This is less analytically transparent compared to the exponential and power decay cases. For small j , this tells us to train at around the logistic offset value, k 5 , and, depending on the value of k 3 , to more or less maintain that value until the denominator of the term within the logarithm reaches zero, which occurs when j = τ 1 τ 2 / ( τ 1 -τ 2 ) ln( k 2 /k 1 ). After this point in time, the analytical result no longer applies and we are again constrained by the upper limit of what is physically possible k 2 w ( i ) ≤ P ( i ). Returning to the statement of 'more or less maintain [ k 5 ]' depending on k 3 , if k 3 ≫ 1 then this behaves much like a step down in training. If k 3 ≪ 1 it will suggest a linear taper from the time j = τ 1 τ 2 / ( τ 1 -τ 2 ) ln( k 2 /k 1 ). If O ( k 1 ) = 1, then this will suggest a step-down taper which behaves approximately linear once stepped down.

For an example of the optimal training loads that maximise performance using the modified Banister model with exponential, power and logistic decay in the fitness benefit, see Fig. 4. In this, we can see a taper in the fashion that was analytically predicted: linear, exponential and step-down, as defined in (19)-(21), for Fig. 4a, 4b and 4c, respectively.

Figure 4: Optimised training load to maximise performance on day 28 using the modified Banister model with the nonlinear fitness decays: (a) Exponential decay (12) with k 1 = 0 . 1, k 3 = 200, (b) Power decay (13) k 1 = 0 . 2, k 3 = 0 . 4, (c) Logistic decay (14) k 1 = 0 . 01, k 3 = 2, k 4 = 0 . 1, k 5 = 100. All with the parameters: P 0 = 100 , k 2 = 0 . 1 , τ 1 = 10 , τ 2 = 3.

<!-- image -->

Whilst we have seen that an in-training fitness-benefit-decay induces tapering dynamics in the optimised training load, it does not seem to induce periodisation. To extend the idea of diminishing returns within a single training impulse to cover several training impulses, we will include the fatigue accumulated from previous training impulses as a decaying effect on the current training impulse's fitness benefit in an effect we will call fatigue feedback. Mathematically speaking, this could be represented in numerous ways. Selecting a couple for the point of demonstration, fatigue feedback could be captured by:

1. Having its own decay on the fitness magnitude

$$A _ { F } ( w ( i ) , f ( i ) ) = k _ { 1 } w ( i ) \exp \left ( - \frac { f ( i ) } { k _ { 4 } } \right ) ,$$

where k 4 is a constant that controls the sensitivity of training effectiveness to the deleterious effect of fatigue. Note, whilst we have just argued for the inclusion of some in-training fitness magnitude decay with respect to w ( i ), we have taken it out here to explore the effect of fatigue feedback in isolation as well as in conjunction with in-training fitness-benefit-decay.

2. Making it an extra term in the fitness magnitude, such as having a power decay for the in-training fitness-benefit decay and an exponential decay for fatigue sustained from previous days,

$$A _ { F } ( w ( i ) , f ( i ) ) = \frac { k _ { 1 } } { k _ { 3 } - 1 } \left ( 1 - \frac { 1 } { ( 1 + w ( i ) ) ^ { k _ { 3 } - 1 } } \right ) \exp \left ( - \frac { f ( i ) } { k _ { 4 } } \right ) .$$

Although the fatigue feedback is expressed as an exponential decay in (22) and (23), it could also be a power decay, logistic decay, or some other decaying function. Moreover, it could be combined with any of the in-training effects, modelled by exponential, power or logistic decays, as defined in (12)-(14). Numerically examining the first case of allowing fatigue feedback expressed in (22), on the Banister model, we can see that the optimal training load to maximise performance in 28 days has changed from training every day, to training only on select days - compare Fig. 2 to Fig. 5. This could be one mechanism underlying the training practice of periodisation. Indeed, if the training benefit magnitude has a relatively high sensitivity to fatigue (reflected in a small value of k 4 ) then we see large rest times occurring between hard training days, Fig. 5c. As the training benefit magnitude's sensitivity to fatigue is reduced, however, we see the rest time between training impulses reduce and the amount of sustained fatigue, increase, Fig. 5a.

Figure 5: Optimised training loads to maximise performance on day 28 using the modified Banister model with nonlinear fatigue feedback (22) for the parameters: (a) k 4 = 100, (b) k 4 = 50, (c) k 4 = 10 and all other parameters were: P 0 = 100 , k 1 = 0 . 01 , k 2 = 0 . 1 , τ 1 = 10 , τ 2 = 2.

<!-- image -->

This now allows us to put together a performance model that naturally displays both periodisation and tapering in the optimised training load. Consider the addition of power decay to in-training fitness-benefit for the same conditions as Fig. 5a-5b and we obtain those visible in Fig. 6a-6b. Comparing these, we see a reduction in the polarisation 1 of the training load and the addition of a taper with the inclusion of intraining fitness-benefit-decay. Note, in this context of modified magnitudes, if we increase the value of the parameters responsible for tapering and periodisation too much, rather than obtaining a heavily periodised training program that displays tapering in the peaks, we more typically suppress the overall training effort, see Fig. 5c. Fortunately, magnitude modifications are not the only means of mathematical intervention that we can have on the performance model; there are time-constant changes that we can make which have the capacity to incentivise high training impulses.

1 Polarisation of training is when the load distribution is split between maximal training and low-intensity training or rest, and little to no intermediate level of training is present.

Figure 6: Optimised training loads to maximise performance on day 28 using the modified Banister model with both the nonlinear training benefit decay and fatigue feedback (23) for the parameters: (a) k 3 = 0 . 25 , k 4 = 100, (b) k 3 = 0 . 25 , k 4 = 50, (c) k 3 = 0 . 5 , k 4 = 10 and all other parameters were: P 0 = 100 , k 1 = 0 . 01 , k 2 = 0 . 1 , τ 1 = 10 , τ 2 = 2.

<!-- image -->

Two possible interpretations of the idea of diminishing returns are: (i) fatigue inherently has a deleterious effect on not just the training quantity, but also the training quality; (ii) it could be that we have saturated various avenues of improvement and are left with fewer means to achieve benefits as a training impulse is increased or completed in relatively quick succession.

In summary, under optimisation, we saw that an exponential decay in training effectiveness, as given in (12), gave rise to the linear taper in (19), a power decay (13) gave rise to an exponential taper (20) and a logistic decay (14) gave rise to a step-down taper (21). We also saw that if we assume that sustained fatigue has a deleterious effect on current day training as per (22) and (23), this naturally gave rise to periodisation, Fig. 5-6. When the two effects are compounded, however, there is the possible issue that these suppress the model's capacity to derive benefit from large training loads and the optimum result is little to no training with a final performance similar to the initial performance, Fig. 6c. We will now detail how time-constant changes can also give rise to varying behaviours in the optimal training solution and can incentivise relatively large training impulses.

## 4.2 Time-Constant Changes

Consider the idea that a small training impulse, such as a training impulse slightly more than a warm-up, will have a small and immediate positive impact on performance which lasts a relatively small amount of time. A large training impulse, on the other hand, will have a more significant effect which will initially be dominated by fatigue, take a few days for the response to reach a positive return and, overall, will persist for several times that of a small training impulse.

This is partially captured in the modified magnitude case by allowing a decay in the fitness magnitude. That is, the return on training may initially be dominated by a fitness benefit, but as the training impulse increases and the return on the fitness benefit diminishes, fatigue may be the dominant immediate effect on the change in performance.

Another avenue for emphasising this is to make changes to the form of the time constant in the Banister model. It is worth noting that the magnitude modifications and the time-constant changes are not different means to the same end. The magnitude response to training and how this decays in time are independent, orthogonal mechanisms which can each be isolated and observed independently (although, we do note that this is obscured and thus complicated by the daily training impulse assumption).

In a similar fashion to the modified magnitude case, we will consider three possible forms of time-constant changes:

1. Power increase in time-decay with training impulse

$$\tau _ { j } ( w ( i ) ) = \tau _ { j 1 } + \tau _ { j 2 } w ( i ) ^ { m } ,$$

2. Logarithmic increase in time-decay with training impulse

$$\tau _ { j } ( w ( i ) ) = \tau _ { j 1 } + \tau _ { j 2 } \ln ( 1 + w ( i ) ) ,$$

3. Logistic increase in time-decay with training impulse

$$\tau _ { j } ( w ( i ) ) = \tau _ { j 1 } + \frac { \tau _ { j 2 } } { 1 + \exp ( - \tau _ { j 3 } ( w ( i ) - \tau _ { j 4 } ) ) } ,$$

where τ j 1 ≥ 0 is the baseline time decay constant, τ j 2 ≥ 0 controls how much the baseline time decay constant is elongated due to a training impulse, τ j 3 &gt; 0 and τ j 4 ≥ 0 are relevant to the logistic case and control the slope and offset of the function, respectively, and these functions appear in the performance equation as

$$P ( n ) = P _ { 0 } + \sum _ { i = 1 } ^ { n - 1 } k _ { 1 } w ( i ) \exp \left ( \frac { - ( n - i ) } { \tau _ { 1 } ( w ( i ) ) } \right ) - k _ { 2 } w ( i ) \exp \left ( \frac { - ( n - 1 ) } { \tau _ { 2 } ( w ( i ) ) } \right ) .$$

The form of the time-constant changes makes both the individual impulse responses and the overall performance equation transcendental functions, which do not lend themselves to analytical optimisation. That is, even when the days can be considered independent and optimisation of the series of training impulses can be reduced to the univariate case, the derivative of the impulse response with respect to w yields an equation that, when set equal to zero, cannot be used to isolate w . This leaves us with two options: first, as we have been doing, using numerical optimisation, or second, where possible, coming up with analytical bounds which enclose the optimal solution.

For the first option, observe a selection of numerically obtained optimal training loads which maximises the performance after 28 days in Fig. 7. Here, we can see that, by having larger training impulses decay more slowly on average, we can motivate periodisation in the optimised training load which then stabilises and tapers into the event in a linear way Fig. 7a-7b, parabolic way Fig. 7c, exponential way Fig. 7d-7e or in a step-down way Fig. 7f. Moreover, when comparing Fig. 7a-7b, we can see an increased taper (beginning day 19 compared to day 16) being driven by a reduction in τ 12 . We also see this being the case in the comparison of Fig. 7d-7e. Particularly noticeable in the comparison of Fig. 7d-7e is that we see an increase in the polarisation and periodisation of the training load for a reduction in τ 12 . This is because, if O ( τ 1 ( w max )) ≫ n , then medium training impulses persist to the end date about as well as large training impulses. Whereas, if O ( τ 1 ( w max )) ≲ n , then we require large training impulses during the initial stages of training to have a relevant impact on day n .

Analytically speaking, we can get a sense of the optimal tapering dynamics by calculating an upper bound on the training impulse. We can do this by finding the training impulse which has its t r as the end date (any more training than this would yield a negative impact on the final performance). To calculate the time to return, we can set the positive and negative impulses as equal to each other and, in this instance, set the time to return equal to the time to the maximum performance date j and solve for the resulting training load upper bound w u ( j )

$$k _ { 1 } w _ { u } ( j ) & \exp \left ( \frac { - j } { \tau _ { 1 } ( w _ { u } ( j ) ) } \right ) = k _ { 2 } w _ { u } ( j ) \exp \left ( \frac { - j } { \tau _ { 2 } ( w _ { u } ( j ) ) } \right ) \\ & \left ( \frac { 1 } { \tau _ { 2 } ( w _ { u } ( j ) ) } - \frac { 1 } { \tau _ { 1 } ( w _ { u } ( j ) ) } \right ) = \frac { 1 } { j } \ln \left ( \frac { k _ { 2 } } { k _ { 1 } } \right )$$

̸

where we have assumed w u ( j ) = 0. From here, we will need to consider each form of time-constant change: power, logarithmic and logistic, as defined in (24)-(26), respectively. For the power case, let's approximate τ j ( w u ( j )) ≈ τ j 2 w u ( j ) m , which yields the approximate upper limit on the training load as we taper into an event as

$$w _ { u } ( j ) \approx \left ( j \left ( \frac { \tau _ { 1 2 } - \tau _ { 2 2 } } { \tau _ { 1 2 } \tau _ { 2 2 } } \right ) \frac { 1 } { \ln ( k _ { 2 } / k _ { 1 } ) } \right ) ^ { 1 / m } .$$

This suggests that as we approach the date of our desired maximum performance, we should decrease our training load in an approximately j 1 /m fashion, where, again, the above is not the taper itself but an upper bound beyond which training is definitely not beneficial. This is consistent with what was observed in the numerical optimisation, Fig. 7a-7c, which has a linear taper, another linear taper and a parabolic taper for the cases m = { 1 , 1 , 1 / 2 } , respectively. For the logarithmic case, we can make the approximation τ j ( w u ( j )) ≈ τ j 2 ln(1 + w u ( j )), which yields the upper limit

Figure 7: Optimised training loads to maximise performance on day 28 using the modified Banister model with the nonlinear time-constant changes and parameters: (a) power (24), m = 1 , τ 11 = 1 , τ 12 = 10 / ( P 0 /k 2 ) , τ 21 = 0 . 2 , τ 22 = 4 / ( P 0 /k 2 ), (b) same as (a) but with τ 12 = 6 / ( P 0 /k 2 ), (c) same as (a) but with m = 1 / 2, (d) Logarithmic (25), τ 11 = 0 , τ 12 = 6 / ln( P 0 /k 2 ) , τ 21 = 0 , τ 22 = 2 / ln ( P 0 /k 2 ), (e) same as (d) but with τ 12 = 3 / ln( P 0 /k 2 ), (f) Logistic (26), τ 11 = 2 , τ 12 = 10 , τ 13 = τ 23 = 1 / 10 , τ 14 = τ 24 = 500 , τ 21 = 1 , τ 22 = 3, and all other parameters were: P 0 = 100 , k 1 = 0 . 01 , k 2 = 0 . 1.

<!-- image -->

$$w _ { u } ( j ) \approx \exp \left ( j \left ( \frac { \tau _ { 1 2 } - \tau _ { 2 2 } } { \tau _ { 1 2 } \tau _ { 2 2 } } \right ) \frac { 1 } { \ln ( k _ { 2 } / k _ { 1 } ) } \right ) - 1 .$$

This result suggests that we would want to decrease our training load in an exponential fashion as we approach the date of our desired maximum performance. Comparing this to the numerical results, we can see that Fig. 7d-7e also display a decaying exponential taper. The logistic case is more complicated than the previous two and it is difficult to make general statements. Some tentative observations include, if τ j 3 ≪ 1, then the logistic curve can behave similarly to a linear power and the optimal training load solution can display a linear taper; if O ( τ j 3 ) = 1 or τ j 3 ≫ 1, then we can observe a sharp change in time-constant at the threshold training value τ j 4 and training might be prioritised as above this threshold - although, the optimised distribution of training load will still vary widely for each of these regimes depending on the values of τ j 1 and τ j 2 , or even k 1 and k 2 .

In summary, time-constant changes offer us another perspective on why we may choose to periodise and taper a training program for an upcoming event. In this case, relatively large training impulses are incentivised by being rewarded with performance benefits which persist for longer periods of time - which is fundamentally different to the mechanism which drove periodisation in the modified magnitude case where sustained fatigue offset some of the benefits of consecutive training impulses. In the case of the changed time-constant, tapering is facilitated by training impulse responses having a decreasing time to return with decreasing training impulses, compared to the modified magnitude case, which was driven by the ratio of performance gain to performance loss.

## 4.3 Combined Changes

Up to this point, we have considered three interventions to the fitness-fatigue model:

1. Diminishing returns on increasing training impulses. This allows for a small training impulse to have an immediate performance gain, while a large training impulse may have an immediate performance loss.
2. Fatigue sustained on previous days reducing not just the quantity but also the quality of current-day training.
3. Large training impulses producing changes in both the fitness and fatigue response that decay more slowly than a small training impulse.

Putting this all into one model, we have our overall fitness-fatigue model

$$P ( n ) = P _ { 0 } + \sum _ { i = 1 } ^ { n - 1 } A _ { F } ( w ( i ) , f ( i ) ) \exp \left ( \frac { - ( n - i ) } { \tau _ { 1 } ( w ( i ) ) } \right ) - k _ { 2 } w ( i ) \exp \left ( \frac { - ( n - i ) } { \tau _ { 2 } ( w ( i ) ) } \right ) .$$

Given the combined magnitude and time-constant changes, it is worth investigating whether one is dominant. That is, we saw that the power decay in training effectiveness expressed in (13) and the logarithmic increase in time constant expressed in (25) both produced an exponential taper, so we may expect that the combination would also produce an exponential taper. What if, however, we mix the exponential decay on training effectiveness defined in (12), which produced the linear taper in (19), with the logarithmic increase in time-constant defined in (25), which produced an exponential taper?

Upon simulation, we can observe examples of what happens when we mix different magnitude and timeconstant behaviours. In Fig. 8a, we can see that an exponential decay in magnitude and a logarithmic increase in time-constant-which produce a linear and exponential taper in isolation, respectively-produce an exponential taper when in combination. That is, upon fitting either a linear or exponential function to the taper (from day 15 onwards) we obtain a coefficient of determination of r 2 = 0 . 8135 and r 2 = 0 . 9980, respectively, suggesting the time-constant change is dominant for these conditions.

In Fig. 8b, we can see the effect of mixing a power decay in the magnitude response (which induces an exponential taper) with a linear increase in the time-constant response (which induces a linear taper) to the training impulse. The combined result is a linear taper, which is compounding evidence for the idea that the time-constant change dominates the tapering behaviour compared to the magnitude modification. Moreover, we can see that the linear time-constant increase gives enough incentive to periodise the early training without the inclusion of any fatigue feedback.

Fig. 8c shows an instance of mixing an exponential decay in the magnitude response (which induces a linear taper) with a square root increase in time-constant response (which induces a parabolic taper) to the training impulse. Certainly, the resulting taper is no longer linear, as we would expect from an exponential decay alone. By fitting an exponential and a parabolic curve to the taper days (day 16 and onwards), we obtained the coefficients of determination r 2 = 0 . 9917 and r 2 = 0 . 9991, respectively - which again suggests that the time-constant behaviour is dominant as the taper is indeed parabolic.

In Fig. 8d-8f we add fatigue-feedback. Fig. 8d has an exponential decay in magnitude, a logarithmic increase in time-constant and fatigue-feedback, it displays a series of periodised peaks which appear to exponentially taper in magnitude and increase in frequency towards the desired maximum performance date. Fig. 8e has a power decay in magnitude, a logarithmic increase in time-constant and fatigue-feedback; it displays a series of periodised peaks which appear to increase with gained fitness before a tapering bump occurs in the lead up to the desired maximum performance date. Finally, Fig. 8f has a power decay in magnitude, a square root increase in time-constant and fatigue-feedback; it displays a series of periodised peaks which appear to fluctuate with sustained fatigue, gained fitness and tapering, before settling into a steadily tapering period before the desired maximum performance date.

In summary, we were able to obtain a variety of complex optimised training programs based on different functional forms and parameter selections in the proposed model expressed in (31). In some cases, we saw relatively consistent training, followed by a taper, being optimal. In others, we saw periodisation of different magnitudes and frequencies being optimal. We hope this mathematical variety has the capacity to reflect the realistic variety seen in practice in different sports and for different individuals.

Figure 8: Optimised training loads to maximise performance on day 28 using (31) with nonlinear magnitude modifications, time-constant changes and parameters: (a) Exponential decay (12), logarithmic increase (25) k 3 = 50 , τ 11 = 1 , τ 12 = 6 / ln( P 0 /k 2 ) , τ 21 = 0 . 5 , τ 22 = 2 / ln( P 0 /k 2 ), (b) Power decay (13), linear increase (24), k 3 = 0 . 5 , τ 11 = 1 , τ 12 = 6 / ( P 0 /k 2 ) , τ 21 = 0 . 5 , τ 22 = 2 / ( P 0 /k 2 ), (c) Exponential decay (12), square root increase (24), k 3 = 50 , τ 11 = 1 , τ 12 = 6 / √ P 0 /k 2 , τ 21 = 1 , τ 22 = 2 / √ P 0 /k 2 , (d) Exponential decay (12), logarithmic increase (25), k 3 = 200 , k 4 = 20 , τ 11 = 0 . 5 , τ 12 = 6 / ln( P 0 /k 2 ) , τ 21 = 0 . 5 , τ 22 = 2 / ln( P 0 /k 2 ), (e) Power decay, fatigue-feedback (23) and logarithmic increase (25), k 3 = 0 . 25 , k 4 = 60 , τ 11 = 0 . 5 , τ 12 = 6 / ln( P 0 /k 2 ) , τ 21 = 0 . 5 , τ 22 = 2 / ln( P 0 /k 2 ), (f) Power decay (13), square root increase (24), k 3 = 0 . 25 , k 4 = 125 , τ 11 = 1 , τ 12 = 6 / √ P 0 /k 2 , τ 21 = 1 , τ 22 = 2 / √ P 0 /k 2 , and all other parameters are: k 1 = 0 . 15 , k 2 = 0 . 1.

<!-- image -->

## 5 Conclusion

To enhance our understanding of athletic performance, it is essential that trends in the optimised training load derived from our mathematical models match with phenomena documented in the experimental sports science literature. Having an accurate model of athletic performance will enable us to both: optimise the training load of elite athletes to maximise performance and enable us to prescribe the most efficient training load to reach or maintain a desired standard for lay individuals. Moreover, an accurate quantitative tool will help individuals set realistic expectations regarding the time frames and amount of performance improvement an investment in training will achieve.

To induce a linear fitness-fatigue impulse response model with exponential decay to display things such as nuanced tapering strategies and periodisation we considered the nonlinear mathematical features:

1. A fitness magnitude with diminishing returns on increasing training impulse. We found that if the decay in fitness benefit density was exponential, as expressed in (12), then the optimised training load arising from the impulse response model naturally adopted the linear taper defined in (19). If it were a power law decay, as shown in (13), then it displayed the exponential taper defined in (20). And if it were a logistic decay, as in (14), it had the step-down taper defined in (21).
2. Fatigue reduces not just the quantity of training but also the effectiveness of training, see equations (22) and (23). This induced periodisation to appear in the optimised training load. Although, this was not the only intervention to produce periodisation in the optimised training load.

3. Large training impulses produce a performance change that has an impulse response with a slower decay than smaller training impulses. We found that if this change in the time-constant governing the impulse response decay was linear with respect to the training impulse, as expressed in (24), then it had the capacity to motivate periodised training and prompted a linear taper in the optimised training load. If the change in time constant were logarithmic, as given by (25), it had reduced capacity to motivate periodisation but still offered some incentive for high training impulses, and prompted an exponential taper. If it were logistic, as described in (26), it incentivised training above a certain threshold whenever possible, and prompted a step-down taper.

When combining these interventions, for the parameter values we considered, we found that the time-constant changes typically had a stronger influence on the optimised training load compared to the magnitude modifications. We emphasise that the functions suggested for magnitude modifications and time-constant changes are merely for the point of demonstration and the choice of which one, mixture or entirely new function must be made based on whichever reflects the experimental evidence most appropriately.

We believe that the combined magnitude decay and time-constant increase with increasing training impulse provides an illuminating perspective on how someone can reduce their fatigue in anticipation of an event whilst still performing some training. We also believe that fatigue-feedback and the desire for long-lasting performance improvements are two good reasons to periodise a training program. That said, the concept of injury prevention and its impact on the formulation of real training programs warrants future investigation.

## Acknowledgements

The authors thank Leroy McLennan for insightful discussions. This research was partially funded by the Australian Government through the Australian Research Council Industrial Transformation Training Centre in Optimisation Technologies, Integrated Methodologies, and Applications (OPTIMA), Project ID IC200100009. D.C. acknowledges funding via the Australian Government Research Training Program Scholarship and Elizabeth and Vernon Puzey Scholarship.

## Appendix A KKT Conditions and Optimal Training Under the Banister Model

Consider the optimisation problem in (6), subject to the constraints in (7), for the case that P ( n ) is given by the Banister model defined in (2), based upon an extensive numerical investigation, we conjecture that the optimal training load that maximises performance is w ∗ given in (8). To prove this, we can show that w ∗ satisfies the Karush-Kuhn-Tucker (KKT) conditions:

1. Stationarity

$$- \partial _ { w ( \ell ) } P ( w ^ { * } , n ) + \sum _ { \alpha = 1 } ^ { 2 ( n - 1 ) } \mu _ { \alpha } \partial _ { w ( \ell ) } c _ { \alpha } ( w ^ { * } ) = 0 \quad \text {for } \ell = \{ 1 , \dots , n - 1 \} ,$$

where c α are the inequality constraints and µ α are the KKT multipliers (note, we have no equality constraints in this context).

2. Primal Feasibility
3. Dual Feasibility
4. Complementary Slackness

$$c _ { \alpha } ( w ^ { * } ) \leq 0 \ \text { for all } \alpha .$$

$$\mu _ { \alpha } \geq 0 \ \text { for all } \alpha .$$

$$\mu _ { \alpha } c _ { \alpha } ( w ^ { * } ) = 0 \quad \text {for all $\alpha$.}$$

For our problem, we have 0 ≤ k 2 w ( i ) ≤ P ( i ) for i = { 1 , ..., n -1 } , or α = { 1 , ..., 2( n -1) } total constraints. Of these, at our candidate optimal solution, there will be n -1 active ( c α ( w ∗ ) = 0) and n -1 inactive ( c α ( w ∗ ) &lt; 0). The active constraints at the candidate optimal solution are

$$0 = c _ { i } ( w ^ { * } ) = \begin{cases} k _ { 2 } w ^ { * } ( i ) - P ( i ) , & \text {for all } n - i > t _ { r } \\ - w ^ { * } ( i ) , & \text {for all } n - i < t _ { r } , \end{cases}$$

for i = { 1 , ..., n -1 } . The inactive constraints at the candidate solution are the complementary set

$$0 > c _ { ( n - 1 + i ) } ( w ^ { * } ) = \begin{cases} - w ^ { * } ( i ) , & \text {for all $n-i>t_{r}$} \\ k _ { 2 } w ^ { * } ( i ) - P ( i ) , & \text {for all $n-i<t_{r}$} , \end{cases}$$

for i = { 1 , ..., n -1 } . Thus, by construction, we satisfy primal feasibility at our candidate solution. For the inactive constraints, we enforce µ α = 0 for α = { n, ..., 2 n -2 } to satisfy complementary slackness. This leaves us with solving for the µ α 's for the active constraints, to satisfy dual feasibility. To do this, we can solve the equation for stationarity. This leads to the matrix equations

$$\left [ \begin{matrix} k _ { 2 } & - I ( 1 ) & - I ( 2 ) & \cdots & - I ( n - t _ { r } ^ { + } - 2 ) \\ 0 & k _ { 2 } & - I ( 1 ) & \cdots & - I ( n - t _ { r } ^ { + } - 3 ) \\ 0 & 0 & k _ { 2 } & \cdots & - I ( n - t _ { r } ^ { + } - 4 ) \\ \vdots & \vdots & \vdots & \ddots & \vdots \\ 0 & 0 & 0 & \cdots & k _ { 2 } \end{matrix} \right ] \left [ \begin{matrix} \mu _ { 1 } \\ \mu _ { 2 } \\ \mu _ { 3 } \\ \vdots \\ \mu _ { ( n - t _ { r } ^ { + } - 1 ) } \end{matrix} \right ] = \left [ \begin{matrix} I ( n - 1 ) \\ I ( n - 2 ) \\ I ( n - 3 ) \\ \vdots \\ I ( t _ { r } ^ { + } ) \end{matrix} \right ] \\$$

where t + r is the ceiling of t r (3) and

$$\begin{bmatrix} - k _ { 2 } & 0 & \cdots & 0 \\ 0 & - k _ { 2 } & \cdots & 0 \\ \vdots & \vdots & \ddots & \vdots \\ 0 & 0 & \cdots & - k _ { 2 } \end{bmatrix} \begin{bmatrix} \mu _ { ( n - t _ { r } ^ { + } ) } \\ \mu _ { ( n - t _ { r } ^ { + } + 1 ) } \\ \vdots \\ 0 & 0 & \cdots & - k _ { 2 } \end{bmatrix} \begin{bmatrix} I ( t _ { r } ^ { + } - 1 ) \\ I ( t _ { r } ^ { + } - 2 ) \\ \vdots \\ I ( 1 ) \end{bmatrix} .$$

Upon inspection, the matrix equation in (39) always has positive solutions for { µ ( n -t + r ) , ..., µ ( n -1) } which corresponds to the case that we allow negative training when n -i &lt; t r . This leaves us in the position that, so long as the matrix equation (38) has strictly positive solutions, then indeed w ∗ is always the optimal solution for any choice of parameters within the feasible set. Employing the shorthand M µ = b for (38), we note that M has a Toeplitz matrix structure and is invertible, so we can state µ = M -1 b exists, although, we are left to conjecture that this solution is strictly positive for all feasible parameters.

We have conducted a extensive numerical investigation that involved the uniform random selection of parameters from the range P 0 ∈ [0 , 1 000], k 2 ∈ [0 , 1], k 1 ∈ [0 , k 2 ), τ 1 ∈ [0 , 60] and τ 2 ∈ [0 , τ 1 ). We then checked that the condition t r &lt; n = 28 was satisfied before calculating the solution to (38). After millions of cases, we never found a counter-example with a zero or negative KKT multiplier.

We consider two special regimes for which we can analytically prove the positive solutions to (38) and the KKT conditions being satisfied. If t r &lt; 1, then the impulse response is positive for all subsequent days from the day of training, there is no (39) and (38) is guaranteed to have positive solutions since each µ is the result of a summation of strictly positive values via back substitution. The second special case we consider is if n -1 &lt; t r &lt; n -2, then there is only one day of training - the first day of training and (38) will have guaranteed positive solution µ 1 = I ( n -1) /k 2 . After significant effort, we could not analytically prove that (38) has strictly positive solutions for all feasible parameters and thus are left to conjecture as much.

## Appendix B Recommended Training Time Frame Based on the Banister Model

Given that the optimised training load w ∗ defined in (8) approaches an asymptote for many parameter choices, so too will there exist a maximum performance P max that can be obtained. We numerically determined this value by considering a n = 1000 day training window and calculating the performance if we trained maximally for 1 000 -t + r , then took t + r days of rest, where t + r is the ceiling of t r defined in (3). We then determined the number of days it would take to reach x % of ( P max -P 0 ) if we were training according to w ∗ for various { k 1 , k 2 , τ 1 , τ 2 } parameter values, see Table 1. We considered the parameter choices P 0 = 100, k 1 /k 2 ∈ { 0 . 05 , 0 . 10 , 0 . 20 } , τ 1 ∈ { 7 , 14 } and τ 2 ∈ { 2 , 4 } . Note, the results were invariant to the choice of P 0 , as well as taking multiples of both k 1 and k 2 , hence we considered the ratio, k 1 /k 2 .

Table 1 is listed in order of increasing number of days to reach 99% of the maximum performance value. In doing this, we see that the detraining time constant, τ 1 , simultaneously orders into all sevens and then fourteens, while an equivalent ordering does not appear in τ 2 , nor the ratio k 1 /k 2 . If we were to list the table in order of the number of days to reach 30%, however, we would observe that the recovery time constant, τ 2 , orders itself into all twos and then all fours (except for the unbounded case). From this, we might conclude that the rate of progress in the early stages is dominated by the recovery time constant τ 2 , while the number of days required to approach the maximum performance is more strongly dominated by the detraining time constant, τ 1 .

It is common for athletes preparing for an event to allocate themselves a specific training period, for example, 42, 56, 84 or 112 days. Given this choice, it is reasonable to ask 'Has this period allowed sufficient time to achieve a reasonable representation of the athlete's best?' With reference to Table 1, the short answer is, yes, in as little as 42 days of earnest training, a significant percentage of an athlete's P max -P 0 is possible, even more so for the longer timeframes of 84 and 112 days.

This result is supported by the account of Olympic Champion, World Champion and World Record Holder, speed skater, Nils van der Poel, who published his training in 'How to skate a 10k' [46]. In this, he describes devoting himself to two aspects '(1) Competition speed capacity and (2) aerobic capacity.' Moreover, the competition speed capacity training period was reported as spanning '3 months [or 91 days] prior to the prioritised competition'.

Overall, this suggests that, according to the Banister model, an athlete can begin to saturate their performance improvement capacity within reasonably typical training time frames. This does not indicate that training over longer periods of time is guaranteed to be unnecessary or wasteful, but if such efforts are productive, then the underlying mechanism behind it is not well captured by the Banister model. Should we wish to have a model that does capture the capacity for performance improvements to compound over longer time frames whilst still remaining bounded, we should consider making modifications to the Banister model.

Table 1: Number of days, being training days and tapering days as per w ∗ defined in (8), to reach x % of ( P max -P 0 ) for various Banister model parameters.

| Banister Model Parameters   | Banister Model Parameters   | Banister Model Parameters   | Banister Model Parameters   | Banister Model Parameters   | No. of days to reach x % of ( P max - P 0 )   | No. of days to reach x % of ( P max - P 0 )   | No. of days to reach x % of ( P max - P 0 )   | No. of days to reach x % of ( P max - P 0 )   | No. of days to reach x % of ( P max - P 0 )   |
|-----------------------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------------------------|-----------------------------------------------|-----------------------------------------------|-----------------------------------------------|-----------------------------------------------|
| k 1 /k 2                    | τ 1                         | τ 2                         | t + r                       | ( P max - P 0 )             | 30                                            | 60                                            | 90                                            | 95                                            | 99                                            |
| 0.05                        | 7                           | 2                           | 9                           | 3.29                        | 13                                            | 17                                            | 28                                            | 34                                            | 46                                            |
| 0.10                        | 7                           | 2                           | 7                           | 10.2                        | 11                                            | 16                                            | 29                                            | 35                                            | 50                                            |
| 0.20                        | 7                           | 4                           | 16                          | 2.11                        | 20                                            | 25                                            | 36                                            | 42                                            | 56                                            |
| 0.10                        | 7                           | 4                           | 22                          | 0.35                        | 26                                            | 30                                            | 41                                            | 46                                            | 58                                            |
| 0.05                        | 7                           | 4                           | 28                          | 0.07                        | 32                                            | 36                                            | 46                                            | 51                                            | 63                                            |
| 0.20                        | 7                           | 2                           | 5                           | 41.2                        | 11                                            | 18                                            | 37                                            | 46                                            | 67                                            |
| 0.05                        | 14                          | 4                           | 17                          | 3.91                        | 24                                            | 33                                            | 55                                            | 66                                            | 92                                            |
| 0.05                        | 14                          | 2                           | 7                           | 19.5                        | 15                                            | 26                                            | 51                                            | 64                                            | 94                                            |
| 0.10                        | 14                          | 4                           | 13                          | 12.5                        | 21                                            | 32                                            | 57                                            | 70                                            | 100                                           |
| 0.10                        | 14                          | 2                           | 6                           | 67.4                        | 17                                            | 33                                            | 73                                            | 93                                            | 139                                           |
| 0.20                        | 14                          | 4                           | 10                          | 56.8                        | 22                                            | 39                                            | 80                                            | 101                                           | 150                                           |
| 0.20                        | 14                          | 2                           | 4                           | ∞                           | ∞                                             | ∞                                             | ∞                                             | ∞                                             | ∞                                             |

## References

- [1] M. F. Agostinho, A. G. Philippe, G. S. Marcolino, E. R. Pereira, T. Busso, R. B. Candau, and E. Franchini. Perceived training intensity and performance changes quantification in judo. The Journal of

strength &amp; conditioning research , 29(6):1570-1577, 2015.

- [2] M. Avalos, P. Hellard, and J.-C. Chatard. Modeling the training-performance relationship using a mixed model in elite swimmers. Medicine and science in sports and exercise , 35(5):838, 2003.
- [3] E. W. Banister, T. W. Calvert, M. V. Savage, and T. Bach. A systems model of training for athletic performance. Australian journal of science and medicine in sport , 7(3):57-61, 1975.
- [4] E. W. Banister, J. B. Carter, and P. C. Zarkadas. Training theory and taper: validation in triathlon athletes. European journal of applied physiology and occupational physiology , 79:182-191, 1999.
- [5] P. Blanch and T. J. Gabbett. Has the athlete trained enough to return to play safely? the acute: chronic workload ratio permits clinicians to quantify a player's risk of subsequent injury. British journal of sports medicine , 50(8):471-475, 2016.
- [6] A. J. Blazevich and N. Babault. Post-activation potentiation versus post-activation performance enhancement in humans: historical perspective, underlying mechanisms, and current issues. Frontiers in physiology , 10:1359, 2019.
- [7] G. C. Bogdanis, M. E. Nevill, H. K. Lakomy, C. M. Graham, and G. Louis. Effects of active recovery on power output during repeated maximal sprint cycling. European journal of applied physiology and occupational physiology , 74(5):461-469, 1996.
- [8] T. O. Bompa and C. Buzzichelli. Periodization: theory and methodology of training . Human kinetics, 2019.
- [9] L. Bosquet, J. Montpetit, D. Arvisais, and I. Mujika. Effects of tapering on performance: a meta-analysis. Medicine &amp; science in sports &amp; exercise , 39(8):1358-1365, 2007.
- [10] T. Busso. Variable dose-response relationship between exercise training and performance. Medicine &amp; science in sports &amp; exercise , 35(7):1188-1195, 2003.
- [11] T. Busso, R. Candau, and J.-R. Lacour. Fatigue and fitness modelled from the effects of training on performance. European journal of applied physiology and occupational physiology , 69:50-54, 1994.
- [12] T. Busso, C. Carasso, and J.-R. Lacour. Adequacy of a systems structure in the modeling of training effects on performance. Journal of applied physiology , 71(5):2044-2049, 1991.
- [13] T. Busso, C. Denis, R. Bonnefoy, A. Geyssant, and J.-R. Lacour. Modeling of adaptations to physical training by using a recursive least squares algorithm. Journal of applied physiology , 82(5):1685-1693, 1997.
- [14] T. Busso, K. H¨ akkinen, A. Pakarinen, C. Carasso, J. R. Lacour, P. Komi, and H. Kauhanen. A systems model of training responses and its relationship to hormonal responses in elite weight-lifters. European journal of applied physiology and occupational physiology , 61:48-54, 1990.
- [15] T. W. Calvert, E. W. Banister, M. V. Savage, and T. Bach. A systems model of the effects of training on physical performance. IEEE Transactions on systems, man, and cybernetics , SMC-6(2):94-102, 1976.
- [16] G. E. Campos, T. J. Luecke, H. K. Wendeln, K. Toma, F. C. Hagerman, T. F. Murray, K. E. Ragg, N. A. Ratamess, W. J. Kraemer, and R. S. Staron. Muscular adaptations in response to three different resistance-training regimens: specificity of repetition maximum training zones. European journal of applied physiology , 88:50-60, 2002.
- [17] A. J. Cunanan, B. H. DeWeese, J. P. Wagle, K. M. Carroll, R. Sausaman, W. G. Hornsby, G. G. Haff, N. T. Triplett, K. C. Pierce, and M. H. Stone. The general adaptation syndrome: a foundation for the concept of periodization. Sports medicine , 48:787-797, 2018.

- [18] F. N. Daussin, J. Zoll, S. P. Dufour, E. Ponsot, E. Lonsdorfer-Wolf, S. Doutreleau, B. Mettauer, F. Piquard, B. Geny, and R. Richard. Effect of interval versus continuous training on cardiorespiratory and mitochondrial functions: relationship to aerobic performance improvements in sedentary subjects. American journal of physiology-regulatory, integrative and comparative physiology , 295(1):R264-R272, 2008.
- [19] S. Edwards. The heart rate monitor book . Heart Zones Publishing, 1994.
- [20] S. J. Fleck. Periodized strength training: a critical review. The journal of strength &amp; conditioning research , 13(1):82-89, 1999.
- [21] A. J. Fradkin, B. J. Gabbe, and P. A. Cameron. Does warming up prevent injury in sport?: The evidence from randomised controlled trials? Journal of science and medicine in sport , 9(3):214-220, 2006.
- [22] B. Franzel, M. Schwiegershausen, P. Heusser, and B. Berger. Individualised medicine from the perspectives of patients using complementarytherapies: a meta-ethnography approach. BMC Complementary and alternative medicine , 13:1-17, 2013.
- [23] T. J. Gabbett. The training-injury prevention paradox: should athletes be training smarter and harder? British journal of sports medicine , 50(5):273-280, 2016.
- [24] P. Hellard, M. Avalos, L. Lacoste, F. Barale, J.-C. Chatard, and G. P. Millet. Assessing the limitations of the banister model in monitoring training. Journal of sports sciences , 24(05):509-520, 2006.
- [25] P. Hellard, M. Avalos, G. Millet, L. Lacoste, F. Barale, and J.-C. Chatard. Modeling the residual effects and threshold saturation of training: acase study of olympic swimmers. The Journal of strength &amp; conditioning research , 19(1):67-75, 2005.
- [26] F. Imbach, S. Perrey, R. Chailan, T. Meline, and R. Candau. Training load responses modelling and model generalisation in elite sports. Scientific reports , 12(1):1586, 2022.
- [27] F. Imbach, N. Sutton-Charani, J. Montmain, R. Candau, and S. Perrey. The use of fitness-fatigue models for sport performance modelling: conceptual issues and contributions from machine-learning. Sports medicine-open , 8(1):1-6, 2022.
- [28] J. B. Kreher and J. B. Schwartz. Overtraining syndrome: a practical guide. Sports health , 4(2):128-138, 2012.
- [29] Y. Le Meur, C. Hausswirth, and I. Mujika. Tapering for competition: A review. Science &amp; sports , 27(2):77-87, 2012.
- [30] A. Lucia, J. Hoyos, A. Carvajal, and J. Chicharro. Heart rate response to professional road cycling: the tour de france. International journal of sports medicine , 20(03):167-172, 1999.
- [31] Z. Milanovi´ c, G. Sporiˇ s, and M. Weston. Effectiveness of high-intensity interval training (hit) and continuous endurance training for vo 2max improvements: a systematic review and meta-analysis of controlled trials. Sports medicine , 45:1469-1481, 2015.
- [32] G. P. Millet, R. Candau, B. Barbier, T. Busso, J. Rouillon, and J. C. Chatard. Modelling the transfers of training effects on performance in elite triathletes. International journal of sports medicine , 23(01):55-63, 2002.
- [33] R. H. Morton, J. R. Fitz-Clarke, and E. W. Banister. Modeling human performance in running. Journal of applied physiology , 69(3):1171-1177, 1990.
- [34] I. Mujika, T. Busso, L. Lacoste, F. Barale, A. Geyssant, and J. C. Chatard. Modeled responses to training and taper in competitive swimmers. Medicine and science in sports and exercise , 28(2):251-258, 1996.
- [35] I. Mujika and S. Padilla. Scientific bases for precompetition tapering strategies. Medicine &amp; science in sports &amp; exercise , 35(7):1182-1187, 2003.

- [36] I. Mujika, S. Padilla, D. Pyne, and T. Busso. Physiological changes associated with the pre-event taper in athletes. Sports medicine , 34:891-927, 2004.
- [37] M. A. M. Peluso and L. H. S. G. De Andrade. Physical activity and mental health: the association between exercise and mood. Clinics , 60(1):61-70, 2005.
- [38] M. Reiner, C. Niermann, D. Jekauc, and A. Woll. Long-term health benefits of physical activity-a systematic review of longitudinal studies. BMC public health , 13:1-9, 2013.
- [39] G. N. Ruegsegger and F. W. Booth. Health benefits of exercise. Cold Spring Harbor perspectives in medicine , 8(7), 2018.
- [40] A. M. Sanchez, O. Galb` es, F. Fabre-Guery, L. Thomas, A. Douillard, G. Py, T. Busso, and R. B. Candau. Modelling training response in elite female gymnasts and optimal strategies of overload training and taper. Journal of sports sciences , 31(14):1510-1519, 2013.
- [41] H. Selye. Stress and the general adaptation syndrome. British medical journal , 1(4667):1383, 1950.
- [42] L. Thomas and T. Busso. A theoretical study of taper characteristics to optimize performance. Medicine &amp; Science in Sports &amp; Exercise , 37(9):1615-1621, 2005.
- [43] L. Thomas, I. Mujika, and T. Busso. A model study of optimal training reduction during pre-event taper in elite swimmers. Journal of sports sciences , 26(6):643-652, 2008.
- [44] L. Thomas, I. Mujika, and T. Busso. Computer simulations assessing the potential performance benefit of a final increase in training during pre-event taper. The Journal of strength &amp; conditioning research , 23(6):1729-1736, 2009.
- [45] J. D. Turner, M. J. Mazzoleni, J. A. Little, D. Sequeira, and B. P. Mann. A nonlinear model for the characterization and optimization of athletic training and performance. Biomedical human kinetics , 9(1):82-93, 2017.
- [46] N. van der Poel. How to skate a 10k, 2022. Retrieved from https://www.howtoskate.se/ . Accessed: 9 May 2025.
- [47] D. Weaving, N. Dalton Barron, J. A. Hickmans, C. Beggs, B. Jones, and T. J. Scott. Latent variable dose-response modelling of external training load measures and musculoskeletal responses in elite rugby league players. Journal of sports sciences , 39(21):2418-2426, 2021.
- [48] J. M. Willardson. A brief review: factors affecting the length of the rest interval between resistance exercise sets. The Journal of strength &amp; conditioning research , 20(4):978-984, 2006.
- [49] J. M. Wilson, N. M. Duncan, P. J. Marin, L. E. Brown, J. P. Loenneke, S. M. Wilson, E. Jo, R. P. Lowery, and C. Ugrinowitsch. Meta-analysis of postactivation potentiation and power: effects of conditioning activity, volume, gender, rest periods, and training status. The Journal of strength &amp; conditioning research , 27(3):854-859, 2013.
- [50] J. M. Wilson, P. J. Marin, M. R. Rhea, S. M. Wilson, J. P. Loenneke, and J. C. Anderson. Concurrent training: a meta-analysis examining interference of aerobic and resistance exercises. The Journal of strength &amp; conditioning research , 26(8):2293-2307, 2012.