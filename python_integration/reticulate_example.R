# Example using reticulate to run Python code from R
library(reticulate)

py_run_string("x = 10 + 5")
cat("Python computed:", py$x, "\n")