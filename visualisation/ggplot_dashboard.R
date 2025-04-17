# Bar chart for Disease Burden
library(tidyverse)

df <- tibble(
  state = c("Karnataka", "Bihar", "Kerala", "UP", "Assam"),
  ncd_burden = c(320, 410, 210, 500, 340),
  communicable_burden = c(180, 390, 120, 430, 360)
)

df %>%
  pivot_longer(-state, names_to = "type", values_to = "burden") %>%
  ggplot(aes(x = reorder(state, -burden), y = burden, fill = type)) +
  geom_col(position = "dodge") +
  labs(title = "Disease Burden by State", x = "State", y = "DALYs per 100K") +
  theme_minimal()