library(forecast)
library(rugarch)
library(aTSA)
library(fGarch)


# Loading data --------------------------------------------------------------------------------
data = read.csv('data/final.csv', header = TRUE)

# Choosing close column and plotting
logreturns = data$logreturns
ts.plot(logreturns, xlab = "Day", ylab = "Closing price")
abline(a = 0, 0, col = "red")

# Splitting into train (80%) and test (20%)
train_size = round(length(logreturns) * 0.8)
train = logreturns[1:train_size]
test = logreturns[(train_size+1):length(logreturns)]

# ARIMA -----------------------------------------------------------------------------

auto_arima = auto.arima(train, ic = "bic", seasonal = FALSE)
arimaorder(auto_arima)
arima = arima(train, c(1,0,1)) #  inserting into model (needed for arch.test)
predict(arima, n.ahead=5)

plot(arima$residuals, type="p", cex=0.5) # Heteroskedasticitet?
arch.test(arima, output = TRUE) #  H0 förkastas -> heteroskedasticitet?


# GARCH with fGarch (one way) ---------------------------------------------------------------------------

fGarch = garchFit(
  formula = ~ arma(1, 1) + garch(1, 1),
  data = train,
  trace = FALSE
)
summary(fGarch)
fgarch_pred = predict(fGarch, n.ahead = 5)

rmse_fGarch = sqrt(mean((test[1:5] - fgarch_pred$meanForecast) ^ 2))
rmse_fGarch



# GARCH (another way) --------------------------------------------------------------------------------

#* ARCH(1,1) from auto_arima (1,1)
arch = ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1))) #  simplest GARCH, a lot available
arch_fit = ugarchfit(spec = arch, data = train)
show(arch_fit)
infocriteria(arch_fit)
plot(arch_fit)

# Forecasting
forecast = ugarchforecast(arch_fit, n.ahead = 5);
forecast
rmse_arch = sqrt(mean((test[1:5] - forecast@forecast$seriesFor)^2))
rmse_arch


# ALTERNATIVE WITH ROLLING FORECAST
#spec = getspec(arch_fit);
#setfixed(spec) <- as.list(coef(arch_fit));
#forecast = ugarchforecast(spec, n.ahead = 1, n.roll = 10, data = test, out.sample = 10);

sigma(forecast);
fitted(forecast)

ts.plot(test[1:5])
lines(fitted(forecast), col="red")


# Function for comparing ARCH -----------------------------------------------------------------
archInfoCriteria <- function(p, q) {
  arch = ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(p, q)))
  arch_fit = ugarchfit(spec = arch, data = train)
  return(infocriteria(arch_fit))
}

archInfoCriteria(1,1)
# very small differences from (1,1) to the other models (< 0.01%)
archInfoCriteria(2,1)
archInfoCriteria(1,2)
archInfoCriteria(2,2)
archInfoCriteria(7,7)
