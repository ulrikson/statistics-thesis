library(forecast)
library(aTSA)
library(fGarch)

data = read.csv('data/final.csv', header = TRUE)
data = subset(data, select = c('Exchange.Date', 'Close', 'logreturns'))

# Skapa en df med en column som är i, och en som är n.ahead

time = c()
Close = c()
forecast = c()
lower = c()
upper = c()

i = 1
while (i <= 100) {
  train_size = round(length(data$Close) * 0.75) + i - 1
  train = data[1:train_size, ]
  test = data[(train_size+1) : length(data$Close), ]
  
  lr_train = train$logreturns
  
  arma_garch = garchFit(
    formula = ~ arma(1, 1) + garch(1, 1),
    data = lr_train,
    trace = FALSE
  )
  
  arma_pred = predict(arma_garch, n.ahead = 63, plot=TRUE)
  last_train = tail(train, 1)$Close
  forecasted_price = exp(cumsum(arma_pred$meanForecast) + log(last_train))
  lower_price = exp(cumsum(arma_pred$lowerInterval) + log(last_train))
  upper_price = exp(cumsum(arma_pred$upperInterval) + log(last_train))
  
  time = c(time, rep(i, 63))
  Close = c(Close, head(test,63)$Close)
  forecast = c(forecast, forecasted_price)
  lower = c(lower, lower_price)
  upper = c(upper, upper_price)
  
  i = i+1
}
#* Note: The whole while process needs to finish before doing the following
#* This takes a while, it's done when the plots stop shifting...

df = data.frame(time, Close, forecast, lower, upper)


write.csv(df, "data/r_cross_val.csv", row.names=FALSE)


