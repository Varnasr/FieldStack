# Bullet chart using ggplot2
library(ggplot2)
library(dplyr)

df <- data.frame(
  category = c("Target", "Achieved"),
  value = c(100, 73)
)

ggplot(df, aes(x = category, y = value, fill = category)) +
  geom_col(width = 0.6) +
  coord_flip() +
  scale_fill_manual(values = c("grey80", "steelblue")) +
  theme_minimal() +
  labs(title = "Performance Against Target", y = "Value", x = "")
