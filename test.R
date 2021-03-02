library(forecast)
library(rugarch)
library(readxl)
library(aTSA)


# Loading data --------------------------------------------------------------------------------

small <- read_excel('Small_cap_day.xlsx', col_names = FALSE)
small = small[-(1:17),-(6:11)] #  removing unnecessary rows and columns
colnames(small) <- small[1, ] #  setting first row as column names
small = small[-1, ] #  removing duplicate of header
small = small[order(small$`Exchange Date`), ] #  sorting by date ASC
small = as.data.frame(small) #  converting to dataframe
small[, (1:5)] <- apply(small[, (1:5)], 2,
                        function(x)
                          as.numeric(as.character(x))) #  converting columns to numeric
head(small)

write.csv(small, 'data/clean_data.csv', row.names = FALSE)

# Choosing close column and plotting
close = small$Close
ts.plot(close, xlab = "Day", ylab = "Closing price")

# Converting to returns
returns = diff(close)
head(returns)

ts.plot(returns,
        xlab = "Day",
        ylab = "Returns (closing price)",
        main = "Returns")
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


