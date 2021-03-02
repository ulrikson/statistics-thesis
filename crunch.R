
# loading data
data = read.csv("data/clean_data.csv")
close = data$Close

# calculating returns
returns = diff(close)
logreturns = diff(log(close), lag = 1)

# setting first row to 0
data$returns <- 0
data$logreturns <- 0

data$returns <- c(0, returns)
data$logreturns <- c(0, logreturns)

write.csv(data, 'final.csv', row.names=FALSE)
