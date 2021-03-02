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
train_size = round(length(returns) * 0.9)

train = returns[1:train_size]
test = returns[(train_size+1):length(returns)]
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


