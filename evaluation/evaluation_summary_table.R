# Generate a simple evaluation results summary table
library(tibble)

summary_table <- tribble(
  ~Indicator, ~Baseline, ~Endline, ~Change,
  "Coverage (%)", 40, 72, "+32",
  "Satisfaction (%)", 60, 84, "+24",
  "Awareness (%)", 55, 70, "+15"
)

print(summary_table)