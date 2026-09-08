# Back checks: re-interviewing a subsample and comparing it against the original
#
# A back check sends a supervisor to re-ask a short subset of questions of
# households the enumerator has already visited. It is the only field procedure
# that can distinguish an enumerator who is fabricating from one who was sent to
# an unusual area, which is the distinction that enumerator monitoring cannot
# make on its own.
#
# The comparison only means something if the questions are classified first, and
# the classification is the part teams skip:
#
#   type1  Should never differ between two competent interviews. Sex of the
#          household head, whether the roof is concrete, land owned, whether the
#          household has electricity. A difference is an error by one of the two
#          interviewers, and the type-1 error rate is the headline number.
#
#   type2  May legitimately differ. Anything recalled over a period, income last
#          month, a subjective rating. Differences here are informative about
#          the question's reliability, not about the enumerator's honesty.
#
#   type3  Expected to differ. Anything genuinely time-varying, or asked of a
#          different respondent within the household. Tracked, never counted
#          against anyone.
#
# Reporting a single undifferentiated "error rate" over all three is the common
# mistake and it makes an honest enumerator asking hard recall questions look
# worse than a careless one asking easy ones. This function refuses to compute
# an overall rate: it reports by type.
#
# On what counts as a difference for a continuous variable: exactly equal is the
# wrong test for a number anyone estimated. Land in acres, monthly expenditure
# and household income all move a little between two honest interviews, so pass
# a tolerance. A zero tolerance on a recalled rupee figure will report a 90 per
# cent error rate and tell you nothing.
#
# See J-PAL's "Conducting back checks" (2020) for the classification scheme and
# the usual thresholds; the arithmetic here is deliberately plain.

.bc_norm_string <- function(x) {
  x <- trimws(tolower(as.character(x)))
  x[x %in% c("", "na", "n/a", ".")] <- NA_character_
  x
}

#' Compare a back-check round against the original submissions
#'
#' @param main Data frame of original submissions.
#' @param back Data frame of back-check submissions.
#' @param id Identifier column, present in both.
#' @param types Named list mapping variable name to "type1", "type2" or
#'   "type3". Every variable to be compared must appear; an unclassified
#'   variable raises rather than being silently pooled with the type-1s.
#' @param tolerance Named list of absolute tolerances for numeric variables,
#'   e.g. \code{list(land_acres = 0.25, monthly_spend = 200)}. A numeric
#'   variable with no tolerance is compared exactly, which is right for a count
#'   of children and wrong for a rupee figure.
#' @param enumerator Optional column in \code{main} naming who did the original
#'   interview, carried through so the summary can be per enumerator.
#' @return A list with \code{comparisons} (one row per household-variable),
#'   \code{by_variable}, \code{by_enumerator} (when available), and
#'   \code{unmatched} (ids in one frame and not the other).
back_check_compare <- function(main, back, id, types, tolerance = list(),
                               enumerator = NULL) {
  if (!is.list(types) || is.null(names(types)) || any(names(types) == "")) {
    stop("back_check_compare: types must be a named list, ",
         "variable -> 'type1'/'type2'/'type3'", call. = FALSE)
  }
  bad_type <- setdiff(unlist(types), c("type1", "type2", "type3"))
  if (length(bad_type)) {
    stop("back_check_compare: unknown type(s) ", paste(bad_type, collapse = ", "),
         ". Use type1 (should never differ), type2 (may differ), ",
         "type3 (expected to differ).", call. = FALSE)
  }
  vars <- names(types)
  for (nm in c("main", "back")) {
    frame <- get(nm)
    missing <- setdiff(c(id, vars), names(frame))
    if (length(missing)) {
      stop("back_check_compare: ", nm, " has no column(s) ",
           paste(missing, collapse = ", "), call. = FALSE)
    }
  }
  bad_tol <- setdiff(names(tolerance), vars)
  if (length(bad_tol)) {
    stop("back_check_compare: tolerance names variable(s) not being compared: ",
         paste(bad_tol, collapse = ", "), call. = FALSE)
  }

  main_id <- as.character(main[[id]])
  back_id <- as.character(back[[id]])
  if (anyDuplicated(back_id)) {
    stop("back_check_compare: the back-check frame has duplicate ids; ",
         "resolve them before comparing", call. = FALSE)
  }

  matched <- intersect(main_id, back_id)
  unmatched <- data.frame(
    id = c(setdiff(back_id, main_id), setdiff(main_id, back_id)),
    problem = c(rep("back-checked but not in the main survey",
                    length(setdiff(back_id, main_id))),
                rep("in the main survey but not back-checked",
                    length(setdiff(main_id, back_id)))),
    stringsAsFactors = FALSE)
  # The first kind is the serious one: a supervisor found a household the main
  # survey has no record of. The second is ordinary, since only a subsample is
  # back-checked, so it is reported as a note rather than mixed in.
  unmatched$severity <- ifelse(
    unmatched$problem == "back-checked but not in the main survey", "error", "note")

  if (!length(matched)) {
    stop("back_check_compare: no ids appear in both frames. Check that the id ",
         "column means the same thing in each.", call. = FALSE)
  }

  mi <- match(matched, main_id)
  bi <- match(matched, back_id)

  rows <- list()
  for (v in vars) {
    a <- main[[v]][mi]
    b <- back[[v]][bi]
    tol <- tolerance[[v]]
    numeric_pair <- is.numeric(a) || is.numeric(b) || !is.null(tol)

    if (numeric_pair) {
      an <- suppressWarnings(as.numeric(a))
      bn <- suppressWarnings(as.numeric(b))
      tolv <- if (is.null(tol)) 0 else tol
      differs <- ifelse(is.na(an) & is.na(bn), FALSE,
                        ifelse(is.na(an) | is.na(bn), TRUE,
                               abs(an - bn) > tolv))
      shown_a <- as.character(an); shown_b <- as.character(bn)
    } else {
      as_ <- .bc_norm_string(a); bs_ <- .bc_norm_string(b)
      differs <- ifelse(is.na(as_) & is.na(bs_), FALSE,
                        ifelse(is.na(as_) | is.na(bs_), TRUE, as_ != bs_))
      shown_a <- as.character(a); shown_b <- as.character(b)
    }

    rows[[v]] <- data.frame(
      id = matched, variable = v, type = types[[v]],
      main_value = shown_a, back_value = shown_b,
      differs = differs, stringsAsFactors = FALSE)
  }
  comparisons <- do.call(rbind, rows)

  if (!is.null(enumerator)) {
    if (!enumerator %in% names(main)) {
      stop("back_check_compare: main has no column ", enumerator, call. = FALSE)
    }
    lookup <- stats::setNames(as.character(main[[enumerator]]), main_id)
    comparisons$enumerator <- unname(lookup[comparisons$id])
  }

  by_variable <- do.call(rbind, lapply(vars, function(v) {
    part <- comparisons[comparisons$variable == v, , drop = FALSE]
    data.frame(variable = v, type = types[[v]], n_compared = nrow(part),
               n_differing = sum(part$differs),
               error_rate = round(mean(part$differs), 4),
               stringsAsFactors = FALSE)
  }))
  by_variable <- by_variable[order(by_variable$type, -by_variable$error_rate), ,
                             drop = FALSE]

  by_enumerator <- NULL
  if (!is.null(enumerator)) {
    t1 <- comparisons[comparisons$type == "type1", , drop = FALSE]
    if (nrow(t1)) {
      by_enumerator <- do.call(rbind, lapply(sort(unique(t1$enumerator)), function(e) {
        part <- t1[!is.na(t1$enumerator) & t1$enumerator == e, , drop = FALSE]
        data.frame(enumerator = e,
                   households_back_checked = length(unique(part$id)),
                   type1_comparisons = nrow(part),
                   type1_differing = sum(part$differs),
                   type1_error_rate = round(mean(part$differs), 4),
                   stringsAsFactors = FALSE)
      }))
      by_enumerator <- by_enumerator[order(-by_enumerator$type1_error_rate), ,
                                     drop = FALSE]
    }
  }

  out <- list(comparisons = comparisons, by_variable = by_variable,
              by_enumerator = by_enumerator, unmatched = unmatched,
              n_matched = length(matched))
  class(out) <- c("fs_back_check", "list")
  out
}

#' @export
print.fs_back_check <- function(x, ...) {
  cat("Back check:", x$n_matched, "households matched\n\n")
  cat("By variable (an overall rate across types would be meaningless):\n")
  print(x$by_variable, row.names = FALSE)
  if (!is.null(x$by_enumerator)) {
    cat("\nType-1 error rate by enumerator:\n")
    print(x$by_enumerator, row.names = FALSE)
  }
  serious <- x$unmatched[x$unmatched$severity == "error", , drop = FALSE]
  if (nrow(serious)) {
    cat("\n", nrow(serious),
        " household(s) back-checked that the main survey has no record of:\n", sep = "")
    print(serious[, c("id", "problem")], row.names = FALSE)
  }
  invisible(x)
}
