
# test_climate_index.R

library(testthat)
source("scripts/climate_vulnerability_index.R")

test_that("climate index is positive and numeric", {
  df <- read.csv("sample_data/climate_exposure.csv")
  result <- compute_climate_index(df)
  expect_s3_class(result, "data.frame")
  expect_true("climate_index" %in% names(result))
  expect_true(all(result$climate_index > 0))
})
