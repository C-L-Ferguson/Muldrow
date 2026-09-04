library(tidyverse)
library(readxl)
library(fixest)    # for regressions with fixed effects
library(modelsummary)  # for regression tables

# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
# Row 1 in the Coding Sheet tab is a section-header row; row 2 has column names.
# Change skip = 1 to skip = 0 if row 1 already contains your column names.
dataset <- read_excel(
  "C:/Users/carol/Box/Bigelow/Job_Talk_paper/Muldrow/muldrow_coding_sheet_cleaned.xlsx",
  sheet = "Coding Sheet",
  skip = 1
)

# ---------------------------------------------------------------------------
# Rename columns to snake_case
# ---------------------------------------------------------------------------
df <- dataset |>
  rename(
    case_name            = `Case Name`,
    citation             = `Westlaw Citation`,
    docket               = `Docket Number`,
    district             = `District`,
    circuit              = `Circuit`,
    filing_date          = `Filing Date`,
    decision_date        = `Decision Date`,
    period               = `Period`,
    ruling_number        = `Ruling Number in Case`,
    protected_char       = `Protected Characteristic(s)`,
    race_sex_origin      = `Race/Sex/Origin of Plaintiff`,
    primary_action       = `Primary Non-Economic Adverse Action`,
    econ_component       = `Primary Adverse Action Economic Component?`,
    pro_se               = `Pro Se Plaintiff?`,
    employer_type        = `Employer Type`,
    motion_type          = `Motion Type Decided`,
    outcome_nonecon      = `Non-Economic Adverse Action Claim Outcome`,
    outcome_overall      = `Overall Case Outcome`,
    harm_addressed       = `Court Addressed Harm Standard?`,
    harm_standard        = `Harm Standard Applied`,
    harm_finding         = `Court Finding on Harm`,
    dismissal_primary    = `Primary Basis for Dismissal`,
    dismissal_secondary  = `Secondary Basis for Dismissal`,
    dismissal_confidence = `Dismissal Basis Confidence`,
    cites_muldrow        = `Cites Muldrow?`,
    appt_party           = `Appointing President Party`,
    opinion_length       = `Opinion Length (pages, approx.)`,
    date_coded           = `Date Coded`
  ) |>
  mutate(
    # Parse dates
    filing_date   = mdy(filing_date),
    decision_date = mdy(decision_date),

    # Period as factor, Pre as reference
    period = factor(period, levels = c("Pre", "Post")),
    post   = as.integer(period == "Post"),

    # Filing date subgroup: was the case filed after Muldrow was decided?
    muldrow_date       = as.Date("2024-04-17"),
    filed_post_muldrow = as.integer(!is.na(filing_date) & filing_date >= muldrow_date),

    # Three-way filing group for subgroup analysis
    filing_group = case_when(
      period == "Pre"                          ~ "Pre-Period",
      period == "Post" & filed_post_muldrow == 0 ~ "Post — Pre-Muldrow Filing",
      period == "Post" & filed_post_muldrow == 1 ~ "Post — Post-Muldrow Filing",
      TRUE                                     ~ NA_character_
    ) |> factor(levels = c("Pre-Period", "Post — Pre-Muldrow Filing",
                            "Post — Post-Muldrow Filing")),

    # Binary outcome variables
    harm_insufficient  = as.integer(harm_finding == "Insufficient"),
    harm_sufficient    = as.integer(harm_finding == "Sufficient"),
    causation_primary  = as.integer(dismissal_primary == "Causation / Discriminatory Intent Insufficient"),
    plaintiff_survived = as.integer(dismissal_primary == "N/A — Plaintiff Survived"),
    harm_primary       = as.integer(dismissal_primary == "Harm Insufficient"),

    # Pre-period secondary basis flags (for robustness specs)
    had_causation_secondary = as.integer(
      dismissal_secondary == "Causation / Discriminatory Intent Insufficient"
    ),

    # Covariates
    circuit       = factor(circuit),
    employer_type = factor(employer_type),
    motion_type   = factor(motion_type, levels = c("Summary Judgment", "12(b)(6)", "Other")),
    appt_party    = factor(appt_party, levels = c("Democrat", "Republican", "N/A")),
    opinion_length = as.numeric(opinion_length)
  )

# ---------------------------------------------------------------------------
# Table 1: Sample characteristics by period
# ---------------------------------------------------------------------------
tab1_pct <- function(x, total) sprintf("%d (%.1f%%)", x, 100 * x / total)

make_table1 <- function(data) {
  n_total <- nrow(data)
  n_pre   <- sum(data$period == "Pre")
  n_post  <- sum(data$period == "Post")

  vars <- list(
    Circuit              = "circuit",
    `Primary Adverse Action` = "primary_action",
    `Employer Type`      = "employer_type",
    `Protected Characteristic` = "protected_char",
    `Appointing Party`   = "appt_party",
    `Motion Type`        = "motion_type",
    `Court Finding on Harm` = "harm_finding",
    `Primary Basis for Dismissal` = "dismissal_primary"
  )

  rows <- map_dfr(names(vars), function(label) {
    col <- vars[[label]]
    lvls <- sort(unique(data[[col]]))
    map_dfr(lvls, function(lv) {
      n_t <- sum(data[[col]] == lv, na.rm = TRUE)
      n_r <- sum(data[[col]][data$period == "Pre"]  == lv, na.rm = TRUE)
      n_p <- sum(data[[col]][data$period == "Post"] == lv, na.rm = TRUE)
      tibble(
        Category    = label,
        Level       = lv,
        Full        = tab1_pct(n_t, n_total),
        Pre         = tab1_pct(n_r, n_pre),
        Post        = tab1_pct(n_p, n_post)
      )
    })
  })
  rows
}

table1 <- make_table1(df)
print(table1, n = 60)

# ---------------------------------------------------------------------------
# Figure 1: Court Finding on Harm — Pre vs. Post
# ---------------------------------------------------------------------------
harm_levels <- c("Insufficient", "Sufficient", "Mixed", "Not Reached")

fig1_data <- df |>
  filter(!is.na(harm_finding)) |>
  mutate(harm_finding = factor(harm_finding, levels = harm_levels)) |>
  count(period, harm_finding) |>
  group_by(period) |>
  mutate(pct = 100 * n / sum(n))

fig1 <- ggplot(fig1_data, aes(x = harm_finding, y = pct, fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            position = position_dodge(width = 0.7), vjust = -0.4, size = 3) +
  scale_fill_manual(values = c("Pre" = "#4472C4", "Post" = "#ED7D31"),
                    labels = c(sprintf("Pre-Period (N=%d)", sum(df$period=="Pre")),
                               sprintf("Post-Period (N=%d)", sum(df$period=="Post")))) +
  labs(title = "Figure 1. Court Finding on Harm: Pre- vs. Post-Muldrow",
       x = "Court Finding on Harm", y = "Percentage of Cases (%)", fill = NULL) +
  theme_bw() +
  theme(legend.position = "top")

ggsave("figures/fig1_harm_finding.pdf", fig1, width = 7, height = 4.5)

# ---------------------------------------------------------------------------
# Figure 2: Primary Basis for Dismissal — Pre vs. Post (excludes survivors)
# ---------------------------------------------------------------------------
dismissal_levels <- c("Harm Insufficient", "Causation / Discriminatory Intent Insufficient",
                      "N/A — Plaintiff Survived", "Pleading Deficiency", "Other")

fig2_data <- df |>
  filter(!is.na(dismissal_primary)) |>
  mutate(dismissal_primary = factor(dismissal_primary, levels = dismissal_levels)) |>
  count(period, dismissal_primary) |>
  group_by(period) |>
  mutate(pct = 100 * n / sum(n))

fig2 <- ggplot(fig2_data, aes(x = dismissal_primary, y = pct, fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            position = position_dodge(width = 0.7), vjust = -0.4, size = 3) +
  scale_fill_manual(values = c("Pre" = "#4472C4", "Post" = "#ED7D31")) +
  scale_x_discrete(labels = c(
    "Harm Insufficient"                               = "Harm\nInsuff.",
    "Causation / Discriminatory Intent Insufficient"  = "Causation\nInsuff.",
    "N/A — Plaintiff Survived"                        = "N/A —\nSurvived",
    "Pleading Deficiency"                             = "Pleading\nDeficiency",
    "Other"                                           = "Other"
  )) +
  labs(title = "Figure 2. Primary Basis for Dismissal: Pre- vs. Post-Muldrow",
       x = "Primary Basis for Dismissal", y = "Percentage of Cases (%)", fill = NULL) +
  theme_bw() +
  theme(legend.position = "top")

ggsave("figures/fig2_dismissal_basis.pdf", fig2, width = 7, height = 4.5)

# ---------------------------------------------------------------------------
# Figure 3: Court Finding on Harm by Filing Date Subgroup
# ---------------------------------------------------------------------------
fig3_data <- df |>
  filter(!is.na(harm_finding), !is.na(filing_group)) |>
  mutate(harm_finding = factor(harm_finding, levels = harm_levels)) |>
  count(filing_group, harm_finding) |>
  group_by(filing_group) |>
  mutate(pct = 100 * n / sum(n))

fig3 <- ggplot(fig3_data, aes(x = filing_group, y = pct, fill = harm_finding)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = sprintf("%.0f%%", pct)),
            position = position_dodge(width = 0.8), vjust = -0.4, size = 2.8) +
  scale_fill_manual(values = c("Insufficient" = "#4472C4", "Sufficient" = "#ED7D31",
                                "Mixed" = "#A9D18E", "Not Reached" = "#FF0000")) +
  labs(title = "Figure 3. Court Finding on Harm by Filing Date Subgroup",
       x = NULL, y = "Percentage of Cases (%)", fill = "Finding") +
  theme_bw() +
  theme(legend.position = "top", axis.text.x = element_text(size = 9))

ggsave("figures/fig3_filing_subgroup.pdf", fig3, width = 7, height = 4.5)

# ---------------------------------------------------------------------------
# Figure 4: Harm Insufficient Rate by Circuit
# ---------------------------------------------------------------------------
fig4_data <- df |>
  filter(!is.na(harm_finding)) |>
  group_by(circuit, period) |>
  summarise(
    n              = n(),
    harm_insuff_rt = 100 * mean(harm_finding == "Insufficient"),
    .groups = "drop"
  )

fig4 <- ggplot(fig4_data, aes(x = circuit, y = harm_insuff_rt, fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.0f%%\n(N=%d)", harm_insuff_rt, n)),
            position = position_dodge(width = 0.7), vjust = -0.3, size = 2.5) +
  scale_fill_manual(values = c("Pre" = "#4472C4", "Post" = "#ED7D31")) +
  labs(title = "Figure 4. Harm Insufficient Rate by Circuit: Pre vs. Post Muldrow",
       x = "Circuit", y = "Harm Insufficient Rate (%)", fill = NULL) +
  theme_bw() +
  theme(legend.position = "top")

ggsave("figures/fig4_circuit.pdf", fig4, width = 8, height = 5)

# ---------------------------------------------------------------------------
# Figure 5: Harm Insufficient Rate by Adverse Action Type
# ---------------------------------------------------------------------------
top_actions <- df |>
  count(primary_action, sort = TRUE) |>
  slice_head(n = 8) |>
  pull(primary_action)

fig5_data <- df |>
  filter(primary_action %in% top_actions, !is.na(harm_finding)) |>
  group_by(primary_action, period) |>
  summarise(
    n              = n(),
    harm_insuff_rt = 100 * mean(harm_finding == "Insufficient"),
    .groups = "drop"
  )

fig5 <- ggplot(fig5_data, aes(x = primary_action, y = harm_insuff_rt, fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(values = c("Pre" = "#4472C4", "Post" = "#ED7D31")) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 12)) +
  labs(title = "Figure 5. Harm Insufficient Rate by Adverse Action Type: Pre vs. Post Muldrow",
       x = "Adverse Action Type", y = "Harm Insufficient Rate (%)", fill = NULL) +
  theme_bw() +
  theme(legend.position = "top", axis.text.x = element_text(size = 8))

ggsave("figures/fig5_action_type.pdf", fig5, width = 9, height = 5)

# ---------------------------------------------------------------------------
# Regression analysis (Table 7)
# Three outcomes: harm_insufficient, causation_primary, plaintiff_survived
# Spec 1: post only
# Spec 2: post + controls (circuit FE, employer, motion type, appt party)
# ---------------------------------------------------------------------------

# Linear probability models (standard in empirical legal studies)
# Using fixest for clustered SEs at district level

reg_harm_1 <- feols(harm_insufficient ~ post,
                    data = df, vcov = "HC1")

reg_harm_2 <- feols(harm_insufficient ~ post + employer_type + motion_type + appt_party |
                      circuit,
                    data = df, vcov = "HC1")

reg_caus_1 <- feols(causation_primary ~ post,
                    data = df, vcov = "HC1")

reg_caus_2 <- feols(causation_primary ~ post + employer_type + motion_type + appt_party |
                      circuit,
                    data = df, vcov = "HC1")

reg_surv_1 <- feols(plaintiff_survived ~ post,
                    data = df, vcov = "HC1")

reg_surv_2 <- feols(plaintiff_survived ~ post + employer_type + motion_type + appt_party |
                      circuit,
                    data = df, vcov = "HC1")

modelsummary(
  list(
    "Harm Insuff. (1)" = reg_harm_1,
    "Harm Insuff. (2)" = reg_harm_2,
    "Causation (1)"    = reg_caus_1,
    "Causation (2)"    = reg_caus_2,
    "Survived (1)"     = reg_surv_1,
    "Survived (2)"     = reg_surv_2
  ),
  stars = c("*" = .1, "**" = .05, "***" = .01),
  gof_map = c("nobs", "r.squared"),
  output = "tables/table7_regressions.tex"
)

# ---------------------------------------------------------------------------
# Robustness: Three-way specification (Table 8)
# Pre-period: harm only vs. harm + causation secondary
# This tests whether post-period substitution differs by pre-period case type
# ---------------------------------------------------------------------------

pre_harm_only <- df |>
  filter(period == "Pre", harm_primary == 1,
         dismissal_secondary %in% c("N/A — Single Basis Only", NA_character_))

pre_harm_caus <- df |>
  filter(period == "Pre", harm_primary == 1, had_causation_secondary == 1)

post_data <- df |> filter(period == "Post")

cat("\n--- Robustness: filing-date subgroup comparison ---\n")
df |>
  filter(period == "Post") |>
  group_by(filing_group) |>
  summarise(
    n                  = n(),
    harm_insuff_pct    = 100 * mean(harm_insufficient, na.rm = TRUE),
    causation_pct      = 100 * mean(causation_primary, na.rm = TRUE),
    survived_pct       = 100 * mean(plaintiff_survived, na.rm = TRUE)
  ) |>
  print()

cat("\n--- Full sample summary ---\n")
df |>
  group_by(period) |>
  summarise(
    n              = n(),
    harm_insuff    = 100 * mean(harm_insufficient, na.rm = TRUE),
    causation_prim = 100 * mean(causation_primary, na.rm = TRUE),
    survived       = 100 * mean(plaintiff_survived, na.rm = TRUE)
  ) |>
  print()
