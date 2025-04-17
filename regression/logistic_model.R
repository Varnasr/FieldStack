# Logistic Regression Example: Predicting Hospitalization
library(tidyverse)

# Simulated dataset
data <- tibble(
  age = c(45, 67, 29, 52, 60),
  has_comorbidity = c(1, 1, 0, 1, 0),
  hospitalized = c(1, 1, 0, 1, 0)
)

# Fit model
model <- glm(hospitalized ~ age + has_comorbidity, data = data, family = binomial)
summary(model)
exp(coef(model))