
# education_outcomes.R

library(dplyr)

summarise_education <- function(df) {
  df %>%
    group_by(district, gender) %>%
    summarise(
      pass_rate = mean(passed, na.rm = TRUE),
      .groups = "drop"
    )
}
