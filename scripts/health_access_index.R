
# health_access_index.R

library(dplyr)

compute_access_index <- function(df) {
  df %>%
    group_by(district) %>%
    summarise(
      subcentres = mean(subcentres),
      phcs = mean(phcs),
      chcs = mean(chcs),
      population = mean(population),
      .groups = "drop"
    ) %>%
    mutate(
      access_index = (subcentres * 0.4 + phcs * 0.4 + chcs * 0.2) / population * 1000
    )
}
