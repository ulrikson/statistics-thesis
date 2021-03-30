library(forecast)
library(aTSA)
library(fGarch)


# Loading data --------------------------------------------------------------------------------
data = read.csv('data/final.csv', header = TRUE)
data = subset(data, select = c('Exchange.Date', 'Close', 'logreturns'))

train_size = round(length(data$Close) * 0.75)
train = data[1:train_size, ]
test = data[train_size + 1:length(data$Close), ]

# Choosing close column and plotting
lr_train = train$logreturns
ts.plot(logreturns, xlab = "Day", ylab = "Closing price")
abline(a = 0, 0, col = "red")

# ARIMA -----------------------------------------------------------------------------

auto_arima = auto.arima(lr_train, ic = "bic", seasonal = FALSE)
arimaorder(auto_arima)
arima = arima(lr_train, c(1, 0, 1)) #  inserting into model (needed for arch.test)

plot(arima$residuals, type = "p", cex = 0.5) # Heteroskedasticitet?
arch.test(arima, output = TRUE) #  Heteroskedasticitet!

# ARMA-GARCH ---------------------------------------------------------------------------

armaGarch = garchFit(
  formula = ~ arma(1, 1) + garch(1, 1),
  data = lr_train,
  trace = FALSE
)
summary(armaGarch)
armaGarch@fit$ics

# 63 days ahead
armaGarch = predict(armaGarch, n.ahead = 63)
forecast = armaGarch$meanForecast


# Creating merged df -------------------------------------------------------------------------

last_train = tail(train, 1)$Close
forecasted_price = exp(cumsum(forecast) + log(last_train))

df1 = data[1:train_size,]
df1$forecast = df1$Close
df2 = data[(train_size+1):(train_size+63),]
df2$forecast = forecasted_price

merged_df = rbind(df1, df2)

write.csv(merged_df, "data/r_results.csv", row.names=FALSE)

