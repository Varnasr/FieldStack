
# test_mel_reshape.R

library(testthat)
source("scripts/mel_reshape.R")

test_that("reshape output has expected structure", {
  df <- read.csv("sample_data/mel_indicators_wide.csv")
  result <- reshape_indicators(df)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("indicator", "quarter", "value") %in% names(result)))
})
