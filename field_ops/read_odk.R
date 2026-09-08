# Reading an ODK / KoBo / SurveyCTO export without losing half of it
#
# The wide CSV these platforms produce is not a tidy data frame, and four
# properties of it break naive analysis in ways that are quiet rather than loud.
#
#   Group prefixes. A question inside a group arrives as
#   `hh_roster/member/education`, so every reference to it in your analysis
#   script needs backticks and the full path, and a form redesign that moves the
#   question renames the column. strip_groups = TRUE flattens them, and stops
#   and names the collision if two groups hold the same question name, because
#   silently keeping one of them is how a variable gets replaced by its
#   namesake from a different section.
#
#   select_multiple. Answers arrive as one space-separated string, "1 3 7", so
#   `table()` on it returns a row per observed combination rather than per
#   option. odk_split_multiple() expands it into one 0/1 column per option.
#
#   Timestamps. `start` and `end` are ISO 8601 in UTC. Reading them as strings
#   loses the duration check, which is the most useful HFC there is, and
#   treating them as local time puts every Indian morning interview in the small
#   hours of the previous night.
#
#   Sentinel codes. -999, -99, 98 and 99 are conventionally "don't know" or
#   "refused" and are numeric in the export, so they enter a mean. A mean age
#   of 41 quietly becomes 78 when a few refusals are counted as ages.
#
# Nothing here needs a package beyond base R. That is deliberate: this is the
# first file that runs on a field export, often on somebody's laptop in a
# district office, and it should not need an install to work.

#' Read an ODK / KoBo / SurveyCTO wide export
#'
#' @param path Path to the CSV.
#' @param strip_groups Flatten `group/question` to `question`. Raises on a
#'   collision rather than choosing one.
#' @param start,end Timestamp columns to parse, if present. Missing ones are
#'   skipped quietly, because the column names differ across platforms.
#' @param na_codes Numeric sentinels to convert to NA in numeric columns. Pass
#'   \code{numeric(0)} to keep them, which you want if the codes are meaningful
#'   in your instrument.
#' @param duration Add a \code{duration_minutes} column where both timestamps
#'   parse.
#' @return A data frame, with a \code{odk_meta} attribute recording what was
#'   renamed and how many sentinel values were converted, so the read is
#'   auditable rather than magic.
read_odk <- function(path, strip_groups = TRUE, start = "start", end = "end",
                     na_codes = c(-999, -998, -99, -88), duration = TRUE) {
  if (!file.exists(path)) stop("read_odk: no file at ", path, call. = FALSE)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                        na.strings = c("", "NA", "n/a"))
  meta <- list(path = path, n_rows = nrow(df), renamed = character(),
               sentinels_converted = 0L)

  if (strip_groups) {
    original <- names(df)
    flat <- sub("^.*/", "", original)
    dup <- flat[duplicated(flat)]
    if (length(dup)) {
      offenders <- original[flat %in% unique(dup)]
      stop("read_odk: flattening group prefixes would collide on ",
           paste(unique(dup), collapse = ", "), " (from ",
           paste(offenders, collapse = ", "),
           "). Rename in the form, or read with strip_groups = FALSE.",
           call. = FALSE)
    }
    changed <- original != flat
    meta$renamed <- stats::setNames(flat[changed], original[changed])
    names(df) <- flat
  }

  for (col in c(start, end)) {
    if (!is.null(col) && col %in% names(df)) {
      parsed <- as.POSIXct(df[[col]], tz = "UTC",
                           tryFormats = c("%Y-%m-%dT%H:%M:%OS", "%Y-%m-%d %H:%M:%OS",
                                          "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M:%S"),
                           optional = TRUE)
      if (!all(is.na(parsed))) df[[col]] <- parsed
    }
  }

  if (length(na_codes)) {
    converted <- 0L
    for (col in names(df)) {
      if (is.numeric(df[[col]])) {
        hit <- df[[col]] %in% na_codes
        converted <- converted + sum(hit, na.rm = TRUE)
        df[[col]][hit] <- NA
      }
    }
    meta$sentinels_converted <- converted
  }

  if (duration && !is.null(start) && !is.null(end) &&
      all(c(start, end) %in% names(df)) &&
      inherits(df[[start]], "POSIXct") && inherits(df[[end]], "POSIXct")) {
    df$duration_minutes <- round(
      as.numeric(difftime(df[[end]], df[[start]], units = "mins")), 2)
  }

  attr(df, "odk_meta") <- meta
  df
}

#' Expand a select_multiple column into one indicator column per option
#'
#' @param df Data frame.
#' @param var The select_multiple column.
#' @param sep Separator inside the string. ODK uses a space.
#' @param options Optional vector of every valid option. Supply it: without it
#'   an option nobody selected produces no column at all, so a table built from
#'   two districts has different columns in each and a rbind silently misaligns.
#' @param prefix Prefix for the new columns. Defaults to the variable name.
#' @param drop Remove the original column.
#' @return The frame with one 0/1 column per option added. A row that is NA in
#'   the source is NA across all the new columns, not zero: "did not answer" and
#'   "selected none of them" are different facts.
odk_split_multiple <- function(df, var, sep = " ", options = NULL,
                               prefix = var, drop = FALSE) {
  if (!var %in% names(df)) {
    stop("odk_split_multiple: no column ", var, " in the data", call. = FALSE)
  }
  raw <- as.character(df[[var]])
  parts <- strsplit(ifelse(is.na(raw), "", raw), sep, fixed = TRUE)
  parts <- lapply(parts, function(p) p[nzchar(p)])

  observed <- sort(unique(unlist(parts)))
  if (is.null(options)) {
    options <- observed
    if (!length(options)) {
      warning("odk_split_multiple: ", var, " has no selections anywhere; ",
              "no columns added", call. = FALSE)
      return(df)
    }
  } else {
    options <- as.character(options)
    unexpected <- setdiff(observed, options)
    if (length(unexpected)) {
      stop("odk_split_multiple: ", var, " contains option(s) not in `options`: ",
           paste(unexpected, collapse = ", "),
           ". Either the choice list is out of date or the column is not a ",
           "select_multiple.", call. = FALSE)
    }
  }

  out <- df
  for (opt in options) {
    col <- paste0(prefix, "_", gsub("[^A-Za-z0-9]+", "_", opt))
    out[[col]] <- ifelse(is.na(raw), NA_integer_,
                         as.integer(vapply(parts, function(p) opt %in% p, logical(1))))
  }
  if (drop) out[[var]] <- NULL
  out
}
