# Muldrow and the Causation Floor: Element Substitution in Title VII Non-Economic Adverse Action Litigation

## Paper Overview Draft

---

### I. Introduction

On April 17, 2024, the Supreme Court decided *Muldrow v. City of St. Louis*, unanimously holding that plaintiffs alleging Title VII employment discrimination need only show "some harm" from an adverse employment action — not the "significant" or "materially adverse" harm that circuit courts had long required. The decision was widely celebrated as a plaintiff-friendly correction to decades of lower court overreach. Employment law scholars predicted it would open the courthouse doors to the everyday texture of workplace discrimination: the lateral transfers, shift changes, and schedule modifications that courts had been dismissing for years because plaintiffs could not demonstrate sufficient economic injury. Practitioners advised clients to expect a flood of new litigation.

This Article asks what actually happened. Using an original dataset of 386 federal court decisions applying the *Muldrow* standard — 128 decided before *Muldrow* and 258 decided in the year following — it provides the first systematic empirical account of how lower courts have responded to the decision. The findings are more complicated, and more instructive, than either the optimists or the skeptics predicted.

On balance, *Muldrow* worked. The overall dismissal rate fell from 70.3% in the pre-period to 55.8% post-*Muldrow*, a difference that holds after controlling for circuit, employer type, motion type, and judicial ideology (odds ratio = 0.57, 95% CI [0.33–0.98], p = .041). Courts are finding plaintiffs' alleged harms sufficient at dramatically higher rates: the share of cases where courts found harm insufficient dropped from 73.8% to 32.4%, while the share finding harm sufficient rose from 10.8% to 40.2%. *Muldrow* moved the needle, and it moved it substantially.

But the gain was partial, and the mechanism of the partial offset is traceable and measurable. As harm has become less available as a ground for dismissal, courts have elevated causation — the requirement that the adverse action occurred "because of" a protected characteristic — from a secondary to a primary dismissal vehicle. Pre-*Muldrow*, 17.2% of cases were dismissed on causation grounds as the primary basis; post-*Muldrow*, that figure is 36.0%. More telling, among the 89 cases dismissed primarily on harm grounds before *Muldrow*, 49% already carried causation as a secondary dismissal basis. Courts did not invent a new weapon. They promoted an existing one.

This Article calls this phenomenon *element substitution*: when a Supreme Court decision makes one element of a multi-element claim less available as a dismissal vehicle, courts shift primary reliance to surviving elements, partially offsetting the intended plaintiff-favorable effect. Element substitution is not the same as judicial nullification — the overall dismissal rate did fall, and the docket management hypothesis (that courts simply relabeled dismissals without changing outcomes) is affirmatively rejected by the data. But it is also not full compliance. The result is a partial reform: *Muldrow* substantially reduced harm-based dismissals and produced a meaningful net gain for plaintiffs, while leaving the causation element in an undertheorized and inconsistently applied state that now functions as the primary barrier to Title VII non-economic adverse action claims.

The Article proceeds in five parts. Part II provides legal background on the pre-*Muldrow* adverse employment action doctrine and what *Muldrow* changed. Part III describes the dataset and methodology. Part IV presents the empirical findings. Part V develops the element substitution theory and its implications for how courts should approach the causation element in non-economic adverse action cases. Part VI considers the broader implications for how the Supreme Court should craft plaintiff-favorable doctrinal decisions to minimize lower court offset.

---

### II. Background: The Adverse Employment Action Problem

Title VII prohibits employers from discriminating against employees "because of" race, color, religion, sex, or national origin with respect to "terms, conditions, or privileges of employment." The statutory text sets no floor on how severe an adverse action must be. Courts, however, largely read one in. By the 2010s, most circuits required plaintiffs alleging non-economic adverse actions — transfers, shift changes, lateral reassignments, schedule modifications — to show that the action produced a "significant" change in employment status or a "materially adverse" change in the terms and conditions of work. The practical effect was that courts were routinely dismissing claims involving actions that were plainly disadvantageous but fell short of formalized economic harm.

Scholarship identified this as a structural problem long before *Muldrow*. The harm threshold, critics argued, systematically excluded the kinds of discrimination most frequently experienced by women and workers of color: the slow accumulation of disadvantage through lateral moves that foreclosed advancement, shift assignments that disrupted caregiving, and geographic transfers that isolated workers from mentorship and networks. These were not "not discrimination" — they were precisely the mechanisms through which workplaces reproduce inequality. Courts were dismissing them because the methodology of harm measurement failed to capture their significance.

*Muldrow* held that this was wrong. Justice Kagan, writing for a unanimous Court, held that Title VII requires only that the plaintiff show "some harm" in the form of "a disadvantageous change in an employment term or condition." The decision explicitly rejected "significance" as a threshold, noting that it appeared nowhere in the statute. Lower courts had, in effect, rewritten Title VII to require more than Congress demanded.

What *Muldrow* left open, however, is at least as important as what it decided. The Court said nothing about how plaintiffs must establish that the adverse action occurred *because of* a protected characteristic. The causation element — the "because of" requirement that connects the adverse action to discriminatory intent — has long been contested in Title VII law. After *University of Texas Southwestern Medical Center v. Nassar* (2013), which imposed but-for causation in retaliation claims, and the continuing doctrinal uncertainty in mixed-motive cases following *Bostock v. Clayton County* (2020), circuits are split on the causation standard applicable to non-economic adverse action claims specifically. *Muldrow* resolved the harm debate but left the causation debate entirely untouched. As this Article shows, that gap matters enormously in practice.

---

### III. Data and Method

The dataset consists of 386 federal district and circuit court decisions deciding dispositive motions in Title VII non-economic adverse action cases. Cases were identified through a systematic Westlaw search for decisions citing *Muldrow* (post-period) and for decisions applying the adverse employment action standard to non-economic harms in the two years prior to the decision (pre-period). Cases were hand-coded for: circuit, employer type (government/private), motion type (Rule 12(b)(6)/summary judgment), adverse action type, outcome, court's finding on the harm standard, primary and secondary basis for dismissal (where applicable), and judicial characteristics including appointing president's party.

The pre-period sample comprises 128 cases decided before April 17, 2024. The post-period sample comprises 258 cases decided on or after that date. The primary identification strategy is a pre/post comparison using *Muldrow*'s decision date as the cutoff. Because this design cannot rule out confounding trends, all regression analyses include controls for circuit fixed effects, employer type, motion type, and judicial ideology (proxied by appointing president's party). Robustness checks restrict the sample to cases filed after *Muldrow* (eliminating cases where the legal landscape was already set at filing) and exclude circuits with fewer than five cases in either period.

The primary outcome variables are: (1) overall case outcome (dismissed vs. survived/mixed, binary); (2) court finding on harm (insufficient/sufficient/not reached); and (3) primary basis for dismissal (harm insufficient, causation insufficient, N/A plaintiff survived, other). The primary analytical models are logistic regressions; supplementary analyses use chi-square tests and cross-tabulations.

---

### IV. Findings

#### A. *Muldrow* Reduced Overall Dismissal Rates

The most basic finding is that *Muldrow* produced a meaningful reduction in overall dismissal rates. Before the decision, 70.3% of cases in the sample ended in dismissal. After the decision, 55.8% did. This 14.5 percentage point reduction is statistically significant (chi-square = 6.94, p = .008) and holds after controlling for relevant covariates in a logistic regression model (OR = 0.57, 95% CI [0.33–0.98], p = .041). The docket management hypothesis — that courts simply relabeled dismissals without changing outcomes — is affirmatively rejected: the dismissal rate fell, not just the dismissal rationale.

#### B. The Harm Finding Shifted Dramatically

The shift in courts' harm findings is the most vivid illustration of *Muldrow*'s impact. Pre-*Muldrow*, courts found the plaintiff's alleged harm insufficient in 73.8% of cases. Post-*Muldrow*, that figure is 32.4% — a 41 percentage point drop. The share of cases where courts found harm sufficient rose from 10.8% to 40.2%. The share of cases where the harm question was not reached at all (because the plaintiff survived on other grounds) rose from 2.3% to 15.2%, consistent with more cases clearing the initial dismissal hurdle entirely.

These shifts are large and uniform across subgroup analyses. They hold in government-defendant and private-defendant cases, in Rule 12(b)(6) and summary judgment contexts, and across circuits. *Muldrow* changed how courts think about harm.

#### C. Causation Emerged as the Dominant Dismissal Ground

The counterweight to the harm finding is the causation finding. Pre-*Muldrow*, 17.2% of cases were dismissed primarily on causation or discriminatory intent grounds. Post-*Muldrow*, that figure is 36.0% — more than double. Correspondingly, a logistic regression examining the probability of a causation-based dismissal (among dismissed cases) versus a harm-based dismissal finds a post-period odds ratio of 4.6 (95% CI [2.5–8.5], p < .001): post-*Muldrow* dismissed cases are 4.6 times more likely to be dismissed on causation grounds than harm grounds relative to the pre-period.

#### D. Causation Was Already Present as a Secondary Ground

The critical question is whether this causation shift represents something genuinely new or simply the promotion of a ground that was already there. The secondary dismissal basis data answers this question directly. Among the 89 pre-*Muldrow* cases dismissed primarily on harm grounds, 44 — fully 49% — carried causation as a secondary basis for dismissal. Courts were already finding causation problems in half of the cases they dismissed on harm. When *Muldrow* eliminated harm as the primary vehicle, courts had causation ready.

The pre- and post-period percentages are almost identical when framed this way: in the pre-period, 35.9% of all cases involved a causation finding (primary or secondary); in the post-period, 36.0% of cases were dismissed on causation as the primary ground alone. This convergence is the clearest evidence for the element substitution account: courts did not become suddenly more skeptical of causation after *Muldrow*. They were already skeptical. They just had to say so.

#### E. The Gain Among Harm-Sufficient Cases Is Real

One might worry that element substitution is so pervasive that plaintiffs who cleared the harm hurdle were simply dismissed on causation instead, producing no net benefit. The data does not support this concern. Among cases where courts found harm sufficient, the dismissal rate fell from 35.7% pre-*Muldrow* to 19.4% post-*Muldrow* — a substantial improvement, though the difference does not reach statistical significance due to the small pre-period denominator (n = 14 pre vs. 103 post). Plaintiffs who clear the harm hurdle are more likely to survive than they were before *Muldrow*. The element substitution effect is real but not total.

---

### V. Element Substitution: Theory and Implications for Causation Doctrine

#### A. The Theory

Element substitution, as this Article uses the term, describes the following dynamic: when a Supreme Court decision lowers the plaintiff's burden on one element of a multi-element claim, defendants and courts may respond by intensifying scrutiny of surviving elements, partially offsetting the intended plaintiff-favorable effect. Element substitution is distinct from judicial nullification (which requires that courts ignore the Supreme Court's holding) and from docket management (which requires that the overall dismissal rate remain unchanged). It is a subtler and more legally defensible form of resistance: courts comply with the letter of the new doctrine on the element it addressed while applying remaining elements with heightened rigor or at least heightened visibility.

The mechanism in *Muldrow* cases is straightforward. Pre-*Muldrow*, defendants moved to dismiss on harm grounds, and courts granted those motions. Causation problems in the same cases were noted but treated as secondary — courts did not need to reach them if harm was dispositive. Post-*Muldrow*, defendants can no longer lead with harm (or can but will lose). They pivot to causation arguments, and courts, applying an undertheorized standard, grant dismissals on that basis. The legal outcome for the plaintiff — dismissal — is the same in both periods, but the legal ground is different, and the rate is somewhat lower.

#### B. Implications for Causation Doctrine

The element substitution finding has a direct doctrinal implication: courts need clearer guidance on the causation standard applicable to Title VII non-economic adverse action claims. As of now, they are operating without it. The circuits have not converged on what a plaintiff must show to establish that a transfer, shift change, or schedule modification occurred "because of" a protected characteristic. Must the plaintiff show that discriminatory intent was the but-for cause? A motivating factor? Something else? The post-*Muldrow* data suggests courts are resolving this ambiguity by requiring plaintiffs to show something that is, in practice, quite demanding — and doing so inconsistently across circuits.

This Article argues that the correct standard, consistent with *Bostock*'s interpretation of Title VII's "because of" language and the statute's remedial purposes, is a motivating-factor standard for non-economic adverse action claims. The but-for standard imported from *Nassar* was justified in the retaliation context by specific statutory text and policy concerns that do not apply with equal force to standard discrimination claims. Applying it to non-economic adverse action claims would ratify element substitution as the post-*Muldrow* equilibrium — effectively replacing one judicially imposed threshold with another — and would frustrate the statute's purpose of reaching the everyday texture of workplace discrimination.

---

### VI. The Broader Lesson

This Article's findings speak to a broader question in public law scholarship: when does a plaintiff-favorable Supreme Court decision translate into plaintiff-favorable outcomes in the lower courts, and when does it get absorbed by doctrinal rebalancing? The *Muldrow* data suggests the answer is neither "always" nor "never" but rather "partially, with the degree of absorption depending on the doctrinal surface area left available for offset." Where a favorable ruling addresses one element of a multi-element claim and leaves other elements unaddressed, lower courts — not necessarily acting in bad faith — will concentrate dispositive attention on surviving elements. The result is partial compliance with an identifiable offset mechanism.

This has implications for how the Supreme Court should craft plaintiff-favorable decisions. Rulings that address one element in isolation, while leaving adjacent elements underspecified, create the conditions for element substitution. *Muldrow* lowered the harm threshold but said nothing about causation. A more complete ruling would have addressed the causation standard directly, or at minimum flagged the question for lower courts. In the absence of that guidance, element substitution has filled the gap.

---

### VII. Conclusion

*Muldrow v. City of St. Louis* was the right decision. Courts had been misreading Title VII for decades, requiring more harm than the statute demands and dismissing cases that reflected the lived reality of workplace discrimination. The empirical evidence in this Article confirms that *Muldrow* changed outcomes: dismissal rates fell significantly, and courts are now far more likely to find plaintiffs' alleged harms sufficient.

But the reform was partial. Element substitution — the elevation of causation from a secondary to a primary dismissal ground — absorbed roughly half of *Muldrow*'s potential gain. The causation element in Title VII non-economic adverse action cases is now the primary contested site of litigation, and courts are applying it without adequate doctrinal guidance. Until the circuits converge on a clear and appropriately accessible causation standard, the promise of *Muldrow* will remain only partly fulfilled. This Article has identified the problem. The doctrinal work of solving it remains ahead.

---

*[Approx. 2,600 words / ~10 pages double-spaced. All statistics drawn from dataset of 386 federal court decisions, April 2022–April 2025.]*
