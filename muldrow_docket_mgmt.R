# muldrow_docket_mgmt.R
# Docket management analysis: did the overall dismissal rate change post-Muldrow?

library(readxl)
library(dplyr)
library(tidyr)
library(broom)
library(writexl)

INFILE <- "muldrow_coding_sheet_cleaned.xlsx"
OUTFILE <- "muldrow_docket_mgmt.xlsx"
MULDROW_DATE <- as.Date("2024-04-17")

df <- read_excel(INFILE) |>
  mutate(
    decision_date = as.Date(`Decision Date`),
    post = as.integer(decision_date >= MULDROW_DATE),

    # Binary outcome: fully dismissed = 1; survived or mixed = 0
    dismissed = case_when(
      `Overall Case Outcome` %in%
        c("Dismissed", "Dismissed with leave to amend", "Dismissed (recommended)") ~ 1L,
      `Overall Case Outcome` %in%
        c("Survived", "Mixed", "Mixed (recommended)") ~ 0L,
      TRUE ~ NA_integer_
    ),

    # Clean factor vars
    Circuit       = as.factor(trimws(Circuit)),
    employer_type = as.factor(trimws(`Employer Type`)),
    motion_type   = as.factor(trimws(`Motion Type Decided`)),
    party         = as.factor(trimws(`Appointing President Party`))
  ) |>
  filter(!is.na(dismissed))

# ── TABLE A: Overall dismissal rates pre vs. post ─────────────────────────────
tbl_a <- df |>
  group_by(Period = if_else(post == 1, "Post-Muldrow", "Pre-Muldrow")) |>
  summarise(
    Dismissed      = sum(dismissed),
    `Survived/Mixed` = sum(1 - dismissed),
    Total          = n(),
    `Dismissal Rate` = scales::percent(mean(dismissed), accuracy = 0.1),
    .groups = "drop"
  )

# Chi-square test
ct <- table(df$post, df$dismissed)
chi_res <- chisq.test(ct)
cat(sprintf("Chi-square = %.3f, p = %.4f\n", chi_res$statistic, chi_res$p.value))

# ── TABLE B: Logistic regression ───────────────────────────────────────────────
mod <- glm(
  dismissed ~ post + Circuit + employer_type + motion_type + party,
  family = binomial,
  data   = df |> filter(!is.na(Circuit), !is.na(employer_type),
                        !is.na(motion_type), !is.na(party))
)

tbl_b <- tidy(mod, exponentiate = TRUE, conf.int = TRUE) |>
  rename(OR = estimate, SE = std.error, `p-value` = p.value,
         `OR (95% CI Lo)` = conf.low, `OR (95% CI Hi)` = conf.high) |>
  mutate(across(where(is.numeric), ~ round(.x, 3)))

cat(sprintf("Post-Muldrow OR = %.3f [%.3f–%.3f], p = %.4f\n",
            tbl_b$OR[tbl_b$term == "post"],
            tbl_b$`OR (95% CI Lo)`[tbl_b$term == "post"],
            tbl_b$`OR (95% CI Hi)`[tbl_b$term == "post"],
            tbl_b$`p-value`[tbl_b$term == "post"]))

# ── TABLE C: Conditional on harm found Sufficient ─────────────────────────────
harm_suff <- read_excel(INFILE) |>
  mutate(
    decision_date = as.Date(`Decision Date`),
    post = as.integer(decision_date >= MULDROW_DATE),
    dismissed = case_when(
      `Overall Case Outcome` %in%
        c("Dismissed", "Dismissed with leave to amend", "Dismissed (recommended)") ~ 1L,
      `Overall Case Outcome` %in%
        c("Survived", "Mixed", "Mixed (recommended)") ~ 0L,
      TRUE ~ NA_integer_
    )
  ) |>
  filter(`Court Finding on Harm` == "Sufficient", !is.na(dismissed))

tbl_c <- harm_suff |>
  group_by(Period = if_else(post == 1, "Post-Muldrow", "Pre-Muldrow")) |>
  summarise(
    Dismissed      = sum(dismissed),
    `Survived/Mixed` = sum(1 - dismissed),
    Total          = n(),
    `Dismissal Rate` = scales::percent(mean(dismissed), accuracy = 0.1),
    .groups = "drop"
  )

ct_c <- table(harm_suff$post, harm_suff$dismissed)
chi_c <- chisq.test(ct_c)
cat(sprintf("Harm-Sufficient chi-square = %.3f, p = %.4f\n",
            chi_c$statistic, chi_c$p.value))

# ── Save to Excel ──────────────────────────────────────────────────────────────
write_xlsx(
  list(
    "Table A - Dismissal Rates"             = tbl_a,
    "Table B - Logit Results"               = tbl_b,
    "Table C - Conditional on Harm Sufficient" = tbl_c
  ),
  path = OUTFILE
)

cat("Saved:", OUTFILE, "\n")
