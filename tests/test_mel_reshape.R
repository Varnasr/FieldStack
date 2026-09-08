# test_mel_reshape.R

library(testthat)
source(fs_path("scripts", "mel_reshape.R"))

test_that("wide indicators reshape to long without losing rows", {
  df <- read.csv(fs_path("sample_data", "mel_indicators_wide.csv"))
  result <- reshape_indicators(df)
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), nrow(df))
})
