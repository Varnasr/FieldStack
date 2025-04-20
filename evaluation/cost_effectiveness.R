# Simple cost-effectiveness ratio calculator
total_cost <- 500000  # Total program cost in INR
total_outcomes <- 10000  # Total positive health outcomes (e.g., DALYs averted)

cost_per_outcome <- total_cost / total_outcomes
cat("Cost per health outcome:", round(cost_per_outcome, 2), "INR\n")