# Qual to Quant Conversion Example
library(tibble)

# Simulated qualitative responses
data <- tibble(
  respondent_id = 1:5,
  satisfaction = c("Very satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very dissatisfied")
)

# Conversion rules
data <- data %>%
  mutate(score = case_when(
    satisfaction == "Very satisfied" ~ 5,
    satisfaction == "Satisfied" ~ 4,
    satisfaction == "Neutral" ~ 3,
    satisfaction == "Dissatisfied" ~ 2,
    satisfaction == "Very dissatisfied" ~ 1
  ))

print(data)