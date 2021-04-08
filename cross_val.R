library(forecast)
library(aTSA)
library(fGarch)

data = read.csv('data/final.csv', header = TRUE)
data = subset(data, select = c('Exchange.Date', 'Close', 'logreturns'))

# Skapa en df med en column som är i, och en som är n.ahead

time = c()
Close = c()
forecast = c()

i = 1
forecast_len = 1000
while (i <= forecast_len) {
  train_size = round(length(data$Close) * 0.75) + i - 1
  train = data[1:train_size, ]
  test = data[(train_size+1) : length(data$Close), ]
  
  lr_train = train$logreturns
  
  arma_garch = garchFit(
    formula = ~ arma(1, 1) + garch(1, 1),
    data = lr_train,
    trace = FALSE
  )
  
  arma_pred = predict(arma_garch, n.ahead = 63)
  last_train = tail(train, 1)$Close
  forecasted_price = exp(cumsum(arma_pred$meanForecast) + log(last_train))
  
  time = c(time, rep(i, 63))
  Close = c(Close, head(test,63)$Close)
  forecast = c(forecast, forecasted_price)
  
  print(paste(i, "of", forecast_len))
  
  i = i+1
}
#* Note: Hela while-loopen måste köras innan man kan fortsätta
#* Kolla consolen, den printar vad den håller på med
#* Jag timeade, och 1000 bör ta ca. 10 min  att köra
#* Finns säkert smidigare sätt, men det är bara en engångsgrej

df = data.frame(time, Close, forecast)

write.csv(df, "data/r_cross_val.csv", row.names=FALSE)


