# Load necessary libraries
install.packages("vars")
install.packages("tseries")
library(vars)
library(tseries)

# Load the Canada dataset
data("Canada")
head(Canada)

# Stationarity check with ADF test
adf_test <- apply(Canada, 2, function(series) adf.test(series)$p.value)
adf_test

# Check if differencing is necessary
needs_diff <- adf_test > 0.05
needs_diff

# Differencing the data if necessary
if (any(needs_diff)) {
  Canada_diff <- diff(Canada)
} else {
  Canada_diff <- Canada
}

# Optimal lag selection
lag_selection <- VARselect(Canada_diff, lag.max = 10, type = "const")
optimal_lag <- lag_selection$selection["AIC(n)"]
optimal_lag

# Estimate VAR model
var_model <- VAR(Canada_diff, p = optimal_lag, type = "const")
summary(var_model)

# Stability check
stability <- stability(var_model)
roots <- roots(var_model)
cat("Roots of the characteristic polynomial:\n")
print(roots)
if (all(abs(roots) < 1)) {
  cat("The model is stationary (all roots are less than 1).\n")
} else {
  cat("The model is not stationary (some roots are greater than or equal to 1).\n")
}
plot(stability)

# Forecast Error Variance Decomposition (FEVD)
fevd_result <- fevd(var_model, n.ahead = 8)
plot(fevd_result, legend.pos = "topright")

# Diagnostics
serial_test <- serial.test(var_model, lags.pt = 10, type = "PT.asymptotic")
serial_test
arch_test <- arch.test(var_model, lags.multi = 5, multivariate.only = TRUE)
arch_test

# Impulse Response Function (IRF)
irf_result <- irf(var_model, impulse = "prod", response = c("e", "rw", "U"), n.ahead = 20, boot = TRUE)
plot(irf_result)

# Forecasting
forecast <- predict(var_model, n.ahead = 8)
par(mar = c(4, 4, 2, 1))
plot(forecast)

