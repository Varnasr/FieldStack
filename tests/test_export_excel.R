
    library(testthat)
    source("scripts/export_summary_to_excel.R")

    test_that("Excel export runs without error", {
      temp_file <- tempfile(fileext = ".xlsx")
      df <- data.frame(a = 1:5, b = 6:10)
      expect_error(export_summary_to_excel(df, temp_file), NA)
    })
    