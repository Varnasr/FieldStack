# The evening run: one script a field supervisor executes against the day's export
#
# Everything else in field_ops/ is a function. This is the thing that gets run,
# because a check nobody runs is not a check. It takes an export, applies the
# whole battery, and writes two files: a per-case list to act on tomorrow, and a
# per-enumerator summary to raise in the morning meeting.
#
# Kept deliberately blunt. It runs on base R, writes CSV, and prints a summary
# to the console, because it has to work on whatever laptop is in the district
# office on a connection that will not install packages.

.fr_source_siblings <- function() {
  here <- tryCatch(dirname(normalizePath(sys.frame(1)$ofile)), error = function(e) NULL)
  if (is.null(here) || !nzchar(here)) here <- "field_ops"
  for (f in c("high_frequency_checks.R", "enumerator_monitoring.R",
              "gps_checks.R", "read_odk.R")) {
    path <- file.path(here, f)
    if (file.exists(path)) source(path)
  }
}

#' Run the daily field-monitoring battery and write the two reports
#'
#' @param data Either a path to an ODK/KoBo CSV export, or a data frame already
#'   read. A path is read through read_odk(), which strips group prefixes,
#'   parses the timestamps and converts sentinel codes.
#' @param id,enumerator Column names.
#' @param required Variables that must always be answered.
#' @param ranges Named list of c(min, max) plausible bounds.
#' @param start,end Timestamp columns, for duration and working-hours checks.
#' @param battery Items forming a scale, for the straightlining check.
#' @param gps Optional list with lat, lon, cluster and optionally radius_m and
#'   a reference frame.
#' @param outcome_vars Numeric variables to compare across enumerators.
#' @param within Optional column holding the enumerator against others working
#'   the same area. Pass it whenever the design allows: without it every
#'   difference confounds the enumerator with where they were sent.
#' @param outdir Where the two CSVs go. NULL writes nothing and only returns.
#' @param tz Local timezone for the working-hours check.
#' @return Invisibly, a list with `issues`, `enumerators` and `outliers`.
field_daily_report <- function(data, id, enumerator = NULL,
                               required = character(), ranges = list(),
                               start = NULL, end = NULL, battery = character(),
                               gps = NULL, outcome_vars = character(),
                               within = NULL, outdir = NULL,
                               tz = "Asia/Kolkata") {
  .fr_source_siblings()

  df <- if (is.character(data) && length(data) == 1) read_odk(data) else as.data.frame(data)
  if (!nrow(df)) stop("field_daily_report: the export has no rows", call. = FALSE)

  duration_arg <- if (!is.null(start) && !is.null(end)) list(start = start, end = end) else NULL
  hours_arg <- if (!is.null(start)) list(timestamp = start, tz = tz) else NULL

  issues <- run_hfc(df, id, required = required, ranges = ranges,
                    duration = duration_arg, hours = hours_arg,
                    battery = battery, enumerator = enumerator)

  if (!is.null(gps)) {
    args <- utils::modifyList(list(df = df), gps)
    located <- do.call(gps_distance_from_cluster, args)
    far <- located$far_from_cluster
    if (any(far)) {
      gps_issues <- data.frame(
        check = "far_from_cluster", severity = "warning",
        id = as.character(df[[id]][far]), variable = gps$cluster,
        value = as.character(located$distance_m[far]),
        message = sprintf("%.0f m from the assigned cluster centre",
                          located$distance_m[far]),
        stringsAsFactors = FALSE)
      if (!is.null(enumerator)) gps_issues$enumerator <- as.character(df[[enumerator]][far])
      issues <- rbind(issues, gps_issues)
    }
  }

  enumerators <- outliers <- NULL
  if (!is.null(enumerator)) {
    enumerators <- enumerator_summary(
      df, enumerator,
      date = if (!is.null(start)) start else NULL,
      duration_minutes = if ("duration_minutes" %in% names(df)) "duration_minutes" else NULL,
      vars = c(required, names(ranges)))
    if (length(outcome_vars)) {
      outliers <- enumerator_outliers(df, enumerator, vars = outcome_vars,
                                      within = within)
    }
  }

  cat("Field report:", nrow(df), "submissions,", nrow(issues), "issues\n")
  if (nrow(issues)) {
    counts <- table(issues$check, issues$severity)
    print(counts)
  } else {
    cat("Every check passed.\n")
  }
  if (!is.null(outliers) && nrow(outliers)) {
    flagged <- outliers[outliers$flagged, , drop = FALSE]
    if (nrow(flagged)) {
      cat("\nEnumerators differing from their peers (look, do not conclude):\n")
      print(flagged[, c("enumerator", "variable", "group", "n", "mean",
                        "others_mean", "z")], row.names = FALSE)
      cat("\n", attr(outliers, "caveat"), "\n", sep = "")
    }
  }

  if (!is.null(outdir)) {
    dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
    stamp <- format(Sys.Date(), "%Y%m%d")
    utils::write.csv(issues, file.path(outdir, paste0("issues_", stamp, ".csv")),
                     row.names = FALSE)
    if (!is.null(enumerators)) {
      utils::write.csv(enumerators,
                       file.path(outdir, paste0("enumerators_", stamp, ".csv")),
                       row.names = FALSE)
    }
    cat("\nWritten to", normalizePath(outdir), "\n")
  }

  invisible(list(issues = issues, enumerators = enumerators, outliers = outliers))
}
