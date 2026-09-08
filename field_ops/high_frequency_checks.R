# High-frequency checks: catching bad data while the team is still in the field
#
# The whole value of an HFC is timing. A duplicated household ID found on day
# three is a phone call; the same duplicate found at analysis is a hole in the
# sample that cannot be filled, because the team has left the district and the
# respondent cannot be re-identified. Everything here is therefore built to run
# every evening against the day's partial export, not once at the end.
#
# Two design decisions follow from that.
#
# The output is a list of cases, not a summary. A field manager cannot act on
# "4.2 percent missingness"; they can act on "these eleven interviews, by these
# two enumerators, are missing the consent question". Every check returns rows
# with an id, a variable, a value and a message, and run_hfc() stacks them into
# one table you can sort by enumerator and hand over.
#
# Nothing here deletes or corrects anything. An HFC that silently fixes data is
# worse than no HFC: the correction is invisible at analysis and the enumerator
# never learns. Flag, report, and let a human decide.
#
# The checks implemented are the standard set used by IPA and J-PAL field teams
# (see IPA's "Best Practices for Data and Code Management", 2020, section 4).

.hfc_issue <- function(check, severity, id, variable, value, message) {
  data.frame(
    check = check, severity = severity, id = as.character(id),
    variable = as.character(variable), value = as.character(value),
    message = message, stringsAsFactors = FALSE
  )
}

.hfc_empty <- function() {
  data.frame(check = character(), severity = character(), id = character(),
             variable = character(), value = character(), message = character(),
             stringsAsFactors = FALSE)
}

.hfc_require_cols <- function(df, cols, fn) {
  missing <- setdiff(cols, names(df))
  if (length(missing)) {
    stop(fn, ": no column(s) ", paste(missing, collapse = ", "), " in the data",
         call. = FALSE)
  }
  invisible(TRUE)
}

#' Duplicate identifiers
#'
#' The first check to run and the one that most often fires. A duplicate is
#' either the same interview submitted twice (harmless, drop one) or two
#' different households given the same ID (serious, and unrecoverable once the
#' team has moved on). This cannot tell the two apart, so it reports every
#' member of every duplicated group and leaves the judgement to a person.
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @return Issue rows, one per duplicated submission.
hfc_duplicates <- function(df, id) {
  .hfc_require_cols(df, id, "hfc_duplicates")
  key <- as.character(df[[id]])
  dup_values <- unique(key[duplicated(key)])
  if (!length(dup_values)) return(.hfc_empty())

  out <- lapply(dup_values, function(v) {
    n <- sum(key == v, na.rm = TRUE)
    .hfc_issue("duplicate_id", "error", v, id, v,
               sprintf("%d submissions share this id", n))
  })
  do.call(rbind, out)
}

#' Missing values in variables that should always be answered
#'
#' Pass only the variables that are unconditionally required. A question behind
#' a skip pattern is legitimately blank for most respondents, and listing it
#' here produces hundreds of false flags that train the field team to ignore the
#' report, which is the failure mode that matters.
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param vars Character vector of always-required variables.
#' @param blank_strings Values to treat as missing alongside NA. Defaults to the
#'   empty string and a lone full stop, both of which arrive routinely from ODK
#'   and from Stata exports and neither of which is NA.
hfc_missing <- function(df, id, vars, blank_strings = c("", ".", "NA", "n/a")) {
  .hfc_require_cols(df, c(id, vars), "hfc_missing")
  out <- list()
  for (v in vars) {
    col <- df[[v]]
    blank <- is.na(col)
    if (is.character(col) || is.factor(col)) {
      blank <- blank | trimws(as.character(col)) %in% blank_strings
    }
    if (any(blank)) {
      out[[v]] <- .hfc_issue("missing_required", "error", df[[id]][blank], v,
                             NA_character_, sprintf("%s is required but blank", v))
    }
  }
  if (!length(out)) return(.hfc_empty())
  do.call(rbind, out)
}

#' Values outside a declared plausible range
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param spec Named list of c(min, max) per variable, e.g.
#'   \code{list(age = c(0, 110), hh_size = c(1, 30))}. Use \code{NA} for an open
#'   end: \code{c(0, NA)} means non-negative with no upper bound.
#'
#' Ranges are a judgement about the population, not about the instrument. A
#' household size of 30 is implausible in most of India and ordinary in a joint
#' household in parts of Bihar, so set these per survey and expect to widen them
#' once the field team pushes back with a real case.
hfc_range <- function(df, id, spec) {
  if (!is.list(spec) || is.null(names(spec)) || any(names(spec) == "")) {
    stop("hfc_range: spec must be a named list of c(min, max)", call. = FALSE)
  }
  .hfc_require_cols(df, c(id, names(spec)), "hfc_range")
  out <- list()
  for (v in names(spec)) {
    bounds <- spec[[v]]
    if (length(bounds) != 2) {
      stop("hfc_range: ", v, " needs exactly c(min, max)", call. = FALSE)
    }
    x <- suppressWarnings(as.numeric(df[[v]]))
    lo <- if (is.na(bounds[1])) -Inf else bounds[1]
    hi <- if (is.na(bounds[2])) Inf else bounds[2]
    bad <- !is.na(x) & (x < lo | x > hi)
    if (any(bad)) {
      out[[v]] <- .hfc_issue("out_of_range", "warning", df[[id]][bad], v, x[bad],
                             sprintf("%s outside [%s, %s]", v,
                                     format(lo), format(hi)))
    }
  }
  if (!length(out)) return(.hfc_empty())
  do.call(rbind, out)
}

#' Interview duration outliers
#'
#' A questionnaire that normally takes 45 minutes and was completed in 11 was
#' not administered as written. This is the single most useful fabrication
#' check there is, and it costs nothing because ODK and SurveyCTO record the
#' timestamps anyway.
#'
#' Long interviews are flagged at a lower severity: an enumerator who left the
#' tablet running over lunch produces a six-hour duration and no data problem.
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param start,end Names of the timestamp columns, POSIXct or parseable.
#' @param min_minutes,max_minutes Plausible bounds. Set min from a timed pilot,
#'   not from a guess: teams consistently overestimate how long their own
#'   instrument takes.
hfc_duration <- function(df, id, start, end, min_minutes = 15, max_minutes = 180) {
  .hfc_require_cols(df, c(id, start, end), "hfc_duration")
  t0 <- as.POSIXct(df[[start]], tz = "UTC")
  t1 <- as.POSIXct(df[[end]], tz = "UTC")
  mins <- as.numeric(difftime(t1, t0, units = "mins"))

  out <- list()
  negative <- !is.na(mins) & mins < 0
  if (any(negative)) {
    out$neg <- .hfc_issue("duration_negative", "error", df[[id]][negative],
                          end, round(mins[negative], 1),
                          "the interview ended before it started; check the device clock")
  }
  short <- !is.na(mins) & mins >= 0 & mins < min_minutes
  if (any(short)) {
    out$short <- .hfc_issue("duration_short", "error", df[[id]][short], end,
                            round(mins[short], 1),
                            sprintf("completed in under %g minutes", min_minutes))
  }
  long <- !is.na(mins) & mins > max_minutes
  if (any(long)) {
    out$long <- .hfc_issue("duration_long", "warning", df[[id]][long], end,
                           round(mins[long], 1),
                           sprintf("took over %g minutes; often a tablet left running",
                                   max_minutes))
  }
  if (!length(out)) return(.hfc_empty())
  do.call(rbind, out)
}

#' Interviews recorded outside plausible working hours
#'
#' An interview stamped 02:40 is a device with the wrong clock or a form filled
#' in after the fact. Both are worth a conversation the same week.
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param timestamp Name of the start-time column.
#' @param earliest_hour,latest_hour Bounds in local time. The default 6 to 21 is
#'   wide on purpose; a survey of night-shift workers needs different ones.
#' @param tz Timezone the fieldwork happened in. ODK stamps UTC, and the whole
#'   check is meaningless if you leave it there: 02:40 UTC is a perfectly
#'   ordinary 08:10 in India.
hfc_outside_hours <- function(df, id, timestamp, earliest_hour = 6,
                              latest_hour = 21, tz = "Asia/Kolkata") {
  .hfc_require_cols(df, c(id, timestamp), "hfc_outside_hours")
  ts <- as.POSIXct(df[[timestamp]], tz = "UTC")
  local_hour <- as.numeric(format(ts, "%H", tz = tz)) +
    as.numeric(format(ts, "%M", tz = tz)) / 60
  bad <- !is.na(local_hour) & (local_hour < earliest_hour | local_hour >= latest_hour)
  if (!any(bad)) return(.hfc_empty())
  .hfc_issue("outside_hours", "warning", df[[id]][bad], timestamp,
             format(ts[bad], tz = tz, usetz = TRUE),
             sprintf("started outside %02d:00-%02d:00 %s",
                     earliest_hour, latest_hour, tz))
}

#' Straightlining: the same answer given to every item in a battery
#'
#' Twenty attitude items all answered "agree" is either a real respondent with
#' consistent views or an enumerator going down the column, and the base rate
#' says look at it. Reported as a warning, never an error, because on a short
#' battery or a genuinely lopsided one it happens legitimately.
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param battery Character vector of the items, which must share a scale.
#' @param min_items Do not flag a battery shorter than this. Three identical
#'   answers out of three is not evidence of anything.
hfc_constant <- function(df, id, battery, min_items = 5) {
  .hfc_require_cols(df, c(id, battery), "hfc_constant")
  if (length(battery) < min_items) {
    return(.hfc_empty())
  }
  block <- df[, battery, drop = FALSE]
  flat <- apply(block, 1, function(row) {
    vals <- row[!is.na(row)]
    length(vals) >= min_items && length(unique(vals)) == 1
  })
  if (!any(flat)) return(.hfc_empty())
  first_val <- apply(block[flat, , drop = FALSE], 1, function(row) {
    as.character(row[!is.na(row)][1])
  })
  .hfc_issue("straightlining", "warning", df[[id]][flat],
             paste(battery, collapse = "+"), first_val,
             sprintf("every one of %d items answered identically", length(battery)))
}

#' Run a set of checks and stack the results into one table
#'
#' @param df Data frame of submissions.
#' @param id Name of the identifier column.
#' @param required Variables that must always be answered.
#' @param ranges Named list of c(min, max), as for hfc_range.
#' @param duration List with start, end and optionally min_minutes/max_minutes.
#' @param hours List with timestamp and optionally the bounds and tz.
#' @param battery Character vector of items forming a scale.
#' @param enumerator Optional column name; when given it is joined onto the
#'   issue table, which is what makes the output sortable into per-enumerator
#'   feedback rather than a flat list.
#' @return A data frame of issues, sorted with errors first. Zero rows means
#'   every check passed, which is worth printing rather than inferring.
run_hfc <- function(df, id, required = character(), ranges = list(),
                    duration = NULL, hours = NULL, battery = character(),
                    enumerator = NULL) {
  .hfc_require_cols(df, id, "run_hfc")
  parts <- list(hfc_duplicates(df, id))

  if (length(required)) parts <- c(parts, list(hfc_missing(df, id, required)))
  if (length(ranges))   parts <- c(parts, list(hfc_range(df, id, ranges)))
  if (!is.null(duration)) {
    args <- utils::modifyList(list(df = df, id = id), duration)
    parts <- c(parts, list(do.call(hfc_duration, args)))
  }
  if (!is.null(hours)) {
    args <- utils::modifyList(list(df = df, id = id), hours)
    parts <- c(parts, list(do.call(hfc_outside_hours, args)))
  }
  if (length(battery)) parts <- c(parts, list(hfc_constant(df, id, battery)))

  issues <- do.call(rbind, parts)
  if (is.null(issues) || !nrow(issues)) return(.hfc_empty())

  if (!is.null(enumerator)) {
    .hfc_require_cols(df, enumerator, "run_hfc")
    lookup <- stats::setNames(as.character(df[[enumerator]]), as.character(df[[id]]))
    issues$enumerator <- unname(lookup[issues$id])
  }

  severity_order <- match(issues$severity, c("error", "warning", "note"))
  issues[order(severity_order, issues$check, issues$id), , drop = FALSE]
}
