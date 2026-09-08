# Tests for field_ops/
#
# A field check has an asymmetric cost structure: a missed fabrication is a
# corrupted dataset nobody knows is corrupted, and a false flag is a wasted
# accusation that teaches the field team to ignore the report. So these test
# both directions: that each check fires on the case it exists for, and that it
# stays quiet on the honest case that superficially resembles it.

library(testthat)
source("helper-paths.R")
source(fs_path("field_ops", "high_frequency_checks.R"))
source(fs_path("field_ops", "enumerator_monitoring.R"))
source(fs_path("field_ops", "back_checks.R"))
source(fs_path("field_ops", "gps_checks.R"))
source(fs_path("field_ops", "read_odk.R"))

sample_submissions <- function() {
  data.frame(
    id = c("A1", "A2", "A3", "A4", "A5"),
    enum = c("E1", "E1", "E2", "E2", "E3"),
    consent = c("yes", "yes", "yes", "yes", "yes"),
    age = c(34, 41, 29, 55, 38),
    start = as.POSIXct(c("2026-01-05 03:30", "2026-01-05 05:00", "2026-01-05 06:00",
                         "2026-01-05 07:00", "2026-01-05 08:00"), tz = "UTC"),
    end = as.POSIXct(c("2026-01-05 04:20", "2026-01-05 05:50", "2026-01-05 06:55",
                       "2026-01-05 07:45", "2026-01-05 08:52"), tz = "UTC"),
    stringsAsFactors = FALSE)
}

# ---------------------------------------------------------------------------
# High-frequency checks
# ---------------------------------------------------------------------------

test_that("a clean day of submissions raises nothing", {
  df <- sample_submissions()
  issues <- run_hfc(df, "id", required = "consent",
                    ranges = list(age = c(0, 110)),
                    duration = list(start = "start", end = "end"))
  expect_equal(nrow(issues), 0)
})

test_that("duplicate ids report every member of the group, not just the repeat", {
  df <- sample_submissions()
  df$id[4] <- "A3"
  issues <- hfc_duplicates(df, "id")
  expect_equal(nrow(issues), 1)
  expect_equal(issues$id, "A3")
  expect_match(issues$message, "2 submissions")
  expect_equal(issues$severity, "error")
})

test_that("a blank string counts as missing, not just NA", {
  df <- sample_submissions()
  df$consent[2] <- ""
  df$consent[3] <- NA
  issues <- hfc_missing(df, "id", "consent")
  expect_setequal(issues$id, c("A2", "A3"))
})

test_that("a skip-pattern blank is not flagged when it is not listed as required", {
  df <- sample_submissions()
  df$followup <- c("a", NA, NA, NA, NA)
  expect_equal(nrow(hfc_missing(df, "id", "consent")), 0)
})

test_that("out-of-range values are caught and an open upper bound is honoured", {
  df <- sample_submissions()
  df$age[3] <- 210
  expect_equal(hfc_range(df, "id", list(age = c(0, 110)))$id, "A3")
  expect_equal(nrow(hfc_range(df, "id", list(age = c(0, NA)))), 0)
})

test_that("a range spec of the wrong shape raises rather than guessing", {
  df <- sample_submissions()
  expect_error(hfc_range(df, "id", list(age = c(0, 50, 110))), "exactly c\\(min, max\\)")
  expect_error(hfc_range(df, "id", list(c(0, 110))), "named list")
})

test_that("a suspiciously short interview is an error and a long one only a warning", {
  df <- sample_submissions()
  df$end[2] <- df$start[2] + 60 * 8       # 8 minutes
  df$end[4] <- df$start[4] + 60 * 400     # over 6 hours
  issues <- hfc_duration(df, "id", "start", "end", min_minutes = 15, max_minutes = 180)
  expect_equal(issues$severity[issues$id == "A2"], "error")
  expect_equal(issues$severity[issues$id == "A4"], "warning")
})

test_that("an interview that ends before it starts is caught separately", {
  df <- sample_submissions()
  df$end[1] <- df$start[1] - 60
  issues <- hfc_duration(df, "id", "start", "end")
  expect_true("duration_negative" %in% issues$check)
  expect_match(issues$message[issues$check == "duration_negative"], "device clock")
})

test_that("working hours are judged in local time, not in the UTC the form recorded", {
  df <- sample_submissions()
  # 03:30 UTC is 09:00 in India: an ordinary morning, and out of hours if the
  # timezone is ignored. This is the check's whole failure mode.
  in_india <- hfc_outside_hours(df, "id", "start", tz = "Asia/Kolkata")
  expect_equal(nrow(in_india), 0)
  as_utc <- hfc_outside_hours(df, "id", "start", tz = "UTC")
  expect_true("A1" %in% as_utc$id)
})

test_that("straightlining fires on a flat battery and not on a short one", {
  df <- sample_submissions()
  items <- paste0("q", 1:5)
  df[items] <- as.data.frame(matrix(c(rep(3, 5), 1:5, c(2, 4, 1, 5, 3),
                                      c(5, 5, 5, 5, 5), c(1, 2, 3, 4, 5)),
                                    nrow = 5, byrow = TRUE))
  flagged <- hfc_constant(df, "id", items)
  expect_setequal(flagged$id, c("A1", "A4"))
  expect_equal(nrow(hfc_constant(df, "id", items[1:3])), 0)   # below min_items
})

test_that("run_hfc stacks the checks, sorts errors first and attaches the enumerator", {
  df <- sample_submissions()
  df$id[4] <- "A3"
  df$age[2] <- 200
  issues <- run_hfc(df, "id", required = "consent", ranges = list(age = c(0, 110)),
                    enumerator = "enum")
  expect_true(all(c("duplicate_id", "out_of_range") %in% issues$check))
  expect_equal(issues$severity[1], "error")
  expect_true("enumerator" %in% names(issues))
  expect_equal(issues$enumerator[issues$check == "out_of_range"], "E1")
})

test_that("a missing column is named rather than producing a cryptic subscript error", {
  df <- sample_submissions()
  expect_error(hfc_missing(df, "id", "no_such_column"), "no column")
})

# ---------------------------------------------------------------------------
# Enumerator monitoring
# ---------------------------------------------------------------------------

monitoring_frame <- function(seed = 4) {
  set.seed(seed)
  data.frame(
    enum = rep(c("E1", "E2", "E3"), each = 60),
    village = rep(rep(c("V1", "V2"), each = 30), 3),
    date = rep(seq(as.Date("2026-01-05"), by = "day", length.out = 6), 30),
    dur = c(rnorm(60, 45, 5), rnorm(60, 44, 5), rnorm(60, 21, 4)),
    poor = c(rbinom(60, 1, 0.40), rbinom(60, 1, 0.42), rbinom(60, 1, 0.85)),
    stringsAsFactors = FALSE)
}

test_that("productivity is per day worked, not per calendar day since the start", {
  df <- monitoring_frame()
  df <- df[!(df$enum == "E2" & df$date > as.Date("2026-01-07")), ]
  s <- enumerator_summary(df, "enum", date = "date")
  e2 <- s[s$enumerator == "E2", ]
  expect_equal(e2$days_worked, 3)
  expect_equal(e2$per_day, round(e2$n_interviews / 3, 2))
})

test_that("the odd enumerator is found on both duration and outcome", {
  out <- enumerator_outliers(monitoring_frame(), "enum", vars = c("dur", "poor"))
  flagged <- unique(out$enumerator[out$flagged])
  expect_true("E3" %in% flagged)
  expect_equal(out$enumerator[1], "E3")     # sorted by |z|
})

test_that("three enumerators doing the same work flag nobody", {
  set.seed(12)
  df <- data.frame(enum = rep(c("E1", "E2", "E3"), each = 60),
                   x = rnorm(180, 10, 2), stringsAsFactors = FALSE)
  out <- enumerator_outliers(df, "enum", vars = "x")
  expect_false(any(out$flagged))
})

test_that("the benchmark leaves the enumerator out of it", {
  # E1 sits far from the others. Included in its own benchmark the difference
  # would be pulled toward zero; left out it is the full gap.
  df <- data.frame(enum = rep(c("E1", "E2"), each = 30),
                   x = c(rep(10, 30), rep(0, 30)), stringsAsFactors = FALSE)
  out <- enumerator_outliers(df, "enum", vars = "x", min_n = 10)
  expect_equal(out$others_mean[out$enumerator == "E1"], 0)
  expect_equal(out$difference[out$enumerator == "E1"], 10)
})

test_that("small cells are skipped rather than producing a large z from nothing", {
  df <- data.frame(enum = c(rep("E1", 3), rep("E2", 40)),
                   x = c(99, 98, 97, rnorm(40)), stringsAsFactors = FALSE)
  out <- enumerator_outliers(df, "enum", vars = "x", min_n = 10)
  expect_false("E1" %in% out$enumerator)
})

test_that("within-group comparison holds the area constant", {
  # E1 works only the rich village and E2 only the poor one. Pooled, E1 looks
  # like an outlier; within village there is nothing to compare and no flag.
  df <- data.frame(
    enum = rep(c("E1", "E2"), each = 40),
    village = rep(c("rich", "poor"), each = 40),
    y = c(rnorm(40, 100, 5), rnorm(40, 50, 5)), stringsAsFactors = FALSE)
  pooled <- enumerator_outliers(df, "enum", vars = "y")
  expect_true(any(pooled$flagged))
  within <- enumerator_outliers(df, "enum", vars = "y", within = "village")
  expect_equal(nrow(within), 0)
})

test_that("the confounding caveat travels with the result", {
  out <- enumerator_outliers(monitoring_frame(), "enum", vars = "dur")
  expect_match(attr(out, "caveat"), "rarely randomly assigned")
})

test_that("daily load flags the heavy day and not the ordinary one", {
  df <- data.frame(enum = c(rep("E1", 12), rep("E2", 4)),
                   date = c(rep("2026-01-05", 12), rep("2026-01-05", 4)),
                   stringsAsFactors = FALSE)
  out <- enumerator_daily_load(df, "enum", "date", max_per_day = 10)
  expect_true(out$flagged[out$enumerator == "E1"])
  expect_false(out$flagged[out$enumerator == "E2"])
})

# ---------------------------------------------------------------------------
# Back checks
# ---------------------------------------------------------------------------

bc_frames <- function() {
  main <- data.frame(
    id = paste0("H", 1:6), enum = c("E1", "E1", "E1", "E2", "E2", "E2"),
    head_sex = c("m", "f", "m", "m", "f", "m"),
    electricity = c(1, 1, 0, 1, 1, 1),
    land_acres = c(2.0, 1.5, 0.0, 3.2, 1.1, 0.8),
    spend = c(4000, 3500, 2000, 5000, 3000, 2500), stringsAsFactors = FALSE)
  back <- data.frame(
    id = paste0("H", 1:5),
    head_sex = c("M", "f", "f", "m", "m"),        # H1 differs only in case
    electricity = c(1, 1, 0, 0, 1),
    land_acres = c(2.0, 1.6, 0.0, 3.2, 1.9),
    spend = c(4100, 3500, 2200, 4800, 3000), stringsAsFactors = FALSE)
  list(main = main, back = back)
}

bc_types <- list(head_sex = "type1", electricity = "type1",
                 land_acres = "type1", spend = "type2")

test_that("case and whitespace do not count as a difference in a string answer", {
  f <- bc_frames()
  r <- back_check_compare(f$main, f$back, "id", bc_types,
                          tolerance = list(land_acres = 0.25, spend = 500))
  h1 <- r$comparisons[r$comparisons$id == "H1" & r$comparisons$variable == "head_sex", ]
  expect_false(h1$differs)         # "m" against "M"
})

test_that("a real type-1 difference is caught", {
  f <- bc_frames()
  r <- back_check_compare(f$main, f$back, "id", bc_types,
                          tolerance = list(land_acres = 0.25, spend = 500))
  differing <- r$comparisons[r$comparisons$differs, ]
  expect_true("H3" %in% differing$id[differing$variable == "head_sex"])
  expect_true("H4" %in% differing$id[differing$variable == "electricity"])
})

test_that("tolerance is what stops a recalled figure reporting a false error", {
  f <- bc_frames()
  loose <- back_check_compare(f$main, f$back, "id", bc_types,
                              tolerance = list(land_acres = 0.25, spend = 500))
  strict <- back_check_compare(f$main, f$back, "id", bc_types)
  spend_loose <- loose$by_variable$n_differing[loose$by_variable$variable == "spend"]
  spend_strict <- strict$by_variable$n_differing[strict$by_variable$variable == "spend"]
  expect_equal(spend_loose, 0)
  expect_gt(spend_strict, 0)
})

test_that("error rates are reported by type and never pooled across types", {
  f <- bc_frames()
  r <- back_check_compare(f$main, f$back, "id", bc_types,
                          tolerance = list(land_acres = 0.25, spend = 500))
  expect_true(all(c("type1", "type2") %in% r$by_variable$type))
  expect_false("error_rate_overall" %in% names(r))
})

test_that("the per-enumerator rate uses type-1 comparisons only", {
  f <- bc_frames()
  r <- back_check_compare(f$main, f$back, "id", bc_types,
                          tolerance = list(land_acres = 0.25, spend = 500),
                          enumerator = "enum")
  expect_true(all(r$by_enumerator$type1_comparisons %% 3 == 0))   # three type-1 vars
  expect_equal(nrow(r$by_enumerator), 2)
})

test_that("a household back-checked but absent from the main survey is an error", {
  f <- bc_frames()
  f$back$id[5] <- "H99"
  r <- back_check_compare(f$main, f$back, "id", bc_types,
                          tolerance = list(land_acres = 0.25, spend = 500))
  serious <- r$unmatched[r$unmatched$severity == "error", ]
  expect_equal(serious$id, "H99")
  # a household simply not sampled for back-check is only a note
  expect_true("H6" %in% r$unmatched$id[r$unmatched$severity == "note"])
})

test_that("an unknown or unclassified type raises rather than being pooled", {
  f <- bc_frames()
  expect_error(back_check_compare(f$main, f$back, "id",
                                  list(head_sex = "important")), "unknown type")
  expect_error(back_check_compare(f$main, f$back, "id", bc_types,
                                  tolerance = list(nonexistent = 1)),
               "not being compared")
})

test_that("duplicate ids in the back-check frame stop the comparison", {
  f <- bc_frames()
  f$back$id[2] <- "H1"
  expect_error(back_check_compare(f$main, f$back, "id", bc_types), "duplicate ids")
})

# ---------------------------------------------------------------------------
# GPS
# ---------------------------------------------------------------------------

test_that("haversine reproduces known distances", {
  # One degree of latitude on a sphere of radius 6371008.8 m
  expect_equal(haversine(0, 0, 1, 0), 111195, tolerance = 1e-4)
  # Delhi to Mumbai, published as roughly 1150 km great circle
  d <- haversine(28.6139, 77.2090, 19.0760, 72.8777) / 1000
  expect_gt(d, 1130); expect_lt(d, 1170)
  expect_equal(haversine(12.9, 77.6, 12.9, 77.6), 0)
})

test_that("haversine is symmetric and vectorised", {
  expect_equal(haversine(10, 20, 30, 40), haversine(30, 40, 10, 20))
  out <- haversine(c(0, 0), c(0, 0), c(1, 2), c(0, 0))
  expect_equal(length(out), 2)
  expect_equal(out[2], 2 * out[1], tolerance = 1e-6)
})

test_that("a longitude passed as a latitude is refused where it can be detected", {
  expect_error(haversine(120, 20, 30, 40), "outside \\[-90, 90\\]")
})

test_that("an interview far from its cluster is flagged and near ones are not", {
  df <- data.frame(id = paste0("H", 1:4), village = "V1",
                   lat = c(25.5000, 25.5010, 25.5005, 25.9000),
                   lon = c(85.1000, 85.1010, 85.1005, 85.4000),
                   stringsAsFactors = FALSE)
  out <- gps_distance_from_cluster(df, "lat", "lon", "village", radius_m = 2000)
  expect_equal(sum(out$far_from_cluster), 1)
  expect_true(out$far_from_cluster[out$id == "H4"])
})

test_that("a reference frame missing a cluster raises rather than silently skipping", {
  df <- data.frame(id = c("H1", "H2"), village = c("V1", "V2"),
                   lat = c(25.5, 25.6), lon = c(85.1, 85.2), stringsAsFactors = FALSE)
  ref <- data.frame(village = "V1", lat = 25.5, lon = 85.1, stringsAsFactors = FALSE)
  expect_error(gps_distance_from_cluster(df, "lat", "lon", "village", reference = ref),
               "no centre for cluster")
})

test_that("the accuracy column widens the threshold per point", {
  df <- data.frame(id = c("H1", "H2", "H3"), village = "V1",
                   lat = c(25.5000, 25.5001, 25.5200),
                   lon = c(85.1, 85.1, 85.1),
                   acc = c(5, 5, 2000), stringsAsFactors = FALSE)
  tight <- gps_distance_from_cluster(df, "lat", "lon", "village", radius_m = 500)
  loose <- gps_distance_from_cluster(df, "lat", "lon", "village", radius_m = 500,
                                     accuracy = "acc")
  expect_true(tight$far_from_cluster[3])
  expect_false(loose$far_from_cluster[3])
})

test_that("households sharing a coordinate are grouped, and spread ones are not", {
  df <- data.frame(id = paste0("H", 1:5),
                   lat = c(26.1, 26.1, 26.1, 25.5, 25.6),
                   lon = c(85.9, 85.9, 85.9, 85.1, 85.2), stringsAsFactors = FALSE)
  out <- gps_duplicate_locations(df, "id", "lat", "lon")
  expect_equal(nrow(out), 3)
  expect_equal(unique(out$group_size), 3)
  expect_setequal(out$id, c("H1", "H2", "H3"))
})

# ---------------------------------------------------------------------------
# Reading an ODK export
# ---------------------------------------------------------------------------

write_export <- function(lines) {
  path <- tempfile(fileext = ".csv")
  writeLines(lines, path)
  path
}

test_that("group prefixes are stripped, recorded, and timestamps become a duration", {
  path <- write_export(c(
    "meta/instanceID,hh/id,hh/age,start,end",
    "uuid:1,H1,34,2026-01-05T09:00:00,2026-01-05T09:47:00",
    "uuid:2,H2,41,2026-01-05T10:00:00,2026-01-05T10:12:00"))
  d <- read_odk(path)
  expect_true(all(c("instanceID", "id", "age") %in% names(d)))
  expect_false(any(grepl("/", names(d))))
  expect_equal(d$duration_minutes, c(47, 12))
  expect_equal(unname(attr(d, "odk_meta")$renamed["hh/age"]), "age")
})

test_that("a name collision from flattening is refused rather than resolved silently", {
  path <- write_export(c("a/name,b/name", "1,2"))
  expect_error(read_odk(path, strip_groups = FALSE), NA)
  expect_error(read_odk(path), "would collide on name")
})

test_that("sentinel codes become NA and the count is recorded", {
  path <- write_export(c("id,age,income", "H1,34,5000", "H2,-999,-99"))
  d <- read_odk(path)
  expect_true(is.na(d$age[2]))
  expect_true(is.na(d$income[2]))
  expect_equal(attr(d, "odk_meta")$sentinels_converted, 2)
  kept <- read_odk(path, na_codes = numeric(0))
  expect_equal(kept$age[2], -999)
})

test_that("select_multiple expands to one column per option", {
  df <- data.frame(id = c("H1", "H2", "H3"),
                   owns = c("1 3", "2", NA), stringsAsFactors = FALSE)
  out <- odk_split_multiple(df, "owns", options = c("1", "2", "3", "4"))
  expect_equal(out$owns_1, c(1L, 0L, NA))
  expect_equal(out$owns_3, c(1L, 0L, NA))
  expect_true("owns_4" %in% names(out))     # kept though nobody selected it
})

test_that("no answer stays NA rather than becoming a row of zeros", {
  df <- data.frame(id = "H1", owns = NA_character_, stringsAsFactors = FALSE)
  out <- odk_split_multiple(df, "owns", options = c("1", "2"))
  expect_true(all(is.na(c(out$owns_1, out$owns_2))))
})

test_that("an option outside the declared choice list raises", {
  df <- data.frame(id = "H1", owns = "9", stringsAsFactors = FALSE)
  expect_error(odk_split_multiple(df, "owns", options = c("1", "2")),
               "not in `options`")
})
