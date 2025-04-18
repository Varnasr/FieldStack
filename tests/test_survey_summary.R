
    library(testthat)
    source("scripts/survey_summary.R")

    test_that("Survey summary returns a data frame", {
      data <- data.frame(group = rep(c("A", "B"), each=10), value = rnorm(20))
      result <- survey_summary(data, "group", "value")
      expect_s3_class(result, "data.frame")
    })
    