install.packages("tidyverse")
install.packages("readxl")

library(readxl)
dataset <- read_excel("C:/Users/carolineferguson/Box/Bigelow/Job Talk paper/Muldrow/muldrow_coding_sheet_v2.xlsx")

summary(dataset)
data_set <- dataset
dim(data_set)
