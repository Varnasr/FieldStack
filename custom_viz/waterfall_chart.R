# Waterfall chart with ggplot2
library(ggplot2)
library(dplyr)

df <- data.frame(
  category = c("Initial", "Increase A", "Decrease B", "Final"),
  value = c(100, 40, -30, 110)
)

df <- df %>%
  mutate(position = cumsum(c(0, head(value, -1))),
         end = position + value,
         fill = ifelse(value >= 0, "positive", "negative"))

ggplot(df, aes(x = category)) +
  geom_rect(aes(xmin = as.numeric(factor(category)) - 0.4,
                xmax = as.numeric(factor(category)) + 0.4,
                ymin = position,
                ymax = end,
                fill = fill)) +
  scale_fill_manual(values = c("positive" = "steelblue", "negative" = "salmon")) +
  theme_minimal() +
  labs(title = "Waterfall Chart", y = "Value")