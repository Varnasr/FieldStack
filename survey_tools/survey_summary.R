# Survey Summary Statistics
# Weighted descriptive statistics using the survey package

#' Create a survey design object from data
#' @param df Data frame with survey data
#' @param weight_col Weight column name
#' @param strata_col Strata column (optional)
#' @param cluster_col Cluster/PSU column (optional)
#' @return Survey design object
create_survey_design <- function(df, weight_col = "weight",
                                   strata_col = NULL, cluster_col = NULL) {
  if (!requireNamespace("survey", quietly = TRUE)) {
    stop("Install the survey package: install.packages('survey')")
  }

  formula_parts <- list()
  if (!is.null(cluster_col)) {
    formula_parts$ids <- as.formula(paste0("~", cluster_col))
  } else {
    formula_parts$ids <- ~1
  }
  if (!is.null(strata_col)) {
    formula_parts$strata <- as.formula(paste0("~", strata_col))
  }

  survey::svydesign(
    ids = formula_parts$ids,
    strata = formula_parts$strata,
    weights = as.formula(paste0("~", weight_col)),
    data = df
  )
}

#' Compute weighted descriptive statistics for numeric variables
#' @param design Survey design object
#' @param vars Character vector of variable names
#' @return Data frame with weighted means, SEs, and CIs
survey_descriptives <- function(design, vars) {
  results <- lapply(vars, function(v) {
    mean_est <- survey::svymean(as.formula(paste0("~", v)), design, na.rm = TRUE)
    ci <- confint(mean_est)
    data.frame(
      variable = v,
      mean = as.numeric(mean_est),
      se = as.numeric(survey::SE(mean_est)),
      ci_lower = ci[1],
      ci_upper = ci[2]
    )
  })
  do.call(rbind, results)
}

#' Compute weighted proportions for categorical variables
#' @param design Survey design object
#' @param var Categorical variable name
#' @return Data frame with proportions and CIs
survey_proportions <- function(design, var) {
  prop_est <- survey::svymean(as.formula(paste0("~factor(", var, ")")), design, na.rm = TRUE)
  ci <- confint(prop_est)
  data.frame(
    category = names(coef(prop_est)),
    proportion = as.numeric(coef(prop_est)),
    se = as.numeric(survey::SE(prop_est)),
    ci_lower = ci[, 1],
    ci_upper = ci[, 2]
  )
}

# Example usage
if (sys.nframe() == 0) {
  if (!requireNamespace("survey", quietly = TRUE)) {
    cat("Install survey package: install.packages('survey')\n")
  } else {
    library(survey)
    set.seed(42)

    # Simulated survey data with weights
    df <- data.frame(
      id = 1:300,
      psu = rep(1:30, each = 10),
      stratum = rep(c("urban", "rural"), each = 150),
      weight = c(rep(50, 150), rep(120, 150)),
      health_score = c(rnorm(150, 70, 12), rnorm(150, 55, 15)),
      education_years = c(rpois(150, 10), rpois(150, 6)),
      female = sample(0:1, 300, replace = TRUE)
    )

    design <- create_survey_design(df, "weight", "stratum", "psu")

    cat("=== Weighted Descriptive Statistics ===\n")
    print(survey_descriptives(design, c("health_score", "education_years")))

    cat("\n=== Weighted Proportions (Gender) ===\n")
    print(survey_proportions(design, "female"))
  }
}
