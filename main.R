library(forecast)


# Exploring data --------------------------------------------------------------------------------

# Reading data set (this is per day, and just for testing)
btc <- read.csv('BTCUSD_Week.csv')
head(btc)
ts.plot(btc$Close, xlab = "Week", ylab = "Closing price")

# nominator returns lagged difference, denominator removes last element
returns = diff(btc$Close) / btc$Close[-length(btc$Close)]
head(returns)
ts.plot(returns,
        xlab = "Day",
        ylab = "Returns (closing price)",
        main = "BTC returns (weekly)")
abline(a=0,0, col="red")


# Trying an ARIMA (for fun) -----------------------------------------------------------------------------

arima_returns = auto.arima(returns, ic = "bic", seasonal = F)
arima_price = auto.arima(btc$Close, ic = 'bic', seasonal = F)
summary(arima_returns)
summary(arima_price)


# Trying GARCH --------------------------------------------------------------------------------
