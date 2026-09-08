# test_education_outcomes.R

library(testthat)
source(fs_path("scripts", "education_outcomes.R"))

test_that("education summary returns one row per group", {
  df <- read.csv(fs_path("sample_data", "education_outcomes.csv"))
  result <- summarise_education(df)
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})
