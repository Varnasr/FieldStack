
# test_health_access_index.R

library(testthat)
source("scripts/health_access_index.R")

test_that("access index is computed and non-negative", {
  df <- read.csv("sample_data/health_services.csv")
  result <- compute_access_index(df)
  expect_s3_class(result, "data.frame")
  expect_true("access_index" %in% names(result))
  expect_true(all(result$access_index >= 0))
})
