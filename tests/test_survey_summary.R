# test_survey_summary.R
#
# The previous version called survey_summary(data, "group", "value"). No such
# function exists in this repository, and none ever did: survey_tools/survey_summary.R
# defines create_survey_design(), survey_descriptives() and survey_proportions().
# The test was written against an imagined API and errored on its source() line,
# so nobody found out.

library(testthat)
source(fs_path("survey_tools", "survey_summary.R"))

make_survey_data <- function() {
  set.seed(42)
  data.frame(
    id = 1:300,
    psu = rep(1:30, each = 10),
    stratum = rep(c("urban", "rural"), each = 150),
    weight = c(rep(50, 150), rep(120, 150)),
    health_score = c(rnorm(150, 70, 12), rnorm(150, 55, 15)),
    # Drawn at random rather than alternating. Alternating gives every cluster
    # exactly five of each, so the between-cluster variance is zero and the
    # standard error is correctly zero, which is not what this test is checking.
    female = sample(0:1, 300, replace = TRUE)
  )
}

test_that("a design object is built with strata and clusters", {
  skip_if_not_installed("survey")
  design <- create_survey_design(make_survey_data(), "weight", "stratum", "psu")
  expect_s3_class(design, "survey.design")
})

test_that("weighted descriptives return one row per variable with finite bounds", {
  skip_if_not_installed("survey")
  design <- create_survey_design(make_survey_data(), "weight", "stratum", "psu")
  result <- survey_descriptives(design, c("health_score", "female"))

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_named(result, c("variable", "mean", "se", "ci_lower", "ci_upper"))
  expect_true(all(is.finite(result$mean)))
  expect_true(all(result$se > 0))
  expect_true(all(result$ci_lower < result$mean))
  expect_true(all(result$mean < result$ci_upper))
})

test_that("the weighted mean differs from the unweighted one", {
  # The rural half carries more than twice the urban weight and a lower mean, so
  # a weighting bug that silently drops the weights would show up here.
  skip_if_not_installed("survey")
  df <- make_survey_data()
  design <- create_survey_design(df, "weight", "stratum", "psu")
  weighted <- survey_descriptives(design, "health_score")$mean
  expect_false(isTRUE(all.equal(weighted, mean(df$health_score))))
  expect_lt(weighted, mean(df$health_score))
})

test_that("weighted proportions sum to one across categories", {
  skip_if_not_installed("survey")
  design <- create_survey_design(make_survey_data(), "weight", "stratum", "psu")
  result <- survey_proportions(design, "female")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_equal(sum(result$proportion), 1, tolerance = 1e-8)
})
