
# test_education_outcomes.R

library(testthat)
source("scripts/education_outcomes.R")

test_that("pass rate is computed and between 0 and 1", {
  df <- read.csv("sample_data/education_outcomes.csv")
  result <- summarise_education(df)
  expect_s3_class(result, "data.frame")
  expect_true(all(result$pass_rate >= 0 & result$pass_rate <= 1))
})
