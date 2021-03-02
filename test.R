library(forecast)
library(rugarch)
library(readxl)
library(aTSA)


# Loading data --------------------------------------------------------------------------------
data = read.csv('data/final.csv', header = TRUE)

# Choosing close column and plotting
logreturns = data$logreturns
ts.plot(logreturns, xlab = "Day", ylab = "Closing price")
abline(a = 0, 0, col = "red")

# Splitting into train (90%) and test (10%)
train_size = round(length(logreturns) * 0.9)

train = logreturns[1:train_size]
test = logreturns[(train_size+1):length(logreturns)]
tail(train)
head(test)

# ARIMA -----------------------------------------------------------------------------

auto_arima = auto.arima(train, ic = "bic", seasonal = FALSE)
arimaorder(auto_arima)
arima = arima(train, c(1,0,1)) #  inserting into model (needed for arch.test)
arima_forecast = predict(arima, n.ahead=5)

rmse_arima = sqrt(mean((test[1:5] - arima_forecast$pred)^2))
rmse_arima

plot(arima$residuals, type="p", cex=0.5)
arch.test(arima, output = TRUE) #  H0 förkastas -> heteroskedasticitet?


# GARCH --------------------------------------------------------------------------------

#* ARCH(1,1) from auto_arima (1,1)
arch = ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1))) #  simplest GARCH, a lot available
arch_fit = ugarchfit(spec = arch, data = train)
show(arch_fit)
infocriteria(arch_fit)
plot(arch_fit)

# Forecasting
forecast = ugarchforecast(arch_fit, n.ahead = 5);
rmse_arch = sqrt(mean((test[1:5] - forecast@forecast$seriesFor)^2))
rmse_arch


# ALTERNATIVE WITH ROLLING FORECAST
#spec = getspec(arch_fit);
#setfixed(spec) <- as.list(coef(arch_fit));
#forecast = ugarchforecast(spec, n.ahead = 1, n.roll = 10, data = test, out.sample = 10);

sigma(forecast);
fitted(forecast)

ts.plot(test[1:50])
lines(fitted(forecast), col="red")


# Function for comparing ARCH -----------------------------------------------------------------
archInfoCriteria <- function(p, q) {
  arch = ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(p, q)))
  arch_fit = ugarchfit(spec = arch, data = train)
  return(infocriteria(arch_fit))
}

archInfoCriteria(1,1)
# very small differences to these other models (< 0.01%)
archInfoCriteria(2,1)
archInfoCriteria(1,2)
archInfoCriteria(2,2)
archInfoCriteria(7,7)
