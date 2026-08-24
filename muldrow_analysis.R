# ============================================================
# Muldrow v. City of St. Louis — Empirical Analysis
# Steps 1–10: Tables + Visualizations
# ============================================================

library(tidyverse)
library(readxl)
library(writexl)
library(nnet)    # multinom()
library(broom)   # tidy()

# ── Paths ──────────────────────────────────────────────────────
INFILE       <- "muldrow_coding_sheet_cleaned.xlsx"
XLOUT        <- "muldrow_tables.xlsx"
MULDROW_DATE <- as.Date("2024-04-17")

# ── 0. Load & prepare ─────────────────────────────────────────
df_raw <- read_excel(INFILE, sheet = "Coding Sheet")

DISMISSAL_MAP <- c(
  "Harm Insufficient"                              = "Harm Insufficient",
  "Causation / Discriminatory Intent Insufficient" = "Causation Insufficient",
  "N/A — Plaintiff Survived"                       = "N/A — Plaintiff Survived",
  "Pleading Deficiency"                            = "Pleading Deficiency",
  "Procedural / Forfeiture"                        = "Other",
  "Multiple Bases"                                 = "Other",
  "Other"                                          = "Other"
)

HARM_ORDER      <- c("Insufficient", "Sufficient", "Mixed", "Not Reached")
DISMISSAL_ORDER <- c("Harm Insufficient", "Causation Insufficient",
                     "N/A — Plaintiff Survived", "Pleading Deficiency", "Other")
OUTCOME_ORDER   <- c("Dismissed — Plaintiff", "Mixed", "Survived — Plaintiff")
CIRCUITS        <- c("First","Second","Fourth","Seventh","Eighth","Tenth","Eleventh")
EMP_TYPES       <- c("Government - Federal","Government - Municipal",
                     "Government - State","Private")

df <- df_raw %>%
  filter(!is.na(`Period (Pre/Post)`)) %>%
  mutate(
    Filing_Date    = as.Date(`Filing Date`,   format = "%m/%d/%Y"),
    Decision_Date  = as.Date(`Decision Date`, format = "%m/%d/%Y"),
    Dismissal_Clean = recode(`Primary Basis for Dismissal`, !!!DISMISSAL_MAP,
                              .default = "Other"),
    Filing_Subgroup = case_when(
      `Period (Pre/Post)` == "Pre"                     ~ "Pre-Period",
      is.na(Filing_Date) | Filing_Date < MULDROW_DATE  ~ "Post — Pre-Muldrow Filing",
      TRUE                                             ~ "Post — Post-Muldrow Filing"
    ),
    post        = as.integer(`Period (Pre/Post)` == "Post"),
    harm_insuff = as.integer(`Court Finding on Harm` == "Insufficient")
  )

pre            <- filter(df, `Period (Pre/Post)` == "Pre")
post_df        <- filter(df, `Period (Pre/Post)` == "Post")
post_prefiled  <- filter(df, Filing_Subgroup == "Post — Pre-Muldrow Filing")
post_postfiled <- filter(df, Filing_Subgroup == "Post — Post-Muldrow Filing")

cat(sprintf("Total: %d  Pre: %d  Post: %d  Post-pre-filed: %d  Post-post-filed: %d\n",
            nrow(df), nrow(pre), nrow(post_df),
            nrow(post_prefiled), nrow(post_postfiled)))

# ── Helpers ────────────────────────────────────────────────────
insuff_rate <- function(d) {
  if (nrow(d) == 0) return(NA_real_)
  100 * mean(d$`Court Finding on Harm` == "Insufficient", na.rm = TRUE)
}

chi2_p <- function(tbl) {
  mat <- as.matrix(tbl)
  mat <- mat[rowSums(mat) > 0, colSums(mat) > 0, drop = FALSE]
  if (nrow(mat) < 2 || ncol(mat) < 2) return("—")
  res   <- chisq.test(mat, correct = FALSE)
  stars <- ifelse(res$p.value < 0.001, "***",
           ifelse(res$p.value < 0.01,  "**",
           ifelse(res$p.value < 0.05,  "*", "")))
  sprintf("%.3f%s", res$p.value, stars)
}

# ── Step 1: Descriptive Statistics ────────────────────────────
desc_rows <- function(label, col, cats) {
  bind_rows(
    tibble(Characteristic = label, Full_Sample = "", Pre_Period = "", Post_Period = ""),
    map_dfr(cats, function(cat) {
      tibble(
        Characteristic = paste0("  ", cat),
        Full_Sample    = sprintf("%d (%.1f%%)", sum(df[[col]] == cat, na.rm = TRUE),
                                 100 * mean(df[[col]] == cat, na.rm = TRUE)),
        Pre_Period     = sprintf("%d (%.1f%%)", sum(pre[[col]] == cat, na.rm = TRUE),
                                 100 * mean(pre[[col]] == cat, na.rm = TRUE)),
        Post_Period    = sprintf("%d (%.1f%%)", sum(post_df[[col]] == cat, na.rm = TRUE),
                                 100 * mean(post_df[[col]] == cat, na.rm = TRUE))
      )
    })
  )
}

table1 <- bind_rows(
  desc_rows("Circuit",                    "Circuit",                            CIRCUITS),
  desc_rows("Primary Adverse Action",     "Primary Non-Economic Adverse Action",
            sort(unique(na.omit(df$`Primary Non-Economic Adverse Action`)))),
  desc_rows("Employer Type",              "Employer Type",                      EMP_TYPES),
  desc_rows("Protected Characteristic",  "Protected Characteristic(s)",
            sort(unique(na.omit(df$`Protected Characteristic(s)`)))),
  desc_rows("Appointing President Party", "Appointing President Party",         c("Democrat","Republican")),
  desc_rows("Motion Type",                "Motion Type Decided",
            sort(unique(na.omit(df$`Motion Type Decided`)))),
  desc_rows("Court Finding on Harm",      "Court Finding on Harm",              HARM_ORDER),
  desc_rows("Primary Basis for Dismissal","Dismissal_Clean",                    DISMISSAL_ORDER)
)

# ── Step 2: Pre/Post Comparison ────────────────────────────────
two_way_section <- function(col, cats, lab) {
  ct    <- table(df[[col]], df$`Period (Pre/Post)`)
  p_str <- chi2_p(ct)
  bind_rows(
    tibble(Outcome = lab, Pre_N = "", Pre_Pct = "", Post_N = "", Post_Pct = "", Chi2_p = ""),
    map_dfr(seq_along(cats), function(i) {
      cat_i <- cats[i]
      np_   <- sum(pre[[col]] == cat_i, na.rm = TRUE)
      npo_  <- sum(post_df[[col]] == cat_i, na.rm = TRUE)
      tibble(
        Outcome  = paste0("  ", cat_i),
        Pre_N    = as.character(np_),
        Pre_Pct  = sprintf("%.1f%%", 100 * np_ / nrow(pre)),
        Post_N   = as.character(npo_),
        Post_Pct = sprintf("%.1f%%", 100 * npo_ / nrow(post_df)),
        Chi2_p   = if (i == 1) p_str else ""
      )
    })
  )
}

table2 <- bind_rows(
  two_way_section("Court Finding on Harm", HARM_ORDER,     "Court Finding on Harm"),
  two_way_section("Dismissal_Clean",       DISMISSAL_ORDER,"Primary Basis for Dismissal"),
  two_way_section("Non-Economic Adverse Action Claim Outcome",
                  OUTCOME_ORDER, "Non-Economic Adverse Action Claim Outcome")
)

# ── Step 3: Three-Way Filing Subgroup ─────────────────────────
three_way_section <- function(col, cats, lab) {
  ct    <- table(df[[col]], df$Filing_Subgroup)
  p_str <- chi2_p(ct)
  bind_rows(
    tibble(Outcome = lab, Pre_N = "", Pre_Pct = "",
           PostPre_N = "", PostPre_Pct = "",
           PostPost_N = "", PostPost_Pct = "", Chi2_p = ""),
    map_dfr(seq_along(cats), function(i) {
      cat_i <- cats[i]
      np_   <- sum(pre[[col]] == cat_i, na.rm = TRUE)
      npp_  <- sum(post_prefiled[[col]] == cat_i, na.rm = TRUE)
      npo_  <- sum(post_postfiled[[col]] == cat_i, na.rm = TRUE)
      tibble(
        Outcome      = paste0("  ", cat_i),
        Pre_N        = as.character(np_),
        Pre_Pct      = sprintf("%.1f%%", 100 * np_  / max(nrow(pre), 1)),
        PostPre_N    = as.character(npp_),
        PostPre_Pct  = sprintf("%.1f%%", 100 * npp_ / max(nrow(post_prefiled), 1)),
        PostPost_N   = as.character(npo_),
        PostPost_Pct = sprintf("%.1f%%", 100 * npo_ / max(nrow(post_postfiled), 1)),
        Chi2_p       = if (i == 1) p_str else ""
      )
    })
  )
}

table3 <- bind_rows(
  three_way_section("Court Finding on Harm", HARM_ORDER,     "Court Finding on Harm"),
  three_way_section("Dismissal_Clean",       DISMISSAL_ORDER,"Primary Basis for Dismissal"),
  three_way_section("Non-Economic Adverse Action Claim Outcome",
                    OUTCOME_ORDER, "Non-Economic Adverse Action Claim Outcome")
)

# ── Step 4: Circuit Breakdown ─────────────────────────────────
table4 <- map_dfr(CIRCUITS, function(circ) {
  dp <- filter(pre,     Circuit == circ)
  dq <- filter(post_df, Circuit == circ)
  ct <- table(df$`Court Finding on Harm`[df$Circuit == circ],
              df$`Period (Pre/Post)`[df$Circuit == circ])
  tibble(
    Circuit         = circ,
    Pre_N           = nrow(dp),
    Pre_Insuff_Pct  = if (nrow(dp) > 0) sprintf("%.1f%%", insuff_rate(dp)) else "—",
    Post_N          = nrow(dq),
    Post_Insuff_Pct = if (nrow(dq) > 0) sprintf("%.1f%%", insuff_rate(dq)) else "—",
    Post_Suff_Pct   = if (nrow(dq) > 0)
                        sprintf("%.1f%%", 100*mean(dq$`Court Finding on Harm`=="Sufficient",na.rm=T)) else "—",
    Post_NR_Pct     = if (nrow(dq) > 0)
                        sprintf("%.1f%%", 100*mean(dq$`Court Finding on Harm`=="Not Reached",na.rm=T)) else "—",
    Chi2_p          = chi2_p(ct),
    Note            = if (circ == "First") "n=1 pre-period" else ""
  )
})

# ── Step 5: Adverse Action Breakdown ──────────────────────────
aa_col  <- "Primary Non-Economic Adverse Action"
aa_cats <- sort(unique(na.omit(df[[aa_col]])))

table5 <- map_dfr(aa_cats, function(act) {
  dp <- filter(pre,     .data[[aa_col]] == act)
  dq <- filter(post_df, .data[[aa_col]] == act)
  ct <- table(df$`Court Finding on Harm`[df[[aa_col]] == act],
              df$`Period (Pre/Post)`[df[[aa_col]] == act])
  tibble(
    Adverse_Action  = act,
    Pre_N           = nrow(dp),
    Pre_Insuff_Pct  = if (nrow(dp) > 0) sprintf("%.1f%%", insuff_rate(dp)) else "—",
    Post_N          = nrow(dq),
    Post_Insuff_Pct = if (nrow(dq) > 0) sprintf("%.1f%%", insuff_rate(dq)) else "—",
    Chi2_p          = chi2_p(ct)
  )
})

# ── Step 6: Employer Type Breakdown ───────────────────────────
table6 <- map_dfr(EMP_TYPES, function(emp) {
  dp <- filter(pre,     `Employer Type` == emp)
  dq <- filter(post_df, `Employer Type` == emp)
  ct <- table(df$`Court Finding on Harm`[df$`Employer Type` == emp],
              df$`Period (Pre/Post)`[df$`Employer Type` == emp])
  tibble(
    Employer_Type   = emp,
    Pre_N           = nrow(dp),
    Pre_Insuff_Pct  = if (nrow(dp) > 0) sprintf("%.1f%%", insuff_rate(dp)) else "—",
    Post_N          = nrow(dq),
    Post_Insuff_Pct = if (nrow(dq) > 0) sprintf("%.1f%%", insuff_rate(dq)) else "—",
    Chi2_p          = chi2_p(ct)
  )
})

# ── Step 7: Logistic Regression — Harm Insufficient ───────────
reg_df <- df %>%
  filter(!is.na(`Court Finding on Harm`), !is.na(`Period (Pre/Post)`),
         !is.na(Circuit), !is.na(`Primary Non-Economic Adverse Action`),
         !is.na(`Employer Type`), !is.na(`Appointing President Party`),
         !is.na(`Motion Type Decided`)) %>%
  mutate(
    Circuit        = relevel(factor(Circuit), ref = "Eighth"),
    adverse_action = relevel(factor(`Primary Non-Economic Adverse Action`),
                             ref = "Exclusion from Opportunities"),
    employer_type  = relevel(factor(`Employer Type`), ref = "Government - Federal"),
    party          = relevel(factor(`Appointing President Party`), ref = "Democrat"),
    motion_type    = relevel(factor(`Motion Type Decided`), ref = "12(b)(6)"),
    post_postfiled = as.integer(post == 1 &
                                  Filing_Subgroup == "Post — Post-Muldrow Filing")
  )

logit1 <- glm(harm_insuff ~ post + Circuit + adverse_action +
                employer_type + party + motion_type,
              data = reg_df, family = binomial)
logit2 <- glm(harm_insuff ~ post + post_postfiled + Circuit + adverse_action +
                employer_type + party + motion_type,
              data = reg_df, family = binomial)

format_logit <- function(model, spec_label) {
  tidy(model, exponentiate = TRUE, conf.int = TRUE) %>%
    mutate(
      stars   = case_when(p.value < 0.001 ~ "***", p.value < 0.01 ~ "**",
                          p.value < 0.05  ~ "*",   TRUE           ~ ""),
      OR      = sprintf("%.3f", estimate),
      CI_95   = sprintf("[%.3f, %.3f]", conf.low, conf.high),
      p_value = sprintf("%.3f%s", p.value, stars),
      Spec    = spec_label
    ) %>%
    select(Variable = term, OR, CI_95, p_value, Spec)
}

table7 <- bind_rows(
  format_logit(logit1, sprintf("Spec 1 — Base (N=%d)", nrow(reg_df))),
  format_logit(logit2, sprintf("Spec 2 — + Filing Subgroup (N=%d)", nrow(reg_df)))
)

# ── Step 8: Binary Logit — Causation vs Harm Insufficient ─────
bin_df <- df %>%
  filter(`Primary Basis for Dismissal` %in% c(
    "Harm Insufficient",
    "Causation / Discriminatory Intent Insufficient"
  )) %>%
  filter(!is.na(Circuit), !is.na(`Employer Type`),
         !is.na(`Appointing President Party`), !is.na(`Motion Type Decided`)) %>%
  mutate(
    causation     = as.integer(`Primary Basis for Dismissal` ==
                                 "Causation / Discriminatory Intent Insufficient"),
    Circuit       = relevel(factor(Circuit), ref = "Eighth"),
    employer_type = relevel(factor(`Employer Type`), ref = "Government - Federal"),
    party         = relevel(factor(`Appointing President Party`), ref = "Democrat"),
    motion_type   = relevel(factor(`Motion Type Decided`), ref = "12(b)(6)")
  )

bin_model <- glm(causation ~ post + Circuit + employer_type + party + motion_type,
                 data = bin_df, family = binomial)

table8 <- tidy(bin_model, exponentiate = TRUE, conf.int = TRUE) %>%
  mutate(
    stars   = case_when(p.value < 0.001 ~ "***", p.value < 0.01 ~ "**",
                        p.value < 0.05  ~ "*",   TRUE           ~ ""),
    OR      = sprintf("%.3f", estimate),
    CI_95   = sprintf("[%.3f, %.3f]", conf.low, conf.high),
    p_value = sprintf("%.3f%s", p.value, stars),
    Note    = sprintf("N=%d. Outcome=1 if Causation Insufficient, 0 if Harm Insufficient.",
                      nrow(bin_df))
  ) %>%
  select(Variable = term, OR, CI_95, p_value)

post_coef <- tidy(bin_model, exponentiate = TRUE, conf.int = TRUE) %>% filter(term == "post")
cat(sprintf("\nTable 8 — Binary logit: OR_post=%.3f [%.3f,%.3f] p=%.4f\n",
            post_coef$estimate, post_coef$conf.low, post_coef$conf.high, post_coef$p.value))

# ── Step 9: Robustness Checks ─────────────────────────────────
robustness_row <- function(label, d_pre, d_post) {
  ct <- table(
    c(d_pre$`Court Finding on Harm`, d_post$`Court Finding on Harm`),
    c(rep("Pre", nrow(d_pre)), rep("Post", nrow(d_post)))
  )
  tibble(
    Sample        = label,
    Pre_N         = nrow(d_pre),
    Pre_Insuff    = if (nrow(d_pre)  > 0) sprintf("%.1f%%", insuff_rate(d_pre))  else "—",
    Post_N        = nrow(d_post),
    Post_Insuff   = if (nrow(d_post) > 0) sprintf("%.1f%%", insuff_rate(d_post)) else "—",
    Pre_Survived  = sprintf("%.1f%%",
                            100 * mean(d_pre$Dismissal_Clean  == "N/A — Plaintiff Survived", na.rm = TRUE)),
    Post_Survived = sprintf("%.1f%%",
                            100 * mean(d_post$Dismissal_Clean == "N/A — Plaintiff Survived", na.rm = TRUE)),
    Chi2_p        = chi2_p(ct)
  )
}

table9 <- bind_rows(
  robustness_row("Full Sample (baseline)", pre, post_df),
  robustness_row("Excl. Uncertain confidence",
    filter(pre,     `Dismissal Basis Confidence` != "Uncertain"),
    filter(post_df, `Dismissal Basis Confidence` != "Uncertain")),
  robustness_row("Excl. Multiple Bases",
    filter(pre,     `Primary Basis for Dismissal` != "Multiple Bases"),
    filter(post_df, `Primary Basis for Dismissal` != "Multiple Bases")),
  robustness_row("Excl. Fourth Circuit",
    filter(pre,     Circuit != "Fourth"),
    filter(post_df, Circuit != "Fourth")),
  robustness_row("Post — post-Muldrow filing only", pre, post_postfiled)
)

# ── Save all tables to one workbook ───────────────────────────
write_xlsx(
  list(
    "Table 1 — Descriptive Stats"    = table1,
    "Table 2 — Pre Post Comparison"  = table2,
    "Table 3 — Filing Date Subgroup" = table3,
    "Table 4 — Circuit Breakdown"    = table4,
    "Table 5 — Adverse Action"       = table5,
    "Table 6 — Employer Type"        = table6,
    "Table 7 — Logistic Regression"  = table7,
    "Table 8 — Binary Logit"         = table8,
    "Table 9 — Robustness Checks"    = table9
  ),
  XLOUT
)
cat(sprintf("\nAll tables saved: %s\n", XLOUT))

# ── Step 10: Visualizations ───────────────────────────────────
pal2 <- c("Pre-Period" = "#2E6DA4", "Post-Period" = "#E07B39")

# Fig 1: Court Finding on Harm
fig1_data <- df %>%
  count(`Period (Pre/Post)`, `Court Finding on Harm`) %>%
  group_by(`Period (Pre/Post)`) %>%
  mutate(pct    = 100 * n / sum(n),
         Period  = ifelse(`Period (Pre/Post)` == "Pre", "Pre-Period", "Post-Period"),
         Finding = factor(`Court Finding on Harm`, levels = HARM_ORDER))

p1 <- ggplot(fig1_data, aes(x = Finding, y = pct, fill = Period)) +
  geom_col(position = "dodge", width = 0.7, colour = "white", linewidth = 0.3) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), position = position_dodge(0.7),
            vjust = -0.4, size = 3, fontface = "bold") +
  scale_fill_manual(values = pal2) +
  labs(title = "Figure 1. Court Finding on Harm: Pre- vs. Post-Muldrow",
       x = "Court Finding on Harm", y = "Percentage of Cases (%)", fill = NULL) +
  theme_classic(base_size = 11) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_line(linetype = "dashed", colour = "grey80"))

ggsave("fig1_harm_finding_pre_post.png", p1, width = 8, height = 5, dpi = 300)

# Fig 2: Primary Basis for Dismissal — 3 categories only
FIG2_CATS <- c("Harm Insufficient", "Causation Insufficient", "N/A — Plaintiff Survived")
fig2_data <- df %>%
  filter(Dismissal_Clean %in% FIG2_CATS) %>%
  count(`Period (Pre/Post)`, Dismissal_Clean) %>%
  group_by(`Period (Pre/Post)`) %>%
  mutate(pct    = 100 * n / sum(n),
         Period = ifelse(`Period (Pre/Post)` == "Pre", "Pre-Period", "Post-Period"),
         Basis  = factor(Dismissal_Clean, levels = FIG2_CATS))

p2 <- ggplot(fig2_data, aes(x = Basis, y = pct, fill = Period)) +
  geom_col(position = "dodge", width = 0.7, colour = "white") +
  geom_text(aes(label = sprintf("%.1f%%", pct)), position = position_dodge(0.7),
            vjust = -0.4, size = 3.2, fontface = "bold") +
  scale_fill_manual(values = pal2) +
  scale_x_discrete(labels = c("Harm\nInsuff.", "Causation\nInsuff.", "N/A —\nSurvived")) +
  labs(title = "Figure 2. Primary Basis for Dismissal: Pre- vs. Post-Muldrow",
       x = "Primary Basis for Dismissal",
       y = "Percentage of Cases with Recorded Basis (%)", fill = NULL) +
  theme_classic(base_size = 11) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_line(linetype = "dashed", colour = "grey80"))

ggsave("fig2_dismissal_basis_pre_post.png", p2, width = 8, height = 5, dpi = 300)

# Fig 3: Three-way filing subgroup
fig3_data <- df %>%
  count(Filing_Subgroup, `Court Finding on Harm`) %>%
  group_by(Filing_Subgroup) %>%
  mutate(pct     = 100 * n / sum(n),
         Finding = factor(`Court Finding on Harm`, levels = HARM_ORDER),
         Group   = factor(Filing_Subgroup,
                   levels = c("Pre-Period",
                              "Post — Pre-Muldrow Filing",
                              "Post — Post-Muldrow Filing")))

group_ns <- df %>%
  count(Filing_Subgroup) %>%
  deframe()

p3 <- ggplot(fig3_data, aes(x = Group, y = pct, fill = Finding)) +
  geom_col(position = "dodge", width = 0.8, colour = "white") +
  scale_fill_manual(values = c("#2E6DA4","#E07B39","#3A8C5C","#C0392B")) +
  scale_x_discrete(labels = c(
    sprintf("Pre-Period\n(N=%d)", group_ns["Pre-Period"]),
    sprintf("Post — Pre-Muldrow\nFiling (N=%d)", group_ns["Post — Pre-Muldrow Filing"]),
    sprintf("Post — Post-Muldrow\nFiling (N=%d)", group_ns["Post — Post-Muldrow Filing"])
  )) +
  labs(title = "Figure 3. Court Finding on Harm by Filing Date Subgroup",
       x = NULL, y = "Percentage of Cases (%)", fill = "Finding") +
  theme_classic(base_size = 11) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_line(linetype = "dashed", colour = "grey80"))

ggsave("fig3_three_way_filing.png", p3, width = 9, height = 5, dpi = 300)

# Fig 4: Circuit harm insufficient rate — First Circuit asterisk
fig4_data <- df %>%
  group_by(Circuit, `Period (Pre/Post)`) %>%
  summarise(Insuff_Rate = insuff_rate(cur_data()),
            N = n(), .groups = "drop") %>%
  mutate(Period  = ifelse(`Period (Pre/Post)` == "Pre", "Pre-Period", "Post-Period"),
         Circuit = factor(Circuit, levels = CIRCUITS),
         Label   = ifelse(Circuit == "First", "First*", as.character(Circuit)))

p4 <- ggplot(fig4_data, aes(x = Label, y = Insuff_Rate, fill = Period)) +
  geom_col(position = "dodge", width = 0.7, colour = "white") +
  geom_text(aes(label = sprintf("%.0f%%\n(N=%d)", Insuff_Rate, N)),
            position = position_dodge(0.7), vjust = -0.2, size = 2.8) +
  scale_fill_manual(values = pal2) +
  labs(title = "Figure 4. Harm Insufficient Rate by Circuit: Pre vs. Post Muldrow",
       x = "Circuit", y = "Harm Insufficient Rate (%)", fill = NULL,
       caption = "* First Circuit: n=1 pre-period") +
  coord_cartesian(ylim = c(0, 110)) +
  theme_classic(base_size = 11) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_line(linetype = "dashed", colour = "grey80"),
        plot.caption = element_text(colour = "grey50", size = 8, hjust = 0))

ggsave("fig4_circuit_harm_insufficient.png", p4, width = 9, height = 5, dpi = 300)

# Fig 5: Adverse action harm insufficient rate — restrict to ≥10 pre-period cases
fig5_actions <- aa_cats[map_int(aa_cats, ~ sum(pre[[aa_col]] == .x, na.rm = TRUE)) >= 10]

fig5_data <- df %>%
  filter(.data[[aa_col]] %in% fig5_actions) %>%
  group_by(.data[[aa_col]], `Period (Pre/Post)`) %>%
  summarise(Insuff_Rate = insuff_rate(cur_data()),
            N = n(), .groups = "drop") %>%
  mutate(Period = ifelse(`Period (Pre/Post)` == "Pre", "Pre-Period", "Post-Period"),
         Action = factor(.data[[aa_col]], levels = fig5_actions))

p5 <- ggplot(fig5_data, aes(x = Action, y = Insuff_Rate, fill = Period)) +
  geom_col(position = "dodge", width = 0.7, colour = "white") +
  geom_text(aes(label = sprintf("N=%d", N)), position = position_dodge(0.7),
            vjust = -0.4, size = 2.5) +
  scale_fill_manual(values = pal2) +
  labs(title = "Figure 5. Harm Insufficient Rate by Adverse Action Type: Pre vs. Post Muldrow",
       x = "Adverse Action Type", y = "Harm Insufficient Rate (%)", fill = NULL) +
  coord_cartesian(ylim = c(0, 115)) +
  theme_classic(base_size = 11) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
        panel.grid.major.y = element_line(linetype = "dashed", colour = "grey80"))

ggsave("fig5_adverse_action_harm_insufficient.png", p5, width = 11, height = 5, dpi = 300)

cat("\n═══ Analysis complete ═══\n")
cat(sprintf("Tables:  %s\n", XLOUT))
cat("Figures: fig1–fig5.png\n")
