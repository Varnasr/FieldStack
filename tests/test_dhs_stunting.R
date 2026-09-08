# test_dhs_stunting.R
#
# Covers survey_tools/dhs_stunting.R against a small synthetic extract shaped
# like the CSV InsightStack's DHS loader writes. No real DHS data is used or
# could be: the licence does not permit redistribution.

library(testthat)
source(fs_path("survey_tools", "dhs_stunting.R"))

write_extract <- function(n = 400, seed = 7) {
  set.seed(seed)
  psu <- rep(1:40, length.out = n)
  df <- data.frame(
    haz = rnorm(n, -1.4, 1.3),
    b5 = c(rep(1, n - 20), rep(0, 20)),      # 20 children who have died
    v190 = rep(1:5, length.out = n),
    weight = runif(n, 0.6, 1.6),
    psu = psu,
    strata = (psu %% 8) + 1
  )
  df$haz[1:15] <- NA                          # not measured, not "not stunted"
  path <- tempfile(fileext = ".csv")
  write.csv(df, path, row.names = FALSE)
  path
}

test_that("children who have died are excluded before anthropometry", {
  df <- read.csv(write_extract())
  prepared <- prepare_children(df)
  expect_true(all(prepared$b5 == 1))
  expect_equal(nrow(prepared), sum(df$b5 == 1))
})

test_that("an unmeasured child is missing, not counted as not stunted", {
  df <- read.csv(write_extract())
  prepared <- prepare_children(df)
  expect_equal(sum(is.na(prepared$stunted)), sum(is.na(prepared$haz)))
  expect_true(all(prepared$stunted[!is.na(prepared$stunted)] %in% c(0, 1)))
})

test_that("a missing haz column is refused rather than worked around", {
  df <- read.csv(write_extract())
  expect_error(prepare_children(df[, setdiff(names(df), "haz")]), "haz")
})

test_that("stunting_by returns every quintile plus a total, with real design effects", {
  skip_if_not_installed("survey")
  est <- stunting_by(dhs_design(prepare_children(read.csv(write_extract()))))

  expect_equal(nrow(est), 6)
  expect_true("Total" %in% est$level)
  expect_true(all(est$estimate >= 0 & est$estimate <= 100))
  expect_true(all(est$ci_low <= est$estimate & est$estimate <= est$ci_high))
  # deff = "replace" must be used: the default deff = TRUE returns nonsense on
  # DHS relative weights, which is how this file got 165 and 207 in testing.
  expect_true(all(is.finite(est$deff)))
  expect_true(all(est$deff > 0 & est$deff < 10))
})

test_that("degrees of freedom are clusters minus strata, not the row count", {
  skip_if_not_installed("survey")
  prepared <- prepare_children(read.csv(write_extract()))
  est <- stunting_by(dhs_design(prepared))
  expected <- length(unique(prepared$psu)) - length(unique(prepared$strata))
  expect_equal(unique(est$df), expected)
})

test_that("the comparison flags a row that misses the published figure", {
  est <- data.frame(level = c("Lowest", "Highest"), estimate = c(46.1, 30.0))
  cmp <- compare_to_published(est, tolerance = 0.5)
  expect_true(cmp$within_tolerance[cmp$level == "Lowest"])
  expect_false(cmp$within_tolerance[cmp$level == "Highest"])
})
