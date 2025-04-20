# Multicollinearity check using VIF
library(car)

data(mtcars)
model <- lm(mpg ~ wt + hp + disp, data = mtcars)

vif_result <- vif(model)
print(vif_result)