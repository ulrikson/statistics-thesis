library(forecast)
library(rugarch)


# Exploring data --------------------------------------------------------------------------------

#* Reading data set (this is per day, and just for testing)
btc <- read.csv('BTCUSD_Day.csv')
tail(btc)
ts.plot(btc$Close, xlab = "Day", ylab = "Closing price")

#* nominator returns lagged difference, denominator removes last element
returns = diff(btc$Close) / btc$Close[-length(btc$Close)]
head(returns)
ts.plot(returns,
        xlab = "Day",
        ylab = "Returns (closing price)",
        main = "BTC returns (daily)")
abline(a=0,0, col="red")

#* Splitting into train and test

train = ts(returns[1:387], start=c(2019,365), frequency = 365)
test = ts(returns[388:397], start=c(2021,22), frequency = 365)

# Trying an ARIMA (for fun) -----------------------------------------------------------------------------

arima_returns = auto.arima(train, ic = "bic", seasonal = FALSE)
summary(arima_returns)


# Trying GARCH --------------------------------------------------------------------------------

#* simple 1.1
spec.1 = ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)))
fit.1 = ugarchfit(spec = spec.1, data = train)
#print(fit.1)
infocriteria(fit.1)

