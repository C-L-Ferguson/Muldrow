library(tidyverse)
library(readr)

# Load coding sheet (CSV export from muldrow_coding_sheet_v2.xlsx)
# To regenerate: export Coding Sheet tab as data/coding_sheet.csv
dataset <- read_csv(
  here::here("data", "coding_sheet.csv"),
  skip = 1  # skip the section-header row; row 2 has column names
)

summary(dataset)
