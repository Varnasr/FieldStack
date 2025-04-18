
    library(testthat)
    source("scripts/care_time_summary.R")

    test_that("Care time summary returns expected columns", {
      data <- data.frame(activity = c("childcare", "eldercare"), hours = c(4, 3))
      result <- care_time_summary(data)
      expect_true("activity" %in% names(result))
    })
    