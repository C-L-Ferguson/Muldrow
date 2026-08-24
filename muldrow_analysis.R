# ============================================================
# Muldrow v. City of St. Louis — Empirical Analysis
# Steps 1–9: Tables + Step 10: Visualizations
# ============================================================

library(tidyverse)
library(readxl)
library(writexl)
library(openxlsx)
library(nnet)       # multinom()
library(broom)      # tidy()

# ── Paths ──────────────────────────────────────────────────────
INFILE <- "muldrow_coding_sheet_cleaned.xlsx"
XLOUT  <- "muldrow_tables_R.xlsx"
MULDROW_DATE <- as.Date("2024-04-17")

# ── 0. Load & prepare ─────────────────────────────────────────
df <- read_excel(INFILE, sheet = "Coding Sheet")

DISMISSAL_MAP <- c(
  "Harm Insufficient"                              = "Harm Insufficient",
  "Causation / Discriminatory Intent Insufficient" = "Causation Insufficient",
  "N/A — Plaintiff Survived"                       = "N/A — Plaintiff Survived",
  "Pleading Deficiency"                            = "Pleading Deficiency",
  "Procedural / Forfeiture"                        = "Other",
  "Multiple Bases"                                 = "Other",
  "Other"                                          = "Other"
)

HARM_ORDER      <- c("Insufficient","Sufficient","Mixed","Not Reached")
DISMISSAL_ORDER <- c("Harm Insufficient","Causation Insufficient",
                     "N/A — Plaintiff Survived","Pleading Deficiency","Other")

df <- df %>%
  filter(!is.na(`Period (Pre/Post)`)) %>%
  mutate(
    Filing_Date   = as.Date(`Filing Date`),
    Decision_Date = as.Date(`Decision Date`),
    Dismissal_Clean = recode(`Primary Basis for Dismissal`, !!!DISMISSAL_MAP,
                             .default = "Other"),
    Filing_Subgroup = case_when(
      `Period (Pre/Post)` == "Pre"                    ~ "Pre-Period",
      is.na(Filing_Date) | Filing_Date < MULDROW_DATE ~ "Post — Pre-Muldrow Filing",
      TRUE                                            ~ "Post — Post-Muldrow Filing"
    ),
    post       = as.integer(`Period (Pre/Post)` == "Post"),
    harm_insuff= as.integer(`Court Finding on Harm` == "Insufficient")
  )

pre  <- filter(df, `Period (Pre/Post)` == "Pre")
post <- filter(df, `Period (Pre/Post)` == "Post")
post_prefiled  <- filter(df, Filing_Subgroup == "Post — Pre-Muldrow Filing")
post_postfiled <- filter(df, Filing_Subgroup == "Post — Post-Muldrow Filing")

cat(sprintf("Total: %d  Pre: %d  Post: %d\n", nrow(df), nrow(pre), nrow(post)))

# ── Helper: count/pct ──────────────────────────────────────────
pct_tbl <- function(data, col, cats) {
  n_total <- nrow(data)
  map_dfr(cats, function(cat) {
    n <- sum(data[[col]] == cat, na.rm = TRUE)
    tibble(Category = cat, N = n,
           Pct = if (n_total > 0) sprintf("%.1f%%", 100*n/n_total) else "—")
  })
}

chi2_p <- function(tbl) {
  mat <- as.matrix(tbl)
  mat <- mat[rowSums(mat) > 0, colSums(mat) > 0, drop = FALSE]
  if (nrow(mat) < 2 || ncol(mat) < 2) return("—")
  res <- chisq.test(mat, correct = FALSE)
  stars <- ifelse(res$p.value < 0.001, "***",
           ifelse(res$p.value < 0.01,  "**",
           ifelse(res$p.value < 0.05,  "*", "")))
  sprintf("%.3f%s", res$p.value, stars)
}

# ── Step 1: Descriptive Statistics ────────────────────────────
desc_rows <- function(label, col, cats) {
  bind_rows(
    tibble(Characteristic = label, Full = "", Pre = "", Post = ""),
    map_dfr(cats, function(cat) {
      tibble(
        Characteristic = paste0("  ", cat),
        Full = sprintf("%d (%.1f%%)", sum(df[[col]]==cat,na.rm=T),
                       100*mean(df[[col]]==cat,na.rm=T)),
        Pre  = sprintf("%d (%.1f%%)", sum(pre[[col]]==cat,na.rm=T),
                       100*mean(pre[[col]]==cat,na.rm=T)),
        Post = sprintf("%d (%.1f%%)", sum(post[[col]]==cat,na.rm=T),
                       100*mean(post[[col]]==cat,na.rm=T))
      )
    })
  )
}

table1 <- bind_rows(
  desc_rows("Circuit",                   "Circuit",
            c("First","Second","Fourth","Seventh","Eighth","Tenth","Eleventh")),
  desc_rows("Primary Adverse Action",    "Primary Non-Economic Adverse Action",
            sort(unique(na.omit(df$`Primary Non-Economic Adverse Action`)))),
  desc_rows("Employer Type",             "Employer Type",
            c("Government - Federal","Government - Municipal","Government - State","Private")),
  desc_rows("Protected Characteristic",  "Protected Characteristic(s)",
            sort(unique(na.omit(df$`Protected Characteristic(s)`)))),
  desc_rows("Appointing President Party","Appointing President Party",
            c("Democrat","Republican")),
  desc_rows("Motion Type",               "Motion Type Decided",
            sort(unique(na.omit(df$`Motion Type Decided`)))),
  desc_rows("Court Finding on Harm",     "Court Finding on Harm",  HARM_ORDER),
  desc_rows("Primary Basis (clean)",     "Dismissal_Clean", DISMISSAL_ORDER)
)
cat("Table 1 rows:", nrow(table1), "\n")

# ── Step 2: Pre/Post Comparison ────────────────────────────────
two_way_section <- function(col, cats, lab) {
  ct <- table(df[[col]], df$`Period (Pre/Post)`)
  p_str <- chi2_p(ct)
  bind_rows(
    tibble(Outcome = lab, Pre_N="", Pre_Pct="", Post_N="", Post_Pct="",
           Chi2_p = p_str),
    map_dfr(seq_along(cats), function(i) {
      cat <- cats[i]
      np_ <- sum(pre[[col]]==cat, na.rm=T)
      npo <- sum(post[[col]]==cat, na.rm=T)
      tibble(
        Outcome  = paste0("  ", cat),
        Pre_N    = as.character(np_),
        Pre_Pct  = sprintf("%.1f%%", 100*np_/nrow(pre)),
        Post_N   = as.character(npo),
        Post_Pct = sprintf("%.1f%%", 100*npo/nrow(post)),
        Chi2_p   = if (i == 1) p_str else ""
      )
    })
  )
}

table2 <- bind_rows(
  two_way_section("Court Finding on Harm", HARM_ORDER, "Court Finding on Harm"),
  two_way_section("Dismissal_Clean",       DISMISSAL_ORDER, "Primary Basis for Dismissal")
)

# ── Step 3: Three-way Filing Subgroup ─────────────────────────
three_way_section <- function(col, cats, lab) {
  ct <- table(df[[col]], df$Filing_Subgroup)
  p_str <- chi2_p(ct)
  bind_rows(
    tibble(Outcome=lab, Pre_N="",Pre_Pct="", PostPre_N="",PostPre_Pct="",
           PostPost_N="",PostPost_Pct="", Chi2_p=p_str),
    map_dfr(seq_along(cats), function(i) {
      cat <- cats[i]
      np_  <- sum(pre[[col]]==cat,na.rm=T)
      npp_ <- sum(post_prefiled[[col]]==cat,na.rm=T)
      npo_ <- sum(post_postfiled[[col]]==cat,na.rm=T)
      tibble(
        Outcome      = paste0("  ",cat),
        Pre_N        = as.character(np_),
        Pre_Pct      = sprintf("%.1f%%",100*np_/nrow(pre)),
        PostPre_N    = as.character(npp_),
        PostPre_Pct  = sprintf("%.1f%%",100*npp_/max(nrow(post_prefiled),1)),
        PostPost_N   = as.character(npo_),
        PostPost_Pct = sprintf("%.1f%%",100*npo_/max(nrow(post_postfiled),1)),
        Chi2_p       = if(i==1) p_str else ""
      )
    })
  )
}

table3 <- bind_rows(
  three_way_section("Court Finding on Harm","Court Finding on Harm",HARM_ORDER),
  three_way_section("Dismissal_Clean","Primary Basis for Dismissal",DISMISSAL_ORDER)
)

# ── Step 4: Circuit Breakdown ─────────────────────────────────
circuits <- c("First","Second","Fourth","Seventh","Eighth","Tenth","Eleventh")
insuff_rate <- function(d) {
  if(nrow(d)==0) return(NA_real_)
  100*mean(d$`Court Finding on Harm`=="Insufficient",na.rm=T)
}

table4 <- map_dfr(circuits, function(circ) {
  dp <- filter(pre,  Circuit==circ)
  dq <- filter(post, Circuit==circ)
  ct <- table(df$`Court Finding on Harm`[df$Circuit==circ],
              df$`Period (Pre/Post)`[df$Circuit==circ])
  tibble(
    Circuit        = circ,
    Pre_N          = nrow(dp),
    Pre_Insuff_Pct = sprintf("%.1f%%", insuff_rate(dp)),
    Post_N         = nrow(dq),
    Post_Insuff_Pct= sprintf("%.1f%%", insuff_rate(dq)),
    Post_Suff_Pct  = sprintf("%.1f%%", 100*mean(dq$`Court Finding on Harm`=="Sufficient",na.rm=T)),
    Post_NR_Pct    = sprintf("%.1f%%", 100*mean(dq$`Court Finding on Harm`=="Not Reached",na.rm=T)),
    Chi2_p         = chi2_p(ct)
  )
})

# ── Step 5: Adverse Action Breakdown ──────────────────────────
aa_col <- "Primary Non-Economic Adverse Action"
table5 <- map_dfr(sort(unique(na.omit(df[[aa_col]]))), function(act) {
  dp <- filter(pre,  .data[[aa_col]]==act)
  dq <- filter(post, .data[[aa_col]]==act)
  ct <- table(df$`Court Finding on Harm`[df[[aa_col]]==act],
              df$`Period (Pre/Post)`[df[[aa_col]]==act])
  tibble(
    Adverse_Action = act,
    Pre_N          = nrow(dp),
    Pre_Insuff_Pct = ifelse(nrow(dp)>0, sprintf("%.1f%%",insuff_rate(dp)),"—"),
    Post_N         = nrow(dq),
    Post_Insuff_Pct= ifelse(nrow(dq)>0, sprintf("%.1f%%",insuff_rate(dq)),"—"),
    Chi2_p         = chi2_p(ct)
  )
})

# ── Step 6: Employer Type Breakdown ───────────────────────────
emp_types <- c("Government - Federal","Government - Municipal",
               "Government - State","Private")
table6 <- map_dfr(emp_types, function(emp) {
  dp <- filter(pre,  `Employer Type`==emp)
  dq <- filter(post, `Employer Type`==emp)
  ct <- table(df$`Court Finding on Harm`[df$`Employer Type`==emp],
              df$`Period (Pre/Post)`[df$`Employer Type`==emp])
  tibble(
    Employer_Type  = emp,
    Pre_N          = nrow(dp),
    Pre_Insuff_Pct = ifelse(nrow(dp)>0, sprintf("%.1f%%",insuff_rate(dp)),"—"),
    Post_N         = nrow(dq),
    Post_Insuff_Pct= ifelse(nrow(dq)>0, sprintf("%.1f%%",insuff_rate(dq)),"—"),
    Chi2_p         = chi2_p(ct)
  )
})

# ── Step 7: Logistic Regression ────────────────────────────────
reg_df <- df %>%
  filter(!is.na(`Court Finding on Harm`), !is.na(`Period (Pre/Post)`),
         !is.na(Circuit), !is.na(`Primary Non-Economic Adverse Action`),
         !is.na(`Employer Type`), !is.na(`Appointing President Party`),
         !is.na(`Motion Type Decided`)) %>%
  mutate(
    Circuit        = relevel(factor(Circuit), ref="Eighth"),
    adverse_action = relevel(factor(`Primary Non-Economic Adverse Action`),
                             ref="Exclusion from Opportunities"),
    employer_type  = relevel(factor(`Employer Type`), ref="Government - Federal"),
    party          = relevel(factor(`Appointing President Party`), ref="Democrat"),
    motion_type    = relevel(factor(`Motion Type Decided`), ref="12(b)(6)"),
    post_postfiled = as.integer(post==1 & Filing_Subgroup=="Post — Post-Muldrow Filing")
  )

logit1 <- glm(harm_insuff ~ post + Circuit + adverse_action +
                employer_type + party + motion_type,
              data=reg_df, family=binomial)
logit2 <- glm(harm_insuff ~ post + post_postfiled + Circuit + adverse_action +
                employer_type + party + motion_type,
              data=reg_df, family=binomial)

format_logit <- function(model, spec) {
  tidy(model, exponentiate=TRUE, conf.int=TRUE) %>%
    mutate(
      stars = case_when(p.value<0.001~"***", p.value<0.01~"**",
                        p.value<0.05~"*", TRUE~""),
      OR        = sprintf("%.3f", estimate),
      CI_95     = sprintf("[%.3f, %.3f]", conf.low, conf.high),
      p_value   = sprintf("%.3f%s", p.value, stars),
      Spec      = spec
    ) %>%
    select(Variable=term, OR, CI_95, p_value, Spec)
}

table7 <- bind_rows(
  format_logit(logit1, sprintf("Spec 1 — Base (N=%d, R²=%s)",
    nrow(reg_df), sprintf("%.3f", 1 - logLik(logit1)/logLik(update(logit1,~1))))),
  format_logit(logit2, sprintf("Spec 2 — + Filing Subgroup (N=%d)",nrow(reg_df)))
)

# ── Step 8: Multinomial Logistic Regression ────────────────────
mn_df <- df %>%
  filter(!is.na(`Primary Basis for Dismissal`), !is.na(`Period (Pre/Post)`),
         !is.na(Circuit), !is.na(`Employer Type`),
         !is.na(`Appointing President Party`), !is.na(`Motion Type Decided`)) %>%
  mutate(
    outcome     = factor(Dismissal_Clean, levels=DISMISSAL_ORDER),
    Circuit     = relevel(factor(Circuit), ref="Eighth"),
    employer_type= relevel(factor(`Employer Type`), ref="Government - Federal"),
    party       = relevel(factor(`Appointing President Party`), ref="Democrat"),
    motion_type = relevel(factor(`Motion Type Decided`), ref="12(b)(6)")
  )

mn_model <- multinom(outcome ~ post + Circuit + employer_type + party + motion_type,
                     data=mn_df, trace=FALSE, maxit=500)

table8 <- tidy(mn_model, exponentiate=TRUE, conf.int=TRUE) %>%
  mutate(
    stars   = case_when(p.value<0.001~"***", p.value<0.01~"**",
                        p.value<0.05~"*", TRUE~""),
    RRR     = sprintf("%.3f", estimate),
    CI_95   = sprintf("[%.3f, %.3f]", conf.low, conf.high),
    p_value = sprintf("%.3f%s", p.value, stars)
  ) %>%
  select(Outcome=y.level, Variable=term, RRR, CI_95, p_value)

# ── Step 9: Robustness Checks ─────────────────────────────────
robustness_row <- function(label, d_pre, d_post) {
  ct <- table(
    c(d_pre$`Court Finding on Harm`, d_post$`Court Finding on Harm`),
    c(rep("Pre",nrow(d_pre)), rep("Post",nrow(d_post)))
  )
  tibble(
    Sample         = label,
    Pre_N          = nrow(d_pre),
    Pre_Insuff     = sprintf("%.1f%%",insuff_rate(d_pre)),
    Post_N         = nrow(d_post),
    Post_Insuff    = sprintf("%.1f%%",insuff_rate(d_post)),
    Pre_Survived   = sprintf("%.1f%%",100*mean(d_pre$Dismissal_Clean=="N/A — Plaintiff Survived",na.rm=T)),
    Post_Survived  = sprintf("%.1f%%",100*mean(d_post$Dismissal_Clean=="N/A — Plaintiff Survived",na.rm=T)),
    Chi2_p         = chi2_p(ct)
  )
}

table9 <- bind_rows(
  robustness_row("Full Sample (baseline)", pre, post),
  robustness_row("Excl. Uncertain confidence",
    filter(pre,  `Dismissal Basis Confidence`!="Uncertain"),
    filter(post, `Dismissal Basis Confidence`!="Uncertain")),
  robustness_row("Excl. Multiple Bases",
    filter(pre,  `Primary Basis for Dismissal`!="Multiple Bases"),
    filter(post, `Primary Basis for Dismissal`!="Multiple Bases")),
  robustness_row("Excl. Fourth Circuit",
    filter(pre,  Circuit!="Fourth"),
    filter(post, Circuit!="Fourth")),
  robustness_row("Post — post-Muldrow filing only", pre, post_postfiled)
)

# ── Step 10: Visualizations ───────────────────────────────────
pal2 <- c("Pre-Period"="#2E6DA4","Post-Period"="#E07B39")

# Fig 1: Harm Finding
fig1_data <- df %>%
  count(`Period (Pre/Post)`, `Court Finding on Harm`) %>%
  group_by(`Period (Pre/Post)`) %>%
  mutate(pct = 100*n/sum(n),
         Period = ifelse(`Period (Pre/Post)`=="Pre","Pre-Period","Post-Period"),
         Finding = factor(`Court Finding on Harm`, levels=HARM_ORDER))

p1 <- ggplot(fig1_data, aes(x=Finding, y=pct, fill=Period)) +
  geom_col(position="dodge", width=0.7, colour="white", linewidth=0.3) +
  geom_text(aes(label=sprintf("%.1f%%",pct)), position=position_dodge(0.7),
            vjust=-0.4, size=3, fontface="bold") +
  scale_fill_manual(values=pal2) +
  labs(title="Figure 1. Court Finding on Harm: Pre- vs. Post-Muldrow",
       x="Court Finding on Harm", y="Percentage of Cases (%)", fill=NULL) +
  theme_classic(base_size=11) +
  theme(legend.position="top", plot.title=element_text(face="bold"),
        panel.grid.major.y=element_line(linetype="dashed",colour="grey80"))

ggsave("fig1_harm_finding_pre_post.png", p1, width=8, height=5, dpi=300)

# Fig 2: Dismissal Basis
fig2_data <- df %>%
  count(`Period (Pre/Post)`, Dismissal_Clean) %>%
  group_by(`Period (Pre/Post)`) %>%
  mutate(pct = 100*n/sum(n),
         Period  = ifelse(`Period (Pre/Post)`=="Pre","Pre-Period","Post-Period"),
         Basis   = factor(Dismissal_Clean, levels=DISMISSAL_ORDER))

p2 <- ggplot(fig2_data, aes(x=Basis, y=pct, fill=Period)) +
  geom_col(position="dodge", width=0.7, colour="white") +
  geom_text(aes(label=sprintf("%.1f%%",pct)), position=position_dodge(0.7),
            vjust=-0.4, size=3, fontface="bold") +
  scale_fill_manual(values=pal2) +
  scale_x_discrete(labels=c("Harm\nInsuff.","Causation\nInsuff.",
                             "N/A —\nSurvived","Pleading\nDeficiency","Other")) +
  labs(title="Figure 2. Primary Basis for Dismissal: Pre- vs. Post-Muldrow",
       x="Primary Basis for Dismissal", y="Percentage of Cases (%)", fill=NULL) +
  theme_classic(base_size=11) +
  theme(legend.position="top", plot.title=element_text(face="bold"),
        panel.grid.major.y=element_line(linetype="dashed",colour="grey80"))

ggsave("fig2_dismissal_basis_pre_post.png", p2, width=9, height=5, dpi=300)

# Fig 3: Three-way comparison
pal3 <- c("Pre-Period"="#2E6DA4",
          "Post — Pre-Muldrow Filing"="#E07B39",
          "Post — Post-Muldrow Filing"="#3A8C5C")
fig3_data <- df %>%
  count(Filing_Subgroup, `Court Finding on Harm`) %>%
  group_by(Filing_Subgroup) %>%
  mutate(pct = 100*n/sum(n),
         Finding = factor(`Court Finding on Harm`, levels=HARM_ORDER),
         Group = factor(Filing_Subgroup,
           levels=c("Pre-Period","Post — Pre-Muldrow Filing","Post — Post-Muldrow Filing")))

p3 <- ggplot(fig3_data, aes(x=Group, y=pct, fill=Finding)) +
  geom_col(position="dodge", width=0.8, colour="white") +
  scale_fill_manual(values=c("#2E6DA4","#E07B39","#3A8C5C","#C0392B")) +
  scale_x_discrete(labels=c("Pre-Period",
                             "Post — Pre-Muldrow\nFiling",
                             "Post — Post-Muldrow\nFiling")) +
  labs(title="Figure 3. Court Finding on Harm by Filing Date Subgroup",
       x=NULL, y="Percentage of Cases (%)", fill="Finding") +
  theme_classic(base_size=11) +
  theme(legend.position="top", plot.title=element_text(face="bold"),
        panel.grid.major.y=element_line(linetype="dashed",colour="grey80"))

ggsave("fig3_three_way_filing.png", p3, width=9, height=5, dpi=300)

# Fig 4: Circuit harm insufficient rate
fig4_data <- df %>%
  group_by(Circuit, `Period (Pre/Post)`) %>%
  summarise(Insuff_Rate = 100*mean(`Court Finding on Harm`=="Insufficient",na.rm=T),
            N = n(), .groups="drop") %>%
  mutate(Period = ifelse(`Period (Pre/Post)`=="Pre","Pre-Period","Post-Period"),
         Circuit = factor(Circuit, levels=circuits))

p4 <- ggplot(fig4_data, aes(x=Circuit, y=Insuff_Rate, fill=Period)) +
  geom_col(position="dodge", width=0.7, colour="white") +
  geom_text(aes(label=sprintf("%.0f%%\n(N=%d)",Insuff_Rate,N)),
            position=position_dodge(0.7), vjust=-0.3, size=2.8) +
  scale_fill_manual(values=pal2) +
  labs(title="Figure 4. Harm Insufficient Rate by Circuit: Pre vs. Post Muldrow",
       x="Circuit", y="Harm Insufficient Rate (%)", fill=NULL) +
  coord_cartesian(ylim=c(0,110)) +
  theme_classic(base_size=11) +
  theme(legend.position="top", plot.title=element_text(face="bold"),
        panel.grid.major.y=element_line(linetype="dashed",colour="grey80"))

ggsave("fig4_circuit_harm_insufficient.png", p4, width=9, height=5, dpi=300)

# Fig 5: Adverse action harm insufficient rate
fig5_data <- df %>%
  group_by(`Primary Non-Economic Adverse Action`, `Period (Pre/Post)`) %>%
  summarise(Insuff_Rate = 100*mean(`Court Finding on Harm`=="Insufficient",na.rm=T),
            N = n(), .groups="drop") %>%
  filter(!is.na(`Primary Non-Economic Adverse Action`)) %>%
  mutate(Period = ifelse(`Period (Pre/Post)`=="Pre","Pre-Period","Post-Period"))

p5 <- ggplot(fig5_data, aes(x=`Primary Non-Economic Adverse Action`,
                             y=Insuff_Rate, fill=Period)) +
  geom_col(position="dodge", width=0.7, colour="white") +
  geom_text(aes(label=sprintf("N=%d",N)), position=position_dodge(0.7),
            vjust=-0.4, size=2.5) +
  scale_fill_manual(values=pal2) +
  labs(title="Figure 5. Harm Insufficient Rate by Adverse Action Type: Pre vs. Post Muldrow",
       x="Adverse Action Type", y="Harm Insufficient Rate (%)", fill=NULL) +
  coord_cartesian(ylim=c(0,115)) +
  theme_classic(base_size=11) +
  theme(legend.position="top", plot.title=element_text(face="bold"),
        axis.text.x=element_text(angle=30, hjust=1, size=8),
        panel.grid.major.y=element_line(linetype="dashed",colour="grey80"))

ggsave("fig5_adverse_action_harm_insufficient.png", p5, width=11, height=5, dpi=300)

# ── Save Tables to Excel ──────────────────────────────────────
write_xlsx(list(
  "Table 1 — Descriptive Stats"    = table1,
  "Table 2 — Pre Post Comparison"  = table2,
  "Table 3 — Filing Date Subgroup" = table3,
  "Table 4 — Circuit Breakdown"    = table4,
  "Table 5 — Adverse Action"       = table5,
  "Table 6 — Employer Type"        = table6,
  "Table 7 — Logistic Regression"  = table7,
  "Table 8 — Multinomial"          = table8,
  "Table 9 — Robustness Checks"    = table9
), XLOUT)

cat("\n═══ Analysis complete ═══\n")
cat(sprintf("Tables saved: %s\n", XLOUT))
cat("Figures saved: fig1–fig5.png\n")
