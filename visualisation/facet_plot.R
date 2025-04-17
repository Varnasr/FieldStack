# Faceted Plot for Disaggregated Burdens
library(tidyverse)

df <- tibble(
  state = rep(c("Karnataka", "Bihar", "Kerala"), each = 2),
  type = rep(c("NCD", "Communicable"), times = 3),
  burden = c(320, 180, 410, 390, 210, 120)
)

ggplot(df, aes(x = state, y = burden, fill = type)) +
  geom_col() +
  facet_wrap(~type) +
  labs(title = "Disease Burden Faceted by Type", x = "State", y = "DALYs") +
  theme_light()