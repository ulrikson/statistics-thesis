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

# Splitting into train and test
train_size = round(length(logreturns) - 7)
train = logreturns[1:train_size]
test = logreturns[(train_size+1):length(logreturns)]

# ARIMA -----------------------------------------------------------------------------

auto_arima = auto.arima(train, ic = "bic", seasonal = FALSE)
arimaorder(auto_arima)
arima = arima(train, c(1,1,2)) #  inserting into model (needed for arch.test)
#predict(arima, n.ahead=5)

plot(arima$residuals, type="p", cex=0.5) # Heteroskedasticitet?
arch.test(arima, output = TRUE) #  H0 förkastas -> heteroskedasticitet?

# ARMA-GARCH ---------------------------------------------------------------------------

armaGarch = garchFit(
  formula = ~ arma(1, 2) + garch(1, 1),
  data = train,
  trace = FALSE
)
summary(armaGarch)
armaGarch@fit$ics

# 1 day ahead
armaGarch_1 = predict(armaGarch, n.ahead = 1)
rmse_1 = sqrt(mean((test[1:1] - armaGarch_1$meanForecast) ^ 2))
mape_1 = mean(abs((test[1:1] - armaGarch_1$meanForecast) / test[1:1])) * 100
paste(rmse_1, mape_1)

# 3 days ahead
armaGarch_3 = predict(armaGarch, n.ahead = 2)
rmse_3 = sqrt(mean((test[1:3] - armaGarch_1$meanForecast) ^ 2))
mape_3 = mean(abs((test[1:3] - armaGarch_1$meanForecast) / test[1:3])) * 100
paste(rmse_3, mape_3)

# 5 days ahead
armaGarch_5 = predict(armaGarch, n.ahead = 5)
rmse_5 = sqrt(mean((test[1:5] - armaGarch_5$meanForecast) ^ 2))
mape_5 = mean(abs((test[1:5] - armaGarch_5$meanForecast) / test[1:5])) * 100
paste(rmse_5, mape_5)

ts.plot(logreturns[4427:4562])
lines(ts(test[1:5], start=132), col="blue")
lines(ts(armaGarch_5$meanForecast, start=132), col="red")



# Pure ARCH (just for fun) --------------------------------------------------------------------


garch = garchFit(formula = ~ garch(1, 1),
                 data = train,
                 trace = FALSE)
summary(garch)

# 5 days ahead
garch_pred = predict(garch, n.ahead = 5)
garch_rmse_5 = sqrt(mean((test[1:5] - garch_pred$meanForecast) ^ 2))
garch_mape_5 = mean(abs((test[1:5] - garch_pred$meanForecast) / test[1:5])) * 100
paste(garch_rmse_5, garch_mape_5)




# GARCH another way (old) --------------------------------------------------------------------------------

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


# Function for comparing ARCH
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
