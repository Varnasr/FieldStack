# Regression with interaction term
data(mtcars)

model <- lm(mpg ~ wt * hp, data = mtcars)
summary(model)