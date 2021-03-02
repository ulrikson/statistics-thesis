
# loading data
data = read.csv("data/clean_data.csv")
close = data$Close

# calculating returns
returns = diff(close, lag = 1)
logreturns = diff(log(close), lag = 1)

# setting first row to 0
data$returns <- 0
data$logreturns <- 0

# appending other rows
data$returns <- c(0, returns)
data$logreturns <- c(0, logreturns)

#write.csv(data, 'final.csv', row.names=FALSE)
