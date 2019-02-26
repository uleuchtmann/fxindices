# main file as working horse for the project: testing, development etc.

library(timeSeries)

# read in FX data from FX.Rdata, extract EURUSD
setRmetricsOptions(myFinCenter = "New_York")
load("FX.RData")
EURUSD <- window(FX[, "EURUSD"], "2007-12-31 18:00:00", "2019-01-08 08:00:00")
rm(FX)


source("methods.R")
e <- log(EURUSD)

plot(H(e, stat="bi", resolution.high="30 mins", low=3, N.low=48))
acf(na.omit(H(e, stat="bi", resolution.high="30 mins", low=3, N.low=72)))
tail(H(e, stat="bi", resolution.high="30 mins", low=3, N.low=48), n=250)
