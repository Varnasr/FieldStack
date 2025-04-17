# Multi-Year SROI Example
years <- 1:5
benefits <- c(50000, 60000, 65000, 70000, 75000)
costs <- rep(100000, 5)
discount_rate <- 0.08

# Present value function
npv <- function(x, rate, t) x / (1 + rate)^t
present_values <- mapply(npv, benefits, discount_rate, years)
sroi <- sum(present_values) / sum(costs)
cat("Discounted SROI:", round(sroi, 2), "\n")