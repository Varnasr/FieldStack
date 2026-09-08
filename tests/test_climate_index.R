# test_climate_index.R

library(testthat)
source(fs_path("scripts", "climate_vulnerability_index.R"))

test_that("climate index is positive and numeric", {
  df <- read.csv(fs_path("sample_data", "climate_exposure.csv"))
  result <- compute_climate_index(df)
  expect_s3_class(result, "data.frame")
  expect_true("climate_index" %in% names(result))
  expect_true(all(result$climate_index > 0))
})
