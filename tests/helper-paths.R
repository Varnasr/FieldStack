# testthat sets the working directory to this folder while tests run, but the
# scripts and sample data live at the repository root. Every test in here used
# to say source("scripts/x.R"), which resolves from the root and not from here,
# so all nine of them errored on the first line. Nothing said so, because the
# repository had no CI.
#
# Resolve through fs_path() instead and a test works from either place.

fs_root <- local({
  for (candidate in c(".", "..", "../..")) {
    if (dir.exists(file.path(candidate, "survey_tools")) &&
        dir.exists(file.path(candidate, "sample_data"))) {
      return(normalizePath(candidate, mustWork = TRUE))
    }
  }
  stop("Cannot locate the FieldStack root from ", normalizePath("."), call. = FALSE)
})

fs_path <- function(...) file.path(fs_root, ...)
