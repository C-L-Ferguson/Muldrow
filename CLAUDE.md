# Muldrow Study — Claude Project Instructions

## Project Overview

Empirical legal study measuring whether federal district courts changed their treatment of non-economic adverse action claims after *Muldrow v. City of St. Louis* (601 U.S. ___ (2024), decided 04/17/2024). The Supreme Court lowered the harm threshold from "materially significant disadvantage" to "some harm." The study also tests whether courts substituted other dismissal grounds (causation, pleading deficiency) post-*Muldrow* — consistent with the attitudinal model of judicial behavior. This is a job talk paper (Bigelow fellowship, University of Chicago).

## Key Files

- `muldrow_coding_sheet_v2.xlsx` — main coding sheet (tabs: Coding Sheet, Controlled Vocabulary, Triage Log, Coding Log, Westlaw Search Term)
- `Cases\Updated Instructions for Claude.docx` — most recent rule corrections; supersedes any conflicting guidance below
- `C:\Users\carol\Downloads\handoff.md` — original full handoff document

## Coding Sheet Structure

The Coding Sheet has 41 columns. Column mapping (1-indexed):

| Col | Field |
|-----|-------|
| A (1) | Case Name |
| B (2) | Westlaw Citation |
| C (3) | Docket Number |
| D (4) | District |
| E (5) | Circuit |
| F (6) | Filing Date |
| G (7) | Decision Date — format: **month/day/year** |
| H (8) | Period (Pre/Post) |
| I (9) | Related Westlaw Citation |
| J (10) | Ruling Number in Case |
| K (11) | Protected Characteristic(s) |
| L (12) | Race/Sex/Origin of Plaintiff |
| M (13) | Primary Non-Economic Adverse Action |
| N (14) | Additional Non-Economic Adverse Actions? |
| O (15) | All Non-Economic Adverse Actions Analyzed |
| P (16) | Primary Adverse Action Economic Component? |
| Q (17) | Pro Se Plaintiff? |
| R (18) | Employer Type |
| S (19) | Motion Type Decided |
| T (20) | Who Moved? |
| U (21) | Non-Economic Adverse Action Claim Outcome |
| V (22) | Overall Case Outcome |
| W (23) | Settlement? |
| X (24) | Other Claim Types Present |
| Y (25) | Outcome on Other Claims |
| Z (26) | Court Addressed Harm Standard? |
| AA (27) | Harm Standard Applied |
| AB (28) | Court Finding on Harm |
| AC (29) | Primary Basis for Dismissal |
| AD (30) | Secondary Basis for Dismissal |
| AE (31) | Dismissal Basis Confidence |
| AF (32) | Cites Muldrow? |
| AG (33) | Court's Characterisation of Standard |
| AH (34) | Muldrow Applied to Transfer? |
| AI (35) | Extended to Other Statute? |
| AJ (36) | Judge Last Name |
| AK (37) | Appointing President Party |
| AL (38) | Opinion Length (pages, approx.) |
| AM (39) | Appeal Filed? |
| AN (40) | Date Coded — format: **month/day/year** |
| AO (41) | Coder Notes |

---

## Controlled Vocabulary

### Protected Characteristic(s) (col K)
When a plaintiff alleges **multiple** protected characteristics, code as `Multiple` — do not list them out.

### Race/Sex/Origin of Plaintiff (col L)
List the specific characteristics here. **Critically: match to the claim alleged, not the plaintiff's full identity.**
- If plaintiff is a Black woman but alleges only race discrimination → col L = `Black` (not `Black woman`)
- If plaintiff alleges multiple characteristics → list all specifics here (e.g., `Black, Woman`)

### Primary Non-Economic Adverse Action (col M)
Permitted values: `Lateral Transfer` · `Reassignment / Duty Change` · `Negative Evaluation` · `Schedule / Shift Change` · `Loss of Perks or Benefits` · `Unreasonable Workload` · `Exclusion from Opportunities` · `Workspace Change` · `Loss of Position` · `Involuntary Leave` · `Heightened Surveillance` · `Miscategorization` · `Other`

### Non-Economic Adverse Action Claim Outcome (col U)
`Dismissed — Plaintiff` · `Survived — Plaintiff` · `Mixed` · `Not Reached`

### Overall Case Outcome (col V)
`Dismissed` · `Survived` · `Pending` · `Settled` · `Other`

### Harm Standard Applied (col AA)
`Materially Significant` · `Significant Disadvantage` · `Materially Adverse` · `Some Harm (Muldrow)` · `Other`

### Court Finding on Harm (col AB)
`Sufficient` · `Insufficient` · `Not Reached` · `Mixed`

### Primary Basis for Dismissal (col AC)
`Harm Insufficient` · `Causation / Discriminatory Intent Insufficient` · `Pleading Deficiency` · `Procedural / Forfeiture` · `Multiple Bases` · `Other` · `N/A — Plaintiff Survived`

### Secondary Basis for Dismissal (col AD)
`Harm Insufficient` · `Causation / Discriminatory Intent Insufficient` · `Pleading Deficiency` · `Procedural / Forfeiture` · `Other` · `N/A — Single Basis Only`

### Dismissal Basis Confidence (col AE)
`Clear` · `Moderate` · `Uncertain`

### Employer Type (col R)
`Private` · `Government — Municipal` · `Government — State` · `Government — Federal`

### Appointing President Party (col AK)
`Democrat` · `Republican` · `N/A` (use N/A for magistrate judges deciding by consent)

### Outcome on Other Claims (col Y)
**Exactly five permitted values — no elaboration:**
`No other claims` · `all dismissed` · `all survived` · `mixed` · `not addressed in this opinion`

---

## Core Coding Rules

### Row Placement
**Always insert new cases immediately below the last coded row in the Coding Sheet. Never skip rows or insert cases elsewhere in the spreadsheet.**

### Primary Non-Economic Adverse Action
Code the **first** adverse action the court analyzes under the harm standard — sequential order in the opinion, not analytical emphasis and not what survived. This avoids endogeneity.

### Primary Basis for Dismissal
Code the **first** dismissal ground the court addresses sequentially. If harm comes first, code Harm Insufficient as primary even if causation also appears later.

### Secondary Basis for Dismissal
Code only when the court gives a second ground roughly equal weight. If only one basis, code `N/A — Single Basis Only`.

### Court Finding on Harm
- `Sufficient` — court finds adverse action meets the threshold
- `Insufficient` — court finds it does not
- `Not Reached` — court assumed sufficiency or dismissed on other grounds first
- `Mixed` — multiple non-economic adverse actions analyzed, some sufficient and others insufficient

### Burlington Northern Signal
When a court uses Burlington Northern language ("materially adverse," "dissuade a reasonable worker," "petty slights") in the adverse action analysis, that is the **retaliation** standard — triage unless a separate discrimination harm analysis using Galabya or circuit-equivalent language also appears.

### Economic vs. Non-Economic Adverse Action
- **Economic:** directly affects pay, grade, or employment status (termination, pay cut, demotion with pay reduction, promotion denial)
- **Non-economic:** changes working conditions without direct pay/status change (transfer, schedule change, duty reassignment, workspace change, monitoring, negative evaluation without pay consequence)
- When a non-economic adverse action has an incidental economic consequence, code Adverse Action Economic Component = Yes but keep the case in sample.

### Within-Case Mixed Claims
- Code non-economic adverse action as Primary
- Put economic adverse actions in Other Claim Types Present (col X)
- Code Outcome on Other Claims (col Y) separately
- This enables within-case comparison

### PDA Claims
Code as `Sex` under Protected Characteristic. Note in Coder Notes that it is a PDA/pregnancy discrimination case.

### ADEA Parallel Claims
When Title VII and ADEA claims are analyzed together under the same harm standard, code as Title VII only. Note ADEA parallel claim in Coder Notes.

### Federal Employee Cases
Code Employer Type as `Government — Federal` even when defendant is named as a cabinet secretary.

---

## R&R Handling (Updated Rule)

**Do NOT automatically triage a Magistrate Judge's Report and Recommendation.**

When you encounter an R&R in search results:
1. Evaluate it on substantive inclusion criteria exactly like any other case
2. If it meets criteria, **code it**, but add to Coder Notes: `THIS IS AN R&R — verify whether the district court judge adopted this before coding`
3. Only triage an R&R on the same grounds you would triage any other case (wrong adverse action type, no harm standard engagement, retaliation only, etc.)
4. **Never triage solely because it is an R&R**

R&R adoption orders → triage (code the underlying R&R instead).
Magistrate deciding case with party consent (§ 636(c)) → code as normal; Appointing President Party = N/A.

---

## Inclusion Criteria

Cases must meet **all** of the following:
1. Federal district court opinion only (appellate excluded)
2. Title VII discrimination claim (not retaliation, not HWE alone)
3. Non-economic adverse action alleged
4. Court explicitly applied the harm standard to a discrete non-economic adverse action and reached a finding
5. Pre-period: opinion must contain the circuit's specific harm standard language
6. Post-period: opinion must cite *Muldrow v. City of St. Louis* directly
7. Decision date: Pre = on or before 04/16/2024; Post = on or after 04/17/2024
8. Date range: 01/01/2020 through present

## Exclusion Criteria (Triage)

Triage if **any** of the following apply:
- Retaliation only (Burlington Northern standard)
- Hostile work environment only (severe or pervasive standard)
- Primary adverse action is economic only
- Court never reached harm analysis (dismissed on causation, timeliness, or pleading first)
- Court assumed harm sufficient without applying a standard
- ADEA only — no Title VII discrimination claim
- Appellate opinion
- Leave to amend granted (only code final decisions)
- R&R adoption order (code the underlying R&R instead)
- Pro se prisoner cases using Title VII language without employment relationship

---

## Circuit-Specific Harm Standards

| Circuit | Standard | Anchor Cases | Status |
|---------|----------|-------------|--------|
| 1st | "materially adverse" / "more disruptive than a mere inconvenience" | *Morales-Vallellanes v. Potter*; *Cham v. Station Operators* | Complete (1 coded, 10 triaged) |
| 2nd | "materially adverse change in terms and conditions" / "more disruptive than a mere inconvenience" | *Galabya*; *Vega* | Complete (57 coded, ~80 triaged) |
| 4th | "significant detrimental effect" / "material disadvantage" | *Boone v. Goldin*; *Von Gunten v. Maryland* | In progress (11 coded, 9 triaged) |
| 7th | "significant change in employment status" | *Herrnreiter*; *Bell v. EPA* | Not started |
| 8th | "significant disadvantage" / "materially adverse" | Pre-*Muldrow* 8th Circuit decisions | Complete (13 coded, 14 triaged) |
| 10th | "material effect on the terms or conditions of employment" | *Sanchez v. Denver Public Schools*; *Hillig v. Rumsfeld* | Not started (28 cases identified) |
| 11th | "serious and material change in the terms, conditions, or privileges of employment" | *Davis v. Town of Lake Park*; *Crawford v. Carroll* | Not started (most restrictive pre-*Muldrow*) |

**Note for 1st Circuit (Puerto Rico cases):** Ignore supplemental PR law claims (Law 3, Law 100, Law 44, Law 115) — code only Title VII harm analysis.

---

## Westlaw Search Strings

### Pre-period
```
adv: "Title VII" /p (transfer! OR reassign! OR review! OR benefit! OR exclu! OR loss!) /p ("[circuit-specific harm language]"); 1/1/2020 - 4/16/2024
```

### Post-period
```
adv: "Title VII" and "Muldrow" and ("terms and conditions" OR "adverse employment action" OR "some harm"); 4/17/2024 - present
```

---

## Current Coding Status (as of 2026-08-05)

- **8th Circuit pre-period:** Complete — 13 coded, 14 triaged
- **1st Circuit pre-period:** Complete — 1 coded, 10 triaged
- **2nd Circuit pre-period:** Complete — 57 coded, ~80 triaged
- **4th Circuit pre-period:** In progress — 11 coded (rows 486–496, **need to be moved to rows 72–82**), 9 triaged
- **7th, 10th, 11th Circuits:** Not started
- **Post-period (all circuits):** Not started
- **Total coded:** ~82

### Known Issues to Fix in 4th Circuit Coded Cases (rows 486–496)
1. Cases are placed at rows 486–496 — should be immediately below row 71
2. Race/Sex/Origin (col L): several entries include sex alongside race when only race discrimination is alleged — fix to match the claim
3. Protected Characteristic(s) (col K): `Race; Sex` → `Multiple` in rows 487 and 489
4. Outcome on Other Claims (col Y): uses verbose descriptions instead of controlled vocabulary
5. Two R&R triage entries (Singletary row 87, Harris row 89 in Triage Log) need substantive re-evaluation per updated R&R rule — user handling manually

---

## Methodological Notes

1. Pre-period searches used /p proximity connector; post-period used document-level "and" — the Muldrow citation requirement serves as an equivalent analytical filter
2. Unit of observation is a ruling on a dispositive motion — cases with both 12(b)(6) and SJ rulings get two rows linked by docket number
3. Primary adverse action determined by order of analysis (sequential rule) to avoid endogeneity
4. Pleading deficiency cases tracked in Triage Log for potential supplementary substitution analysis
5. 2nd Circuit cases heavily concentrated in NYC municipal employers — flag as methodological limitation
