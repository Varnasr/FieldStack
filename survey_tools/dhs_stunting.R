# DHS Stunting by Wealth Quintile
# Worked example: design-based estimates from a DHS children's recode, checked
# against the figures DHS published.
#
# This is the analysis half of a chain that starts in InsightStack's
# data_starters/dhs-south-asia/, which turns the raw recode into a clean CSV:
#
#   python load_dhs.py IAKR7EFL.DTA --vars v190 v025 hw70 b5 --anthro \
#       --out children.csv
#
# and continues here:
#
#   source("survey_tools/dhs_stunting.R")
#   res <- dhs_stunting_report("children.csv")
#
# The two repositories are coupled through a file rather than a dependency.
#
# Requires: survey, dplyr

suppressPackageStartupMessages({
  library(survey)
  library(dplyr)
})

# DHS Program API, indicator CN_NUTS_C_HA2 (children stunted, height-for-age
# below -2 SD of the WHO 2006 median), survey IA2020DHS, retrieved 2026-09-08.
PUBLISHED_NFHS5 <- data.frame(
  wealth_quintile = c("Lowest", "Second", "Middle", "Fourth", "Highest", "Total"),
  published = c(46.1, 39.7, 34.4, 28.1, 22.9, 35.5),
  stringsAsFactors = FALSE
)

QUINTILE_LABELS <- c("1" = "Lowest", "2" = "Second", "3" = "Middle",
                     "4" = "Fourth", "5" = "Highest")

#' Build the stunting indicator and wealth quintile labels
#'
#' Two filters matter and neither announces itself if you skip it. The children's
#' recode covers births in the last five years including children who have died,
#' so b5 == 1 is required before any anthropometry. And a child with no valid
#' height-for-age is not a child who is not stunted, so those stay NA rather than
#' becoming zeros.
#'
#' @param df Data frame from the InsightStack loader, carrying haz and weight
#' @return Data frame with stunted and wealth_quintile added
prepare_children <- function(df) {
  if (!"haz" %in% names(df)) {
    stop("No 'haz' column. Run the loader with --anthro so the flags at 9990 ",
         "and above are dropped before the values are divided by 100.",
         call. = FALSE)
  }
  if ("b5" %in% names(df)) {
    before <- nrow(df)
    df <- df[!is.na(df$b5) & df$b5 == 1, , drop = FALSE]
    message(sprintf("  living children: %s of %s",
                    format(nrow(df), big.mark = ","), format(before, big.mark = ",")))
  }
  df$stunted <- ifelse(is.na(df$haz), NA_real_, as.numeric(df$haz < -2))
  message(sprintf("  with a valid height-for-age: %s of %s",
                  format(sum(!is.na(df$stunted)), big.mark = ","),
                  format(nrow(df), big.mark = ",")))
  if ("v190" %in% names(df)) {
    df$wealth_quintile <- unname(QUINTILE_LABELS[as.character(df$v190)])
  }
  df
}

#' Silence one specific survey warning that is expected on DHS data
#'
#' The survey package warns "Sample size greater than population size: are
#' weights correctly scaled?" whenever the weights in a domain sum to less than
#' the number of rows in it. On DHS that is normal and not a fault: v005 is a
#' relative weight normalised so that it averages one across the sample, not an
#' expansion weight carrying population totals. Anyone who takes the warning at
#' face value and rescales the weights upward will make their estimates worse.
#'
#' Only this one message is muffled. Every other warning passes through.
quiet_relative_weight_warning <- function(expr) {
  withCallingHandlers(expr, warning = function(w) {
    if (grepl("Sample size greater than population size", conditionMessage(w),
              fixed = TRUE)) {
      invokeRestart("muffleWarning")
    }
  })
}

#' Survey design object for a prepared DHS extract
#'
#' nest = TRUE because DHS cluster numbers restart within strata, so cluster 3
#' in stratum 1 and cluster 3 in stratum 2 are different clusters.
dhs_design <- function(df) {
  has_strata <- "strata" %in% names(df) && any(!is.na(df$strata))
  svydesign(
    ids = ~psu,
    strata = if (has_strata) ~strata else NULL,
    weights = ~weight,
    data = df,
    nest = TRUE
  )
}

#' Stunting prevalence by a background characteristic
#'
#' Uses svyby on the full design rather than estimating each group from a
#' filtered data frame. This is the R version of a trap that catches people in
#' every language: subsetting the data before estimating a subgroup discards the
#' clusters that contain none of its members, and those clusters are part of the
#' design. In R the safe forms are svyby on the whole design, or subset() applied
#' to the design object, never a filter applied to the data before svydesign().
#'
#' Intervals here are linear, estimate plus or minus t times the standard error
#' on degf(des) degrees of freedom, which is what svyby gives. For a proportion
#' close to zero or one that can report a bound outside [0, 1]; use
#' svyciprop(~stunted, subset(des, ...), method = "logit") when it matters.
#'
#' @param des Survey design from dhs_design()
#' @param by Grouping column, default wealth_quintile
#' @return Data frame with estimate, se, ci bounds and design effect, in percent
stunting_by <- function(des, by = "wealth_quintile") {
  formula_by <- as.formula(paste0("~", by))
  # deff = "replace" rather than TRUE. See quiet_relative_weight_warning() below:
  # DHS weights are relative, so the default design effect divides by a
  # population size that is really the sample size, and returns nonsense.
  # On one 40-cluster extract that was 165, 207 and two NAs where the correct
  # values are 1.11, 0.83 and 1.49.
  grouped <- quiet_relative_weight_warning(
    svyby(~stunted, formula_by, des, svymean, na.rm = TRUE, deff = "replace"))
  total <- quiet_relative_weight_warning(
    svymean(~stunted, des, na.rm = TRUE, deff = "replace"))
  dof <- degf(des)
  tq <- qt(0.975, dof)

  deff_col <- grep("^DEff", names(grouped), value = TRUE)[1]
  out <- data.frame(
    level = as.character(grouped[[by]]),
    estimate = as.numeric(grouped$stunted) * 100,
    se = as.numeric(SE(grouped)) * 100,
    deff = if (is.na(deff_col)) NA_real_ else as.numeric(grouped[[deff_col]]),
    stringsAsFactors = FALSE
  )
  out <- rbind(out, data.frame(
    level = "Total",
    estimate = as.numeric(coef(total)[[1]]) * 100,
    se = as.numeric(SE(total)[[1]]) * 100,
    deff = as.numeric(attr(total, "deff")[[1]]),
    stringsAsFactors = FALSE
  ))
  out$ci_low <- out$estimate - tq * out$se
  out$ci_high <- out$estimate + tq * out$se
  out$df <- dof
  out
}

#' Line the estimates up against a published table
#'
#' Reproducing the published figures is the only cheap check that a survey
#' pipeline is right end to end. A weight left unscaled, a subgroup filtered too
#' early, an anthropometry flag kept as a measurement: each produces a number
#' that looks reasonable alone and visibly wrong beside the published report.
#'
#' @param est Output of stunting_by()
#' @param published Data frame with wealth_quintile and published columns
#' @param tolerance Allowed gap in percentage points
compare_to_published <- function(est, published = PUBLISHED_NFHS5, tolerance = 0.5) {
  merged <- merge(est, published, by.x = "level", by.y = "wealth_quintile", all = TRUE)
  merged$difference <- merged$estimate - merged$published
  merged$within_tolerance <- abs(merged$difference) <= tolerance
  merged[, c("level", "estimate", "published", "difference", "within_tolerance")]
}

#' Run the whole example and print both tables
#'
#' @param csv Cleaned children's recode written by InsightStack's load_dhs
#' @param benchmark Set FALSE for a survey other than India's NFHS-5
#' @return The estimates, invisibly
dhs_stunting_report <- function(csv, benchmark = TRUE, tolerance = 0.5) {
  df <- prepare_children(read.csv(csv))
  est <- stunting_by(dhs_design(df))

  order <- c("Lowest", "Second", "Middle", "Fourth", "Highest", "Total")
  est <- est[order(match(est$level, order)), ]

  cat("\nStunting by wealth quintile, percent\n")
  print(format(est, digits = 3), row.names = FALSE)

  if (isTRUE(benchmark)) {
    cmp <- compare_to_published(est, tolerance = tolerance)
    cmp <- cmp[order(match(cmp$level, order)), ]
    cat(sprintf("\nAgainst the published NFHS-5 table (tolerance %.1f points)\n",
                tolerance))
    print(format(cmp, digits = 3), row.names = FALSE)
    off <- sum(!cmp$within_tolerance, na.rm = TRUE)
    if (off > 0) {
      message(sprintf("\n%d row(s) outside tolerance. Check the weight scaling, ", off),
              "whether the subgroup was filtered before estimation, and whether ",
              "the anthropometry flags were dropped before dividing by 100.")
    } else {
      cat("\nEvery row reproduces the published figure. The pipeline is sound.\n")
    }
  }
  invisible(est)
}
