# Survey Sampling Weights
# Compute and apply weights for complex survey designs

library(tidyverse)

#' Calculate base sampling weights (inverse probability of selection)
#' @param df Data frame with survey data
#' @param strata_col Column identifying strata
#' @param strata_pop Named vector of stratum population sizes
#' @return Data frame with base_weight column added
calculate_base_weights <- function(df, strata_col = "stratum", strata_pop) {
  df %>%
    group_by(.data[[strata_col]]) %>%
    mutate(
      n_sampled = n(),
      N_stratum = strata_pop[as.character(.data[[strata_col]])],
      base_weight = N_stratum / n_sampled
    ) %>%
    ungroup()
}

#' Trim extreme weights to reduce variance
#' @param weights Vector of survey weights
#' @param lower Lower percentile for trimming (default 0.01)
#' @param upper Upper percentile for trimming (default 0.99)
#' @return Trimmed weight vector
trim_weights <- function(weights, lower = 0.01, upper = 0.99) {
  bounds <- quantile(weights, probs = c(lower, upper), na.rm = TRUE)
  pmin(pmax(weights, bounds[1]), bounds[2])
}

#' Compute weighted summary statistics
#' @param df Data frame with weights
#' @param var Variable to summarise
#' @param weight_col Weight column name
#' @param group_col Optional grouping column
#' @return Data frame with weighted mean, SE, and CI
weighted_summary <- function(df, var, weight_col = "base_weight", group_col = NULL) {
  if (!is.null(group_col)) {
    df <- df %>% group_by(.data[[group_col]])
  }

  df %>%
    summarise(
      n = n(),
      weighted_mean = weighted.mean(.data[[var]], .data[[weight_col]], na.rm = TRUE),
      weighted_sd = sqrt(
        sum(.data[[weight_col]] * (.data[[var]] - weighted.mean(.data[[var]], .data[[weight_col]], na.rm = TRUE))^2, na.rm = TRUE) /
        sum(.data[[weight_col]], na.rm = TRUE)
      ),
      .groups = "drop"
    ) %>%
    mutate(
      se = weighted_sd / sqrt(n),
      ci_lower = weighted_mean - 1.96 * se,
      ci_upper = weighted_mean + 1.96 * se
    )
}

# Example usage
if (sys.nframe() == 0) {
  # Create sample data
  set.seed(42)
  survey_data <- tibble(
    id = 1:200,
    stratum = rep(c("urban", "rural", "tribal"), times = c(80, 80, 40)),
    outcome = c(rnorm(80, 65, 10), rnorm(80, 45, 12), rnorm(40, 35, 8)),
    district = sample(c("A", "B", "C"), 200, replace = TRUE)
  )

  strata_populations <- c(urban = 50000, rural = 120000, tribal = 30000)

  cat("=== Base Weights ===\n")
  weighted_data <- calculate_base_weights(survey_data, "stratum", strata_populations)
  weighted_data %>%
    distinct(stratum, n_sampled, N_stratum, base_weight) %>%
    print()

  cat("\n=== Weighted Summary (by stratum) ===\n")
  weighted_summary(weighted_data, "outcome", group_col = "stratum") %>%
    print()

  cat("\n=== Overall Weighted Mean ===\n")
  weighted_summary(weighted_data, "outcome") %>%
    print()
}
