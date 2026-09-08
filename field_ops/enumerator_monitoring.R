# Enumerator monitoring: productivity, and outliers that are worth a conversation
#
# The one thing to hold on to before using any of this:
#
#   ENUMERATORS ARE ALMOST NEVER RANDOMLY ASSIGNED TO AREAS.
#
# So an enumerator whose households report much lower consumption may be
# fabricating, or may have been sent to the poorest block in the district. The
# difference between those two conclusions is somebody's job. Nothing in this
# file can tell them apart, and a flag here is a reason to look, listen to the
# enumerator's explanation, and check the back-check data. It is not evidence.
#
# The `within` argument exists for exactly this. Comparing an enumerator against
# the others who worked the same village, block or stratum removes most of the
# confounding, and where assignment really was randomised within a cluster it
# removes all of it. Use it whenever the design allows.
#
# Two smaller decisions, both of which change the answer:
#
# Comparisons are leave-one-out. Measuring an enumerator against an average that
# includes their own interviews pulls the benchmark toward them, and the more
# work they have done the less likely they are to be flagged, which is backwards.
#
# The standardised difference uses the enumerator's own interview count. An
# enumerator with 12 interviews and one with 300 do not deserve the same
# threshold: the first will drift from the mean by chance alone.

.em_require_cols <- function(df, cols, fn) {
  missing <- setdiff(cols, names(df))
  if (length(missing)) {
    stop(fn, ": no column(s) ", paste(missing, collapse = ", "), " in the data",
         call. = FALSE)
  }
  invisible(TRUE)
}

#' Per-enumerator workload and data-quality summary
#'
#' The table a field manager reads each morning: how much each person did, how
#' fast, and how much of it is blank or "don't know".
#'
#' @param df Data frame of submissions.
#' @param enumerator Name of the enumerator column.
#' @param date Optional date column, for interviews per working day. Counted
#'   over days the enumerator actually worked, not calendar days since the
#'   survey started, so a week of leave does not read as low productivity.
#' @param duration_minutes Optional numeric column of interview length.
#' @param vars Optional variables to compute a missingness rate over.
#' @param dk_codes Values that count as "don't know" or refusal. The defaults
#'   cover the usual ODK and Stata conventions; extend for your own instrument.
#' @return One row per enumerator.
enumerator_summary <- function(df, enumerator, date = NULL,
                               duration_minutes = NULL, vars = character(),
                               dk_codes = c(-999, -998, -99, -88, 98, 99,
                                            "don't know", "dont know", "dk", "refused")) {
  .em_require_cols(df, c(enumerator, date, duration_minutes, vars),
                   "enumerator_summary")
  keys <- as.character(df[[enumerator]])
  levels_ <- sort(unique(keys[!is.na(keys)]))

  rows <- lapply(levels_, function(e) {
    part <- df[!is.na(keys) & keys == e, , drop = FALSE]
    n <- nrow(part)
    out <- list(enumerator = e, n_interviews = n)

    if (!is.null(date)) {
      days <- unique(as.Date(part[[date]]))
      days <- days[!is.na(days)]
      out$days_worked <- length(days)
      out$per_day <- if (length(days)) round(n / length(days), 2) else NA_real_
    }
    if (!is.null(duration_minutes)) {
      d <- suppressWarnings(as.numeric(part[[duration_minutes]]))
      out$median_minutes <- if (any(!is.na(d))) round(stats::median(d, na.rm = TRUE), 1) else NA_real_
      out$min_minutes <- if (any(!is.na(d))) round(min(d, na.rm = TRUE), 1) else NA_real_
    }
    if (length(vars)) {
      block <- part[, vars, drop = FALSE]
      out$missing_rate <- round(mean(is.na(as.matrix(block))), 4)
      flat <- unlist(lapply(block, function(col) as.character(col)))
      is_dk <- !is.na(flat) & tolower(trimws(flat)) %in% tolower(as.character(dk_codes))
      out$dk_rate <- round(mean(is_dk), 4)
    }
    as.data.frame(out, stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  out[order(-out$n_interviews), , drop = FALSE]
}

#' Enumerators whose mean on a variable differs from everyone else's
#'
#' For each enumerator and each variable, compares that enumerator's mean
#' against the mean of every *other* enumerator, standardised by the standard
#' error of the difference. Reported as a z-like statistic, not a p-value: with
#' one test per enumerator per variable there are dozens of comparisons and an
#' unadjusted p-value would be read as far more decisive than it is.
#'
#' @param df Data frame of submissions.
#' @param enumerator Name of the enumerator column.
#' @param vars Numeric variables to compare. Binary 0/1 is fine.
#' @param within Optional column (village, block, stratum). When supplied, each
#'   enumerator is compared only against others working the same units, which is
#'   the comparison that is actually interpretable. Strongly recommended.
#' @param threshold Absolute z above which a row is flagged. 2 flags a lot; the
#'   default 2.5 is a compromise between missing fabrication and burying the
#'   field manager in false positives.
#' @param min_n Skip an enumerator-variable pair with fewer than this many
#'   observations. Small cells produce large z values from nothing.
#' @return One row per enumerator-variable pair, flagged rows first.
enumerator_outliers <- function(df, enumerator, vars, within = NULL,
                                threshold = 2.5, min_n = 10) {
  .em_require_cols(df, c(enumerator, vars, within), "enumerator_outliers")
  keys <- as.character(df[[enumerator]])

  compare <- function(sub, label) {
    ks <- as.character(sub[[enumerator]])
    res <- list()
    for (v in vars) {
      x <- suppressWarnings(as.numeric(sub[[v]]))
      for (e in unique(ks[!is.na(ks)])) {
        mine <- x[ks == e & !is.na(x)]
        others <- x[ks != e & !is.na(x)]
        if (length(mine) < min_n || length(others) < min_n) next
        m1 <- mean(mine); m0 <- mean(others)
        s1 <- stats::var(mine); s0 <- stats::var(others)
        se <- sqrt(s1 / length(mine) + s0 / length(others))
        z <- if (is.finite(se) && se > 0) (m1 - m0) / se else NA_real_
        res[[length(res) + 1]] <- data.frame(
          enumerator = e, variable = v, group = label,
          n = length(mine), mean = round(m1, 4),
          others_mean = round(m0, 4), difference = round(m1 - m0, 4),
          z = round(z, 2),
          flagged = !is.na(z) && abs(z) > threshold,
          stringsAsFactors = FALSE)
      }
    }
    if (!length(res)) return(NULL)
    do.call(rbind, res)
  }

  if (is.null(within)) {
    out <- compare(df, "all")
  } else {
    groups <- as.character(df[[within]])
    pieces <- lapply(unique(groups[!is.na(groups)]), function(g) {
      compare(df[!is.na(groups) & groups == g, , drop = FALSE], g)
    })
    pieces <- Filter(Negate(is.null), pieces)
    out <- if (length(pieces)) do.call(rbind, pieces) else NULL
  }

  if (is.null(out) || !nrow(out)) {
    return(data.frame(enumerator = character(), variable = character(),
                      group = character(), n = integer(), mean = numeric(),
                      others_mean = numeric(), difference = numeric(),
                      z = numeric(), flagged = logical(),
                      stringsAsFactors = FALSE))
  }
  attr(out, "caveat") <- paste(
    "Enumerators are rarely randomly assigned. A flag here is a reason to look,",
    "not a finding. Where the design allows, pass `within` so each enumerator is",
    "compared only against others who worked the same units.")
  out[order(-abs(replace(out$z, is.na(out$z), 0))), , drop = FALSE]
}

#' Days on which an enumerator submitted implausibly many interviews
#'
#' Twelve 50-minute interviews in a day is fifteen hours of work including
#' travel. This finds the days worth asking about, per enumerator per day,
#' rather than averaging the pace away over a fortnight.
#'
#' @param df Data frame of submissions.
#' @param enumerator,date Column names.
#' @param max_per_day Threshold. Set it from the instrument's timed length and
#'   the travel between households, not from a round number.
enumerator_daily_load <- function(df, enumerator, date, max_per_day = 10) {
  .em_require_cols(df, c(enumerator, date), "enumerator_daily_load")
  d <- as.Date(df[[date]])
  tab <- as.data.frame(table(enumerator = as.character(df[[enumerator]]),
                             date = as.character(d)),
                       stringsAsFactors = FALSE)
  names(tab)[3] <- "n_interviews"
  tab <- tab[tab$n_interviews > 0, , drop = FALSE]
  tab$flagged <- tab$n_interviews > max_per_day
  tab[order(-tab$n_interviews), , drop = FALSE]
}
