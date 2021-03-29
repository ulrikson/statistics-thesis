
statistics = read.csv('data/statistics.csv')
statistics_ts = ts(statistics$index, start=c(2010,1), frequency=12)
ml = read.csv('data/ml.csv')
ml_ts = ts(ml$index, start=c(2010,1), frequency = 12)


ts.plot(
  statistics_ts,
  ylim = c(0, 100),
  ylab = "Sökindex",
  xlab = "Tid",
  main = "Söktrender 2010-2020"
)
lines(ml_ts, col = "red")
legend(
  x = 'top',
  inset = c(-1, 0),
  legend = c("'statistics'", "'machine learning'"),
  col = c(1, 2),
  lty = c(1, 1),
  cex = 0.75
)


