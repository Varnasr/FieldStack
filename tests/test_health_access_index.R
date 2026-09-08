# test_health_access_index.R

library(testthat)
source(fs_path("scripts", "health_access_index.R"))

test_that("health access index is bounded and numeric", {
  df <- read.csv(fs_path("sample_data", "health_services.csv"))
  result <- compute_access_index(df)
  expect_s3_class(result, "data.frame")
  expect_true("access_index" %in% names(result))
  expect_true(all(is.finite(result$access_index)))
})
