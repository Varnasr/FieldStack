# Sample Size Calculator for Survey Design
# Covers simple random, stratified, and cluster sampling designs

#' Calculate sample size for simple random sampling
#' @param p Expected proportion (default 0.5 for maximum variance)
#' @param margin Margin of error (default 0.05)
#' @param confidence Confidence level (default 0.95)
#' @param population Population size (NULL for infinite)
#' @return Required sample size
sample_size_simple <- function(p = 0.5, margin = 0.05, confidence = 0.95, population = NULL) {
  z <- qnorm(1 - (1 - confidence) / 2)
  n <- (z^2 * p * (1 - p)) / margin^2

  # Finite population correction
  if (!is.null(population)) {
    n <- n / (1 + (n - 1) / population)
  }
  ceiling(n)
}

#' Calculate sample size for stratified sampling
#' @param strata_sizes Vector of stratum population sizes
#' @param strata_proportions Expected proportion per stratum
#' @param margin Margin of error
#' @param confidence Confidence level
#' @param allocation Allocation method: "proportional" or "equal"
#' @return Data frame with stratum-wise sample sizes
sample_size_stratified <- function(strata_sizes, strata_proportions = NULL,
                                     margin = 0.05, confidence = 0.95,
                                     allocation = "proportional") {
  k <- length(strata_sizes)
  if (is.null(strata_proportions)) strata_proportions <- rep(0.5, k)

  N <- sum(strata_sizes)
  z <- qnorm(1 - (1 - confidence) / 2)

  # Total sample size
  n_total <- sample_size_simple(p = 0.5, margin = margin, confidence = confidence, population = N)

  # Allocate across strata
  if (allocation == "proportional") {
    weights <- strata_sizes / N
  } else {
    weights <- rep(1 / k, k)
  }

  n_strata <- ceiling(n_total * weights)

  data.frame(
    stratum = seq_len(k),
    population = strata_sizes,
    proportion = strata_proportions,
    sample_size = n_strata
  )
}

#' Calculate sample size for cluster randomized designs
#' @param icc Intra-cluster correlation coefficient
#' @param cluster_size Average number of units per cluster
#' @param p Expected proportion
#' @param margin Margin of error
#' @param confidence Confidence level
#' @return List with design effect, effective sample size, and clusters needed
sample_size_cluster <- function(icc = 0.05, cluster_size = 30,
                                  p = 0.5, margin = 0.05, confidence = 0.95) {
  # Design effect
  deff <- 1 + (cluster_size - 1) * icc

  # Simple sample size
  n_simple <- sample_size_simple(p = p, margin = margin, confidence = confidence)

  # Adjusted for clustering
  n_effective <- ceiling(n_simple * deff)
  n_clusters <- ceiling(n_effective / cluster_size)

  list(
    design_effect = round(deff, 2),
    simple_sample_size = n_simple,
    effective_sample_size = n_effective,
    clusters_needed = n_clusters,
    total_sample = n_clusters * cluster_size,
    icc = icc,
    cluster_size = cluster_size
  )
}

# Example usage
if (sys.nframe() == 0) {
  cat("=== Simple Random Sampling ===\n")
  cat(sprintf("50%% proportion, 5%% margin: n = %d\n", sample_size_simple()))
  cat(sprintf("30%% proportion, 3%% margin: n = %d\n", sample_size_simple(p = 0.3, margin = 0.03)))
  cat(sprintf("With population 10000: n = %d\n", sample_size_simple(population = 10000)))

  cat("\n=== Stratified Sampling ===\n")
  strat <- sample_size_stratified(
    strata_sizes = c(5000, 3000, 2000),
    allocation = "proportional"
  )
  print(strat)

  cat("\n=== Cluster Sampling ===\n")
  cluster <- sample_size_cluster(icc = 0.05, cluster_size = 30)
  cat(sprintf("Design effect: %.2f\n", cluster$design_effect))
  cat(sprintf("Clusters needed: %d\n", cluster$clusters_needed))
  cat(sprintf("Total sample: %d (vs %d simple)\n", cluster$total_sample, cluster$simple_sample_size))
}
