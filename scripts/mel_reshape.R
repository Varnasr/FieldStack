
# mel_reshape.R

library(tidyr)
library(dplyr)

reshape_indicators <- function(df) {
  df_long <- df %>%
    pivot_longer(
      cols = starts_with("indicator"),
      names_to = c("indicator", "quarter"),
      # Backslashes must be doubled inside an R string literal. Written with
      # single ones this file will not parse at all, so reshape_indicators()
      # was never callable.
      names_pattern = "indicator_(\\d)_(\\d{4}Q\\d)",
      values_to = "value"
    )
  return(df_long)
}
