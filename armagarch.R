library(forecast)
library(aTSA)
library(fGarch)
library(urca)


# Loading data --------------------------------------------------------------------------------
data = read.csv('data/final.csv', header = TRUE)
data = subset(data, select = c('Exchange.Date', 'Close', 'logreturns'))

train_size = round(length(data$Close) * 0.75)
train = data[1:train_size, ]
test = data[(train_size+1):length(data$Close), ]

# Choosing close column and plotting
lr_train = train$logreturns
ts.plot(lr_train, xlab = "Day", ylab = "Closing price")
abline(a = 0, 0, col = "red")


# Stationarity --------------------------------------------------------------------------------

# Testing time series for stationarity
adf.test(lr_train, nlag=1)

adf_auto = ur.df(lr_train, selectlags = "AIC")
summary(adf_auto)

# Simulating stationary time series
stationary <- rnorm(100, 0, 100)
trend = 3*(1:100) + rnorm(100,0,10)

par(mfrow=c(1,2))

plot(
  stationary,
  type = 'l',
  xlab = 'Tid',
  ylab = expression('y'[t]),
  main = 'Stationär tidsserie'
)
plot(
  trend,
  type = 'l',
  xlab = 'Tid',
  ylab = expression('y'[t]),
  main = 'Icke-stationär tidsserie'
)

par(mfrow=c(1,1))

# Simulating non-stationary time series

# Plotting

# ARIMA -----------------------------------------------------------------------------

auto_arima = auto.arima(lr_train, ic = "bic", seasonal = FALSE)
arimaorder(auto_arima)
arima = arima(lr_train, c(1, 0, 1)) #  inserting into model (needed for arch.test)

arch.test(arima, output = TRUE) #  Heteroskedasticitet!

# ARMA-GARCH ---------------------------------------------------------------------------

fit_ics = function(p, q, x, y) {
  model = garchFit(substitute(~ arma(p, q) + garch(x, y),
                              list(
                                p = p,
                                q = q,
                                x = x,
                                y = y
                              )),
                   data = lr_train,
                   trace = FALSE)
  print(model@fit$ics)
}

# AIC, BIC
fit_ics(0,0,1,0) # -6.782130, -6.776750
fit_ics(0,0,1,1) # -6.937843, -6.930670
fit_ics(0,1,1,1) # -6.950833, -6.941867
fit_ics(1,0,1,1) # -6.953370, -6.944404
fit_ics(1,1,1,1) # -6.965158, -6.954399 !BEST!
fit_ics(1,1,2,1) # -6.964548, -6.951996
fit_ics(1,1,2,2) # -6.964357, -6.950011
fit_ics(2,1,2,2) # -6.964010, -6.947871
fit_ics(2,2,2,2) # -6.963515, -6.945582


# Best model, from above
arma_garch = garchFit(
  formula = ~ arma(1, 1) + garch(1, 1),
  data = lr_train,
  trace = FALSE
)
summary(arma_garch)

# 63 days ahead
arma_pred = predict(arma_garch, n.ahead = 63, plot=TRUE)
forecast = arma_pred$meanForecast
lower = arma_pred$lowerInterval
upper = arma_pred$upperInterval


# Creating merged df -------------------------------------------------------------------------

last_train = tail(train, 1)$Close
forecasted_price = exp(cumsum(forecast) + log(last_train))
lower_price = exp(cumsum(lower) + log(last_train))
upper_price = exp(cumsum(upper) + log(last_train))

df1 = data[1:train_size,]
df1$forecast = df1$Close
df1$lower = df1$Close
df1$upper = df1$Close

df2 = data[(train_size+1):(train_size+63),]
df2$forecast = forecasted_price
df2$lower = lower_price
df2$upper = upper_price

merged_df = rbind(df1, df2)
tail(merged_df)


# Writing to CSV for further analysis in Python -----------------------------------------------

write.csv(merged_df, "data/r_results.csv", row.names=FALSE)

