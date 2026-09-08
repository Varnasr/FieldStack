# GPS checks: was the interview where it was supposed to be?
#
# Every ODK and SurveyCTO form can capture a location at no extra cost to the
# enumerator, and almost nobody looks at it. Three things it catches:
#
#   1. Interviews recorded far from the assigned village, which is either a
#      wrong cluster assignment or an interview conducted somewhere else.
#   2. Several households sharing one coordinate to the metre, which means the
#      device was not moved between them.
#   3. A day's work with no spatial spread at all, from an enumerator who
#      recorded a batch of forms in one sitting.
#
# None of these is proof of anything on its own. A shared coordinate is ordinary
# in a dense urban block or where the enumerator captured the location once at
# the entrance to a lane. Read them alongside duration and back-check results,
# which is where a pattern becomes a case.
#
# Accuracy caveat that matters for thresholds: a phone GPS under tree cover or
# between buildings is routinely 20 to 50 metres out, and the ODK accuracy field
# often reports worse. A radius threshold below about 100 metres will flag honest
# work. Where the form captured accuracy, pass it and let the check widen its own
# tolerance per point rather than using one radius for a clear sky and a forest.

#' Great-circle distance in metres between two points
#'
#' Haversine on a sphere of radius 6,371,008.8 m, the IUGG mean Earth radius.
#' Accurate to about 0.5 per cent against the WGS-84 ellipsoid, which at the
#' distances a field check cares about is a few metres in a kilometre: far
#' inside GPS error, and not worth a geodesic library and its install.
#'
#' Vectorised over all four arguments.
#'
#' @param lat1,lon1,lat2,lon2 Decimal degrees.
#' @return Distance in metres.
haversine <- function(lat1, lon1, lat2, lon2) {
  R <- 6371008.8
  to_rad <- pi / 180
  # Catches a longitude passed as a latitude, which is the commonest argument
  # slip, but only where that longitude exceeds 90 degrees. A Bihar coordinate
  # swapped to (85.1, 25.5) passes every bounds check there is, because 85.1 is
  # a perfectly valid Arctic latitude, and comes back as a plausible distance.
  # Nothing arithmetic can catch that; sanity-check one known point by hand.
  for (v in list(lat1, lat2)) {
    if (any(!is.na(v) & (v < -90 | v > 90))) {
      stop("haversine: a latitude outside [-90, 90]. Latitude and longitude ",
           "passed in the wrong order is the usual cause.", call. = FALSE)
    }
  }
  for (v in list(lon1, lon2)) {
    if (any(!is.na(v) & (v < -180 | v > 180))) {
      stop("haversine: a longitude outside [-180, 180]", call. = FALSE)
    }
  }
  phi1 <- lat1 * to_rad; phi2 <- lat2 * to_rad
  dphi <- (lat2 - lat1) * to_rad
  dlam <- (lon2 - lon1) * to_rad
  a <- sin(dphi / 2)^2 + cos(phi1) * cos(phi2) * sin(dlam / 2)^2
  2 * R * asin(pmin(1, sqrt(a)))
}

#' Distance from each interview to its assigned cluster
#'
#' @param df Data frame of submissions.
#' @param lat,lon Coordinate columns.
#' @param cluster Column naming the assigned village or PSU.
#' @param reference Optional data frame with the cluster column and its own
#'   \code{lat}/\code{lon}, giving the authoritative centre. Without it the
#'   centre is the median of the interviews in that cluster, which is
#'   self-referential but still finds the point that sits well away from the
#'   others. Median rather than mean, so one bad coordinate does not drag the
#'   centre toward itself and hide.
#' @param radius_m Flag beyond this many metres. See the accuracy note above
#'   before setting it below 100.
#' @param accuracy Optional column of the device's reported accuracy in metres.
#'   Where given, the threshold for each point becomes \code{radius_m} plus
#'   twice that point's accuracy.
gps_distance_from_cluster <- function(df, lat, lon, cluster, reference = NULL,
                                      radius_m = 2000, accuracy = NULL) {
  need <- c(lat, lon, cluster, accuracy)
  missing <- setdiff(need, names(df))
  if (length(missing)) {
    stop("gps_distance_from_cluster: no column(s) ",
         paste(missing, collapse = ", "), " in the data", call. = FALSE)
  }
  la <- suppressWarnings(as.numeric(df[[lat]]))
  lo <- suppressWarnings(as.numeric(df[[lon]]))
  cl <- as.character(df[[cluster]])

  if (is.null(reference)) {
    centres <- do.call(rbind, lapply(unique(cl[!is.na(cl)]), function(k) {
      inside <- !is.na(cl) & cl == k
      data.frame(cluster = k,
                 clat = stats::median(la[inside], na.rm = TRUE),
                 clon = stats::median(lo[inside], na.rm = TRUE),
                 stringsAsFactors = FALSE)
    }))
    centre_source <- "median of the interviews in each cluster"
  } else {
    missing <- setdiff(c(cluster, lat, lon), names(reference))
    if (length(missing)) {
      stop("gps_distance_from_cluster: the reference frame has no column(s) ",
           paste(missing, collapse = ", "), call. = FALSE)
    }
    centres <- data.frame(cluster = as.character(reference[[cluster]]),
                          clat = as.numeric(reference[[lat]]),
                          clon = as.numeric(reference[[lon]]),
                          stringsAsFactors = FALSE)
    unknown <- setdiff(unique(cl[!is.na(cl)]), centres$cluster)
    if (length(unknown)) {
      stop("gps_distance_from_cluster: the reference frame has no centre for ",
           "cluster(s) ", paste(unknown, collapse = ", "),
           ". Those interviews would silently get no distance.", call. = FALSE)
    }
    centre_source <- "the supplied reference frame"
  }

  idx <- match(cl, centres$cluster)
  dist <- haversine(la, lo, centres$clat[idx], centres$clon[idx])

  threshold <- rep(radius_m, nrow(df))
  if (!is.null(accuracy)) {
    acc <- suppressWarnings(as.numeric(df[[accuracy]]))
    threshold <- radius_m + 2 * ifelse(is.na(acc), 0, acc)
  }

  out <- df
  out$distance_m <- round(dist, 1)
  out$distance_threshold_m <- threshold
  out$far_from_cluster <- !is.na(dist) & dist > threshold
  attr(out, "centre_source") <- centre_source
  out
}

#' Interviews sharing a coordinate, to the metre
#'
#' Legitimate in a dense block or where the enumerator captured one point for a
#' lane, so this reports groups rather than accusations. Worth reading next to
#' interview duration: identical coordinates *and* short durations is a
#' different conversation from either alone.
#'
#' @param df Data frame of submissions.
#' @param id,lat,lon Column names.
#' @param tolerance_m Points within this distance count as the same place.
#' @param min_group Only report groups of at least this size.
gps_duplicate_locations <- function(df, id, lat, lon, tolerance_m = 5,
                                    min_group = 2) {
  missing <- setdiff(c(id, lat, lon), names(df))
  if (length(missing)) {
    stop("gps_duplicate_locations: no column(s) ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  la <- suppressWarnings(as.numeric(df[[lat]]))
  lo <- suppressWarnings(as.numeric(df[[lon]]))
  ids <- as.character(df[[id]])
  ok <- which(!is.na(la) & !is.na(lo))
  if (length(ok) < 2) {
    return(data.frame(group = integer(), id = character(), lat = numeric(),
                      lon = numeric(), group_size = integer(),
                      stringsAsFactors = FALSE))
  }

  # Single-linkage clustering at the tolerance. Fine for the few thousand points
  # a survey round produces; it is O(n^2) and would want rethinking at 10^5.
  assigned <- rep(NA_integer_, length(ok))
  group_id <- 0L
  for (i in seq_along(ok)) {
    if (!is.na(assigned[i])) next
    group_id <- group_id + 1L
    queue <- i
    assigned[i] <- group_id
    while (length(queue)) {
      cur <- queue[1]; queue <- queue[-1]
      d <- haversine(la[ok[cur]], lo[ok[cur]], la[ok], lo[ok])
      near <- which(d <= tolerance_m & is.na(assigned))
      if (length(near)) {
        assigned[near] <- group_id
        queue <- c(queue, near)
      }
    }
  }

  sizes <- table(assigned)
  keep_groups <- as.integer(names(sizes)[sizes >= min_group])
  keep <- assigned %in% keep_groups
  if (!any(keep)) {
    return(data.frame(group = integer(), id = character(), lat = numeric(),
                      lon = numeric(), group_size = integer(),
                      stringsAsFactors = FALSE))
  }
  out <- data.frame(group = assigned[keep], id = ids[ok][keep],
                    lat = la[ok][keep], lon = lo[ok][keep],
                    stringsAsFactors = FALSE)
  out$group_size <- as.integer(sizes[as.character(out$group)])
  out[order(-out$group_size, out$group, out$id), , drop = FALSE]
}
