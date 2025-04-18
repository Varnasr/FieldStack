
    library(testthat)
    source("scripts/sroi_calculator.R")

    test_that("SROI is numeric and positive", {
      result <- calculate_sroi(300000, 100000)
      expect_type(result, "double")
      expect_gt(result, 1)
    })
    